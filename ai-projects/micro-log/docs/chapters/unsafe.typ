= Understanding the unsafe boundary

The lowest-level application code is small enough to read in one sitting. Its responsibility is substantial: turn a range of addresses chosen by the linker into the exclusive storage handle expected by the flash driver. It does not measure acceleration, encode records, calculate checksums, or implement the controller's programming sequence. Understanding that boundary makes the rest of the project much less mysterious.

Keep three questions separate while reading: *Where are the bytes? Who may access them? How does the hardware change them?* In this project, `memory.x` answers the first, the ownership handoff answers the second, and the NVMC driver answers the third. The `unsafe` keyword marks the bridge between information Rust can check and facts supplied by the board and linker.

== What unsafe actually means

An unsafe operation has conditions the compiler cannot establish on its own. The programmer must establish those conditions. It does not disable ordinary type checking or borrowing rules, and it does not make incorrect accesses acceptable. A well-designed unsafe boundary lets ordinary safe code rely on a carefully justified promise. See the #link("https://doc.rust-lang.org/book/ch20-01-unsafe-rust.html")[Rust Book's introduction to unsafe Rust].

For this example, imagine telling the compiler: “These 65,536 mapped bytes exist at this board-specific address. Nothing else in this running program owns them. Give this driver the exclusive view.” The compiler cannot inspect the micro:bit's physical flash chip, inspect every debugger action, or infer the meaning of our custom linker symbols. That information must come from the build configuration and program design.

The application contains one `unsafe fn`, `reserved_flash`, and two `unsafe { ... }` expression blocks: the call to that function in `main`, and its call to `from_raw_parts_mut`. There is also an `unsafe extern "C"` declaration block. It declares names; it is not an extra executed write or a call into a C program. Dependencies contain additional unsafe implementations behind their APIs.

== The exact function

This is the current function in `src/main.rs`. Read it once without trying to memorize the syntax; the following sections work through every part.

```rust
unsafe fn reserved_flash() -> &'static mut [u8] {
    unsafe extern "C" {
        static mut _log_start: u8;
        static _log_end: u8;
    }

    let start = core::ptr::addr_of_mut!(_log_start);
    let length = core::ptr::addr_of!(_log_end) as usize - start as usize;
    assert_eq!(length, 64 * 1024);

    // SAFETY: caller ensures unique ownership. Linker symbols delimit mapped,
    // page-aligned flash, with no executable code or initialized data in it.
    unsafe { core::slice::from_raw_parts_mut(start, length) }
}
```

There is no loop and no actual flash programming here. The returned value is a view into existing memory. Constructing this view neither allocates a new buffer nor copies the saved readings into RAM. That is why calling the function does not, by itself, erase or initialize the log.

== First understand the addresses

The nRF52833 flash is divided into a program region and a log region by the project's `memory.x`:

```text
MEMORY
{
  FLASH : ORIGIN = 0x00000000, LENGTH = 448K
  LOG   : ORIGIN = 0x00070000, LENGTH = 64K
  RAM   : ORIGIN = 0x20000000, LENGTH = 128K
}

_log_start = ORIGIN(LOG);
_log_end = ORIGIN(LOG) + LENGTH(LOG);
```

Here `K` means 1,024 bytes. The firmware gets 448 × 1,024 = 458,752 bytes. The log gets 64 × 1,024 = 65,536 bytes. The two add to 524,288 bytes, or 512 KiB. RAM occupies a different address range and loses its working contents when power goes away.

#table(
  columns: (auto, auto, 1fr),
  table.header([Name], [Address / size], [Meaning]),
  [`_log_start`], [`0x00070000`], [First log byte],
  [Last log byte], [`0x0007ffff`], [Last byte included in the log],
  [`_log_end`], [`0x00080000`], [Boundary immediately after the log],
  [Length], [`0x10000` = 65,536], [Number of included bytes],
)

