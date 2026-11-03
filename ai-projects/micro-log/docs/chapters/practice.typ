= Experiments, debugging, and a reading checklist

== Verify the build without changing the board

From the repository root:

```sh
cargo build-log --profile firmware
cargo test -p micro-log --lib
```

The first command compiles and links an ARM executable. It does not run that
executable on your computer. The second builds the storage library and tests
for your computer's host target, using the simulated flash implementation.
It does not test the physical sensor, USB bridge, or brownout behaviour.

For this guide, the freshly linked executable was also inspected. Its
`_log_start` and `_log_end` symbols resolved to `0x70000` and `0x80000`, and no
loadable file contents overlapped that range. The highest flash load address
ended at `0x6254`, far below the reserved boundary. This is why “the FLASH
region ends at `0x70000`” does not mean “the program fills 448 KiB.” If the
program changes, inspect the new ELF rather than relying on these old values.

LLVM's `llvm-readobj --program-headers` shows load segments, and
`llvm-objdump --syms` shows linker symbols. The toolchain includes LLVM tools;
depending on installation, their directory may need to be added to PATH. An
ELF inspection checks the built image, not a physical board's existing memory.

Cargo finds configuration from the working directory and its parents. Selecting
`-p micro-log` alone does not load the child project's `.cargo/config.toml`.
The root build alias selects `thumbv7em-none-eabihf` explicitly. From inside
`projects/micro-log`, the local default target is ARM; host tests there need
an explicit host target. The code's target-specific dependencies keep the
hardware runtime out of the host-only library tests.

The `firmware` profile inherits release optimisation while retaining debug
information. Build the same profile you intend to flash. The exact flashing
command is documented here for when you intentionally replace the board's
current program:

```sh
cargo flash-log -- --profile firmware
```

Export data you want to keep before changing firmware. A page-aligned region
outside this ELF's loadable contents is a deliberate protection, not a universal
promise about every flasher or replacement program. A mass erase, chip recovery,
or another program's different memory map can remove the log.

== Experiment 1: persistence is not a long-lived variable

+ Start with a deliberately cleared log. Record five or more samples while
  slowly rotating the board, then pause.
+ Export once to a new filename. Note the number of rows and their session.
+ Remove USB and the battery pack so the entire board loses power.
+ Reconnect USB and wait for the paused picture. Export to another new filename
  *without reflashing*. The old rows should still be present.
+ Record a few more samples and export again. Old rows retain their old session;
  the new saved rows use the session derived during this boot.

Predict what a simple RAM-only implementation would do before performing the
experiment. The point is not that the same `Log` Rust object survived. That
object was recreated. The bytes survived, and the new object reconstructed its
position by scanning them.

== Experiment 2: inspect the byte format on paper

Use the sample uptime `1000`, acceleration `[-1000, 7, 999]`, and magnetic field
`[125, -23456, 34567]`. Write the byte positions for each value using the
storage chapter's table. Check that `1000` becomes `e8 03 00 00` in little-endian
form. Check that `-1000` has the 32-bit two's-complement bit pattern `fffffc18`,
stored as `18 fc ff ff`.

Now mark the reserved bytes, checksum, and final completion word. Explain why
copying the in-memory `Record` struct would fail to establish the same stable
format. The codec writes an explicit format, not an assumption about a Rust
struct's padding or field layout.

== Experiment 3: reason about interrupted writes

Draw three slots. Slot 0 has a valid record, slot 1 has some programmed payload
but no completed commit word, and slot 2 is erased. Predict the new valid-row
count, next physical slot, and session after reboot. Then compare your answer
with `Log::open` and the interruption tests.

Next draw an erased hole followed by a valid slot. Predict what goes wrong if
the scan stops at the first blank slot. Finally draw a completed commit whose
caller received an error before updating its RAM count. A scan can discover a
valid stored record that the previous in-memory count never included.

These are reasoning exercises and simulated-fault cases. Repeatedly pulling
power while flash is actively being programmed is not a complete characterisation
of the device's electrical limits. The protocol improves recovery; it does not
replace Nordic's required supply conditions.

== Experiment 4: separate the clocks

