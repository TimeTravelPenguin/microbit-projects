use std::{
    collections::VecDeque,
    panic::{AssertUnwindSafe, catch_unwind},
    sync::mpsc::{self, Receiver, TryRecvError},
    thread,
    time::Duration,
};

use iced::{
    Alignment, Border, Color, Element, Fill, Font, Length, Point, Rectangle, Renderer, Size,
    Subscription, Theme, mouse,
    widget::{
        Canvas, button, canvas, column, container, progress_bar, row, scrollable, text, text_input,
    },
};
use micro_burn::{
    host::{ConnectionState, HostEvent, Monitor},
    protocol::{ActionKind, AlertPolicy, Phase, Snapshot},
};

use crate::{
    Args, new_run_directory,
    training::{self, TrainingConfig, TrainingEvent, TrainingResults},
};

const BACKGROUND: Color = Color::from_rgb(0.035, 0.051, 0.075);
const PANEL: Color = Color::from_rgb(0.063, 0.086, 0.118);
const BORDER: Color = Color::from_rgb(0.14, 0.18, 0.23);
const MUTED: Color = Color::from_rgb(0.59, 0.66, 0.74);
const TEAL: Color = Color::from_rgb(0.25, 0.84, 0.73);
const BLUE: Color = Color::from_rgb(0.40, 0.65, 1.0);
const MAX_HISTORY: usize = 512;

pub fn run(args: Args) -> iced::Result {
    iced::application(
        move || Dashboard::new(args.clone()),
        Dashboard::update,
        Dashboard::view,
    )
    .title("micro-burn · Training companion")
    .theme(Theme::Dark)
    .subscription(Dashboard::subscription)
    .window_size(Size::new(1220.0, 850.0))
    .run()
}

#[derive(Clone, Debug)]
enum Message {
    Tick,
    Epochs(String),
    LearningRate(String),
    Seed(String),
    Train,
    Scan,
    Connect(String),
    Disconnect,
    CycleAlerts,
    Acknowledge,
}

struct Dashboard {
    args: Args,
    monitor: Option<Monitor>,
    connection: String,
    devices: Vec<(String, String)>,
    receiver: Option<Receiver<TrainingEvent>>,
    running: bool,
    snapshot: Snapshot,
    epochs: String,
    learning_rate: String,
    seed: String,
    history: Vec<HistoryPoint>,
    log: VecDeque<String>,
    results: Option<TrainingResults>,
    error: Option<String>,
}

impl Dashboard {
    fn new(args: Args) -> Self {
        let mut error = None;
        let monitor = match Monitor::new(
            "Classroom GCN",
            Some(args.artifacts.join("pager-state.json")),
        ) {
            Ok(monitor) => Some(monitor),
            Err(failure) => {
                error = Some(format!("Monitor could not start: {failure}"));
                None
            }
        };

        let snapshot = monitor
            .as_ref()
            .map(|monitor| monitor.reporter.snapshot())
            .unwrap_or_default();

        Self {
            epochs: args.epochs.to_string(),
            learning_rate: args.learning_rate.to_string(),
            seed: args.seed.to_string(),
            args,
            monitor,
            connection: "Not connected".into(),
            devices: Vec::new(),
            receiver: None,
            running: false,
            snapshot,
            history: Vec::new(),
            log: VecDeque::from(["Ready. Training works with or without a micro:bit.".into()]),
            results: None,
            error,
        }
    }

    fn subscription(&self) -> Subscription<Message> {
        iced::time::every(Duration::from_millis(250)).map(|_| Message::Tick)
    }

    fn update(&mut self, message: Message) {
        match message {
            Message::Tick => self.poll(),
            Message::Epochs(value) => self.epochs = value,
            Message::LearningRate(value) => self.learning_rate = value,
            Message::Seed(value) => self.seed = value,
            Message::Train => self.start_training(),
            Message::Scan => {
                self.devices.clear();

                if let Some(monitor) = &self.monitor {
                    monitor.scan();
                }
            }
            Message::Connect(id) => {
                if let Some(monitor) = &self.monitor {
                    monitor.connect(&id);
                }
            }
            Message::Disconnect => {
                if let Some(monitor) = &self.monitor {
                    monitor.disconnect();
                }
            }
            Message::CycleAlerts => {
                if let Some(monitor) = &self.monitor {
                    let policy = match self.snapshot.alert_policy {
                        AlertPolicy::All => AlertPolicy::ErrorsOnly,
                        AlertPolicy::ErrorsOnly => AlertPolicy::Muted,
                        AlertPolicy::Muted => AlertPolicy::All,
                    };

                    self.snapshot = monitor.reporter.set_alert_policy(policy);
                }
            }
            Message::Acknowledge => {
                if let Some(monitor) = &self.monitor {
                    self.snapshot = monitor.reporter.acknowledge();
                }
            }
        }
    }

