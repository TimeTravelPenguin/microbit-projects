# micro-burn project specification

Status: implemented and exercised end to end; extended reliability checks remain
partially verified. Evidence and limits are recorded in [VALIDATION.md](VALIDATION.md).
Last updated: 2026-11-03, Australia/Sydney.

This file is the implementation contract. Complete its milestones and acceptance
criteria before adding extensions. Record material changes here with their reason.

## 1. Intended outcome

Train a small, real, multilayer graph neural network in an Iced desktop application
using Burn. A reusable library connects the training application to a micro:bit V2
over Bluetooth Low Energy. The micro:bit, fitted with a Kitronik :VIEW Graphics128,
shows useful progress and final results and sounds completion/error alerts.

The user can leave the desk, inspect training within Bluetooth coverage, and
acknowledge or snooze an alert from the board. Training must continue normally when
the board is absent, disconnected, or powered off.

## 2. Confirmed requirements and scope

- Exactly three project crates: `lib`, `firmware`, and `app`.
- The library is reusable in other Burn training projects.
- Firmware uses async Rust and demonstrates BLE setup and two-way communication.
- Hardware: micro:bit V2, Kitronik :VIEW Graphics128, and battery power for portability.
- The desktop app uses Iced, as selected by the user on 2026-11-03.
- The app trains and evaluates an actual GNN and reports training and results.
- Prefer a student-grade prediction task with real observed relationships.
- Include clear documentation of the GNN, BLE roles, and both async environments.

Version one supports one active training run and one selected micro:bit. It does
not include cloud accounts, remote training infrastructure, multi-device support,
phone apps, generic experiment tracking, or distributed training. Cooperative
remote stopping, pause/resume, and checkpoint-on-demand are later work rather than
assumed Burn capabilities. Do not add artificial delays to make training look long.

## 3. Three-part structure and ownership

Isolated Cargo workspace:

```text
projects/micro-burn/
  AGENTS.md
  SPEC.md
  DATASETS.md
  Cargo.toml
  Cargo.lock
  lib/         # package: micro-burn
  firmware/    # package: micro-burn-firmware
  app/         # package: micro-burn-app
```

Exclude this mini-workspace from the
repository's root firmware workspace. Build/check each executable for its own
target; do not build all members for one platform.

### Library

Own the nonblocking reporting API, Burn adapter, BLE connection lifecycle, compact
wire protocol, delivery state, and events received from the board. Keep model,
dataset, backend selection, Iced, and application artifact policy outside it.

Keep shared wire types and codecs inside this crate rather than adding a fourth
protocol crate. Feature boundaries:

- No default features: `no_std` protocol-only build, usable by firmware.
- `host`: standard library, Tokio, `btleplug`, device discovery and connection worker.
- `burn`: implies `host` and adds the version-specific Burn reporting adapter.

Firmware must not compile or link Burn, Tokio, desktop Bluetooth backends, or Iced.
The host API must let other Burn projects retain their existing renderer while
reporting telemetry. The example app supplies one Iced dashboard and does not
launch a second competing Burn TUI.

### Firmware

Own BLE peripheral/GATT-server operation, screen rendering, button input, sounds,
connection state, and local alert interaction. Depend on the library's protocol-only
build. Training outcomes originate on the laptop; firmware does not infer success
from a stopped progress counter or expired ETA.

### App

Own dataset preparation, GNN and baseline training, evaluation, model/results
artifacts, the Iced UI, and explicit run outcomes. Use the public library interface
for all device communication. Because the app trains the model itself, version one
needs no separate relay process, local socket, or scraped terminal output.

## 4. Dataset and learning task

Selected dataset: Czech classroom networks, Mendeley Data version 3. Predict a later
Czech-language subject grade from baseline grades and the baseline friendship graph.
The raw-file audit passed; see [DATA_AUDIT.md](DATA_AUDIT.md) for exact columns,
missingness, exclusions, provenance, and fixed split IDs. Source research and
alternatives remain in [DATASETS.md](DATASETS.md).

This is a close match to the user's example, with two explicit differences:
friendship nominations are not verified study partnerships, and teacher-assigned
subject grades are not individual exam marks. Do not describe them otherwise.

Before model implementation, inspect the raw files and record:

- Exact columns/sheets for student ID, classroom ID, T1/T2 grade and T1 literacy.
- The mapping between attribute IDs and both axes of each T1 network matrix.
- Grade direction, wave chronology, missing-value codes and usable sample counts.
- Whether incomplete labels/features require exclusions or training-fitted imputation.
- Version, download URL, checksum, attribution, and reproducible preprocessing.

If the public files cannot support the proposed temporal task, report the reason
and propose a documented alternative. Do not silently manufacture relationships or
replace the task. Dataset/model-specific code belongs only in `app`.

