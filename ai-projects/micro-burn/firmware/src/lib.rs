#![no_std]

//! Hardware-independent pager state and drawing, shared by firmware and host tests.

use core::fmt::Write;

use embedded_graphics::{
    mono_font::{MonoTextStyle, ascii::FONT_6X10},
    pixelcolor::BinaryColor,
    prelude::*,
    primitives::{Line, PrimitiveStyle, Rectangle},
    text::{Baseline, Text},
};
use heapless::String;
use micro_burn::protocol::{
    ActionKind, ActionResult, AlertPolicy, DeviceEvent, DeviceStatus, Phase, Snapshot,
};

/// A fully debounced physical button press.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum Button {
    A,
    B,
}

/// The device's independent view of a training session.
pub struct Pager {
    snapshot: Snapshot,
    has_snapshot: bool,
    connected: bool,
    last_receipt_ms: u64,
    page: u8,
    menu: Option<u8>,
    next_action_id: u16,
    pending: Option<DeviceEvent>,
    pending_acknowledgement: Option<DeviceEvent>,
    acknowledged: bool,
    snoozed_until_ms: u64,
    alert_policy: AlertPolicy,
    trend: [f32; 64],
    trend_len: usize,
    notice: &'static str,
}

impl Default for Pager {
    fn default() -> Self {
        Self::new()
    }
}

impl Pager {
    pub fn new() -> Self {
        Self {
            snapshot: Snapshot::default(),
            has_snapshot: false,
            connected: false,
            last_receipt_ms: 0,
            page: 0,
            menu: None,
            next_action_id: 1,
            pending: None,
            pending_acknowledgement: None,
            acknowledged: false,
            snoozed_until_ms: 0,
            alert_policy: AlertPolicy::All,
            trend: [0.0; 64],
            trend_len: 0,
            notice: "Waiting for laptop",
        }
    }

    /// Apply a complete snapshot. Duplicate retransmissions retain a local acknowledgement.
    pub fn apply(&mut self, snapshot: Snapshot, now_ms: u64) -> DeviceEvent {
        let same_run = self.has_snapshot && snapshot.run_id == self.snapshot.run_id;
        let same_event = same_run && snapshot.event_id == self.snapshot.event_id;
        let new_observation = !same_run || snapshot.sequence != self.snapshot.sequence;
        self.last_receipt_ms = now_ms;

        if !same_run {
            self.trend_len = 0;
            self.pending = None;
            self.pending_acknowledgement = None;
            self.snoozed_until_ms = 0;
        }

        self.acknowledged = snapshot.acknowledged || (same_event && self.acknowledged);

        if !same_event {
            self.snoozed_until_ms = 0;

            if snapshot.phase.is_terminal() {
                self.page = 2;
                self.menu = None;
            }
        }

        if new_observation {
            if let Some(loss) = snapshot.train_loss.filter(|loss| loss.is_finite()) {
                if self.trend_len < self.trend.len() {
                    self.trend[self.trend_len] = loss;
                    self.trend_len += 1;
                } else {
                    self.trend.copy_within(1.., 0);
                    self.trend[63] = loss;
                }
            }
        }

        if !matches!(self.pending, Some(event) if event.kind == ActionKind::SetAlertPolicy) {
            self.alert_policy = snapshot.alert_policy;
        }

        self.snapshot = snapshot;
        self.has_snapshot = true;
        self.notice = if snapshot.phase.is_terminal() {
            "Result retained"
        } else {
            "Live training"
        };

        self.event(ActionKind::Received, 0, 0)
    }

    pub fn set_connected(&mut self, connected: bool) {
        self.connected = connected;
    }

    pub fn status(&self) -> DeviceStatus {
        DeviceStatus {
            run_id: self.snapshot.run_id,
            sequence: self.snapshot.sequence,
            event_id: self.snapshot.event_id,
            acknowledged: self.acknowledged,
            alert_policy: self.alert_policy,
        }
    }

    /// A pending action is retransmitted using its original ID after reconnect.
    pub fn pending(&self) -> Option<DeviceEvent> {
        self.pending_acknowledgement.or(self.pending)
    }

    pub fn action_result(&mut self, result: ActionResult) {
        if let Some(pending) = self.pending_acknowledgement {
            if result.run_id == pending.run_id && result.action_id == pending.action_id {
                self.pending_acknowledgement = None;
                self.notice = if result.accepted {
                    "Action confirmed"
                } else {
                    "Action rejected"
                };

                return;
            }
        }

        if let Some(pending) = self.pending {
            if result.run_id == pending.run_id && result.action_id == pending.action_id {
                self.pending = None;
                self.notice = if result.accepted {
                    "Action confirmed"
                } else {
                    "Action rejected"
                };
            }
        }
    }

