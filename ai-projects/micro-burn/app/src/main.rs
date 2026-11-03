use std::{
    path::PathBuf,
    sync::mpsc,
    thread,
    time::{SystemTime, UNIX_EPOCH},
};

use anyhow::{Context, Result};
use clap::Parser;
use micro_burn::host::Monitor;

mod data;
mod model;
mod training;
mod ui;

#[derive(Clone, Debug, Parser)]
#[command(
    version,
    about = "Train a graph neural network and follow it on a micro:bit"
)]
pub struct Args {
    /// Prepared classroom graphs produced by the data preparation script
    #[arg(long, default_value = concat!(env!("CARGO_MANIFEST_DIR"), "/../data/classrooms.json"))]
    pub data: PathBuf,

    /// Parent directory for new, uniquely named run folders
    #[arg(long, default_value = concat!(env!("CARGO_MANIFEST_DIR"), "/../artifacts"))]
    pub artifacts: PathBuf,

    #[arg(long, default_value_t = 200, value_parser = clap::value_parser!(u32).range(1..=10000))]
    pub epochs: u32,

    #[arg(long, default_value_t = 0.01)]
    pub learning_rate: f64,

    #[arg(long, default_value_t = 42)]
    pub seed: u64,

    /// Train and save results without opening a window (Bluetooth is not scanned)
    #[arg(long)]
    pub headless: bool,
}

pub fn new_run_directory(args: &Args) -> PathBuf {
    let timestamp = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_millis();

    args.artifacts.join(format!("run-{timestamp}"))
}

fn main() -> Result<()> {
    let args = Args::parse();

    anyhow::ensure!(
        args.learning_rate.is_finite() && args.learning_rate > 0.0 && args.learning_rate <= 1.0,
        "learning rate must be finite and in (0, 1]"
    );

    if !args.headless {
        return ui::run(args).context("running the training window");
    }

    let monitor = Monitor::new(
        "Classroom GCN",
        Some(args.artifacts.join("pager-state.json")),
    )
    .context("starting the training monitor")?;
    let reporter = monitor.reporter.clone();
    reporter.begin_run("Classroom GCN");
    let (events, receiver) = mpsc::sync_channel(64);
    let printer = thread::spawn(move || {
        while let Ok(event) = receiver.recv() {
            if let training::TrainingEvent::Snapshot(snapshot) = event {
                println!(
                    "{:?}: epoch {}/{} train={:?} validation={:?}",
                    snapshot.phase,
                    snapshot.epoch,
                    snapshot.epochs,
                    snapshot.train_loss,
                    snapshot.valid_loss,
                );
            }
        }
    });

    let config = training::TrainingConfig {
        epochs: args.epochs as usize,
        learning_rate: args.learning_rate,
        seed: args.seed,
    };

    let result = training::train(
        config,
        &args.data,
        &new_run_directory(&args),
        reporter,
        events,
    );
    let _ = printer.join();
    let results = result?;
    println!("{}", results.summary);
    println!("Results saved in {}", results.artifact_dir.display());

    Ok(())
}
