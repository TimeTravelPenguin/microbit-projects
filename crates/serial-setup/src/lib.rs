#![no_std]

use core::fmt;
use embedded_io::{Read, ReadReady, Write};
use microbit::hal::uarte::{self, Instance, Uarte, UarteRx, UarteTx};

pub struct UartePort<T: Instance>(UarteTx<T>, UarteRx<T>);

impl<T: Instance> UartePort<T> {
    pub fn new(serial: Uarte<T>) -> UartePort<T> {
        let tx_buf = cortex_m::singleton!(TX_BUF: [u8; 1] = [0u8; 1]).unwrap();
        let rx_buf = cortex_m::singleton!(RX_BUF: [u8; 1] = [0u8; 1]).unwrap();
        let (tx, rx) = serial.split(tx_buf, rx_buf).unwrap();
        UartePort(tx, rx)
    }
}

impl<T: Instance> fmt::Write for UartePort<T> {
    fn write_str(&mut self, s: &str) -> fmt::Result {
        self.0.write_str(s)
    }
}

impl<T: Instance> UartePort<T> {
    pub fn write(&mut self, b: u8) -> Result<(), uarte::Error> {
        self.0.write(&[b])?;
        Ok(())
    }

    pub fn write_all(&mut self, bytes: &[u8]) -> Result<(), uarte::Error> {
        self.0.write_all(bytes)
    }

    pub fn write_lf(&mut self) -> Result<(), uarte::Error> {
        self.write(b'\n')
    }

    pub fn write_crlf(&mut self) -> Result<(), uarte::Error> {
        self.write_all(b"\r\n")
    }

    pub fn flush(&mut self) -> Result<(), uarte::Error> {
        self.0.flush()
    }

    pub fn read(&mut self) -> Result<u8, uarte::Error> {
        let mut buf = [0u8; 1];
        self.1.read(&mut buf)?;
        Ok(buf[0])
    }

    pub fn try_read(&mut self) -> Result<Option<u8>, uarte::Error> {
        if !self.1.read_ready()? {
            return Ok(None);
        }

        self.read().map(Some)
    }
}
