//! Read the sensor board using the blocking ADC driver.
//!
//! Wire sound to edge P0 (P0.02), temperature to P1 (P0.03), light to P2
//! (P0.04), and connect 3V and GND. The board and ADC must share their supply.

#![no_std]
#![no_main]

use cortex_m_rt::entry;
use embassy_nrf as _;
use monkmakes::sensor_board::blocking::SensorBoard;
use nrf52833_hal::{Timer, gpio::p0, pac::Peripherals};
use panic_rtt_target as _;
use rtt_target::{rprintln, rtt_init_print};

#[entry]
fn main() -> ! {
    rtt_init_print!();

    let peripherals = Peripherals::take().unwrap();
    let pins = p0::Parts::new(peripherals.P0);
    let mut sensors = SensorBoard::new(peripherals.SAADC, pins.p0_02, pins.p0_03, pins.p0_04);

    let mut timer = Timer::new(peripherals.TIMER0);
    let mut sound_samples = [0_i16; 128];

    loop {
        let raw = sensors.read_raw().unwrap();
        rprintln!("Raw sound/temp/light: {:?}", raw);

        match raw.convert() {
            Ok(readings) => {
                rprintln!("Converted: {:?}", readings);
            }
            Err(error) => {
                rprintln!("Conversion failed: {:?}", error);
            }
        }

        let sound_level = sensors.read_sound_level(&mut sound_samples).unwrap();
        rprintln!("Sound peak-to-peak fraction: {}", sound_level);
        timer.delay(500_000);
    }
}