### First model

Default to a small GCN with two message-passing layers, ReLU activations, hidden
width 16, and a scalar linear regression head. Two layers allow information from
friends and friends-of-friends to contribute to a prediction. The model supports a
vector of additional hidden layers after the input layer: `hidden_layers` counts
those additional layers, so total message-passing depth is `1 + hidden_layers`.
The experiment's `HIDDEN_LAYERS` constant defaults to one. The matching MLP uses
the same depth, and exported configuration records the architecture for reload.

Represent each classroom as its own graph. Start with dense adjacency matrices;
these small graphs do not require a new sparse-graph framework. Add self-loops and
normalize adjacency. The implemented simplification makes a friendship edge undirected
when either student nominates the other; retain the original directed data and
document this transformation. Do not use same-class membership as an invented
friendship edge.

Use T1 grade as the single node feature. Baseline literacy is omitted because 55
records are missing it. Exclude the 26 students with entirely missing baseline
nomination rows, including the sole student missing both grades; retain the induced
graphs of 250 complete-case students. Exclude student ID, later grades,
later literacy, and later networks from input features. Start on CPU; an additional
compute backend is not an acceptance requirement.

### Evaluation contract

- Fixed split: eight classrooms/166 students for training, two/40 for validation,
  two/44 for test, stratified by intervention/control classroom type with split
  seed 42. Exact IDs and hash-order rule are in the audit. Model seed changes do
  not change the split. No student or classroom graph may span splits.
- Fit any normalization/imputation on the training split only.
- Optimize MSE; report MAE and RMSE in grade units, acknowledging the ordinal scale.
- Compare with the training-target mean, the student's prior grade, and an MLP
  with the same node features but no graph aggregation.
- Tune/stop using validation data; evaluate the selected model on held-out test
  data after selection. Record the checkpoint selection rule.
- Report usable counts, split IDs, seed, model configuration, and baseline results.
- Model improvement is an experimental result, not a completion requirement.
  Do not claim causation or practical validity for individual grading decisions.

## 5. Desktop experience and training execution

The Iced window shows run configuration, start/status, training and validation
loss curves, epoch/progress, learning rate, elapsed time, estimated remaining time,
device connection, alert state, and final evaluation/baseline comparisons.

Keep the initial settings small: epochs, learning rate, and seed, with fixed model
structure. Keep test results separate from validation curves. ETA is an estimate
and may be unavailable until enough progress has been observed.

Construct and run the Burn model/backend/training pipeline inside a dedicated
worker. The pinned Burn runner is not `Send`; do not construct it on the UI thread
and then assume it can be moved. Iced owns the UI; the library owns its async BLE
worker. Synchronous Burn hooks publish lightweight snapshots without awaiting
Bluetooth, screen rendering, disk writes, or reconnection.

Coalesce intermediate progress and retain bounded chart history. Preserve terminal
outcomes and action results independently of high-frequency metrics. A monitor
failure must be surfaced in the UI while leaving training able to finish.

Save the selected model, effective configuration, preprocessing/split metadata,
final metrics/baseline comparison, and prediction summary before declaring success.
The pager receives aggregate results and a short run label; student records remain
in the app's evaluation output.

## 6. Firmware experience

Three pages:

1. Overview: run label, phase, epoch/progress, elapsed time and estimated remaining time.
2. Metrics: train/validation loss, selected task metric and a short trend graph.
3. Details: final metrics or connection/freshness information and alert settings.

Completion/error events temporarily show a result screen and an audible alert.
Always retain a visible result after sound is silenced. Missing values display as
unavailable, not zero.

Button A cycles pages. Button B opens a small action menu. Actions are acknowledge,
snooze/change alert policy, and bookmark the displayed training point. Page changes
are local; acknowledgements, policy changes and bookmarks go back to the host.
Bookmarks identify the displayed snapshot, not whichever step the trainer reaches
when the request arrives. Show action confirmation or an explicit pending/offline
state. Acknowledging an alert must work locally even while disconnected.

Run BLE servicing, button sampling, display transfers and sounds concurrently.
Keep elapsed-time and link-freshness calculations independent of display refresh. Use the
existing async `kitronik-view` helper and `embedded-graphics`.

## 7. BLE and protocol contract

The laptop is the central/GATT client. Firmware is the advertising peripheral and
GATT server. Discovery uses a custom service UUID and explicit device selection,
not a hard-coded MAC address. Version one permits one unpaired, unencrypted client
and carries nonsensitive aggregate telemetry.

Use these characteristic roles:

