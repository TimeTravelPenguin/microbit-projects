use std::{env, fs, path::PathBuf};

fn main() {
    let out_dir = PathBuf::from(env::var_os("OUT_DIR").expect("Cargo output directory"));
    fs::write(out_dir.join("memory.x"), include_bytes!("memory.x"))
        .expect("write firmware memory map");

    println!("cargo:rustc-link-search={}", out_dir.display());
    println!("cargo:rerun-if-changed=memory.x");
}