We write the region as the *half-open range* `[0x00070000, 0x00080000)`: include the start, exclude the end. This convention makes the length equal to `end - start` without adding one. It also matches Rust's `start..end` ranges.

The end address is particularly important. It is one byte past this chip's flash region. The code must never read a byte there, write a byte there, or create a Rust reference claiming a byte exists there. It only uses the boundary's numeric address. By contrast, `slice[65_535]` would identify the last included byte; `slice[65_536]` would fail a bounds check.

The rest of `memory.x` checks that the declared firmware FLASH region ends exactly where the log region begins and that the log starts on a 4,096-byte page boundary. The actual executable may occupy much less than that region. These linker assertions detect important layout mistakes during building. They do not inspect runtime ownership.

== Why linker symbols look like static variables

The lines `_log_start = ORIGIN(LOG)` and `_log_end = ...` create linker symbols associated with addresses. They do not store the integers 458,752 and 524,288 in two Rust variables. They do not reserve one-byte objects for the declarations below. This distinction is a standard linker convention, explained in #link("https://sourceware.org/binutils/docs/ld/Source-Code-Reference.html")[the linker manual's source-code reference].

Rust still needs a way to refer to the names. The function therefore declares:

```rust
unsafe extern "C" {
    static mut _log_start: u8;
    static _log_end: u8;
}
```

These are declarations without initializers: “the definitions come from outside this Rust source.” In this project the linker supplies them. `extern "C"` is the interface convention used for the external declarations. There is no C function body here, and no C compiler needs to run to create the log. The Rust Reference describes #link("https://doc.rust-lang.org/reference/items/external-blocks.html")[external blocks] as declarations of externally defined functions or statics.

The `u8` spelling gives the address-taking expressions a byte-pointer type. It does *not* mean the whole log is one byte long, or that reading `_log_end` is an acceptable way to obtain its address. An ordinary value expression such as `let end = _log_end` would attempt a load from that address; it would not return the boundary number. The start is declared `mut` because the eventual driver needs a mutable view into the region; that declaration does not itself program flash.

Rust 2024 requires the `unsafe` marker on this external block. It calls attention to the author's responsibility to match the externally supplied definitions correctly. The marker is about the declarations, not a command to execute a dangerous operation. See the #link("https://doc.rust-lang.org/edition-guide/rust-2024/unsafe-extern.html")[edition guide on unsafe external blocks].

== Taking an address is different from reading a value

The next line is:

```rust
let start = core::ptr::addr_of_mut!(_log_start);
```

`start` has type `*mut u8`: a raw pointer to a byte through which mutation may be permitted when the relevant conditions hold. The `*` is part of the pointer type here. This line does not use `*start` to dereference the pointer and does not load the first stored byte.

`addr_of_mut!` creates the raw pointer directly, without first creating a temporary `&mut` reference. That matters because references immediately make stronger validity and exclusivity promises. The current Rust documentation also presents the equivalent spelling `&raw mut _log_start`; the example retains the existing macro spelling. See #link("https://doc.rust-lang.org/core/ptr/macro.addr_of_mut.html")[`addr_of_mut!`].

The other macro, `addr_of!(_log_end)`, produces a `*const u8`. For this simple symbol expression it also takes the address without loading from the location. That permits using a one-past-the-end boundary without claiming it contains a byte we can read. See #link("https://doc.rust-lang.org/core/ptr/macro.addr_of.html")[`addr_of!`].

A raw pointer is not automatically safe to use because it has a plausible address. It carries fewer guarantees than a Rust reference; dereferencing it needs an independent justification. A `*mut u8` is also not a request to reserve memory. It identifies a location; the linker/target arrangement must establish what lives there. The #link("https://doc.rust-lang.org/reference/types/pointer.html")[Rust Reference on pointer types] distinguishes raw pointers from checked references.

Notice what the function avoids: `&mut _log_start` would manufacture a reference to the declared byte before constructing the wider view, while `&_log_end` would claim a byte exists at the excluded boundary. Direct raw address-taking is the appropriate operation for these linker markers.