    fn poll(&mut self) {
        let mut training_events = Vec::new();
        let mut worker_disconnected = false;

        if let Some(receiver) = &self.receiver {
            loop {
                match receiver.try_recv() {
                    Ok(event) => training_events.push(event),
                    Err(TryRecvError::Empty) => break,
                    Err(TryRecvError::Disconnected) => {
                        worker_disconnected = true;
                        break;
                    }
                }
            }
        }

        for event in training_events {
            match event {
                TrainingEvent::Snapshot(snapshot) => self.record(snapshot),
                TrainingEvent::Finished(result) => {
                    self.running = false;
                    self.receiver = None;

                    match result {
                        Ok(results) => {
                            self.restore_history(&results);
                            self.log(format!("Saved results: {}", results.artifact_dir.display()));
                            self.results = Some(results);
                        }
                        Err(failure) => {
                            self.log(format!("Run failed: {failure}"));
                            self.error = Some(failure);
                        }
                    }
                }
            }
        }

        if worker_disconnected && self.running {
            self.running = false;
            self.receiver = None;
            let failure = "The training worker stopped without reporting an outcome. Check the run artifacts before starting again.".to_owned();
            self.log(failure.clone());
            self.error = Some(failure);
        }

        let mut host_events = Vec::new();

        if let Some(monitor) = &self.monitor {
            while let Ok(event) = monitor.try_recv() {
                host_events.push(event);
            }

            self.snapshot = monitor.reporter.snapshot();
        }

        for event in host_events {
            match event {
                HostEvent::DeviceFound(device) => {
                    if !self.devices.iter().any(|(id, _)| id == &device.id) {
                        self.devices.push((device.id, device.name));
                    }
                }
                HostEvent::Connection(state) => {
                    self.connection = match state {
                        ConnectionState::Disconnected => "Not connected",
                        ConnectionState::Scanning => "Looking for your micro:bit…",
                        ConnectionState::Connecting(_) => "Connecting…",
                        ConnectionState::Ready(_) => "Connected to your micro:bit",
                    }
                    .into();

                    self.log(self.connection.clone());
                }
                HostEvent::Error(failure) => self.log(format!("Device: {failure}")),
                HostEvent::Action(action) => {
                    let message = match action.kind {
                        ActionKind::Received | ActionKind::Bookmark => None,
                        ActionKind::Acknowledged => {
                            Some("Result acknowledged on the micro:bit.".to_owned())
                        }
                        ActionKind::Snoozed => {
                            Some(format!("Pager alert snoozed for {} seconds.", action.value))
                        }
                        ActionKind::SetAlertPolicy => {
                            Some("Alert settings changed on the micro:bit.".to_owned())
                        }
                    };

                    if let Some(message) = message {
                        self.log(message);
                    }
                }
                HostEvent::Bookmark { snapshot, .. } => self.log(format!(
                    "Saved a bookmark at epoch {} (training loss {}).",
                    snapshot.epoch,
                    metric(snapshot.train_loss),
                )),
                HostEvent::Recovered(snapshot) => {
                    self.snapshot = snapshot;
                    self.log("Recovered the last retained run result.".into());
                }
            }
        }
    }

    fn restore_history(&mut self, results: &TrainingResults) {
        #[derive(serde::Deserialize)]
        struct SavedEpoch {
            epoch: usize,
            gnn_train_mse: f32,
            gnn_validation_mse: f32,
        }

        let history = std::fs::read(results.artifact_dir.join("history.json"))
            .map_err(|failure| failure.to_string())
            .and_then(|bytes| {
                serde_json::from_slice::<Vec<SavedEpoch>>(&bytes)
                    .map_err(|failure| failure.to_string())
            });

        match history {
            Ok(history) => {
                self.history = history
                    .iter()
                    .skip(history.len().saturating_sub(MAX_HISTORY))
                    .map(|epoch| HistoryPoint {
                        epoch: epoch.epoch as f32,
                        train: Some(epoch.gnn_train_mse),
                        valid: Some(epoch.gnn_validation_mse),
                    })
                    .collect();
            }
            Err(failure) => self.log(format!(
                "Could not restore the complete learning curve: {failure}"
            )),
        }
    }

