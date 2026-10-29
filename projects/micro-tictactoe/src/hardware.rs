use cardkb::blocking::CardKb;
use display_interface::DisplayError;
use embedded_hal::i2c::I2c;
use microbit::pac;
use nrf52833_hal::{
    Twim,
    twim::{Frequency, Pins},
};
use ssd1306::{I2CDisplayInterface, Ssd1306, mode::BufferedGraphicsMode, prelude::*};

pub type Oled<I> =
    Ssd1306<I2CInterface<I>, DisplaySize128x64, BufferedGraphicsMode<DisplaySize128x64>>;

pub fn init_display(twim0: pac::TWIM0, pins: Pins) -> Oled<Twim<pac::TWIM0>> {
    let display_bus = Twim::new(twim0, pins, Frequency::K400);

    initialize_display(display_bus).expect("Failed to initialize display")
}

pub fn init_cardkb(twim1: pac::TWIM1, pins: Pins) -> CardKb<Twim<pac::TWIM1>> {
    let cardkb_bus = Twim::new(twim1, pins, Frequency::K100);

    CardKb::new(cardkb_bus)
}

fn initialize_display<I: I2c>(i2c: I) -> Result<Oled<I>, DisplayError> {
    let interface = I2CDisplayInterface::new(i2c);
    let mut display = Ssd1306::new(interface, DisplaySize128x64, DisplayRotation::Rotate0)
        .into_buffered_graphics_mode();

    display.init()?;
    display.clear_buffer();
    display.flush()?;
    display.set_display_on(true)?;

    Ok(display)
}
