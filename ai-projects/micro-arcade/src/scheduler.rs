//! Cooperative input and movement timing using a wrapping millisecond clock.

pub const INPUT_SAMPLE_INTERVAL_MS: u32 = 5;

/// Each due check schedules the next run from the current time.
/// Missed intervals produce one update rather than a burst of catch-up work.
pub struct Scheduler {
    last_input_ms: u32,
    last_movement_ms: u32,
}

impl Scheduler {
    pub fn new(now_ms: u32) -> Self {
        Self {
            last_input_ms: now_ms,
            last_movement_ms: now_ms,
        }
    }

    pub fn input_due(&mut self, now_ms: u32) -> bool {
        if now_ms.wrapping_sub(self.last_input_ms) < INPUT_SAMPLE_INTERVAL_MS {
            return false;
        }

        self.last_input_ms = now_ms;

        true
    }

    pub fn movement_due(&mut self, now_ms: u32, interval_ms: u32) -> bool {
        if now_ms.wrapping_sub(self.last_movement_ms) < interval_ms {
            return false;
        }

        self.last_movement_ms = now_ms;

        true
    }

    /// Give a restarted game or newly placed row its full movement interval.
    pub fn restart_movement(&mut self, now_ms: u32) {
        self.last_movement_ms = now_ms;
    }
}

#[cfg(test)]
mod tests {
    use super::Scheduler;

    #[test]
    fn input_is_sampled_while_movement_is_waiting() {
        let mut scheduler = Scheduler::new(0);

        for now_ms in (5..1_000).step_by(5) {
            assert!(scheduler.input_due(now_ms));
            assert!(!scheduler.movement_due(now_ms, 1_000));
        }

        assert!(scheduler.input_due(1_000));
        assert!(scheduler.movement_due(1_000, 1_000));
    }

    #[test]
    fn early_or_repeated_checks_do_not_run_tasks_again() {
        let mut scheduler = Scheduler::new(100);

        assert!(!scheduler.input_due(104));
        assert!(scheduler.input_due(105));
        assert!(!scheduler.input_due(105));
        assert!(!scheduler.input_due(109));
        assert!(scheduler.input_due(110));

        assert!(scheduler.movement_due(150, 50));
        assert!(!scheduler.movement_due(150, 50));
    }

    #[test]
    fn an_action_cancels_movement_due_on_the_same_step() {
        let mut scheduler = Scheduler::new(0);
        assert!(scheduler.input_due(1_000));

        scheduler.restart_movement(1_000);

        assert!(!scheduler.movement_due(1_000, 810));
        assert!(!scheduler.movement_due(1_809, 810));
        assert!(scheduler.movement_due(1_810, 810));
    }

    #[test]
    fn stalled_tasks_resume_once_without_synthetic_samples() {
        let mut scheduler = Scheduler::new(0);

        assert!(scheduler.input_due(200));
        assert!(scheduler.movement_due(200, 50));
        assert!(!scheduler.input_due(200));
        assert!(!scheduler.movement_due(200, 50));
        assert!(!scheduler.input_due(204));
        assert!(scheduler.input_due(205));
        assert!(scheduler.movement_due(250, 50));
    }

    #[test]
    fn elapsed_time_remains_correct_when_the_clock_wraps() {
        let start_ms = u32::MAX - 2;
        let mut scheduler = Scheduler::new(start_ms);

        assert!(!scheduler.input_due(start_ms.wrapping_add(4)));
        assert!(scheduler.input_due(start_ms.wrapping_add(5)));
        assert!(!scheduler.movement_due(start_ms.wrapping_add(49), 50));
        assert!(scheduler.movement_due(start_ms.wrapping_add(50), 50));

        scheduler.restart_movement(u32::MAX - 10);

        assert!(!scheduler.movement_due(38, 50));
        assert!(scheduler.movement_due(39, 50));
    }
}
