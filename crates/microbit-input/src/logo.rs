//! Calibrated capacitive-logo detection, independent of hardware and drawing.

use crate::DebouncedButton;

const CALIBRATION_READINGS: u8 = 10;
const RECOVERY_READINGS: u8 = 4;

/// Elapsed charge time on the hardware's free-running 32-bit microsecond clock.
#[cfg(any(feature = "hardware", test))]
pub(crate) fn elapsed_charge_us(captured_us: u32, started_us: u32, maximum_us: u32) -> u32 {
    captured_us.wrapping_sub(started_us).min(maximum_us)
}

/// Detect one logo touch after four stable RC charge-time measurements.
///
/// The hardware samples every 4 ms, so touches settle in 12–16 ms. Calibration
/// follows CODAL: the largest of ten untouched readings, plus 10% and 2 µs.
pub struct LogoDetector {
    baseline_us: u16,
    calibration_remaining: u8,
    recovery_readings: u8,
    recovery_max_us: u16,
    button: DebouncedButton,
    pending_presses: u8,
}

impl LogoDetector {
    pub const fn new() -> Self {
        Self {
            baseline_us: 0,
            calibration_remaining: CALIBRATION_READINGS,
            recovery_readings: 0,
            recovery_max_us: 0,
            button: DebouncedButton::new(),
            pending_presses: 0,
        }
    }

    /// Record the time for the board's weak pull-up to charge the logo high.
    pub fn sample(&mut self, duration_us: u16) {
        if self.calibration_remaining != 0 {
            self.baseline_us = self.baseline_us.max(duration_us);
            self.calibration_remaining -= 1;
            return;
        }

        // If startup calibration happened while touched, a much faster reading
        // after a stable release restores the untouched baseline instead of
        // leaving the logo insensitive until the next reset. Four readings
        // keep a single unusually fast, noisy measurement from lowering it.
        if u32::from(duration_us) * 2 < u32::from(self.baseline_us) {
            self.recovery_max_us = self.recovery_max_us.max(duration_us);
            self.recovery_readings += 1;

            if self.recovery_readings == RECOVERY_READINGS {
                self.baseline_us = self.recovery_max_us;
                self.button = DebouncedButton::new();
                self.recovery_readings = 0;
                self.recovery_max_us = 0;
            }
        } else {
            self.recovery_readings = 0;
            self.recovery_max_us = 0;
        }

        let threshold_us = self.baseline_us.saturating_add(self.baseline_us / 10 + 2);

        if self.button.update(duration_us >= threshold_us) {
            self.pending_presses = self.pending_presses.saturating_add(1);
        }
    }

    /// Drain queued touches without disturbing calibration or held-touch state.
    pub fn take_presses(&mut self) -> u8 {
        core::mem::take(&mut self.pending_presses)
    }
}

impl Default for LogoDetector {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn settle(detector: &mut LogoDetector, duration_us: u16) {
        for _ in 0..4 {
            detector.sample(duration_us);
        }
    }

    fn calibrated() -> LogoDetector {
        let mut detector = LogoDetector::new();

        for _ in 0..CALIBRATION_READINGS {
            detector.sample(100);
        }

        detector
    }

    #[test]
    fn calibration_uses_the_highest_reading_without_emitting_a_touch() {
        let mut detector = LogoDetector::new();

        for duration_us in [100, 95, 102, 99, 100, 101, 100, 99, 100, 98] {
            detector.sample(duration_us);
            assert_eq!(detector.take_presses(), 0);
        }

        assert_eq!(detector.baseline_us, 102);
        settle(&mut detector, 113);
        assert_eq!(detector.take_presses(), 0);
        settle(&mut detector, 114);
        assert_eq!(detector.take_presses(), 1);
    }

    #[test]
    fn untouched_noise_does_not_emit_presses() {
        let mut detector = calibrated();

        for duration_us in [100, 105, 98, 110, 101, 109, 99, 100, 105, 102] {
            detector.sample(duration_us);
        }

        assert_eq!(detector.take_presses(), 0);
    }

    #[test]
    fn four_stable_readings_queue_a_touch_during_foreground_work() {
        let mut detector = calibrated();

        for _ in 0..3 {
            detector.sample(200);
        }

        assert_eq!(detector.take_presses(), 0);
        detector.sample(200);
        settle(&mut detector, 100);
        assert_eq!(detector.take_presses(), 1);
        assert_eq!(detector.take_presses(), 0);
    }

    #[test]
    fn a_hold_does_not_repeat_and_release_chatter_does_not_rearm() {
        let mut detector = calibrated();
        settle(&mut detector, 200);

        for _ in 0..20 {
            detector.sample(200);
        }

        for duration_us in [100, 100, 200, 100, 100, 100, 200, 200, 200, 200] {
            detector.sample(duration_us);
        }

        assert_eq!(detector.take_presses(), 1);
        settle(&mut detector, 100);
        settle(&mut detector, 200);
        assert_eq!(detector.take_presses(), 1);
    }

    #[test]
    fn releasing_a_logo_held_during_calibration_restores_sensitivity() {
        let mut detector = LogoDetector::new();

        for _ in 0..CALIBRATION_READINGS {
            detector.sample(800);
        }

        settle(&mut detector, 800);
        assert_eq!(detector.take_presses(), 0);
        settle(&mut detector, 100);
        assert_eq!(detector.baseline_us, 100);
        assert_eq!(detector.take_presses(), 0);
        settle(&mut detector, 200);
        assert_eq!(detector.take_presses(), 1);
    }

    #[test]
    fn multiple_touches_are_retained_and_the_count_saturates() {
        let mut detector = calibrated();

        for _ in 0..=u8::MAX {
            settle(&mut detector, 200);
            settle(&mut detector, 100);
        }

        assert_eq!(detector.take_presses(), u8::MAX);
        assert_eq!(detector.take_presses(), 0);
    }

    #[test]
    fn one_unusually_fast_reading_does_not_corrupt_the_baseline() {
        let mut detector = calibrated();
        detector.sample(1);
        settle(&mut detector, 100);
        assert_eq!(detector.baseline_us, 100);
        assert_eq!(detector.take_presses(), 0);
    }

    #[test]
    fn charge_time_stays_correct_across_the_timer_counter_wrap() {
        assert_eq!(elapsed_charge_us(50, u32::MAX - 49, 1_000), 100);
    }

    #[test]
    fn a_late_rising_edge_is_a_timeout_instead_of_a_short_charge() {
        assert_eq!(elapsed_charge_us(4_005, 2_000, 1_000), 1_000);
        assert_eq!(elapsed_charge_us(1_500, u32::MAX - 999, 1_000), 1_000);
    }
}
