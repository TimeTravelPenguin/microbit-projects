//! Buffered OLED setup for the Kitronik :VIEW display.
//!
//! The `blocking` feature is enabled by default; `async` uses
//! `embedded-hal-async`. Both features may be enabled together, with their APIs
//! available through separate modules. Applications configure and provide the
//! I²C bus and retain responsibility for pins, interrupts, and scheduling.
//!
//! Each initializer returns the SSD1306 driver directly, so drawing uses its
//! existing `embedded-graphics` support and updates use `flush`.

#![no_std]

#[cfg(feature = "async")]
pub mod r#async;

#[cfg(feature = "blocking")]
pub mod blocking;

pub use display_interface::DisplayError;
pub use ssd1306::{rotation::DisplayRotation, size};

#[cfg(all(feature = "async", not(feature = "blocking")))]
pub use r#async::{Oled, init_display};

#[cfg(all(feature = "blocking", not(feature = "async")))]
pub use blocking::{Oled, init_display};

/// The Kitronik :VIEW OLED resolution.
pub const DISPLAY_SIZE: size::DisplaySize128x64 = size::DisplaySize128x64;

/// The Kitronik :VIEW OLED's 7-bit I²C address.
pub const DISPLAY_I2C_ADDR: u8 = 0x3C;

#[cfg(all(test, any(feature = "blocking", feature = "async")))]
mod tests;
