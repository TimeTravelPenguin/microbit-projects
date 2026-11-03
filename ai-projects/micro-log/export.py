#!/usr/bin/env python3
"""Request a complete micro-log CSV over the micro:bit's USB serial port."""

import csv
import os
import tempfile
import time
from collections.abc import Iterable, Iterator
from pathlib import Path
from typing import IO

import click
from serial import Serial

BAUD_RATE = 115200
IDLE_TIMEOUT = 20
BEGIN_MARKER = "# BEGIN MICRO_LOG"
END_MARKER = "# END MICRO_LOG"
HEADER = [
    "session",
    "uptime_ms",
    "acc_x_mg",
    "acc_y_mg",
    "acc_z_mg",
    "mag_x_nt",
    "mag_y_nt",
    "mag_z_nt",
]


def read_lines(connection: Serial, idle_timeout: float) -> Iterator[str]:
    """Read complete ASCII lines, timing out when the serial stream goes idle."""
    last_data = time.monotonic()

    while True:
        raw_line = connection.readline()
        if not raw_line:
            if time.monotonic() - last_data >= idle_timeout:
                raise TimeoutError(
                    f"No serial data for {idle_timeout:g} seconds; the export did not finish. No CSV was saved."
                )

            continue

        last_data = time.monotonic()
        if not raw_line.endswith(b"\n"):
            raise ValueError("Incomplete serial line; no CSV was saved.")

        yield raw_line.decode("ascii").rstrip("\r\n")


def write_csv(lines: Iterable[str], destination: IO[str]) -> int:
    """Validate a framed export and write its CSV, returning the sample count."""
    writer = csv.writer(destination)
    started = False
    header_received = False
    row_count = 0

    for line in lines:
        if not started:
            if line == BEGIN_MARKER:
                started = True

            continue

        if line == BEGIN_MARKER:
            raise ValueError(
                "The board restarted the export before it finished."
            )

        if line == END_MARKER:
            if not header_received:
                raise ValueError("The export ended without its CSV header.")

            return row_count

        if line.startswith("#"):
            continue

        fields = next(csv.reader([line], strict=True))
        if not header_received:
            if fields != HEADER:
                raise ValueError(f"Unexpected CSV header: {line!r}")

            writer.writerow(HEADER)
            header_received = True
            continue

        if len(fields) != len(HEADER):
            raise ValueError(f"Expected eight CSV fields: {line!r}")

        try:
            values = [int(field, 10) for field in fields]
        except ValueError as error:
            raise ValueError(
                f"Expected integer sensor data: {line!r}"
            ) from error

        writer.writerow(values)
        row_count += 1

    raise ValueError("The export ended without its completion marker.")


def capture_log(
    connection: Serial,
    output: str | Path,
    idle_timeout: float = IDLE_TIMEOUT,
) -> int:
    """Pause logging, capture one framed CSV, and publish it only when complete."""
    output = Path(output)
    if output.exists() or output.is_symlink():
        raise FileExistsError(
            f"Refusing to overwrite {output}; choose another --output."
        )

    if not output.parent.is_dir():
        raise FileNotFoundError(
            f"Output directory does not exist: {output.parent}"
        )

    connection.reset_input_buffer()
    connection.write(b"d")
    connection.flush()

    temp_path: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w",
            encoding="ascii",
            newline="",
            dir=output.parent,
            prefix=f".{output.name}.",
            suffix=".tmp",
            delete=False,
        ) as temp_file:
            temp_path = Path(temp_file.name)
            row_count = write_csv(
                read_lines(connection, idle_timeout), temp_file.file
            )

            temp_file.flush()
            os.fsync(temp_file.fileno())

        # Install the complete file atomically, refusing even a concurrent overwrite.
        os.link(temp_path, output)
        return row_count
    finally:
        if temp_path is not None:
            temp_path.unlink(missing_ok=True)


@click.command(context_settings={"help_option_names": ["-h", "--help"]})
@click.argument("port")
@click.option(
    "--output",
    type=click.Path(path_type=Path),
    default="readings.csv",
    show_default=True,
    help="New CSV file to create; existing files are refused.",
)
@click.pass_context
def main(ctx: click.Context, port: str, output: Path) -> None:
    """Request a complete micro-log CSV over the micro:bit's USB serial port.

    PORT is the USB serial port, e.g. /dev/cu.usbmodem123 or COM3.
    """

    try:
        with Serial(port, BAUD_RATE, timeout=1, write_timeout=5) as connection:
            row_count = capture_log(connection, output)

    except (OSError, ValueError, csv.Error) as error:
        click.echo(f"Export failed: {error}", err=True)
        ctx.exit(1)

    except KeyboardInterrupt:
        click.echo("Export cancelled; no CSV was saved.", err=True)
        ctx.exit(130)

    click.echo(f"Saved {row_count} samples to {output}", err=True)


if __name__ == "__main__":
    main()
