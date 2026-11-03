//! Burn 0.22.0-pre.4 renderer/progress integration.
//!
//! Attach [`BurnReporter`] with `SupervisedTraining::renderer`. It can wrap an
//! existing Burn renderer, forwarding every callback while publishing progress,
//! loss and learning rate. An application must publish its own terminal outcome
//! after evaluation and artifact saving; Burn's end callbacks also run on interruption.

use std::{collections::HashMap, error::Error, time::Instant};

use burn::train::{
    LearnerSummary,
    logger::{EvaluationProgressLogger, TrainingProgressLogger},
    metric::{MetricDefinition, MetricId},
    renderer::{
        EvaluationName, MetricState, MetricsRenderer, MetricsRendererEvaluation,
        MetricsRendererTraining,
    },
};

use crate::{host::Reporter, protocol::Phase};

pub struct BurnReporter {
    reporter: Reporter,
    inner: Option<Box<dyn MetricsRenderer>>,
    names: HashMap<MetricId, String>,
    started: Instant,
    epoch: usize,
    epochs: usize,
    split_total: usize,
}

impl BurnReporter {
    /// Report into an application-owned dashboard, without a second terminal UI.
    pub fn new(reporter: Reporter) -> Self {
        Self {
            reporter,
            inner: None,
            names: HashMap::new(),
            started: Instant::now(),
            epoch: 0,
            epochs: 0,
            split_total: 0,
        }
    }

    /// Preserve Burn's default TUI or another renderer in an existing project.
    pub fn with_renderer(reporter: Reporter, renderer: Box<dyn MetricsRenderer>) -> Self {
        Self {
            inner: Some(renderer),
            ..Self::new(reporter)
        }
    }

    fn progress(&self, processed: usize) {
        let mut snapshot = self.reporter.snapshot();
        snapshot.epoch = self.epoch.saturating_add(1).min(self.epochs) as u16;
        snapshot.epochs = self.epochs.min(u16::MAX as usize) as u16;
        snapshot.elapsed_secs = self.started.elapsed().as_secs().min(u32::MAX as u64) as u32;
        snapshot.progress_permille = if self.split_total == 0 {
            0
        } else {
            processed
                .saturating_mul(1_000)
                .checked_div(self.split_total)
                .unwrap_or(0)
                .min(1_000) as u16
        };

        let _ = self.reporter.publish(snapshot);
    }

    fn metric(&self, state: &MetricState, valid: bool) {
        let MetricState::Numeric(entry, Some(value)) = state else {
            return;
        };
        let Some(name) = self.names.get(&entry.metric_id) else {
            return;
        };
        let value = value.current() as f32;

        if !value.is_finite() {
            return;
        }

        let mut snapshot = self.reporter.snapshot();
        let lower_name = name.to_ascii_lowercase();

        if lower_name.contains("learning") && lower_name.contains("rate") {
            snapshot.learning_rate = Some(value);
        } else if lower_name.contains("loss") {
            if valid {
                snapshot.valid_loss = Some(value);
            } else {
                snapshot.train_loss = Some(value);
            }
        } else {
            return;
        }

        let _ = self.reporter.publish(snapshot);
    }
}

impl MetricsRenderer for BurnReporter {
    fn manual_close(&mut self) {
        if let Some(inner) = &mut self.inner {
            inner.manual_close();
        }
    }

    fn register_metric(&mut self, definition: MetricDefinition) {
        self.names.insert(
            definition.metric_id.clone(),
            definition.name.as_ref().clone(),
        );

        if let Some(inner) = &mut self.inner {
            inner.register_metric(definition);
        }
    }
}

impl MetricsRendererTraining for BurnReporter {
    fn update_train(&mut self, state: MetricState) {
        self.metric(&state, false);

        if let Some(inner) = &mut self.inner {
            inner.update_train(state);
        }
    }

    fn update_valid(&mut self, state: MetricState) {
        self.metric(&state, true);

        if let Some(inner) = &mut self.inner {
            inner.update_valid(state);
        }
    }

    fn on_train_end(&mut self, summary: Option<LearnerSummary>) -> Result<(), Box<dyn Error>> {
        match &mut self.inner {
            Some(inner) => inner.on_train_end(summary),
            None => Ok(()),
        }
    }
}

