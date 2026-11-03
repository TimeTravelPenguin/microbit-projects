# Prepared classroom graphs

`classrooms.json` is derived from:

Lintner, Tomáš; Sedova, Klara; Sedláček, Martin; Šalamounová, Zuzana; Švaříček,
Roman; Malíková, Karolína; Rozmahel, Ivo; Vlček, Jakub; Nekardová, Barbora (2024),
“Relational and interactional dynamic network data from Czech lower-secondary
school students”, Mendeley Data, version 3,
[doi:10.17632/9c3dth6cwp.3](https://doi.org/10.17632/9c3dth6cwp.3).

Source licence: [Creative Commons Attribution 4.0 International](https://creativecommons.org/licenses/by/4.0/).
The authors do not endorse this application. Changes: select baseline grade and
later-grade target, exclude missing baseline nomination rows, retain induced
classroom graphs, symmetrize observed nominations, and assign a deterministic
classroom-held-out split. See [the audit](../DATA_AUDIT.md).

The JSON contains twelve graphs with `classroom_id`, `classroom_type`, `split`,
`student_ids`, `features`, `targets`, and `edges`. Feature order is
`[grade_start]`. Each edge is stored once as `[source_index, target_index]`, with
`source_index < target_index`. Both directions and self-loops are added by the
model input preparation. Raw numeric grades are retained without normalization.
Provenance, exact split IDs and excluded records are embedded in the JSON.

Regenerate using `uv run data/prepare.py --download`. Raw workbooks are verified
against their recorded SHA-256 checksums and stored in ignored `raw/`.
