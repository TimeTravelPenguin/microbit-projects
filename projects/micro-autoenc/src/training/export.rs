//! Export Burn's completed numeric logs without retaining all batches in memory.

use std::{
    collections::BTreeMap,
    fs::{self, File},
    io::{BufRead, BufReader},
    path::{Path, PathBuf},
};

use anyhow::{Context, Result, ensure};
use plotters::prelude::*;

const PLOT_BUCKETS: usize = 2048;
type Point = (f64, f64);

struct EpochLog {
    epoch: usize,
    path: PathBuf,
    summary: Summary,
}

#[derive(Debug, PartialEq)]
struct Summary {
    batches: usize,
    weight: u64,
    value: String,
}

struct MetricSeries {
    split: String,
    name: String,
    logs: Vec<EpochLog>,
}

/// Export every registered numeric metric from the completed epochs on disk.
pub(super) fn export_metrics(artifact_dir: &Path) -> Result<()> {
    let series = discover_series(artifact_dir)?;
    let output_dir = artifact_dir.join("exports");
    fs::create_dir_all(&output_dir)?;

    let mut epochs_csv = csv::Writer::from_path(output_dir.join("epoch_metrics.csv"))?;
    epochs_csv.write_record(["split", "metric", "epoch", "batches", "value", "weight"])?;
    let mut epoch_plots: BTreeMap<String, Vec<(String, Vec<Point>)>> = BTreeMap::new();

    for metric in series {
        let stem = metric.name.to_ascii_lowercase();
        let label = metric.name.replace('_', " ");
        let filename = format!("{}_{}", metric.split, stem);
        let mut batches_csv = csv::Writer::from_path(output_dir.join(format!("{filename}.csv")))?;
        batches_csv.write_record(["epoch", "batch", "step", "value", "weight"])?;

        let total_batches: usize = metric.logs.iter().map(|log| log.summary.batches).sum();
        let mut envelope = Envelope::new(total_batches.div_ceil(PLOT_BUCKETS));
        let mut epoch_values = Vec::with_capacity(metric.logs.len());
        let mut step = 0_usize;

        for log in metric.logs {
            let summary = read_log(&log.path, |batch, value, weight| {
                step += 1;
                batches_csv.serialize((log.epoch, batch, step, value, weight))?;
                envelope.push((step as f64, value.parse()?));

                Ok(())
            })?;

            ensure!(
                summary == log.summary,
                "metric log changed during export: {}",
                log.path.display()
            );
            epochs_csv.serialize((
                &metric.split,
                &label,
                log.epoch,
                summary.batches,
                &summary.value,
                summary.weight,
            ))?;
            epoch_values.push((log.epoch as f64, summary.value.parse()?));
        }

        batches_csv.flush()?;
        let points = envelope.finish();
        let subtitle = if total_batches > PLOT_BUCKETS {
            "First, minimum, maximum and last per interval; CSV retains every batch"
        } else {
            "Every batch shown; epoch aggregates excluded"
        };

        plot(
            &output_dir.join(format!("{filename}_by_step.svg")),
            &format!("{} - {label} by batch", metric.split),
            subtitle,
            "Batch step within this split",
            &label,
            &[(metric.split.clone(), points)],
        )?;
        epoch_plots
            .entry(metric.name)
            .or_default()
            .push((metric.split, epoch_values));
    }

    epochs_csv.flush()?;

    for (name, curves) in epoch_plots {
        let label = name.replace('_', " ");
        plot(
            &output_dir.join(format!("{}_by_epoch.svg", name.to_ascii_lowercase())),
            &format!("{label} by epoch"),
            "Logged epoch aggregates (learning rate is its epoch mean)",
            "Epoch",
            &label,
            &curves,
        )?;
    }

    fs::write(output_dir.join("README.txt"), EXPORT_NOTES)?;

    Ok(())
}

