use core::{cell::RefCell, convert::Infallible};
use embedded_hal::{
    delay::DelayNs,
    i2c::{ErrorType, I2c, Operation},
};
use microbit::{
    board::I2CInternalPins,
    hal::{
        Timer, Twim,
        gpio::{Disconnected, Input, PullUp, p0::P0_25},
        twim::{self, Frequency},
    },
    pac,
};

use crate::{Error, PowerManager};

/// Communication failure reported by the micro:bit V2 power helper.
pub type HardwareError = Error<twim::Error, Infallible>;

type BoardPowerManager<'bus> = PowerManager<InternalBus<'bus>, P0_25<Input<PullUp>>>;

enum InternalBus<'bus> {
    Owned(Twim<pac::TWIM0>),
    Shared(&'bus RefCell<Twim<pac::TWIM0>>),
}

impl InternalBus<'_> {
    fn disable(&mut self) {
        match self {
            Self::Owned(bus) => bus.disable(),
            Self::Shared(bus) => bus.borrow_mut().disable(),
        }
    }
}

impl ErrorType for InternalBus<'_> {
    type Error = twim::Error;
}

impl I2c for InternalBus<'_> {
    fn transaction(
        &mut self,
        address: u8,
        operations: &mut [Operation<'_>],
    ) -> Result<(), Self::Error> {
        match self {
            Self::Owned(bus) => bus.transaction(address, operations),
            Self::Shared(bus) => bus.borrow_mut().transaction(address, operations),
        }
    }
}

/// Checks reset-button events and enters System OFF after a long press.
///
/// This helper owns or shares the internal I²C bus and reserves its shared
/// interrupt input, TIMER3, and POWER. Call it at a safe boundary after active DMA
/// operations finish. [`Self::new_shared`] allows motion-sensor drivers to use
/// the same bus through [`crate::SharedI2c`].
pub struct PowerOff<'bus> {
    manager: Option<BoardPowerManager<'bus>>,
    timer: Timer<pac::TIMER3>,
    power: pac::POWER,
    latest_error: Option<HardwareError>,
}

impl PowerOff<'static> {
    /// Configures power management and waits briefly for a late startup event.
    #[doc(hidden)]
    pub fn new(
        i2c: pac::TWIM0,
        pins: I2CInternalPins,
        interrupt: P0_25<Disconnected>,
        timer: pac::TIMER3,
        power: pac::POWER,
    ) -> Self {
        let i2c = Twim::new(i2c, pins.into(), Frequency::K100);
        let mut power = Self::with_bus(InternalBus::Owned(i2c), interrupt, timer, power);
        power.check_startup_with(|| {});

        power
    }
}

impl<'bus> PowerOff<'bus> {
    /// Uses an application-owned internal bus shared with motion-sensor drivers.
    ///
    /// Configure TWIM0 on the internal P0.08/P0.16 pins, wrap it in a `RefCell`,
    /// and give each sensor a [`crate::SharedI2c`] handle. All bus access must run
    /// at the same interrupt priority; this helper does not mask interrupts.
    ///
    /// This constructor defers startup polling so application-specific cleanup
    /// is available. Call [`Self::check_startup_with`] after creating the device
    /// drivers and before the first frame. The helper disables the internal
    /// controller only after the power-down handshake has completed.
    pub fn new_shared(
        bus: &'bus RefCell<Twim<pac::TWIM0>>,
        interrupt: P0_25<Disconnected>,
        timer: pac::TIMER3,
        power: pac::POWER,
    ) -> Self {
        Self::with_bus(InternalBus::Shared(bus), interrupt, timer, power)
    }

    fn with_bus(
        bus: InternalBus<'bus>,
        interrupt: P0_25<Disconnected>,
        timer: pac::TIMER3,
        power: pac::POWER,
    ) -> Self {
        Self {
            manager: Some(PowerManager::new(bus, interrupt.into_pullup_input())),
            timer: Timer::new(timer),
            power,
            latest_error: None,
        }
    }

    /// Runs an application step repeatedly, checking power events between steps.
    ///
    /// Each step must return periodically and finish active DMA operations before
    /// returning. This is cooperative polling; no background interrupt is used.
    pub fn run(&mut self, mut step: impl FnMut()) -> ! {
        loop {
            self.check();
            step();
        }
    }

