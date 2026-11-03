#import "theme.typ": guide, note, ink, accent, muted, pale
#show: guide

#v(17mm)
#text(size: 11pt, weight: "bold", fill: accent)[A SMALL LOGGER, EXPLAINED FROM THE BITS UP]
#v(6mm)
#text(size: 38pt, weight: "bold")[Inside micro-log]
#v(5mm)
#text(size: 18pt, fill: muted)[Rust, peripherals, persistent flash, and unsafe code]
#v(12mm)

You can run a microcontroller program without yet understanding why its memory
survives a power cut, how a pin becomes an I²C connection, or what makes an
`unsafe` block acceptable. This guide makes those connections explicit, using
the working `projects/micro-log` project in this repository.

#v(5mm)
#note([What you will be able to explain])[
  How a physical movement becomes six sensor values, how those values become
  bytes in flash, how the next boot recognises complete records, and how the
  computer receives a CSV. You will also be able to state the assumptions behind
  the raw-pointer code instead of treating `unsafe` as a magic incantation.
]

#v(5mm)
#text(size: 9pt, fill: muted)[
  Prepared 24 October 2026. Based on the current workspace sources and their
  pinned Rust and Python dependencies. The source listings are read directly
  from the project whenever this document is compiled.
]

#pagebreak()
#outline(title: [Contents], depth: 2)
#pagebreak()

= The whole project before the details

== What the program actually promises

The firmware is for a *micro:bit V2 with an LSM303AGR sensor*. It records the
three acceleration axes and three magnetic-field axes, nominally once per
second. It stores records in a dedicated 64 KiB region of the application
processor's flash. Flash retains its contents without power; the Rust variables
used to keep track of that flash do not. Each boot rebuilds those variables by
reading the stored bytes.

Press A to start or pause recording. Press B, or send the single byte `d` from
the computer, to pause and export all valid records. Hold A+B during startup for
two seconds to erase the region, then release both buttons. The firmware always
starts paused. It never erases the log just because it has restarted or become
full. The pause bars, recording square, and full-log X are status pictures, not
additional storage.

The log holds 1,024 slots. At one record per second, an entirely blank log holds
about 17 minutes of recording. A torn or damaged slot still consumes space.
Stopping when full makes it possible to examine old data before deleting it.
This is a finite teaching logger, not an indefinitely running circular log.

The familiar `MY_DATA.HTM` experience in MakeCode and MicroPython belongs to
their logging runtime. This project instead uses its own record format in the
nRF52833 and exports through USB serial. The official
#link("https://microbit.org/get-started/user-guide/data-logging/")[micro:bit data
logging guide] describes the higher-level runtime's experience; it is not the
file format implemented here.

== Follow a single reading

#figure(
  grid(
    columns: (1fr, auto, 1fr, auto, 1fr),
    column-gutter: 7pt,
    row-gutter: 7pt,
    block(fill: pale, inset: 10pt)[*LSM303AGR*\ Physical motion and magnetic field],
    align(center + horizon)[→],
    block(fill: pale, inset: 10pt)[*TWIM0 / I²C*\ Read the sensor's registers],
    align(center + horizon)[→],
    block(fill: pale, inset: 10pt)[*RAM*\ Build a `Sample` and encode its bytes],
    [], [], [], [], align(center)[↓],
    block(fill: pale, inset: 10pt)[*CSV on the computer*\ Validate and publish the file],
    align(center + horizon)[←],
    block(fill: pale, inset: 10pt)[*UARTE0 → USB bridge*\ Transmit formatted rows],
    align(center + horizon)[←],
    block(fill: pale, inset: 10pt)[*NVMC / flash*\ Append, commit, and recover],
  ),
  kind: "diagram",
  supplement: [Figure],
  caption: [The six sensor values pass through several different representations.
    The flash remains when power is removed; the RAM working values do not.],
)

For example, a stationary board might report acceleration near
`[0, 0, 1000]` mg, with signs and axes depending on orientation. The library
wraps the measurement with a boot session and uptime. It deliberately encodes
those integers into a 64-byte array. NVMC programs a fresh slot, then a final
completion word. On a later boot the scan checks the format, completion word,
and checksum. The exporter formats only records that pass those checks.

You should distinguish four operations: *measuring* a sensor, *reading* its
output registers, *saving* a record, and *transmitting* that record. They happen
at different times. The sensors run at 10 Hz, flash logging happens at about
1 Hz, and CSV export happens only on request. The six columns in one row are
not a promise of simultaneous physical measurements.

== A map of the source files

#table(
  columns: (1.1fr, 2.1fr),
  table.header([File], [Responsibility]),
  [`src/main.rs`], [Owns the hardware, performs startup, polls buttons, reads sensors, chooses when to append, and emits CSV.],
  [`src/lib.rs`], [Defines records, encodes and checks bytes, scans flash, appends safely with respect to its storage protocol, and clears explicitly.],
  [`src/tests.rs`], [Runs the storage logic against a simulated flash device, including interruptions inside writes.],
  [`memory.x` + `build.rs`], [Describe the memory partition and make that linker script available during the build.],
  [`Cargo.toml`, local Cargo config, `Embed.toml`], [Select dependencies, target, and how firmware is built and flashed.],
  [`crates/serial-setup/src/lib.rs`], [Adapts the HAL UART halves to formatting and byte-oriented I/O with persistent DMA buffers.],
  [`crates/microbit-input/src/lib.rs`], [Provides the reusable button debouncer used by this firmware without its interrupt-based hardware module.],
  [`export.py`], [Requests a framed export and saves a validated CSV without publishing an incomplete file.],
  [`pyproject.toml` + `uv.lock`], [Declare and resolve the desktop Python dependencies managed by UV.],
)

== How to read the rest

Start with the hardware chapter if the peripheral names feel unfamiliar. Read
the flash-storage chapter to understand what must remain true after a power
cut. Then work slowly through the unsafe chapter: it names the guarantees that
ordinary Rust borrowing cannot establish from a linker file. The desktop chapter
completes the path into a file you can open in a spreadsheet.

Code excerpts explain selected operations. The appendix contains line-numbered
listings read from the actual files, so you can place each excerpt back into
context. A phrase such as “the program checks” refers to code in this project;
“the hardware guarantees” requires the device documentation. Tests demonstrate
selected situations, not every possible physical power failure.

#note([Two meanings of “safe”])[
  *Rust memory safety* concerns valid pointers, lifetimes, aliasing, and access
  rules. *Data durability* concerns which records survive an interruption.
  A checksum and a commit word help the second problem. They do not make an
  invalid Rust reference valid. A correct `unsafe` argument helps the first
  problem. It does not guarantee that power stays on until a flash write ends.
]

#pagebreak()
#include "chapters/hardware.typ"
#pagebreak()
#include "chapters/storage.typ"
#pagebreak()
#include "chapters/unsafe.typ"
#pagebreak()
#include "chapters/desktop.typ"
#pagebreak()
#include "chapters/practice.typ"
#pagebreak()
#set page(flipped: true)
#include "appendix.typ"