    fn record(&mut self, snapshot: Snapshot) {
        if self.snapshot.phase != snapshot.phase {
            self.log(format!("Training: {:?}", snapshot.phase));
        }

        if snapshot.phase == Phase::Validating
            && snapshot.train_loss.is_some()
            && snapshot.valid_loss.is_some()
        {
            let point = HistoryPoint {
                epoch: snapshot.epoch as f32,
                train: snapshot.train_loss,
                valid: snapshot.valid_loss,
            };

            if let Some(previous) = self
                .history
                .last_mut()
                .filter(|previous| previous.epoch == point.epoch)
            {
                *previous = point;
            } else {
                if self.history.len() == MAX_HISTORY {
                    self.history.remove(0);
                }

                self.history.push(point);
            }
        }

        self.snapshot = snapshot;
    }

    fn log(&mut self, message: String) {
        if self.log.len() == 40 {
            self.log.pop_front();
        }

        self.log.push_back(message);
    }

    fn start_training(&mut self) {
        if self.running {
            return;
        }

        let config = match self.parse_config() {
            Ok(config) => config,
            Err(failure) => {
                self.error = Some(failure);
                return;
            }
        };

        let Some(monitor) = &self.monitor else {
            self.error = Some("The local reporter is unavailable. Restart the application.".into());
            return;
        };

        let reporter = monitor.reporter.clone();
        self.snapshot = reporter.begin_run("Classroom GCN");
        let data_path = self.args.data.clone();
        let artifact_dir = new_run_directory(&self.args);
        let (events, receiver) = mpsc::sync_channel(64);
        self.receiver = Some(receiver);
        self.running = true;
        self.results = None;
        self.error = None;
        self.history.clear();
        self.log("Started a new classroom GCN experiment.".into());

        let failure_reporter = reporter.clone();
        let worker = thread::Builder::new()
            .name("micro-burn-training".into())
            .spawn(move || {
                let result = catch_unwind(AssertUnwindSafe(|| {
                    training::train(
                        config,
                        &data_path,
                        &artifact_dir,
                        reporter.clone(),
                        events.clone(),
                    )
                }));

                let result = match result {
                    Ok(result) => result.map_err(|failure| format!("{failure:#}")),
                    Err(_) => {
                        let mut snapshot = reporter.snapshot();
                        snapshot.phase = Phase::Failed;
                        let _ = reporter.publish(snapshot);
                        Err(
                            "The training worker panicked. See the application log for details."
                                .into(),
                        )
                    }
                };

                let _ = events.send(TrainingEvent::Finished(result));
            });

        if let Err(failure) = worker {
            self.running = false;
            self.receiver = None;
            self.error = Some(format!("Could not start the training worker: {failure}"));
            let mut snapshot = failure_reporter.snapshot();
            snapshot.phase = Phase::Failed;
            let _ = failure_reporter.publish(snapshot);
        }
    }

    fn parse_config(&self) -> Result<TrainingConfig, String> {
        let epochs = self
            .epochs
            .parse::<usize>()
            .map_err(|_| "Enter a whole number of epochs.")?;
        let learning_rate = self
            .learning_rate
            .parse::<f64>()
            .map_err(|_| "Enter a numeric learning rate.")?;
        let seed = self
            .seed
            .parse::<u64>()
            .map_err(|_| "Enter a nonnegative whole seed.")?;

        if !(1..=10000).contains(&epochs) {
            return Err("Epochs must be between 1 and 10,000.".into());
        }

        if !learning_rate.is_finite() || learning_rate <= 0.0 || learning_rate > 1.0 {
            return Err("Learning rate must be in (0, 1].".into());
        }

        Ok(TrainingConfig {
            epochs,
            learning_rate,
            seed,
        })
    }