impl MetricsRendererEvaluation for BurnReporter {
    fn update_test(&mut self, name: EvaluationName, state: MetricState) {
        if let Some(inner) = &mut self.inner {
            inner.update_test(name, state);
        }
    }

    fn on_test_end(&mut self, summary: Option<LearnerSummary>) -> Result<(), Box<dyn Error>> {
        match &mut self.inner {
            Some(inner) => inner.on_test_end(summary),
            None => Ok(()),
        }
    }
}

impl TrainingProgressLogger for BurnReporter {
    fn start(&mut self, total_epochs: usize, starting_epoch: usize, total_items: Option<usize>) {
        self.started = Instant::now();
        self.epochs = total_epochs;
        self.epoch = starting_epoch;
        self.split_total = total_items.unwrap_or(0);

        if let Some(inner) = &mut self.inner {
            inner.start(total_epochs, starting_epoch, total_items);
        }

        self.progress(0);
    }

    fn update_epoch(&mut self, epoch: usize) {
        self.epoch = epoch;

        if let Some(inner) = &mut self.inner {
            inner.update_epoch(epoch);
        }

        self.progress(self.split_total);
        self.epoch = epoch.saturating_add(1);
    }

    fn start_split(&mut self, split: &str, total_items: usize) {
        self.split_total = total_items;
        let mut snapshot = self.reporter.snapshot();
        snapshot.phase = if split == "train" {
            Phase::Training
        } else {
            Phase::Validating
        };
        let _ = self.reporter.publish(snapshot);

        if let Some(inner) = &mut self.inner {
            inner.start_split(split, total_items);
        }

        self.progress(0);
    }

    fn update_split(&mut self, items_processed: usize) {
        if let Some(inner) = &mut self.inner {
            inner.update_split(items_processed);
        }

        self.progress(items_processed);
    }

    fn end_split(&mut self) {
        if let Some(inner) = &mut self.inner {
            inner.end_split();
        }

        self.progress(self.split_total);
    }

    fn end(&mut self) {
        if let Some(inner) = &mut self.inner {
            inner.end();
        }
    }

    fn log_event_training(&mut self, event: String) {
        if let Some(inner) = &mut self.inner {
            inner.log_event_training(event);
        }
    }
}

impl EvaluationProgressLogger for BurnReporter {
    fn start_global_progress(&mut self, total_tests: usize) {
        if let Some(inner) = &mut self.inner {
            inner.start_global_progress(total_tests);
        }
    }

    fn start_test(&mut self, name: &str, total_items: usize) {
        self.split_total = total_items;
        let mut snapshot = self.reporter.snapshot();
        snapshot.phase = Phase::Evaluating;
        let _ = self.reporter.publish(snapshot);

        if let Some(inner) = &mut self.inner {
            inner.start_test(name, total_items);
        }

        self.progress(0);
    }

    fn update_test_progress(&mut self, items_processed: usize) {
        if let Some(inner) = &mut self.inner {
            inner.update_test_progress(items_processed);
        }

        self.progress(items_processed);
    }

    fn end_test(&mut self) {
        if let Some(inner) = &mut self.inner {
            inner.end_test();
        }

        self.progress(self.split_total);
    }

    fn end_global_progress(&mut self) {
        if let Some(inner) = &mut self.inner {
            inner.end_global_progress();
        }
    }

    fn log_event_evaluation(&mut self, event: String) {
        if let Some(inner) = &mut self.inner {
            inner.log_event_evaluation(event);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn training_end_does_not_claim_success_and_evaluation_is_explicit() {
        let reporter = Reporter::new("GCN");
        let mut adapter = BurnReporter::new(reporter.clone());
        adapter.start(10, 0, Some(80));
        adapter.start_split("train", 80);
        adapter.update_split(40);
        assert_eq!(reporter.snapshot().progress_permille, 500);
        adapter.end();
        adapter.on_train_end(None).unwrap();
        assert_eq!(reporter.snapshot().phase, Phase::Training);
        adapter.start_test("held out", 20);
        assert_eq!(reporter.snapshot().phase, Phase::Evaluating);
        assert!(!reporter.snapshot().phase.is_terminal());
    }
}
