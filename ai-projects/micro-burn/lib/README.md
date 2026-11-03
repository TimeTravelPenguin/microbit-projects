# micro-burn library

Use this crate to report an existing Burn training run to a micro:bit training
pager. It owns Bluetooth discovery, connection, reconnect, snapshot delivery and
device actions. It does not own a model, compute backend, dataset or desktop UI.

## Features

| Features | Use |
| --- | --- |
| None, the default | Allocation-free `no_std` protocol for firmware |
| `host` | Reporter and async Bluetooth monitor on a desktop |
| `burn` | Host support plus the Burn `0.22.0-pre.4` renderer/progress adapter |

The Burn adapter's version is deliberately pinned. It is not a claim of API
compatibility with other Burn releases. Firmware must use `default-features = false`.

## Add reporting to a Burn project

Add the library with `features = ["burn"]`. Create a monitor outside training,
then pass its cloneable reporter to the training worker. Keep the monitor alive
until the run's result has been handled.

```rust,ignore
use micro_burn::{
    burn::BurnReporter,
    host::Monitor,
    protocol::Phase,
};

let mut monitor = Monitor::new("my experiment", Some("artifacts/pager.json".into()))?;
let reporter = monitor.reporter.clone();
reporter.begin_run("my experiment");

// Attach this to your existing SupervisedTraining before launch.
let training = training.renderer(Box::new(BurnReporter::new(reporter.clone())));
let result = training.launch(learner);

// Your application determines whether the run succeeded or was interrupted.
// Burn's end callback alone cannot establish success.
let mut snapshot = reporter.snapshot();
snapshot.phase = Phase::Saving;
reporter.publish(snapshot)?;

save_model_and_evaluation_results(result)?;

let mut snapshot = reporter.snapshot();
snapshot.phase = Phase::Succeeded;
snapshot.mae = Some(final_test_mae);
snapshot.rmse = Some(final_test_rmse);
reporter.publish(snapshot)?;

// At application exit, flush retained results and join the worker.
monitor.shutdown()?;
```

The named `training`, `learner`, saving function and final metrics above belong to
the consuming project. The example app in `../app` supplies a complete GNN run.
For a custom Burn loop, call `Reporter::publish` directly with the same fields.
Always use the returned snapshot if you retain its sequence for UI or bookmarks.

To preserve Burn's terminal renderer in another project, wrap it:

```rust,ignore
let renderer = burn::train::renderer::default_renderer(training.interrupter(), None);
let renderer = BurnReporter::with_renderer(reporter.clone(), renderer);
let training = training.renderer(Box::new(renderer));
```

`BurnReporter` forwards all renderer and progress callbacks and copies numeric loss
and learning rate into reports. It never publishes terminal success implicitly.
Its ordinary end callback can also follow cancellation. The application explicitly
publishes `Succeeded`, `Interrupted`, or `Failed`, after its own outcome checks.

## Desktop event loop

Bluetooth is accessed only after `monitor.scan()` or `monitor.connect(id)`.
`HostEvent::DeviceFound` provides the opaque platform ID for explicit selection.
Call `connect` with that ID; macOS does not expose a Bluetooth MAC address here.

Poll `monitor.try_recv()` from a desktop event timer, or forward its events through
your UI integration. Events include connection changes, errors, recovered results,
acknowledgements and exact-snapshot bookmarks. The Iced app is an example consumer.
No Iced dependency is part of the library.

`Reporter::publish` performs only bounded in-memory work. Latest progress coalesces,
while the terminal result is retained separately. It does not await Bluetooth or
write artifacts. The monitor's worker sends ordinary updates once per second and
terminal outcomes immediately, and automatically retries a selected pager.
Reconnect attempts wait three seconds after the previous attempt finishes; bounded
discovery and connection work add to that interval. The worker discards a stale
peripheral handle and rediscovers the selected opaque platform ID before retrying.
It does not silently choose a different board. Bluetooth operations have finite
timeouts. Scan and connection errors do not stop training. Command and UI event
channels have fixed capacities.

With `state_path` configured, terminal results and acknowledgement state are saved
there atomically. Once the monitor observes a new active run, it writes one marker
to replace any older terminal result. If that run ends without reporting an outcome,
restart recovery leaves the reporter idle and emits an explicit “status unknown”
event; it cannot restore the older success as the new run's result. The marker is
not a continuous progress log. Bookmarks are saved next to the state file as
`*.bookmarks.jsonl`, including the displayed snapshot and action identifiers.
Restoration must not overwrite a newly started run. `Monitor::shutdown` and `Drop`
flush retained state and join the worker; they belong at application shutdown,
not inside a training callback.

## Protocol

Firmware advertises the library's custom service and exposes telemetry writes,
control writes, device-event notifications, and readable device status. The host
subscribes and reads status before replaying current state. One logical snapshot is
eight 20-byte frames, versioned and tagged with a run ID, sequence and fragment
index. Partial or old assemblies are not displayed. Optional values retain the
difference between unavailable and zero.

Delivery receipt and human acknowledgement are different device events. Retrying a
terminal result must not sound an already acknowledged alarm. The board identifies
the exact displayed sequence in a bookmark; the worker keeps transmitted history
independently of fast training updates. Source age travels in each snapshot so a
live Bluetooth heartbeat does not imply fresh trainer observations.

The current service is unpaired and unencrypted and carries aggregate metrics.
Treat Bluetooth coverage and macOS permission as setup requirements. A disconnected
pager cannot know that training finished until reconnecting.

From `projects/micro-burn`, validate the library separately:

```sh
cargo test -p micro-burn --features burn
cargo check -p micro-burn --no-default-features --target thumbv7em-none-eabihf
cargo run -p micro-burn --example discover --features host
```

