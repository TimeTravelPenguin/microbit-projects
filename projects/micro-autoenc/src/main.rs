use std::{
    fs,
    num::NonZeroUsize,
    path::{Path, PathBuf},
};

use anyhow::{Context, Result, ensure};
use burn::{
    config::Config,
    data::dataloader::DataLoader,
    module::Module,
    nn::loss::{MseLoss, Reduction},
    tensor::Device,
};
use clap::Parser;
use micro_autoenc::{
    Autoencoder, AutoencoderConfig,
    cli::{Cli, CliCommand, ComputeDevice, Split, TrainArgs},
    dataset::{VoiceBankDataLoader, VoiceBankDataset},
    training::{TrainingConfig, train},
};

mod audio;

/// The number of samples per frame for the autoencoder.
const FRAME_SIZE: usize = 256;

fn main() -> Result<()> {
    let cli = Cli::parse();

    match cli.command {
        CliCommand::Config => {
            let config = default_config();
            println!("{}", serde_json::to_string_pretty(&config)?);
            Ok(())
        }
        CliCommand::Index { directory, split } => index(directory, split, cli.device),
        CliCommand::Train(args) => run_training(args, cli.device),
        CliCommand::Test {
            directory,
            split,
            artifact_dir,
            batch_size,
        } => evaluate(directory, split, artifact_dir, batch_size, cli.device),
        CliCommand::Process {
            model,
            input,
            output,
        } => process_audio(model, input, output, cli.device),
    }
}

fn default_config() -> TrainingConfig {
    TrainingConfig::new(
        AutoencoderConfig::new(FRAME_SIZE, 8, vec![64, 32], vec![32, 64])
            .with_dropout(vec![0.05; 2], vec![0.0; 2]),
    )
    .with_patience(Some(20))
}

fn load_config(path: &Path) -> Result<TrainingConfig> {
    let config =
        TrainingConfig::load(path).with_context(|| format!("loading {}", path.display()))?;
    config
        .model
        .validate()
        .map_err(anyhow::Error::msg)
        .with_context(|| format!("invalid model configuration in {}", path.display()))?;

    ensure!(
        config.model.input_size() == FRAME_SIZE,
        "this executable requires {FRAME_SIZE}-sample frames, but the configuration specifies {}",
        config.model.input_size()
    );

    Ok(config)
}

fn load_model(
    directory: &Path,
    config: &AutoencoderConfig,
    device: &Device,
) -> Result<Autoencoder> {
    let weights = directory.join("model.bpk");
    let model = config
        .init(device)
        .try_load_file(&weights)
        .with_context(|| format!("loading weights from {}", weights.display()))?;

    Ok(model.valid())
}

fn index(directory: Option<PathBuf>, split: Split, device: ComputeDevice) -> Result<()> {
    let config = default_config();
    let directory = directory.unwrap_or(config.dataset_dir);
    let held_out: Vec<&str> = config
        .validation_speakers
        .iter()
        .map(String::as_str)
        .collect();
    println!("Indexing {split:?} from {}...", directory.display());
    let dataset = VoiceBankDataset::<FRAME_SIZE>::load(&directory, split.into(), &held_out)?;
    println!(
        "{} recordings, {} paired frames of {FRAME_SIZE} samples",
        dataset.recording_count(),
        dataset.len(),
    );

    let loader = VoiceBankDataLoader::new(dataset, 32, device.init())?;
    let batch = loader.iter().next().context("dataset has no batches")??;
    println!(
        "First batch: noisy {:?}, clean {:?}",
        batch.noisy.dims(),
        batch.clean.dims(),
    );

    Ok(())
}

fn run_training(args: TrainArgs, device: ComputeDevice) -> Result<()> {
    let mut config = match args.config {
        Some(path) => load_config(&path)?,
        None => default_config(),
    };

    if let Some(directory) = args.directory {
        config.dataset_dir = directory;
    }

    if let Some(epochs) = args.epochs {
        config.num_epochs = epochs.get();
    }

    if let Some(batch_size) = args.batch_size {
        config.batch_size = batch_size.get();
    }

    if let Some(buffer_frames) = args.shuffle_buffer_frames {
        config.shuffle_buffer_frames = buffer_frames.get();
    }

    if let Some(seed) = args.seed {
        config.seed = seed;
    }

    if args.overwrite {
        fs::remove_dir_all(args.artifact_dir.clone()).ok();
    }

    println!("Training from {}", config.dataset_dir.display());
    println!("Artifacts: {}", args.artifact_dir.display());

    train::<FRAME_SIZE>(&args.artifact_dir, config, device.init())?;

    println!(
        "Saved trained weights to {}",
        args.artifact_dir.join("model.bpk").display()
    );

    Ok(())
}

fn evaluate(
    directory: Option<PathBuf>,
    split: Split,
    artifact_dir: PathBuf,
    batch_size: Option<NonZeroUsize>,
    device: ComputeDevice,
) -> Result<()> {
    let config = load_config(&artifact_dir.join("config.json"))?;
    let directory = directory.unwrap_or(config.dataset_dir);
    let held_out: Vec<&str> = config
        .validation_speakers
        .iter()
        .map(String::as_str)
        .collect();
    let device = device.init();
    let model = load_model(&artifact_dir, &config.model, &device)?;

    println!("Evaluating {split:?} from {}...", directory.display());

    let dataset = VoiceBankDataset::<FRAME_SIZE>::load(&directory, split.into(), &held_out)?;
    let recording_count = dataset.recording_count();
    let batch_size = batch_size.map_or(config.batch_size, NonZeroUsize::get);
    let loader = VoiceBankDataLoader::new(dataset, batch_size, device)?;
    let loss = MseLoss::new();
    let mut frames_seen = 0;
    let mut denoised_squared_error = 0.0;
    let mut noisy_squared_error = 0.0;

    for batch in loader.iter() {
        let batch = batch?;
        let [frames, _] = batch.noisy.dims();
        let output = model.forward(batch.noisy.clone());
        let denoised_mse = loss
            .forward(output, batch.clean.clone(), Reduction::Mean)
            .try_into_scalar::<f64>()?;
        let noisy_mse = loss
            .forward(batch.noisy, batch.clean, Reduction::Mean)
            .try_into_scalar::<f64>()?;

        ensure!(
            denoised_mse.is_finite() && noisy_mse.is_finite(),
            "non-finite evaluation loss"
        );

        // Weight by frames so the last partial batch contributes correctly.
        denoised_squared_error += denoised_mse * frames as f64;
        noisy_squared_error += noisy_mse * frames as f64;
        frames_seen += frames;
    }

    ensure!(frames_seen > 0, "evaluation contains no complete frames");
    println!("Evaluated {frames_seen} frames from {recording_count} recordings");
    println!("Noisy MSE: {:.8}", noisy_squared_error / frames_seen as f64);
    println!(
        "Denoised MSE: {:.8}",
        denoised_squared_error / frames_seen as f64
    );

    Ok(())
}

fn process_audio(
    artifact_dir: PathBuf,
    input_path: PathBuf,
    output_path: PathBuf,
    device: ComputeDevice,
) -> Result<()> {
    let config = load_config(&artifact_dir.join("config.json"))?;
    let device = device.init();
    let model = load_model(&artifact_dir, &config.model, &device)?;

    println!("Processing {}...", input_path.display());
    let sample_count = audio::denoise(&model, &device, &input_path, &output_path)
        .with_context(|| format!("processing {}", input_path.display()))?;
    println!(
        "Saved {sample_count} denoised samples to {}",
        output_path.display()
    );

    Ok(())
}
