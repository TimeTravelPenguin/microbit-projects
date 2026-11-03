= Meeting the hardware

The firmware in `src/main.rs` is the coordinator. It obtains access to the
board, starts clocks, prepares the display and serial connection, opens the
saved log, configures the motion sensor, and repeats a small control loop.
The storage library decides how a reading becomes a persistent record. The
Python program later turns the serial export into a desktop file.

== CPU, peripherals, pins, and registers

The *CPU* is the part of the nRF52833 that executes Rust's compiled machine
instructions. This micro:bit uses an Arm Cortex-M4 processor. A *peripheral*
is a hardware unit that performs a particular job alongside the CPU: counting
clock pulses, moving serial bytes, or controlling flash, for example. The
sensor is also a peripheral in the broader sense, but it is a separate chip
connected to the nRF52833. The distinction matters: `RTC0` is inside the
microcontroller; the LSM303AGR is outside it. See the
#link("https://tech.microbit.org/hardware/2-0-revision/")[official V2 hardware overview].

A *GPIO* is a general-purpose input/output connection. Configured as an input,
it lets software read a voltage as a logical high or low. Configured as an
output, it drives a logical high or low. The same physical pin can sometimes
be connected internally to a serial peripheral instead of being manually
controlled by software. A peripheral and its pins are therefore different
resources: `TWIM0` is the I²C controller, while SDA and SCL are its electrical
connections to the sensor.

A *register* is a small hardware control or status location. Writing a clock
register can start an oscillator; reading an RTC register obtains the current
counter. These registers are mapped to addresses that the CPU accesses using
memory instructions. A register read can observe changing hardware, so it is
not interchangeable with reading an ordinary Rust variable. The register
access libraries arrange the special, volatile accesses that tell the
compiler to perform the actual operation.

The code relies on several layers of assistance:

#table(
  columns: (1fr, 2.5fr),
  table.header([Layer], [Role in this project]),
  [Application], [`main.rs`: decide when to read, record, and export.],
  [Driver], [`lsm303agr`: translate sensor operations into register messages.],
  [BSP], [`microbit`: name the board's wired pins and provide its display.],
  [HAL], [`nrf-hal-common`: operate clocks, timers, I²C, UART, and flash.],
  [PAC], [`pac`: typed names for the nRF52833's peripheral registers.],
  [Hardware], [The electrical circuits, clocks, flash cells, and sensor.],
)

*HAL* means hardware abstraction layer; *BSP* means board support package;
*PAC* means peripheral access crate. An abstraction does not make the
hardware disappear. It gathers the register sequences and their safety
requirements into reusable code. For example, `sensor.acceleration()` calls
the driver, which calls the HAL's I²C implementation, which uses the PAC to
operate TWIM hardware. The
#link("https://docs.rs/microbit-v2/latest/microbit/")[micro:bit crate documentation]
is the entry point to the BSP used here.

== The resources actually used

#table(
  columns: (1fr, 2.5fr),
  table.header([Resource], [Job]),
  [`CLOCK`], [Start the high-frequency and low-frequency clocks.],
  [`RTC0`], [Keep a free-running count for sample intervals and timestamps.],
  [`TIMER0`], [Provide short blocking delays for display and sensor setup.],
  [GPIO], [Read A/B and drive the LED rows and columns.],
  [`TWIM0`], [Read and configure the motion sensor over internal I²C.],
  [`UARTE0`], [Exchange commands and CSV through the USB interface chip.],
  [`NVMC`], [Program and erase the reserved internal flash.],
  [SWD / RTT], [Send diagnostic and panic messages through the debugger.],
)

`RADIO`, Bluetooth, the microphone, speaker, ADC, sensor interrupts, `TIMER2`,
and the nRF52833's native USB device peripheral are not used by this logger.
Having a resource available on `Board` does not activate it. The log persists
because it uses flash, not because the firmware keeps any of those other
peripherals running when power is removed.

= From reset to the first loop

== What the opening Rust attributes mean

```rust
#![no_std]
#![no_main]

#[entry]
fn main() -> ! {
    // Initialisation, then an endless loop.
}
```

`no_std` means that the firmware does not link Rust's usual operating-system
standard library. There is no desktop process, filesystem, or terminal here.
Rust's `core` library still supplies familiar types, formatting, slices,
iterators, and `Result`. The program uses fixed-size values and buffers;
ordinary sensor sampling does not allocate a growing collection in RAM.