    /// Checks for a shutdown request, entering System OFF if one was received.
    ///
    /// Call this regularly after active DMA operations finish. A completed
    /// shutdown blanks the GPIO-driven display, clears microphone enable, and
    /// sets the speaker's GPIO level low. Active PWM must be stopped with
    /// [`Self::check_with`], since it overrides GPIO levels. This returns normally
    /// while no shutdown is requested or when polling fails. [`Self::last_error`]
    /// provides optional diagnostics. Once a shutdown request is received, it
    /// retries the handshake until System OFF.
    pub fn check(&mut self) {
        self.check_with(|| {});
    }

    /// Runs application cleanup only after a latched shutdown request.
    ///
    /// Stop any external devices or asynchronous peripherals before returning
    /// from `cleanup`. It runs once; handshake retries stay inside this call and
    /// do not return control to the application's rendering loop.
    pub fn check_with(&mut self, cleanup: impl FnOnce()) {
        self.latest_error = None;
        let Some(manager) = self.manager.as_mut() else {
            return;
        };

        match manager.poll() {
            Ok(false) => return,
            Err(error) => {
                self.latest_error = Some(error);
                return;
            }

            Ok(true) => {}
        }

        cleanup();

        loop {
            match manager.prepare_power_off(&mut self.timer) {
                Ok(()) => break,
                Err(error) => {
                    self.latest_error = Some(error);
                    self.timer.delay_ms(100);
                }
            }
        }

        let manager = self.manager.take().unwrap();
        let (mut i2c, interrupt) = manager.into_parts();
        i2c.disable();
        enter_system_off(&self.power, interrupt);
    }

    /// The most recent check's error, cleared after a successful check.
    pub fn last_error(&self) -> Option<&HardwareError> {
        self.latest_error.as_ref()
    }

    /// Polls through the startup grace period using application-specific cleanup.
    ///
    /// Call once before the first frame when using [`Self::new_shared`]. Long
    /// reset-button presses restart the processor, so attached devices and motion
    /// sensors can still be active from the previous run. Cleanup must stop those
    /// devices before the shutdown handshake. Keep the internal bus enabled;
    /// this helper disables it after the handshake, before entering System OFF.
    pub fn check_startup_with(&mut self, cleanup: impl FnOnce()) {
        self.latest_error = None;
        let Some(manager) = self.manager.as_mut() else {
            return;
        };

        match manager.poll_startup(&mut self.timer) {
            Ok(true) => self.check_with(cleanup),
            Ok(false) => {}
            Err(error) => self.latest_error = Some(error),
        }
    }
}

fn enter_system_off(power: &pac::POWER, _wake_pin: P0_25<Input<PullUp>>) -> ! {
    cortex_m::interrupt::disable();

    // SAFETY: this is the final transition; the application cannot resume.
    // Interrupts are masked so a display handler cannot relight the LEDs.
    // Only the built-in display, microphone-enable, and speaker pins are changed.
    let gpio0 = unsafe { &*pac::P0::ptr() };
    let gpio1 = unsafe { &*pac::P1::ptr() };
    const DISPLAY_ROWS: u32 = (1 << 15) | (1 << 19) | (1 << 21) | (1 << 22) | (1 << 24);
    const DISPLAY_COLUMNS_P0: u32 = (1 << 11) | (1 << 28) | (1 << 30) | (1 << 31);
    const DISPLAY_COLUMN_P1: u32 = 1 << 5;
    const MICROPHONE_ENABLE: u32 = 1 << 20;
    const SPEAKER: u32 = 1 << 0;

    gpio0
        .outclr
        .write(|writer| unsafe { writer.bits(DISPLAY_ROWS | MICROPHONE_ENABLE | SPEAKER) });

    gpio0
        .outset
        .write(|writer| unsafe { writer.bits(DISPLAY_COLUMNS_P0) });
    gpio1
        .outset
        .write(|writer| unsafe { writer.bits(DISPLAY_COLUMN_P1) });
    gpio0.dirset.write(|writer| unsafe {
        writer.bits(DISPLAY_ROWS | DISPLAY_COLUMNS_P0 | MICROPHONE_ENABLE | SPEAKER)
    });

    gpio1
        .dirset
        .write(|writer| unsafe { writer.bits(DISPLAY_COLUMN_P1) });

    // This function owns P0.25; the HAL does not expose its GPIO SENSE setting.
    gpio0.pin_cnf[25].modify(|_, writer| writer.sense().low());

    cortex_m::asm::dsb();
    power.systemoff.write(|writer| writer.systemoff().enter());
    cortex_m::asm::dsb();

    // System OFF is emulated while debugging. Keep the application stopped even
    // when the hardware therefore returns from the register write.
    loop {
        cortex_m::asm::wfi();
    }
}
