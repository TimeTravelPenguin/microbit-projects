//! Host-side reporting and BLE connection management.
//!
//! [`Reporter::publish`] only updates bounded memory. Bluetooth and retained-state
//! I/O happen on the monitor's worker, so training never waits for the pager.

use std::{
    collections::{HashMap, VecDeque},
    path::{Path, PathBuf},
    sync::{
        Arc, Mutex,
        atomic::{AtomicBool, AtomicU32, Ordering},
        mpsc,
    },
    time::{SystemTime, UNIX_EPOCH},
};

use btleplug::{
    api::{
        Central, CharPropFlags, Characteristic, Manager as _, Peripheral as _, ScanFilter,
        WriteType,
    },
    platform::{Adapter, Manager, Peripheral},
};
use futures_util::{StreamExt, stream::BoxStream};
use tokio::{
    sync::watch,
    time::{Duration, Instant},
};
use uuid::Uuid;

use crate::protocol::{
    ActionKind, ActionResult, AlertPolicy, CONTROL_UUID, DeviceEvent, DeviceStatus, EVENTS_UUID,
    Label, Phase, ProtocolError, SERVICE_UUID, STATUS_UUID, Snapshot, TELEMETRY_UUID,
};

type WorkerError = Box<dyn std::error::Error + Send + Sync>;

const HISTORY_LIMIT: usize = 256;
const ACTION_HISTORY_LIMIT: usize = 64;
const SENT_HISTORY_LIMIT: usize = 64;

#[derive(Clone)]
pub struct Reporter {
    shared: Arc<Shared>,
}

struct Shared {
    latest: watch::Sender<Snapshot>,
    mutation: Mutex<()>,
    history: Mutex<VecDeque<Snapshot>>,
    terminal: Mutex<Option<Snapshot>>,
    sequence: AtomicU32,
    last_observation: Mutex<Instant>,
}

impl Reporter {
    /// Create a reporter without starting Bluetooth or allocating a runtime.
    pub fn new(label: &str) -> Self {
        let initial = Snapshot {
            run_id: next_run_id(),
            label: Label::new(label),
            ..Snapshot::default()
        };
        let (latest, _) = watch::channel(initial);

        Self {
            shared: Arc::new(Shared {
                latest,
                mutation: Mutex::new(()),
                history: Mutex::new(VecDeque::with_capacity(HISTORY_LIMIT)),
                terminal: Mutex::new(None),
                sequence: AtomicU32::new(0),
                last_observation: Mutex::new(Instant::now()),
            }),
        }
    }

    pub fn snapshot(&self) -> Snapshot {
        let mut snapshot = *self.shared.latest.borrow();
        snapshot.trainer_age_secs = self
            .shared
            .last_observation
            .lock()
            .unwrap_or_else(|err| err.into_inner())
            .elapsed()
            .as_secs()
            .min(u16::MAX as u64) as u16;
        snapshot
    }

    /// Start another run while retaining the user's alert policy.
    pub fn begin_run(&self, label: &str) -> Snapshot {
        let snapshot = Snapshot {
            run_id: next_run_id(),
            phase: Phase::Preparing,
            label: Label::new(label),
            alert_policy: self.snapshot().alert_policy,
            ..Snapshot::default()
        };
        self.publish(snapshot)
            .expect("new run contains valid fields")
    }

    /// Publish a snapshot and return its canonical sequence/event identifiers.
    ///
    /// This does no file or Bluetooth I/O. Intermediate observations may coalesce;
    /// terminal outcomes have separate retained storage. Only finite metrics are
    /// accepted. The application explicitly reports success after saving artifacts.
    pub fn publish(&self, snapshot: Snapshot) -> Result<Snapshot, ProtocolError> {
        self.publish_inner(snapshot, true, true)
    }

