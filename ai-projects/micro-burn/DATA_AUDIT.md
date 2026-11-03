# Czech classroom data audit

Completed 2026-11-03 against Mendeley dataset `9c3dth6cwp`, version 3,
DOI [10.17632/9c3dth6cwp.3](https://doi.org/10.17632/9c3dth6cwp.3).
The proposed temporal grade-prediction task is supported by the raw files.

## Verified schema and alignment

`student attributes.xlsx`, sheet `attributes`, has grouped headings in row 1,
field names in row 2, and 276 unique student records. Relevant fields are
`studentID`, `classroomID`, `classroom_type`, `literacy_start`, `literacy_end`,
`grade_start`, and `grade_end`. IDs are strings: preserve their leading zeros.
Trailing formatted blank rows are not student records.

`relational data.xlsx` has `01start`/`01end` through `12start`/`12end` sheets.
The first row and first column identify students. In every baseline matrix, row
and column order match exactly; the union of participant IDs equals the attribute
table, with no duplicates or cross-classroom mismatches. Extra formatted blank rows
in two sheets must not enlarge the graph.

Populated nomination cells are exclusively 0 or 1. Twenty-six baseline rows are
wholly blank. The preparation conservatively excludes those students instead of
turning unknown nominations into negative observations. The induced graph retains
an undirected edge whenever either retained student nominated the other at baseline.

Both grade fields are absent only for student `1009`, whose baseline nomination row
is also blank. Grades use 1 best to 5 worst; the observed later grades span 1–4.
Baseline literacy is missing for 55 students and includes legitimate negative
values. Version one therefore uses **only `grade_start` as its node feature**.
No imputation is needed, and no later fields or networks enter the model inputs.

## Prepared dataset and split

The complete-case preparation retains **250 students and 1,173 undirected edges**
across all twelve classrooms. Exclusions and reasons are retained in
`data/classrooms.json`. Each edge is a unique pair of zero-based local node indices;
the app adds both directions and self-loops before adjacency normalization.

Classroom grouping is frozen before model tuning. Within each of the source's
experimental/control groups, order classroom IDs by
`SHA256("micro-burn-split-v1:42:" + classroomID)` and take four/one/one for
training/validation/test. This balances source intervention type across splits;
it is not a published benchmark split. School IDs are not supplied in this table.

| Split | Classroom IDs | Students | Graphs |
| --- | --- | ---: | ---: |
| Training | 01, 03, 04, 06, 08, 10, 11, 12 | 166 | 8 |
| Validation | 02, 07 | 40 | 2 |
| Test | 05, 09 | 44 | 2 |

Fit any feature scaling only on training students. Evaluate MSE/MAE/RMSE with actual
student-count weighting, rather than giving each classroom equal weight. Keep the
test set separate during model selection. Complete-case filtering and the small
number of classrooms limit interpretation of any apparent improvement.

## Provenance and reproduction

Raw inputs are kept under ignored `data/raw/`. Prepared JSON is redistributed with
attribution and is a transformation of the source under CC BY 4.0. The source
workbooks were read without changes. Their version-specific file IDs and SHA-256
hashes are embedded in the JSON and verified by `data/prepare.py`.

| Source | SHA-256 |
| --- | --- |
| student attributes.xlsx | `c75a240be84c07277f45a92e6b76c7f037149fbd66db5e5520354a0d31d14d0d` |
| relational data.xlsx | `9df3435c113ea62a879ab4588201985da0b08707a8d374d1778cf7c490b5953b` |
| codebook.pdf, inspected for scope | `48dd12d205aca13043c1536480fdba882486b7d4e2682ef9c508b7228d0a76d5` |
| prepared classrooms.json | `385a6e63da41c27ab331da307e078c0280a62a8bbdc3a42e436a985856bbc7df` |

The codebook concerns verbal group-work coding and supplies no replacement for
the explicit friendship matrices or grade fields. Interactional data and end-wave
friendship matrices are not used by the preparation.

Regenerate from the project directory:

```sh
uv run data/prepare.py --download
```

The PEP 723 script declares Click, checks both source hashes, parses the original
XLSX XML with the Python standard library, and writes deterministic JSON. No
spreadsheet runtime is required by the Rust application. A checksum mismatch or
unexpected schema fails preparation rather than guessing a new interpretation.

