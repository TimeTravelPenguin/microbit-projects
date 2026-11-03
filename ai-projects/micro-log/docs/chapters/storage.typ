= Persistent storage: from a Rust value to flash bytes

The persistence mechanism lives in `src/lib.rs`. It is deliberately separate
from the sensor loop: the library accepts a `Sample`, stores it, and later
reconstructs a `Record`. It does not know about buttons, I²C, or serial ports.
This makes its most important failure cases testable on the computer.

Keep three things separate while reading this chapter: the Rust values in
RAM, the encoded bytes in RAM, and the physical bytes in flash. Constructing
a value or filling an array does not save anything. Calling the flash
driver's `write` or `erase` method performs the persistent operation.

== Why flash needs a different algorithm from RAM

RAM is the working area for local variables, buffers, the stack, and the
`Log` object's bookkeeping. Ordinary assignments can change its bytes
repeatedly. Its contents are not retained across power loss.

Flash holds the firmware and this project's saved measurements. Reading
flash resembles reading other mapped memory, but changing it requires the
NVMC: the nRF52833's _non-volatile memory controller_. Programming operates
on aligned 32-bit words, or four bytes. An erase operates on an entire
4 KiB page. An erased byte is `0xff`: all eight bits are one. Programming
can change a one bit to zero; changing it back requires an erase. Flash
operations can stall execution of code fetched from flash. These are
hardware rules, not Rust restrictions.
#footnote[See Nordic's
#link("https://docs.nordicsemi.com/r/bundle/ps_nrf52833/page/nvmc.html")[NVMC
specification] and the project's installed `nrf-hal-common` 0.19.0
implementation, `src/nvmc.rs`.]

For example, programming `0b1111_0000` over erased bits is possible.
Replacing that value with `0b1111_1111` by another ordinary write is not.
The driver must erase the containing page first. Erasing a page also
erases all the other samples sharing it. The application therefore appends
to fresh space and never edits an existing record.

Erase/program endurance is finite. This project reduces unnecessary wear
by avoiding automatic erases, including at boot and when full. It does
not implement wear levelling or estimate a guaranteed storage lifetime.

== Where the saved data fits

The device has 512 KiB of internal flash. `memory.x` divides it into
448 KiB for firmware and 64 KiB for the log. Here, KiB means 1,024 bytes;
the linker's `K` suffix uses this binary quantity.

#table(
  columns: (auto, auto, 1fr),
  table.header([Region], [Address range], [Purpose]),
  [`FLASH`], [`0x00000000..0x00070000`], [Firmware; 448 KiB],
  [`LOG`], [`0x00070000..0x00080000`], [Persistent samples; 64 KiB],
  [`RAM`], [`0x20000000..0x20020000`], [Working memory; 128 KiB],
)

These ranges are half-open: the first address belongs to the region and
the address after `..` does not. `0x80000 - 0x70000` is `0x10000`, or
65,536 bytes. That is sixteen 4 KiB erase pages.

The library fixes `SLOT_SIZE` at 64 bytes. A _slot_ is one possible
physical record position. Capacity is therefore `65,536 / 64 = 1,024`
slots, with 64 slots per erase page. At one successful sample each second,
an initially empty log holds about 17 minutes and four seconds. Damaged
slots consume space, too, so the number of valid samples can be lower.

The library uses offsets relative to its partition. Slot 3 begins at
`3 * 64 = 192`, rather than at absolute address 192. The HAL's storage
slice makes that relative position refer to physical address
`0x70000 + 192`. Keeping these two address systems distinct helps prevent
confusing a slot index, a byte offset, and a processor address.

== The data structures and the flash abstraction

```rust
pub struct Sample {
    pub uptime_ms: u32,
    pub acceleration_mg: [i32; 3],
    pub magnetic_field_nt: [i32; 3],
}

pub struct Record {
    pub session: u32,
    pub sample: Sample,
}
```