== Why calculate length using integers?

```rust
let length = core::ptr::addr_of!(_log_end) as usize - start as usize;
assert_eq!(length, 64 * 1024);
```

`usize` is Rust's address-sized unsigned integer. On this 32-bit target it can represent the addresses involved. Casting each pointer to `usize` lets the function subtract their numerical addresses. It subtracts 0x70000 from 0x80000 and obtains 0x10000, or 65,536. Since the element type is `u8`, the byte count will also be the slice's element count.

You may encounter `pointer.offset_from(other)` elsewhere. Do not substitute it merely because it looks more pointer-oriented. That operation has a same-allocation relationship requirement, beyond simply having two numeric addresses. These are separately declared linker symbols. Their relationship comes from the platform layout, not two ordinary references into a Rust array. Integer address subtraction avoids asserting that particular `offset_from` relationship. See #link("https://doc.rust-lang.org/core/primitive.pointer.html#method.offset_from")[the raw-pointer distance safety requirements].

This is not a trick that proves the resulting range valid. The length assertion can catch an incorrectly sized partition, but two wrong addresses can still be exactly 65,536 bytes apart. The assertion does not establish that the target maps that region, that the firmware stays out, or that another reference has not already been created. A safety argument must include those facts separately.

The function also retains the original start pointer when constructing the slice; it does not cast the computed length or a fresh integer back into a new pointer. Address arithmetic and authorization to access memory are different subjects. Rust calls the association between a pointer and its permitted memory *provenance*. For deeper reading, see #link("https://doc.rust-lang.org/core/ptr/index.html#provenance")[the pointer module's provenance discussion]. Treat this function as an embedded, linker-aware boundary for this exact build, rather than a general recipe for turning arbitrary addresses into references.

== The moment a raw address becomes a reference

The function's final expression is:

```rust
unsafe { core::slice::from_raw_parts_mut(start, length) }
```

This constructs a mutable slice reference using a start pointer and a count. The result can be understood as a pair: “start at 0x70000; there are 65,536 byte elements.” A slice reference carries both the address and length, often called a *fat pointer*. There is still only one underlying log region. A slice is a view, and safe indexing uses its length for bounds checking. See #link("https://doc.rust-lang.org/reference/types/slice.html")[the Rust Reference on slices].

The #link("https://doc.rust-lang.org/core/slice/fn.from_raw_parts_mut.html")[`from_raw_parts_mut` safety contract] requires the range to be valid for reads and writes, non-null, aligned, initialized as the element type, within a single allocation, and exclusively accessed through the returned reference and its derivatives while borrowed. Its size must fit `isize` and not wrap the address space. In this application, `u8` has byte alignment and every possible byte pattern is a valid value; an erased `0xff` byte is valid, as is a byte from an incomplete record. “Initialized as bytes” does not mean “contains a valid log record.”

The significant external assumption is that the embedded target and linker arrangement make the entire reserved flash region available as one usable storage area for this driver. A matching numeric length alone cannot establish that assumption. Rust's general documentation does not magically validate a fabricated memory map. The small unsafe boundary records where that platform knowledge enters the application.

There are two kinds of alignment to keep distinct. A slice of `u8` only needs byte alignment. NVMC erase operations need page alignment, and programming needs word alignment. The larger hardware requirements are supplied by the linker layout, driver checks, and record layout; they do not follow just from the slice element type.

== Decoding the return type

Read `&'static mut [u8]` in pieces:

- `&` means a reference: a borrowed view into existing storage.
- `'static` means the referenced storage can remain valid for the running program's lifetime.
- `mut` grants exclusive mutable access under Rust's borrowing rules.
- `[u8]` means a sequence of bytes whose length travels with the reference.

The lifetime does not allocate storage, extend a local array's life, prevent erasure, or make a saved reading survive power loss. Physical flash supplies persistence. The lifetime describes what the program may assume about the view while it runs. A reset starts a new execution with new reference values, even if the physical bytes remain. See the #link("https://doc.rust-lang.org/book/ch10-03-lifetime-syntax.html")[Rust Book's lifetime discussion].

