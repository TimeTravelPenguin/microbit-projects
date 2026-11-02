//! Draw a counter on the Kitronik :VIEW using Embassy and async I²C.
//!
//! Connect SDA to edge P20 (P1.00), SCL to edge P19 (P0.26), plus 3V and GND.

#![no_std]
#![no_main]

use embassy_executor::Spawner;
use embassy_nrf::{
    bind_interrupts,
    config::{Config, HfclkSource},
    peripherals,
    twim::{self, Twim},
};
use embassy_time::Timer;
use embedded_graphics::{
    mono_font::{MonoTextStyle, ascii::FONT_6X10},
    pixelcolor::BinaryColor,
    prelude::*,
    primitives::{PrimitiveStyle, Rectangle},
    text::Text,
};
use heapless::format;
use kitronik_view::{DISPLAY_SIZE, r#async::init_display};
use panic_rtt_target as _;
use rtt_target::{rprintln, rtt_init_print};

bind_interrupts!(struct Irqs {
    TWISPI0 => twim::InterruptHandler<peripherals::TWISPI0>;
});

#[embassy_executor::main]
async fn main(_spawner: Spawner) {
    rtt_init_print!();

    let mut config = Config::default();
    config.hfclk_source = HfclkSource::ExternalXtal;

    let peripherals = embassy_nrf::init(config);
    let mut bus_config = twim::Config::default();
    bus_config.frequency = twim::Frequency::K400;
    let mut tx_buffer = [0_u8; 32];

    let bus = Twim::new(
        peripherals.TWISPI0,
        Irqs,
        peripherals.P1_00,
        peripherals.P0_26,
        bus_config,
        &mut tx_buffer,
    );

    let mut display = init_display(bus, DISPLAY_SIZE)
        .await
        .expect("Failed to initialize :VIEW");
    let text_style = MonoTextStyle::new(&FONT_6X10, BinaryColor::On);
    let mut count = 0_u32;

    loop {
        display.clear_buffer();

        Rectangle::new(Point::zero(), Size::new(128, 64))
            .into_styled(PrimitiveStyle::with_stroke(BinaryColor::On, 1))
            .draw(&mut display)
            .expect("Failed to draw border");
        Text::new("Kitronik :VIEW", Point::new(5, 14), text_style)
            .draw(&mut display)
            .expect("Failed to draw title");
        Text::new("Async I2C", Point::new(5, 28), text_style)
            .draw(&mut display)
            .expect("Failed to draw mode");

        let text = format!(20; "Count: {}", count).expect("Counter text exceeds capacity");
        Text::new(&text, Point::new(5, 50), text_style)
            .draw(&mut display)
            .expect("Failed to draw counter");
        display.flush().await.expect("Failed to flush :VIEW");
        rprintln!("Displayed count: {}", count);

        count = count.wrapping_add(1);
        Timer::after_secs(1).await;
    }
}
