#![no_main]
#![no_std]

mod microphone;

use core::cell::RefCell;

use cortex_m_rt::entry;
use embedded_hal::{delay::DelayNs, digital::OutputPin};
use micro_view_audio::{Analyzer, AudioView, BLOCK_QUEUE_LEN};
use microbit::{
    hal::{
        Clocks, Timer, Twim,
        gpio::{Level, OpenDrainConfig, p0, p1},
        ppi,
        twim::{Frequency, Pins},
    },
    pac,
};
use microbit_input::input;
use microbit_power::PowerOff;
use panic_rtt_target as _;
use rtt_target::{rprintln, rtt_init_print};
use ssd1306::{Ssd1306, mode::BufferedGraphicsMode, prelude::*};

type Oled = Ssd1306<
    I2CInterface<Twim<pac::TWIM1>>,
    DisplaySize128x64,
    BufferedGraphicsMode<DisplaySize128x64>,
>;

const OLED_ADDRESS: u8 = 0x3C;
const FRAME_INTERVAL_US: u32 = 50_000;

#[entry]
fn main() -> ! {
    rtt_init_print!();

    let peripherals = pac::Peripherals::take().unwrap();
    let port0 = p0::Parts::new(peripherals.P0);
    let port1 = p1::Parts::new(peripherals.P1);
    let _clocks = Clocks::new(peripherals.CLOCK).enable_ext_hfosc();
    let ppi = ppi::Parts::new(peripherals.PPI);
    let mut delay = Timer::new(peripherals.TIMER1);

    // Use the BSP's high-drive microphone supply configuration, initially off.
    let mut mic_enable = port0
        .p0_20
        .into_open_drain_output(OpenDrainConfig::Disconnect0HighDrive1, Level::Low);

    let display_bus = Twim::new(
        peripherals.TWIM1,
        Pins {
            scl: port0.p0_26.into_floating_input().degrade(),
            sda: port1.p1_00.into_floating_input().degrade(),
        },
        Frequency::K400,
    );

    let interface = I2CInterface::new(display_bus, OLED_ADDRESS, 0x40);
    let mut oled = Some(
        Ssd1306::new(interface, DisplaySize128x64, DisplayRotation::Rotate0)
            .into_buffered_graphics_mode(),
    );

    let internal_bus = RefCell::new(Twim::new(
        peripherals.TWIM0,
        Pins {
            scl: port0.p0_08.into_floating_input().degrade(),
            sda: port0.p0_16.into_floating_input().degrade(),
        },
        Frequency::K100,
    ));

    let mut power = PowerOff::new_shared(
        &internal_bus,
        port0.p0_25,
        peripherals.TIMER3,
        peripherals.POWER,
    );

    // Include external-display cleanup for a power event posted after reset.
    power.check_startup_with(|| shutdown(&mut oled));

    oled.as_mut()
        .unwrap()
        .init()
        .expect("VIEW initialization failed: check power/address");

    input::initialise_with_logo(
        peripherals.TIMER2,
        port0.p0_14.into_floating_input(),
        port0.p0_23.into_floating_input(),
        port1
            .p1_04
            .into_open_drain_input_output(OpenDrainConfig::Standard0Disconnect1, Level::Low),
        peripherals.GPIOTE,
        ppi.ppi2,
    );

    mic_enable.set_high().unwrap();
    delay.delay_ms(100);
    microphone::initialise(
        peripherals.SAADC,
        peripherals.TIMER0,
        ppi.ppi0,
        ppi.ppi1,
        port0.p0_05.into_floating_input(),
        mic_enable,
    );

    let mut analyzer = Analyzer::new();
    let mut view = AudioView::new();
    let mut expected_sequence = None;
    let mut reported_drops = 0;
    let mut frame_dirty = true;
    let mut frame_timer = delay.into_periodic();
    frame_timer.start(FRAME_INTERVAL_US);

    rprintln!("Audio VIEW ready: A previous, B next, touch logo changes history");

    loop {
        // Capture uses a separate peripheral. Cleanup stops its DMA before
        // the power helper performs the handshake and enters System OFF.
        power.check_with(|| shutdown(&mut oled));

        let presses = input::take_presses();
        let logo_presses = input::take_logo_presses();
        let mode_changed = presses.button_a != 0 || presses.button_b != 0;
        let duration_changed = logo_presses != 0;

        for _ in 0..presses.button_a {
            view.previous_mode();
        }

        for _ in 0..presses.button_b {
            view.next_mode();
        }

        for _ in 0..logo_presses {
            view.next_duration();
        }

        frame_dirty |= mode_changed || duration_changed;

        // Bound catch-up work so input and power checks keep getting serviced.
        for _ in 0..BLOCK_QUEUE_LEN {
            let Some(block) = microphone::take_block() else {
                break;
            };

            if expected_sequence.is_some_and(|expected| block.sequence != expected) {
                analyzer.reset();
                view.reset_history();
                frame_dirty = true;
            }

            expected_sequence = Some(block.sequence.wrapping_add(1));

            if let Some(analysis) = analyzer.push(&block.samples) {
                view.update(analysis);
                frame_dirty = true;
            }
        }

        let dropped_blocks = microphone::dropped_blocks();

        if dropped_blocks != reported_drops {
            rprintln!("Audio capture queue dropped {} blocks", dropped_blocks);
            reported_drops = dropped_blocks;
        }

        let frame_due = frame_timer.reset_if_finished();

        if frame_dirty && (frame_due || mode_changed || duration_changed) {
            let display = oled.as_mut().unwrap();
            view.render(display).unwrap();
            display.flush().expect("VIEW write failed");
            frame_dirty = false;
        }

        // The 2 ms input interrupt wakes the foreground; audio DMA runs via PPI.
        cortex_m::asm::wfi();
    }
}

fn shutdown(oled: &mut Option<Oled>) {
    input::stop();
    microphone::stop();

    if let Some(mut display) = oled.take() {
        if let Err(error) = display.set_display_on(false) {
            rprintln!("VIEW shutdown failed: {:?}", error);
        }

        display.release().release().disable();
    }
}
