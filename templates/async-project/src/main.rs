#![no_std]
#![no_main]

use embassy_executor::Spawner;
use embassy_nrf::config::{Config, HfclkSource};
use embassy_time::Timer;
use panic_rtt_target as _;
use rtt_target::{rprintln, rtt_init_print};

#[embassy_executor::main]
async fn main(_spawner: Spawner) {
    rtt_init_print!();

    let mut config = Config::default();
    config.hfclk_source = HfclkSource::ExternalXtal;

    let _peripherals = embassy_nrf::init(config);

    loop {
        rprintln!("__PROJECT_NAME__ is running");
        Timer::after_secs(1).await;
    }
}
