use embedded_hal_async::i2c::I2c;

use crate::{CARDKB_I2C_ADDR, Error, Key, decode_key};

#[derive(Debug)]
pub struct CardKb<I> {
    buffer: [u8; 1],
    i2c: I,
}

impl<I: I2c> CardKb<I> {
    pub const fn new(i2c: I) -> Self {
        Self {
            buffer: [0u8; 1],
            i2c,
        }
    }

    /// Read one output value, returning `None` when no input is available.
    pub async fn read_key(&mut self) -> Result<Option<Key>, Error<I::Error>> {
        let raw_key = self.read_key_raw().await?;
        decode_key(raw_key).map_err(Error::Decode)
    }

    /// Read one output value as a raw byte.
    pub async fn read_key_raw(&mut self) -> Result<u8, Error<I::Error>> {
        self.i2c
            .read(CARDKB_I2C_ADDR, &mut self.buffer)
            .await
            .map_err(Error::I2C)?;

        Ok(self.buffer[0])
    }
}
