#!/bin/sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
bundle_dir="$project_dir/target/micro-burn.app"

cargo build --manifest-path "$project_dir/Cargo.toml" -p micro-burn-app --release
mkdir -p "$bundle_dir/Contents/MacOS"
cp "$project_dir/target/release/micro-burn-app" "$bundle_dir/Contents/MacOS/"
cp "$project_dir/app/macos/Info.plist" "$bundle_dir/Contents/Info.plist"
printf 'Created %s\n' "$bundle_dir"
