use core::convert::Infallible;
use embedded_hal::delay::DelayNs;
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

type BoardPowerManager = PowerManager<Twim<pac::TWIM0>, P0_25<Input<PullUp>>>;

/// Checks reset-button events and enters System OFF after a long press.
///
/// This helper reserves the internal I²C bus, its shared interrupt input, TIMER3,
/// and POWER. Call it at a safe boundary after active DMA operations finish.
/// Drivers for the motion sensors cannot independently own the same I²C bus.
pub struct PowerOff {
    manager: Option<BoardPowerManager>,
    timer: Timer<pac::TIMER3>,
    power: pac::POWER,
    latest_error: Option<HardwareError>,
}

impl PowerOff {
    /// Setup used by [`crate::power_off!`]. The macro also performs a startup check.
    #[doc(hidden)]
    pub fn new(
        i2c: pac::TWIM0,
        pins: I2CInternalPins,
        interrupt: P0_25<Disconnected>,
        timer: pac::TIMER3,
        power: pac::POWER,
    ) -> Self {
        let i2c = Twim::new(i2c, pins.into(), Frequency::K100);
        let interrupt = interrupt.into_pullup_input();

        Self {
            manager: Some(PowerManager::new(i2c, interrupt)),
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
