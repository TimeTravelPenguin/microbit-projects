# Streaming audio dataset loading

The `train` feature provides `dataset::VoiceBankDataset<N>` and
`dataset::VoiceBankDataLoader<N>` for the locally downloaded
[JacobLinCool/VoiceBank-DEMAND-16k dataset](https://huggingface.co/datasets/JacobLinCool/VoiceBank-DEMAND-16k).
Loading uses Rust throughout: Polars reads Parquet and Hound reads WAVs.
No extraction, disk cache, or Python runtime is required.

## Memory and streaming

`VoiceBankDataset::load` makes an initial bounded pass to index recordings,
validate the paired WAV headers/data lengths, and count frames. It retains only
IDs, row locations, and frame counts. It does not decode or retain the full audio.

Each epoch then reads **one physical Parquet row group at a time**, using
`ParquetReader::with_slice` over the row range from the file's metadata. The
row-group reader skips all groups outside that range before decoding. The
resulting dataframe is bounded to that single group; its buffers are released before reading the next. Only the current
recording is decoded to PCM16. The downloaded shards have groups of at most
100 recordings, far smaller than a complete shard.

The live data consists of:

- The small recording index.
- One Parquet row group and its temporary decompression buffers.
- One decoded clean/noisy recording pair.
- The current batch and, for training, a fixed-size shuffle buffer.

A 4,096-frame shuffle buffer at 256 samples contains about **8 MiB** of waveform
data plus small metadata overhead. Memory depends on the largest row group and
recording, not the number of recordings in the dataset. This is not a hard total
process memory limit: Polars, Burn, their allocators, and tensors add overhead.
Each concurrently active iterator owns its own bounded buffers.

On the downloaded data in this workspace, the debug-build training index plus
first shuffled batch peaked at **192 MiB process RSS**. Indexing and streaming
the entire validation split (730 recordings, 129,754 frames) peaked at **194 MiB**.
These are measured process peaks, including library overhead, not memory caps.

## Try the loader

From the workspace root:

```sh
cargo run -p micro-autoenc
cargo run -p micro-autoenc -- datasets/VoiceBank-DEMAND-16k/data validation
```

The default directory is anchored to the crate location, so the first command
also works from `projects/micro-autoenc`. Explicit paths are relative to the
working directory. The executable indexes the selected split, prints counts,
and streams one `[32, 256]` batch on Burn's Flex CPU device. Training uses a
4,096-frame shuffle buffer; validation keeps the source order. It does not start
model training.

Use `test` as the final argument to explicitly open the official test shards.
Training and validation never open those shards.

## Use with Burn 0.22.0-pre.4

```rust
use std::sync::Arc;
use burn::{data::dataloader::DataLoader, tensor::Device};
use micro_autoenc::dataset::{DatasetSplit, VoiceBankDataLoader, VoiceBankDataset};

let directory = "datasets/VoiceBank-DEMAND-16k/data";
let held_out = &["p282", "p287"];
let device = Device::flex();
let training = VoiceBankDataset::<256>::load(directory, DatasetSplit::Train, held_out)?;
let validation = VoiceBankDataset::<256>::load(directory, DatasetSplit::Validation, held_out)?;

let training_loader = Arc::new(
    VoiceBankDataLoader::new(training, 32, device.clone())?
        .shuffle(42, 4096)?,
);

let validation_loader = Arc::new(
    VoiceBankDataLoader::new(validation, 32, device)?,
);

for batch in training_loader.iter() {
    let batch = batch?;
    // batch.noisy is the model input; batch.clean is the reconstruction target.
}
```

These implement Burn's `DataLoader<DenoisingBatch>` directly and can be passed to
its learner. They replace the previous `DataLoaderBuilder` integration:
`VoiceBankDataset` no longer implements random-access `Dataset::get`. Arbitrary
frame-level disk reads would repeatedly decompress the same row groups.
`dataset.frames()` is available for an ordered stream of individual frame pairs.

Every `iter()` starts a fresh epoch. Training permutes row groups and mixes frames
through the bounded buffer, with reproducible but different orders each epoch.
This is **not a uniform global permutation** of every frame. Each frame still
appears exactly once per complete epoch. Validation/test are deterministic unless
you explicitly enable shuffling.

The loader supports Burn's device transfer, progress reporting, final partial
batches, and slicing. Slices select a range of the original ordered frames before
shuffling, and skip unrelated row groups. Read failures are returned once, then
iteration stops. Keep the source files unchanged while using an index.

## Audio and split rules

The schema is `id: String`, with `clean` and `noisy` structs containing
`bytes: Binary` and `path: String`. Embedded bytes are read directly; paths are
metadata. Only mono, 16 kHz, 16-bit integer PCM WAVs with equal paired lengths are
accepted. Errors identify the file and recording where available.

Frames are non-overlapping and never cross recording boundaries. Incomplete
tails are dropped; recordings shorter than `N` contribute no frames. A 256-sample
frame at 16 kHz spans 16 ms. Both sides use `i16_sample / 32768.0`, with no separate
normalization, resampling, silence filtering, or added noise. Match the model's
input size to `N`.

Train and validation partition source `train-*.parquet` rows by speaker prefix
before framing. Pass the same held-out speaker list to both. The example uses
`p282` and `p287` as a project choice, not an official validation split. Unknown
holdout speakers are errors. An empty list trains on all source training speakers.
Test reads only `test-*.parquet` and ignores the holdout list.

## Verification and embedded builds

```sh
cargo test -p micro-autoenc --test dataset
cargo check -p micro-autoenc --no-default-features --lib
```

To run the optional complete pass over the downloaded validation recordings:

```sh
MICRO_AUTOENC_DATASET="$PWD/datasets/VoiceBank-DEMAND-16k/data" \
  cargo test -p micro-autoenc --test dataset downloaded_validation_streams_to_completion -- --ignored --nocapture
```

Tests cover paired values and frame boundaries, speaker separation, multi-group
streaming, repeatable epochs, bounded shuffling without dropped/duplicate frames,
partial batches, progress, device transfer, slices, and deferred read failures.

Polars, Hound, Rand, Anyhow, and all dataset/executable code are gated behind
`train`. The feature-disabled host check does not establish micro:bit firmware
compatibility or memory fit; that requires a separate target build and measurement.
