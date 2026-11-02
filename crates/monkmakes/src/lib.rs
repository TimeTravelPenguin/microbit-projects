//! Drivers for the MonkMakes micro:bit seven-segment display and sensor board.
//!
//! Enable `seven_seg` or `sensor` to select a product. The `blocking` feature
//! (enabled by default) uses `nrf52833-hal`; `async` uses `embassy-nrf`.
//! Both modes may be enabled together and have separate modules.
//!
//! Constructors take ownership of peripherals and pins and configure the UART
//! or ADC internally. Applications retain responsibility for clocks, interrupt
//! bindings, startup delays, and scheduling. Sensor conversion formulas and
//! units are documented in `sensor_board` when the `sensor` feature is enabled.
//! The library leaves interrupt-vector selection to the application; the
//! standalone examples supply one nRF PAC runtime for both driver modes.

#![no_std]

mod products;

#[cfg(feature = "seven_seg")]
pub use products::seven_segment;

#[cfg(feature = "sensor")]
pub use products::sensor_board;
