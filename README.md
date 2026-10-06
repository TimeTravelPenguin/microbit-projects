# microbit projects

This repo contains projects that I decided to play with to help learn about
microcontrollers.

## Projects

Below is a list of current projects.

| Project            | Description                                   |
| ------------------ | --------------------------------------------- |
| [microbit-autoenc]  | Use an autoencoder to remove noise from audio |
| [micro-tictactoe]   | Learn micro:bit programming with tic-tac-toe    |

[microbit-autoenc]: ./projects/micro-autoenc/
[micro-tictactoe]: ./projects/micro-tictactoe/

## Building and flashing

The workspace includes code that runs on the host computer and firmware that runs on
the micro:bit. From the workspace root, use the appropriate Cargo alias:

```sh
cargo build-host
cargo build-tictactoe
cargo flash-tictactoe
```

The Rust toolchain includes the micro:bit target and LLVM tools. The root
`.cargo/config.toml` shares the ARM runner and linker settings, while
`projects/micro-tictactoe/.cargo/config.toml` selects the ARM target when working in
that project. Cargo reads configuration from the current directory and its parents;
selecting a package with `-p` does not load that package's local configuration. The
workspace root therefore keeps the host target as its default, and the firmware
build alias selects the ARM target explicitly.

`Embed.toml` stays in `projects/micro-tictactoe`, where `cargo embed` can find it.
The flash alias changes its working directory to that project. When following the
tutorial from inside the project, the usual commands still work:

```sh
cargo build
cargo embed
```

Use the default development profile for the tutorial's debugging steps. For an
optimized build that retains debugging information, use the `firmware` profile:

```sh
# From the workspace root:
cargo build-tictactoe --profile firmware

# From projects/micro-tictactoe:
cargo embed -- --profile firmware
```

## AI Usage

I try to avoid using AI as much as possible, unless I am significantlly confident that all
it is doing is filling out boilerplate that I am entirely capable and familiar with
doing, or in the event that I have absolutely no clue how to solve a problem.

One exception is that I am content with allowing AI to write tests and documentation.
Honestly, I probably wouldn't do it for hobby projects, otherwise.
