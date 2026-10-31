#![no_std]
#![no_main]

use cortex_m_rt::entry;
use heapless::format;
use monkmakes::seven_segment::blocking::SevenSegment;
use nrf52833_hal::{Timer, gpio::p0, pac::Peripherals};
use panic_rtt_target as _;
use rtt_target::{rprintln, rtt_init_print};

#[entry]
fn main() -> ! {
    rtt_init_print!();

    let peripherals = Peripherals::take().unwrap();
    let pins = p0::Parts::new(peripherals.P0);

    let mut board = SevenSegment::new(
        peripherals.UARTE0,
        pins.p0_02.degrade(),
        pins.p0_03.degrade(),
    );

    let mut timer = Timer::new(peripherals.TIMER0);
    timer.start(1_000_000);

    board.clear().unwrap();
    board.display(",").unwrap();

    let mut value: u8 = 0;
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