    pub fn press(&mut self, button: Button, now_ms: u64) -> Option<DeviceEvent> {
        match (self.menu, button) {
            (None, Button::A) => self.page = (self.page + 1) % 3,
            (None, Button::B) => self.menu = Some(0),
            (Some(selected), Button::A) => self.menu = Some((selected + 1) % 5),
            (Some(selected), Button::B) => {
                self.menu = None;

                if selected == 4 || !self.has_snapshot {
                    return None;
                }

                // Silence is always local and immediate, including while offline.
                if selected == 0 && self.snapshot.phase.is_terminal() {
                    self.acknowledged = true;
                }

                if selected != 0 && self.pending.is_some() {
                    self.notice = "Action still pending";

                    return None;
                }

                let (kind, value) = match selected {
                    0 if self.snapshot.phase.is_terminal() => (ActionKind::Acknowledged, 0),
                    0 => {
                        self.notice = "No result to confirm";

                        return None;
                    }

                    1 => {
                        self.snoozed_until_ms = now_ms.saturating_add(60_000);

                        (ActionKind::Snoozed, 60)
                    }

                    2 => {
                        self.alert_policy = match self.alert_policy {
                            AlertPolicy::All => AlertPolicy::ErrorsOnly,
                            AlertPolicy::ErrorsOnly => AlertPolicy::Muted,
                            AlertPolicy::Muted => AlertPolicy::All,
                        };

                        (ActionKind::SetAlertPolicy, self.alert_policy as u8)
                    }

                    3 => (ActionKind::Bookmark, 0),
                    _ => return None,
                };

                let action_id = self.next_action_id;
                self.next_action_id = self.next_action_id.wrapping_add(1).max(1);
                let event = self.event(kind, action_id, value);
                if kind == ActionKind::Acknowledged {
                    self.pending_acknowledgement = Some(event);
                } else {
                    self.pending = Some(event);
                }
                self.notice = if self.connected {
                    "Sending action"
                } else {
                    "Saved until connected"
                };

                return Some(event);
            }
        }

        None
    }

    pub fn should_sound(&self, now_ms: u64) -> bool {
        self.has_snapshot
            && self.snapshot.phase.is_terminal()
            && !self.acknowledged
            && now_ms >= self.snoozed_until_ms
            && match self.alert_policy {
                AlertPolicy::All => true,
                AlertPolicy::ErrorsOnly => self.snapshot.phase == Phase::Failed,
                AlertPolicy::Muted => false,
            }
    }

    pub fn draw<Display>(&self, display: &mut Display, now_ms: u64) -> Result<(), Display::Error>
    where
        Display: DrawTarget<Color = BinaryColor>,
    {
        display.clear(BinaryColor::Off)?;

        if let Some(selected) = self.menu {
            text(display, 0, "Device actions")?;
            let options = [
                "Acknowledge",
                "Snooze 60 sec",
                "Cycle alert policy",
                "Bookmark this point",
                "Back",
            ];

            for (idx, option) in options.iter().enumerate() {
                let mut label = String::<24>::new();
                let marker = if selected as usize == idx { '>' } else { ' ' };
                let _ = write!(label, "{marker}{option}");
                text(display, 11 + idx as i32 * 9, &label)?;
            }

            return Ok(());
        }

        if !self.has_snapshot {
            text(display, 0, "micro-burn")?;
            text(display, 14, "Waiting for training")?;
            text(display, 28, "Select this device")?;
            text(display, 38, "in the desktop app")?;
            text(display, 53, "A:Page  B:Menu")?;

            return Ok(());
        }

        let label = if self.snapshot.label.as_str().is_empty() {
            "Training run"
        } else {
            self.snapshot.label.as_str()
        };
        let heading = if !self.connected {
            "BLE disconnected"
        } else if self.data_age_secs(now_ms) > 15 {
            "Training updates old"
        } else {
            label
        };
        text(display, 0, heading)?;

        match self.page {
            0 => self.draw_overview(display)?,
            1 => self.draw_metrics(display)?,
            _ => self.draw_details(display, now_ms)?,
        }

        text(display, 54, "A:Page  B:Menu")
    }

    fn event(&self, kind: ActionKind, action_id: u16, value: u8) -> DeviceEvent {
        DeviceEvent {
            run_id: self.snapshot.run_id,
            sequence: self.snapshot.sequence,
            event_id: self.snapshot.event_id,
            action_id,
            kind,
            value,
        }
    }

