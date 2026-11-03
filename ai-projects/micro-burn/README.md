# micro-burn

A Burn training dashboard with a portable micro:bit V2 + Kitronik :VIEW companion.
The Iced application defaults to a two-layer graph neural network on real classroom
friendship data. The board shows progress and results, sounds alerts, and sends
acknowledgements, alert settings and bookmarks back to the laptop.

The implementation contract is [SPEC.md](SPEC.md). Dataset evidence and exact
preprocessing are in [DATASETS.md](DATASETS.md) and [DATA_AUDIT.md](DATA_AUDIT.md).

## Three parts

| Package | Responsibility |
| --- | --- |
| `lib/` — `micro-burn` | Reusable Burn adapter, reporting, Bluetooth connection and shared protocol |
| `firmware/` — `micro-burn-firmware` | Async BLE peripheral, OLED pages, buttons and audible alerts |
| `app/` — `micro-burn-app` | Iced desktop UI, GNN/baselines, evaluation and saved results |

The library contains the allocation-free wire protocol behind a feature boundary.
The firmware uses it without Burn, Tokio or desktop dependencies. Host applications
enable the `burn` feature. This is a separate Cargo workspace so its desktop and
controller features do not change existing projects.

## Run the desktop app

From this directory:

```sh
just                  # List recipes
just build            # Build the app and firmware with release optimisation
just run              # Run the desktop app in release mode
just embed            # Flash and run firmware on the connected micro:bit
just run --headless --epochs 200 --seed 42
```

`just build-app` and `just build-firmware` build either part separately. Firmware
uses the existing `firmware` profile, which inherits release optimisation and
retains debugging information, and writes to `target-firmware/`. `just embed` uses
the configured probe-rs runner and shows RTT output; it replaces the board's
current firmware.

The equivalent desktop Cargo command is:

```sh
cargo run -p micro-burn-app --release
```

The prepared, attributed dataset is included. No account, Python environment or
dataset download is required to train. Set epochs, learning rate and model seed in
the window and choose **Train & evaluate**. Training works with no board connected.
Use **Find micro:bit** and select the discovered board after flashing the firmware.
The Bluetooth scan starts only when requested.

For a reproducible run without a window or Bluetooth scan:

```sh
cargo run -p micro-burn-app --release -- --headless --epochs 200 --seed 42
```

Each run gets a new directory under `artifacts/`. It contains the selected GNN and
MLP weights, effective configuration, data provenance, history, predictions and final
metrics. The classroom split remains fixed when changing the model seed. Use
`--help` for input/output paths and other supported arguments.

On macOS, permit Bluetooth access for the terminal/application that launches the
program. A local app bundle can be built with `app/package-macos.sh`; its metadata
includes the Bluetooth usage description. The first build needs network access to
fetch Rust dependencies. The library's first Burn compatibility target is exactly
`0.22.0-pre.4`.

## Prepare the hardware

Fit a micro:bit V2 into a Kitronik :VIEW Graphics128. The display uses the external
I²C pins and is powered through the micro:bit. Use a USB data cable for flashing
and a battery pack when carrying the device. See [firmware setup](firmware/README.md)
for the display address, pin allocation, flash command and controls.

```sh
cargo build -p micro-burn-firmware --target thumbv7em-none-eabihf --profile firmware
cargo run -p micro-burn-firmware --target thumbv7em-none-eabihf --profile firmware
```

The run command uses the repository's probe-rs runner. It overwrites the program
currently on the board. Stop other programs using its debug probe first.

## The learning task

Each student is a node. An observed baseline friendship is an edge. The input is
the student's earlier Czech-language grade; the target is the later subject grade.
These are teacher-assigned grades on the 1-best to 5-worst scale, not exam marks or
verified study partnerships.

The raw-data audit keeps 250 complete-case students in twelve classroom graphs.
The fixed training/validation/test split has 166/40/44 students. Relationships and
features are from the earlier wave only. Twenty-six missing-response records are
excluded rather than turned into invented negative friendships.

By default, the GNN computes two rounds of neighbour aggregation:

```text
earlier grades → aggregate neighbours → linear + ReLU
               → aggregate neighbours → linear + ReLU → predicted later grade
```

Adjacency includes self-loops and symmetric degree normalization. Two rounds let a
student's prediction use information two friendship hops away. Each hidden layer
has width 16. A matching MLP uses the same student feature without graph edges.

The model accepts any number of additional hidden layers after its input layer.
Change `HIDDEN_LAYERS` in `app/src/training.rs` to set the experiment's depth:
`0` gives one message-passing step, `1` gives two (the default), and `2` gives three.
Every hidden layer aggregates neighbours, applies its linear transform and ReLU;
the scalar output head adds no graph hop. The MLP uses the same layers without
aggregation. Saved configuration records both the extra-layer count and total
message-passing depth. Load new checkpoints with the matching width and layer count;
checkpoints from the original fixed `first`/`second` layout need conversion or
retraining.

Models are selected using validation loss. Final held-out MAE and RMSE are compared
against the prior-grade and training-mean predictors. A smaller error is better.
The experiment can legitimately find that the GNN adds no benefit. It does not
establish a causal effect of friends or justify individual grading decisions.

## How training reaches the board

Burn work runs on a dedicated CPU thread. Lightweight reports enter the library's
shared state without waiting for Bluetooth. A Tokio worker owns the laptop's BLE
central connection. Firmware advertises as the peripheral/GATT server.

The laptop writes versioned 20-byte fragments. Firmware assembles a complete
snapshot before displaying it. Ordinary progress is coalesced to about one update
per second; terminal outcomes are retained and retried on reconnection. The board
notifies the host of receipt and user actions. Receipt and human acknowledgement
are distinct.

Firmware services Bluetooth, the screen, buttons and sounds concurrently. A lost
connection shows stale/disconnected status. It never turns a stopped counter or
expired ETA into a success alert. Bluetooth coverage depends on the environment;
test the rooms where you plan to carry it. Results produced out of range arrive
after reconnection.

The desktop reports success after evaluation and required artifact saves complete.
An error, interruption, unavailable trainer and disconnected board have separate
meanings. The current session and delivery state are retained locally; firmware
power-loss persistence is not guaranteed.

## Verify and reproduce

Build targets separately:

```sh
cargo test -p micro-burn --features burn
cargo check -p micro-burn --no-default-features --target thumbv7em-none-eabihf
cargo test -p micro-burn-firmware --lib
cargo test -p micro-burn-app
cargo build -p micro-burn-firmware --target thumbv7em-none-eabihf --profile firmware
```

To regenerate the included prepared data from the publisher's original workbooks:

```sh
uv run data/prepare.py --download
```

The preparation checks source SHA-256 hashes and schema and preserves attribution.
See [data/README.md](data/README.md). Raw downloads and run artifacts are ignored.
Actual build/test and hardware evidence is recorded in [VALIDATION.md](VALIDATION.md).
