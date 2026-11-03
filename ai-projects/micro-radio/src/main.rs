#![no_std]
#![no_main]

use core::str;
use embassy_executor::Spawner;
use embassy_futures::select::{Either, select};
use embassy_nrf::{
    bind_interrupts,
    config::{Config, HfclkSource},
    gpio::{Input, Level, Output, OutputDrive, Pull},
    peripherals, radio,
    radio::ieee802154::{Packet, Radio},
};

use embassy_sync::{blocking_mutex::raw::ThreadModeRawMutex, channel::Channel, signal::Signal};
use embassy_time::Timer;
use panic_rtt_target as _;
use rtt_target::{ChannelMode, rprintln, rtt_init_print};

bind_interrupts!(struct Irqs {
    RADIO => radio::InterruptHandler<peripherals::RADIO>;
});

// Button tasks queue messages; only main owns the radio.
static OUTGOING: Channel<ThreadModeRawMutex, &'static str, 4> = Channel::new();
// Several receptions can share one visual notification.
static RECEIVED: Signal<ThreadModeRawMutex, ()> = Signal::new();

const RECEIVED_IMAGE: [[u8; 5]; 5] = [
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 1],
    [0, 0, 0, 1, 0],
    [1, 0, 1, 0, 0],
    [0, 1, 0, 0, 0],
];

#[embassy_executor::main]
async fn main(spawner: Spawner) {
    rtt_init_print!(ChannelMode::NoBlockSkip);

    let mut config = Config::default();
    config.hfclk_source = HfclkSource::ExternalXtal;
    let peripherals = embassy_nrf::init(config);

    let button_a = Input::new(peripherals.P0_14, Pull::None);
    let button_b = Input::new(peripherals.P0_23, Pull::None);
    spawner.spawn(button_task(button_a, "HELLO").unwrap());
    spawner.spawn(button_task(button_b, "WORLD").unwrap());

    // The micro:bit V2's LED matrix has active-high rows and active-low columns.
    let rows = [
        Output::new(peripherals.P0_21, Level::Low, OutputDrive::Standard),
        Output::new(peripherals.P0_22, Level::Low, OutputDrive::Standard),
        Output::new(peripherals.P0_15, Level::Low, OutputDrive::Standard),
        Output::new(peripherals.P0_24, Level::Low, OutputDrive::Standard),
        Output::new(peripherals.P0_19, Level::Low, OutputDrive::Standard),
    ];

    let columns = [
        Output::new(peripherals.P0_28, Level::High, OutputDrive::Standard),
        Output::new(peripherals.P0_11, Level::High, OutputDrive::Standard),
        Output::new(peripherals.P0_31, Level::High, OutputDrive::Standard),
        Output::new(peripherals.P1_05, Level::High, OutputDrive::Standard),
        Output::new(peripherals.P0_30, Level::High, OutputDrive::Standard),
    ];

    spawner.spawn(display_task(rows, columns).unwrap());

    let mut radio = Radio::new(peripherals.RADIO, Irqs);
    radio.set_channel(11);
    radio.set_transmission_power(0);
    let mut incoming = Packet::new();

    rprintln!("micro-radio ready: Embassy, channel 11, 0 dBm");
    rprintln!("A sends HELLO; B sends WORLD. Listening...");

    loop {
        // Wait for either a received packet or a message queued by a button.
        // select drops the other future; receive safely stops its DMA on drop.
        let event = select(radio.receive(&mut incoming), OUTGOING.receive()).await;

        match event {
            Either::First(Ok(())) => {
                match str::from_utf8(&incoming) {
                    Ok(message) => {
                        rprintln!("RX: {}", message);
                    }
                    Err(_) => {
                        rprintln!("RX bytes: {:02X?}", &*incoming);
                    }
                }

                RECEIVED.signal(());
            }
            Either::First(Err(error)) => {
                rprintln!("RX error: {:?}", error);
            }
            Either::Second(message) => {
                send_message(&mut radio, message).await;
            }
        }
    }
}

#[embassy_executor::task(pool_size = 2)]
async fn button_task(mut button: Input<'static>, message: &'static str) {
    loop {
        // A/B are active low, with external pull-ups on the board.
        button.wait_for_low().await;
        Timer::after_millis(20).await;

        if button.is_high() {
            continue;
        }

        OUTGOING.send(message).await;

        // A held button sends once. Debounce release before waiting for another press.
        loop {
            button.wait_for_high().await;
            Timer::after_millis(20).await;

            if button.is_high() {
                break;
            }
        }
    }
}

#[embassy_executor::task]
async fn display_task(mut rows: [Output<'static>; 5], mut columns: [Output<'static>; 5]) {
    loop {
        RECEIVED.wait().await;
        let mut frames_left = 20;

        while frames_left > 0 {
            if RECEIVED.try_take().is_some() {
                frames_left = 20;
            }

            for (row, pixels) in rows.iter_mut().zip(RECEIVED_IMAGE) {
                for (column, pixel) in columns.iter_mut().zip(pixels) {
                    column.set_level(if pixel == 0 { Level::High } else { Level::Low });
                }

                row.set_high();
                Timer::after_millis(2).await;
                row.set_low();
            }

            frames_left -= 1;
        }

        for column in &mut columns {
            column.set_high();
        }
    }
}

async fn send_message(radio: &mut Radio<'_>, message: &str) {
    let mut outgoing = Packet::new();
    outgoing.copy_from_slice(message.as_bytes());

    // Await TX to completion: do not cancel a transmission with another select.
    // Success still means local transmission, not acknowledgement from a peer.
    match radio.try_send(&mut outgoing).await {
        Ok(()) => {
            rprintln!("TX: {}", message);
        }
        Err(radio::Error::ChannelInUse) => {
            rprintln!("TX busy: {} was not sent; press again", message);
        }
        Err(error) => {
            rprintln!("TX error: {:?}", error);
        }
    }
}
