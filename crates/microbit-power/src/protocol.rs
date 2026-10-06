//! The micro:bit V2 interface chip reports long reset-button presses over I²C.
//!
//! Call [`PowerManager::poll`] before the first frame and regularly thereafter.
//! After a shutdown request, stop the application's peripherals, call
//! [`PowerManager::prepare_power_off`], then enter the nRF52833's System OFF mode
//! with the combined interrupt pin configured as an active-low wake source.

use embedded_hal::{delay::DelayNs, digital::InputPin, i2c::I2c};

const INTERFACE_ADDRESS: u8 = 0x70;
const RESPONSE_LEN: usize = 12;
const WAIT_ATTEMPTS: usize = 50;
const STARTUP_GRACE_MS: usize = 100;

#[derive(Clone, Copy)]
enum ShutdownPhase {
    SendLedOff,
    AwaitLedAck,
    SendPowerDown,
    AwaitPowerDownAck,
    AwaitInterruptRelease,
}

/// Failure to communicate with the interface chip or complete its shutdown.
#[derive(Debug, Eq, PartialEq)]
pub enum Error<BusError, PinError> {
    I2c(BusError),
    Pin(PinError),
    Interface(u8),
    Timeout,
    InterruptActive,
}

/// Owns the internal I²C bus and the shared, active-low interrupt input.
///
/// Sensor interrupt sources must be cleared before shutdown preparation, so
/// the shared interrupt line can be released and used as a wake source.
pub struct PowerManager<Bus, InterruptPin> {
    bus: Bus,
    interrupt: InterruptPin,
    shutdown_requested: bool,
    shutdown_phase: ShutdownPhase,
}

impl<Bus: I2c, InterruptPin: InputPin> PowerManager<Bus, InterruptPin> {
    pub fn new(bus: Bus, interrupt: InterruptPin) -> Self {
        Self {
            bus,
            interrupt,
            shutdown_requested: false,
            shutdown_phase: ShutdownPhase::SendLedOff,
        }
    }

    /// Returns true after a long reset-button press, including one pending at boot.
    ///
    /// The request stays latched, allowing the caller to retry a failed shutdown.
    /// Sensor interrupts, other user events, and transient busy replies are ignored.
    pub fn poll(&mut self) -> Result<bool, Error<Bus::Error, InterruptPin::Error>> {
        if self.shutdown_requested {
            return Ok(true);
        }

        if !self.interrupt.is_low().map_err(Error::Pin)? {
            return Ok(false);
        }

        let response = self.read_response()?;
        self.observe_response(&response)?;

        Ok(self.shutdown_requested)
    }

    /// Gives the interface time to post a long-press event after resuming the CPU.
    ///
    /// The bounded guard spans several 30 ms interface ticks; the protocol does
    /// not formally guarantee when the event arrives. Poll immediately, then
    /// wait one millisecond between samples, retrying transient errors.
    pub(crate) fn poll_startup(
        &mut self,
        delay: &mut impl DelayNs,
    ) -> Result<bool, Error<Bus::Error, InterruptPin::Error>> {
        let mut result = self.poll();

        for _ in 0..STARTUP_GRACE_MS {
            if matches!(&result, Ok(true)) {
                return result;
            }

            delay.delay_ms(1);
            result = self.poll();
        }

        result
    }

