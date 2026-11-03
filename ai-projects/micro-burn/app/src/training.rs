//! A small real Burn experiment with explicit outcomes and optional device reporting.

use std::{
    fs,
    path::{Path, PathBuf},
    sync::mpsc::SyncSender,
    time::Instant,
};

use anyhow::{Context, Result, ensure};
use burn::{
    module::Module,
    nn::loss::{MseLoss, Reduction},
    optim::{AdamConfig, GradientsParams},
    tensor::{Device, Tensor},
};
use micro_burn::{
    host::Reporter,
    protocol::{Phase, Snapshot},
};
use serde::{Deserialize, Serialize};

use crate::{
    data::{Dataset, GraphBatch},
    model::GradeRegressor,
};

pub const HIDDEN_WIDTH: usize = 32;
/// Additional hidden layers after the first message-passing/input layer.
pub const HIDDEN_LAYERS: usize = 2;

#[derive(Clone, Debug, Deserialize, Serialize)]
pub struct TrainingConfig {
    pub epochs: usize,
    pub learning_rate: f64,
    pub seed: u64,
}

impl Default for TrainingConfig {
    fn default() -> Self {
        Self {
            epochs: 200,
            learning_rate: 0.01,
            seed: 42,
        }
    }
}

#[derive(Clone, Debug)]
pub enum TrainingEvent {
    Snapshot(Snapshot),
    Finished(std::result::Result<TrainingResults, String>),
}