`u32` is an unsigned 32-bit integer. `i32` is a signed 32-bit integer,
needed because the axes can be negative. Each three-element array is
ordered x, y, z. Acceleration is stored in milligravity units and magnetic
field in nanotesla. A `Record` adds the session number to the sample.
Its `uptime_ms` is time relative to this boot, not a calendar timestamp.

Both structures derive `Clone`, `Copy`, `Debug`, `Eq`, and `PartialEq`.
They contain only small fixed-size values: copying them needs no heap
allocation. Equality also makes readback verification and tests direct.
Their RAM layout is not the file format. There is no `repr(C)` contract
and no cast of a `Record` pointer into a byte slice. The serializer chooses
every byte explicitly, avoiding dependence on padding or Rust layout.

```rust
pub struct Log<Flash> {
    flash: Flash,
    next_slot: usize,
    count: usize,
    session: u32,
}

impl<Flash: NorFlash> Log<Flash> {
    // Methods follow here.
}
```

`Flash` is a generic type parameter. `Flash: NorFlash` means the methods
are available when that type implements the `NorFlash` trait. In the
firmware it is an `Nvmc<pac::NVMC>`; in tests it is `FakeFlash`. The same
storage algorithm works with either implementation. Owning `flash`
inside `Log` also keeps other safe callers from independently using that
driver while the log owns it.

`NorFlash` extends `ReadNorFlash`, which supplies `read` and `capacity`.
The write trait adds `write` and `erase`. Its associated constants
`READ_SIZE`, `WRITE_SIZE`, and `ERASE_SIZE` describe the implementation's
alignment/granularity requirements. Its associated error type is written
`Flash::Error`. These traits are an interface to storage capabilities,
not a guarantee that any possible device has this project's geometry.
#footnote[The
#link("https://docs.rs/embedded-storage/0.3.1/embedded_storage/nor_flash/trait.NorFlash.html")[published
`NorFlash` contract] describes aligned writes and erases, interrupted
operations, and the restriction on rewriting a word. The project locks
`embedded-storage` at 0.3.2; the linked 0.3.1 reference documents the same
core trait interface.]

Consequently, `open` asserts that reads have size 1, writes have size 4,
erase size is positive, the partition is a whole number of erase units,
and capacity is at least 64 KiB. An assertion failure is a programming or
configuration error and panics; it is not an `Error` returned to callers.

== The exact 64-byte record format

All integer fields use little-endian encoding: the least significant
byte comes first. The ranges in this table are relative to one slot.

#table(
  columns: (auto, auto, 1fr),
  table.header([Bytes], [Size], [Meaning]),
  [`0..4`], [4], [ASCII magic `MBLG`],
  [`4..8`], [4], [Format version, currently `1` as `u32`],
  [`8..12`], [4], [Session number as `u32`],
  [`12..16`], [4], [Uptime in milliseconds as `u32`],
  [`16..20`], [4], [Acceleration x as `i32`],
  [`20..24`], [4], [Acceleration y as `i32`],
  [`24..28`], [4], [Acceleration z as `i32`],
  [`28..32`], [4], [Magnetic field x as `i32`],
  [`32..36`], [4], [Magnetic field y as `i32`],
  [`36..40`], [4], [Magnetic field z as `i32`],
  [`40..56`], [16], [Reserved; encoder leaves these at `0xff`],
  [`56..60`], [4], [CRC-32 of bytes `0..56`],
  [`60..64`], [4], [ASCII commit marker `DONE`],
)

The _magic_ identifies something that looks like this log format. The
version prevents a future incompatible format from being interpreted as
the current one. Reserved bytes provide room for a future format change;
they are included in the checksum. The current decoder does not require
each reserved byte to be `0xff` independently: the CRC covers them.

The commit marker is in its own four-byte word. That word is written last,
after the previous 60 bytes. This arrangement is the basis of recovery.
A slot whose payload was only partly written normally has no complete
`DONE` word and is rejected.

