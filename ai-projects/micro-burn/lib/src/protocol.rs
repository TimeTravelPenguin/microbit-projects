//! Versioned, allocation-free messages shared by the laptop and micro:bit.

pub const VERSION: u8 = 1;
pub const FRAME_LEN: usize = 20;
pub const SNAPSHOT_FRAMES: usize = 8;
pub const LABEL_LEN: usize = 16;
pub const SERVICE_UUID: u128 = 0xa77e0001_0b5b_4bc7_a7f0_8debb64b0001;
pub const TELEMETRY_UUID: u128 = 0xa77e0001_0b5b_4bc7_a7f0_8debb64b0002;
pub const CONTROL_UUID: u128 = 0xa77e0001_0b5b_4bc7_a7f0_8debb64b0003;
pub const EVENTS_UUID: u128 = 0xa77e0001_0b5b_4bc7_a7f0_8debb64b0004;
pub const STATUS_UUID: u128 = 0xa77e0001_0b5b_4bc7_a7f0_8debb64b0005;

pub type Frame = [u8; FRAME_LEN];

const SNAPSHOT_KIND: u8 = 1;
const EVENT_KIND: u8 = 2;
const RESULT_KIND: u8 = 3;
const STATUS_KIND: u8 = 4;
const ASSEMBLY_TIMEOUT_MS: u64 = 3_000;

/// A printable ASCII run label, bounded independently of desktop string storage.
#[derive(Clone, Copy, Debug, Default, Eq, PartialEq)]
#[cfg_attr(feature = "host", derive(serde::Serialize, serde::Deserialize))]
pub struct Label([u8; LABEL_LEN]);

impl Label {
    /// Replace non-ASCII characters with `?` and truncate to the display budget.
    pub fn new(text: &str) -> Self {
        let mut bytes = [0; LABEL_LEN];

        for (idx, character) in text.chars().take(LABEL_LEN).enumerate() {
            bytes[idx] = if character.is_ascii_graphic() || character == ' ' {
                character as u8
            } else {
                b'?'
            };
        }

        Self(bytes)
    }

    pub fn as_str(&self) -> &str {
        let length = self
            .0
            .iter()
            .position(|byte| *byte == 0)
            .unwrap_or(LABEL_LEN);
        core::str::from_utf8(&self.0[..length]).unwrap_or("?")
    }
}

#[derive(Clone, Copy, Debug, Default, Eq, PartialEq)]
#[cfg_attr(feature = "host", derive(serde::Serialize, serde::Deserialize))]
#[repr(u8)]
pub enum Phase {
    #[default]
    Idle = 0,
    Preparing = 1,
    Training = 2,
    Validating = 3,
    Evaluating = 4,
    Saving = 5,
    Succeeded = 6,
    Interrupted = 7,
    Failed = 8,
}

impl Phase {
    pub fn is_terminal(self) -> bool {
        matches!(self, Self::Succeeded | Self::Interrupted | Self::Failed)
    }

    pub fn label(self) -> &'static str {
        match self {
            Self::Idle => "IDLE",
            Self::Preparing => "PREPARING",
            Self::Training => "TRAINING",
            Self::Validating => "VALIDATING",
            Self::Evaluating => "EVALUATING",
            Self::Saving => "SAVING",
            Self::Succeeded => "COMPLETE",
            Self::Interrupted => "STOPPED",
            Self::Failed => "FAILED",
        }
    }
}

impl TryFrom<u8> for Phase {
    type Error = ProtocolError;

    fn try_from(value: u8) -> Result<Self, Self::Error> {
        match value {
            0 => Ok(Self::Idle),
            1 => Ok(Self::Preparing),
            2 => Ok(Self::Training),
            3 => Ok(Self::Validating),
            4 => Ok(Self::Evaluating),
            5 => Ok(Self::Saving),
            6 => Ok(Self::Succeeded),
            7 => Ok(Self::Interrupted),
            8 => Ok(Self::Failed),
            _ => Err(ProtocolError::InvalidValue),
        }
    }
}

#[derive(Clone, Copy, Debug, Default, Eq, PartialEq)]
#[cfg_attr(feature = "host", derive(serde::Serialize, serde::Deserialize))]
#[repr(u8)]
pub enum AlertPolicy {
    #[default]
    All = 0,
    ErrorsOnly = 1,
    Muted = 2,
}

impl TryFrom<u8> for AlertPolicy {
    type Error = ProtocolError;

    fn try_from(value: u8) -> Result<Self, Self::Error> {
        match value {
            0 => Ok(Self::All),
            1 => Ok(Self::ErrorsOnly),
            2 => Ok(Self::Muted),
            _ => Err(ProtocolError::InvalidValue),
        }
    }
}

