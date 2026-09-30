use std::{
    path::{Path, PathBuf},
    sync::Arc,
};

use anyhow::{Context, Result, ensure};
use burn::{
    data::dataloader::DataLoader,
    lr_scheduler::{
        cosine::CosineAnnealingLrSchedulerConfig, linear::LinearLrSchedulerConfig,
        sequential::SequentialLrSchedulerConfig,
    },
    nn::loss::{MseLoss, Reduction},
    optim::AdamConfig,
    prelude::*,
    train::{
        InferenceStep, Learner, MetricEarlyStoppingStrategy, RegressionOutput, StoppingCondition,
        SupervisedTraining, TrainOutput, TrainStep,
        metric::{
            LearningRateMetric, LossMetric,
            store::{Aggregate, Direction, Split},
        },
    },
};

use crate::{
    Autoencoder, AutoencoderConfig,
    dataset::{DatasetSplit, VoiceBankDataLoader, VoiceBankDataset},
};

mod export;

pub const DEFAULT_NUM_EPOCHS: usize = 50;
pub const DEFAULT_BATCH_SIZE: usize = 64;
pub const DEFAULT_SHUFFLE_BUFFER_FRAMES: usize = 4096;
pub const DEFAULT_SEED: u64 = 42;

/// A training/validation/testing batch for a denoising autoencoder.
///
/// Both tensors have shape:
///
/// ```text
/// [batch_size, input_size]
/// ```
///
/// `noisy` is supplied to the autoencoder as its input.
///
/// `clean` is the reconstruction target.
#[derive(Clone, Debug)]
pub struct DenoisingBatch {
    pub noisy: Tensor<2>,
    pub clean: Tensor<2>,
}

impl DenoisingBatch {
    /// Creates a denoising batch.
    pub const fn new(noisy: Tensor<2>, clean: Tensor<2>) -> Self {
        Self { noisy, clean }
    }
}

impl Autoencoder {
    /// Runs a denoising batch through the network and calculates MSE.
    ///
    /// This helper is shared by:
    ///
    /// - training,
    /// - validation,
    /// - testing/evaluation.
    fn forward_regression(&self, batch: DenoisingBatch) -> RegressionOutput {
        let targets = batch.clean;
        let output = self.forward(batch.noisy);

        let loss = MseLoss::new().forward(output.clone(), targets.clone(), Reduction::Mean);

        RegressionOutput::new(loss, output, targets)
    }
}

/// Training implementation.
///
/// This performs:
///
/// ```text
/// noisy
///   ↓
/// autoencoder
///   ↓
/// reconstruction
///   ↓
/// MSE(reconstruction, clean)
///   ↓
/// backward()
/// ```
impl TrainStep for Autoencoder {
    type Input = DenoisingBatch;
    type Output = RegressionOutput;

    fn step(&self, batch: Self::Input) -> TrainOutput<Self::Output> {
        let output = self.forward_regression(batch);
        let gradients = output.loss.backward();

        TrainOutput::new(self, gradients, output)
    }
}

/// Validation and testing/evaluation implementation.
///
/// No backward pass is performed here.
impl InferenceStep for Autoencoder {
    type Input = DenoisingBatch;
    type Output = RegressionOutput;

    fn step(&self, batch: Self::Input) -> Self::Output {
        self.forward_regression(batch)
    }
}

/// Training settings, including encoder and decoder depths configured at runtime.
#[derive(Clone, Debug, burn::serde::Serialize, burn::serde::Deserialize)]
#[serde(crate = "burn::serde")]
pub struct TrainingConfig {
    pub model: AutoencoderConfig,
    pub optimizer: AdamConfig,
    pub num_epochs: usize,
    pub batch_size: usize,
    pub patience: Option<usize>,
    pub seed: u64,

    /// Directory containing the downloaded VoiceBank Parquet shards.
    #[serde(default = "default_dataset_dir")]
    pub dataset_dir: PathBuf,

    /// Speakers held out from the source training shards for validation.
    #[serde(default = "default_validation_speakers")]
    pub validation_speakers: Vec<String>,

    /// Maximum number of frames retained for bounded training shuffling.
    #[serde(default = "default_shuffle_buffer_frames")]
    pub shuffle_buffer_frames: usize,

    #[serde(default = "default_max_learning_rate", alias = "learning_rate")]
    pub max_learning_rate: f64,

    /// Learning rate used at the start of warmup and at the end of
    /// cosine annealing.
    #[serde(default = "default_min_learning_rate")]
    pub min_learning_rate: f64,

    /// Fraction of all optimizer steps devoted to linear warmup.
    #[serde(default = "default_warmup_fraction")]
    pub warmup_fraction: f64,
}