    /// Turns off the power LED and asks the interface chip to power down.
    ///
    /// Each command receives its acknowledgement before the next command. Success
    /// also means the interrupt input was released, so arming a low-level wake
    /// source will not immediately wake the processor. This does not itself enter
    /// System OFF. On USB power, the interface chip remains awake by design.
    pub fn prepare_power_off(
        &mut self,
        delay: &mut impl DelayNs,
    ) -> Result<(), Error<Bus::Error, InterruptPin::Error>> {
        // Preserve progress across errors. Once the interface powers down, I²C
        // cannot wake it to receive repeated commands when running on batteries.
        loop {
            match self.shutdown_phase {
                ShutdownPhase::SendLedOff => {
                    self.write_property(0x08, 0x00)?;
                    self.shutdown_phase = ShutdownPhase::AwaitLedAck;
                }

                ShutdownPhase::AwaitLedAck => {
                    self.await_ack(0x08, delay)?;
                    self.shutdown_phase = ShutdownPhase::SendPowerDown;
                }

                ShutdownPhase::SendPowerDown => {
                    self.write_property(0x07, 0x08)?;
                    self.shutdown_phase = ShutdownPhase::AwaitPowerDownAck;
                }

                ShutdownPhase::AwaitPowerDownAck => {
                    self.await_ack(0x07, delay)?;
                    self.shutdown_phase = ShutdownPhase::AwaitInterruptRelease;
                    delay.delay_ms(10);
                }

                ShutdownPhase::AwaitInterruptRelease => {
                    return self.await_interrupt_release(delay);
                }
            }
        }
    }

    /// Returns the peripherals for their final shutdown and wake-pin configuration.
    pub fn into_parts(self) -> (Bus, InterruptPin) {
        (self.bus, self.interrupt)
    }

    fn wake_interface(&mut self) -> Result<(), Error<Bus::Error, InterruptPin::Error>> {
        // Older interface firmware needs a transaction to wake before servicing
        // another one. NOP preserves any pending asynchronous user-event reply.
        self.bus
            .write(INTERFACE_ADDRESS, &[0x00])
            .map_err(Error::I2c)
    }

    fn read_response(
        &mut self,
    ) -> Result<[u8; RESPONSE_LEN], Error<Bus::Error, InterruptPin::Error>> {
        self.wake_interface()?;
        let mut response = [0; RESPONSE_LEN];
        self.bus
            .read(INTERFACE_ADDRESS, &mut response)
            .map_err(Error::I2c)?;

        Ok(response)
    }

    fn observe_response(
        &mut self,
        response: &[u8; RESPONSE_LEN],
    ) -> Result<(), Error<Bus::Error, InterruptPin::Error>> {
        if response[..4] == [0x11, 0x09, 0x01, 0x03] {
            self.shutdown_requested = true;
        }

        if response[0] == 0x20 && !matches!(response[1], 0x31 | 0x39) {
            return Err(Error::Interface(response[1]));
        }

        Ok(())
    }

    fn write_property(
        &mut self,
        property: u8,
        value: u8,
    ) -> Result<(), Error<Bus::Error, InterruptPin::Error>> {
        self.wake_interface()?;
        self.bus
            .write(INTERFACE_ADDRESS, &[0x12, property, 0x01, value])
            .map_err(Error::I2c)?;

        Ok(())
    }

    fn await_ack(
        &mut self,
        property: u8,
        delay: &mut impl DelayNs,
    ) -> Result<(), Error<Bus::Error, InterruptPin::Error>> {
        // Commands are processed asynchronously after STOP; a repeated-start
        // write_read transaction would read before the reply is ready.
        for _ in 0..WAIT_ATTEMPTS {
            delay.delay_ms(1);

            if !self.interrupt.is_low().map_err(Error::Pin)? {
                continue;
            }

            let response = self.read_response()?;
            self.observe_response(&response)?;

            if response[..2] == [0x13, property] {
                return Ok(());
            }
        }

        Err(Error::Timeout)
    }

    fn await_interrupt_release(
        &mut self,
        delay: &mut impl DelayNs,
    ) -> Result<(), Error<Bus::Error, InterruptPin::Error>> {
        for _ in 0..WAIT_ATTEMPTS {
            if self.interrupt.is_high().map_err(Error::Pin)? {
                return Ok(());
            }

            delay.delay_ms(1);
        }

        Err(Error::InterruptActive)
    }
}

#[cfg(test)]
#[path = "protocol/tests.rs"]
mod tests;
