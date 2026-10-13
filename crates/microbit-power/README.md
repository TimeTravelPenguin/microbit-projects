# microbit-power

Cooperative reset-button power management for micro:bit V2 Rust firmware. The
interface chip detects a long press and reports it after restarting the program
on release. This crate reads that event, completes the power-down handshake, and
puts the application processor into System OFF. A short reset press wakes it.

Add the crate to another project in this workspace:

```toml
[dependencies]
microbit-power = { path = "../../crates/microbit-power" }
```

Set it up immediately after taking the board, then let it run your application:

```rust
use microbit::board::Board;

let board = Board::take().unwrap();
let mut power = microbit_power::power_off!(board);

// The remaining board fields are available for your display, buttons, and timers.
power.run(|| {
    // Render a frame or do other work. Finish active DMA before the next check.
});
```

On reset-button release, the interface restarts the application processor before
posting its event. Setup polls during a roughly 100 ms grace period, retrying
transient replies, so a late shutdown event can be handled before application
initialization or the first frame. Normal startup takes about 100 ms longer.
This is a bounded grace period, not a protocol delivery deadline.

`run` checks again between calls to your closure. Your closure must return
periodically; no background interrupt or global state is used. Checking once per
displayed frame is sufficient for the existing blocking display example. If you
manage your own loop, call `power.check()` at the same safe boundary instead.

The helper reserves TWIM0, the internal I²C pins P0.08/P0.16, the shared interrupt
input P0.25, TIMER3, and POWER. TIMER3 handles the short handshake delays without
using the application's display timer. The motion sensors share this I²C bus;
use `PowerOff::new_shared` when the application also needs them.

For a sensor application, create the internal TWIM0 bus yourself, store it in a
`RefCell`, and give each driver a `SharedI2c` handle:

```rust
use core::cell::RefCell;
use microbit::hal::{Twim, twim::Frequency};
use microbit_power::{PowerOff, SharedI2c};

let internal_bus = RefCell::new(Twim::new(
    board.TWIM0,
    board.i2c_internal.into(),
    Frequency::K100,
));

let mut power = PowerOff::new_shared(
    &internal_bus,
    board.pins.p0_25,
    board.TIMER3,
    board.POWER,
);

let mut sensor = lsm303agr::Lsm303agr::new_with_i2c(SharedI2c::new(&internal_bus));
// Create device drivers before this check so cleanup can turn them off.
// Initialize them for normal use only after checking the startup power event.
power.check_startup_with(|| {
    // Stop the sensor and external display if a shutdown event is pending.
});
```

The shared constructor defers startup polling until `check_startup_with`, so its
cleanup callback can stop devices that remain powered through a processor reset.
Run that check before the first frame. For example, the VIEW demo powers down the
accelerometer and turns off the OLED in both startup and normal shutdown cleanup.
`power_off!(board)` retains its automatic startup grace period.

Shared bus access stays in the main loop. `SharedI2c` borrows only for the duration
of each transaction and does not mask interrupts, allowing unrelated button
handlers to run during transfers. Do not access that same bus from an interrupt
handler while a main-loop transfer is running.

Applications with external devices or asynchronous DMA/PWM work can use a cleanup
callback in their own loop. It runs once after a shutdown request:

```rust
power.check_with(|| {
    // Finish DMA and stop application-specific devices here.
});
```

Cleanup must leave the internal I²C controller enabled for the interface-chip
handshake. Once the handshake completes and P0.25 is released, the helper disables
that controller before entering System OFF. External I²C controllers, sensors,
displays, and application timers should be stopped by the cleanup callback.

Polling errors return control to the application; optional diagnostics are
available through `power.last_error()`. After a shutdown request, the helper owns
the shutdown process and retries the pending handshake step with a short delay,
without returning to rendering or resending acknowledged commands. On shutdown,
the helper blanks the GPIO-driven display, clears microphone enable, sets the
speaker's GPIO level low, and uses P0.25 as the wake input. Active PWM overrides
GPIO levels and must be stopped in `check_with`, including when testing with a
debugger attached. With USB connected, the interface chip stays powered; on
batteries it powers down too.

The generic `PowerManager`, `Error`, and `SharedI2c` are also available without the
hardware feature. Run the protocol and shared-bus tests on the host from the
workspace root:

```sh
cargo test --offline -p microbit-power --lib --no-default-features
```

The protocol follows the official [power-management specification](https://tech.microbit.org/software/spec-power-management/)
and [I²C interface protocol](https://tech.microbit.org/software/spec-i2c-protocol/).
