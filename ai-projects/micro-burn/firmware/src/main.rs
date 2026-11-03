#![no_std]
#![no_main]

use core::sync::atomic::{AtomicBool, Ordering};

use embassy_executor::Spawner;
use embassy_futures::{
    join::join,
    select::{Either, Either3, select, select3},
};
use embassy_nrf::{
    bind_interrupts,
    config::{Config, HfclkSource},
    gpio::{Input, Pull},
    interrupt::{self, InterruptExt, Priority},
    peripherals,
    pwm::{DutyCycle, Prescaler, SimpleConfig, SimplePwm},
    rng,
    twim::{self, Twim},
};
use embassy_sync::{
    blocking_mutex::raw::{NoopRawMutex, ThreadModeRawMutex},
    channel::Channel,
    signal::Signal,
};
use embassy_time::{Instant, Timer};
use micro_burn::protocol::{
    ActionResult, CONTROL_UUID, DeviceEvent, DeviceStatus, EVENTS_UUID, Frame, SERVICE_UUID,
    STATUS_UUID, Snapshot, SnapshotAssembler, TELEMETRY_UUID,
};
use micro_burn_firmware::{Button, Pager};
use microbit_input::Buttons;
use nrf_sdc::{self as sdc, mpsl};
use panic_rtt_target as _;
use rtt_target::{rprintln, rtt_init_print};
use static_cell::StaticCell;
use trouble_host::prelude::*;

// These mailboxes are accessed only by tasks on the same thread-mode executor.
static SNAPSHOTS: Signal<ThreadModeRawMutex, Snapshot> = Signal::new();
static ACTION_RESULTS: Signal<ThreadModeRawMutex, ActionResult> = Signal::new();
static DEVICE_STATUS: Signal<ThreadModeRawMutex, Frame> = Signal::new();
static SOUND: Signal<ThreadModeRawMutex, bool> = Signal::new();
static BUTTONS: Channel<ThreadModeRawMutex, Button, 16> = Channel::new();
static EVENTS: Channel<ThreadModeRawMutex, DeviceEvent, 8> = Channel::new();
static CONNECTED: AtomicBool = AtomicBool::new(false);

bind_interrupts!(struct Irqs {
    RNG => rng::InterruptHandler<peripherals::RNG>;
    EGU0_SWI0 => mpsl::LowPrioInterruptHandler;
    CLOCK_POWER => mpsl::ClockInterruptHandler;
    RADIO => mpsl::HighPrioInterruptHandler;
    TIMER0 => mpsl::HighPrioInterruptHandler;
    RTC0 => mpsl::HighPrioInterruptHandler;
    TWISPI0 => twim::InterruptHandler<peripherals::TWISPI0>;
});

#[gatt_server(connections_max = 1, mutex_type = NoopRawMutex, attribute_table_size = 32)]
struct Server {
    pager: PagerService,
}

#[gatt_service(uuid = SERVICE_UUID)]
struct PagerService {
    #[characteristic(uuid = TELEMETRY_UUID, write, write_without_response)]
    telemetry: Frame,
    #[characteristic(uuid = CONTROL_UUID, write)]
    control: Frame,
    #[characteristic(uuid = EVENTS_UUID, notify)]
    events: Frame,
    #[characteristic(uuid = STATUS_UUID, read)]
    status: Frame,
}

#[embassy_executor::task]
async fn mpsl_task(layer: &'static mpsl::MultiprotocolServiceLayer<'static>) -> ! {
    layer.run().await
}