impl TrainingConfig {
    pub fn new(model: AutoencoderConfig, optimizer: AdamConfig) -> Self {
        Self {
            model,
            optimizer,
            dataset_dir: default_dataset_dir(),
            validation_speakers: default_validation_speakers(),
            num_epochs: DEFAULT_NUM_EPOCHS,
            batch_size: DEFAULT_BATCH_SIZE,
            shuffle_buffer_frames: default_shuffle_buffer_frames(),
            patience: None,
            seed: DEFAULT_SEED,
            max_learning_rate: default_max_learning_rate(),
            min_learning_rate: default_min_learning_rate(),
            warmup_fraction: default_warmup_fraction(),
        }
    }

    pub fn with_dataset_dir(mut self, dataset_dir: impl Into<PathBuf>) -> Self {
        self.dataset_dir = dataset_dir.into();

        self
    }

    pub fn with_validation_speakers(mut self, validation_speakers: Vec<String>) -> Self {
        self.validation_speakers = validation_speakers;

        self
    }

    pub fn with_num_epochs(mut self, num_epochs: usize) -> Self {
        self.num_epochs = num_epochs;

        self
    }

    pub fn with_batch_size(mut self, batch_size: usize) -> Self {
        self.batch_size = batch_size;

        self
    }

    pub fn with_shuffle_buffer_frames(mut self, shuffle_buffer_frames: usize) -> Self {
        self.shuffle_buffer_frames = shuffle_buffer_frames;

        self
    }

    pub fn with_seed(mut self, seed: u64) -> Self {
        self.seed = seed;

        self
    }

    pub fn with_learning_rate_range(
        mut self,
        min_learning_rate: f64,
        max_learning_rate: f64,
    ) -> Self {
        self.min_learning_rate = min_learning_rate;
        self.max_learning_rate = max_learning_rate;

        self
    }

    pub fn with_warmup_fraction(mut self, warmup_fraction: f64) -> Self {
        self.warmup_fraction = warmup_fraction;

        self
    }
}

impl burn::config::Config for TrainingConfig {}

impl std::fmt::Display for TrainingConfig {
    fn fmt(&self, formatter: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        formatter.write_str(&burn::config::config_to_json(self))
    }
}

fn default_dataset_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../datasets/VoiceBank-DEMAND-16k/data")
        .canonicalize()
        .expect("canonicalizing default dataset directory should not fail")
}

fn default_validation_speakers() -> Vec<String> {
    vec!["p282".into(), "p287".into()]
}

const fn default_shuffle_buffer_frames() -> usize {
    4096
}

const fn default_max_learning_rate() -> f64 {
    1.0e-3
}

const fn default_min_learning_rate() -> f64 {
    1.0e-5
}

const fn default_warmup_fraction() -> f64 {
    0.05
}

