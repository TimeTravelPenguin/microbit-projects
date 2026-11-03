= The computer side: export.py

== Where this program runs

The Rust firmware executes on the micro:bit. `export.py` executes on your
computer, using the computer's operating system to open a serial device and
create a file. Python has ordinary process memory and a filesystem here; the
micro:bit does not acquire a filesystem just because Python creates a CSV.
The two programs agree on a small text protocol.

All imports are at the top. `csv`, `os`, `tempfile`, `time`, `pathlib`,
`collections.abc`, and `typing` come from Python. Click and PySerial are external
dependencies declared in `pyproject.toml`. The imported name `Serial` comes from
the distribution named `pyserial`, not from an unrelated package named `serial`.
UV resolves the declared dependencies and runs the script in the project's
environment. There is no longer a manual “try importing, then tell the user to
install it” branch. See the official
#link("https://docs.astral.sh/uv/guides/projects/")[UV project guide].

From the workspace root, this command shows the interface without opening a
device:

```sh
uv run --project projects/micro-log \
  python projects/micro-log/export.py --help
```

For an actual export, replace the example port with the connected board's port:

```sh
uv run --project projects/micro-log \
  python projects/micro-log/export.py \
  /dev/cu.usbmodem123 --output readings.csv
```

The `.venv` directory is an installed environment, not source code. The lockfile
records a dependency resolution; it is not a sensor log. Python type hints
describe expected values for readers and type checkers. They do not validate
bytes received from the micro:bit; the explicit CSV checks do that work.

== The type hints are a map of the data flow

#table(
  columns: (1.25fr, 2fr),
  table.header([Annotation], [Meaning in this script]),
  [`Serial`], [An open serial-port object that supplies reads, writes, flushing, and buffer reset.],
  [`Iterator[str]`], [A producer that yields one decoded line at a time and remembers where it stopped.],
  [`Iterable[str]`], [Anything the CSV validator can loop over for text lines; it need not be a pre-built list.],
  [`IO[str]`], [A writable text-file interface. CSV output is text, whereas serial input initially consists of bytes.],
  [`str | Path`], [The capture function accepts either a path string or a Path object and normalises it to Path.],
  [`Path | None`], [A temporary path may not exist yet if creation fails. None represents that state explicitly.],
  [`-> int`], [The function returns the number of sensor records written; the header is not counted.],
  [`-> None`], [The command callback does its work through I/O and reports no ordinary return value.],
)

The stream is intentionally lazy. Creating `read_lines(connection, timeout)`
does not read the entire device into RAM. `write_csv` asks that iterator for the
next line; the generator reads until it can yield one, pauses at `yield`, and
resumes when asked again. This keeps memory use independent of log length.

== read_lines: bytes, text, and two timeouts

The serial port is opened with a one-second *read timeout*. That gives each
read an opportunity to return instead of hanging forever. Separately,
`read_lines` applies a default 20-second *idle timeout* across reads that return
no bytes. These are different controls. A complete export can take more than
20 seconds if data keeps arriving.

```python
last_data = time.monotonic()

while True:
    raw_line = connection.readline()
    if not raw_line:
        if time.monotonic() - last_data >= idle_timeout:
            raise TimeoutError(...)

        continue
```

This excerpt abbreviates only the long error message. `time.monotonic()` measures
elapsed time without using calendar time. The comparison is a duration in
seconds, not a date. Every non-empty read resets `last_data`, including a
preamble or status comment. Consequently this is not a total transfer deadline:
a source that continually sends irrelevant complete lines can keep the wait
alive.

PySerial's timeout can also cause a read to return only part of a line. This
script deliberately rejects a non-empty result without a final newline rather
than silently treating it as a complete record. It next decodes strict ASCII
and removes the line-ending CR and LF characters. A byte outside ASCII raises
a decoding error. A partial or non-ASCII preamble is rejected too: validation of
the transport line happens before the framing parser sees it. The
#link("https://pyserial.readthedocs.io/en/latest/pyserial_api.html")[PySerial API]
describes the read-timeout and serial-buffer operations used here.

The prefix `b` in `b"d"` and `b"\n"` means *bytes*. The value `"d"` is instead
Python text. The program sends bytes over the serial connection and writes
text through the CSV writer. Calling `.decode("ascii")` is the explicit boundary
between those representations.

== write_csv: the framing state machine

The firmware sends this envelope:

```text
# BEGIN MICRO_LOG
session,uptime_ms,acc_x_mg,acc_y_mg,acc_z_mg,mag_x_nt,...
1,1000,0,0,1000,125,-23456,34567
# END MICRO_LOG
```

The header line above is shortened for the page; the script checks all eight
column names exactly, including the three magnetic axes. The full header is in
the source listing and the resulting CSV.

The two booleans `started` and `header_received` describe three useful states:

#table(
  columns: (0.95fr, 1.25fr, 1.8fr),
  table.header([State], [Expected input], [What happens]),
  [Waiting for BEGIN], [Any valid text line], [Ignore it until it equals the exact BEGIN marker.],
  [Waiting for header], [The exact CSV header], [Ignore ordinary `#` comments. Reject END without a header. Validate and write the header once.],
  [Reading rows], [Eight integers or END], [Validate, normalise, and write each row. Return the row count only after END.],
)

A second BEGIN after the first BEGIN is an error. It could indicate another
export starting before the first completed. Ordinary lines beginning with `#`
are ignored inside a frame, but the two special markers are checked *before*
the generic comment rule. If comments were checked first, END would be discarded
and the export would never finish.