    fn publish_inner(
        &self,
        mut snapshot: Snapshot,
        preserve_policy: bool,
        observation: bool,
    ) -> Result<Snapshot, ProtocolError> {
        snapshot.validate()?;
        let _guard = self
            .shared
            .mutation
            .lock()
            .unwrap_or_else(|err| err.into_inner());
        let current = self.snapshot();

        if observation {
            *self
                .shared
                .last_observation
                .lock()
                .unwrap_or_else(|err| err.into_inner()) = Instant::now();
        }

        snapshot.trainer_age_secs = 0;

        if snapshot.run_id == current.run_id {
            if preserve_policy {
                snapshot.alert_policy = current.alert_policy;
            }

            if snapshot.event_id != 0
                && snapshot.event_id == current.event_id
                && current.acknowledged
            {
                snapshot.acknowledged = true;
            }
        } else {
            *self
                .shared
                .terminal
                .lock()
                .unwrap_or_else(|err| err.into_inner()) = None;
        }

        snapshot.sequence = self
            .shared
            .sequence
            .fetch_add(1, Ordering::Relaxed)
            .wrapping_add(1);

        if snapshot.phase.is_terminal() && snapshot.event_id == 0 {
            snapshot.event_id = snapshot.sequence;
        }

        if snapshot.phase.is_terminal() {
            *self
                .shared
                .terminal
                .lock()
                .unwrap_or_else(|err| err.into_inner()) = Some(snapshot);
        }

        let mut history = self
            .shared
            .history
            .lock()
            .unwrap_or_else(|err| err.into_inner());

        if history.len() == HISTORY_LIMIT {
            history.pop_front();
        }

        history.push_back(snapshot);
        drop(history);
        self.shared.latest.send_replace(snapshot);
        Ok(snapshot)
    }

    pub fn set_alert_policy(&self, policy: AlertPolicy) -> Snapshot {
        let mut snapshot = self.snapshot();
        snapshot.alert_policy = policy;
        self.publish_inner(snapshot, false, false)
            .expect("existing snapshot is valid")
    }

    pub fn acknowledge(&self) -> Snapshot {
        let mut snapshot = self.snapshot();

        if snapshot.phase.is_terminal() {
            snapshot.acknowledged = true;
        }

        self.publish_inner(snapshot, true, false)
            .expect("existing snapshot is valid")
    }

    pub fn snapshot_at(&self, run_id: u32, sequence: u32) -> Option<Snapshot> {
        self.shared
            .history
            .lock()
            .unwrap_or_else(|err| err.into_inner())
            .iter()
            .find(|snapshot| snapshot.run_id == run_id && snapshot.sequence == sequence)
            .copied()
    }

    fn restore(&self, snapshot: Snapshot) -> bool {
        let _guard = self
            .shared
            .mutation
            .lock()
            .unwrap_or_else(|err| err.into_inner());

        if self.snapshot().phase != Phase::Idle {
            return false;
        }

        self.shared
            .sequence
            .store(snapshot.sequence, Ordering::Relaxed);
        *self
            .shared
            .terminal
            .lock()
            .unwrap_or_else(|err| err.into_inner()) = Some(snapshot);
        self.shared
            .history
            .lock()
            .unwrap_or_else(|err| err.into_inner())
            .push_back(snapshot);
        self.shared.latest.send_replace(snapshot);
        true
    }
}

