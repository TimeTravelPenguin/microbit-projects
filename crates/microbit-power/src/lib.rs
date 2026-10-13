//! Cooperative reset-button power management for the micro:bit V2.
//!
//! Create a helper with [`power_off!`] immediately after taking the board, then
//! pass an application step to [`PowerOff::run`] or call [`PowerOff::check`] at a
//! safe boundary in your own loop. Setup allows a short grace period for a late
//! reset-button event before the application starts.
//!
//! Applications using the motion sensors can share the internal I²C controller
//! through [`SharedI2c`] and [`PowerOff::new_shared`]. They must call
//! [`PowerOff::check_startup_with`] before their first frame to include device
//! cleanup in startup shutdown handling.

#![no_std]

mod protocol;
mod shared_i2c;

pub use protocol::{Error, PowerManager};
pub use shared_i2c::SharedI2c;

#[cfg(feature = "hardware")]
mod hardware;

#[cfg(feature = "hardware")]
pub use hardware::{HardwareError, PowerOff};

/// Sets up reset-button power management before the application starts.
///
/// This partially moves the board's internal I²C bus, combined interrupt pin,
/// TIMER3, and POWER peripheral. The remaining board fields stay available.
/// Call `check()` regularly at a safe loop boundary after active DMA operations
/// finish. Use `check_with()` to stop application-specific asynchronous devices.
#[cfg(feature = "hardware")]
#[macro_export]
macro_rules! power_off {
    ($board:ident) => {{
        $crate::PowerOff::new(
            $board.TWIM0,
            $board.i2c_internal,
            $board.pins.p0_25,
            $board.TIMER3,
            $board.POWER,
        )
    }};
}