=== Walking through `encode`

`let mut bytes = [0xff; SLOT_SIZE]` creates a 64-byte array in RAM. The
`; SLOT_SIZE` syntax repeats the value, rather than listing elements.
`copy_from_slice` copies bytes into the destination slice in RAM; it does
not invoke the NVMC. Calls such as `session.to_le_bytes()` produce a
four-byte array with an explicit byte order.

```rust
for (axis, value) in record
    .sample
    .acceleration_mg
    .iter()
    .chain(record.sample.magnetic_field_nt.iter())
    .enumerate()
{
    let offset = 16 + axis * 4;
    bytes[offset..offset + 4].copy_from_slice(&value.to_le_bytes());
}
```

`iter()` borrows each array's elements. `chain` visits the three
acceleration values followed by the three magnetic values. `enumerate`
adds indices 0 through 5. Here `axis` indexes the combined six values;
it is not just an x/y/z number. Multiplying by four converts that index
to a byte displacement. Adding 16 skips the header. The final value
starts at byte 36 and ends just before byte 40.

The remaining operations compute the checksum, copy its four bytes into
`56..60`, copy `DONE` into `60..64`, and return the array. Although the
RAM array already contains `DONE`, the append method still controls when
that part reaches flash.

For a signed example, `-1000i32` has the two's-complement bit pattern
`0xfffffc18`. Its little-endian bytes are `18 fc ff ff`. Decoding first
gets the unsigned bit pattern `0xfffffc18`; `as i32` interprets those same
32 bits as a signed integer, giving −1000. There is no magnitude-only
conversion and no separate sign byte.

=== Walking through `decode` and `read_u32`

`decode` takes a reference to an exactly 64-byte array. It returns
`Option<Record>`: `Some(record)` for an accepted row and `None` for a
blank, unfinished, incompatible, or damaged row. These cases are all
unusable rows to the exporter; they do not need separate decoding errors.

It checks the magic, version, commit word, and checksum. Boolean `||`
short-circuits, so a failed early check can avoid later work. Only after
those checks does it construct a `Record` with the known field offsets.
This validates the storage format, not the physical plausibility of a
measurement: unusual axes can still be correctly encoded measurements.

`read_u32` selects `bytes[offset..offset + 4]`, converts that slice to a
four-byte array using `try_into()`, then calls `u32::from_le_bytes`.
Its `unwrap()` relies on the private helper always receiving a valid
four-byte range. All existing call sites use fixed valid offsets within
the 64-byte buffer. Arbitrary offsets would require additional checks;
the helper is not exposed as a public unchecked parser.

== What the checksum actually does

`crc32` implements CRC-32/ISO-HDLC using the reflected polynomial
`0xedb8_8320`. A CRC is a compact check value that changes in response to
changes in the input bytes. It detects many accidental corruption
patterns. It is not encryption, authentication, or a promise to detect
every possible error. Two different inputs can have the same CRC.

```rust
let mut crc = u32::MAX;

for byte in bytes {
    crc ^= u32::from(*byte);

    for _bit in 0..8 {
        let low_bit = crc & 1;
        crc >>= 1;

        if low_bit != 0 {
            crc ^= 0xedb8_8320;
        }
    }
}

!crc
```

`u32::MAX` starts with all 32 bits set. `^` is bitwise exclusive-or;
`& 1` isolates the lowest bit; `>>= 1` shifts the working register right.
For each input byte, eight iterations process its bits using the
polynomial. `!crc` inverts every final bit. `_bit` names an intentionally
unused loop variable: the loop needs eight repetitions, not the index.

The checksum is calculated over the first 56 bytes. It excludes both its
own four-byte value and `DONE`. The decoder recalculates the checksum
from the bytes actually read, then compares it with the stored value.
The standard check input `123456789` produces `0xcbf4_3926`; a test fixes
that expected value to catch an incompatible implementation change.

