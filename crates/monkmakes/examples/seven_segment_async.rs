//! Count on the display with Embassy.
//!
//! Connect edge P0 (P0.02) to display RX/arrow, plus 3V and GND.

#![no_std]
#![no_main]

use embassy_executor::Spawner;
use embassy_nrf::{bind_interrupts, config::HfclkSource, uarte};
use embassy_time::Timer;
use heapless::format;
use monkmakes::seven_segment::r#async::SevenSegment;
use panic_rtt_target as _;

bind_interrupts!(struct Irqs {
    UARTE0 => uarte::InterruptHandler<embassy_nrf::peripherals::UARTE0>;
});

#[embassy_executor::main]
async fn main(_spawner: Spawner) {
    rtt_target::rtt_init_print!();

    let mut config = embassy_nrf::config::Config::default();
    config.hfclk_source = HfclkSource::ExternalXtal;
    let peripherals = embassy_nrf::init(config);
    let mut display = SevenSegment::new(peripherals.UARTE0, Irqs, peripherals.P0_02);

    Timer::after_millis(100).await;
    display.clear().await.unwrap();
    display.display(",").await.unwrap();

    let mut value = 0_u8;

    loop {
        let text = format!(5; "{:>4},", value).unwrap();
        display.display(&text).await.unwrap();
        value = (value + 1) % 10;
        Timer::after_secs(1).await;
    }
}
