# micro-burn firmware

An async BLE peripheral for a micro:bit V2 and Kitronik :VIEW Graphics128 OLED.
The desktop is the BLE central and writes training observations to this device.
The device sends receipt and user-action notifications back to the desktop.

## Build and test

From `projects/micro-burn`:

```sh
cargo test -p micro-burn-firmware --lib
cargo build -p micro-burn-firmware --target thumbv7em-none-eabihf --profile firmware
```

To render the actual screen layout using synthetic data on the laptop:

```sh
cargo run -p micro-burn-firmware --example preview
```

This writes 128×64 PGM images to `/tmp/micro-burn-oled-preview`. They are labelled
synthetic previews, not recorded training data or proof of hardware operation.

To program a connected board from this directory:

```sh
cargo run -p micro-burn-firmware --target thumbv7em-none-eabihf --profile firmware
```

The repository's ARM runner uses `probe-rs` and `nRF52833_xxAA`. Running a flash
command replaces the program on the connected board. The first build needs the
Rust ARM target and downloads the published Nordic controller/MPSL libraries.
There is no separately flashed monolithic SoftDevice image.

The `src/lib.rs` tests run on the laptop and check pager state, including offline
acknowledgement, duplicate results, snooze and bookmark identity. They do not prove
Bluetooth connectivity, OLED wiring, sound, or physical button operation. Actual
board validation is recorded in the project specification separately.

## Hardware

Slot the micro:bit into the :VIEW. The default OLED address is `0x3C`.

| Function | nRF52833 pin/peripheral |
| --- | --- |
| :VIEW SDA / edge P20 | P1.00, TWISPI0 |
| :VIEW SCL / edge P19 | P0.26, TWISPI0 |
| Button A | P0.14, active low |
| Button B | P0.23, active low |
| Onboard speaker | P0.00, PWM0 |
| Embassy time | RTC1 |
| MPSL radio timing | RADIO, RTC0, TIMER0, TEMP and reserved PPI channels |

Use the micro:bit USB connector for programming and a battery pack for portability.
Bluetooth coverage depends on the laptop, room and obstructions. A disconnected
pager shows its retained observation and data age; it cannot receive a new result
until the connection returns.

## Controls

- A cycles the overview, metrics/trend, and result/connection pages.
- B opens the action menu.
- In the menu, A selects the next action and B chooses it.
- Acknowledge silences the result locally immediately, including while offline.
- Snooze silences the alarm for 60 seconds.
- Cycle alert policy selects all results, errors only, or muted.
- Bookmark records the snapshot currently displayed, rather than the later step
  reached when the host receives the request.
- Back closes the menu.

One ordinary user action is pending at a time, with a reserved slot so alert
acknowledgement can always take priority. The device retains request IDs and retries
after reconnection until the host confirms or rejects them. An acknowledgement made
offline also appears in readable device status so reconnect reconciliation can
respect it. Page changes remain local and do not manufacture network messages.

## Async and BLE structure

`main.rs` binds the Nordic controller interrupts and creates the GATT service
defined by the shared `micro-burn` protocol constants. Its advertisement contains
the service UUID; the scan response supplies the `micro-burn` name. Its static-random
BLE address comes from the nRF52833 factory-programmed `FICR.DEVICEADDR` registers,
so the desktop can rediscover the same explicitly selected board after a reset.
The hardware RNG remains available to the Nordic controller. See Nordic's
[factory address guidance](https://devzone.nordicsemi.com/f/nordic-q-a/105268/nrf52833-mac-address-ramdonly-changing-while-advertising/454384).

The MPSL runner maintains radio timing, and the TrouBLE runner services the BLE
host. A connection loop validates writes, assembles complete snapshots, accepts
notification subscriptions, exposes readable status and transmits device events.
After disconnection it starts advertising again.

Separate Embassy tasks sample/debounce buttons every 2 ms, draw and asynchronously
flush the OLED, and generate short PWM speaker pulses while an alert is active.
All application mailboxes use `ThreadModeRawMutex` on the same single-core,
thread-mode executor; access from an interrupt is rejected. The button task reuses only the pure debounce
state machine, avoiding the existing wrapper's global interrupt masking.

The firmware selects MPSL's critical-section implementation. It does not link the
root workspace's `cortex-m/critical-section-single-core` implementation. MPSL's
reserved peripherals are unavailable to display/button/sound code. The protocol
crate is built without host features, so Burn, Iced, Tokio and `btleplug` are absent
from the ARM image.

The link is an unpaired local demonstration carrying aggregate training metrics.
No student-level records are transmitted. Nordic's precompiled controller/MPSL
libraries have their own licences in addition to the Rust wrappers' MIT/Apache
licences. See the published `nrf-sdc` and `nrf-mpsl` package licence files.