The CRC and final marker make a useful recovery protocol. They do not
make a 64-byte write physically atomic. An _atomic_ operation would be
indivisible: entirely before or entirely after a failure. These sixteen
flash words are programmed separately, and interruption can leave a
partially programmed word. Recovery interprets the surviving bytes.

== Opening the log: recovering the index without storing an index

The `Log` object's fields live in RAM, so reboot loses `next_slot`,
`count`, and `session`. `open` rebuilds them by reading all 1,024 slots.
There is no separately updated flash header that could become the one
fragile source of truth.

It begins with `next_slot = 0`, `count = 0`, `last_session = 0`, and one
reusable 64-byte buffer. For each physical slot it reads from
`(slot * SLOT_SIZE) as u32` into that buffer. A driver error becomes
`Error::Flash` and returns immediately.

Two independent questions follow each read:

+ _Does any byte differ from `0xff`?_ If so, this slot has evidence of
  use, and `next_slot` moves to `slot + 1`, even if decoding will fail.
+ _Does `decode` return a valid record?_ If so, `count` increases and
  `last_session` becomes the maximum valid session observed so far.

The scan visits every slot, even after an erased one. An interrupted
clear can erase early pages while leaving later records intact. Stopping
at the first blank slot could reuse earlier space and eventually collide
with those later records. Instead, the next append always goes after the
last nonblank slot found anywhere in the partition.

For example, suppose slots 0 and 1 are blank, 2 is damaged, and 3 is a
valid row, with all later slots blank. `count()` is 1 but `used_slots()`
is 4. Slots 0 through 3 are behind the append position. The implementation
does not fill holes. Once slot 1023 is nonblank, the log is full even if
few valid records survive.

After scanning, `checked_add(1)` chooses the next session after the
highest valid stored session. On an empty partition it returns 1. If the
highest valid session is `u32::MAX`, addition returns `None` and
`ok_or(Error::SessionExhausted)?` returns an error instead of wrapping
to zero.

A session is consequently inferred from saved rows; it is not an exact
persistent boot counter. If a boot saves no complete row, the following
boot can reuse that session number. Likewise, a torn first row does not
advance the highest _valid_ session. A successful clear resets numbering
to 1. CSV session values are useful for separating recorded runs, with
those qualifications.

== Appending: reserve, encode, program, verify

`append(&mut self, sample)` needs an exclusive mutable borrow of the log,
because it changes both flash and bookkeeping. If `is_full()` is true,
it returns `Error::Full` before programming anything.

Next it saves the current slot in a local and immediately increments
`next_slot`. That reservation happens _before_ either write. Even if a
write fails, an immediate retry in this same process uses a different
slot. A failed write must not cause the program to program the same
flash word again without erasing it.

After wrapping the sample in this session's `Record` and encoding it,
the two persistent calls are:

```rust
self.flash
    .write(offset, &bytes[..COMMIT_OFFSET])
    .map_err(Error::Flash)?;
self.flash
    .write(offset + COMMIT_OFFSET as u32, &bytes[COMMIT_OFFSET..])
    .map_err(Error::Flash)?;
```

The first call programs 60 bytes: fifteen four-byte words. The second
programs the final word. Their addresses and lengths are multiples of
four. There is no read-modify-write of an existing record, and the code
does not rely on the more permissive `MultiwriteNorFlash` trait that some
drivers implement.

Within the installed nRF HAL, writes enable NVMC write mode, program
words, wait for readiness between writes, and restore read mode. The log
then calls `read(slot)` for readback. The HAL read waits for NVMC
readiness before copying the mapped flash bytes into the RAM buffer.
This final read is therefore part of completion and verification, not
just an optional debugging print.

The returned record must equal `Some(record)` exactly. A successful
driver return with missing or corrupted data becomes
`Error::VerifyFailed`. Only after successful verification does `count`
increase and the method return `Ok(())`.

