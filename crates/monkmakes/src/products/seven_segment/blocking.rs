use core::fmt::Write;

use nrf52833_hal::{
    gpio::{Disconnected, Level, Pin},
    uarte::{self, Baudrate, Instance, Parity, Uarte},
};

pub struct SevenSegment<Peripheral> {
    uart: Uarte<Peripheral>,
}

impl<Peripheral: Instance> SevenSegment<Peripheral> {
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

    pub fn clear(&mut self) -> Result<(), uarte::Error> {
        let command = *b"/";
        self.uart.write(&command)
    }

    pub fn display(&mut self, s: &str) -> Result<(), core::fmt::Error> {
        self.uart.write_str(s)
    }
}
