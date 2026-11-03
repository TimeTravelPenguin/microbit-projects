# Validation evidence

Observed results from 2026-11-03 on macOS with a micro:bit V2 and Kitronik :VIEW
Graphics128. See [SPEC.md](SPEC.md) for the acceptance criteria. Software state
tests and physical hardware observations are recorded separately below.

## Software checks

The isolated workspace builds with Rust 1.101.0-nightly (2026-10-22). Public
dependencies are pinned in `Cargo.lock`; the desktop uses Burn `0.22.0-pre.4`,
Iced 0.14 and `btleplug` 0.13.5. Firmware uses TrouBLE 0.8, SDC/MPSL 0.4 and the
matching Embassy versions.

These commands passed from the project directory; `--offline` was used after
dependencies had been fetched:

```sh
cargo test -p micro-burn --features burn --offline
cargo check -p micro-burn --no-default-features --target thumbv7em-none-eabihf --offline
cargo test -p micro-burn-firmware --lib --offline
cargo test -p micro-burn-app --offline
cargo build -p micro-burn-firmware --target thumbv7em-none-eabihf --profile firmware --offline
cargo build -p micro-burn-app --release --offline
```

There are 37 passing tests: 22 library, six firmware and nine app tests. They cover:

- Protocol round trips, out-of-order fragments, assembly expiry, stale/duplicate
  sequences, malformed frames and non-finite metrics.
- Reporting without a Bluetooth runtime, explicit outcomes, retained-result
  recovery, receipt versus human acknowledgement, exact-snapshot bookmarks and
  deduplication across retries/restarts. A new active-run marker replaces an older
  success; recovery reports an unknown outcome if the new run never finishes.
- Pager state for disconnected/freshness display, local acknowledgement surviving
  repeated terminal packets, snooze expiry and pending-action priority.
- Dataset split/edge preservation, training-only scaling, rejected duplicate
  students and future networks, two-hop propagation and gradients through the
  trainable graph layers.
- Real training, saved-model reload matching exported predictions, artifact-save
  failure reporting `Failed`, lost UI workers and restoration of complete chart
  history after live updates are coalesced.

The final chart-axis change was followed by another successful nine-test app run.
The final library changes passed all 22 library tests, and the ARM protocol-only
check was repeated. Workspace formatting and `git diff --check` also passed. The
final desktop release executable and macOS bundle were rebuilt successfully.

The ARM protocol-only build succeeds. A dependency-feature inspection confirmed
that the firmware excludes Burn, Iced, Tokio and desktop Bluetooth backends. The
final firmware builds without warnings and uses 221,564 bytes of flash and 21,840
bytes of static RAM, excluding stack use. This image was successfully flashed and
used for the automatic-reconnection test below.

The native Iced release build was exercised in the local macOS app bundle,
including configuration, training, loss curves, device discovery/selection, final
comparison results and human-readable board actions. The release build is the
recommended interactive launch configuration.

## Dataset and training results

The raw dataset audit passed. Exact schemas, source SHA-256 hashes, exclusions,
attribution and fixed classroom splits are recorded in [DATA_AUDIT.md](DATA_AUDIT.md).
The prepared dataset contains 250 students and 1,173 undirected observed friendship
edges. It uses 166/40/44 students for training/validation/test.

A real 200-epoch run with model seed 42 and learning rate 0.01 completed in the
Iced app. Each model was selected by its own minimum validation MSE before test
evaluation. The selected GCN epoch was 200. Results from
`artifacts/run-1793685505454/metrics.json` are:

| Predictor | Held-out MAE | Held-out RMSE |
| --- | ---: | ---: |
| GCN, two message-passing layers | 0.494778 | 0.552617 |
| Feature-only MLP | 0.284723 | 0.371850 |
| Prior grade | 0.159091 | 0.398862 |
| Training-target mean | 0.595838 | 0.665500 |

These errors are in grade units on the 1-best to 5-worst ordinal scale. The GCN
does not beat the prior-grade baseline in this experiment. Friendship nominations
are not verified study partnerships, and these are teacher-assigned subject grades,
not exam marks.