Consider four failure points. Before any persistent byte changes, reboot
may find the slot fully erased and reuse it. During the payload, reboot
normally finds a nonblank rejected slot and advances past it. During the
commit word, an incomplete marker is rejected. After the complete commit
but before the caller receives success, reboot can accept the record.
An error return therefore does not prove no data reached flash.

This last case also means a live `count` can temporarily undercount
valid on-flash rows after a backend error. A fresh `open` reconstructs
the count. Unlike failed `clear`, a failed `append` does not globally
disable future appends; it consumes its own slot. The firmware currently
uses `expect` on append errors, so it panics instead of automatically
retrying. The library tests deliberately exercise continued use.

== Reading, erasing, and the remaining public methods

`read(slot)` accepts a physical slot index, not the ordinal number of a
valid sample. It rejects `slot >= CAPACITY` before multiplying the index
or reading. A valid index can refer to an erased or damaged slot, so the
return type is `Result<Option<Record>, Error<Flash::Error>>`.

Read that nested type from the outside inward: `Err(...)` means the
operation failed; `Ok(None)` means the bytes were read but contain no
accepted record; `Ok(Some(record))` contains a usable measurement.
The exporter visits `0..used_slots()` and skips `None` entries.

`clear()` explicitly erases the entire 64 KiB partition. Before doing so
it sets `next_slot = CAPACITY` and `count = 0`. This pessimistic state
blocks writes if the erase reports an error. An interrupted erase can
change more than the rows the software expected; the old RAM index is
not trustworthy after it.

On successful erase, `next_slot` becomes 0 and `session` becomes 1.
On failure, the old session remains, the count is not a count of surviving
rows, and `is_full()` remains true as a deliberate write lockout. Reopen
the underlying flash to scan survivors, or successfully clear it before
continuing. Erase is not transactional: it cannot restore already erased
samples if a later page fails.

#table(
  columns: (auto, 1fr),
  table.header([Method], [Exact role]),
  [`count()`], [Valid rows found at open or successfully appended;
    qualifications after errors are explained above.],
  [`used_slots()`], [Append position, including holes and rejected rows
    before the final nonblank slot.],
  [`capacity()`], [The fixed 1,024 physical slots.],
  [`session()`], [The current inferred session number.],
  [`is_full()`], [`next_slot == CAPACITY`; also the failed-clear lockout.],
  [`into_inner(self)`], [Consumes the log and returns its owned flash
    driver; it neither erases nor rescans storage.],
)

The five `Error` variants cover distinct decisions. `Flash(error)` wraps
the driver's original error, such as an invalid alignment or address.
`Full` means no writable next slot. `SessionExhausted` prevents session
wraparound. `SlotOutOfBounds` rejects invalid read indices.
`VerifyFailed` reports that readback did not match the requested record.
An invalid row by itself is represented by `None`, not an error variant.

In `.map_err(Error::Flash)?`, `map_err` transforms the driver error into
the library's error enum. `?` passes success onward or returns early with
the error. It does not retry, panic, undo a write, or erase anything.
`Ok(())` is successful completion with no additional return value.

== How the build keeps firmware away from the log

`build.rs` is a small program run by Cargo on the development computer,
not on the micro:bit. `OUT_DIR` names Cargo's generated-files directory.
`include_bytes!("memory.x")` embeds the project's linker script into the
build script at compile time; `fs::write` copies it to that directory.
Its two `cargo:` output lines add a linker search directory and request
a rerun when `memory.x` changes. The `unwrap`s here report a failed build
environment operation, not a hardware fault at runtime.

The workspace target configuration selects `rust-lld` and passes
`-Tlink.x`. The Cortex-M runtime's `link.x` uses `memory.x` to place the
image. Declaring the usable firmware `FLASH` as 448 KiB prevents normal
firmware sections from growing into the 64 KiB log.
#footnote[The runtime documents this relationship in
#link("https://docs.rs/cortex-m-rt/0.7.7/cortex_m_rt/")[`cortex-m-rt`'s
memory-layout and inspection reference].]