| Characteristic | Operations | Meaning |
| --- | --- | --- |
| Telemetry | Write | Host sends metric/progress snapshot fragments |
| Control | Write with response | Host sends metadata, lifecycle events and action results |
| Device events | Notify | Board reports receipt, user acknowledgement, policy changes and bookmarks |
| Device status | Read | Protocol version, current run/event identifiers and device settings |

The host subscribes to device events before sending data. Use fixed-width,
little-endian, explicitly versioned messages. Keep each message within 20 bytes;
encode larger logical snapshots as a bounded set of messages sharing a run/session
token and sequence number. Publish only an assembled snapshot, and discard partial,
outdated, incompatible or malformed data. Bound run-label length and assembly time.

Send ordinary snapshots around once per second; send lifecycle events immediately.
Use separate delivery and human-acknowledgement states. Retain terminal events on
the host, with a small local record for restart recovery; reconcile the device's
run/event IDs and replay pending results on reconnect. Retries must not repeat a
human-acknowledged alarm. Firmware may retain the current session in RAM; persistence
across its power loss is not a first-version guarantee.

After reconnect, negotiate/check protocol compatibility, restore subscriptions and
send authoritative current state. Do not blindly replay old user commands.

## 8. Lifecycle and reliability

Application phases: preparing, training, validating, evaluating, saving/exporting,
succeeded, interrupted, failed. Configured early stopping is a successful training
strategy when evaluation/artifact saving succeeds; it is not user cancellation.

Emit success only after required model and results artifacts are saved. Burn's
generic end callbacks run after interruption as well, and its pinned TUI can reset
the interrupter: neither an end callback nor a post-launch flag alone is an outcome
classifier. Track the explicit application outcome and interruption/error reason.

Maintain separate facts for BLE connectivity, age of the latest trainer observation,
and explicit run outcome. A bridge heartbeat does not prove training is progressing.
A long batch can produce old progress without implying failure. Sudden process
loss without a known outcome displays unavailable/unknown, never complete.

Validate real Bluetooth coverage early. The portable display cannot receive new
information while out of range; it shows last-update age and disconnected status.
On reconnection it receives any retained completion/error result. The laptop must
remain running and awake to train and communicate.

## 9. Dependency and hardware decisions

Versions locked after successful host and ARM builds:

- Burn adapter: first compatibility target `=0.22.0-pre.4`, matching this repository's
  training project. Do not silently promise compatibility with every Burn release.
- Desktop: Iced 0.14 with Tokio integration, `btleplug` 0.13.5, Tokio 1.x, and stream/UUID
  support as directly required. Avoid a parallel Ratatui dashboard.
- Firmware: `trouble-host` 0.8.0, `nrf-sdc` 0.4.0, `nrf-mpsl` 0.4.0 and matching
  Embassy versions. These published dependency requirements align with Embassy
  nRF 0.11, sync 0.8 and time 0.5.1. The ARM image was built, flashed and exercised
  with the actual board.
- Reuse `kitronik-view` with its async feature, SSD1306, `embedded-graphics`, existing
  RTT logging and the pure button-debouncing code where compatible.
- If CLI arguments are added, use `clap` with `derive` and `wrap_help`.

Select MPSL's critical-section implementation for this firmware and keep the root
workspace's single-core implementation out of its link. Avoid the existing button
wrapper's global interrupt masking. Reserve SDC/MPSL radio, timer, RTC and PPI
resources; retain Embassy time on RTC1. Follow board-compatible clock calibration.
Use static bounded storage and verify flash/RAM consumption.

macOS is the initial target for desktop validation. Handle Bluetooth permission and provide
appropriate usage-description metadata for a packaged app. Record Nordic binary
library licence requirements; the stack is not entirely Rust/open-source code.

## 10. Milestones and completion evidence

M1 gates dataset/model decisions. Independent library/protocol and firmware work
may proceed concurrently; integrate and verify dependent milestones in order.

- [x] M0: create this spec and dataset research; record Iced selection.
- [x] M1: audit recommended raw data; record exact schema, usable counts, provenance,
  graph transformation, splits and baselines before model implementation.
- [x] M2: create the isolated three-crate workspace; verify host/Burn features and
  ARM protocol-only build; add focused malformed-packet/round-trip tests.
- [x] M3: establish real BLE connection, board display and two-way action/result flow;
  test reconnect and duplicate events using clearly labelled telemetry fixtures.
- [x] M4: train a tiny genuine two-layer GNN in Burn; display live progress and saved
  outcomes through Iced and the :VIEW, without UI stalls or BLE-dependent training.
  Check two-hop propagation on a known small graph and verify trainable gradients.
- [x] M5: train/evaluate the selected educational task and baselines; save reproducible
  artifacts and show final held-out results on desktop and board.