Exclusivity is the most important caller responsibility. Repeating this function while the first storage view remains in use would create another purportedly exclusive view of the same bytes. Each view's type would look correct in isolation; together they would break the promise. The compiler cannot catch the duplication because the references were manufactured from external addresses.

It is useful to distinguish owning a *handle* from owning the physical memory. `Nvmc` will own the storage reference and peripheral token. The microcontroller still physically contains the flash. Dropping or moving a handle does not move, free, or automatically erase that flash. In this firmware the handle is retained by the running log for the rest of execution.

== Why both unsafe fn and an inner unsafe block?

The function declaration says calling `reserved_flash` has extra obligations. Its implementation, in turn, calls another function with extra obligations: `from_raw_parts_mut`. The inner block records where those obligations are satisfied using the function's contract plus the platform layout. The two `unsafe` spellings operate at different boundaries. See #link("https://doc.rust-lang.org/reference/unsafe-keyword.html")[the Rust Reference's explanation of unsafe functions and blocks].

In edition 2024, the `unsafe_op_in_unsafe_fn` lint warns by default when an unsafe operation inside an unsafe function is not explicitly wrapped in an unsafe block. Thus declaring a whole function unsafe is not a useful reason to omit the small local block. The existing code is explicit about both responsibilities. See the #link("https://doc.rust-lang.org/edition-guide/rust-2024/unsafe-op-in-unsafe-fn.html")[edition guide on unsafe operations in unsafe functions].

The final block is also the function's return expression: it has no trailing semicolon. Its value is the constructed slice. This is ordinary Rust expression syntax; it has no special flash-related behavior.

== The one-time handoff in main

Here is the only application call:

```rust
let flash = Nvmc::new(board.NVMC, unsafe { reserved_flash() });
let mut log = Log::open(flash).expect("Cannot scan flash log");
```

There are two complementary resources. `board.NVMC` is the ownership token for the controller peripheral. `reserved_flash()` supplies the exclusive storage view. The constructor moves both into the driver; `Log::open` then moves that driver into the log. The ownership path is therefore `Board` → `Nvmc` → `Log` for the controller, alongside linker region → slice → `Nvmc` → `Log` for the storage handle.

The comment above this call identifies the key reasons it is allowed: the linker excludes the pages from program data, there is exactly one call, and the driver keeps the view. Making `reserved_flash` private reduces accidental use outside this module, but privacy does not prove uniqueness. A later second call in the same module would still need review.

The current program has no interrupt handler that separately reads or modifies this log partition. If you add one, the original reasoning must be revisited. Taking a peripheral singleton does not automatically protect against arbitrary raw addresses, a debugger, or unrelated code that deliberately bypasses the API.

== What the HAL does below the safe calls

The locked `nrf-hal-common` version is 0.19.0. Its NVMC constructor stores the peripheral token and storage view, checking page alignment and a whole-page length. Its flash trait exposes one-byte reads, four-byte writes, and 4,096-byte erases. The implementation checks ranges/alignment, changes the controller mode, waits for readiness, programs words, and restores read mode. It uses lower-level unsafe code internally, including conversion of aligned byte storage to a word reference. These details come from the project's locally cached dependency source, `nrf-hal-common-0.19.0/src/nvmc.rs`.

Consequently, `Log::append` can call a safe trait method without putting its own register accesses in unsafe blocks. The safety work is concentrated in the driver and initial storage handoff. Moving code behind a safe API is helpful only when that API's implementation and preconditions are correct.

At the hardware level, NVMC has registers controlling access mode and indicating readiness. Programming changes erased one bits into zero bits in aligned 32-bit words; returning bits to one requires erasing a page. Ordinary byte assignment is not a replacement for that sequence and can violate the device's access requirements. Flash operations can also stall instruction execution from flash, which is relevant to this firmware's timing. See #link("https://docs.nordicsemi.com/bundle/ps_nrf52833/page/nvmc.html")[Nordic's nRF52833 NVMC specification].