    fn view(&self) -> Element<'_, Message> {
        let header = row![
            column![
                text("micro-burn").size(30),
                text("A training companion, at your desk and away.").color(MUTED)
            ]
            .spacing(5),
            iced::widget::Space::new().width(Fill),
            text(phase_label(self.snapshot.phase)).size(16).color(TEAL),
        ]
        .align_y(Alignment::Center);

        let progress = self.snapshot.progress_permille as f32 / 1000.0;
        let overview = row![
            metric_card(
                "EPOCH",
                format!("{} / {}", self.snapshot.epoch, self.snapshot.epochs)
            ),
            metric_card("TRAIN LOSS", metric(self.snapshot.train_loss)),
            metric_card("VALIDATION LOSS", metric(self.snapshot.valid_loss)),
            metric_card(
                "ELAPSED / EST. LEFT",
                format!(
                    "{} / {}",
                    clock(self.snapshot.elapsed_secs),
                    self.snapshot
                        .eta_secs
                        .map(clock)
                        .unwrap_or_else(|| "—".into())
                )
            ),
        ]
        .spacing(14);

        let mut configuration = column![
            text("Experiment").size(20),
            text("Czech classroom friendships").color(TEAL),
            text("Predict a later subject grade from earlier grades and observed friendships.")
                .size(14)
                .color(MUTED),
            text(format!(
                "{} message-passing layers · hidden width {} · CPU",
                training::HIDDEN_LAYERS + 1,
                training::HIDDEN_WIDTH,
            ))
            .size(13)
            .color(MUTED),
            text("Epochs").size(13),
            text_input("200", &self.epochs).on_input(Message::Epochs),
            text("Learning rate").size(13),
            text_input("0.01", &self.learning_rate).on_input(Message::LearningRate),
            text("Seed").size(13),
            text_input("42", &self.seed).on_input(Message::Seed),
        ]
        .spacing(10);

        let train_button = button(if self.running {
            "Training…"
        } else {
            "Train & evaluate"
        })
        .padding([12, 18]);
        configuration = configuration.push(if self.running {
            train_button
        } else {
            train_button.on_press(Message::Train)
        });

        if let Some(failure) = &self.error {
            configuration = configuration.push(
                text(failure)
                    .size(13)
                    .color(Color::from_rgb(1.0, 0.52, 0.48)),
            );
        }

        let chart = column![
            row![
                text("Learning curves").size(20),
                iced::widget::Space::new().width(Fill),
                text("● Train").color(TEAL),
                text("● Validation").color(BLUE)
            ]
            .spacing(14),
            Canvas::new(LossChart {
                points: &self.history
            })
            .width(Fill)
            .height(Length::Fixed(260.0)),
            text("Mean squared error by epoch · test results are evaluated after model selection")
                .size(12)
                .color(MUTED),
        ]
        .spacing(10);

        let mut device = column![
            row![text("Portable display").size(20), iced::widget::Space::new().width(Fill), button("Find micro:bit").on_press(Message::Scan), button("Disconnect").on_press(Message::Disconnect)].spacing(10).align_y(Alignment::Center),
            text(&self.connection).color(TEAL),
            text("The board shows progress, final metrics and alerts. Acknowledge or snooze on the board; training continues independently.").size(13).color(MUTED),
        ].spacing(12);

        let policy_label = match self.snapshot.alert_policy {
            AlertPolicy::All => "Alerts: completion & errors",
            AlertPolicy::ErrorsOnly => "Alerts: errors only",
            AlertPolicy::Muted => "Alerts: muted",
        };
        let acknowledge = button(if self.snapshot.acknowledged {
            "Acknowledged"
        } else {
            "Acknowledge result"
        });
        let acknowledge = if self.snapshot.phase.is_terminal() && !self.snapshot.acknowledged {
            acknowledge.on_press(Message::Acknowledge)
        } else {
            acknowledge
        };

        device = device.push(
            row![
                button(policy_label).on_press(Message::CycleAlerts),
                acknowledge
            ]
            .spacing(12),
        );

        for (id, name) in &self.devices {
            device = device.push(button(text(name)).on_press(Message::Connect(id.clone())));
        }

        let events = self.log.iter().rev().take(8).fold(
            column![text("Session events").size(20)].spacing(7),
            |acc, event| acc.push(text(event).size(12).font(Font::MONOSPACE).color(MUTED)),
        );