    fn data_age_secs(&self, now_ms: u64) -> u64 {
        u64::from(self.snapshot.trainer_age_secs)
            .saturating_add(now_ms.saturating_sub(self.last_receipt_ms) / 1_000)
    }

    fn draw_overview<Display>(&self, display: &mut Display) -> Result<(), Display::Error>
    where
        Display: DrawTarget<Color = BinaryColor>,
    {
        let mut line = String::<32>::new();
        let _ = write!(
            line,
            "{}  {}/{}",
            phase_name(self.snapshot.phase),
            self.snapshot.epoch,
            self.snapshot.epochs
        );
        text(display, 11, &line)?;
        line.clear();
        let _ = write!(
            line,
            "Elapsed {}:{:02}",
            self.snapshot.elapsed_secs / 60,
            self.snapshot.elapsed_secs % 60
        );
        text(display, 22, &line)?;
        line.clear();

        if let Some(eta) = self.snapshot.eta_secs {
            let _ = write!(line, "ETA ~{}:{:02}", eta / 60, eta % 60);
        } else {
            let _ = write!(line, "ETA unavailable");
        }

        text(display, 33, &line)?;
        let width = u32::from(self.snapshot.progress_permille.min(1000)) * 126 / 1000;
        Rectangle::new(Point::new(0, 45), Size::new(128, 5))
            .into_styled(PrimitiveStyle::with_stroke(BinaryColor::On, 1))
            .draw(display)?;
        Rectangle::new(Point::new(1, 46), Size::new(width, 3))
            .into_styled(PrimitiveStyle::with_fill(BinaryColor::On))
            .draw(display)?;

        Ok(())
    }

    fn draw_metrics<Display>(&self, display: &mut Display) -> Result<(), Display::Error>
    where
        Display: DrawTarget<Color = BinaryColor>,
    {
        metric(display, 11, "Loss", self.snapshot.train_loss)?;
        metric(display, 22, "Valid", self.snapshot.valid_loss)?;
        metric(display, 33, "LR", self.snapshot.learning_rate)?;

        if self.trend_len > 1 {
            let samples = &self.trend[..self.trend_len];
            let minimum = samples.iter().copied().fold(f32::INFINITY, f32::min);
            let maximum = samples.iter().copied().fold(f32::NEG_INFINITY, f32::max);
            let range = (maximum - minimum).max(f32::EPSILON);

            for idx in 1..samples.len() {
                let previous = Point::new(
                    (idx as i32 - 1) * 2,
                    50 - ((samples[idx - 1] - minimum) * 8.0 / range) as i32,
                );
                let current = Point::new(
                    idx as i32 * 2,
                    50 - ((samples[idx] - minimum) * 8.0 / range) as i32,
                );
                Line::new(previous, current)
                    .into_styled(PrimitiveStyle::with_stroke(BinaryColor::On, 1))
                    .draw(display)?;
            }
        }

        Ok(())
    }

    fn draw_details<Display>(
        &self,
        display: &mut Display,
        now_ms: u64,
    ) -> Result<(), Display::Error>
    where
        Display: DrawTarget<Color = BinaryColor>,
    {
        if self.snapshot.phase.is_terminal() {
            text(display, 11, phase_name(self.snapshot.phase))?;
            metric(display, 22, "MAE", self.snapshot.mae)?;
            metric(display, 33, "RMSE", self.snapshot.rmse)?;
            text(
                display,
                44,
                if self.acknowledged {
                    "Acknowledged"
                } else {
                    "B menu: acknowledge"
                },
            )?;
        } else {
            let mut line = String::<32>::new();
            let _ = write!(
                line,
                "BLE {}",
                if self.connected {
                    "connected"
                } else {
                    "disconnected"
                }
            );
            text(display, 11, &line)?;
            line.clear();
            let age_secs = self.data_age_secs(now_ms);
            let _ = write!(line, "Data age {age_secs}s");
            text(display, 22, &line)?;
            text(
                display,
                33,
                match self.alert_policy {
                    AlertPolicy::All => "Alerts: all results",
                    AlertPolicy::ErrorsOnly => "Alerts: errors only",
                    AlertPolicy::Muted => "Alerts: muted",
                },
            )?;
            text(display, 44, self.notice)?;
        }

        Ok(())
    }
}

fn text<Display>(display: &mut Display, y: i32, content: &str) -> Result<(), Display::Error>
where
    Display: DrawTarget<Color = BinaryColor>,
{
    Text::with_baseline(
        content,
        Point::new(0, y),
        MonoTextStyle::new(&FONT_6X10, BinaryColor::On),
        Baseline::Top,
    )
    .draw(display)?;

    Ok(())
}