/// Trains on paired noisy/clean audio, with speaker-disjoint validation each epoch.
///
/// `N` is the frame size and must equal `config.model.input_size()`. Encoder and
/// decoder depths come from the configuration's width lists. Both splits stream
/// row groups; only training uses the bounded shuffle buffer. Official test
/// shards are never opened here.
///
/// Use a new or empty artifact directory. Saves `config.json`, Burn's metrics and
/// checkpoints, and the final epoch's weights as `model.bpk`. Returns the trained
/// model after exporting numeric metric CSVs and Plotters SVGs to `exports/`.
/// Export failures return an error but leave the saved weights available.
/// The model is in inference mode. An interrupted run returns an error without exporting
/// a final model; any completed checkpoints remain available.
pub fn train<const N: usize>(
    artifact_dir: impl AsRef<Path>,
    config: TrainingConfig,
    device: impl Into<Device>,
) -> Result<Autoencoder> {
    ensure!(N > 0, "frame size must be greater than zero");
    ensure!(
        config.model.input_size() == N,
        "model input size {} must equal frame size {N}",
        config.model.input_size()
    );
    ensure!(
        config.num_epochs > 0,
        "number of epochs must be greater than zero"
    );
    ensure!(
        config.batch_size > 0,
        "batch size must be greater than zero"
    );
    ensure!(
        config.shuffle_buffer_frames > 0,
        "shuffle buffer size must be greater than zero"
    );
    ensure!(
        config.min_learning_rate.is_finite() && config.min_learning_rate > 0.0,
        "minimum learning rate must be finite and greater than zero"
    );
    ensure!(
        config.max_learning_rate.is_finite()
            && config.max_learning_rate > config.min_learning_rate
            && config.max_learning_rate <= 1.0,
        "maximum learning rate must be finite, greater than the minimum \
        learning rate, and at most 1"
    );
    ensure!(
        config.warmup_fraction.is_finite()
            && config.warmup_fraction > 0.0
            && config.warmup_fraction < 1.0,
        "warmup fraction must be finite and strictly between zero and one"
    );
    ensure!(
        !config.validation_speakers.is_empty(),
        "validation requires at least one held-out speaker"
    );

    config.model.validate().map_err(anyhow::Error::msg)?;

    let artifact_dir = artifact_dir.as_ref();
    std::fs::create_dir_all(artifact_dir)
        .with_context(|| format!("creating artifact directory {}", artifact_dir.display()))?;

    ensure!(
        std::fs::read_dir(artifact_dir)?
            .next()
            .transpose()?
            .is_none(),
        "artifact directory {} must be empty; use a new directory for each run",
        artifact_dir.display()
    );

    let held_out: Vec<&str> = config
        .validation_speakers
        .iter()
        .map(String::as_str)
        .collect();

    let dataset_train =
        VoiceBankDataset::<N>::load(&config.dataset_dir, DatasetSplit::Train, &held_out)
            .context("indexing training audio")?;

    let dataset_valid =
        VoiceBankDataset::<N>::load(&config.dataset_dir, DatasetSplit::Validation, &held_out)
            .context("indexing validation audio")?;

    let device = device.into().inner();
    device.seed(config.seed);

    let autodiff_device = device.clone().autodiff();

    let dataloader_train =
        VoiceBankDataLoader::new(dataset_train, config.batch_size, autodiff_device.clone())?
            .shuffle(config.seed, config.shuffle_buffer_frames)?;

    let steps_per_epoch = dataloader_train.num_items().div_ceil(config.batch_size);

    let total_steps = steps_per_epoch
        .checked_mul(config.num_epochs)
        .context("total training step count overflowed usize")?;

    ensure!(
        total_steps >= 2,
        "training requires at least two optimizer steps"
    );

    let warmup_steps = (total_steps as f64 * config.warmup_fraction).round() as usize;
    let warmup_steps = warmup_steps.clamp(1, total_steps - 1);
    let cosine_steps = total_steps - warmup_steps;

    let lr_scheduler = SequentialLrSchedulerConfig::new(
        vec![
            LinearLrSchedulerConfig::new(
                config.min_learning_rate,
                config.max_learning_rate,
                warmup_steps,
            )
            .into(),
            CosineAnnealingLrSchedulerConfig::new(config.max_learning_rate, cosine_steps)
                .with_min_lr(config.min_learning_rate)
                .into(),
        ],
        vec![warmup_steps],
    )
    .init()
    .map_err(|err| anyhow::anyhow!("initializing learning-rate scheduler: {err}"))?;

    let dataloader_train = Arc::new(dataloader_train);

    let dataloader_valid = Arc::new(VoiceBankDataLoader::new(
        dataset_valid,
        config.batch_size,
        device,
    )?);

    config
        .save(artifact_dir.join("config.json"))
        .context("saving training configuration")?;

    let mut training = SupervisedTraining::new(artifact_dir, dataloader_train, dataloader_valid)
        .metric_train_numeric(LossMetric::new())
        .metric_valid_numeric(LossMetric::new())
        .metric_train_numeric(LearningRateMetric::new());

    if let Some(patience) = config.patience {
        ensure!(
            patience > 0,
            "patience must be greater than zero if early stopping is enabled"
        );

        training = training.early_stopping(MetricEarlyStoppingStrategy::new(
            &LossMetric::new(),
            Aggregate::Mean,
            Direction::Lowest,
            Split::Valid,
            StoppingCondition::NoImprovementSince { n_epochs: patience },
        ));
    }

    training = training
        .with_default_checkpointers()
        .num_epochs(config.num_epochs)
        .summary();

    let interrupter = training.interrupter();
    let model = config.model.init(&autodiff_device);
    let result = training.launch(Learner::new(model, config.optimizer.init(), lr_scheduler));

    // In this Burn prerelease, streaming read failures stop the learner through
    // its interrupter; launch itself does not return a Result.
    ensure!(
        !interrupter.should_stop(),
        "training interrupted: {}",
        interrupter
            .get_message()
            .unwrap_or_else(|| "cancelled".into())
    );

    result
        .model
        .clone()
        .into_record()
        .save(artifact_dir.join("model.bpk"))
        .context("saving trained model")?;

    // launch has joined Burn's metric writer threads before returning, so these
    // logs include their final epoch aggregates without polling or sleeps.
    export::export_metrics(artifact_dir)
        .context("training completed and model.bpk was saved, but exporting metrics failed")?;

    Ok(result.model)
}
