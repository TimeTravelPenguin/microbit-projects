//! A library for the MonkMakes micro:bit products.

#![no_std]
#![allow(dead_code)]

mod products;

#[cfg(feature = "seven_seg")]
pub use products::seven_segment;

#[cfg(feature = "sensor")]
pub use products::sensor_board;
