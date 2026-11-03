# micro-log

Record the micro:bit V2's built-in accelerometer and magnetometer to flash, then
retrieve the readings as CSV after disconnecting its power. No extra hardware or
wiring is needed.

For a complete code and hardware walkthrough, including the unsafe flash-memory
code, see the [Typst learning guide](docs/guide.typ) or its
[compiled PDF](../../output/pdf/micro-log-guide.pdf). The
[document README](docs/README.md) explains how to rebuild it.

RAM holds working values while a program runs and loses them when power is
removed. Flash keeps its contents without power. This project sets aside the last
64 KiB of the nRF52833's flash for a log, separate from the program itself.

This is a Rust example with its own storage format and USB serial export. The
`MY_DATA.HTM` viewer used by MakeCode and MicroPython is a separate logging
feature; this project does not create that file.

## Build and flash

Run these commands from the workspace root, with a micro:bit V2 connected by USB:

```sh
cargo build-log --profile firmware
cargo flash-log -- --profile firmware
```

The firmware starts **paused** after every reset. It scans the existing log and
keeps previously saved samples. On the first run, the reserved area might contain
data left by an earlier program, so clear it using the gesture below before your
first recording.

## Controls

| Action | Result |
| --- | --- |
| Press A | Start or pause recording at one sample per second. |
| Press B | Pause recording and export all saved samples over USB serial. |
| Send lowercase `d` over USB serial | Pause and export, as the included script does. |
| Hold A+B while powering on or resetting, keep held for two seconds, then release | Erase the log. |

The LEDs show pause bars when paused, a square while recording, and an X when
full. Exporting also pauses recording.

Each saved sample includes a session number, time since the firmware started, and
three acceleration and three magnetic-field readings. Acceleration is in `mg`
(1,000 mg = 1 g), and magnetic field is in `nT` (1,000 nT = 1 µT). Magnetic readings
are measurements from the sensor, without compass calibration. Nearby metal,
magnets, and currents in the board (including its LEDs) can affect them. Both
sensors run at 10 Hz; each logged row reads their latest independent conversions.

The reserved space holds **1,024 samples**, about **17 minutes at 1 Hz**. Recording
stops when full, keeping the existing data until you explicitly erase it. A
damaged slot from an interrupted write also uses space.

## Export a CSV

Run the export script with [UV](https://docs.astral.sh/uv/). It manages the
project's environment and installs its `click` and `pyserial` dependencies:

```sh
uv sync --project projects/micro-log
```

Connect the micro:bit by USB. On macOS, list its serial port:

```sh
ls /dev/cu.usbmodem*
```

Use the matching port in the export command:

```sh
uv run --project projects/micro-log python projects/micro-log/export.py /dev/cu.usbmodem123 --output readings.csv
```

Replace the example port with yours. Linux ports are commonly `/dev/ttyACM0`;
Windows ports look like `COM3`. Close any serial monitor that is using the port.
The script uses 115,200 baud and sends `d`, so there is no need to press B.

The script checks the header and each row, waits for the completion marker, and
only then publishes the CSV. It refuses to overwrite an existing output file;
choose a new name for another export. A disconnect or 20 seconds without data
causes an error and leaves no incomplete CSV. Exporting leaves recording paused.

Open the resulting file in a spreadsheet or another analysis tool. Its columns
are:

```csv
session,uptime_ms,acc_x_mg,acc_y_mg,acc_z_mg,mag_x_nt,mag_y_nt,mag_z_nt
```

## Prove that the readings survive a power-off

1. Clear the log with the A+B startup gesture, then release both buttons.
2. Press A, move or rotate the board for a few seconds, then press A to pause.
3. Disconnect USB **and any battery pack**, so the board has no power.
4. Reconnect USB. The firmware starts paused; **do not flash it again**.
5. Run the export script. The samples you collected before unplugging should be
   present in `readings.csv`.
6. Press A to collect more samples, pause again, and export to a different file.
   The export contains both recordings, with a new session number for the samples
   taken after restarting the board.

Time is measured since firmware startup, with 125 ms resolution from an 8 Hz
clock. It is not a date or wall-clock time, does not advance while power is off,
and wraps after about 24 days. The session number increases on a restart when
previously saved samples exist, so a new timestamp origin can be distinguished
from an older recording. Empty restarts do not need to create saved sessions.

## How persistence works

`memory.x` limits the program to the first 448 KiB and reserves addresses
`0x70000..0x80000` for logging. This region has no initial data in the firmware
image, so loading the program does not intentionally fill it with defaults.

`src/lib.rs` implements the log format and append/recovery logic. Each 64-byte row
has a checksum and a separate commit word written last. After a reset, incomplete
or corrupt rows are ignored and their slots are left consumed. Valid earlier
rows remain readable; losing power during a write can lose that latest sample.

`src/main.rs` reads the sensor, handles the buttons and sampling timer, and sends
CSV through the board's USB serial connection. The wire format starts with
`# BEGIN MICRO_LOG`, followed by the header and rows, and ends with
`# END MICRO_LOG`. Other status lines start with `#`. A flash read failure does
not send the end marker, so the script can reject an incomplete export.

Flash writes can change bits from 1 to 0; erasing resets a whole 4 KiB page to
ones. The logger appends to unused slots instead of erasing for every sample,
which reduces wear. Erasing is explicit, and interruption during an erase can
leave a partly cleared log: repeat the A+B startup gesture to finish clearing it.

Saved samples survive power-offs, but changing firmware, a full chip erase, or a
recovery/unlock operation can remove them. Export anything you want to keep
before reprogramming the board.

Run the storage recovery tests from the workspace root:

```sh
cargo test -p micro-log --lib
```

The firmware builds and the storage tests pass, but its
sensor, button, power-cycle, and USB behavior still need verification on a real
micro:bit V2.

## References

- [micro:bit data logging guide](https://microbit.org/get-started/user-guide/data-logging/)
  describes the MakeCode/Python experience and persistent logging.
- [Nordic nRF52833 memory](https://docs.nordicsemi.com/r/bundle/ps_nrf52833/page/memory.html)
  documents its 512 KiB flash and 4 KiB pages.
- [Nordic NVMC](https://docs.nordicsemi.com/r/bundle/ps_nrf52833/page/nvmc.html)
  explains word writes, page erasure, and flash programming restrictions.
