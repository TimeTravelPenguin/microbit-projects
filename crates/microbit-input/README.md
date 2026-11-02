# microbit-input

Shared A/B button sampling for micro:bit V2 projects, with `blocking` and `async`
implementations. Both sample every 2 ms and retain presses while foreground
I²C or signal processing runs.
Four equal readings give 6–8 ms debounce; each hold produces one press. Pending
counts saturate at 255 and both buttons are independent.

The default `blocking` feature provides `blocking::initialise` with TIMER2 and
the floating-input A/B pins. Drain `blocking::take_presses()` in the main loop.
Call `blocking::stop()` during power-off cleanup. The application supplies its
nRF52833 interrupt-vector runtime; the crate supplies the TIMER2 handler. The
existing `hardware` feature enables `blocking` and its `input` module alias for
compatibility. Only state transfer masks interrupts; I²C, FFTs and rendering run
outside critical sections.

For Embassy, disable default features and enable `async`:

```toml
microbit-input = { workspace = true, features = ["async"] }
```

The workspace dependency already disables default features. For a standalone
path dependency, also set `default-features = false`. The async sampler accepts
two `embedded_hal::digital::InputPin` implementations that read low when pressed
and have the same error type. It returns an error if either read fails. Drain
`r#async::take_presses()` from the application loop. Applications configure the
pins, initialize Embassy's time driver, and own their executor. For an Embassy
application, provide a small task wrapper and spawn it once:

```rust
use embassy_nrf::gpio::Input;

#[embassy_executor::task]
async fn sample_buttons(button_a: Input<'static>, button_b: Input<'static>) {
    microbit_input::r#async::sample(button_a, button_b)
        .await
        .expect("Button sampling failed");
}
```

This is the sampler used by `micro-tictactoe`; it reuses the same `Buttons`
state machine as the blocking implementation. Both features may be enabled
together, with independent press queues. The library does not select a concrete
HAL or executor for async sampling. Build blocking and Embassy applications
separately to keep their interrupt-vector runtime features isolated.

For the capacitive logo, use `blocking::initialise_with_logo` with P1.04 configured
as open-drain input/output at output-low, GPIOTE, and PPI channel 2. Logo charge
time is captured by PPI into TIMER2 CC2; sensing never waits inside an interrupt.
It measures every 4 ms, calibrates ten readings, then debounces in 12–16 ms.
Drain touches with `blocking::take_logo_presses()`. Holds produce one event;
stable release rearms detection. Shutdown also disables logo capture and
disconnects the pin. The existing A/B-only initializer remains available.

The state machine is usable with default features disabled. From the workspace
root, run its short-tap, bounce and queue regressions with:

```sh
cargo test -p microbit-input --lib --no-default-features
```