`no_main` suppresses the normal desktop entry arrangement. The `entry`
attribute from `cortex-m-rt` connects this function to the microcontroller's
startup code. At reset, the processor uses a *vector table*, containing the
initial stack pointer and reset-handler address. The runtime prepares the
usual initialized and zero-initialized RAM sections before calling the
application entry point. These duties are documented by
#link("https://docs.rs/cortex-m-rt/0.7.7/cortex_m_rt/")[cortex-m-rt].

`-> !` is Rust's *never type*: this function never returns to a caller. The
main loop runs until reset, power loss, or a fatal error. `unwrap()` and
`expect("message")` take a successful value out of an `Option` or `Result`;
failure panics. `expect` adds a useful description. Here a sensor or flash
failure stops normal operation instead of attempting a recovery strategy.
The imported `panic_rtt_target` supplies that panic handler. A panic does
not erase the saved log, and it does not automatically restart the board.

== Taking ownership of the board

`microbit::Board::take().unwrap()` obtains the BSP's collection of peripheral
and pin handles. `take()` normally succeeds only once. The handles are
ownership tokens for real hardware, not copied simulated devices. Moving
`board.RTC0` into `Rtc::new` means that the RTC wrapper now owns that token.
Other code cannot keep independently using the moved field.

This is a practical use of Rust ownership: two drivers should not secretly
reconfigure the same timer while each believes it controls it. Pin ownership
also prevents accidentally handing the display's wires to a second driver.
Ownership does not prove that every electrical choice is correct, but it
removes a large class of conflicting uses from ordinary safe application
code.

The aliases near the imports simply shorten types:

```rust
type FlashLog = Log<Nvmc<pac::NVMC>>;
type Serial = UartePort<pac::UARTE0>;
```

The first means “our log using this chip's flash-controller driver”; the
second means “our serial wrapper using UARTE0.” They create no new hardware.
The angle brackets supply the concrete type used by a generic library.

== Initialization order

Reading `main` in phases makes its dependencies clearer:

+ Initialize RTT so later diagnostics have a destination.
+ Take the board, start clocks, and start the RTC.
+ Create the delay timer, display, button reader, and serial port.
+ Give the reserved flash region to NVMC and scan existing log slots.
+ Check the optional startup erase gesture.
+ Create the I²C bus and configure the motion sensor.
+ Set `recording = false`, remember the current RTC count, and print Ready.
+ Enter the control loop.

The unsafe `reserved_flash()` call is the bridge between linker-defined
memory addresses and a Rust slice. NVMC receives that slice and owns access
to it for the run. Understanding its contract requires the memory map and
Rust's reference rules; the flash and unsafe-code chapter examines it in
detail. The call creates access to existing bytes: it does not itself clear
them. `Log::open` examines those bytes to recover earlier committed rows.

== The deliberate erase gesture

Only the startup path checks whether *both* physical buttons are down. If
they are, it remembers the RTC count and repeatedly checks them while showing
an X. At 16 ticks, nominally two seconds, it calls `log.clear()`. It then
shows pause bars until both buttons are released, preventing that held
gesture from immediately becoming a normal recording command.

If either button is released before the threshold is observed, the loop
exits without erasing. The check uses raw input levels, not the later
four-sample debouncer, and the RTC has 125 ms resolution. This is a simple
guarded startup gesture, not a precision long-press detector. Pressing A+B
after normal startup does not invoke erase. Erasing several pages is also
not one atomic transaction: interruption can leave a partly cleared area.
Repeating the startup gesture finishes clearing it; there is no separate
erase journal.

= Two timers with different jobs

== CLOCK: the rhythm behind the hardware

```rust
let _clocks = Clocks::new(board.CLOCK)
    .enable_ext_hfosc()
    .set_lfclk_src_synth()
    .start_lfclk();
```

A clock supplies repeated electrical timing pulses. This chain starts the
external high-frequency oscillator, selects a synthesized low-frequency
clock, then starts it. An external 32 MHz crystal controls the oscillator
that supplies the 64 MHz high-frequency clock; the synthesized LFCLK is
32,768 Hz. *Synthesized* means derived from
the high-frequency source, rather than from a separate watch crystal.
Consequently this choice also keeps that source required. See Nordic's
#link("https://docs.nordicsemi.com/r/bundle/ps_nrf52833/page/clock.html")[CLOCK specification].