#[embassy_executor::main]
async fn main(spawner: Spawner) {
    rtt_init_print!();

    let mut config = Config::default();
    config.hfclk_source = HfclkSource::ExternalXtal;
    config.time_interrupt_priority = Priority::P2;
    let peripherals = embassy_nrf::init(config);

    // MPSL owns RTC0/TIMER0/TEMP and the listed PPI channels. Embassy uses RTC1.
    let mpsl_peripherals = mpsl::Peripherals::new(
        peripherals.RTC0,
        peripherals.TIMER0,
        peripherals.TEMP,
        peripherals.PPI_CH19,
        peripherals.PPI_CH30,
        peripherals.PPI_CH31,
    );

    let clock = mpsl::raw::mpsl_clock_lfclk_cfg_t {
        source: mpsl::raw::MPSL_CLOCK_LF_SRC_RC as u8,
        rc_ctiv: mpsl::raw::MPSL_RECOMMENDED_RC_CTIV as u8,
        rc_temp_ctiv: mpsl::raw::MPSL_RECOMMENDED_RC_TEMP_CTIV as u8,
        accuracy_ppm: mpsl::raw::MPSL_DEFAULT_CLOCK_ACCURACY_PPM as u16,
        skip_wait_lfclk_started: false,
    };

    static MPSL: StaticCell<mpsl::MultiprotocolServiceLayer> = StaticCell::new();
    let layer = MPSL.init(
        mpsl::MultiprotocolServiceLayer::new(mpsl_peripherals, Irqs, clock)
            .expect("initialize Nordic radio timing"),
    );
    spawner.spawn(mpsl_task(layer).expect("create MPSL task"));

    let mut display_config = twim::Config::default();
    display_config.frequency = twim::Frequency::K400;
    interrupt::TWISPI0.set_priority(Priority::P2);
    interrupt::RNG.set_priority(Priority::P2);
    let display_bus = Twim::new(
        peripherals.TWISPI0,
        Irqs,
        peripherals.P1_00,
        peripherals.P0_26,
        display_config,
        &mut [],
    );
    spawner.spawn(display_task(display_bus).expect("create display task"));
    spawner.spawn(
        button_task(
            Input::new(peripherals.P0_14, Pull::None),
            Input::new(peripherals.P0_23, Pull::None),
        )
        .expect("create button task"),
    );

    let mut speaker_config = SimpleConfig::default();
    speaker_config.prescaler = Prescaler::Div1;
    speaker_config.max_duty = 8_000;
    let speaker = SimplePwm::new_1ch(peripherals.PWM0, peripherals.P0_00, &speaker_config);
    spawner.spawn(sound_task(speaker).expect("create speaker task"));

    let sdc_peripherals = sdc::Peripherals::new(
        peripherals.PPI_CH17,
        peripherals.PPI_CH18,
        peripherals.PPI_CH20,
        peripherals.PPI_CH21,
        peripherals.PPI_CH22,
        peripherals.PPI_CH23,
        peripherals.PPI_CH24,
        peripherals.PPI_CH25,
        peripherals.PPI_CH26,
        peripherals.PPI_CH27,
        peripherals.PPI_CH28,
        peripherals.PPI_CH29,
    );

    let mut rng = rng::Rng::new(peripherals.RNG, Irqs);
    // Keep this board's selected identity across resets. The factory address is
    // random per device; setting its top bits selects the static-random type.
    let address_low = embassy_nrf::pac::FICR.deviceaddr(0).read().to_le_bytes();
    let address_high = embassy_nrf::pac::FICR.deviceaddr(1).read().to_le_bytes();
    let address = [
        address_low[0],
        address_low[1],
        address_low[2],
        address_low[3],
        address_high[0],
        address_high[1] | 0xc0,
    ];

    let mut controller_memory = sdc::Mem::<8_192>::new();
    let controller = sdc::Builder::new()
        .expect("initialize Bluetooth controller")
        .support_adv()
        .support_peripheral()
        .peripheral_count(1)
        .expect("configure one connection")
        .buffer_cfg(128, 128, 3, 3)
        .expect("configure controller buffers")
        .build(sdc_peripherals, &mut rng, layer, &mut controller_memory)
        .expect("enable Bluetooth controller");

    let mut resources: HostResources<DefaultPacketPool, 1, 3> = HostResources::new();
    let stack = trouble_host::new(controller, &mut resources)
        .set_random_address(Address::random(address))
        .build();
    let mut runner = stack.runner();
    let mut peripheral = stack.peripheral();
    let server = Server::new_with_config(GapConfig::default("micro-burn"))
        .expect("create training GATT service");
    server
        .set(&server.pager.status, &DeviceStatus::default().encode())
        .expect("initialize device status");

    let service_bytes = SERVICE_UUID.to_le_bytes();
    let mut advertising = [0; 31];
    let advertising_len = AdStructure::encode_slice(
        &[
            AdStructure::Flags(LE_GENERAL_DISCOVERABLE | BR_EDR_NOT_SUPPORTED),
            AdStructure::CompleteServiceUuids128(&[service_bytes]),
        ],
        &mut advertising,
    )
    .expect("encode service advertisement");
    let mut scan_response = [0; 31];
    let scan_response_len = AdStructure::encode_slice(
        &[AdStructure::CompleteLocalName(b"micro-burn")],
        &mut scan_response,
    )
    .expect("encode scan response");

    let connections = async {
        loop {
            CONNECTED.store(false, Ordering::Relaxed);
            rprintln!("micro-burn advertising");
            let advertisement = Advertisement::ConnectableScannableUndirected {
                adv_data: &advertising[..advertising_len],
                scan_data: &scan_response[..scan_response_len],
            };

            let connection = match peripheral
                .advertise(&Default::default(), advertisement)
                .await
            {
                Ok(advertiser) => match advertiser.accept().await {
                    Ok(connection) => connection,
                    Err(error) => {
                        rprintln!("Connection failed: {:?}", error);
                        Timer::after_millis(500).await;

                        continue;
                    }
                },
                Err(error) => {
                    rprintln!("Advertising failed: {:?}", error);
                    Timer::after_millis(500).await;

                    continue;
                }
            };

            let connection = connection
                .with_attribute_server(&server)
                .expect("attach GATT server");
            let mut assembler = SnapshotAssembler::new();
            CONNECTED.store(true, Ordering::Relaxed);
            rprintln!("Laptop connected");

            loop {
                let next =
                    select3(connection.next(), EVENTS.receive(), Timer::after_millis(50)).await;

                if let Some(status) = DEVICE_STATUS.try_take() {
                    let _ = server.set(&server.pager.status, &status);
                }

                match next {
                    Either3::First(GattConnectionEvent::Disconnected { .. }) => break,
                    Either3::First(GattConnectionEvent::Gatt {
                        event: GattEvent::Write(write),
                    }) => {
                        let handle = write.handle();

                        if handle == server.pager.telemetry.handle
                            || handle == server.pager.control.handle
                        {
                            let decoded = write.with_data(|offset, data| {
                                if offset != 0 {
                                    return Err(());
                                }

                                if let Ok(result) = ActionResult::decode(data) {
                                    ACTION_RESULTS.signal(result);

                                    return Ok(());
                                }

                                match assembler.push(data, Instant::now().as_millis()) {
                                    Ok(Some(snapshot)) => SNAPSHOTS.signal(snapshot),
                                    Ok(None) => {}
                                    Err(_) => return Err(()),
                                }

                                Ok(())
                            });

                            let reply = if decoded.is_ok() {
                                write.accept()
                            } else {
                                write.reject(AttErrorCode::VALUE_NOT_ALLOWED)
                            };

                            if let Ok(reply) = reply {
                                reply.send().await;
                            }
                        } else if let Ok(reply) = write.accept() {
                            // Notification subscriptions write the CCCD descriptor.
                            reply.send().await;
                        }
                    }

                    Either3::First(GattConnectionEvent::Gatt { event }) => {
                        if let Ok(reply) = event.accept() {
                            reply.send().await;
                        }
                    }

                    Either3::Second(event) => {
                        if let Err(error) = server
                            .pager
                            .events
                            .notify(&connection, &event.encode(), true)
                            .await
                        {
                            rprintln!("Notification failed: {:?}", error);
                        }
                    }

                    _ => {}
                }
            }

            CONNECTED.store(false, Ordering::Relaxed);
            assembler.reset();
        }
    };

    let (result, ()) = join(runner.run(), connections).await;
    rprintln!("Bluetooth runner stopped: {:?}", result);
    panic!("Bluetooth host stopped");
}

