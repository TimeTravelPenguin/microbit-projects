use std::{
    path::{Path, PathBuf},
    sync::Arc,
};

use anyhow::{Context, Result, ensure};
use burn::{
    nn::loss::{MseLoss, Reduction},
    optim::AdamConfig,
    prelude::*,
    train::{
        EarlyStoppingStrategy, InferenceStep, Learner, MetricEarlyStoppingStrategy,
        RegressionOutput, StoppingCondition, SupervisedTraining, TrainOutput, TrainStep,
        metric::{
            IterationSpeedMetric, LearningRateMetric, LossMetric,
            store::{Aggregate, Direction, Split},
        },
    },
};

use crate::{
    Autoencoder, AutoencoderConfig,
    dataset::{DatasetSplit, VoiceBankDataLoader, VoiceBankDataset},
};

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

impl<const E: usize, const D: usize> Autoencoder<E, D> {
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
impl<const E: usize, const D: usize> TrainStep for Autoencoder<E, D> {
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
impl<const E: usize, const D: usize> InferenceStep for Autoencoder<E, D> {
    type Input = DenoisingBatch;
    type Output = RegressionOutput;

    fn step(&self, batch: Self::Input) -> Self::Output {
        self.forward_regression(batch)
    }
}

/// Training settings for an encoder with `E` and a decoder with `D` hidden layers.
///
/// Burn 0.22.0-pre.4's `Config` derive does not propagate generics to its generated
/// implementations. Derive Serde directly and implement `Config` below instead.
#[derive(Clone, Debug, burn::serde::Serialize, burn::serde::Deserialize)]
#[serde(crate = "burn::serde")]
pub struct TrainingConfig<const E: usize = 4, const D: usize = 4> {
    pub model: AutoencoderConfig<E, D>,
    pub optimizer: AdamConfig,
    /// Directory containing the downloaded VoiceBank Parquet shards.
    #[serde(default = "default_dataset_dir")]
    pub dataset_dir: PathBuf,
    /// Speakers held out from the source training shards for validation.
    #[serde(default = "default_validation_speakers")]
    pub validation_speakers: Vec<String>,
    pub num_epochs: usize,
    pub batch_size: usize,
    /// Maximum number of frames retained for bounded training shuffling.
    #[serde(default = "default_shuffle_buffer_frames")]
    pub shuffle_buffer_frames: usize,
    pub seed: u64,
    pub learning_rate: f64,
}

impl<const E: usize, const D: usize> TrainingConfig<E, D> {
    pub fn new(model: AutoencoderConfig<E, D>, optimizer: AdamConfig) -> Self {
        Self {
            model,
            optimizer,
            dataset_dir: default_dataset_dir(),
            validation_speakers: default_validation_speakers(),
            num_epochs: 50,
            batch_size: 64,
            shuffle_buffer_frames: default_shuffle_buffer_frames(),
            seed: 42,
            learning_rate: 1.0e-4,
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

    pub fn with_learning_rate(mut self, learning_rate: f64) -> Self {
        self.learning_rate = learning_rate;

        self
    }
}

impl<const E: usize, const D: usize> burn::config::Config for TrainingConfig<E, D> {}

impl<const E: usize, const D: usize> std::fmt::Display for TrainingConfig<E, D> {
    fn fmt(&self, formatter: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        formatter.write_str(&burn::config::config_to_json(self))
    }
}

fn default_dataset_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("../../datasets/VoiceBank-DEMAND-16k/data")
}

fn default_validation_speakers() -> Vec<String> {
    vec!["p282".into(), "p287".into()]
}

const fn default_shuffle_buffer_frames() -> usize {
    4096
}

/// Trains on paired noisy/clean audio, with speaker-disjoint validation each epoch.
///
/// `N` is the frame size and must equal `config.model.input_size()`. `E` and `D`
/// retain the encoder/decoder depths from the configuration. Both splits stream
/// row groups; only training uses the bounded shuffle buffer. Official test
/// shards are never opened here.
///
/// Use a new or empty artifact directory. Saves `config.json`, Burn's metrics and
/// checkpoints, and the final epoch's weights as `model.bpk`. Returns the trained
/// model in inference mode. An interrupted run returns an error without exporting
/// a final model; any completed checkpoints remain available.
pub fn train<const N: usize, const E: usize, const D: usize>(
    artifact_dir: impl AsRef<Path>,
    config: TrainingConfig<E, D>,
    device: impl Into<Device>,
) -> Result<Autoencoder<E, D>> {
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
        config.learning_rate.is_finite() && config.learning_rate > 0.0,
        "learning rate must be finite and greater than zero"
    );
    ensure!(
        !config.validation_speakers.is_empty(),
        "validation requires at least one held-out speaker"
    );

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

    let dataloader_train = Arc::new(
        VoiceBankDataLoader::new(dataset_train, config.batch_size, autodiff_device.clone())?
            .shuffle(config.seed, config.shuffle_buffer_frames)?,
    );

    let dataloader_valid = Arc::new(VoiceBankDataLoader::new(
        dataset_valid,
        config.batch_size,
        device,
    )?);

    config
        .save(artifact_dir.join("config.json"))
        .context("saving training configuration")?;

    let training = SupervisedTraining::new(artifact_dir, dataloader_train, dataloader_valid)
        .metric_train(IterationSpeedMetric::new())
        .metric_train_numeric(LossMetric::new())
        .metric_valid_numeric(LossMetric::new())
        .metric_train_numeric(LearningRateMetric::new())
        .early_stopping(MetricEarlyStoppingStrategy::new(
            &LossMetric::new(),
            Aggregate::Mean,
            Direction::Lowest,
            Split::Valid,
            StoppingCondition::NoImprovementSince { n_epochs: 7 },
        ))
        .with_default_checkpointers()
        .num_epochs(config.num_epochs)
        .summary();

    let interrupter = training.interrupter();
    let model = config.model.init(&autodiff_device);
    let result = training.launch(Learner::new(
        model,
        config.optimizer.init(),
        config.learning_rate,
    ));

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

    Ok(result.model)
}
