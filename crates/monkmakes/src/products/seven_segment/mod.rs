//! Module for the MonkMakes [7 Segment Display][seven_seg].
//!
//! [seven_seg]: https://monkmakes.com/mb_7_seg

#[cfg(feature = "async")]
pub mod r#async;

#[cfg(feature = "blocking")]
pub mod blocking;