The leading underscore in `_clocks` says that retaining the value is
intentional even though later code does not read that variable. The type
tracks which clock sources and running state have been selected. The object
is a handle to the configuration, not a software loop generating pulses.

== RTC0: an elapsed-time counter

`Rtc::new(board.RTC0, 4095)` chooses a prescaler, a hardware divider. The
counter frequency is `32768 / (4095 + 1) = 8` increments per second, making
one tick `1 / 8` second, or 125 ms. `enable_counter()` starts it; no interrupt
handler is required to keep it counting. The CPU reads it with
`get_counter()`. Nordic describes this as a 24-bit real-time *counter* in its
#link("https://docs.nordicsemi.com/r/bundle/ps_nrf52833/page/rtc.html")[RTC specification].

The firmware uses that one counter in three places: measuring the erase
gesture, deciding when another sample is due, and calculating `uptime_ms`.
With `TICKS_PER_SAMPLE = 8`, each ordinary sampling interval is nominally
one second. `uptime_ms: now * 125` changes in steps of 125, so the column
contains millisecond units without millisecond precision. A timestamp such
as `3125` represents the RTC count 25.

This counter is not a calendar clock and has no battery-backed timekeeping.
It starts again after reset and stops advancing when power is removed.
Time spent in initialization is included because the RTC starts before
sensor configuration. The saved session field distinguishes timestamp
origins across boots when earlier valid rows exist.

== Why `rtc_elapsed` masks the subtraction

```rust
fn rtc_elapsed(now: u32, earlier: u32) -> u32 {
    now.wrapping_sub(earlier) & RTC_MASK
}
```

The register has 24 useful bits even though Rust stores its value in a
32-bit integer. After `0xFFFFFF`, hardware returns to zero. Ordinary unsigned
subtraction across that transition can underflow; `wrapping_sub` explicitly
allows arithmetic modulo the 32-bit range. Applying `& 0x00FFFFFF` keeps the
lowest 24 bits, giving elapsed ticks modulo the hardware counter's range.

For example, suppose `earlier = 0xFFFFFC` and `now = 0x000004`. The counter
crossed zero, but eight increments passed. Wrapping subtraction followed by
the mask produces 8, so a sample can still become due. A simple `now >=
earlier + 8` comparison would mishandle this boundary.

There are 16,777,216 different counter values. At eight per second, a full
cycle takes 2,097,152 seconds, approximately 24.27 days. The helper works
when the actual elapsed interval is shorter than one complete cycle. It
cannot distinguish eight ticks from one complete cycle plus eight ticks.
The exported uptime also returns to zero at that wrap without creating a
new session. Long-running analyses must account for it.

== TIMER0: short waits while the CPU is busy

`Timer::new(board.TIMER0)` prepares a separate general-purpose timer. In
this HAL its delay implementation uses a 1 MHz timer basis. The display
borrows it to hold a row on for milliseconds; sensor setup borrows it for
required transition delays. Those calls block the current flow until the
delay is complete.

The RTC continues counting during those delays and while serial output or
flash programming occupies the CPU. The application therefore asks “how
many ticks passed?” instead of pretending every loop iteration takes exactly
10 ms. That preserves a useful time reference, but it does not make sampling
concurrent. If work delays the loop, the next row is late. The code sets
`last_sample = now` and stores one reading; it does not reconstruct missing
seconds or write a burst of historical readings.

= Buttons and the LED display

== Active-low buttons and software debounce

Button A connects to P0.14 and B to P0.23 in the BSP. Board pull-up resistors
hold the released inputs high; pressing a button connects its input low.
Thus `button_a.is_low()` returns true when A is pressed. The BSP configures
these GPIOs as floating inputs because the board already supplies the
external pull-ups. Pin names such as P0.14 identify the microcontroller's
port and bit, not the numbering printed along the edge connector.

Mechanical contacts can chatter between pressed and released during one
physical transition. `Buttons` filters this in software:

+ `candidate` stores the state currently being tested.
+ A changed candidate starts a count at one; matching readings increase it.
+ Four consecutive readings establish a new stable state.
+ A stable transition to pressed emits one event. Holding does not repeat.
+ A stable release is needed before another press can be emitted.

