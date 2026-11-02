//! Read the sensor board with Embassy.
//!
//! Wire sound to edge P0 (P0.02), temperature to P1 (P0.03), light to P2
//! (P0.04), and connect 3V and GND. The board and ADC must share their supply.

#![no_std]
#![no_main]

use embassy_executor::Spawner;
use embassy_nrf::{bind_interrupts, saadc};
use embassy_time::Timer;
use monkmakes::sensor_board::r#async::SensorBoard;
use panic_rtt_target as _;
use rtt_target::{rprintln, rtt_init_print};

bind_interrupts!(struct Irqs {
    SAADC => saadc::InterruptHandler;
});

#[embassy_executor::main]
async fn main(_spawner: Spawner) {
    rtt_init_print!();

    let peripherals = embassy_nrf::init(Default::default());
    let mut sensors = SensorBoard::new(
        peripherals.SAADC,
        Irqs,
        peripherals.P0_02,
        peripherals.P0_03,
        peripherals.P0_04,
    )
    .await;

    let mut sound_samples = [0_i16; 128];

    loop {
        let raw = sensors.read_raw().await.unwrap();
        rprintln!("Raw sound/temp/light: {:?}", raw);

        match raw.convert() {
            Ok(readings) => {
                rprintln!("Converted: {:?}", readings);
            }
            Err(error) => {
                rprintln!("Conversion failed: {:?}", error);
            }
        }

        let sound_level = sensors.read_sound_level(&mut sound_samples).await.unwrap();
        rprintln!("Sound peak-to-peak fraction: {}", sound_level);
        Timer::after_millis(500).await;
    }
}
