//! Asynchronous control of a display through an owned Embassy UART transmitter.

use core::fmt;

use embassy_nrf::{
    Peri,
    gpio::Pin,
    interrupt::typelevel::Binding,
    uarte::{self, Baudrate, Config, Instance, InterruptHandler, Parity, UarteTx},
};

/// A 7 segment display that owns its configured UART transmitter.
///
/// Commands complete after their bytes have been transmitted. Construction does
/// not wait for the display to power up; allow its startup time in the application
/// before sending the first command.
pub struct SevenSegment<'d> {
    uart: UarteTx<'d>,
}

impl<'d> SevenSegment<'d> {
    /// Take ownership of a UART peripheral, its interrupt binding, and a TX pin.
    ///
    /// The UART uses 9600 baud, no parity, and no hardware flow control. No receive
    /// pin is required because communication with the display is transmit only.
    pub fn new<Peripheral: Instance>(
        peripheral: Peri<'d, Peripheral>,
        irq: impl Binding<Peripheral::Interrupt, InterruptHandler<Peripheral>> + 'd,
        tx_pin: Peri<'d, impl Pin>,
    ) -> Self {
        let mut config = Config::default();
        config.baudrate = Baudrate::Baud9600;
        config.parity = Parity::Excluded;
        let uart = UarteTx::new(peripheral, irq, tx_pin, config);

        Self { uart }
    }

    /// Send the display's `/` clear command.
    #[expect(
        clippy::unnecessary_mut_passed,
        reason = "The mutable borrow prevents promotion of the EasyDMA buffer to flash."
    )]
    pub async fn clear(&mut self) -> Result<(), uarte::Error> {
        let mut command = *b"/";
        self.uart.write(&mut command).await
    }

    /// Send the text's UTF-8 bytes unchanged, using a bounded RAM buffer.
    ///
    /// The display interprets `/` and `,` according to its protocol. This method
    /// adds no commands or terminators, and an empty string sends nothing. UART
    /// failures are reported as [`core::fmt::Error`].
    pub async fn display(&mut self, s: &str) -> Result<(), fmt::Error> {
        let mut buffer = [0u8; 16];

        for chunk in s.as_bytes().chunks(buffer.len()) {
            buffer[..chunk.len()].copy_from_slice(chunk);
            self.uart
                .write(&buffer[..chunk.len()])
                .await
                .map_err(|_| fmt::Error)?;
        }

        Ok(())
    }
}