In this application `sample()` runs once per main loop, and one display scan
normally takes about 10 ms. Four samples therefore correspond to roughly
30–40 ms from the physical transition to detection in a quiet loop. Serial
exports and flash work can lengthen that interval. The shared input crate
also serves other projects whose sampling timer runs every 2 ms; its comment
about a 6–8 ms debounce does not describe this logger. There is no background
button interrupt here, so a short tap during a blocking export can be missed.

`Buttons::sample` increases separate pending A/B counts using saturating
addition: a count stops at 255 instead of wrapping to zero.
`take_presses()` uses `core::mem::take` to return those counts and replace
them with their default zero values. It leaves the candidate and held-button
state intact. The logger only tests whether each count is greater than zero,
so it treats any queued count as a request rather than toggling once per
count.

== A matrix, not 25 separate output wires

`Display::new(board.display_pins)` receives five row lines and five column
lines. The blocking driver selects a row high and pulls the columns for its
lit pixels low, waits, then turns that row off and proceeds. In the version
used here, each row receives 2 ms and five rows make one approximately
10 ms scan. Repeating scans makes the pattern appear steady.

`PAUSED`, `RECORDING`, and `FULL` are arrays of five arrays, each containing
five `u8` values. In this simple driver zero is off and a positive value is
on. `[[0, 1, 0, 1, 0]; 5]` repeats the same row five times to draw pause bars.
These arrays are pictures, not GPIO addresses.

`display.show(&mut delay, image, 10)` temporarily borrows the timer and
display mutably. While it scans, the main loop does no other application
work. It does not arrange an autonomous continuous display update. Export
calls `display.clear()` first, so the LEDs stay dark while the blocking CSV
transfer proceeds; repeated scans resume afterward.

= Reading the accelerometer and magnetometer

== TWIM0 and the internal I²C bus

```rust
let bus = Twim::new(
    board.TWIM0,
    board.i2c_internal.into(),
    Frequency::K100,
);
let mut sensor = Lsm303agr::new_with_i2c(bus);
```

I²C carries messages over two shared lines: SCL carries clock pulses and
SDA carries data. TWIM is Nordic's I²C controller with EasyDMA support;
the final zero selects a particular hardware instance. `K100` requests a
100 kHz bus clock. It does not request 100,000 sensor samples per second.
The BSP's internal bus uses SCL P0.08 and SDA P0.16. `.into()` converts its
board-specific pin collection into the generic pin structure expected by
the HAL; it does not move or rewire physical connections.

The sensor driver uses two 7-bit I²C device addresses, `0x19` for the
accelerometer and `0x1E` for the magnetometer. They are two functions within
one package, not flash addresses or CPU pointers. A transaction selects the
device and a sensor register, then sends configuration bytes or receives
measurement bytes. The driver handles the register numbers, multi-byte
reads, and conversion details. The
#link("https://tech.microbit.org/hardware/i2c/")[micro:bit I²C documentation]
describes the bus and addressing.

This firmware specifically uses the LSM303AGR driver. It does not detect
and select an alternative motion-sensor model at runtime; the description
here follows that hardware and driver combination.

== Sensor configuration and type state

`sensor.init()` enables block data update for both measurement blocks and
also enables the sensor's temperature circuitry in driver version 1.1.0;
the application never reads that temperature. The following calls select
high-resolution magnetometer mode at 10 Hz, continuous magnetic measurement,
and normal accelerometer mode at 10 Hz. The accelerometer range remains the
driver's default of ±2 g. See the
#link("https://docs.rs/lsm303agr/latest/lsm303agr/")[lsm303agr driver API]
and the
#link("https://www.st.com/resource/en/datasheet/lsm303agr.pdf")[ST sensor datasheet].

`into_mag_continuous()` consumes the existing driver and returns one whose
Rust type represents continuous magnetometer mode. This pattern is called
*type state*: available operations depend on the state encoded in the type.
The `let Ok(mut sensor) = ... else { panic!(...) };` statement extracts that
new driver on success. The new `sensor` binding shadows the previous one;
there are not two independently active driver objects.

The sensor now produces conversions internally about every 100 ms, whether
the application is paused or recording. The logger reads at approximately
1 Hz. It deliberately keeps a sparse observation of the output, not all
ten conversions and not their average. It does not enable the sensor FIFO
or wait on data-ready interrupts.

== What one row really measures