`_log_start = ORIGIN(LOG)` and `_log_end = ORIGIN(LOG) + LENGTH(LOG)`
define linker symbols at the partition boundaries. They do not create
Rust variables whose stored values contain the addresses. Taking each
symbol's address is what obtains the boundary. No loadable section is
assigned to `LOG`, so the intended ELF carries no initial log payload.
The unsafe bridge in `main.rs` turns this reserved address range into
the slice owned by the NVMC driver.

The two linker assertions check that the firmware FLASH region ends where the log begins
and that the log starts on a page boundary. These are useful configuration
checks, not a hardware protection mechanism. The final linked ELF must
still be inspected for the expected boundary symbols and flash load
ranges, especially when a dependency also provides a `memory.x` file.

`Cargo.toml` keeps `embedded-storage` as the library dependency available
on host and device. The target-specific dependency section brings in
the runtime, board support, sensors, buttons, serial support, and RTT
only for bare-metal targets. `test = false` on the firmware binary
avoids trying to execute that entry point in host tests. The library's
`#[cfg(test)] extern crate std` and test module enable the host fake
while normal firmware stays `no_std`.

`Embed.toml` selects `nrf52833_xxAA` and sets `do_chip_erase = false`.
This asks the flashing workflow to erase firmware sectors rather than
the whole chip. Persistence across power cycles is separate from
persistence across reflashing: a mass erase, another tool, or a firmware
image using these pages can destroy the log. The configuration expresses
the preservation intent; it does not turn the region into protected
storage.

== What the twelve storage tests prove

`FakeFlash` stores simulated bytes in a heap-allocated array on the
computer. It advertises byte reads, four-byte writes, and 4 KiB erases.
It rejects invalid accesses, tracks programmed words, rejects rewriting
a word without an erase, and enforces the one-to-zero programming rule.
Fault switches simulate failures after words, halfway through a word,
after a commit, or after selected erase pages.

The twelve named tests exercise these cases:

+ `stores_signed_axes_and_starts_a_new_session_after_reboot` checks
  signed values, multiple rows, reopen, the next session, and no erase.
+ `every_word_power_cut_preserves_old_rows_and_skips_the_interrupted_slot`
  tries all sixteen word boundaries, including a completed commit.
+ `a_failed_append_consumes_its_slot_even_without_a_reboot` verifies
  that an immediate retry uses the following slot.
+ `a_partial_write_inside_each_word_including_commit_is_not_a_record`
  interrupts each word after two programmed bytes.
+ `full_log_stops_without_erasing_or_overwriting` fills all slots and
  confirms the first and final rows survive reopen.
+ `clear_erases_explicitly_and_restarts_the_log` checks one explicit
  erase, empty state, and session reset.
+ `corrupt_records_and_blank_holes_are_never_reused` checks scanning
  beyond a blank hole and damaged payload/commit rows.
+ `failed_clear_can_be_reopened_past_all_remaining_rows` interrupts an
  erase after the first page; six of seventy rows survive, and the
  recovered append position remains 70.
+ `verification_detects_a_failed_program` simulates corruption after
  commit and expects `VerifyFailed` with a consumed slot.
+ `session_counter_never_wraps` seeds the maximum session and checks
  the explicit overflow error.
+ `rejects_out_of_bounds_slots` rejects capacity and `usize::MAX`.
+ `crc_matches_the_standard_check_value` checks the CRC test vector.

These tests provide evidence about the algorithm under the fake's fault
models. They do not reproduce every electrical effect of a falling
supply, verify actual flash endurance, or prove universal atomicity.
Their useful promise is specific: the code deliberately treats slots
as consumable, validates surviving records, scans the whole partition,
and never erases automatically to make room.
