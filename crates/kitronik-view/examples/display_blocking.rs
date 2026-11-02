//! Draw a counter on the Kitronik :VIEW using blocking I²C.
//!
//! Connect SDA to edge P20 (P1.00), SCL to edge P19 (P0.26), plus 3V and GND.

#![no_std]
#![no_main]

use cortex_m_rt::entry;
use embassy_nrf as _;
use embedded_graphics::{
    mono_font::{MonoTextStyle, ascii::FONT_6X10},
    pixelcolor::BinaryColor,
    prelude::*,
    primitives::{PrimitiveStyle, Rectangle},
    text::Text,
};
use heapless::format;
use kitronik_view::{DISPLAY_SIZE, blocking::init_display};
use nrf52833_hal::{
    Timer, Twim,
    clocks::Clocks,
    gpio::{p0, p1},
    pac::Peripherals,
    twim::{Frequency, Pins},
};
use panic_rtt_target as _;
use rtt_target::{rprintln, rtt_init_print};

#[entry]
fn main() -> ! {
    rtt_init_print!();

    let peripherals = Peripherals::take().expect("Peripherals already taken");
    let _clocks = Clocks::new(peripherals.CLOCK).enable_ext_hfosc();
    let port0 = p0::Parts::new(peripherals.P0);
    let port1 = p1::Parts::new(peripherals.P1);
    let mut timer = Timer::new(peripherals.TIMER0);

    let bus = Twim::new(
        peripherals.TWIM0,
        Pins {
            scl: port0.p0_26.into_floating_input().degrade(),
            sda: port1.p1_00.into_floating_input().degrade(),
        },
        Frequency::K400,
    );

    let mut display = init_display(bus, DISPLAY_SIZE).expect("Failed to initialize :VIEW");
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
        Text::new("Blocking I2C", Point::new(5, 28), text_style)
            .draw(&mut display)
            .expect("Failed to draw mode");

        let text = format!(20; "Count: {}", count).expect("Counter text exceeds capacity");
        Text::new(&text, Point::new(5, 50), text_style)
            .draw(&mut display)
            .expect("Failed to draw counter");
        display.flush().expect("Failed to flush :VIEW");
        rprintln!("Displayed count: {}", count);

        count = count.wrapping_add(1);
        timer.delay(1_000_000);
    }
}
