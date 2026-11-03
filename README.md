# microbit projects

This repo contains projects that I decided to play with to help learn about
microcontrollers.

## Projects

Below is a list of current projects.

| Project            | Runs on   | Description |
| ------------------ | --------- | ----------- |
| [micro-autoenc]     | Computer  | Use an autoencoder to remove noise from audio |
| [micro-burn]        | Both      | Train a graph neural network and follow progress on a Bluetooth OLED pager |
| [micro-arcade]      | micro:bit | Learn micro:bit programming with a small arcade game |
| [micro-log]         | micro:bit | Save accelerometer and magnetometer data across power-offs |
| [micro-maze]        | micro:bit | Render a maze on a microcontroller display |
| [micro-radio]       | micro:bit | Send and receive text between two micro:bit V2 boards |
| [micro-tictactoe]   | micro:bit | Learn to build wireless tic-tac-toe between two boards |
| [micro-view]        | micro:bit | Plot live accelerometer data on a Kitronik VIEW OLED |
| [micro-view-audio]  | micro:bit | Plot microphone waveforms, FFT spectra and a spectrogram |
| [tutorial]          | micro:bit | Work through micro:bit examples and peripheral experiments |

[micro-autoenc]: ./projects/micro-autoenc/
[micro-burn]: ./projects/micro-burn/
[micro-arcade]: ./projects/micro-arcade/
[micro-log]: ./projects/micro-log/
[micro-maze]: ./projects/micro-maze/
[micro-radio]: ./projects/micro-radio/
[micro-tictactoe]: ./projects/micro-tictactoe/
[micro-view]: ./projects/micro-view/
[micro-view-audio]: ./projects/micro-view-audio/
[tutorial]: ./projects/tutorial/

## Workspace layout

The root Cargo workspace contains the firmware projects and shared crates in
`crates/`. Shared dependency versions and firmware profiles live in the root
`Cargo.toml`, and the root `Cargo.lock` records their resolved versions.

`projects/micro-autoenc` is a separate Cargo workspace with its own manifest,
dependency settings, profiles, and lockfile. Its training stack needs desktop
features such as `std`; keeping its dependency graph separate prevents those
features from being unified into firmware builds. Run host commands with its
manifest path or from that project directory.

## Building and Flashing

The Rust toolchain includes the micro:bit target and LLVM tools. Install
[`probe-rs`](https://probe.rs/docs/getting-started/installation/) for flashing and
running firmware on a connected board. From the repository root:

```sh
# Check every firmware project and shared crate:
cargo check-firmware

# Build the independent desktop project:
cargo build-host

# Build or flash one firmware project (development profile by default):
cargo build-arcade
cargo flash-arcade
cargo build-tutorial
cargo flash-tutorial
```

Build firmware one project at a time. A full workspace build combines the
blocking and async input features, pulling in two nRF interrupt tables and
failing at the linker. The per-project build aliases keep those runtime choices
separate; the workspace-wide check remains available.

Every firmware project has matching `build-<name>` and `flash-<name>` aliases:
`arcade`, `log`, `maze`, `radio`, `tictactoe`, `tutorial`, `view`, and `view-audio`.
The build aliases select `thumbv7em-none-eabihf` explicitly. Flash aliases run
`cargo embed` in the project directory, where its `Embed.toml` and local Cargo
configuration are available.

The root `.cargo/config.toml` shares the ARM runner and linker settings without
setting a default build target. Each firmware project's `.cargo/config.toml`
selects ARM when working inside that directory. Cargo reads configuration from
the current directory and its parents; `-p` and `--manifest-path` do not load a
project's local configuration. Use the root aliases or change into the project:

```sh
cd projects/tutorial
cargo build
cargo embed
```

Use the default development profile for debugging and the tutorial's debugging
steps. The `firmware` profile enables release optimizations while retaining debug
information; the `release` profile strips debug information. Build and flash the
same profile when comparing behaviour:

```sh
# From the workspace root:
cargo build-arcade --profile firmware
cargo flash-arcade -- --profile firmware

# From projects/micro-arcade:
cargo embed -- --profile firmware
```

For desktop work from the repository root, use `cargo check-host`,
`cargo test-host`, or `cargo run-host --release -- [arguments...]`; use
`cargo build-host --release` to build without running. See the
[micro-autoenc README](projects/micro-autoenc/README.md) for training commands.
Its commands and features are independent of the firmware workspace.

## Repository recipes

[`just`](https://just.systems/) provides optional repository commands:

```sh
just                              # List recipes; no .env file required.
just new-async micro-example      # Create and register an Embassy firmware project.
just tree                         # Inspect duplicate firmware dependency versions.
just tree projects/micro-autoenc/Cargo.toml
just run micro-autoenc --help      # Build and run in release mode, with notifications.
```

`just run <project> [arguments...]` changes into firmware project directories to
load their Cargo configuration and use the configured `probe-rs` runner. Desktop
runs select the independent manifest while retaining the repository root as the
working directory, so configuration and output paths remain relative to the root.
The recipe requires `PUSHOVER_TOKEN` and `PUSHOVER_USER` in the environment or an
optional root `.env` file; it sends build and run notifications through Pushover.
Other recipes do not require these credentials.

`just new-async <name>` creates `projects/<name>` with async micro:bit V2 startup,
Embassy dependencies, RTT logging, memory layout, and build/flash configuration.
It adds the project to the workspace and refuses to overwrite an existing path.
Build or run the result from its directory with `cargo build` or `cargo run`.

## AI Usage

I try to avoid using AI as much as possible, unless I am significantly confident that all
it is doing is filling out boilerplate that I am entirely capable and familiar with doing,
or in the event that I have absolutely no clue how to solve a problem.

My otherwise main usage is to run AI over my completed work and have it refactor what I
have into a cleaner structure. I try to do this as little as possible, but it is nice when
it does a good job and picks out additional bugs along the way. Also, I can have it add
stub functions in place of real ones, which prevents it from finishing any remaining work
I might have.

One exception, where I don't necessarily care as much about AI usage, is that I am
content with allowing AI to write tests and documentation. Honestly, I probably wouldn't
do it for hobby projects, otherwise.
