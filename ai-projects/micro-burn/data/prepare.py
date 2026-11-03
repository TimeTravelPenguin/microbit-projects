# /// script
# requires-python = ">=3.11"
# dependencies = ["click>=8,<9"]
# ///
"""Prepare the versioned Czech classroom data without changing its source files."""

from __future__ import annotations

import hashlib
import io
import json
import posixpath
import urllib.request
import xml.etree.ElementTree as ET
import zipfile
from collections import Counter
from pathlib import Path
from typing import Any, TypeAlias

import click

Cell: TypeAlias = str | int | float | None
Rows: TypeAlias = list[list[Cell]]
NS = {"sheet": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}
DATASET_DOI = "10.17632/9c3dth6cwp.3"
SOURCES = {
    "student attributes.xlsx": {
        "file_id": "ba8e3ea1-b4c4-4f0d-9d38-781545ca72fd",
        "sha256": "c75a240be84c07277f45a92e6b76c7f037149fbd66db5e5520354a0d31d14d0d",
    },
    "relational data.xlsx": {
        "file_id": "b32aa4ea-cfb2-438b-bf58-dbf36f75d7bb",
        "sha256": "9df3435c113ea62a879ab4588201985da0b08707a8d374d1778cf7c490b5953b",
    },
}


def column_index(reference: str) -> int:
    index = 0

    for char in reference:
        if not char.isalpha():
            break

        index = index * 26 + ord(char.upper()) - ord("A") + 1

    return index - 1


def read_workbook(payload: bytes) -> dict[str, Rows]:
    with zipfile.ZipFile(io.BytesIO(payload)) as archive:
        strings: list[str] = []

        if "xl/sharedStrings.xml" in archive.namelist():
            root = ET.fromstring(archive.read("xl/sharedStrings.xml"))
            strings = [
                "".join(item.itertext())
                for item in root.findall("sheet:si", NS)
            ]

        relationships = ET.fromstring(archive.read("xl/_rels/workbook.xml.rels"))
        targets = {
            item.attrib["Id"]: item.attrib["Target"]
            for item in relationships
        }

        workbook = ET.fromstring(archive.read("xl/workbook.xml"))
        sheets: dict[str, Rows] = {}

        for sheet in workbook.findall("sheet:sheets/sheet:sheet", NS):
            relation = sheet.attrib[
                "{http://schemas.openxmlformats.org/officeDocument/2006/relationships}id"
            ]
            target = targets[relation]
            path = target.lstrip("/") if target.startswith("/") else posixpath.normpath(
                posixpath.join("xl", target)
            )
            root = ET.fromstring(archive.read(path))
            rows: Rows = []

            for row in root.findall("sheet:sheetData/sheet:row", NS):
                values: list[Cell] = []

                for cell in row.findall("sheet:c", NS):
                    index = column_index(cell.attrib["r"])
                    values.extend([None] * (index + 1 - len(values)))
                    value = cell.findtext("sheet:v", namespaces=NS)
                    kind = cell.attrib.get("t")

                    if kind == "s" and value is not None:
                        parsed: Cell = strings[int(value)]
                    elif kind == "inlineStr":
                        parsed = "".join(cell.find("sheet:is", NS).itertext())
                    elif value is None:
                        parsed = None
                    elif kind in ("str", "e"):
                        parsed = value
                    else:
                        number = float(value)
                        parsed = int(number) if number.is_integer() else number

                    values[index] = parsed

                if any(value is not None for value in values):
                    rows.append(values)

            sheets[sheet.attrib["name"]] = rows

    return sheets


def source_url(file_id: str) -> str:
    return (
        "https://data.mendeley.com/public-files/datasets/9c3dth6cwp/files/"
        f"{file_id}/file_downloaded"
    )


def load_source(raw_dir: Path, filename: str, download: bool) -> bytes:
    path = raw_dir / filename
    metadata = SOURCES[filename]

    if not path.exists():
        if not download:
            raise click.ClickException(f"Missing {path}; rerun with --download")

        request = urllib.request.Request(
            source_url(metadata["file_id"]),
            headers={"User-Agent": "micro-burn-dataset-preparation/1"},
        )

        with urllib.request.urlopen(request, timeout=60) as response:
            payload = response.read()

        raw_dir.mkdir(parents=True, exist_ok=True)
        path.write_bytes(payload)

    payload = path.read_bytes()
    digest = hashlib.sha256(payload).hexdigest()

    if digest != metadata["sha256"]:
        raise click.ClickException(f"Checksum mismatch for {filename}: {digest}")

    return payload


def valid_grade(value: Cell) -> bool:
    return isinstance(value, (float, int)) and 1 <= value <= 5


