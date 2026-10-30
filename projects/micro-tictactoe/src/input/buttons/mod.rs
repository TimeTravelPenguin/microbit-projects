use core::cell::RefCell;

use cortex_m::interrupt::{Mutex, free};
use embassy_nrf::gpio::Input;
use embassy_time::Timer;

static BUTTONS: Mutex<RefCell<Buttons>> = Mutex::new(RefCell::new(Buttons::new()));

#[embassy_executor::task]
pub async fn sample(button_a: Input<'static>, button_b: Input<'static>) {
    loop {
        free(|ctx| {
            BUTTONS
                .borrow(ctx)
                .borrow_mut()
                .sample(button_a.is_low(), button_b.is_low());
        });

        Timer::after_millis(2).await;
    }
}

pub fn take_presses() -> ButtonPresses {
    free(|ctx| BUTTONS.borrow(ctx).borrow_mut().take_presses())
}

const STABLE_READINGS: u8 = 4;

/// Emits one press after four equal samples, then waits for a stable release.
/// With the firmware's 2ms timer, a transition takes 6–8 ms to settle.
pub struct DebouncedButton {
    candidate: bool,
    stable: bool,
    consecutive_readings: u8,
}

impl DebouncedButton {
    pub const fn new() -> Self {
        Self {
            candidate: false,
            stable: false,
            consecutive_readings: 0,
        }
    }

    pub fn update(&mut self, pressed: bool) -> bool {
        if pressed != self.candidate {
            self.candidate = pressed;
            self.consecutive_readings = 1;
        } else {
            self.consecutive_readings = (self.consecutive_readings + 1).min(STABLE_READINGS);
        }

        if self.consecutive_readings == STABLE_READINGS && self.stable != self.candidate {
            self.stable = self.candidate;
            return self.stable;
        }

        false
    }
}

impl Default for DebouncedButton {
    fn default() -> Self {
        Self::new()
    }
}

/// Presses waiting for the main loop. Each count saturates at 255.
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct ButtonPresses {
    pub button_a: u8,
    pub button_b: u8,
}

/// Retains independent A/B presses until the main loop can process them.
pub struct Buttons {
    button_a: DebouncedButton,
    button_b: DebouncedButton,
    pending: ButtonPresses,
}

impl Buttons {
    pub const fn new() -> Self {
        Self {
            button_a: DebouncedButton::new(),
            button_b: DebouncedButton::new(),
            pending: ButtonPresses {
                button_a: 0,
                button_b: 0,
            },
        }
    }

    /// Sample both active-low button inputs at a fixed interval.
    pub fn sample(&mut self, button_a_pressed: bool, button_b_pressed: bool) {
        if self.button_a.update(button_a_pressed) {
            self.pending.button_a = self.pending.button_a.saturating_add(1);
        }

        if self.button_b.update(button_b_pressed) {
            self.pending.button_b = self.pending.button_b.saturating_add(1);
        }
    }

    /// Drain queued presses without disturbing debounce or held-button state.
    pub fn take_presses(&mut self) -> ButtonPresses {
        core::mem::take(&mut self.pending)
    }
}

impl Default for Buttons {
    fn default() -> Self {
        Self::new()
    }
}
