# microbit projects

This repo contains projects that I decided to play with to help learn about
microcontrollers.

## Projects

Below is a list of current projects.

| Project            | Description                                          |
| ------------------ | ---------------------------------------------------- |
| [microbit-autoenc] | Use an autoencoder to remove noise from audio        |
| [micro-arcade]     | Learn micro:bit programming with a small arcade game |

[microbit-autoenc]: ./projects/micro-autoenc/
[micro-arcade]: ./projects/micro-arcade/

## Building and Flashing

The workspace includes code that runs on the host computer and firmware that runs on
the micro:bit. From the workspace root, use the appropriate Cargo alias:

```sh
cargo build-host
cargo build-arcade
cargo flash-arcade
```

The Rust toolchain includes the micro:bit target and LLVM tools. The root
`.cargo/config.toml` shares the ARM runner and linker settings, while
`projects/micro-arcade/.cargo/config.toml` selects the ARM target when working in
that project. Cargo reads configuration from the current directory and its parents;
selecting a package with `-p` does not load that package's local configuration. The
workspace root therefore keeps the host target as its default, and the firmware
build alias selects the ARM target explicitly.

`Embed.toml` stays in `projects/micro-arcade`, where `cargo embed` can find it.
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
cargo build-arcade --profile firmware

# From projects/micro-arcade:
cargo embed -- --profile firmware
```

## AI Usage

I try to avoid using AI as much as possible, unless I am significantlly confident that all
it is doing is filling out boilerplate that I am entirely capable and familiar with doing,
or in the event that I have absolutely no clue how to solve a problem.

My otherwise main usage is to run AI over my completed work and have it refactor what I
have into a cleaner structure. I try to do this as little as possible, but it is nice when
it does a good job and picks out additional bugs along the way. Also, I can have it add
stub functions in place of real ones, which prevents it from finishing any remaining work
I might have.

One exception, where I don't necessarily care as much about AI usage, is that I am
content with allowing AI to write tests and documentation. Honestly, I probably wouldn't
do it for hobby projects, otherwise.