- [ ] M6: verify board absent, mid-run disconnect, completion while disconnected,
  reconnect, repeated packets, local acknowledgement, snooze, bookmark, interrupted
  training, invalid data, and artifact-save failure. Document setup and operation.

M3's real connection, display, two-way actions and automatic reconnection after a
board reset are verified. M6 is partially verified: board-absent training, duplicate
packet/action handling, local acknowledgement, snooze state, bookmarks, invalid data
and artifact-save failure have evidence. A GUI run also completed while explicitly
disconnected, and an interrupted release-executable run replaced an older success
with a new active-run marker. Restart regression coverage verifies an unknown
outcome for that marker. See [VALIDATION.md](VALIDATION.md) for the distinction
between software tests and physical observations. A deliberate link loss during
active training, physical snooze/offline-acknowledgement checks and physical pager
behaviour following trainer process loss remain untested. Battery/range measurements
are also still pending.

Completion requires code checks/tests for the relevant packages and both targets,
plus an actual micro:bit/:VIEW run. Simulations must be labelled and cannot stand in
for hardware evidence. Record commands, outcomes, limitations and hardware used as
milestones complete. No claim that the model beats baselines is required.

## 11. Research references

- [Dataset investigation and primary sources](DATASETS.md).
- [Burn training hooks](https://burn.dev/docs/burn/train/struct.SupervisedTraining.html).
- [TrouBLE release](https://docs.rs/crate/trouble-host/0.8.0).
- [Nordic controller and setup](https://docs.rs/nrf-sdc/0.4.0/nrf_sdc/).
- [MPSL](https://docs.rs/crate/nrf-mpsl/0.4.0).
- [btleplug platform guidance](https://github.com/deviceplug/btleplug).
- [Iced Tokio integration](https://book.iced.rs/faq.html).
- [Kitronik :VIEW Graphics128](https://kitronik.co.uk/products/56115-kitronik-view-graphics128-oled-display-128x64-for-bbc-micro-bit).
- [Bluetooth range factors](https://www.bluetooth.com/learn-about-bluetooth/key-attributes/range/).

## 12. Decision record

2026-11-03: user specified three parts and selected Iced. The dataset recommendation
is Czech classroom networks v3, subject to raw-schema verification; the distinction
from exam marks/study partnerships is explicit. The spec adds no cloud service or
separate relay process. Current repository files outside this new project were
left unchanged. No firmware, model, app, or library implementation exists yet.

2026-11-03, implementation start: independent protocol/hardware foundations may run
alongside M1 to avoid blocking unrelated work. Model/data decisions still require
the audit. A read-only probe inventory currently finds no connected micro:bit;
hardware validation remains pending.

2026-11-03, M1: raw v3 fields and matrix IDs verified. Complete-case processing
retains 250 students, 1,173 observed undirected friendship edges and twelve graphs.
Use baseline grade only; missing literacy is not imputed. The reproducible prepared
dataset and source attribution are included, with raw downloads ignored.

2026-11-03, implementation and hardware validation: the isolated three-crate
workspace is implemented. The library's no-default-feature protocol builds for ARM;
the desktop/Burn and firmware feature boundaries are checked. Thirty-seven tests
pass across the three crates. The tested firmware was flashed to a micro:bit V2
fitted with the Kitronik :VIEW Graphics128. A real 200-epoch Burn GCN run completed
through the Iced app and sent progress/results to the board. The user confirmed
the screen, completion sound and acknowledgement; host records also confirm a
board-initiated bookmark and alert-policy change. The GCN's held-out MAE is 0.495,
compared with 0.159 for the prior-grade baseline, so no graph improvement is
claimed. Reproducible model/results artifacts and setup documentation are present.
Extended failure/range validation is distinguished from these completed checks in
[VALIDATION.md](VALIDATION.md).

2026-11-03, reliability checks: the host now discards stale peripheral handles and
performs bounded rediscovery of the explicitly selected platform ID. A new active
run writes one persistence marker so process loss cannot restore an older run's
success. Release-executable interruption and restart regression checks verify this
behaviour. A 200-epoch GUI run also completed with the board explicitly disconnected.
Firmware now derives its static BLE address from factory identity, preserving
identity across board resets. The final image was flashed successfully. Actual
board-reset testing verified automatic reconnection in about six seconds without
another scan or device selection, retaining the offline result and alert policy.
The user confirmed the replayed `COMPLETE` 200/200 result on the :VIEW and
acknowledged it; the host recorded that acknowledgement for the retained event.

2026-11-03, variable model depth: at the user's request, the hidden-layer vector
drives the forward pass. Each additional layer performs one aggregation and
linear/ReLU step; zero additional layers remains a valid one-hop model. The
default experiment keeps its two-hop architecture, with callers, display labels,
saved configuration and reload checks following the selected layer count.