This explains a superficially surprising point: the returned type is mutable, but application code should not use `storage[index] = value` as its flash-writing algorithm. The type expresses ownership; it does not configure the controller. Use the driver's operation so the access width, mode, completion, and bounds are handled together.

=== Registers, addresses, and volatile access

*Memory-mapped input/output*, abbreviated *MMIO*, means the processor accesses peripheral control registers through addresses. A register is a hardware control or status location, rather than an ordinary variable in your program's RAM. Writing a control bit can start a hardware action; reading a status bit can tell you whether it has finished. A register's address and access width come from the chip specification. The #link("https://docs.rust-embedded.org/book/peripherals/a-first-attempt.html")[Embedded Rust Book's register example] develops this model.

For example, Nordic places NVMC at base address `0x4001e000`. Its `READY` register is at offset `0x400`, hence address `0x4001e400`; `CONFIG` is at offset `0x504`, hence `0x4001e504`. These controller registers are separate from the log data at `0x70000`. Changing a register configures the controller; programming a log address changes stored data. Both use addresses, but the hardware meanings differ.

The cached `nrf52833-pac` source represents registers with generated types. Their accessors use `vcell`, whose implementation performs volatile reads and writes inside small unsafe blocks. This is part of the lower-level foundation supporting the HAL's readable calls such as `config.write(...)` and `ready.read()`.

*Volatile* tells the compiler an access is externally observable, so it cannot casually remove it or combine it as if only ordinary program memory were involved. It does not make an access atomic, establish exclusive ownership, verify the address, wait for flash completion, or rescue an invalid register operation. Those are separate responsibilities. See the #link("https://doc.rust-lang.org/core/ptr/fn.write_volatile.html")[Rust documentation for volatile writes].

The flash driver's actual data-word assignment is a distinct implementation detail; do not infer that every write involved in flash programming is implemented with `write_volatile`. The important learning point is the layering: the application owns the partition, the HAL sequences operations, and the PAC/register access layer talks to the controller. Each layer contributes different guarantees.

== Why ordinary startup does not wipe the log

`memory.x` defines a region and boundary symbols, but creates no loadable log section with initial bytes. There is no Rust `static mut LOG: [u8; 65536] = ...` initializer placed there. The flash log also is not the runtime's RAM `.bss` region, which is normally zeroed at startup, or `.data`, which is populated from an initial image.

`build.rs` copies this project's memory layout into Cargo's build output and makes it available to the linker. That is a host build step. It is not a function running on the micro:bit that clears memory. `reserved_flash` constructs a view, `Nvmc::new` constructs a driver, and `Log::open` scans existing slots. None requests an erase.

That separation is deliberate: adding a loadable initialized array in `LOG`, extending program sections into it, or using a flashing command that erases the whole chip could destroy retained readings. The source layout avoids supplying initial log bytes in the ELF; it cannot constrain every possible programmer/debugger operation. Save important readings before replacing firmware.

== Memory safety and power-loss recovery are separate

Memory safety asks whether accesses obey Rust's rules and stay within the intended storage. Persistence asks what remains after power disappears during an operation. A program can be memory-safe while losing the most recent record. A CRC can reject a corrupted record while doing nothing to repair an invalid pointer.

This project's persistence design uses fresh 64-byte slots, writes the body and checksum first, and writes the `DONE` commit word last. It reads the slot back after appending. At reboot it scans the whole partition, accepts records with the expected markers/version/checksum, and resumes after the last nonblank slot. An incomplete slot is consumed rather than rewritten. These are record-format and recovery decisions in `lib.rs`, not extra powers provided by `unsafe`.