#[derive(Clone, Debug, Deserialize, Serialize)]
pub struct ModelMetrics {
    pub name: String,
    pub mae: f64,
    pub rmse: f64,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
pub struct TrainingResults {
    pub model_metrics: Vec<ModelMetrics>,
    pub best_epoch: usize,
    pub artifact_dir: PathBuf,
    pub summary: String,
}

#[derive(Serialize)]
struct EpochMetrics {
    epoch: usize,
    gnn_train_mse: f64,
    gnn_validation_mse: f64,
    mlp_train_mse: f64,
    mlp_validation_mse: f64,
}

#[derive(Serialize)]
struct Prediction {
    student_id: String,
    classroom_id: String,
    actual: f32,
    gnn: f32,
    mlp: f32,
    prior_grade: f32,
    training_mean: f64,
}

pub fn train(
    config: TrainingConfig,
    data_path: &Path,
    artifact_dir: &Path,
    reporter: Reporter,
    events: SyncSender<TrainingEvent>,
) -> Result<TrainingResults> {
    let started = Instant::now();
    let result = train_inner(
        &config,
        data_path,
        artifact_dir,
        &reporter,
        &events,
        started,
    );

    if result.is_err() {
        let mut snapshot = reporter.snapshot();
        snapshot.phase = Phase::Failed;
        snapshot.elapsed_secs = started.elapsed().as_secs().min(u64::from(u32::MAX)) as u32;
        publish(&reporter, &events, snapshot);
    }

    result
}

fn train_inner(
    config: &TrainingConfig,
    data_path: &Path,
    artifact_dir: &Path,
    reporter: &Reporter,
    events: &SyncSender<TrainingEvent>,
    started: Instant,
) -> Result<TrainingResults> {
    ensure!(
        (1..=10_000).contains(&config.epochs),
        "epochs must be between 1 and 10000"
    );
    ensure!(
        config.learning_rate.is_finite()
            && config.learning_rate > 0.0
            && config.learning_rate <= 1.0,
        "learning rate must be finite and between 0 and 1"
    );

    let mut snapshot = reporter.snapshot();
    snapshot.phase = Phase::Preparing;
    snapshot.epochs = config.epochs as u16;
    snapshot.learning_rate = Some(config.learning_rate as f32);
    publish(reporter, events, snapshot);

    let dataset = Dataset::load(data_path)?;
    let scaling = dataset.fit_scaling();
    let training_mean = dataset.target_mean();
    fs::create_dir_all(artifact_dir).context("creating artifact directory")?;
    ensure!(
        fs::read_dir(artifact_dir)?.next().is_none(),
        "artifact directory must be empty"
    );

    let device = Device::flex();
    device.seed(config.seed);
    let training_device = device.clone().autodiff();
    let train_batch = dataset.batch("train", scaling, &training_device);
    let validation_batch = dataset.batch("validation", scaling, &device);
    let mut gnn = GradeRegressor::new(HIDDEN_WIDTH, HIDDEN_LAYERS, &training_device);
    let mut mlp = GradeRegressor::new(HIDDEN_WIDTH, HIDDEN_LAYERS, &training_device);
    let mut gnn_optimizer = AdamConfig::new().init();
    let mut mlp_optimizer = AdamConfig::new().init();
    let mut best_gnn = gnn.valid();
    let mut best_mlp = mlp.valid();
    let mut best_gnn_loss = f64::INFINITY;
    let mut best_mlp_loss = f64::INFINITY;
    let mut best_epoch = 0;
    let mut mlp_best_epoch = 0;
    let mut history = Vec::with_capacity(config.epochs);

    for epoch in 1..=config.epochs {
        let mut snapshot = reporter.snapshot();
        snapshot.phase = Phase::Training;
        snapshot.epoch = epoch as u16;
        snapshot.valid_loss = None;
        snapshot.progress_permille = (((epoch - 1) * 1000) / config.epochs) as u16;
        publish(reporter, events, snapshot);

        let gnn_loss = loss(&gnn, &train_batch, true);
        let gnn_train_mse = f64::from(gnn_loss.clone().into_scalar::<f32>());
        let gnn_grads = GradientsParams::from_grads(gnn_loss.backward(), &gnn);
        gnn = gnn_optimizer.step(config.learning_rate, gnn, gnn_grads);

        let mlp_loss = loss(&mlp, &train_batch, false);
        let mlp_train_mse = f64::from(mlp_loss.clone().into_scalar::<f32>());
        let mlp_grads = GradientsParams::from_grads(mlp_loss.backward(), &mlp);
        mlp = mlp_optimizer.step(config.learning_rate, mlp, mlp_grads);

        let mut snapshot = reporter.snapshot();
        snapshot.phase = Phase::Validating;
        snapshot.train_loss = Some(gnn_train_mse as f32);
        publish(reporter, events, snapshot);

        let gnn_validation_mse =
            f64::from(loss(&gnn.valid(), &validation_batch, true).into_scalar::<f32>());
        let mlp_validation_mse =
            f64::from(loss(&mlp.valid(), &validation_batch, false).into_scalar::<f32>());
        ensure!(
            [
                gnn_train_mse,
                mlp_train_mse,
                gnn_validation_mse,
                mlp_validation_mse
            ]
            .iter()
            .all(|value| value.is_finite()),
            "training produced a non-finite loss"
        );

        if gnn_validation_mse < best_gnn_loss {
            best_gnn = gnn.valid();
            best_gnn_loss = gnn_validation_mse;
            best_epoch = epoch;
        }

        if mlp_validation_mse < best_mlp_loss {
            best_mlp = mlp.valid();
            best_mlp_loss = mlp_validation_mse;
            mlp_best_epoch = epoch;
        }

        history.push(EpochMetrics {
            epoch,
            gnn_train_mse,
            gnn_validation_mse,
            mlp_train_mse,
            mlp_validation_mse,
        });

        let mut snapshot = reporter.snapshot();
        snapshot.valid_loss = Some(gnn_validation_mse as f32);
        snapshot.progress_permille = ((epoch * 1000) / config.epochs) as u16;
        let elapsed = started.elapsed().as_secs_f64();
        snapshot.elapsed_secs = elapsed.min(f64::from(u32::MAX)) as u32;
        snapshot.eta_secs = Some(
            (elapsed / epoch as f64 * (config.epochs - epoch) as f64).min(f64::from(u32::MAX - 1))
                as u32,
        );
        publish(reporter, events, snapshot);
    }

    let mut snapshot = reporter.snapshot();
    snapshot.phase = Phase::Evaluating;
    snapshot.eta_secs = None;
    publish(reporter, events, snapshot);

    // Test labels are first evaluated after both checkpoints have been selected.
    let test_batch = dataset.batch("test", scaling, &device);
    let gnn_predictions = predictions(&best_gnn, &test_batch, true)?;
    let mlp_predictions = predictions(&best_mlp, &test_batch, false)?;
    let mean_predictions = vec![training_mean as f32; test_batch.target_values.len()];
    let model_metrics = vec![
        metrics(
            &format!("GCN ({} hops)", HIDDEN_LAYERS + 1),
            &gnn_predictions,
            &test_batch.target_values,
        )?,
        metrics(
            "Feature-only MLP",
            &mlp_predictions,
            &test_batch.target_values,
        )?,
        metrics(
            "Prior grade",
            &test_batch.prior_grades,
            &test_batch.target_values,
        )?,
        metrics(
            "Training mean",
            &mean_predictions,
            &test_batch.target_values,
        )?,
    ];
    let summary = format!(
        "{} held-out students; GCN MAE {:.3}, prior-grade MAE {:.3}. Selected epoch {} by validation MSE.",
        test_batch.target_values.len(),
        model_metrics[0].mae,
        model_metrics[2].mae,
        best_epoch,
    );
    let results = TrainingResults {
        model_metrics,
        best_epoch,
        artifact_dir: artifact_dir.to_path_buf(),
        summary,
    };

    let mut snapshot = reporter.snapshot();
    snapshot.phase = Phase::Saving;
    snapshot.mae = Some(results.model_metrics[0].mae as f32);
    snapshot.rmse = Some(results.model_metrics[0].rmse as f32);
    publish(reporter, events, snapshot);

    best_gnn
        .into_record()
        .save(artifact_dir.join("gnn.bpk"))
        .context("saving GCN weights")?;
    best_mlp
        .into_record()
        .save(artifact_dir.join("mlp.bpk"))
        .context("saving MLP weights")?;
    save_json(
        &artifact_dir.join("config.json"),
        &serde_json::json!({
            "training": config,
            "model": {
                "hidden_width": HIDDEN_WIDTH,
                "hidden_layers": HIDDEN_LAYERS,
                "message_passing_layers": HIDDEN_LAYERS + 1,
                "output_features": 1,
            },
            "gnn_best_epoch": best_epoch,
            "mlp_best_epoch": mlp_best_epoch,
            "selection": "minimum student-weighted validation MSE, earliest epoch on ties",
            "backend": "Burn Flex CPU",
        }),
    )?;
    save_json(
        &artifact_dir.join("data-provenance.json"),
        &serde_json::json!({
            "source": dataset.source,
            "preprocessing": dataset.preprocessing,
            "split": dataset.split,
            "feature_scaling": scaling,
            "training_target_mean": training_mean,
        }),
    )?;
    save_json(&artifact_dir.join("metrics.json"), &results)?;
    save_json(&artifact_dir.join("history.json"), &history)?;

    let prediction_rows: Vec<_> = test_batch
        .student_ids
        .iter()
        .enumerate()
        .map(|(idx, student_id)| Prediction {
            student_id: student_id.clone(),
            classroom_id: test_batch.classroom_ids[idx].clone(),
            actual: test_batch.target_values[idx],
            gnn: gnn_predictions[idx],
            mlp: mlp_predictions[idx],
            prior_grade: test_batch.prior_grades[idx],
            training_mean,
        })
        .collect();
    save_json(&artifact_dir.join("predictions.json"), &prediction_rows)?;

    let mut snapshot = reporter.snapshot();
    snapshot.phase = Phase::Succeeded;
    snapshot.progress_permille = 1000;
    snapshot.eta_secs = Some(0);
    snapshot.elapsed_secs = started.elapsed().as_secs().min(u64::from(u32::MAX)) as u32;
    publish(reporter, events, snapshot);

    Ok(results)
}

fn loss(model: &GradeRegressor, batch: &GraphBatch, graph: bool) -> Tensor<1> {
    let adjacency = graph.then(|| batch.adjacency.clone());
    MseLoss::new().forward(
        model.forward(batch.features.clone(), adjacency),
        batch.targets.clone(),
        Reduction::Mean,
    )
}

fn predictions(model: &GradeRegressor, batch: &GraphBatch, graph: bool) -> Result<Vec<f32>> {
    model
        .forward(
            batch.features.clone(),
            graph.then(|| batch.adjacency.clone()),
        )
        .to_data()
        .try_to_vec::<f32>()
        .context("reading prediction values")
}

fn metrics(name: &str, predictions: &[f32], targets: &[f32]) -> Result<ModelMetrics> {
    ensure!(
        !targets.is_empty() && predictions.len() == targets.len(),
        "invalid evaluation counts"
    );
    let mut absolute = 0.0;
    let mut squared = 0.0;

    for (&prediction, &target) in predictions.iter().zip(targets) {
        ensure!(
            prediction.is_finite() && target.is_finite(),
            "non-finite evaluation result"
        );
        let error = f64::from(prediction) - f64::from(target);
        absolute += error.abs();
        squared += error * error;
    }

    Ok(ModelMetrics {
        name: name.to_owned(),
        mae: absolute / targets.len() as f64,
        rmse: (squared / targets.len() as f64).sqrt(),
    })
}

fn save_json(path: &Path, value: &impl Serialize) -> Result<()> {
    fs::write(path, serde_json::to_vec_pretty(value)?)
        .with_context(|| format!("saving {}", path.display()))
}

fn publish(reporter: &Reporter, events: &SyncSender<TrainingEvent>, snapshot: Snapshot) {
    if let Ok(snapshot) = reporter.publish(snapshot) {
        let _ = events.try_send(TrainingEvent::Snapshot(snapshot));
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use micro_burn::host::Monitor;
    use std::sync::mpsc::sync_channel;

    #[test]
    fn a_short_real_run_saves_results_before_success() {
        let temporary = tempfile::tempdir().unwrap();
        let artifacts = temporary.path().join("run");
        let monitor = Monitor::new("test", None).unwrap();
        monitor.reporter.begin_run("classroom-test");
        let (events, _) = sync_channel(1);
        let results = train(
            TrainingConfig {
                epochs: 2,
                ..TrainingConfig::default()
            },
            &Path::new(env!("CARGO_MANIFEST_DIR")).join("../data/classrooms.json"),
            &artifacts,
            monitor.reporter.clone(),
            events,
        )
        .unwrap();

        assert_eq!(results.model_metrics.len(), 4);
        assert!((1..=2).contains(&results.best_epoch));

        for filename in [
            "gnn.bpk",
            "mlp.bpk",
            "config.json",
            "metrics.json",
            "predictions.json",
            "history.json",
        ] {
            assert!(artifacts.join(filename).is_file());
        }

        let dataset =
            Dataset::load(&Path::new(env!("CARGO_MANIFEST_DIR")).join("../data/classrooms.json"))
                .unwrap();
        let device = Device::flex();
        let batch = dataset.batch("test", dataset.fit_scaling(), &device);
        let saved_config: serde_json::Value =
            serde_json::from_slice(&fs::read(artifacts.join("config.json")).unwrap()).unwrap();
        let hidden_width = saved_config["model"]["hidden_width"].as_u64().unwrap() as usize;
        let hidden_layers = saved_config["model"]["hidden_layers"].as_u64().unwrap() as usize;
        assert_eq!(
            saved_config["model"]["message_passing_layers"].as_u64(),
            Some((hidden_layers + 1) as u64)
        );

        let loaded = GradeRegressor::new(hidden_width, hidden_layers, &device)
            .try_load_file(artifacts.join("gnn.bpk"))
            .unwrap()
            .valid();
        let restored = predictions(&loaded, &batch, true).unwrap();
        let saved: serde_json::Value =
            serde_json::from_slice(&fs::read(artifacts.join("predictions.json")).unwrap()).unwrap();

        for (prediction, row) in restored.iter().zip(saved.as_array().unwrap()) {
            assert!((f64::from(*prediction) - row["gnn"].as_f64().unwrap()).abs() < 1.0e-6);
        }

        assert_eq!(monitor.reporter.snapshot().phase, Phase::Succeeded);
    }

    #[test]
    fn save_path_failure_cannot_report_success() {
        let temporary = tempfile::tempdir().unwrap();
        let artifacts = temporary.path().join("not-a-directory");
        fs::write(&artifacts, "existing file").unwrap();
        let monitor = Monitor::new("test", None).unwrap();
        monitor.reporter.begin_run("failure-test");
        let (events, _) = sync_channel(1);
        let outcome = train(
            TrainingConfig {
                epochs: 1,
                ..TrainingConfig::default()
            },
            &Path::new(env!("CARGO_MANIFEST_DIR")).join("../data/classrooms.json"),
            &artifacts,
            monitor.reporter.clone(),
            events,
        );
        assert!(outcome.is_err());
        assert_eq!(monitor.reporter.snapshot().phase, Phase::Failed);
    }
}
