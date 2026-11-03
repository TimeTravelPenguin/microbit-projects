# Dataset research for micro-burn

Researched 2026-11-03. Sources below are dataset publishers, investigators, or
original research. The selected dataset has since been downloaded and audited;
see [DATA_AUDIT.md](DATA_AUDIT.md) and [prepared-data attribution](data/README.md).
The specification is [SPEC.md](SPEC.md).

## Recommendation

Use the Czech classroom dataset, whose raw schema now passes the audit. It supplies
an educational graph prediction problem close to the
requested example. Keep ESOL as a small, clearly licensed graph-regression fallback
if the educational task proves unsuitable. Do not implement both datasets in v1.

The useful GNN question is: does adding information from observed relationships
help predict later outcomes beyond the student's own baseline information? A
negative result is informative and does not mean the application failed.

## 1. Czech classroom networks: recommended near-match

The [version 3 dataset](https://data.mendeley.com/datasets/9c3dth6cwp/3), DOI
`10.17632/9c3dth6cwp.3`, contains 276 students in 12 classrooms, friendship and
group-work networks, and Czech-language grades. Its licence is CC BY 4.0. Grades
run from 1 (best) to 5 (worst).

The [associated paper](https://journals.sagepub.com/doi/abs/10.1177/02724316241271424)
documents baseline and end-of-year grades/literacy and friendship measurements
about seven months apart. Friendship nominations are directed and may be
unreciprocated. It reports no evidence of the peer-influence effects it tested.
An [author-hosted manuscript](https://is.muni.cz/publication/2421399/Lintner_2024b.pdf)
is also available.

### Proposed experiment, not a publisher benchmark

- Nodes: students, kept in their classroom graphs.
- Edges: T1 friendship nominations, symmetrized by union for the first GCN.
- Inputs: T1 grade, plus T1 literacy if its raw fields are usable.
- Target: T2 subject grade as an ordinal-valued regression task.
- Model: two message-passing layers and a scalar head.
- Evaluation: classroom-disjoint train/validation/test sets; MAE/RMSE; compare
  prior-grade prediction, a training-mean predictor and a feature-only MLP.

One message-passing layer aggregates immediate neighbours; a second incorporates
information two hops away. This is the requested friends-of-friends mechanism.
It does not imply that friendships cause changes in achievement.

The data are subject grades and friendship ties, not exam marks or proven study
partnerships. The sample is small; uncertainty and baseline comparisons matter.
Raw-file inspection must establish exact wave/column names, identifiers, missingness
and usable counts. Do not assume that every published participant has every label.
Use only baseline data; later networks and later literacy would leak future
information. Group-work interactions require their own timing audit and are outside
the first model.

## 2. Swiss StudentLife: closest conceptual match, request access

The [PNAS study](https://pmc.ncbi.nlm.nih.gov/articles/PMC6338824/) follows 226
engineering students and includes studying-together networks, prior academic
achievement and examination outcomes. Its data-access route is through the
researchers; a frictionless public download was not verified. The
[ETH project page](https://sn.ethz.ch/research/studentlife.html) describes access.

This closely matches the user's original example, but requesting data and satisfying
access conditions is a separate decision. Do not contact researchers or make it the
default dependency for a runnable example.

## 3. NetSense: promising longitudinal option, licence unresolved

The investigator-maintained [academic codebook](https://olizardo.github.io/NetSense-Codebook/academics.html)
documents course grades and GPA records for 111 students, with longitudinal
academic records. The [download portal](https://olizardo.github.io/NetSense-Codebook/download.html)
also provides social-network data.

Predicting later grades from earlier grades and earlier relationships is plausible.
However, an explicit dataset reuse licence was not verified. Academic and network
coverage must also be joined and audited. Publicly linked files are not, by
themselves, a verified redistribution licence. Keep this as a research alternative,
not the automatic example dataset.

## 4. UCI Student Performance: grades without a social graph

[UCI Student Performance](https://archive.ics.uci.edu/dataset/320/student%2Bperformance)
provides earlier-period grades G1/G2 and final grade G3, under CC BY 4.0. Its published
schema does not include observed student-to-student links.

It is suitable for ordinary grade-prediction baselines. Connecting students by
similarity would construct a different experiment and cannot be described as
observed study or friendship relationships. It is therefore not the recommended
GNN dataset for this request.

## 5. OULAD: educational relational data with a different graph

[Open University Learning Analytics Dataset](https://archive.ics.uci.edu/dataset/349/open%2Buniversity%2Blearning%2Banalytics%2Bdataset)
contains seven courses, more than 30,000 students and linked CSV tables of assessment
and learning-environment activity; it is CC BY 4.0.

A graph could represent actual student-resource or student-assessment relations.
These edges are not study partnerships. It needs a temporal cutoff, treatment of
repeated students and a carefully selected target; final exam marks are not a
uniformly established target across all subsets. This is a larger heterogeneous
graph/preprocessing project than the first example needs.

## 6. ESOL molecular solubility: strongest compact fallback

OGB's `ogbg-molesol` has 1,128 molecular graphs. Atoms are nodes, bonds are edges, and
the regression target is solubility. OGB supplies precomputed graph data and fixed
scaffold splits; its molecular dataset documentation lists MIT licensing.

Primary references: [OGB graph-property documentation](https://ogb.stanford.edu/docs/graphprop/),
[OGB metadata](https://raw.githubusercontent.com/snap-stanford/ogb/master/ogb/graphproppred/master.csv),
and [ESOL target and size](https://deepchem.readthedocs.io/en/stable/api_reference/moleculenet.html#delaney-datasets).

A two-layer GNN with graph-level pooling could predict solubility. Reading OGB's
precomputed CSV representation avoids implementing molecular parsing or requiring
Python/RDKit at runtime. Use the supplied scaffold split and report held-out RMSE,
with a mean predictor and a graph-free feature model for comparison. This is the
recommended alternative if the user prefers a more conventional GNN task.

## Other screened candidates

- [Biweekly student collaboration nominations](https://data.mendeley.com/datasets/vf5s29p5mn/1):
  real collaboration edges and CC BY 4.0, but included grade labels were not
  established from the publisher description.
- [UTA student relationships](https://mavmatrix.uta.edu/socialnetworksforsocialgood_datasets/2/):
  academic-discussion ties and incoming GPA, but no later-grade target was verified.
- [Cora](https://linqs-data.soe.ucsc.edu/public/datasets/cora/): classic citation-graph
  topic classification, but explicit dataset licence terms were not verified from
  the primary distribution. A loader's software licence is not the data licence.

## Required data audit before implementation

1. Retrieve the selected version and preserve source/attribution/licence metadata.
2. Inspect actual tables and record exact fields, IDs, units and timepoints.
3. Verify graph alignment, labels, missing-value handling and duplicate identities.
4. Save a deterministic preprocessing description and file checksums.
5. Freeze the split and baseline definitions before tuning the GNN.
6. Keep held-out labels out of features, graph construction and training loss.
7. Record what is known and what remains unverified; change the proposed task
   explicitly if the data do not support it.

## Research limitations

The initial research inspected publisher metadata and papers. The subsequent
[raw-file audit](DATA_AUDIT.md) verifies the selected workbooks and documents the
250 complete-case students, exact fields, missingness, and split.
The Hugging Face CLI discovery request could not resolve the network in the current
environment, so primary publisher pages were used. The recommendation does not
depend on an unverified Hub mirror. No researcher was contacted, account created,
or access request submitted.