#[embassy_executor::task]
async fn button_task(button_a: Input<'static>, button_b: Input<'static>) {
    let mut buttons = Buttons::new();

    loop {
        buttons.sample(button_a.is_low(), button_b.is_low());
        let presses = buttons.take_presses();

        if presses.button_a > 0 {
            let _ = BUTTONS.try_send(Button::A);
        }

        if presses.button_b > 0 {
            let _ = BUTTONS.try_send(Button::B);
        }

        Timer::after_millis(2).await;
    }
}

#[embassy_executor::task]
async fn display_task(bus: Twim<'static>) {
    let mut display = kitronik_view::r#async::init_display(bus, kitronik_view::DISPLAY_SIZE)
        .await
        .expect("initialize Kitronik VIEW");
    let mut pager = Pager::new();
    let mut last_draw_ms = 0;
    let mut last_retry_ms = 0;
    let mut sounding = false;
    let mut redraw = true;

    loop {
        let now_ms = Instant::now().as_millis();
        pager.set_connected(CONNECTED.load(Ordering::Relaxed));

        if let Some(snapshot) = SNAPSHOTS.try_take() {
            let receipt = pager.apply(snapshot, now_ms);
            let _ = EVENTS.try_send(receipt);
            redraw = true;
        }

        if let Some(result) = ACTION_RESULTS.try_take() {
            pager.action_result(result);
            redraw = true;
        }

        while let Ok(button) = BUTTONS.try_receive() {
            if let Some(action) = pager.press(button, now_ms) {
                if CONNECTED.load(Ordering::Relaxed) {
                    let _ = EVENTS.try_send(action);
                }
            }

            redraw = true;
        }

        if CONNECTED.load(Ordering::Relaxed) && now_ms.saturating_sub(last_retry_ms) >= 1_000 {
            if let Some(action) = pager.pending() {
                let _ = EVENTS.try_send(action);
            }

            last_retry_ms = now_ms;
        }

        DEVICE_STATUS.signal(pager.status().encode());
        let should_sound = pager.should_sound(now_ms);

        if should_sound != sounding {
            SOUND.signal(should_sound);
            sounding = should_sound;
        }

        if redraw || now_ms.saturating_sub(last_draw_ms) >= 1_000 {
            pager.draw(&mut display, now_ms).expect("draw pager");
            display.flush().await.expect("update VIEW");
            last_draw_ms = now_ms;
            redraw = false;
        }

        Timer::after_millis(10).await;
    }
}

#[embassy_executor::task]
async fn sound_task(mut speaker: SimplePwm<'static>) {
    let mut enabled = false;
    speaker.set_duty(0, DutyCycle::normal(0));

    loop {
        if !enabled {
            enabled = SOUND.wait().await;

            continue;
        }

        speaker.set_duty(0, DutyCycle::normal(4_000));

        if let Either::Second(next) = select(Timer::after_millis(100), SOUND.wait()).await {
            enabled = next;
        }

        speaker.set_duty(0, DutyCycle::normal(0));

        if enabled {
            if let Either::Second(next) = select(Timer::after_millis(900), SOUND.wait()).await {
                enabled = next;
            }
        }
    }
}
