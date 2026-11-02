use std::{env, fs, path::PathBuf};

fn main() {
    println!("cargo::rerun-if-changed=examples/memory.x");

    if env::var("CARGO_CFG_TARGET_OS").unwrap() != "none" {
        return;
    }

    let output_dir = PathBuf::from(env::var_os("OUT_DIR").unwrap());
    fs::write(
        output_dir.join("memory.x"),
        include_bytes!("examples/memory.x"),
    )
    .unwrap();

    // Supply the micro:bit memory map only to this crate's example programs.
    // Applications using the library continue to choose their own memory map.
    println!("cargo::rustc-link-arg-examples=-L{}", output_dir.display());
}