`sensor.acceleration()` reads the acceleration output registers, then
`sensor.magnetic_field()` reads the magnetic output registers. These calls
are sequential and their underlying conversion clocks are independent.
`now` is read before both calls. Consequently the row timestamp is the
application's sampling time reference, not a hardware timestamp that proves
all six axes were converted at precisely that instant.

Block data update (BDU) prevents a channel's low and high bytes from changing
halfway through reading that byte pair. ST's application note explains that
the registers otherwise contain the latest output, with the pair held once
its read begins. BDU does not synchronize all axes or both sensor blocks.
Under normal continuous 10 Hz operation, output can be roughly one conversion
period old when read. For precise relationships between movement and field,
this program offers no stronger synchronization guarantee. See
#link("https://www.st.com/resource/en/application_note/an4825-ultracompact-highperformance-ecompass-module-based-on-the-lsm303agr-stmicroelectronics.pdf")[ST AN4825, sections 3.3.4 and 4.2.1].

The driver interprets signed sensor output and applies sensitivity factors.
`x_mg()` returns acceleration in milli-g, so 1,000 mg corresponds to 1 g,
approximately 9.81 metres per second squared. A board resting on a table
still senses gravity; rotating it changes the distribution among its axes.
`mg` here is a unit of acceleration, not milligrams of mass.

`x_nt()` returns magnetic field in nanotesla: 1,000 nT equals 1 µT. With this
driver a magnetic raw count corresponds to 150 nT. The integers in the CSV
are already converted physical units, not raw register contents, despite
retaining sensor noise and offsets. They are not compass headings. This
application adds no compass calibration, tilt correction, or heading
calculation. Magnets, nearby metal, and electrical currents can affect the
measurements. Axis directions follow the sensor driver's convention rather
than a separate transformation to compass directions.

= Serial communication and the helper crate

== UART inside the board, USB outside it

The constructor configures `UARTE0` with 115,200 baud and excluded parity.
The UART framing is 8 data bits, no parity, and one stop bit (8N1). There
are no RTS/CTS flow-control pins in the BSP conversion. From the application
processor's perspective, TX is P0.06 and RX is P1.08.

Those wires reach the separate interface processor, which presents a USB
serial connection to the computer. The route is application UARTE → board
interface processor → USB → operating-system serial port → Python. This
firmware does not implement a USB stack or directly use the nRF52833's USBD
peripheral. The distinction explains why Rust configures UART pins even
though the user plugs in a USB cable. Nordic documents the hardware unit in
its
#link("https://docs.nordicsemi.com/r/bundle/ps_nrf52833/page/uarte.html")[UARTE specification].

UART transmission does not require a serial monitor to acknowledge every
byte. With flow control disabled, status messages can be sent when no host
program is listening; they are simply not saved by that host. The Python
exporter initiates a fresh complete transfer instead of relying on the
startup Ready message still being available.

== EasyDMA, buffers, and `UartePort`

DMA means direct memory access: hardware moves bytes between a peripheral
and RAM while the CPU performs other instructions or waits. Nordic's
EasyDMA uses RAM buffers with valid addresses and lifetimes for the transfer.
This is why the serial helper creates its own static buffers instead of
giving DMA a temporary string that might disappear.

`UartePort::new` creates one-byte TX and RX buffers using
`cortex_m::singleton!`, then calls `serial.split(...)`. The macro provides
unique static storage and returns `None` if that allocation site has already
been taken; `unwrap()` enforces the one-initialization assumption. These
`'static` buffers last for the entire firmware run. The HAL can therefore
retain their references while transfers proceed.

The wrapper holds a transmitter and receiver as two tuple-struct fields,
accessed as `self.0` and `self.1`. Its methods are small adapters:

#table(
  columns: (1fr, 2.5fr),
  table.header([Method], [Meaning]),
  [`write_str`], [Implements `core::fmt::Write` for formatted text.],
  [`write`], [Send one byte.],
  [`write_all`], [Keep writing until the supplied bytes are accepted.],
  [`write_lf`], [Send the newline byte.],
  [`write_crlf`], [Send carriage return followed by newline.],
  [`flush`], [Wait until queued transmission completes.],
  [`read`], [Wait for and return one received byte.],
  [`try_read`], [Check readiness, then return a byte or `None`.],
)

