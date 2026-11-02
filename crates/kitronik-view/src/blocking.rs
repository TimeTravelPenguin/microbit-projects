//! Blocking initialization over an application-provided I²C bus.

use embedded_hal::i2c::I2c;
use ssd1306::{
    Ssd1306,
    mode::{BufferedGraphicsMode, DisplayConfig},
    prelude::I2CInterface,
    size::{DisplaySize, DisplaySize128x64},
};

use crate::{DISPLAY_I2C_ADDR, DisplayError, DisplayRotation};

/// A buffered SSD1306 display that owns its I²C bus.
pub type Oled<I2c, Size = DisplaySize128x64> =
    Ssd1306<I2CInterface<I2c>, Size, BufferedGraphicsMode<Size>>;

/// Initialize the OLED, clear its pixels, and turn the display on.
///
/// The display uses address `0x3C` and no rotation. Bus failures during
/// initialization, clearing, or enabling the display are returned to the caller.
pub fn init_display<I2cBus, Size>(
    bus: I2cBus,
    size: Size,
) -> Result<Oled<I2cBus, Size>, DisplayError>
where
    I2cBus: I2c,
    Size: DisplaySize,
{
    let interface = I2CInterface::new(bus, DISPLAY_I2C_ADDR, 0x40);
    let mut display =
        Ssd1306::new(interface, size, DisplayRotation::Rotate0).into_buffered_graphics_mode();

    display.init()?;
    display.clear_buffer();
    display.flush()?;
    display.set_display_on(true)?;

    Ok(display)
}