The run saved `gnn.bpk`, `mlp.bpk`, `config.json`, `data-provenance.json`,
`history.json`, `metrics.json` and `predictions.json` before publishing success.
Independent headless training also completed without a connected Bluetooth monitor.

An end-to-end invalid-input run used the release executable with a deliberately
missing dataset path, one epoch and an isolated artifact directory. It exited with
status 1, reported `Preparing` then `Failed`, and saved a retained `Failed` snapshot
at epoch 0 of 1. It did not scan for Bluetooth or report completion.

The final release executable was also checked for process interruption. An isolated
10,000-epoch run first finished successfully as run 277699409. A second
10,000-epoch run, 3408531633, received SIGINT after approximately one second and
exited with status 1 while validating epoch 7,344. Its retained state contained the
new run's nonterminal `Preparing` marker with event ID 0, replacing the previous
success. The corresponding restart regression test confirms that this marker
produces an explicit unknown outcome rather than recovering the old `Complete`
result. This is a process/persistence check, not a physical pager process-loss test.

A further 200-epoch run completed in the Iced app while its board connection was
explicitly disconnected. The retained snapshot for run 1805419457 was `Succeeded`
at sequence/event ID 1818. The complete loss curve and its corrected epoch axis
from 1 through 200 were visually checked. This result remained retained through
the later connection and board-reset test.

## Actual hardware observations

Firmware was flashed to the connected micro:bit V2 through its USB debug probe.
It advertised its custom BLE service, and the desktop app discovered and connected
to it. The real training run above used that connection.

The user physically confirmed that the :VIEW showed training progress and the
`COMPLETE` result, that the completion sound worked, and that the board's
acknowledgement menu worked. The desktop received the acknowledgement and retained
the terminal snapshot with `acknowledged: true`.

The user then used the board menu to bookmark the displayed result and change the
alert policy. The host recorded exactly one bookmark in
`artifacts/pager-state.bookmarks.jsonl`: action ID 2, run ID 3210945801, displayed
sequence 1212, epoch 200 and the matching held-out result. The next retained
snapshot, sequence 1213, had `ErrorsOnly` policy and remained acknowledged. This
verifies meaningful communication in both directions, including durable recording
of the particular result displayed on the board.

The final firmware preserves the board's BLE identity across resets using its
factory identity. The host discards stale macOS peripheral handles and performs
bounded rediscovery of the selected identity. Together these changes allow the
selected board to reconnect automatically after a reset.

With the final image flashed, the app discovered one `micro-burn` device and
connected after explicit selection. The board was then reset through its debug
probe while the app remained running. About six seconds later, the desktop showed
`Connected to your micro:bit` again, with `Connecting` then `Connected` in its log
and the same single device entry. No further scan or device selection was made.
The `ErrorsOnly` policy and retained offline result, run 1805419457 at
sequence/event ID 1818, remained intact. The user then physically confirmed that
the :VIEW showed `COMPLETE` at 200/200 and acknowledged it with the board menu.
The host retained sequence 1819 with the same event ID 1818,
`acknowledged: true` and `ErrorsOnly` policy; the bookmark journal still contained
exactly one record. This verifies that a result produced while disconnected was
displayed after reconnection and that its acknowledgement returned to the host.
The final app was left connected with the board running independently of the
debugger.

The synthetic OLED layout previews are useful for checking screen fit, but are not
hardware evidence. Physical observations above came from the real device and real
training data.

## Remaining validation limits

The completed hardware checks use USB power near the laptop. Battery operation,
walking between rooms, maximum range and sustained operation have not been
measured. Other desktop operating systems have not been exercised.

Snooze expiry, offline acknowledgement, duplicate terminal suppression and malformed
packets have software-test evidence; they have not all been repeated manually on
the board. A link loss during active training has not been deliberately exercised;
the actual disconnect checks cover completion while explicitly disconnected and
automatic reconnection after a board reset. Process interruption has the scoped
release-executable/persistence evidence above; physical pager behaviour following
trainer process loss has not been manually tested.

Firmware retains session state in RAM. Host terminal state and bookmarks survive
host restart; firmware power-loss persistence is outside version-one scope. The
local BLE demonstration is unpaired and unencrypted and sends aggregate metrics,
not student-level records.
