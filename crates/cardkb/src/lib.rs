#![no_std]

#[cfg(feature = "async")]
pub mod r#async;

#[cfg(feature = "blocking")]
pub mod blocking;

pub mod key;

use key::DecodeError;
pub use key::{Key, decode_key};

pub const CARDKB_I2C_ADDR: u8 = 0x5F;

/// A failed bus transaction or an unsupported CardKB output value.
#[derive(Debug, thiserror::Error)]
pub enum Error<I2CError> {
    #[error("I2C transaction failed: {0:?}")]
    I2C(I2CError),
    #[error(transparent)]
    Decode(DecodeError),
}

#[cfg(all(test, any(feature = "blocking", feature = "async")))]
mod tests;