fn discover_series(artifact_dir: &Path) -> Result<Vec<MetricSeries>> {
    let mut groups: BTreeMap<(String, String), Vec<(usize, PathBuf)>> = BTreeMap::new();

    for split in ["train", "valid"] {
        for entry in fs::read_dir(artifact_dir.join(split))
            .with_context(|| format!("reading {split} metric logs"))?
        {
            let entry = entry?;

            if !entry.file_type()?.is_dir() {
                continue;
            }

            let directory_name = entry.file_name();
            let Some(epoch_text) = directory_name
                .to_str()
                .and_then(|name| name.strip_prefix("epoch-"))
            else {
                continue;
            };

            let epoch = epoch_text
                .parse::<usize>()
                .context("invalid metric epoch directory")?;
            ensure!(epoch > 0, "metric epochs must start at one");

            for metric in fs::read_dir(entry.path())? {
                let path = metric?.path();

                if path.extension().is_none_or(|extension| extension != "log") {
                    continue;
                }

                let name = path
                    .file_stem()
                    .and_then(|name| name.to_str())
                    .context("invalid metric filename")?;
                groups
                    .entry((split.to_owned(), name.to_owned()))
                    .or_default()
                    .push((epoch, path));
            }
        }
    }

    ensure!(!groups.is_empty(), "no numeric metric logs to export");
    let mut series = Vec::with_capacity(groups.len());

    for ((split, name), mut paths) in groups {
        paths.sort_by_key(|(epoch, _)| *epoch);
        ensure!(
            paths.windows(2).all(|pair| pair[0].0 != pair[1].0),
            "duplicate epochs for {split}/{name}"
        );
        let logs = paths
            .into_iter()
            .map(|(epoch, path)| {
                let summary = read_log(&path, |_, _, _| Ok(()))?;

                Ok(EpochLog {
                    epoch,
                    path,
                    summary,
                })
            })
            .collect::<Result<_>>()?;
        series.push(MetricSeries { split, name, logs });
    }

    Ok(series)
}

/// Burn 0.22.0-pre.4 writes `value,weight` per batch, then `value,final`.
/// The final entry is authoritative and is never treated as another batch.
fn read_log(path: &Path, mut batch: impl FnMut(usize, &str, u64) -> Result<()>) -> Result<Summary> {
    let mut parse = || -> Result<Summary> {
        let mut batches = 0;
        let mut weight = 0_u64;
        let mut final_value = None;

        for (index, line) in BufReader::new(File::open(path)?).lines().enumerate() {
            let line = line?;
            ensure!(
                final_value.is_none(),
                "entry after final aggregate on line {}",
                index + 1
            );
            let (value, count) = line
                .split_once(',')
                .context("expected value,weight or value,final")?;
            let numeric: f64 = value.parse().context("invalid metric value")?;
            ensure!(
                numeric.is_finite(),
                "non-finite metric on line {}",
                index + 1
            );

            if count == "final" {
                final_value = Some(value.to_owned());
                continue;
            }

            let count: u64 = count.parse().context("invalid metric weight")?;
            ensure!(count > 0, "metric weight must be positive");
            weight = weight
                .checked_add(count)
                .context("metric weight overflow")?;
            batches += 1;
            batch(batches, value, count)?;
        }

        ensure!(batches > 0, "metric log has no batches");
        let value = final_value.context("metric log is missing its final aggregate")?;

        Ok(Summary {
            batches,
            weight,
            value,
        })
    };

    parse().with_context(|| format!("reading metric log {}", path.display()))
}

/// At most four points per interval preserve spikes and endpoints in source order.
/// This bounds SVG size and memory independently of the total batch count.
struct Envelope {
    interval: usize,
    count: usize,
    first: Point,
    last: Point,
    minimum: Point,
    maximum: Point,
    points: Vec<Point>,
}

impl Envelope {
    fn new(interval: usize) -> Self {
        Self {
            interval,
            count: 0,
            first: (0.0, 0.0),
            last: (0.0, 0.0),
            minimum: (0.0, 0.0),
            maximum: (0.0, 0.0),
            points: Vec::new(),
        }
    }

    fn push(&mut self, point: Point) {
        if self.count == 0 {
            self.first = point;
            self.minimum = point;
            self.maximum = point;
        }

        self.last = point;

        if point.1 < self.minimum.1 {
            self.minimum = point;
        }

        if point.1 > self.maximum.1 {
            self.maximum = point;
        }

        self.count += 1;

        if self.count == self.interval {
            self.flush();
        }
    }