/// An authoritative host observation; `None` is unavailable, never numeric zero.
#[derive(Clone, Copy, Debug, Default, PartialEq)]
#[cfg_attr(feature = "host", derive(serde::Serialize, serde::Deserialize))]
pub struct Snapshot {
    pub run_id: u32,
    pub sequence: u32,
    pub event_id: u32,
    pub phase: Phase,
    pub epoch: u16,
    pub epochs: u16,
    pub progress_permille: u16,
    pub elapsed_secs: u32,
    pub eta_secs: Option<u32>,
    pub train_loss: Option<f32>,
    pub valid_loss: Option<f32>,
    pub learning_rate: Option<f32>,
    pub mae: Option<f32>,
    pub rmse: Option<f32>,
    pub label: Label,
    pub alert_policy: AlertPolicy,
    pub acknowledged: bool,
    /// Host-observed age of actual trainer data, separate from BLE heartbeats.
    pub trainer_age_secs: u16,
}

impl Snapshot {
    pub fn validate(&self) -> Result<(), ProtocolError> {
        let metrics = [
            self.train_loss,
            self.valid_loss,
            self.learning_rate,
            self.mae,
            self.rmse,
        ];

        if self.progress_permille > 1_000
            || metrics.iter().flatten().any(|value| !value.is_finite())
            || self.eta_secs == Some(u32::MAX)
            || (self.epochs != 0 && self.epoch > self.epochs)
            || !self
                .label
                .0
                .iter()
                .all(|byte| *byte == 0 || byte.is_ascii_graphic() || *byte == b' ')
        {
            return Err(ProtocolError::InvalidValue);
        }

        Ok(())
    }

    pub fn frames(&self) -> [Frame; SNAPSHOT_FRAMES] {
        let mut bytes = [0; 64];
        bytes[0..4].copy_from_slice(&self.event_id.to_le_bytes());
        bytes[4] = self.phase as u8;
        bytes[5..7].copy_from_slice(&self.epoch.to_le_bytes());
        bytes[7..9].copy_from_slice(&self.epochs.to_le_bytes());
        bytes[9..11].copy_from_slice(&self.progress_permille.to_le_bytes());
        bytes[11..15].copy_from_slice(&self.elapsed_secs.to_le_bytes());
        bytes[15..19].copy_from_slice(&self.eta_secs.unwrap_or(u32::MAX).to_le_bytes());

        for (idx, metric) in [
            self.train_loss,
            self.valid_loss,
            self.learning_rate,
            self.mae,
            self.rmse,
        ]
        .iter()
        .enumerate()
        {
            let start = 19 + idx * 4;
            bytes[start..start + 4].copy_from_slice(&metric.unwrap_or(f32::NAN).to_le_bytes());
        }

        bytes[39..55].copy_from_slice(&self.label.0);
        bytes[55] = self.alert_policy as u8;
        bytes[56] = u8::from(self.acknowledged);
        bytes[57..59].copy_from_slice(&self.trainer_age_secs.to_le_bytes());
        let mut frames = [[0; FRAME_LEN]; SNAPSHOT_FRAMES];

        for (idx, frame) in frames.iter_mut().enumerate() {
            *frame = header(SNAPSHOT_KIND, self.run_id, self.sequence);
            frame[2] = idx as u8;
            frame[3] = SNAPSHOT_FRAMES as u8;
            frame[12..20].copy_from_slice(&bytes[idx * 8..idx * 8 + 8]);
        }

        frames
    }

    fn decode(bytes: &[u8; 64], run_id: u32, sequence: u32) -> Result<Self, ProtocolError> {
        let mut label = [0; LABEL_LEN];
        label.copy_from_slice(&bytes[39..55]);

        if !label
            .iter()
            .all(|byte| *byte == 0 || byte.is_ascii_graphic() || *byte == b' ')
            || bytes[56] > 1
            || bytes[59..].iter().any(|byte| *byte != 0)
        {
            return Err(ProtocolError::InvalidValue);
        }

        let eta = read_u32(&bytes[15..19]);
        let snapshot = Self {
            run_id,
            sequence,
            event_id: read_u32(&bytes[0..4]),
            phase: bytes[4].try_into()?,
            epoch: read_u16(&bytes[5..7]),
            epochs: read_u16(&bytes[7..9]),
            progress_permille: read_u16(&bytes[9..11]),
            elapsed_secs: read_u32(&bytes[11..15]),
            eta_secs: (eta != u32::MAX).then_some(eta),
            train_loss: read_metric(&bytes[19..23])?,
            valid_loss: read_metric(&bytes[23..27])?,
            learning_rate: read_metric(&bytes[27..31])?,
            mae: read_metric(&bytes[31..35])?,
            rmse: read_metric(&bytes[35..39])?,
            label: Label(label),
            alert_policy: bytes[55].try_into()?,
            acknowledged: bytes[56] != 0,
            trainer_age_secs: read_u16(&bytes[57..59]),
        };

        snapshot.validate()?;
        Ok(snapshot)
    }
}