impl Default for Reporter {
    fn default() -> Self {
        Self::new("Burn training")
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct DeviceInfo {
    /// Opaque platform ID; macOS does not provide the peripheral MAC address.
    pub id: String,
    pub name: String,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum ConnectionState {
    Disconnected,
    Scanning,
    Connecting(String),
    Ready(String),
}

#[derive(Clone, Debug)]
pub enum HostEvent {
    DeviceFound(DeviceInfo),
    Connection(ConnectionState),
    Action(DeviceEvent),
    Bookmark {
        event: DeviceEvent,
        snapshot: Snapshot,
    },
    Recovered(Snapshot),
    Error(String),
}

enum Command {
    Scan,
    Connect(String),
    Disconnect,
    Shutdown,
}

/// Owns a BLE worker and a polling event receiver suitable for an Iced UI.
pub struct Monitor {
    pub reporter: Reporter,
    commands: tokio::sync::mpsc::Sender<Command>,
    events: mpsc::Receiver<HostEvent>,
    worker: Option<std::thread::JoinHandle<()>>,
    shutdown: Arc<AtomicBool>,
}

impl Monitor {
    /// `state_path` is a small retained terminal-result record, not a training log.
    /// Bluetooth permission is requested only after an explicit scan or connection.
    pub fn new(label: &str, state_path: Option<PathBuf>) -> std::io::Result<Self> {
        let reporter = Reporter::new(label);
        let runtime = tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .worker_threads(1)
            .build()?;
        let (commands, receiver) = tokio::sync::mpsc::channel(8);
        let (sender, events) = mpsc::sync_channel(128);
        let worker_reporter = reporter.clone();
        let shutdown = Arc::new(AtomicBool::new(false));
        let worker_shutdown = shutdown.clone();

        let worker = std::thread::Builder::new()
            .name("micro-burn-ble".into())
            .spawn(move || {
                runtime.block_on(worker(
                    worker_reporter,
                    receiver,
                    sender,
                    state_path,
                    worker_shutdown,
                ));
            })?;

        Ok(Self {
            reporter,
            commands,
            events,
            worker: Some(worker),
            shutdown,
        })
    }

    pub fn scan(&self) {
        let _ = self.commands.try_send(Command::Scan);
    }

    pub fn connect(&self, device_id: &str) {
        let _ = self
            .commands
            .try_send(Command::Connect(device_id.to_owned()));
    }

    pub fn disconnect(&self) {
        let _ = self.commands.try_send(Command::Disconnect);
    }

    pub fn try_recv(&self) -> Result<HostEvent, mpsc::TryRecvError> {
        self.events.try_recv()
    }

    /// Flush retained outcomes and join the worker when closing the application.
    /// This may wait for the current bounded BLE operation; never call from a
    /// training callback. Dropping the monitor performs the same cleanup.
    pub fn shutdown(&mut self) -> std::io::Result<()> {
        self.shutdown.store(true, Ordering::Release);
        let _ = self.commands.try_send(Command::Shutdown);

        if let Some(worker) = self.worker.take() {
            worker
                .join()
                .map_err(|_| std::io::Error::other("Bluetooth worker panicked"))?;
        }

        Ok(())
    }
}

impl Drop for Monitor {
    fn drop(&mut self) {
        let _ = self.shutdown();
    }
}

struct Connection {
    peripheral: Peripheral,
    telemetry: Characteristic,
    control: Characteristic,
}

struct Worker {
    reporter: Reporter,
    events: mpsc::SyncSender<HostEvent>,
    state_path: Option<PathBuf>,
    manager: Option<Manager>,
    adapter: Option<Adapter>,
    devices: HashMap<String, Peripheral>,
    selected: Option<String>,
    connection: Option<Connection>,
    actions: VecDeque<(u32, u16, bool)>,
    sent: VecDeque<Snapshot>,
    received: Option<(u32, u32)>,
    last_saved: Option<Snapshot>,
}

async fn worker(
    reporter: Reporter,
    mut commands: tokio::sync::mpsc::Receiver<Command>,
    events: mpsc::SyncSender<HostEvent>,
    state_path: Option<PathBuf>,
    shutdown: Arc<AtomicBool>,
) {
    let mut updates = reporter.shared.latest.subscribe();
    let mut worker = Worker {
        reporter,
        events,
        state_path,
        manager: None,
        adapter: None,
        devices: HashMap::new(),
        selected: None,
        connection: None,
        actions: VecDeque::with_capacity(ACTION_HISTORY_LIMIT),
        sent: VecDeque::with_capacity(SENT_HISTORY_LIMIT),
        received: None,
        last_saved: None,
    };

    worker.restore().await;
    let mut notifications: Option<BoxStream<'static, btleplug::api::ValueNotification>> = None;
    let mut tick = tokio::time::interval(Duration::from_secs(1));
    let mut next_reconnect = Instant::now();

    loop {
        if shutdown.load(Ordering::Acquire) {
            worker.persist().await;
            worker.disconnect().await;
            break;
        }

        tokio::select! {
            command = commands.recv() => {
                match command {
                    Some(Command::Scan) => {
                        if let Err(err) = bounded(worker.scan(), "Scanning").await {
                            worker.error(err);

                            if worker.connection.is_none() {
                                worker.emit(HostEvent::Connection(ConnectionState::Disconnected));
                            }
                        }
                    }
                    Some(Command::Connect(id)) => {
                        worker.disconnect().await;
                        worker.selected = Some(id);
                        next_reconnect = Instant::now();
                    }
                    Some(Command::Disconnect) => {
                        worker.selected = None;
                        worker.disconnect().await;
                        notifications = None;
                    }
                    Some(Command::Shutdown) | None => {
                        worker.persist().await;
                        worker.disconnect().await;
                        break;
                    }
                }
            }
            changed = updates.changed() => {
                if changed.is_err() {
                    break;
                }

                worker.persist().await;

                if worker.reporter.snapshot().phase.is_terminal() {
                    if let Err(err) = bounded(worker.send_snapshot(), "Sending training snapshot").await {
                        worker.error(err);
                        worker.disconnect().await;
                        notifications = None;
                    }
                }
            }
            notification = next_notification(&mut notifications) => {
                match notification {
                    Some(notification) if notification.uuid == Uuid::from_u128(EVENTS_UUID) => {
                        match DeviceEvent::decode(&notification.value) {
                            Ok(event) => {
                                if let Err(err) = worker.action(event).await {
                                    worker.error(err);
                                }
                            }
                            Err(err) => worker.error(format!("Invalid device event: {err}").into()),
                        }
                    }
                    Some(_) => {}
                    None => {
                        worker.disconnect().await;
                        notifications = None;
                    }
                }
            }
            _ = tick.tick() => {
                worker.persist().await;

                if worker.connection.is_none() && worker.selected.is_some() && Instant::now() >= next_reconnect {
                    match worker.connect().await {
                        Ok(stream) => notifications = Some(stream),
                        Err(err) => worker.error(err),
                    }

                    next_reconnect = Instant::now() + Duration::from_secs(3);
                }

                if worker.connection.is_some() {
                    if let Err(err) = bounded(worker.send_snapshot(), "Sending training snapshot").await {
                        worker.error(err);
                        worker.disconnect().await;
                        notifications = None;
                    }
                }
            }
        }
    }
}

async fn next_notification(
    notifications: &mut Option<BoxStream<'static, btleplug::api::ValueNotification>>,
) -> Option<btleplug::api::ValueNotification> {
    match notifications {
        Some(stream) => stream.next().await,
        None => std::future::pending().await,
    }
}

async fn bounded<T>(
    operation: impl std::future::Future<Output = Result<T, WorkerError>>,
    description: &str,
) -> Result<T, WorkerError> {
    tokio::time::timeout(Duration::from_secs(8), operation)
        .await
        .map_err(|_| format!("{description} timed out"))?
}

impl Worker {
    fn emit(&self, event: HostEvent) -> bool {
        self.events.try_send(event).is_ok()
    }

    fn error(&self, error: WorkerError) {
        self.emit(HostEvent::Error(error.to_string()));
    }

    async fn adapter(&mut self) -> Result<Adapter, WorkerError> {
        if let Some(adapter) = &self.adapter {
            return Ok(adapter.clone());
        }

        let manager = Manager::new().await?;
        let adapter = manager
            .adapters()
            .await?
            .into_iter()
            .next()
            .ok_or("No Bluetooth adapter available")?;
        self.manager = Some(manager);
        self.adapter = Some(adapter.clone());
        Ok(adapter)
    }

    async fn scan(&mut self) -> Result<(), WorkerError> {
        self.emit(HostEvent::Connection(ConnectionState::Scanning));
        self.discover_devices().await?;

        if self.connection.is_none() {
            self.emit(HostEvent::Connection(ConnectionState::Disconnected));
        }

        Ok(())
    }

    async fn discover_devices(&mut self) -> Result<(), WorkerError> {
        let adapter = self.adapter().await?;
        let discovered = bounded(
            async {
                adapter
                    .start_scan(ScanFilter {
                        services: vec![Uuid::from_u128(SERVICE_UUID)],
                    })
                    .await?;
                tokio::time::sleep(Duration::from_secs(3)).await;
                Ok(adapter.peripherals().await?)
            },
            "Discovering training pagers",
        )
        .await;
        // Stop discovery on success and failure. A timeout must not leave an
        // otherwise idle monitor scanning indefinitely.
        let stopped = tokio::time::timeout(Duration::from_secs(2), adapter.stop_scan()).await;
        let peripherals = discovered?;
        stopped.map_err(|_| "Stopping Bluetooth discovery timed out")??;

        for peripheral in peripherals {
            let Some(properties) = peripheral.properties().await? else {
                continue;
            };

            if !properties.services.contains(&Uuid::from_u128(SERVICE_UUID)) {
                continue;
            }

            let id = peripheral.id().to_string();
            let name = properties
                .local_name
                .unwrap_or_else(|| "micro-burn pager".into());
            self.devices.insert(id.clone(), peripheral);
            self.emit(HostEvent::DeviceFound(DeviceInfo { id, name }));
        }

        Ok(())
    }

    async fn connect(
        &mut self,
    ) -> Result<BoxStream<'static, btleplug::api::ValueNotification>, WorkerError> {
        let id = self.selected.as_ref().ok_or("No device selected")?.clone();

        if !self.devices.contains_key(&id) {
            // CoreBluetooth removes a disconnected peripheral from its internal
            // registry. Rediscovery supplies a fresh handle; retrying the old
            // clone alone can never reconnect after a board reset.
            bounded(self.discover_devices(), "Rediscovering selected pager").await?;
        }

        let peripheral = self
            .devices
            .get(&id)
            .ok_or("Selected pager is not advertising yet; retrying automatically")?
            .clone();
        self.emit(HostEvent::Connection(ConnectionState::Connecting(
            id.clone(),
        )));
        let setup = bounded(
            async {
                peripheral.connect().await?;
                let notifications = peripheral.notifications().await?;
                peripheral.discover_services().await?;
                let characteristics = peripheral.characteristics();
                let find = |uuid, property| {
                    characteristics
                        .iter()
                        .find(|characteristic| {
                            characteristic.uuid == Uuid::from_u128(uuid)
                                && characteristic.properties.contains(property)
                        })
                        .cloned()
                        .ok_or_else(|| format!("Pager lacks compatible characteristic {uuid:032x}"))
                };
                let telemetry = find(TELEMETRY_UUID, CharPropFlags::WRITE)?;
                let control = find(CONTROL_UUID, CharPropFlags::WRITE)?;
                let events = find(EVENTS_UUID, CharPropFlags::NOTIFY)?;
                let status = find(STATUS_UUID, CharPropFlags::READ)?;
                peripheral.subscribe(&events).await?;
                let status = DeviceStatus::decode(&peripheral.read(&status).await?)?;
                Ok((notifications, telemetry, control, status))
            },
            "Connecting and discovering pager",
        )
        .await;
        let (notifications, telemetry, control, status) = match setup {
            Ok(setup) => setup,
            Err(err) => {
                let _ = tokio::time::timeout(Duration::from_secs(2), peripheral.disconnect()).await;
                self.devices.remove(&id);
                return Err(err);
            }
        };

        let current = self.reporter.snapshot();

        if status.run_id == current.run_id {
            if status.event_id == current.event_id && status.acknowledged {
                self.reporter.acknowledge();
            }
        }

        self.connection = Some(Connection {
            peripheral,
            telemetry,
            control,
        });
        self.emit(HostEvent::Connection(ConnectionState::Ready(id)));
        Ok(notifications)
    }

    async fn disconnect(&mut self) {
        self.received = None;

        if let Some(connection) = self.connection.take() {
            self.devices.remove(&connection.peripheral.id().to_string());
            let _ =
                tokio::time::timeout(Duration::from_secs(2), connection.peripheral.disconnect())
                    .await;
        }

        if let Some(id) = &self.selected {
            self.devices.remove(id);
        }

        self.emit(HostEvent::Connection(ConnectionState::Disconnected));
    }

    async fn send_snapshot(&mut self) -> Result<(), WorkerError> {
        let Some(connection) = &self.connection else {
            return Ok(());
        };

        if !connection.peripheral.is_connected().await? {
            return Err("Pager disconnected".into());
        }

        let snapshot = self.reporter.snapshot();

        if snapshot.phase.is_terminal()
            && self.received == Some((snapshot.run_id, snapshot.sequence))
        {
            return Ok(());
        }

        let characteristic = if snapshot.phase.is_terminal() {
            &connection.control
        } else {
            &connection.telemetry
        };

        for frame in snapshot.frames() {
            connection
                .peripheral
                .write(characteristic, &frame, WriteType::WithResponse)
                .await?;
        }

        if self.sent.back().is_some_and(|last| {
            last.run_id == snapshot.run_id && last.sequence == snapshot.sequence
        }) {
            *self.sent.back_mut().unwrap() = snapshot;
        } else {
            if self.sent.len() == SENT_HISTORY_LIMIT {
                self.sent.pop_front();
            }

            self.sent.push_back(snapshot);
        }

        Ok(())
    }

    async fn action(&mut self, event: DeviceEvent) -> Result<(), WorkerError> {
        if event.kind == ActionKind::Received {
            let valid = self.sent.iter().any(|snapshot| {
                snapshot.run_id == event.run_id
                    && snapshot.sequence == event.sequence
                    && snapshot.event_id == event.event_id
            });

            if valid && self.received != Some((event.run_id, event.sequence)) {
                self.received = Some((event.run_id, event.sequence));
                self.emit(HostEvent::Action(event));
            }

            return Ok(());
        }

        let cached = self
            .actions
            .iter()
            .find(|(run, action, _)| *run == event.run_id && *action == event.action_id);
        let accepted = if let Some((_, _, accepted)) = cached {
            *accepted
        } else {
            let accepted = if event.kind == ActionKind::Bookmark {
                self.bookmark(event).await
            } else {
                self.apply_action(event)
            };

            if self.actions.len() == ACTION_HISTORY_LIMIT {
                self.actions.pop_front();
            }

            self.actions
                .push_back((event.run_id, event.action_id, accepted));
            accepted
        };

        self.persist().await;

        if let Some(connection) = &self.connection {
            let frame = ActionResult {
                run_id: event.run_id,
                sequence: event.sequence,
                action_id: event.action_id,
                accepted,
            }
            .encode();
            tokio::time::timeout(
                Duration::from_secs(3),
                connection
                    .peripheral
                    .write(&connection.control, &frame, WriteType::WithResponse),
            )
            .await
            .map_err(|_| "Sending action result timed out")??;
        }

        Ok(())
    }

    fn apply_action(&mut self, event: DeviceEvent) -> bool {
        let current = self.reporter.snapshot();

        if event.run_id != current.run_id {
            return false;
        }

        match event.kind {
            ActionKind::Acknowledged => {
                if !current.phase.is_terminal() || current.event_id != event.event_id {
                    return false;
                }

                self.reporter.acknowledge();
            }
            ActionKind::SetAlertPolicy => {
                let Ok(policy) = AlertPolicy::try_from(event.value) else {
                    return false;
                };

                self.reporter.set_alert_policy(policy);
            }
            ActionKind::Bookmark => {
                let Some(snapshot) = self.bookmarked_snapshot(event) else {
                    return false;
                };

                if !self.emit(HostEvent::Bookmark { event, snapshot }) {
                    return false;
                }
            }
            ActionKind::Snoozed => {
                if !current.phase.is_terminal() || current.event_id != event.event_id {
                    return false;
                }
            }
            ActionKind::Received => {}
        }

        self.emit(HostEvent::Action(event));
        true
    }

    fn bookmarked_snapshot(&self, event: DeviceEvent) -> Option<Snapshot> {
        if event.run_id != self.reporter.snapshot().run_id {
            return None;
        }

        self.sent
            .iter()
            .find(|snapshot| snapshot.run_id == event.run_id && snapshot.sequence == event.sequence)
            .copied()
            .or_else(|| self.reporter.snapshot_at(event.run_id, event.sequence))
    }

    async fn bookmark(&mut self, event: DeviceEvent) -> bool {
        let Some(snapshot) = self.bookmarked_snapshot(event) else {
            return false;
        };

        if let Some(path) = &self.state_path {
            if let Err(err) =
                write_bookmark(&path.with_extension("bookmarks.jsonl"), event, &snapshot).await
            {
                self.error(format!("Saving bookmark: {err}").into());
                return false;
            }
        }

        let queued = self.emit(HostEvent::Bookmark { event, snapshot });

        if !queued && self.state_path.is_none() {
            return false;
        }

        self.emit(HostEvent::Action(event));
        true
    }

    async fn restore(&mut self) {
        let Some(path) = &self.state_path else {
            return;
        };

        match tokio::fs::read(path).await {
            Ok(bytes) => {
                match serde_json::from_slice::<Snapshot>(&bytes) {
                    Ok(snapshot) if snapshot.phase.is_terminal() && snapshot.validate().is_ok() => {
                        // A fast new run must never be overwritten by startup recovery.
                        if self.reporter.restore(snapshot) {
                            self.last_saved = Some(snapshot);
                            self.emit(HostEvent::Recovered(snapshot));
                        }
                    }
                    Ok(snapshot)
                        if snapshot.phase != Phase::Idle && snapshot.validate().is_ok() =>
                    {
                        self.last_saved = Some(snapshot);
                        self.emit(HostEvent::Error(format!(
                            "Previous run '{}' has no reported final outcome; status unknown",
                            snapshot.label.as_str()
                        )));
                    }
                    _ => {
                        self.emit(HostEvent::Error(
                            "Retained pager state is invalid; ignoring it".into(),
                        ));
                    }
                }
            }
            Err(err) if err.kind() == std::io::ErrorKind::NotFound => {}
            Err(err) => {
                self.emit(HostEvent::Error(format!(
                    "Reading retained pager state: {err}"
                )));
            }
        }
    }

    async fn persist(&mut self) {
        let Some(path) = &self.state_path else {
            return;
        };
        let terminal = *self
            .reporter
            .shared
            .terminal
            .lock()
            .unwrap_or_else(|err| err.into_inner());
        let snapshot = match terminal {
            Some(snapshot) => snapshot,
            None => {
                let current = self.reporter.snapshot();

                if current.phase == Phase::Idle
                    || self.last_saved.is_some_and(|saved| {
                        saved.run_id == current.run_id && !saved.phase.is_terminal()
                    })
                {
                    return;
                }

                // Replace an obsolete success with one marker for this active
                // run. On a later restart its outcome is unknown, not success.
                current
            }
        };

        if self.last_saved == Some(snapshot) {
            return;
        }

        match write_retained(path, &snapshot).await {
            Ok(()) => self.last_saved = Some(snapshot),
            Err(err) => self.error(format!("Saving retained pager result: {err}").into()),
        }
    }
}

async fn write_retained(path: &Path, snapshot: &Snapshot) -> Result<(), WorkerError> {
    if let Some(parent) = path
        .parent()
        .filter(|parent| !parent.as_os_str().is_empty())
    {
        tokio::fs::create_dir_all(parent).await?;
    }

    let temporary = path.with_extension("tmp");
    tokio::fs::write(&temporary, serde_json::to_vec(snapshot)?).await?;
    tokio::fs::rename(temporary, path).await?;
    Ok(())
}

async fn write_bookmark(
    path: &Path,
    event: DeviceEvent,
    snapshot: &Snapshot,
) -> Result<(), WorkerError> {
    use tokio::io::{AsyncBufReadExt, AsyncWriteExt};

    if let Some(parent) = path
        .parent()
        .filter(|parent| !parent.as_os_str().is_empty())
    {
        tokio::fs::create_dir_all(parent).await?;
    }

    // Reading one line at a time bounds memory and makes an action retry after
    // process restart idempotent even when its previous response was lost.
    match tokio::fs::File::open(path).await {
        Ok(file) => {
            let mut lines = tokio::io::BufReader::new(file).lines();

            while let Some(line) = lines.next_line().await? {
                if let Ok(record) = serde_json::from_str::<serde_json::Value>(&line) {
                    if record["run_id"].as_u64() == Some(event.run_id as u64)
                        && record["action_id"].as_u64() == Some(event.action_id as u64)
                    {
                        return Ok(());
                    }
                }
            }
        }
        Err(err) if err.kind() == std::io::ErrorKind::NotFound => {}
        Err(err) => return Err(err.into()),
    }

    let record = serde_json::json!({
        "run_id": event.run_id,
        "action_id": event.action_id,
        "sequence": event.sequence,
        "recorded_unix_secs": SystemTime::now().duration_since(UNIX_EPOCH).unwrap_or_default().as_secs(),
        "snapshot": snapshot,
    });
    let mut file = tokio::fs::OpenOptions::new()
        .append(true)
        .create(true)
        .open(path)
        .await?;
    file.write_all(&serde_json::to_vec(&record)?).await?;
    file.write_all(b"\n").await?;
    file.sync_data().await?;
    Ok(())
}

fn next_run_id() -> u32 {
    static NEXT: AtomicU32 = AtomicU32::new(0);
    let timestamp = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_nanos() as u32;
    timestamp
        .wrapping_add(NEXT.fetch_add(1, Ordering::Relaxed))
        .max(1)
}

#[cfg(test)]
mod tests;
