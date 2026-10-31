//! Module for the MonkMakes [Sensor Board].
//!
//! [Sensor Board]: https://monkmakes.com/mb_sensor

#[cfg(feature = "async")]
pub mod r#async;

#[cfg(feature = "blocking")]
pub mod blocking;