Change nothing at first. Explain why there are eight RTC ticks per nominal log
interval but ten sensor conversions per second. Explain which clock the LED
display's delay uses. Then predict the effect of doubling `TICKS_PER_SAMPLE`.
It changes the interval between saved rows; it does not reconfigure the sensor
output rate or expand flash capacity.

If you later experiment with a faster log interval, reconsider the blocking
display and serial work, integer timestamp resolution, flash timing, and how
quickly the log fills. There is no scheduler in this program that automatically
makes those operations concurrent or replays missed samples.

== Experiment 5: audit the unsafe boundary

Cover the safety comments and explain each obligation in your own words. Which
file establishes the address range? Which operation checks only its length?
Who keeps the peripheral and the unique mutable slice after construction? What
would a second call to `reserved_flash()` break? Why is `_log_end` only used as
an address, even though it is declared as a `u8` symbol?

Then read the safety comments again. A useful comment should justify why this
particular invocation satisfies the unsafe API's requirements. Merely saying
“this is safe” or “it works on my board” does not identify those requirements.

== A practical debugging map

#table(
  columns: (1.1fr, 2.1fr),
  table.header([Symptom], [First distinction to investigate]),
  [Build fails before flashing], [Dependency/target problem versus linker-script problem. Check the compiler message before changing hardware code.],
  [Sensor initialisation panics], [Expected LSM303AGR versus a different board revision, then I²C pin mapping and driver configuration.],
  [No CSV arrives], [Correct device/port and baud, board showing paused status, another process holding the port, then command/framing behaviour.],
  [Export refuses output], [Existing file or symlink, missing directory, or a filesystem without hard-link support. This is separate from whether flash holds records.],
  [Only some slots export], [Valid-record count versus occupied-slot count. Torn or corrupt slots are deliberately omitted.],
  [Uptime starts again], [A reboot changes the time origin. Compare session numbers; uptime is not calendar time.],
  [Magnetic readings change near the computer], [Board orientation, nearby metal and magnets, currents and LEDs, and lack of compass calibration.],
  [Short button tap is missed], [This firmware polls in the foreground. It is not using the interrupt sampler, and export blocks that foreground work.],
  [X immediately after programming], [Reserved pages may contain earlier firmware data. Export anything useful, then explicitly clear before a fresh experiment.],
)

RTT diagnostics and the USB serial port are different channels. A panic may be
visible through an attached debug probe while the serial exporter simply times
out. Reconnecting a serial terminal is different from running a flash command.
During diagnosis, avoid replacing firmware just to retrieve the readings that
the existing firmware already knows how to export.

== Glossary

#table(
  columns: (0.9fr, 2.3fr),
  table.header([Term], [Meaning here]),
  [Address], [A numeric location in the processor's memory map. An integer having that value does not itself prove an access is valid.],
  [Register], [A hardware-defined control/status location, often accessed through memory-mapped I/O.],
  [Peripheral], [A hardware unit such as a timer, serial controller, or flash controller that the CPU configures and observes.],
  [Ownership], [The program's rule about which value is responsible for a resource. Moving a peripheral token transfers that responsibility.],
  [Lifetime], [A constraint describing how long a Rust reference may be used. A lifetime annotation does not allocate storage.],
  [Aliasing], [Multiple ways to reach the same memory. Mutable references impose exclusivity requirements, even when two paths look syntactically different.],
  [Undefined behaviour], [A violation of the language's required rules, after which ordinary reasoning about program behaviour is no longer valid. It is not merely a recoverable Result error.],
  [Invariant], [A condition that must remain true while a data structure or unsafe abstraction is being used.],
  [Page / word / slot], [4 KiB erase unit / 4-byte programming unit / this application's 64-byte record allocation.],
  [MMIO / DMA], [Memory-mapped I/O for register access / hardware transfer to or from memory. These are mechanisms, not threads managed by an operating system.],
  [CRC / commit], [An accidental-corruption check / a completion indication written after the payload. Neither is encryption or authentication.],
  [Atomic visibility], [Readers see a completed published file name rather than this script's partially written final file. Different from guaranteed survival of a host crash.],
)

