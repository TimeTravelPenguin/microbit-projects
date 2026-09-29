use std::{env, path::PathBuf};

use anyhow::{Context, Result, bail, ensure};
use burn::{data::dataloader::DataLoader, tensor::Device};
use micro_autoenc::dataset::{DatasetSplit, VoiceBankDataLoader, VoiceBankDataset};

const FRAME_SIZE: usize = 256;
const VALIDATION_SPEAKERS: &[&str] = &["p282", "p287"];

fn main() -> Result<()> {
    let mut args = env::args_os().skip(1);
    let directory = args.next().map(PathBuf::from).unwrap_or_else(|| {
        PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("../../datasets/VoiceBank-DEMAND-16k/data")
    });

    let split = match args.next() {
        None => DatasetSplit::Train,
        Some(arg) => match arg.to_str() {
            Some("train") => DatasetSplit::Train,
            Some("validation") => DatasetSplit::Validation,
            Some("test") => DatasetSplit::Test,
            _ => bail!("unknown split {arg:?}; use train, validation, or test"),
        },
    };

    ensure!(
        args.next().is_none(),
        "usage: micro-autoenc [parquet-directory] [train|validation|test]"
    );

    println!("Indexing {split:?} from {}...", directory.display());
    let dataset = VoiceBankDataset::<FRAME_SIZE>::load(&directory, split, VALIDATION_SPEAKERS)?;
    println!(
        "{} recordings, {} paired frames of {FRAME_SIZE} samples",
        dataset.recording_count(),
        dataset.len(),
    );

    let loader = VoiceBankDataLoader::new(dataset, 32, Device::flex())?;
    let loader = if split == DatasetSplit::Train {
        loader.shuffle(42, 4096)?
    } else {
        loader
    };

    let batch = loader.iter().next().context("dataset has no batches")??;
    println!(
        "First batch: noisy {:?}, clean {:?}",
        batch.noisy.dims(),
        batch.clean.dims(),
    );

    Ok(())
}
