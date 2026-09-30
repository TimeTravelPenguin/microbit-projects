# Audio dataset loading and training

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
cargo run -p micro-autoenc -- index
cargo run -p micro-autoenc -- index datasets/VoiceBank-DEMAND-16k/data --split validation
```

The default directory is anchored to the crate location, so the first command
also works from `projects/micro-autoenc`. Explicit paths are relative to the
working directory. The `index` command prints counts and streams one batch of up
to 32 frames in source order on Burn's Flex CPU device.

Use `--split test` to explicitly open the official test shards.
Training and validation never open those shards.

## Command-line training and evaluation

The executable uses [Clap subcommands](https://docs.rs/clap/4.6.7/clap/_derive/_tutorial/index.html#subcommands).
Use `--help`, `train --help`, or `test --help` to list options.

```sh
cargo run -p micro-autoenc -- train --artifact-dir artifacts/run-01 --epochs 10
cargo run -p micro-autoenc -- test --artifact-dir artifacts/run-01
```

`train` uses the training shards with held-out speakers for validation. It streams
both splits and saves the effective configuration and final weights in the run
directory. Its optional positional directory overrides the configuration's data
path. Options include `--epochs`, `--batch-size`, `--learning-rate`, `--seed`, and
`--shuffle-buffer-frames`.

The executable uses 256-sample frames, with a default architecture of
`256 → 64 → 32 → 8 → 32 → 64 → 256`. `--config FILE` loads a `TrainingConfig`
JSON, including layer widths and depths, dropout, and validation speakers;
explicit CLI options override its settings. This starts a fresh run, not a
checkpoint resume. Other frame sizes remain available through the library API.

Model depths are determined at runtime by the lengths of `model.encoder_hidden`
and `model.decoder_hidden`. Change those lists in the JSON to experiment with
different architectures using the same executable. Each corresponding dropout
list must have the same length as its hidden-width list. Widths must be positive
and dropout probabilities must be between zero and one. Empty hidden lists are
supported; that half then consists of its output linear layer alone.

Existing valid config files retain the same JSON format. For example, start with
`cargo run -p micro-autoenc -- config > config.json`, edit the model lists, and
pass `--config config.json` when training. Evaluation reconstructs the architecture
from the saved run's configuration.

`test` loads `config.json` and `model.bpk` from the supplied run directory and
evaluates the official test split by default. It prints the noisy-input baseline
MSE and denoised MSE against clean audio, weighted by frame count so partial
batches contribute correctly. It streams the whole split without training or
writing to the run directory. Use `--split validation` for validation measurements,
`--batch-size` to override the saved batch size, or a positional directory to
relocate the dataset.

Both commands default to CPU. On a compatible Mac, append `--device metal` to use
Burn's Metal backend. For example:

```sh
cargo run -p micro-autoenc -- train datasets/VoiceBank-DEMAND-16k/data \
  --artifact-dir artifacts/metal-run-01 --device metal
```

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

## Train the autoencoder

`training::train` connects the streaming loaders to Burn's `SupervisedTraining`:
noisy frames are inputs, clean frames are targets, and both training and validation
report mean squared error through `LossMetric`.

The CLI uses this function. You can also call it from another training entry point:

```rust
use burn::{optim::AdamConfig, tensor::Device};
use micro_autoenc::{
    AutoencoderConfig,
    training::{TrainingConfig, train},
};

fn main() -> anyhow::Result<()> {
    let model = AutoencoderConfig::new(256, 16, vec![128, 64], vec![64, 128]);
    let config = TrainingConfig::new(model, AdamConfig::new())
        .with_dataset_dir("datasets/VoiceBank-DEMAND-16k/data")
        .with_num_epochs(10)
        .with_batch_size(64)
        .with_shuffle_buffer_frames(4096);

    let trained = train::<256>("artifacts/denoising-run-01", config, Device::flex())?;
    // `trained` is ready for inference, with dropout disabled.

    Ok(())
}
```

The only const generic argument is the frame size `N`; layer depths are runtime
configuration. Constructors accept vectors or array literals, and config getters
return slices. The model's input size must equal `N`. Training uses autodiff on the supplied
device; validation uses its inference device. Defaults are seed 42, Adam learning
rate `1e-4`, and held-out speakers `p282` and `p287`. Override the speakers with
`.with_validation_speakers(vec!["p282".into(), "p287".into()])`. Both splits must
contain complete frames. Official test shards remain reserved for final evaluation.

The artifact directory must be new or empty to prevent overwriting a previous
run. It contains:

- `config.json`, including dataset path, speaker split, and shuffle-buffer size.
- Training/validation metrics, the experiment log, and Burn's retained model,
  optimizer, and scheduler checkpoints under `checkpoint/`.
- `model.bpk`, the final epoch's weights (not an automatic selection of the best
  validation checkpoint).
- `exports/`, with CSVs and SVG graphs generated automatically using
  [Plotters](https://github.com/plotters-rs/plotters) when training finishes,
  including when early stopping ends the run.

The exports include training and validation loss, plus the training learning rate.
Each metric gets a CSV containing every logged batch and a graph against batch
step. `epoch_metrics.csv` contains Burn's final epoch aggregates;
`loss_by_epoch.svg` compares training and validation, and
`learning_rate_by_epoch.svg` shows the mean learning rate for each epoch.
The CSV columns and aggregation details are documented in `exports/README.txt`.

Export reads metric logs sequentially. Batch graphs retain the first, minimum,
maximum, and last point in each of at most 2,048 intervals to preserve spikes
while bounding memory and SVG size. CSVs keep every batch at its logged precision;
epoch graphs keep every completed epoch. Burn's current scalar loss is averaged
across batches, and the logged weights are aggregation weights, not audio-frame
counts.

The function returns `anyhow::Result<Autoencoder>`. Model dimensions and dropout
lists are validated before training creates artifacts. Configuration, indexing,
final-save, and metric-export failures propagate as errors. If exporting metrics
fails, the saved `model.bpk` remains available. An interruption or streaming read
failure also returns an error and skips the final export. Completed checkpoints
remain on disk. Burn's internal backend/checkpoint failures can still panic.

`shuffle_buffer_frames` replaces the tutorial's `num_workers`: the streaming
loader reads one row group at a time without worker prefetch queues. It retains
the same bounded audio buffers during training. Model tensors, gradients, Adam
state, and checkpoints add their own memory use.

## Verification and embedded builds

```sh
cargo test -p micro-autoenc
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
The training smoke test runs two CPU epochs on small synthetic Parquet shards,
checks both splits' batch counts and automatic CSV/SVG exports, and reloads the
exported weights for inference. Export tests cover numeric epoch ordering,
aggregation weights, invalid logs, single-point graphs, and complete CSVs for
series larger than the graph's point budget.
The CLI smoke test invokes `index`, `train`, and `test` in separate processes,
checks configuration overrides, exercises several layer depths with the same
executable, and verifies evaluation agrees across batch sizes.

Polars, Hound, Rand, Anyhow, CSV, Plotters, and all dataset/executable code are gated behind
`train`. The feature-disabled host check does not establish micro:bit firmware
compatibility or memory fit; that requires a separate target build and measurement.
The model uses `alloc::vec::Vec` in the inference-only build; its final firmware
application must provide an allocator.