        let mut content = column![
            header,
            overview,
            progress_bar(0.0..=1.0, progress),
            row![
                panel(configuration).width(Length::FillPortion(1)),
                panel(chart).width(Length::FillPortion(2))
            ]
            .spacing(14),
            panel(device),
        ]
        .spacing(18);

        if let Some(results) = &self.results {
            let metrics = results.model_metrics.iter().fold(
                column![text("Held-out results").size(20)].spacing(8),
                |acc, result| {
                    acc.push(row![
                        text(&result.name).width(Fill),
                        text(format!("MAE {:.4}     RMSE {:.4}", result.mae, result.rmse))
                            .font(Font::MONOSPACE)
                    ])
                },
            );

            content = content.push(panel(
                metrics.push(
                    text(format!("Saved to {}", results.artifact_dir.display()))
                        .size(12)
                        .color(MUTED),
                ),
            ));
        }

        content = content.push(panel(events));

        container(scrollable(content.padding(28)))
            .width(Fill)
            .height(Fill)
            .style(|_| container::Style::default().background(BACKGROUND))
            .into()
    }
}

fn panel<'a>(content: impl Into<Element<'a, Message>>) -> container::Container<'a, Message> {
    container(content).padding(20).style(|_| {
        container::Style::default()
            .background(PANEL)
            .border(Border {
                color: BORDER,
                width: 1.0,
                radius: 12.0.into(),
            })
    })
}

fn metric_card(label: &'static str, value: String) -> container::Container<'static, Message> {
    panel(
        column![
            text(label).size(11).color(MUTED),
            text(value).size(25).font(Font::MONOSPACE)
        ]
        .spacing(10),
    )
    .width(Fill)
}

fn metric(value: Option<f32>) -> String {
    value
        .filter(|value| value.is_finite())
        .map(|value| format!("{value:.4}"))
        .unwrap_or_else(|| "—".into())
}

fn clock(seconds: u32) -> String {
    format!("{}:{:02}", seconds / 60, seconds % 60)
}

fn phase_label(phase: Phase) -> &'static str {
    match phase {
        Phase::Idle => "READY",
        Phase::Preparing => "PREPARING",
        Phase::Training => "TRAINING",
        Phase::Validating => "VALIDATING",
        Phase::Evaluating => "EVALUATING",
        Phase::Saving => "SAVING RESULTS",
        Phase::Succeeded => "COMPLETE",
        Phase::Interrupted => "INTERRUPTED",
        Phase::Failed => "FAILED",
    }
}

struct HistoryPoint {
    epoch: f32,
    train: Option<f32>,
    valid: Option<f32>,
}

struct LossChart<'a> {
    points: &'a [HistoryPoint],
}

