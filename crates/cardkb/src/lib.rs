#![no_std]

#[cfg(feature = "async")]
pub mod r#async;

#[cfg(feature = "blocking")]
pub mod blocking;

pub mod key;

use key::DecodeError;
pub use key::{Key, KeyExt, decode_key};

#[cfg(all(feature = "async", not(feature = "blocking")))]
pub use r#async::CardKb;

#[cfg(all(feature = "blocking", not(feature = "async")))]
pub use blocking::CardKb;

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
