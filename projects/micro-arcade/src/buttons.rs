use embedded_hal::digital::InputPin;

const DEBOUNCE_MS: u32 = 20;

/// A new press of one of the board's buttons.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum ButtonPress {
    A,
    B,
}

/// Active-low buttons with independent press histories.
///
/// Keep this controller across game resets: resetting the game does not release
/// a physical button. Read failures retain the last accepted state.
pub struct Buttons<PinA, PinB> {
    button_a: Button<PinA>,
    button_b: Button<PinB>,
}

impl<PinA: InputPin, PinB: InputPin> Buttons<PinA, PinB> {
    pub fn new(button_a: PinA, button_b: PinB) -> Self {
        Self {
            button_a: Button::new(button_a),
            button_b: Button::new(button_b),
        }
    }

    /// Sample both buttons and return at most one new press.
    ///
    /// Press and release changes need 20 ms of unchanged successful readings.
    /// `now_ms` must advance monotonically, allowing normal `u32` rollover.
    ///
    /// If both raw or accepted states indicate a hold, suppress each button
    /// until its release is confirmed. Releasing one of two held buttons therefore
    /// does not create a new press, even when their debounce intervals differ.
    /// A failed read suppresses new events for this poll and restarts that button's
    /// pending debounce interval; it never changes the accepted state.
    pub fn poll(&mut self, now_ms: u32) -> Option<ButtonPress> {
        let button_a = self.button_a.sample(now_ms);
        let button_b = self.button_b.sample(now_ms);

        if button_a.settled_released {
            self.button_a.press_suppressed = false;
        }

        if button_b.settled_released {
            self.button_b.press_suppressed = false;
        }

        let button_a_held = button_a.raw_pressed == Some(true) || button_a.pressed;
        let button_b_held = button_b.raw_pressed == Some(true) || button_b.pressed;

        if button_a_held && button_b_held {
            self.button_a.press_suppressed = true;
            self.button_b.press_suppressed = true;
        }

        match (button_a.raw_pressed, button_b.raw_pressed) {
            (Some(true), Some(false))
                if button_a.just_pressed
                    && !button_b.pressed
                    && !self.button_a.press_suppressed =>
            {
                Some(ButtonPress::A)
            }

            (Some(false), Some(true))
                if button_b.just_pressed
                    && !button_a.pressed
                    && !self.button_b.press_suppressed =>
            {
                Some(ButtonPress::B)
            }

            _ => None,
        }
    }
}

struct Button<Pin> {
    pin: Pin,
    candidate_pressed: bool,
    candidate_since_ms: u32,
    candidate_valid: bool,
    stable_pressed: bool,
    press_suppressed: bool,
}

struct ButtonSample {
    raw_pressed: Option<bool>,
    pressed: bool,
    just_pressed: bool,
    settled_released: bool,
}

impl<Pin: InputPin> Button<Pin> {
    fn new(pin: Pin) -> Self {
        Self {
            pin,
            candidate_pressed: false,
            candidate_since_ms: 0,
            candidate_valid: false,
            stable_pressed: false,
            press_suppressed: false,
        }
    }