The CSV parser uses `strict=True`, so malformed quoting is rejected. The first
non-comment CSV line must equal `HEADER`. Later rows must have eight fields,
and every field must convert through `int(field, 10)`. A value such as `001000`
is written as `1000`; the numerical value is preserved, not its original
spelling. The result is produced by `csv.writer`, not by joining strings with
commas yourself.

The function returns a count when it sees a valid END. If a finite iterable runs
out first, it raises an error about the missing completion marker. The live
serial generator normally stops through an I/O error or timeout instead of
normal iterator exhaustion. Supporting a general `Iterable[str]` also makes
the validator easy to exercise with a short list of sample lines.

#block(fill: rgb("fff7e8"), inset: 10pt, breakable: true)[
  *What the text protocol cannot prove.* Eight integer fields and an END marker
  show that this parser accepted a complete-looking frame. The text protocol
  contains no expected row count or transfer checksum. If an entire valid row
  disappeared in transport, this script would not detect its absence. Flash
  CRC checks happen on the board before formatting; they are not a checksum
  over the USB export. The framing protocol is useful for this demo without
  being a general reliable-file-transfer protocol.
]

== capture_log: prepare, request, receive, publish

This function owns the file lifecycle. It first converts the output argument to
`Path`. It refuses an existing destination, including a dangling symbolic link,
and requires the destination directory to exist. These checks happen before
sending a command, so an obviously unusable output path does not start an
export on the board.

It then clears stale received bytes, sends `b"d"`, and flushes the serial
transmitter. Clearing the input buffer discards old startup or earlier-export
text, not the board's flash log. Sending `d` makes the firmware pause and begin
a fresh framed export. The script does not remotely erase flash.

The temporary file is created in the *destination's directory*. That keeps it
on the same filesystem as the final path, which matters to the hard-link step.
Its unpredictable name begins with the intended filename and ends in `.tmp`.
`mode="w"` and `encoding="ascii"` specify text output. `newline=""` lets the
CSV writer manage line endings. `delete=False` keeps the pathname available
after closing; the outer `finally` handles deletion. Python's
#link("https://docs.python.org/3.12/library/tempfile.html#tempfile.NamedTemporaryFile")[NamedTemporaryFile documentation]
explains these lifetime controls.

The temporary-file object is a wrapper. `temp_file.file` is its underlying text
file, which fits the `IO[str]` annotation accepted by `write_csv`. The nested
call connects the serial-line iterator directly to the CSV validator:

```python
row_count = write_csv(
    read_lines(connection, idle_timeout), temp_file.file
)
```

Returning from that call means the parser saw END. Only then does capture flush
Python's file buffer and call `os.fsync` on the file descriptor. After the file
is closed, `os.link(temp_path, output)` adds the final pathname for the already
written contents. It fails if another file appeared at the destination between
the earlier existence check and this operation. That final check is essential:
“I checked that it did not exist a moment ago” is not protection against a
concurrent creator.

The temporary name is unlinked in `finally`, on success and on failure. A hard
link means the two names referred to the same file contents; deleting the
temporary name leaves the final name intact. A malformed capture, or an
interruption before publication, does not acquire the final name. Once
`os.link` succeeds, the complete file can remain even if cleanup or reporting
is interrupted. This assumes a filesystem that supports
hard links; an unsupported filesystem raises an error. The program syncs file
contents but does not explicitly sync the containing directory, so do not
interpret atomic publication as a guarantee against every possible computer
power failure. See Python's
#link("https://docs.python.org/3.12/library/os.html#os.link")[os.link] and
#link("https://docs.python.org/3.12/library/os.html#os.fsync")[os.fsync] contracts.

There are three distinct meanings of *flush* here. Serial flush waits for
outgoing serial data. Text-file flush moves Python-buffered data towards the
operating system. File `fsync` asks the operating system to synchronise that
file's data. None of them tells the micro:bit to erase or append a record.

== main: the Click command and error boundary

`@click.command` turns the function into a command. `@click.argument("port")`
requires a positional port. `@click.option` supplies an optional output path
defaulting to `readings.csv`; `click.Path(path_type=Path)` creates a Path object
for the callback. `@click.pass_context` supplies the `ctx` parameter, which is
used to set explicit process exit codes.

The `with Serial(...)` block opens the port at 115,200 baud with a one-second
read timeout and a five-second write timeout, then closes it when leaving the
block. This closure still happens when capture raises an error. The `try`
around it catches operating-system, CSV, and value errors. Those cases print
an explanation to standard error and exit with code 1. Cancellation prints a
specific message and exits with code 130. Success prints the saved sample
count to standard error and normally exits with code 0. Returning `1` from a
Click callback would not set the process exit code; `ctx.exit(1)` does.

The bottom guard, `if __name__ == "__main__":`, runs the command when the file
is executed as a script. Importing it to inspect or exercise `read_lines`,
`write_csv`, or `capture_log` does not open a serial port. Importing still
requires the declared third-party packages, which is appropriate for the
UV-managed project.

== Compare the two completion markers

The flash commit word `DONE` belongs to *one binary record*. It is programmed
after that record's payload and checksum. The text `# END MICRO_LOG` belongs to
*one export session*. It is printed after the firmware has visited the occupied
slots. Python's final hard-link publication belongs to *one host file*. Each
marker answers a different question, and each layer has its own failure modes.
