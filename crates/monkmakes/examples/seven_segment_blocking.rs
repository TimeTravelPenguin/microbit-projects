//! Count on the display using the blocking UART driver.
//!
//! Connect edge P0 (P0.02) to display RX/arrow, plus 3V and GND. P0.03 is
//! reserved as the HAL's unused RX pin and needs no display connection.

#![no_std]
#![no_main]

use cortex_m_rt::entry;
use embassy_nrf as _;
use heapless::format;
use monkmakes::seven_segment::blocking::SevenSegment;
use nrf52833_hal::{Timer, clocks::Clocks, gpio::p0, pac::Peripherals};
use panic_rtt_target as _;
use rtt_target::{rprintln, rtt_init_print};

#[entry]
fn main() -> ! {
    rtt_init_print!();

    let peripherals = Peripherals::take().unwrap();
    let _clocks = Clocks::new(peripherals.CLOCK).enable_ext_hfosc();
    let pins = p0::Parts::new(peripherals.P0);

    let mut board = SevenSegment::new(
        peripherals.UARTE0,
        pins.p0_02.degrade(),
        pins.p0_03.degrade(),
    );

    let mut timer = Timer::new(peripherals.TIMER0);
    timer.delay(100_000);

    board.clear().unwrap();
    board.display(",").unwrap();

    let mut value: u8 = 0;
    timer.start(1_000_000);

    loop {
        if timer.reset_if_finished() {
            rprintln!("Displaying value: {}", value);
            let display_str = format!(2; "{},", value).unwrap();
            board.display(&display_str).unwrap();
            value = (value + 1) % 10;

            timer.start(1_000_000);
        }
    }
}