    fn sample(&mut self, now_ms: u32) -> ButtonSample {
        let Ok(raw_pressed) = self.pin.is_low() else {
            self.candidate_valid = false;

            return ButtonSample {
                raw_pressed: None,
                pressed: self.stable_pressed,
                just_pressed: false,
                settled_released: false,
            };
        };

        if !self.candidate_valid || raw_pressed != self.candidate_pressed {
            self.candidate_pressed = raw_pressed;
            self.candidate_since_ms = now_ms;
            self.candidate_valid = true;
        }

        let candidate_settled = now_ms.wrapping_sub(self.candidate_since_ms) >= DEBOUNCE_MS;
        let mut just_pressed = false;

        if candidate_settled && self.candidate_pressed != self.stable_pressed {
            self.stable_pressed = self.candidate_pressed;
            just_pressed = self.stable_pressed;
        }

        ButtonSample {
            raw_pressed: Some(raw_pressed),
            pressed: self.stable_pressed,
            just_pressed,
            settled_released: candidate_settled && !self.stable_pressed,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::{ButtonPress, Buttons};
    use embedded_hal::digital::{Error, ErrorKind, ErrorType, InputPin};

    #[derive(Clone, Copy, Debug)]
    struct ReadError;

    impl Error for ReadError {
        fn kind(&self) -> ErrorKind {
            ErrorKind::Other
        }
    }

    struct TestPin {
        reading: Result<bool, ReadError>,
        read_count: usize,
    }

    impl TestPin {
        fn released() -> Self {
            Self {
                reading: Ok(false),
                read_count: 0,
            }
        }
    }

    impl ErrorType for TestPin {
        type Error = ReadError;
    }

    impl InputPin for TestPin {
        fn is_high(&mut self) -> Result<bool, Self::Error> {
            self.reading.map(|pressed| !pressed)
        }

        fn is_low(&mut self) -> Result<bool, Self::Error> {
            self.read_count += 1;

            self.reading
        }
    }

    #[test]
    fn stable_press_emits_once_and_stable_release_rearms_each_button() {
        let mut buttons = Buttons::new(TestPin::released(), TestPin::released());

        assert_eq!(buttons.poll(0), None);
        buttons.button_a.pin.reading = Ok(true);
        assert_eq!(buttons.poll(5), None);
        assert_eq!(buttons.poll(24), None);
        assert_eq!(buttons.poll(25), Some(ButtonPress::A));
        assert_eq!(buttons.poll(500), None);

        buttons.button_a.pin.reading = Ok(false);
        assert_eq!(buttons.poll(505), None);
        assert_eq!(buttons.poll(525), None);
        buttons.button_a.pin.reading = Ok(true);
        assert_eq!(buttons.poll(530), None);
        assert_eq!(buttons.poll(550), Some(ButtonPress::A));

        buttons.button_a.pin.reading = Ok(false);
        assert_eq!(buttons.poll(555), None);
        assert_eq!(buttons.poll(575), None);
        buttons.button_b.pin.reading = Ok(true);
        assert_eq!(buttons.poll(580), None);
        assert_eq!(buttons.poll(600), Some(ButtonPress::B));
        assert_eq!(buttons.poll(605), None);

        buttons.button_b.pin.reading = Ok(false);
        assert_eq!(buttons.poll(610), None);
        assert_eq!(buttons.poll(630), None);
        buttons.button_b.pin.reading = Ok(true);
        assert_eq!(buttons.poll(635), None);
        assert_eq!(buttons.poll(655), Some(ButtonPress::B));
    }

    #[test]
    fn press_chatter_restarts_the_stability_interval() {
        let mut buttons = Buttons::new(TestPin::released(), TestPin::released());
        buttons.button_a.pin.reading = Ok(true);
        assert_eq!(buttons.poll(0), None);

        buttons.button_a.pin.reading = Ok(false);
        assert_eq!(buttons.poll(5), None);
        buttons.button_a.pin.reading = Ok(true);
        assert_eq!(buttons.poll(10), None);
        buttons.button_a.pin.reading = Ok(false);
        assert_eq!(buttons.poll(15), None);
        buttons.button_a.pin.reading = Ok(true);
        assert_eq!(buttons.poll(20), None);

        assert_eq!(buttons.poll(39), None);
        assert_eq!(buttons.poll(40), Some(ButtonPress::A));
        assert_eq!(buttons.poll(45), None);
    }

    #[test]
    fn release_chatter_does_not_rearm_a_held_button() {
        let mut buttons = Buttons::new(TestPin::released(), TestPin::released());
        buttons.button_a.pin.reading = Ok(true);
        assert_eq!(buttons.poll(0), None);
        assert_eq!(buttons.poll(20), Some(ButtonPress::A));

        buttons.button_a.pin.reading = Ok(false);
        assert_eq!(buttons.poll(25), None);
        buttons.button_a.pin.reading = Ok(true);
        assert_eq!(buttons.poll(30), None);
        buttons.button_a.pin.reading = Ok(false);
        assert_eq!(buttons.poll(35), None);
        buttons.button_a.pin.reading = Ok(true);
        assert_eq!(buttons.poll(40), None);
        assert_eq!(buttons.poll(60), None);

        buttons.button_a.pin.reading = Ok(false);
        assert_eq!(buttons.poll(65), None);
        assert_eq!(buttons.poll(85), None);
        buttons.button_a.pin.reading = Ok(true);
        assert_eq!(buttons.poll(90), None);
        assert_eq!(buttons.poll(110), Some(ButtonPress::A));
    }

    #[test]
    fn simultaneous_presses_are_suppressed_without_inventing_a_later_press() {
        let mut buttons = Buttons::new(TestPin::released(), TestPin::released());
        buttons.button_a.pin.reading = Ok(true);
        buttons.button_b.pin.reading = Ok(true);
        assert_eq!(buttons.poll(0), None);
        assert_eq!(buttons.poll(20), None);

        buttons.button_a.pin.reading = Ok(false);
        assert_eq!(buttons.poll(25), None);
        assert_eq!(buttons.poll(45), None);
        assert_eq!(buttons.poll(100), None);

        buttons.button_b.pin.reading = Ok(false);
        assert_eq!(buttons.poll(105), None);
        assert_eq!(buttons.poll(125), None);

        buttons.button_a.pin.reading = Ok(true);
        assert_eq!(buttons.poll(130), None);
        assert_eq!(buttons.poll(150), Some(ButtonPress::A));
    }

    #[test]
    fn raw_overlap_suppresses_press_before_the_other_button_has_debounced() {
        let mut buttons = Buttons::new(TestPin::released(), TestPin::released());
        buttons.button_a.pin.reading = Ok(true);
        assert_eq!(buttons.poll(0), None);

        buttons.button_b.pin.reading = Ok(true);
        assert_eq!(buttons.poll(20), None);
        assert_eq!(buttons.poll(40), None);

        buttons.button_a.pin.reading = Ok(false);
        assert_eq!(buttons.poll(45), None);
        assert_eq!(buttons.poll(65), None);
        assert_eq!(buttons.poll(100), None);
    }

    #[test]
    fn early_peer_release_does_not_unsuppress_a_pending_press() {
        let mut buttons = Buttons::new(TestPin::released(), TestPin::released());
        buttons.button_a.pin.reading = Ok(true);
        buttons.button_b.pin.reading = Ok(true);
        assert_eq!(buttons.poll(0), None);

        buttons.button_a.pin.reading = Ok(false);
        assert_eq!(buttons.poll(5), None);
        assert_eq!(buttons.poll(20), None);
        assert_eq!(buttons.poll(25), None);
        assert_eq!(buttons.poll(100), None);

        buttons.button_b.pin.reading = Ok(false);
        assert_eq!(buttons.poll(105), None);
        assert_eq!(buttons.poll(125), None);
        buttons.button_b.pin.reading = Ok(true);
        assert_eq!(buttons.poll(130), None);
        assert_eq!(buttons.poll(150), Some(ButtonPress::B));
    }

    #[test]
    fn overlapping_release_debounce_suppresses_a_new_peer_press() {
        let mut buttons = Buttons::new(TestPin::released(), TestPin::released());
        buttons.button_a.pin.reading = Ok(true);
        assert_eq!(buttons.poll(0), None);
        assert_eq!(buttons.poll(20), Some(ButtonPress::A));

        buttons.button_a.pin.reading = Ok(false);
        buttons.button_b.pin.reading = Ok(true);
        assert_eq!(buttons.poll(25), None);
        assert_eq!(buttons.poll(45), None);
        assert_eq!(buttons.poll(100), None);
    }

    #[test]
    fn read_failure_retains_pressed_state_and_cannot_rearm_it() {
        let mut buttons = Buttons::new(TestPin::released(), TestPin::released());
        buttons.button_a.pin.reading = Ok(true);
        assert_eq!(buttons.poll(0), None);
        assert_eq!(buttons.poll(20), Some(ButtonPress::A));

        buttons.button_a.pin.reading = Err(ReadError);
        assert_eq!(buttons.poll(25), None);
        assert!(buttons.button_a.stable_pressed);

        buttons.button_a.pin.reading = Ok(true);
        assert_eq!(buttons.poll(100), None);
        assert_eq!(buttons.poll(120), None);
    }

    #[test]
    fn read_failure_restarts_pending_press_and_release_intervals() {
        let mut buttons = Buttons::new(TestPin::released(), TestPin::released());
        buttons.button_a.pin.reading = Ok(true);
        assert_eq!(buttons.poll(0), None);
        buttons.button_a.pin.reading = Err(ReadError);
        assert_eq!(buttons.poll(15), None);
        buttons.button_a.pin.reading = Ok(true);
        assert_eq!(buttons.poll(100), None);
        assert_eq!(buttons.poll(119), None);
        assert_eq!(buttons.poll(120), Some(ButtonPress::A));

        buttons.button_a.pin.reading = Ok(false);
        assert_eq!(buttons.poll(125), None);
        buttons.button_a.pin.reading = Err(ReadError);
        assert_eq!(buttons.poll(140), None);
        buttons.button_a.pin.reading = Ok(false);
        assert_eq!(buttons.poll(200), None);
        assert!(buttons.button_a.stable_pressed);
        assert_eq!(buttons.poll(219), None);
        assert!(buttons.button_a.stable_pressed);
        assert_eq!(buttons.poll(220), None);
        assert!(!buttons.button_a.stable_pressed);
    }

    #[test]
    fn unknown_peer_read_suppresses_press_and_both_pins_are_always_sampled() {
        let mut buttons = Buttons::new(TestPin::released(), TestPin::released());
        buttons.button_a.pin.reading = Ok(true);
        assert_eq!(buttons.poll(0), None);
        buttons.button_b.pin.reading = Err(ReadError);
        assert_eq!(buttons.poll(20), None);

        buttons.button_b.pin.reading = Ok(false);
        assert_eq!(buttons.poll(25), None);
        assert_eq!(buttons.poll(45), None);
        buttons.button_a.pin.reading = Err(ReadError);
        assert_eq!(buttons.poll(50), None);

        assert_eq!(buttons.button_a.pin.read_count, 5);
        assert_eq!(buttons.button_b.pin.read_count, 5);
    }

    #[test]
    fn stability_interval_survives_millisecond_counter_rollover() {
        let mut buttons = Buttons::new(TestPin::released(), TestPin::released());
        buttons.button_a.pin.reading = Ok(true);
        assert_eq!(buttons.poll(u32::MAX - 9), None);
        assert_eq!(buttons.poll(9), None);
        assert_eq!(buttons.poll(10), Some(ButtonPress::A));
    }
}
