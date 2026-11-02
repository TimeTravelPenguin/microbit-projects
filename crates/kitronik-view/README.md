# kitronik-view

Shared OLED setup for the Kitronik :VIEW. The crate initializes its SSD1306 at
I²C address `0x3C`, clears and flushes the framebuffer, and turns the display on.
It returns the buffered SSD1306 driver directly for `embedded-graphics` drawing.
Initialization failures return `DisplayError` to the application.

Like `cardkb`, the crate provides `blocking` and `r#async` modules. `blocking` is
enabled by default. Select `default-features = false, features = ["async"]` for
an async application. Both features may be enabled together; use explicit module
paths when both are enabled. With exactly one feature, `Oled` and `init_display`
are also available at the crate root.

```rust,ignore
// Blocking: provide an embedded_hal::i2c::I2c bus.
let mut display = kitronik_view::blocking::init_display(bus, kitronik_view::DISPLAY_SIZE)?;
display.flush()?;

// Async: provide an embedded_hal_async::i2c::I2c bus.
let mut display = kitronik_view::r#async::init_display(bus, kitronik_view::DISPLAY_SIZE).await?;
display.flush().await?;
```

Applications configure the I²C peripheral, pins, clock rate, and interrupt
bindings. On the micro:bit V2 edge connector, :VIEW SDA is P20 (P1.00) and SCL is
P19 (P0.26); tic-tac-toe configures this bus at 400 kHz. `DISPLAY_SIZE` is
128×64, and `size` reexports the SSD1306 size types and traits for generic code.
The display starts with no rotation; use the returned driver's methods to
change it if needed.

## Examples

The standalone micro:bit V2 examples draw text and update a counter once per
second. Connect the :VIEW to 3V, GND, edge P20 (SDA), and edge P19 (SCL), with
the display address set to `0x3C`.

From the workspace root, build either example:

```sh
cargo build -p kitronik-view --example display_blocking --target thumbv7em-none-eabihf
cargo build -p kitronik-view --example display_async --no-default-features --features async --target thumbv7em-none-eabihf
```

Replace `build` with `run` to flash and run on a connected board using `probe-rs`.
From `crates/kitronik-view`, the target is selected automatically:

```sh
cargo run --example display_blocking
cargo run --example display_async --no-default-features --features async
```

[display_blocking](examples/display_blocking.rs) uses the blocking nRF HAL;
[display_async](examples/display_async.rs) uses Embassy and an I²C interrupt
binding. Both configure I²C at 400 kHz. The examples share Embassy's interrupt
table, with the blocking HAL's runtime feature disabled. Their memory map is
supplied only to the example executables.

Run the initialization and bus-failure checks from the workspace root with:

```sh
cargo test -p kitronik-view --lib
cargo test -p kitronik-view --no-default-features --features async --lib
cargo test -p kitronik-view --all-features --lib
```
