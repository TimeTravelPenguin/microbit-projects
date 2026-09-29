use core::num::NonZeroUsize;
use std::path::PathBuf;

use crate::dataset::DatasetSplit;
use burn::tensor::{Device, DeviceKind};
use clap::{Args, Parser, Subcommand, ValueEnum};

#[derive(Parser)]
#[command(
    version,
    about = "Train and evaluate a streaming audio denoising autoencoder"
)]
pub struct Cli {
    #[command(subcommand)]
    pub command: CliCommand,

    /// Compute device (CPU uses Burn Flex; Metal requires a compatible GPU)
    #[arg(long, global = true, value_enum, default_value_t = ComputeDevice::Metal)]
    pub device: ComputeDevice,
}

#[derive(Subcommand)]
pub enum CliCommand {
    /// Print the default training configuration
    Config,
    /// Index a VoiceBank split, print counts, and preview one batch
    Index {
        /// Directory containing Parquet shards (defaults to the local download)
        #[arg(value_name = "PARQUET_DIRECTORY")]
        directory: Option<PathBuf>,

        /// Dataset split to index
        #[arg(long, value_enum, default_value_t = Split::Train)]
        split: Split,
    },
    /// Train on noisy/clean pairs and validate on held-out speakers
    Train(TrainArgs),
    /// Evaluate saved weights and report MSE against clean audio
    Test {
        /// Parquet directory (defaults to the saved training configuration)
        #[arg(value_name = "PARQUET_DIRECTORY")]
        directory: Option<PathBuf>,

        /// Dataset split to evaluate
        #[arg(long, value_enum, default_value_t = Split::Test)]
        split: Split,

        /// Existing run containing config.json and model.bpk
        #[arg(long, default_value = "artifacts", value_name = "DIRECTORY")]
        artifact_dir: PathBuf,

        /// Override the saved batch size
        #[arg(long)]
        batch_size: Option<NonZeroUsize>,
    },
}

#[derive(Args)]
#[command(after_help = "See the default configuration value with the `config` command.")]
pub struct TrainArgs {
    /// Parquet directory (overrides the configuration)
    #[arg(value_name = "PARQUET_DIRECTORY")]
    pub directory: Option<PathBuf>,

    /// New or empty directory for configuration, weights, checkpoints, and logs
    #[arg(long, default_value = "artifacts", value_name = "DIRECTORY")]
    pub artifact_dir: PathBuf,

    /// Training JSON for 256-sample frames and two hidden layers per half
    #[arg(long, value_name = "FILE")]
    pub config: Option<PathBuf>,

    /// Override the number of epochs
    #[arg(long)]
    pub epochs: Option<NonZeroUsize>,

    /// Override the batch size
    #[arg(long)]
    pub batch_size: Option<NonZeroUsize>,

    /// Override the bounded shuffle buffer size in frames
    #[arg(long)]
    pub shuffle_buffer_frames: Option<NonZeroUsize>,

    /// Override the random seed
    #[arg(long)]
    pub seed: Option<u64>,
}

#[derive(Clone, Copy, Debug, ValueEnum)]
pub enum Split {
    Train,
    Validation,
    Test,
}

impl From<Split> for DatasetSplit {
    fn from(split: Split) -> Self {
        match split {
            Split::Train => Self::Train,
            Split::Validation => Self::Validation,
            Split::Test => Self::Test,
        }
    }
}

#[derive(Clone, Copy, Debug, ValueEnum)]
pub enum ComputeDevice {
    Cpu,
    Metal,
}

impl ComputeDevice {
    pub fn init(self) -> Device {
        match self {
            Self::Cpu => Device::flex(),
            Self::Metal => Device::metal(DeviceKind::DefaultDevice),
        }
    }
}

fn parse_learning_rate(value: &str) -> std::result::Result<f64, String> {
    let rate: f64 = value.parse().map_err(|_| "expected a positive number")?;

    if !rate.is_finite() || rate <= 0.0 {
        return Err("learning rate must be finite and greater than zero".into());
    }

    Ok(rate)
}
