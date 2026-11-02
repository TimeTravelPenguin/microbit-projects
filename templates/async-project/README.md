# __PROJECT_NAME__

Async firmware for the micro:bit V2, using Embassy on the nRF52833. The starter
initializes the external high-frequency crystal and prints an RTT message every
second while the executor waits on Embassy's RTC1 time driver.

From this directory:

```sh
cargo build
cargo run
```

`cargo run` flashes and runs the firmware using `probe-rs`. Alternatively, use
`cargo embed` with the included `Embed.toml`. A connected micro:bit V2 and
`probe-rs` are required for either command.

From the workspace root, build with:

```sh
cargo build -p __PROJECT_NAME__ --target thumbv7em-none-eabihf
```

The package inherits dependency versions and profiles from the workspace. Add
application tasks with `#[embassy_executor::task]` and spawn them using the main
function's `Spawner`.
