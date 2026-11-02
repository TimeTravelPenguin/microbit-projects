//! Blocking control of a display through an owned nRF52833 UART.

use core::fmt::Write;

use nrf52833_hal::{
    gpio::{Disconnected, Level, Pin},
    uarte::{self, Baudrate, Instance, Parity, Uarte},
};

/// A 7 segment display that owns its configured UART peripheral.
///
/// Commands complete after their bytes have been transmitted. Construction does
/// not wait for the display to power up; allow its startup time in the application
/// before sending the first command.
pub struct SevenSegment<Peripheral> {
    uart: Uarte<Peripheral>,
}

impl<Peripheral: Instance> SevenSegment<Peripheral> {
    /// Take ownership of a UART peripheral and its transmit and receive pins.
    ///
    /// The UART uses 9600 baud, no parity, and no hardware flow control. The
    /// blocking HAL requires a receive pin even though the display only receives
    /// data; that pin does not need an electrical connection to the display.
    pub fn new(
        peripheral: Peripheral,
        tx_pin: Pin<Disconnected>,
        rx_pin: Pin<Disconnected>,
    ) -> Self {
        let uart = Uarte::new(
            peripheral,
            uarte::Pins {
                txd: tx_pin.into_push_pull_output(Level::High),
                rxd: rx_pin.into_floating_input(),
                cts: None,
                rts: None,
            },
            Parity::EXCLUDED,
            Baudrate::BAUD9600,
        );

        Self { uart }
    }

    /// Send the display's `/` clear command.
    #[expect(
        clippy::unnecessary_mut_passed,
        reason = "The mutable borrow prevents promotion of the EasyDMA buffer to flash."
    )]
    pub fn clear(&mut self) -> Result<(), uarte::Error> {
        let mut command = *b"/";
        self.uart.write(&mut command)
    }

    /// Send the text's UTF-8 bytes unchanged, using bounded RAM buffers.
    ///
    /// The display interprets `/` and `,` according to its protocol. This method
    /// adds no commands or terminators, and an empty string sends nothing. UART
    /// failures are reported as [`core::fmt::Error`].
    pub fn display(&mut self, s: &str) -> Result<(), core::fmt::Error> {
        self.uart.write_str(s)
    }
}