    fn flush(&mut self) {
        if self.count == 0 {
            return;
        }

        let mut points = [self.first, self.minimum, self.maximum, self.last];
        points.sort_by(|left, right| left.0.total_cmp(&right.0));

        for point in points {
            if self
                .points
                .last()
                .is_none_or(|previous| previous.0 != point.0)
            {
                self.points.push(point);
            }
        }

        self.count = 0;
    }

    fn finish(mut self) -> Vec<Point> {
        self.flush();

        self.points
    }
}

fn plot(
    path: &Path,
    title: &str,
    subtitle: &str,
    x_label: &str,
    y_label: &str,
    curves: &[(String, Vec<Point>)],
) -> Result<()> {
    let mut x_max = 1.0_f64;
    let mut y_min = f64::INFINITY;
    let mut y_max = f64::NEG_INFINITY;

    for (_, points) in curves {
        for &(step, value) in points {
            x_max = x_max.max(step);
            y_min = y_min.min(value);
            y_max = y_max.max(value);
        }
    }

    ensure!(
        y_min.is_finite() && y_max.is_finite(),
        "no finite values to plot"
    );
    let padding = if y_max > y_min {
        (y_max - y_min) * 0.08
    } else {
        y_max.abs().max(1.0e-6) * 0.08
    };
    let root = SVGBackend::new(path, (1200, 720)).into_drawing_area();
    root.fill(&WHITE)?;
    let (body, footer) = root.split_vertically(675);
    let mut chart = ChartBuilder::on(&body)
        .caption(title, ("sans-serif", 27))
        .margin(24)
        .x_label_area_size(45)
        .y_label_area_size(95)
        .build_cartesian_2d(0.5..(x_max + 0.5), (y_min - padding)..(y_max + padding))?;
    chart
        .configure_mesh()
        .x_desc(x_label)
        .y_desc(y_label)
        .x_labels((x_max as usize).min(10))
        .y_labels(8)
        .x_label_formatter(&|value| format!("{value:.0}"))
        .y_label_formatter(&|value| format!("{value:.3e}"))
        .light_line_style(RGBColor(230, 235, 240))
        .draw()?;

    for (label, points) in curves {
        let color = if label == "valid" {
            RGBColor(198, 89, 40)
        } else {
            RGBColor(23, 105, 160)
        };
        chart
            .draw_series(LineSeries::new(
                points.iter().copied(),
                color.stroke_width(2),
            ))?
            .label(label)
            .legend(move |(x, y)| {
                PathElement::new(vec![(x, y), (x + 24, y)], color.stroke_width(2))
            });

        // Epoch plots and single-batch runs remain visible even with one point.
        if points.len() <= 200 {
            chart.draw_series(
                points
                    .iter()
                    .map(|point| Circle::new(*point, 3, color.filled())),
            )?;
        }
    }

    chart
        .configure_series_labels()
        .background_style(WHITE.mix(0.9))
        .border_style(RGBColor(210, 218, 224))
        .draw()?;
    footer.draw(&Text::new(
        subtitle,
        (24, 23),
        ("sans-serif", 16).into_font().color(&RGBColor(75, 90, 105)),
    ))?;
    root.present()
        .with_context(|| format!("saving graph {}", path.display()))?;

    Ok(())
}

const EXPORT_NOTES: &str = "Generated automatically after training with Plotters.\n\nEach <split>_<metric>.csv contains every logged batch, in numeric epoch order.\nColumns: epoch, batch (1-based within epoch), step (1-based within this split/metric), value, weight.\nOriginal metric decimal strings are preserved. Weights are Burn aggregation weights, not sample counts.\n\nepoch_metrics.csv contains only Burn's authoritative final epoch aggregates.\nLearning Rate's final value is the epoch mean, not the last optimizer learning rate.\nWith the current scalar MSE loss, weights are 1 per batch, so epoch loss is a mean of batch means.\n\nAll completed epochs are plotted. Batch graphs keep the first, minimum, maximum and last\npoint from each of at most 2048 consecutive intervals, in source order, preserving spikes.\nThe CSV files are never downsampled. Epoch graphs include all epoch aggregates.\nOnly metric values are exported; config.json and model.bpk remain in the run directory.\n";

#[cfg(test)]
mod tests;
