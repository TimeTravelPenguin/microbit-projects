// Use the current sources instead of keeping a second, drifting code copy.
#let listing(path, lang, label) = {
  heading(level: 2, label)
  let source = read(path)
  let lines = source.split("\n")
  let numbered = lines.enumerate().map(((idx, line)) => {
    let number = str(idx + 1)
    " " * (4 - number.len()) + number + " | " + line
  }).join("\n")

  raw(numbered, lang: lang, block: true)
}

= Source reference: the actual files

These listings are populated from the current workspace files during compilation.
The left column is a line number added by the document, not part of the source.
Landscape pages preserve long code lines without shrinking them excessively.
This is reference material; the preceding chapters supply the explanations.

#listing("../src/main.rs", "rust", "Firmware: src/main.rs")
#pagebreak()
#listing("../src/lib.rs", "rust", "Storage library: src/lib.rs")
#pagebreak()
#listing("../export.py", "python", "Desktop export: export.py")
#pagebreak()
#listing("../memory.x", "text", "Linker map: memory.x")
#listing("../build.rs", "rust", "Build helper: build.rs")
#listing("../Cargo.toml", "toml", "Firmware dependencies: Cargo.toml")
#listing("../.cargo/config.toml", "toml", "Local target selection")
#listing("../Embed.toml", "toml", "Flashing configuration: Embed.toml")
#listing("../pyproject.toml", "toml", "Python dependencies: pyproject.toml")
#pagebreak()
#listing("../../../crates/serial-setup/src/lib.rs", "rust", "Shared serial adapter")

== Shared button logic, excluding its own test module

The firmware uses the pure `Buttons` / `DebouncedButton` definitions below.
The optional `input` hardware module is declared but not enabled by micro-log.
The source's separate host tests are omitted from this appendix.

#let button-source = read("../../../crates/microbit-input/src/lib.rs").split("#[cfg(test)]").first()
#raw(button-source, lang: "rust", block: true)
