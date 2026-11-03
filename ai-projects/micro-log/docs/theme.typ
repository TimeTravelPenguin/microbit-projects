#let ink = rgb("233247")
#let accent = rgb("087f8c")
#let muted = rgb("617184")
#let pale = rgb("eef5f7")

#let note(title, body) = block(
  width: 100%,
  inset: 11pt,
  fill: pale,
  stroke: (left: 3pt + accent),
  radius: 2pt,
  breakable: true,
)[
  #text(weight: "bold", fill: ink, title)

  #body
]

#let guide(body) = {
  set document(
    title: "Inside micro-log: a beginner's guide to persistent sensor logging",
    author: "micro:bit learning project",
    description: "An annotated guide to the Rust firmware, unsafe flash access, peripherals, storage format, and Python exporter.",
  )

  set page(
    paper: "a4",
    margin: (top: 21mm, bottom: 20mm, left: 20mm, right: 20mm),
    header: context {
      if counter(page).get().first() > 1 {
        text(size: 8pt, fill: muted)[MICRO-LOG / CODE AND HARDWARE GUIDE]
        line(length: 100%, stroke: 0.35pt + rgb("d4dfe5"))
      }
    },
    footer: context [
      #set text(size: 8pt, fill: muted)
      #grid(columns: (1fr, auto), [micro:bit V2 · Rust + Python], counter(page).display("1"))
    ],
  )

  set text(font: "Avenir Next", size: 10.1pt, fill: ink, lang: "en", region: "AU")
  set par(justify: false, leading: 0.65em, spacing: 0.75em)
  set heading(numbering: "1.1", outlined: true)
  set list(indent: 1.1em, body-indent: 0.55em, spacing: 0.35em)
  set enum(indent: 1.2em, body-indent: 0.6em, spacing: 0.35em)
  set table(inset: 6pt, stroke: 0.4pt + rgb("d4dfe5"))
  show table.cell.where(y: 0): set text(weight: "bold", fill: accent)
  show link: it => text(fill: accent, it)
  show raw: set text(font: "DejaVu Sans Mono", size: 8.25pt)
  show raw.where(block: true): it => {
    set par(leading: 0.25em, spacing: 0pt)
    block(
      width: 100%,
      fill: rgb("f3f5f7"),
      inset: 9pt,
      radius: 3pt,
      breakable: true,
      it,
    )
  }
  show heading.where(level: 1): it => block(
    above: 1.7em, below: 0.8em,
    text(size: 21pt, weight: "bold", fill: ink, it),
  )
  show heading.where(level: 2): it => block(
    above: 1.2em, below: 0.55em,
    text(size: 14pt, weight: "bold", fill: accent, it),
  )
  show heading.where(level: 3): it => block(
    above: 1em, below: 0.4em,
    text(size: 11pt, weight: "bold", fill: ink, it),
  )

  body
}