fn metric<Display>(
    display: &mut Display,
    y: i32,
    name: &str,
    value: Option<f32>,
) -> Result<(), Display::Error>
where
    Display: DrawTarget<Color = BinaryColor>,
{
    let mut line = String::<32>::new();

    if let Some(value) = value {
        let _ = write!(line, "{name} {value:.4}");
    } else {
        let _ = write!(line, "{name} --");
    }

    text(display, y, &line)
}

pub fn phase_name(phase: Phase) -> &'static str {
    match phase {
        Phase::Idle => "Idle",
        Phase::Preparing => "Preparing",
        Phase::Training => "Training",
        Phase::Validating => "Validating",
        Phase::Evaluating => "Evaluating",
        Phase::Saving => "Saving",
        Phase::Succeeded => "Complete",
        Phase::Interrupted => "Interrupted",
        Phase::Failed => "Failed",
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn completed() -> Snapshot {
        Snapshot {
            run_id: 42,
            sequence: 9,
            event_id: 1,
            phase: Phase::Succeeded,
            ..Snapshot::default()
        }
    }

    #[test]
    fn disconnect_and_eta_do_not_invent_success() {
        let mut pager = Pager::new();
        pager.apply(
            Snapshot {
                phase: Phase::Training,
                eta_secs: Some(1),
                ..Snapshot::default()
            },
            0,
        );
        pager.set_connected(false);

        assert!(!pager.should_sound(120_000));
        assert_eq!(pager.snapshot.phase, Phase::Training);
    }

    #[test]
    fn local_acknowledgement_survives_duplicate_terminal_snapshot() {
        let mut pager = Pager::new();
        pager.apply(completed(), 0);
        assert!(pager.should_sound(0));
        pager.press(Button::B, 0);
        let action = pager.press(Button::B, 0).expect("acknowledge action");

        assert_eq!(action.kind, ActionKind::Acknowledged);
        assert!(!pager.should_sound(1));
        pager.apply(completed(), 2);

        assert!(!pager.should_sound(2));
        assert!(pager.status().acknowledged);
        assert_eq!(pager.pending(), Some(action));
    }

    #[test]
    fn bookmark_preserves_the_displayed_snapshot_id() {
        let mut pager = Pager::new();
        pager.apply(completed(), 0);
        pager.press(Button::B, 0);

        for _ in 0..3 {
            pager.press(Button::A, 0);
        }

        let action = pager.press(Button::B, 0).expect("bookmark action");
        pager.apply(
            Snapshot {
                sequence: 10,
                ..completed()
            },
            1,
        );

        assert_eq!(action.sequence, 9);
        assert_eq!(pager.pending().expect("pending bookmark").sequence, 9);
    }

    #[test]
    fn snooze_expires_without_changing_training_outcome() {
        let mut pager = Pager::new();
        pager.apply(completed(), 0);
        pager.press(Button::B, 0);
        pager.press(Button::A, 0);
        pager.press(Button::B, 0);

        assert!(!pager.should_sound(59_999));
        assert!(pager.should_sound(60_000));
        assert_eq!(pager.snapshot.phase, Phase::Succeeded);
    }

    #[test]
    fn acknowledgement_is_delivered_even_when_a_bookmark_is_pending() {
        let mut pager = Pager::new();
        pager.apply(completed(), 0);
        pager.press(Button::B, 0);

        for _ in 0..3 {
            pager.press(Button::A, 0);
        }

        let bookmark = pager.press(Button::B, 0).expect("bookmark action");
        pager.press(Button::B, 0);
        let acknowledgement = pager.press(Button::B, 0).expect("acknowledge action");

        assert!(!pager.should_sound(0));
        assert_eq!(pager.pending(), Some(acknowledgement));
        pager.action_result(ActionResult {
            run_id: acknowledgement.run_id,
            sequence: acknowledgement.sequence,
            action_id: acknowledgement.action_id,
            accepted: true,
        });

        assert_eq!(pager.pending(), Some(bookmark));
    }

    #[test]
    fn reconnect_uses_reported_trainer_age_instead_of_resetting_freshness() {
        let mut pager = Pager::new();
        pager.apply(
            Snapshot {
                trainer_age_secs: 90,
                phase: Phase::Training,
                ..Snapshot::default()
            },
            0,
        );

        assert_eq!(pager.data_age_secs(5_000), 95);
        assert!(!pager.should_sound(5_000));
    }
}
