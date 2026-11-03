# Inside micro-log

[guide.typ](guide.typ) is the main editable Typst document. It explains the
firmware, peripherals, storage algorithm, unsafe code, build files, shared
helpers, and Python exporter. The source appendix reads the current project
files directly when compiled.

The [compiled PDF](../../../output/pdf/micro-log-guide.pdf) is available from the
repository's `output/pdf` directory.

From the workspace root, using Typst 0.15 or newer:

```sh
mkdir -p output/pdf
typst compile --root . projects/micro-log/docs/guide.typ output/pdf/micro-log-guide.pdf
```

The repository root is required because the appendix reads shared crates outside
the document directory. No Typst package downloads are needed. The layout uses
Avenir Next and DejaVu Sans Mono; Typst can substitute available fonts on other
systems. Explanations are in `chapters/`, styling is in `theme.typ`, and the
source-listing helper is in `appendix.typ`.

The guide describes this version of the code. If the firmware changes, review the
explanations as well as regenerating the automatically populated source appendix.
