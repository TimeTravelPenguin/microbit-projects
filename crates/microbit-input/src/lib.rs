//! Button debounce and press counts, independent of screen rendering.

#![no_std]

#[cfg(feature = "hardware")]
pub mod input;

pub mod logo;

const STABLE_READINGS: u8 = 4;

/// Emits one press after four equal samples, then waits for a stable release.
/// With the firmware's 2 ms timer, a transition takes 6–8 ms to settle.
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

#[cfg(test)]
mod tests {
    use super::*;

    fn settle(buttons: &mut Buttons, button_a_pressed: bool, button_b_pressed: bool) {
        for _ in 0..4 {
            buttons.sample(button_a_pressed, button_b_pressed);
        }
    }

    #[test]
    fn a_short_tap_is_retained_while_the_main_loop_is_drawing() {
        let mut buttons = Buttons::new();

        // The ISR keeps sampling every 2 ms during a 40 ms OLED transfer.
        // This 12 ms tap finishes before the main loop resumes.
        for tick in 0..20 {
            buttons.sample((4..10).contains(&tick), false);
        }

        assert_eq!(
            buttons.take_presses(),
            ButtonPresses {
                button_a: 1,
                button_b: 0,
            }
        );
        assert_eq!(buttons.take_presses(), ButtonPresses::default());
    }

    #[test]
    fn chatter_waits_for_a_stable_press_and_a_hold_does_not_repeat() {
        let mut buttons = Buttons::new();

        for pressed in [true, false, true, true, false, true, true, true] {
            buttons.sample(pressed, false);
        }

        assert_eq!(buttons.take_presses(), ButtonPresses::default());
        buttons.sample(true, false);
        assert_eq!(buttons.take_presses().button_a, 1);

        for _ in 0..50 {
            buttons.sample(true, false);
        }

        assert_eq!(buttons.take_presses(), ButtonPresses::default());
    }

    #[test]
    fn release_chatter_does_not_rearm_until_release_is_stable() {
        let mut buttons = Buttons::new();
        settle(&mut buttons, true, false);

        for pressed in [false, false, true, false, false, false] {
            buttons.sample(pressed, false);
        }

        settle(&mut buttons, true, false);
        assert_eq!(buttons.take_presses().button_a, 1);

        settle(&mut buttons, false, false);
        settle(&mut buttons, true, false);
        assert_eq!(buttons.take_presses().button_a, 1);
    }

    #[test]
    fn multiple_taps_are_retained_before_a_drain() {
        let mut buttons = Buttons::new();

        for _ in 0..3 {
            settle(&mut buttons, true, false);
            settle(&mut buttons, false, false);
        }

        for _ in 0..2 {
            settle(&mut buttons, false, true);
            settle(&mut buttons, false, false);
        }

        assert_eq!(
            buttons.take_presses(),
            ButtonPresses {
                button_a: 3,
                button_b: 2,
            }
        );
        assert_eq!(buttons.take_presses(), ButtonPresses::default());
    }

    #[test]
    fn simultaneous_buttons_keep_independent_press_events() {
        let mut buttons = Buttons::new();
        settle(&mut buttons, true, true);

        assert_eq!(
            buttons.take_presses(),
            ButtonPresses {
                button_a: 1,
                button_b: 1,
            }
        );

        settle(&mut buttons, true, true);
        assert_eq!(buttons.take_presses(), ButtonPresses::default());
    }

    #[test]
    fn pending_press_counts_saturate_instead_of_wrapping() {
        let mut buttons = Buttons::new();

        for _ in 0..=u8::MAX {
            settle(&mut buttons, true, true);
            settle(&mut buttons, false, false);
        }

        assert_eq!(
            buttons.take_presses(),
            ButtonPresses {
                button_a: u8::MAX,
                button_b: u8::MAX,
            }
        );
    }
}