The one-byte TX buffer keeps this example small but gives poor throughput
compared with larger DMA batches. `writeln!` formats directly into this
writer; it does not first create a giant CSV `String`. The HAL copies text
into its RAM buffer and progresses transmission, potentially blocking while
earlier bytes finish. Thus a full export occupies the main control flow.

`try_read()` checks `read_ready()` before calling the blocking `read()`.
When there is no completed received byte it returns `Ok(None)` immediately.
`Ok(Some(b'd'))` requests export. Only one byte is examined per main-loop
iteration; this is a tiny command protocol, not a buffered command shell.

== RTT is a separate route

`rprintln!` sends diagnostic text to an RTT buffer in RAM, which a debugger
can inspect over SWD. It is not sent to the USB serial CSV stream.
`rtt_init_print!()` defaults to a nonblocking skip mode for ordinary output:
if the buffer cannot accept output, messages can be dropped instead of
stalling normal logging. The logger prints only a brief Ready diagnostic
through RTT in its normal path.

The panic handler deliberately switches RTT to blocking mode so a debugger
can receive a panic report. If no debugger drains the buffer, it may wait
there; it then remains in a non-returning halt loop anyway. That difference
matters when interpreting a stopped board: normal recording does not depend
on continuously draining RTT, while a panic is intentionally fatal.

= Following one pass through the main loop

First, the loop samples A/B and drains pending press counts. It also checks
one incoming serial byte. The following decision has an explicit order:

```rust
if presses.button_b > 0 || export_requested {
    recording = false;
    // Clear display and export saved rows.
} else if presses.button_a > 0 {
    recording = !recording && !log.is_full();
    last_sample = rtc.get_counter();
}
```

B or lowercase `d` wins over A when both are observed in the same iteration.
Export always pauses recording. Otherwise A toggles recording, subject to
the log not being full. The expression `!recording && !log.is_full()` means
“start only when currently paused and space remains”; pressing A while
already recording produces false and pauses.

Resetting `last_sample` when A is handled ensures that starting or resuming
does not immediately store a row left over from a long pause. The first row
waits until eight RTC counts have passed, nominally one second. Because the
initial RTC read can occur between ticks, that is a quantized interval,
approximately 875–1,000 ms plus loop delay, rather than an exact stopwatch
second.

The loop reads `now` and tests whether recording is active and enough ticks
have passed. If so, it captures both sensor values into a `Sample` and calls
`log.append(sample)`. That hand-off is where ordinary volatile working data
becomes a request for persistent storage. The library supplies session and
record-format information. If the append consumes the final slot, the
firmware pauses and prints a full-log message.

Finally it chooses the picture in priority order: full X, recording square,
or paused bars. A full log therefore keeps showing X even when A is pressed.
One blocking 10 ms display scan finishes the iteration, then the process
repeats. The overall design is a single cooperative loop: it handles each
job in order, while clock counters and serial hardware can progress
independently.

== Walking through `export_csv`

The function borrows the log and serial wrapper mutably for the duration of
export. It writes a beginning marker and an eight-column header, walks
`0..log.used_slots()`, and asks `log.read(slot)` for each record. `None`
means there is no valid record to export in that slot, so `continue` skips
it. Used slots include space consumed by invalid or interrupted writes;
iterating only the number of valid records would miss later valid slots.

For a valid record, `writeln!` serializes the session, uptime, acceleration
array's three entries, and magnetic array's three entries in order. The
format strings explicitly include `\r`; `writeln!` adds `\n`, producing
CRLF line endings. Status lines begin with `#`, allowing the Python side to
recognize them as protocol or commentary rather than sensor rows.

The `?` operator returns early if serial formatting or writing fails. A
flash read error instead invokes `expect` and panics. Only after every slot
has been traversed does the function write the ending marker and flush the
transmitter. This ordering lets the exporter reject a disconnected or
interrupted transmission that never reaches a valid end marker. Flush means
bytes have left the UART's pending transmission; it is not proof that a
desktop file has been written. That final responsibility belongs to Python.

== What the power controls do not add

The firmware does not configure `POWER`, enter System OFF, or put the CPU
into a scheduled low-power sleep between samples. Paused recording still
scans LEDs, polls inputs, and leaves the sensor running. Persistent flash
logging should therefore not be confused with a complete battery-life
management strategy. The physical rear reset/power button also involves
the board's interface firmware; this application implements no long-press
power-button policy. For the persistence experiment, physically remove
both USB and battery power, then reconnect without reflashing.
