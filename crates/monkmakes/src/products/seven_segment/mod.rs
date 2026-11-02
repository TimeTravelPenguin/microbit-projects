//! Module for the MonkMakes [7 Segment Display][seven_seg].
//!
//! Each driver owns and configures its UART at 9600 baud with no parity or
//! hardware flow control. The application chooses the peripheral and pins and
//! allows the display to finish powering up before sending commands.
//!
//! Both APIs send text unchanged: `/` and `,` retain the meanings assigned by the
//! display's protocol. No clearing, escaping, or terminators are added by
//! `display`.
//!
//! [seven_seg]: https://monkmakes.com/mb_7_seg

#[cfg(feature = "async")]
pub mod r#async;

#[cfg(feature = "blocking")]
pub mod blocking;
