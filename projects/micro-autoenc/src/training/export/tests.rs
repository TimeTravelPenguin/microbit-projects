use std::{fs, path::Path};

use tempfile::tempdir;

use super::export_metrics;

fn write_epoch(directory: &Path, epoch: usize, loss: &str, learning_rate: &str) {
    for (split, metric, contents) in [
        ("train", "Loss", loss),
        ("valid", "Loss", loss),
        ("train", "Learning_Rate", learning_rate),
    ] {
        let epoch_dir = directory.join(split).join(format!("epoch-{epoch}"));
        fs::create_dir_all(&epoch_dir).unwrap();
        fs::write(epoch_dir.join(format!("{metric}.log")), contents).unwrap();
    }
}

fn csv_rows(path: &Path) -> Vec<Vec<String>> {
    fs::read_to_string(path)
        .unwrap()
        .lines()
        .skip(1)
        .map(|line| line.split(',').map(str::to_string).collect())
        .collect()
}

fn assert_graphs_complete(directory: &Path) {
    for name in [
        "loss_by_epoch",
        "learning_rate_by_epoch",
        "train_loss_by_step",
        "valid_loss_by_step",
        "train_learning_rate_by_step",
    ] {
        let svg =
            fs::read_to_string(directory.join("exports").join(format!("{name}.svg"))).unwrap();
        assert!(svg.contains("<svg"), "{name} is not an SVG graph");
        assert!(svg.contains("</svg>"), "{name} has not finished writing");
        assert!(
            svg.contains("<polyline") || svg.contains("<circle"),
            "{name} has no plotted data"
        );
    }
}

#[test]
fn exports_batch_values_and_authoritative_epoch_values_in_numeric_epoch_order() {
    let directory = tempdir().unwrap();

    // Both directory creation order and lexical order differ from epoch order.
    for epoch in [10, 2, 1] {
        write_epoch(
            directory.path(),
            epoch,
            "2,3\n6,1\n3,final\n",
            "0.1,1\n0.3,1\n0.2,final\n",
        );
    }

    export_metrics(directory.path()).unwrap();
    let exports = directory.path().join("exports");
    let batches = csv_rows(&exports.join("train_loss.csv"));
    assert_eq!(batches.len(), 6);

    for (idx, row) in batches.iter().enumerate() {
        assert_eq!(row.len(), 5);
        assert_eq!(row[0].parse::<usize>().unwrap(), [1, 2, 10][idx / 2]);
        assert_eq!(row[1].parse::<usize>().unwrap(), idx % 2 + 1);
        assert_eq!(row[2].parse::<usize>().unwrap(), idx + 1);
        assert_eq!(row[3].parse::<f64>().unwrap(), [2.0, 6.0][idx % 2]);
        assert_eq!(row[4].parse::<usize>().unwrap(), [3, 1][idx % 2]);
    }

    let epochs = csv_rows(&exports.join("epoch_metrics.csv"));
    assert_eq!(epochs.len(), 9);

    for (split, metric, value, weight) in [
        ("train", "Loss", 3.0, 4),
        ("valid", "Loss", 3.0, 4),
        ("train", "Learning Rate", 0.2, 2),
    ] {
        let rows: Vec<_> = epochs
            .iter()
            .filter(|row| row[0] == split && row[1] == metric)
            .collect();
        assert_eq!(rows.len(), 3);

        for (row, epoch) in rows.into_iter().zip([1, 2, 10]) {
            assert_eq!(row[2].parse::<usize>().unwrap(), epoch);
            assert_eq!(row[3].parse::<usize>().unwrap(), 2);
            assert_eq!(row[4].parse::<f64>().unwrap(), value);
            assert_eq!(row[5].parse::<usize>().unwrap(), weight);
        }
    }

    assert_graphs_complete(directory.path());
}

#[test]
fn single_epoch_with_constant_metrics_produces_complete_graphs() {
    let directory = tempdir().unwrap();
    write_epoch(
        directory.path(),
        1,
        "0,1\n0,final\n",
        "0.001,1\n0.001,final\n",
    );

    export_metrics(directory.path()).unwrap();

    assert_graphs_complete(directory.path());
    assert_eq!(
        csv_rows(&directory.path().join("exports/train_loss.csv")).len(),
        1
    );
    assert_eq!(
        csv_rows(&directory.path().join("exports/epoch_metrics.csv")).len(),
        3
    );
}

#[test]
fn invalid_or_incomplete_metric_logs_are_reported() {
    for invalid_loss in ["invalid\n", "NaN,1\nNaN,final\n", "", "1,1\n"] {
        let directory = tempdir().unwrap();
        write_epoch(directory.path(), 1, invalid_loss, "0.001,1\n0.001,final\n");

        let error = export_metrics(directory.path()).unwrap_err();
        let message = format!("{error:#}");
        assert!(
            message.contains("Loss.log"),
            "error should identify the source log: {message}"
        );
    }
}

#[test]
fn full_csv_retains_every_batch_beyond_chart_point_budget() {
    let directory = tempdir().unwrap();
    let batch_count = 10_000;
    let loss = "2,1\n".repeat(batch_count) + "2,final\n";
    let learning_rate = "0.001,1\n".repeat(batch_count) + "0.001,final\n";
    write_epoch(directory.path(), 1, &loss, &learning_rate);

    export_metrics(directory.path()).unwrap();

    for metric in ["train_loss", "valid_loss", "train_learning_rate"] {
        let rows = csv_rows(
            &directory
                .path()
                .join("exports")
                .join(format!("{metric}.csv")),
        );
        assert_eq!(rows.len(), batch_count);

        for (idx, row) in rows.iter().enumerate() {
            assert_eq!(row[0], "1");
            assert_eq!(row[1].parse::<usize>().unwrap(), idx + 1);
            assert_eq!(row[2].parse::<usize>().unwrap(), idx + 1);
            assert_eq!(row[4], "1");
        }
    }

    assert_graphs_complete(directory.path());
}
