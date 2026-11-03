# micro-radio

A small Embassy radio experiment for two **micro:bit V2** boards. Both run the
same firmware:

| Action | Result |
| --- | --- |
| Press A | Send the UTF-8 text `HELLO` once. |
| Press B | Send the UTF-8 text `WORLD` once. |
| Receive a valid packet | Show a tick on the built-in 5×5 LEDs for about 200 ms and log its contents. |

Release a button before pressing it again; holding it does not keep sending.
No accessory display is needed.

## Build and flash

**From `projects/micro-radio`, use:**

```sh
cargo build --profile firmware
cargo embed -- --profile firmware
```

The project's `.cargo/config.toml` selects the ARM target. `Embed.toml` selects
the nRF52833 and enables RTT logging. The project's `memory.x` describes its
512 KiB flash and 128 KiB RAM; `build.rs` makes that memory map available to the
linker.

From the workspace root, the equivalent aliases are:

```sh
cargo build-radio --profile firmware
cargo flash-radio -- --profile firmware
```

## Try it on two boards

1. Connect **only the first board** by USB and run the flash command. Wait for
   flashing to finish, then stop its debugging/RTT session with **Ctrl+C**.
2. Disconnect that board's USB cable and power it from its battery pack.
3. Connect the second board by USB and run the same flash command. Keep this
   session open so you can read the second board's RTT output.
4. Press A on the battery-powered board. The USB board should briefly show a
   tick and log `RX: HELLO`. Press B to send `WORLD`.
5. Press A or B on the USB board. Its output reports the send result, and the
   battery-powered board should show a tick when it receives the packet.

Stopping the first session and disconnecting its USB cable before flashing the
second board avoids choosing between two attached debug probes. A board's tick
indicates reception; sending a packet does not light its own tick.

Read RTT in the flashing/debugging session. It uses the debug probe rather than
a USB serial port, so a serial monitor will not show these messages. Valid
UTF-8 packets are printed as text; other received bytes are printed in hex.
Logging does not block a battery-powered board without an attached debugger.

## Follow the code

Read [`src/main.rs`](src/main.rs) in this order: `main`, `button_task`, the radio
loop and `send_message`, then `display_task`. Inputs, radio and LED pins are
owned directly through `embassy-nrf`.

### Entry point and tasks

`#[embassy_executor::main]` starts Embassy's executor and runs the async `main`.
Its `Spawner` starts independent tasks:

```rust
spawner.spawn(button_task(button_a, "HELLO").unwrap());
spawner.spawn(button_task(button_b, "WORLD").unwrap());
```

`button_task` has `#[embassy_executor::task(pool_size = 2)]`, allowing these two
instances of the same task, each owning its input pin and message. A third task
owns the LED matrix. The main task keeps sole ownership of the radio.

Calling an async function creates an operation that must be polled to make
progress. `.await` waits for that operation within the current task; it does
not spawn another task. When the awaited operation is pending, the executor can
run other ready tasks. This lets button waits, LED timing and radio reception
share the CPU without a manual polling loop.

### Buttons and the outgoing queue

The board's buttons are active low. Each button task waits for low, waits
20 ms, then checks the pin is still low before queuing its message. After
sending to the queue, it waits for high and confirms release after another
20 ms. This filters bounce and makes a held button send once.

The shared channel holds up to four outgoing text messages:

```rust
static OUTGOING: Channel<ThreadModeRawMutex, &'static str, 4> = Channel::new();
```

`OUTGOING.send(message).await` queues a message, waiting if the queue is full.
The button task never accesses the radio. The strings are fixed program data,
so their references stay valid while queued.

### Receive or send

Setup selects the external high-frequency crystal, binds the RADIO interrupt
to Embassy's handler, and configures channel 11 at 0 dBm. The main loop waits
for either a received packet or queued outgoing text:

```rust
let event = select(radio.receive(&mut incoming), OUTGOING.receive()).await;
```

`select` runs both operations until one completes, then drops the other. This
radio driver's receive operation safely stops its DMA transfer when cancelled,
so a button message can end the current receive and start a send. A successful
receive has passed the hardware CRC check; the loop logs its bytes and calls
`RECEIVED.signal(())` to notify the display task.

`send_message` copies text into a RAM packet and awaits one send attempt:

```rust
outgoing.copy_from_slice(message.as_bytes());
let result = radio.try_send(&mut outgoing).await;
```

The actual helper matches that result to log success, a busy channel, or another
error. Transmission is awaited to completion rather than cancelled by another
`select`. `TX: HELLO` means the local transmission finished; it does not prove
the peer received it. A busy channel produces a message asking you to press
again. There are no automatic retries or delivery acknowledgements.

### Receive indicator

`display_task` waits on the `RECEIVED` signal. It scans the tick one row at a
time, awaiting 2 ms per row for 20 complete frames: about 200 ms. Those waits
let the radio and button tasks continue. Another reception refreshes the tick's
duration. A signal is a notification rather than a packet queue, so several
arrivals can share one visible tick.

## Radio limits

This uses the raw **IEEE 802.15.4 physical layer at 250 kbit/s**, with up to
**125 application bytes** per packet. It supplies length framing and CRC
handling, without adding discovery, pairing or a complete networking stack.
Its channel, power and packet format match the previous HAL version of this
demo, so those two implementations can exchange these text packets.

This mode does not interoperate with MakeCode or MicroPython's usual micro:bit
radio protocol. Both boards should run this demo for the exercise above.

Reception is best effort. Each receive operation handles one packet and must
be started again; processing and sending create gaps, and the radio cannot
receive while transmitting. Async display timing lets reception progress while
the tick is shown, but does not guarantee every packet arrives. Start with
separate presses on one board, then alternate between boards.