/// Assemble complete snapshots without mixing sequences or publishing fragments.
pub struct SnapshotAssembler {
    run_id: u32,
    sequence: u32,
    bytes: [u8; 64],
    received: u8,
    started_ms: u64,
    last_complete: Option<(u32, u32)>,
}

impl Default for SnapshotAssembler {
    fn default() -> Self {
        Self::new()
    }
}

impl SnapshotAssembler {
    pub const fn new() -> Self {
        Self {
            run_id: 0,
            sequence: 0,
            bytes: [0; 64],
            received: 0,
            started_ms: 0,
            last_complete: None,
        }
    }

    pub fn reset(&mut self) {
        *self = Self::new();
    }

    pub fn push(&mut self, frame: &[u8], now_ms: u64) -> Result<Option<Snapshot>, ProtocolError> {
        check_frame(frame, SNAPSHOT_KIND)?;

        if frame[3] as usize != SNAPSHOT_FRAMES || frame[2] as usize >= SNAPSHOT_FRAMES {
            return Err(ProtocolError::InvalidFragment);
        }

        let run_id = read_u32(&frame[4..8]);
        let sequence = read_u32(&frame[8..12]);

        if let Some((last_run, last_sequence)) = self.last_complete {
            if run_id == last_run && is_older(sequence, last_sequence) {
                return Err(ProtocolError::Outdated);
            }
        }

        let timed_out = now_ms.saturating_sub(self.started_ms) > ASSEMBLY_TIMEOUT_MS;
        let changed = run_id != self.run_id || sequence != self.sequence;

        if self.received == 0 || timed_out || changed {
            if changed
                && run_id == self.run_id
                && self.received != 0
                && is_older(sequence, self.sequence)
            {
                return Err(ProtocolError::Outdated);
            }

            self.run_id = run_id;
            self.sequence = sequence;
            self.received = 0;
            self.bytes.fill(0);
            self.started_ms = now_ms;
        }

        let idx = frame[2] as usize;
        self.bytes[idx * 8..idx * 8 + 8].copy_from_slice(&frame[12..20]);
        self.received |= 1 << idx;

        if self.received != u8::MAX {
            return Ok(None);
        }

        self.received = 0;
        let snapshot = Snapshot::decode(&self.bytes, run_id, sequence)?;
        self.last_complete = Some((run_id, sequence));
        Ok(Some(snapshot))
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
#[repr(u8)]
pub enum ActionKind {
    Received = 1,
    Acknowledged = 2,
    Snoozed = 3,
    SetAlertPolicy = 4,
    Bookmark = 5,
}

impl TryFrom<u8> for ActionKind {
    type Error = ProtocolError;

    fn try_from(value: u8) -> Result<Self, Self::Error> {
        match value {
            1 => Ok(Self::Received),
            2 => Ok(Self::Acknowledged),
            3 => Ok(Self::Snoozed),
            4 => Ok(Self::SetAlertPolicy),
            5 => Ok(Self::Bookmark),
            _ => Err(ProtocolError::InvalidValue),
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct DeviceEvent {
    pub run_id: u32,
    pub sequence: u32,
    pub event_id: u32,
    pub action_id: u16,
    pub kind: ActionKind,
    /// Snooze seconds or AlertPolicy discriminant; otherwise zero.
    pub value: u8,
}

impl DeviceEvent {
    pub fn encode(self) -> Frame {
        let mut frame = header(EVENT_KIND, self.run_id, self.sequence);
        frame[12..16].copy_from_slice(&self.event_id.to_le_bytes());
        frame[16..18].copy_from_slice(&self.action_id.to_le_bytes());
        frame[18] = self.kind as u8;
        frame[19] = self.value;
        frame
    }

    pub fn decode(frame: &[u8]) -> Result<Self, ProtocolError> {
        check_single_frame(frame, EVENT_KIND)?;
        let kind = ActionKind::try_from(frame[18])?;

        if (kind == ActionKind::SetAlertPolicy && AlertPolicy::try_from(frame[19]).is_err())
            || (kind == ActionKind::Snoozed && !(1..=60).contains(&frame[19]))
        {
            return Err(ProtocolError::InvalidValue);
        }

        Ok(Self {
            run_id: read_u32(&frame[4..8]),
            sequence: read_u32(&frame[8..12]),
            event_id: read_u32(&frame[12..16]),
            action_id: read_u16(&frame[16..18]),
            kind,
            value: frame[19],
        })
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct ActionResult {
    pub run_id: u32,
    pub sequence: u32,
    pub action_id: u16,
    pub accepted: bool,
}

impl ActionResult {
    pub fn encode(self) -> Frame {
        let mut frame = header(RESULT_KIND, self.run_id, self.sequence);
        frame[12..14].copy_from_slice(&self.action_id.to_le_bytes());
        frame[14] = u8::from(self.accepted);
        frame
    }

    pub fn decode(frame: &[u8]) -> Result<Self, ProtocolError> {
        check_single_frame(frame, RESULT_KIND)?;

        if frame[14] > 1 || frame[15..].iter().any(|byte| *byte != 0) {
            return Err(ProtocolError::InvalidValue);
        }

        Ok(Self {
            run_id: read_u32(&frame[4..8]),
            sequence: read_u32(&frame[8..12]),
            action_id: read_u16(&frame[12..14]),
            accepted: frame[14] != 0,
        })
    }
}

#[derive(Clone, Copy, Debug, Default, Eq, PartialEq)]
pub struct DeviceStatus {
    pub run_id: u32,
    pub sequence: u32,
    pub event_id: u32,
    pub acknowledged: bool,
    pub alert_policy: AlertPolicy,
}

impl DeviceStatus {
    pub fn encode(self) -> Frame {
        let mut frame = header(STATUS_KIND, self.run_id, self.sequence);
        frame[12..16].copy_from_slice(&self.event_id.to_le_bytes());
        frame[16] = u8::from(self.acknowledged);
        frame[17] = self.alert_policy as u8;
        frame
    }

    pub fn decode(frame: &[u8]) -> Result<Self, ProtocolError> {
        check_single_frame(frame, STATUS_KIND)?;

        if frame[16] > 1 || frame[18..].iter().any(|byte| *byte != 0) {
            return Err(ProtocolError::InvalidValue);
        }

        Ok(Self {
            run_id: read_u32(&frame[4..8]),
            sequence: read_u32(&frame[8..12]),
            event_id: read_u32(&frame[12..16]),
            acknowledged: frame[16] != 0,
            alert_policy: frame[17].try_into()?,
        })
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum ProtocolError {
    InvalidLength,
    UnsupportedVersion,
    InvalidKind,
    InvalidFragment,
    InvalidValue,
    Outdated,
}

impl core::fmt::Display for ProtocolError {
    fn fmt(&self, formatter: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
        write!(formatter, "{self:?}")
    }
}

impl core::error::Error for ProtocolError {}

fn header(kind: u8, run_id: u32, sequence: u32) -> Frame {
    let mut frame = [0; FRAME_LEN];
    frame[0] = VERSION;
    frame[1] = kind;
    frame[3] = 1;
    frame[4..8].copy_from_slice(&run_id.to_le_bytes());
    frame[8..12].copy_from_slice(&sequence.to_le_bytes());
    frame
}

fn check_frame(frame: &[u8], kind: u8) -> Result<(), ProtocolError> {
    if frame.len() != FRAME_LEN {
        return Err(ProtocolError::InvalidLength);
    }

    if frame[0] != VERSION {
        return Err(ProtocolError::UnsupportedVersion);
    }

    if frame[1] != kind {
        return Err(ProtocolError::InvalidKind);
    }

    Ok(())
}

fn check_single_frame(frame: &[u8], kind: u8) -> Result<(), ProtocolError> {
    check_frame(frame, kind)?;

    if frame[2] != 0 || frame[3] != 1 {
        return Err(ProtocolError::InvalidFragment);
    }

    Ok(())
}

fn read_u16(bytes: &[u8]) -> u16 {
    u16::from_le_bytes(bytes.try_into().unwrap())
}

fn read_u32(bytes: &[u8]) -> u32 {
    u32::from_le_bytes(bytes.try_into().unwrap())
}

fn read_metric(bytes: &[u8]) -> Result<Option<f32>, ProtocolError> {
    let value = f32::from_le_bytes(bytes.try_into().unwrap());

    if value.is_infinite() {
        return Err(ProtocolError::InvalidValue);
    }

    Ok((!value.is_nan()).then_some(value))
}

fn is_older(sequence: u32, reference: u32) -> bool {
    sequence.wrapping_sub(reference) > i32::MAX as u32
}

#[cfg(test)]
mod tests;