A checksum has a finite number of possible outputs, so collisions are possible. It detects many damaged contents; it is not a mathematical guarantee that every possible corruption will be rejected. Likewise, erase is deliberately explicit and is not transactional: a power failure partway through can leave a mixture of erased and retained pages. Good memory safety reasoning and good durability reasoning support different parts of the program.

== Changes that look harmless but break assumptions

#table(
  columns: (1fr, 2fr),
  table.header([Tempting change], [Why it needs more work]),
  [Call `reserved_flash` again for an exporter.],
  [That creates a second storage view. Export through the existing `Log` instead.],
  [Replace address-taking with reading `_log_end`.],
  [That attempts a byte load beyond flash rather than obtaining a boundary address.],
  [Keep a second raw flash reader beside `Nvmc`.],
  [Access through an independent pointer conflicts with the exclusive view's contract.],
  [Move `LOG` without changing the rest of the layout.],
  [Firmware overlap, size, page alignment, and target mapping must all be rechecked.],
  [Write `0xff` through each byte to clear the log.],
  [Programming cannot restore zero bits to one; use the driver's page erase.],
  [Add an initialized Rust array in the reserved region.],
  [The ELF may then supply bytes that overwrite persistent data when flashing.],
)

An even simpler-looking change is to remove `unsafe` from the helper's signature while keeping the body. That would advertise that any ordinary caller may request another exclusive storage view. A safe, repeatable constructor would need to *enforce* a one-time acquisition rule, for example by consuming a unique ownership capability; changing the keyword alone supplies no enforcement.

Incorrect unsafe code can cause undefined behavior, including invalid accesses or broken aliasing promises. Undefined behavior is not a well-defined error result you can reliably catch with `expect`. The optimizer may rely on reference promises even if the observed hardware happens to tolerate an individual access. See #link("https://doc.rust-lang.org/reference/behavior-considered-undefined.html")[the Rust Reference's discussion of undefined behavior].

== A practical review checklist

Before changing this boundary, answer these questions from the actual target and linked image:

1. Do `_log_start` and `_log_end` still delimit exactly the intended 65,536 bytes?
2. Is the complete half-open range mapped as flash on this chip, with no program section, runtime initializer, or other storage owner overlapping it?
3. Is the start page-aligned, the length a whole number of pages, and the record layout compatible with word-sized writes?
4. Is there one storage acquisition and one driver owning the resulting view? Have any independent readers, interrupt handlers, or raw accesses been added?
5. Does every program/erase operation still go through the controller driver, and does recovery still avoid reusing partially programmed slots?
6. Will the flashing procedure preserve the partition, or have the readings already been exported?

The first four questions support the memory boundary and hardware access assumptions. The last two support retention and recovery. Neither the size assertion nor a passing host-side test can answer all six.

== Check your understanding

*Exercise 1.* If the start is `0x70000` and the end is `0x80000`, how many bytes belong to the log? Is `0x80000` included? _Answer:_ 65,536 bytes; the end is excluded. Subtracting addresses gives the count without an extra `+ 1`.

*Exercise 2.* Does `addr_of!(_log_end)` read saved data? _Answer:_ No. It obtains the marker's address. A value expression reading `_log_end` would be a different operation and is wrong here.

*Exercise 3.* Why is a second call to an argument-free helper dangerous? _Answer:_ It returns another exclusive reference to the same physical region. There are no arguments for the borrow checker to use to connect the calls.

*Exercise 4.* A torn record contains arbitrary bytes. Must the slice construction reject those bytes? _Answer:_ No; arbitrary initialized bytes are valid `u8` values. Record validity is checked later by `decode` using format markers and CRC.

*Exercise 5.* Will changing the return lifetime to `'static` make a stack array permanent? _Answer:_ No. A lifetime annotation expresses a validity requirement; it does not create storage. This helper relies on physically mapped flash and a linker reservation, not a local array.

*Exercise 6.* What changes the bits: constructing the slice, calling `Log::open`, or appending/clearing through the driver? _Answer:_ Only the requested programming or erase operations change the log. Constructing views and scanning are separate operations.