impl canvas::Program<Message> for LossChart<'_> {
    type State = ();

    fn draw(
        &self,
        _state: &(),
        renderer: &Renderer,
        _theme: &Theme,
        bounds: Rectangle,
        _cursor: mouse::Cursor,
    ) -> Vec<canvas::Geometry> {
        let mut frame = canvas::Frame::new(renderer, bounds.size());
        let left = 54.0;
        let top = 18.0;
        let plot_width = (bounds.width - left - 20.0).max(1.0);
        let plot_height = (bounds.height - top - 28.0).max(1.0);
        let maximum = self
            .points
            .iter()
            .flat_map(|point| [point.train, point.valid])
            .flatten()
            .filter(|value| value.is_finite())
            .fold(
                if self.points.is_empty() {
                    1.0_f32
                } else {
                    0.01_f32
                },
                f32::max,
            )
            * 1.1;
        let epoch_max = self
            .points
            .last()
            .map(|point| point.epoch)
            .unwrap_or(1.0)
            .max(1.0);
        let epoch_min = self.points.first().map(|point| point.epoch).unwrap_or(0.0);
        let epoch_span = (epoch_max - epoch_min).max(1.0);

        for division in 0..=4 {
            let fraction = division as f32 / 4.0;
            let y = top + plot_height * fraction;
            frame.stroke(
                &canvas::Path::line(Point::new(left, y), Point::new(left + plot_width, y)),
                canvas::Stroke::default().with_color(BORDER),
            );
            frame.fill_text(canvas::Text {
                content: format!("{:.2}", maximum * (1.0 - fraction)),
                position: Point::new(0.0, y - 7.0),
                color: MUTED,
                size: 11.0.into(),
                ..Default::default()
            });
        }

        for (validation, color) in [(false, TEAL), (true, BLUE)] {
            let points: Vec<Point> = self
                .points
                .iter()
                .filter_map(|point| {
                    let value = if validation { point.valid } else { point.train }?;

                    value.is_finite().then(|| {
                        Point::new(
                            left + plot_width * (point.epoch - epoch_min) / epoch_span,
                            top + plot_height * (1.0 - value / maximum),
                        )
                    })
                })
                .collect();

            if let Some(first) = points.first() {
                let path = canvas::Path::new(|builder| {
                    builder.move_to(*first);

                    for point in points.iter().skip(1) {
                        builder.line_to(*point);
                    }
                });

                frame.stroke(
                    &path,
                    canvas::Stroke::default().with_color(color).with_width(2.0),
                );
            }
        }

        if self.points.is_empty() {
            frame.fill_text(canvas::Text {
                content: "Start a run to see real training measurements".into(),
                position: Point::new(left + 16.0, top + plot_height / 2.0),
                color: MUTED,
                size: 14.0.into(),
                ..Default::default()
            });
        }

        frame.fill_text(canvas::Text {
            content: format!("Epoch {epoch_min:.0}"),
            position: Point::new(left, top + plot_height + 8.0),
            color: MUTED,
            size: 11.0.into(),
            ..Default::default()
        });
        frame.fill_text(canvas::Text {
            content: format!("{epoch_max:.0}"),
            position: Point::new(left + plot_width, top + plot_height + 8.0),
            align_x: iced::alignment::Horizontal::Right.into(),
            color: MUTED,
            size: 11.0.into(),
            ..Default::default()
        });

        vec![frame.into_geometry()]
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use clap::Parser;

    fn dashboard(directory: &std::path::Path) -> Dashboard {
        let mut args = Args::parse_from(["micro-burn-app"]);
        args.artifacts = directory.to_path_buf();

        Dashboard::new(args)
    }

    #[test]
    fn a_lost_worker_does_not_leave_training_running_or_invent_success() {
        let directory = tempfile::tempdir().unwrap();
        let mut dashboard = dashboard(directory.path());
        let (sender, receiver) = mpsc::sync_channel(1);
        dashboard.running = true;
        dashboard.receiver = Some(receiver);
        drop(sender);
        dashboard.poll();

        assert!(!dashboard.running);
        assert!(
            dashboard
                .error
                .as_ref()
                .unwrap()
                .contains("without reporting an outcome")
        );
        assert_ne!(dashboard.snapshot.phase, Phase::Succeeded);
    }

    #[test]
    fn completion_restores_curve_points_dropped_from_the_live_queue() {
        let directory = tempfile::tempdir().unwrap();
        let mut dashboard = dashboard(directory.path());
        let epochs: Vec<_> = (1..=200)
            .map(|epoch| {
                serde_json::json!({
                    "epoch": epoch,
                    "gnn_train_mse": 1.0 / epoch as f64,
                    "gnn_validation_mse": 1.2 / epoch as f64,
                })
            })
            .collect();
        std::fs::write(
            directory.path().join("history.json"),
            serde_json::to_vec(&epochs).unwrap(),
        )
        .unwrap();
        let results = TrainingResults {
            model_metrics: Vec::new(),
            best_epoch: 200,
            artifact_dir: directory.path().to_path_buf(),
            summary: "test fixture".into(),
        };
        let (sender, receiver) = mpsc::sync_channel(2);
        sender
            .send(TrainingEvent::Snapshot(Snapshot {
                phase: Phase::Validating,
                epoch: 1,
                train_loss: Some(1.0),
                valid_loss: Some(1.2),
                ..Snapshot::default()
            }))
            .unwrap();
        sender.send(TrainingEvent::Finished(Ok(results))).unwrap();
        drop(sender);
        dashboard.running = true;
        dashboard.receiver = Some(receiver);
        dashboard.poll();

        assert!(!dashboard.running);
        assert!(dashboard.error.is_none());
        assert_eq!(dashboard.history.len(), 200);
        assert_eq!(dashboard.history.last().unwrap().epoch, 200.0);
    }
}