def prepare(raw_dir: Path, download: bool, seed: int) -> dict[str, Any]:
    attributes = read_workbook(load_source(raw_dir, "student attributes.xlsx", download))
    networks = read_workbook(load_source(raw_dir, "relational data.xlsx", download))
    rows = attributes["attributes"]
    headers = rows[1]
    records = {
        str(row[0]): dict(zip(headers, row + [None] * (len(headers) - len(row))))
        for row in rows[2:]
        if row[0] is not None
    }

    if len(records) != 276:
        raise click.ClickException("Unexpected source population or duplicate student IDs")

    graphs: list[dict[str, Any]] = []
    excluded: list[dict[str, Any]] = []
    seen_ids: set[str] = set()

    for classroom_id in (f"{index:02d}" for index in range(1, 13)):
        rows = networks[f"{classroom_id}start"]
        student_ids = [str(value) for value in rows[0][1:]]
        body = [row for row in rows[1:] if row and row[0] is not None]

        if student_ids != [str(row[0]) for row in body]:
            raise click.ClickException(f"Network row/column ID mismatch in {classroom_id}")

        matrix = {str(row[0]): row[1:] for row in body}
        kept: list[str] = []

        for student_id in student_ids:
            record = records[student_id]
            nominations = matrix[student_id]
            reasons: list[str] = []

            if record["classroomID"] != classroom_id:
                raise click.ClickException("Attribute/network classroom mismatch")

            if not valid_grade(record["grade_start"]) or not valid_grade(record["grade_end"]):
                reasons.append("missing_grade")

            if all(value is None for value in nominations):
                reasons.append("missing_baseline_nomination_row")
            elif len(nominations) != len(student_ids) or any(
                value not in (0, 1) for value in nominations
            ):
                raise click.ClickException("Unexpected partial/malformed nomination row")

            if reasons:
                excluded.append({"student_id": student_id, "reasons": reasons})
            else:
                kept.append(student_id)

        seen_ids.update(student_ids)
        positions = {student_id: index for index, student_id in enumerate(student_ids)}
        edges = [
            [source, target]
            for source, source_id in enumerate(kept)
            for target in range(source + 1, len(kept))
            if matrix[source_id][positions[kept[target]]] == 1
            or matrix[kept[target]][positions[source_id]] == 1
        ]

        graphs.append({
            "classroom_id": classroom_id,
            "classroom_type": records[kept[0]]["classroom_type"],
            "student_ids": kept,
            "features": [[float(records[student_id]["grade_start"])] for student_id in kept],
            "targets": [float(records[student_id]["grade_end"]) for student_id in kept],
            "edges": edges,
        })

    if seen_ids != set(records):
        raise click.ClickException("Attribute/network participant populations differ")

    split: dict[str, list[str]] = {"train": [], "validation": [], "test": []}

    for classroom_type in ("experimental", "control"):
        classroom_ids = [
            graph["classroom_id"]
            for graph in graphs
            if graph["classroom_type"] == classroom_type
        ]
        classroom_ids.sort(key=lambda classroom_id: hashlib.sha256(
            f"micro-burn-split-v1:{seed}:{classroom_id}".encode()
        ).digest())

        if len(classroom_ids) != 6:
            raise click.ClickException("Unexpected classroom-type grouping")

        split["train"].extend(classroom_ids[:4])
        split["validation"].extend(classroom_ids[4:5])
        split["test"].extend(classroom_ids[5:])

    for split_name, classroom_ids in split.items():
        classroom_ids.sort()

        for graph in graphs:
            if graph["classroom_id"] in classroom_ids:
                graph["split"] = split_name

    return {
        "schema_version": 1,
        "source": {
            "doi": DATASET_DOI,
            "version": 3,
            "license": "CC-BY-4.0",
            "url": "https://data.mendeley.com/datasets/9c3dth6cwp/3",
            "files": [{"filename": filename, **metadata} for filename, metadata in SOURCES.items()],
        },
        "preprocessing": {
            "feature_names": ["grade_start"],
            "target_name": "grade_end",
            "network_wave": "start",
            "edge_semantics": "undirected union of observed baseline nominations; indices local to graph",
            "normalization": "none; fit any scaling on training graphs in app",
            "excluded_students": excluded,
            "split_seed": seed,
            "split_method": "sha256(micro-burn-split-v1:seed:classroom_id), four/one/one per classroom_type",
        },
        "split": split,
        "graphs": graphs,
    }


@click.command()
@click.option("--raw-dir", type=click.Path(path_type=Path), default=Path(__file__).parent / "raw")
@click.option("--output", type=click.Path(path_type=Path), default=Path(__file__).parent / "classrooms.json")
@click.option("--download", is_flag=True, help="Fetch missing public source workbooks and verify checksums.")
@click.option("--seed", type=int, default=42, show_default=True)
def main(raw_dir: Path, output: Path, download: bool, seed: int) -> None:
    dataset = prepare(raw_dir, download, seed)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(dataset, indent=2, ensure_ascii=False) + "\n")
    counts = Counter(graph["split"] for graph in dataset["graphs"])
    node_counts = Counter[str]()

    for graph in dataset["graphs"]:
        node_counts[graph["split"]] += len(graph["student_ids"])

    click.echo(json.dumps({"graphs": counts, "students": node_counts, "split": dataset["split"]}))


if __name__ == "__main__":
    main()
