//! The reusable micro:bit V2 power-management protocol.
//!
//! New applications can use `microbit_power::power_off!` to configure the board
//! and let `PowerOff::run` handle the checks around their application steps.

pub use microbit_power::{Error, PowerManager};
