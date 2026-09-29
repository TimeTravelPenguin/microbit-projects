#![cfg(feature = "train")]

use std::{fs::File, io::Cursor, path::Path};

use burn::{
    config::Config,
    data::dataloader::{DataLoader, batcher::Batcher},
    module::Module,
    optim::AdamConfig,
    tensor::{Device, Tensor},
    train::InferenceStep,
};
use hound::{SampleFormat, WavSpec, WavWriter};
use micro_autoenc::{
    AutoencoderConfig,
    dataset::{DatasetSplit, DenoisingBatcher, VoiceBankDataLoader, VoiceBankDataset},
    training::{TrainingConfig, train},
};
use polars::prelude::*;
use tempfile::tempdir;

fn wav(samples: &[i16], sample_rate: u32, channels: u16) -> Vec<u8> {
    let mut cursor = Cursor::new(Vec::new());
    let spec = WavSpec {
        channels,
        sample_rate,
        bits_per_sample: 16,
        sample_format: SampleFormat::Int,
    };

    let mut writer = WavWriter::new(&mut cursor, spec).unwrap();

    for sample in samples {
        writer.write_sample(*sample).unwrap();
    }

    writer.finalize().unwrap();

    cursor.into_inner()
}

fn write_shard(
    path: &Path,
    ids: &[Option<&str>],
    clean: &[Option<&[u8]>],
    noisy: &[Option<&[u8]>],
) {
    let audio_column = |name: &str, bytes: &[Option<&[u8]>]| {
        let fields = [
            Series::new("bytes".into(), bytes),
            Series::new("path".into(), vec![None::<&str>; ids.len()]),
        ];

        StructChunked::from_series(name.into(), ids.len(), fields.iter())
            .unwrap()
            .into_series()
            .into_column()
    };

    let mut frame = DataFrame::new(
        ids.len(),
        vec![
            Series::new("id".into(), ids).into_column(),
            audio_column("clean", clean),
            audio_column("noisy", noisy),
        ],
    )
    .unwrap();

    ParquetWriter::new(File::create(path).unwrap())
        .with_row_group_size(Some(1))
        .finish(&mut frame)
        .unwrap();
}

#[test]
fn frames_preserve_pairing_scale_order_and_recording_boundaries() {
    let directory = tempdir().unwrap();
    let clean = wav(
        &[i16::MIN, -16384, 0, 16384, i16::MAX, 8192, -8192],
        16_000,
        1,
    );
    let noisy = wav(&[16384, 0, -16384, i16::MIN, 100, 200, 300], 16_000, 1);

    // Create in reverse order: frame order must still follow sorted filenames.
    for (filename, id) in [
        ("train-00001.parquet", "p227_001"),
        ("train-00000.parquet", "p226_001"),
    ] {
        write_shard(
            &directory.path().join(filename),
            &[Some(id)],
            &[Some(&clean)],
            &[Some(&noisy)],
        );
    }

    let dataset = VoiceBankDataset::<3>::load(directory.path(), DatasetSplit::Train, &[]).unwrap();
    assert_eq!(dataset.recording_count(), 2);
    assert_eq!(dataset.len(), 4);
    let mut frames = dataset.frames();
    let first = frames.next().unwrap().unwrap();
    assert_eq!(&*first.id, "p226_001");
    assert_eq!(first.offset, 0);
    assert_eq!(first.clean, [-1.0, -0.5, 0.0]);
    assert_eq!(first.noisy, [0.5, 0.0, -0.5]);
    let second = frames.next().unwrap().unwrap();
    assert_eq!(second.offset, 3);
    assert_eq!(second.clean, [0.5, 32767.0 / 32768.0, 0.25]);
    assert_eq!(second.noisy, [-1.0, 100.0 / 32768.0, 200.0 / 32768.0]);
    let next_recording = frames.next().unwrap().unwrap();
    assert_eq!(&*next_recording.id, "p227_001");
    assert_eq!(next_recording.offset, 0);
    assert_eq!(next_recording.clean, first.clean);
}

#[test]
fn speaker_holdout_and_test_shards_are_separate() {
    let directory = tempdir().unwrap();
    let audio = wav(&[1, 2, 3, 4], 16_000, 1);
    write_shard(
        &directory.path().join("train-00000.parquet"),
        &[Some("p226_001"), Some("p282_001"), Some("p287_001")],
        &[Some(audio.as_slice()); 3],
        &[Some(audio.as_slice()); 3],
    );

    // A broken test shard must not interfere with train/validation loading.
    std::fs::write(directory.path().join("test-00000.parquet"), b"not parquet").unwrap();
    let held_out = &["p282", "p287"];
    let train =
        VoiceBankDataset::<4>::load(directory.path(), DatasetSplit::Train, held_out).unwrap();
    let validation =
        VoiceBankDataset::<4>::load(directory.path(), DatasetSplit::Validation, held_out).unwrap();
    assert_eq!(train.len(), 1);
    assert_eq!(&*train.frames().next().unwrap().unwrap().id, "p226_001");
    assert_eq!(validation.len(), 2);
    assert_eq!(
        &*validation.frames().next().unwrap().unwrap().id,
        "p282_001"
    );
    assert_eq!(
        &*validation.frames().nth(1).unwrap().unwrap().id,
        "p287_001"
    );

    write_shard(
        &directory.path().join("test-00000.parquet"),
        &[Some("p232_001")],
        &[Some(&audio)],
        &[Some(&audio)],
    );
    std::fs::write(directory.path().join("train-00000.parquet"), b"not parquet").unwrap();
    let test = VoiceBankDataset::<4>::load(directory.path(), DatasetSplit::Test, &["not-present"])
        .unwrap();
    assert_eq!(test.len(), 1);
    assert_eq!(&*test.frames().next().unwrap().unwrap().id, "p232_001");
}

#[test]
fn rejects_invalid_audio_with_recording_context() {
    let directory = tempdir().unwrap();
    let clean = wav(&[1, 2, 3, 4], 16_000, 1);
    let mut truncated = clean.clone();
    truncated.pop();
    let invalid_audio = [
        (wav(&[1, 2], 16_000, 1), "lengths differ"),
        (wav(&[1, 2, 3, 4], 8_000, 1), "16000 Hz"),
        (wav(&[1, 2, 3, 4], 16_000, 2), "mono"),
        (wav(&[], 16_000, 1), "empty"),
        (b"not a WAV".to_vec(), "invalid WAV"),
        (truncated, "truncated"),
    ];

    for (noisy, expected) in invalid_audio {
        write_shard(
            &directory.path().join("train-00000.parquet"),
            &[Some("p226_001")],
            &[Some(&clean)],
            &[Some(&noisy)],
        );
        let error =
            VoiceBankDataset::<2>::load(directory.path(), DatasetSplit::Train, &[]).unwrap_err();
        let message = format!("{error:#}");
        assert!(message.contains(expected), "{message}");
        assert!(message.contains("p226_001"), "{message}");
        assert!(message.contains("train-00000.parquet"), "{message}");
    }
}

#[test]
fn rejects_missing_bytes_ids_and_duplicate_recordings() {
    let directory = tempdir().unwrap();
    let audio = wav(&[1, 2], 16_000, 1);
    let path = directory.path().join("train-00000.parquet");
    let cases = [
        (
            Some("p226_001"),
            None,
            Some(audio.as_slice()),
            "missing clean.bytes",
        ),
        (
            Some("p226_001"),
            Some(audio.as_slice()),
            None,
            "missing noisy.bytes",
        ),
        (
            None,
            Some(audio.as_slice()),
            Some(audio.as_slice()),
            "missing id",
        ),
        (
            Some("bad-id"),
            Some(audio.as_slice()),
            Some(audio.as_slice()),
            "invalid recording id",
        ),
    ];

    for (id, clean, noisy, expected) in cases {
        write_shard(&path, &[id], &[clean], &[noisy]);
        let error =
            VoiceBankDataset::<2>::load(directory.path(), DatasetSplit::Train, &[]).unwrap_err();
        assert!(format!("{error:#}").contains(expected), "{error:#}");
    }

    write_shard(
        &path,
        &[Some("p226_001"); 2],
        &[Some(audio.as_slice()); 2],
        &[Some(audio.as_slice()); 2],
    );
    let error =
        VoiceBankDataset::<2>::load(directory.path(), DatasetSplit::Train, &[]).unwrap_err();
    assert!(format!("{error:#}").contains("duplicate recording"));
}

#[test]
fn rejects_empty_splits_unknown_holdouts_and_zero_frame_size() {
    let directory = tempdir().unwrap();
    assert!(VoiceBankDataset::<2>::load(directory.path(), DatasetSplit::Train, &[]).is_err());
    let audio = wav(&[1, 2], 16_000, 1);
    write_shard(
        &directory.path().join("train-00000.parquet"),
        &[Some("p226_001")],
        &[Some(&audio)],
        &[Some(&audio)],
    );
    assert!(VoiceBankDataset::<0>::load(directory.path(), DatasetSplit::Train, &[]).is_err());
    assert!(VoiceBankDataset::<3>::load(directory.path(), DatasetSplit::Train, &[]).is_err());
    assert!(VoiceBankDataset::<2>::load(directory.path(), DatasetSplit::Validation, &[]).is_err());
    assert!(
        VoiceBankDataset::<2>::load(directory.path(), DatasetSplit::Train, &["unknown"]).is_err()
    );
    assert!(
        VoiceBankDataset::<2>::load(directory.path(), DatasetSplit::Validation, &["unknown"])
            .is_err()
    );
    assert!(VoiceBankDataset::<2>::load(directory.path(), DatasetSplit::Train, &["p226"]).is_err());
}

#[test]
#[should_panic(expected = "out of bounds")]
fn out_of_bounds_slice_matches_burn_loader_contract() {
    let directory = tempdir().unwrap();
    let audio = wav(&[1, 2], 16_000, 1);
    write_shard(
        &directory.path().join("train-00000.parquet"),
        &[Some("p226_001")],
        &[Some(&audio)],
        &[Some(&audio)],
    );
    let dataset = VoiceBankDataset::<2>::load(directory.path(), DatasetSplit::Train, &[]).unwrap();
    let loader = VoiceBankDataLoader::new(dataset, 2, Device::flex()).unwrap();
    let _ = loader.slice(0, loader.num_items() + 1);
}

#[test]
fn batcher_and_streaming_loader_feed_the_existing_model() {
    let directory = tempdir().unwrap();
    let clean = wav(&[8192; 10], 16_000, 1);
    let noisy = wav(&[-16384; 10], 16_000, 1);
    write_shard(
        &directory.path().join("train-00000.parquet"),
        &[Some("p226_001")],
        &[Some(&clean)],
        &[Some(&noisy)],
    );
    let dataset = VoiceBankDataset::<2>::load(directory.path(), DatasetSplit::Train, &[]).unwrap();
    let device = Device::flex();
    let batch = DenoisingBatcher.batch(
        dataset
            .frames()
            .take(2)
            .collect::<Result<Vec<_>, _>>()
            .unwrap(),
        &device,
    );
    assert_eq!(batch.noisy.dims(), [2, 2]);
    assert_eq!(batch.clean.dims(), [2, 2]);
    assert_eq!(
        batch.noisy.to_data().try_to_vec::<f32>().unwrap(),
        vec![-0.5; 4]
    );
    assert_eq!(
        batch.clean.to_data().try_to_vec::<f32>().unwrap(),
        vec![0.25; 4]
    );

    let model = AutoencoderConfig::new(2, 1, [2], [2]).init(&device);
    let output = InferenceStep::step(&model, batch);
    assert!(output.loss.to_data().try_to_vec::<f32>().unwrap()[0].is_finite());

    let loader = VoiceBankDataLoader::new(dataset, 2, device)
        .unwrap()
        .shuffle(42, 3)
        .unwrap();

    let mut samples_seen = 0;

    for batch in loader.iter() {
        let batch = batch.unwrap();
        samples_seen += batch.noisy.dims()[0];
        assert_eq!(batch.clean.dims(), batch.noisy.dims());
        assert!(
            batch
                .noisy
                .to_data()
                .try_to_vec::<f32>()
                .unwrap()
                .iter()
                .all(|sample| *sample == -0.5)
        );
        assert!(
            batch
                .clean
                .to_data()
                .try_to_vec::<f32>()
                .unwrap()
                .iter()
                .all(|sample| *sample == 0.25)
        );
    }

    assert_eq!(samples_seen, 5);
}

fn unique_dataset(directory: &Path) -> VoiceBankDataset<2> {
    let audio: Vec<_> = (0..6)
        .map(|row| {
            let samples: Vec<i16> = (row * 8..row * 8 + 8).collect();

            wav(&samples, 16_000, 1)
        })
        .collect();

    let bytes: Vec<_> = audio.iter().map(|audio| Some(audio.as_slice())).collect();
    write_shard(
        &directory.join("train-00000.parquet"),
        &[
            Some("p226_001"),
            Some("p227_001"),
            Some("p228_001"),
            Some("p229_001"),
            Some("p230_001"),
            Some("p231_001"),
        ],
        &bytes,
        &bytes,
    );

    VoiceBankDataset::load(directory, DatasetSplit::Train, &[]).unwrap()
}

fn frame_order(loader: &dyn DataLoader<micro_autoenc::DenoisingBatch>) -> Vec<i16> {
    let mut order = Vec::new();
    let mut iter = loader.iter();
    assert_eq!(iter.progress().items_processed, 0);
    assert_eq!(iter.progress().items_total, loader.num_items());

    while let Some(batch) = iter.next() {
        let batch = batch.unwrap();
        let noisy = batch.noisy.to_data().try_to_vec::<f32>().unwrap();
        let clean = batch.clean.to_data().try_to_vec::<f32>().unwrap();
        assert_eq!(noisy, clean);
        order.extend(
            clean
                .as_chunks::<2>()
                .0
                .iter()
                .map(|frame| (frame[0] * 32768.0) as i16),
        );
        assert_eq!(iter.progress().items_processed, order.len());
    }

    assert!(iter.progress().is_completed());
    assert!(iter.next().is_none());

    order
}

#[test]
fn streaming_restarts_and_preserves_partial_batches_progress_and_slices() {
    let directory = tempdir().unwrap();
    let dataset = unique_dataset(directory.path());
    let loader = VoiceBankDataLoader::new(dataset, 5, Device::flex()).unwrap();
    let expected: Vec<_> = (0..48).step_by(2).collect();
    assert_eq!(frame_order(&loader), expected);
    assert_eq!(frame_order(&loader), expected);
    let slice = loader.slice(3, 14);
    assert_eq!(frame_order(slice.as_ref()), expected[3..14]);
    assert_eq!(frame_order(slice.slice(2, 8).as_ref()), expected[5..11]);
    assert_eq!(
        frame_order(loader.to_device(&Device::flex()).as_ref()),
        expected
    );
    assert_eq!(loader.slice(24, 24).num_items(), 0);
    assert!(loader.slice(24, 24).iter().next().is_none());
    let sizes: Vec<_> = loader
        .iter()
        .map(|batch| batch.unwrap().noisy.dims()[0])
        .collect();
    assert_eq!(sizes, [5, 5, 5, 5, 4]);
}

#[test]
fn bounded_shuffle_is_reproducible_and_visits_every_frame_once_per_epoch() {
    let directory = tempdir().unwrap();
    let dataset = unique_dataset(directory.path());
    let expected: Vec<_> = (0..48).step_by(2).collect();

    for capacity in [1, 3, 100] {
        let make_loader = || {
            VoiceBankDataLoader::new(dataset.clone(), 5, Device::flex())
                .unwrap()
                .shuffle(42, capacity)
                .unwrap()
        };
        let loader = make_loader();
        let first = frame_order(&loader);
        let second = frame_order(&loader);
        let replica = make_loader();
        assert_eq!(first, frame_order(&replica));
        assert_eq!(second, frame_order(&replica));
        assert_ne!(first, second);

        for mut order in [first, second] {
            order.sort();
            assert_eq!(order, expected);
        }

        let mut subset = frame_order(loader.slice(3, 14).as_ref());
        subset.sort();
        assert_eq!(subset, expected[3..14]);
    }
}

#[test]
fn source_is_read_on_demand_and_io_errors_terminate_iteration() {
    let directory = tempdir().unwrap();
    let audio = wav(&[1, 2, 3, 4], 16_000, 1);

    for (filename, id) in [
        ("train-00000.parquet", "p226_001"),
        ("train-00001.parquet", "p227_001"),
    ] {
        write_shard(
            &directory.path().join(filename),
            &[Some(id)],
            &[Some(&audio)],
            &[Some(&audio)],
        );
    }

    let dataset = VoiceBankDataset::<2>::load(directory.path(), DatasetSplit::Train, &[]).unwrap();
    let mut frames = dataset.frames();
    let loader = VoiceBankDataLoader::new(dataset, 1, Device::flex()).unwrap();
    let mut batches = loader.iter();
    std::fs::remove_file(directory.path().join("train-00001.parquet")).unwrap();
    assert_eq!(&*frames.next().unwrap().unwrap().id, "p226_001");
    assert!(frames.next().unwrap().is_ok());
    assert!(format!("{:#}", frames.next().unwrap().unwrap_err()).contains("train-00001.parquet"));
    assert!(frames.next().is_none());
    assert!(frames.next().is_none());
    assert!(batches.next().unwrap().is_ok());
    assert!(batches.next().unwrap().is_ok());
    assert!(
        batches
            .next()
            .unwrap()
            .unwrap_err()
            .to_string()
            .contains("train-00001.parquet")
    );
    assert!(batches.next().is_none());
    assert_eq!(batches.progress().items_processed, 2);
    assert!(!batches.progress().is_completed());

    // A slice restricted to the surviving row group never opens the missing file.
    assert_eq!(loader.slice(0, 2).iter().count(), 2);
    std::fs::remove_file(directory.path().join("train-00000.parquet")).unwrap();
    assert!(loader.iter().next().unwrap().is_err());
}

#[test]
fn changed_recordings_are_detected_after_indexing() {
    let directory = tempdir().unwrap();
    let audio = wav(&[1, 2, 3, 4], 16_000, 1);
    let path = directory.path().join("train-00000.parquet");
    write_shard(&path, &[Some("p226_001")], &[Some(&audio)], &[Some(&audio)]);
    let dataset = VoiceBankDataset::<2>::load(directory.path(), DatasetSplit::Train, &[]).unwrap();
    write_shard(&path, &[Some("p227_001")], &[Some(&audio)], &[Some(&audio)]);
    let error = dataset.frames().next().unwrap().unwrap_err();
    assert!(format!("{error:#}").contains("ID changed"));

    let shorter = wav(&[1, 2], 16_000, 1);
    write_shard(
        &path,
        &[Some("p226_001")],
        &[Some(&shorter)],
        &[Some(&shorter)],
    );
    let error = dataset.frames().next().unwrap().unwrap_err();
    assert!(format!("{error:#}").contains("length changed"));
}

#[test]
fn invalid_batch_and_shuffle_sizes_are_rejected() {
    let directory = tempdir().unwrap();
    let dataset = unique_dataset(directory.path());
    assert!(VoiceBankDataLoader::new(dataset.clone(), 0, Device::flex()).is_err());
    assert!(
        VoiceBankDataLoader::new(dataset, 2, Device::flex())
            .unwrap()
            .shuffle(42, 0)
            .is_err()
    );
}

#[test]
fn training_streams_audio_for_multiple_epochs_and_exports_reloadable_weights() {
    let directory = tempdir().unwrap();
    let artifact_dir = directory.path().join("run");
    let clean = wav(&[4096; 12], 16_000, 1);
    let noisy = wav(&[8192; 12], 16_000, 1);
    write_shard(
        &directory.path().join("train-00000.parquet"),
        &[Some("p226_001"), Some("p282_001"), Some("p287_001")],
        &[Some(clean.as_slice()); 3],
        &[Some(noisy.as_slice()); 3],
    );

    // Training must validate on held-out training speakers, never test shards.
    std::fs::write(directory.path().join("test-00000.parquet"), b"not parquet").unwrap();
    let model_config = AutoencoderConfig::new(4, 2, [6, 5], [6]).with_dropout([0.1, 0.1], [0.2]);
    let config = TrainingConfig::new(model_config, AdamConfig::new())
        .with_dataset_dir(directory.path())
        .with_num_epochs(2)
        .with_batch_size(2)
        .with_shuffle_buffer_frames(2)
        .with_learning_rate_range(0.0001, 0.01);
    let device = Device::flex();
    let trained = train::<4, 2, 1>(&artifact_dir, config.clone(), device.clone()).unwrap();
    let restored_config = TrainingConfig::<2, 1>::load(artifact_dir.join("config.json")).unwrap();
    assert_eq!(restored_config.to_string(), config.to_string());

    let restored = model_config
        .init(&device)
        .try_load_file(artifact_dir.join("model.bpk"))
        .unwrap()
        .valid();
    let input = Tensor::<2>::from_data([[0.25; 4]], &device);
    let prediction = trained.forward(input.clone()).into_data();
    assert!(prediction.iter::<f32>().all(f32::is_finite));
    assert_eq!(prediction, restored.forward(input.clone()).into_data());
    // The returned model must have dropout disabled.
    assert_eq!(prediction, trained.forward(input.clone()).into_data());

    let first_epoch = model_config
        .init(&device)
        .try_load_file(artifact_dir.join("checkpoint/model-1.bpk"))
        .unwrap()
        .valid();
    assert_ne!(prediction, first_epoch.forward(input).into_data());

    for epoch in 1..=2 {
        // Three training frames include a final partial batch each epoch.
        for (split, batches) in [("train", 2), ("valid", 3)] {
            let log = std::fs::read_to_string(
                artifact_dir.join(format!("{split}/epoch-{epoch}/Loss.log")),
            )
            .unwrap();
            // Burn writes one entry per batch followed by the epoch aggregate.
            assert_eq!(log.lines().count(), batches + 1);
        }

        for component in ["model", "optim", "scheduler"] {
            assert!(
                artifact_dir
                    .join(format!("checkpoint/{component}-{epoch}.bpk"))
                    .is_file()
            );
        }
    }

    // A second run cannot overwrite this run's weights or metrics.
    let error = train::<4, 2, 1>(&artifact_dir, config, device).unwrap_err();
    assert!(error.to_string().contains("must be empty"));
    assert!(artifact_dir.join("model.bpk").is_file());
}

#[test]
fn cli_indexes_trains_and_evaluates_saved_weights() {
    let directory = tempdir().unwrap();
    let artifact_dir = directory.path().join("run with spaces");
    let clean = wav(&[4096; 768], 16_000, 1);
    let noisy = wav(&[8192; 768], 16_000, 1);
    write_shard(
        &directory.path().join("train-00000.parquet"),
        &[Some("p226_001"), Some("p282_001"), Some("p287_001")],
        &[Some(clean.as_slice()); 3],
        &[Some(noisy.as_slice()); 3],
    );

    let run = |args: &[&str]| {
        let output = std::process::Command::new(env!("CARGO_BIN_EXE_micro-autoenc"))
            .args(["--device", "cpu"])
            .args(args)
            .output()
            .unwrap();
        assert!(
            output.status.success(),
            "{args:?}:\n{}\n{}",
            String::from_utf8_lossy(&output.stdout),
            String::from_utf8_lossy(&output.stderr),
        );

        String::from_utf8(output.stdout).unwrap()
    };

    let directory_arg = directory.path().to_str().unwrap();
    let artifact_arg = artifact_dir.to_str().unwrap();
    let indexed = run(&["index", directory_arg, "--split", "validation"]);
    assert!(indexed.contains("2 recordings, 6 paired frames of 256 samples"));

    // Exercise config loading and CLI overrides together. Training must never
    // open the intentionally malformed test shard.
    std::fs::write(directory.path().join("test-00000.parquet"), b"not parquet").unwrap();
    let config_path = directory.path().join("input-config.json");
    TrainingConfig::new(AutoencoderConfig::new(256, 2, [6], [6]), AdamConfig::new())
        .with_dataset_dir("missing-directory")
        .with_learning_rate_range(0.0001, 0.01)
        .with_warmup_fraction(0.25)
        .save(&config_path)
        .unwrap();
    run(&[
        "train",
        directory_arg,
        "--config",
        config_path.to_str().unwrap(),
        "--artifact-dir",
        artifact_arg,
        "--epochs",
        "1",
        "--batch-size",
        "2",
        "--shuffle-buffer-frames",
        "2",
        "--seed",
        "7",
    ]);
    let saved = TrainingConfig::<1, 1>::load(artifact_dir.join("config.json")).unwrap();
    assert_eq!(saved.dataset_dir, directory.path());
    assert_eq!(saved.model.encoder_hidden(), &[6]);
    assert_eq!(saved.model.decoder_hidden(), &[6]);
    assert_eq!(saved.num_epochs, 1);
    assert_eq!(saved.batch_size, 2);
    assert_eq!(saved.shuffle_buffer_frames, 2);
    assert_eq!(saved.min_learning_rate, 0.0001);
    assert_eq!(saved.max_learning_rate, 0.01);
    assert_eq!(saved.warmup_fraction, 0.25);
    assert_eq!(saved.seed, 7);

    let test_samples: Vec<i16> = [4096, 8192, 16384]
        .into_iter()
        .flat_map(|sample| [sample; 256])
        .collect();
    let test_noisy = wav(&test_samples, 16_000, 1);
    let test_clean = wav(&[0; 768], 16_000, 1);
    write_shard(
        &directory.path().join("test-00000.parquet"),
        &[Some("p232_001")],
        &[Some(&test_clean)],
        &[Some(&test_noisy)],
    );

    // Test must use the saved path and the official test split, with no reads of
    // the source training shards and no writes to the saved model/configuration.
    std::fs::write(directory.path().join("train-00000.parquet"), b"not parquet").unwrap();
    let weights_before = std::fs::read(artifact_dir.join("model.bpk")).unwrap();
    let mut predictions = Vec::new();

    for batch_size in ["1", "2"] {
        let output = run(&[
            "test",
            "--artifact-dir",
            artifact_arg,
            "--batch-size",
            batch_size,
        ]);
        assert!(output.contains("Evaluated 3 frames from 1 recordings"));
        assert!(output.contains("Noisy MSE: 0.10937500"));
        let denoised_mse = output
            .lines()
            .find_map(|line| line.strip_prefix("Denoised MSE: "))
            .unwrap()
            .parse::<f64>()
            .unwrap();
        assert!(denoised_mse.is_finite());
        predictions.push(denoised_mse);
    }

    assert!((predictions[0] - predictions[1]).abs() < 1.0e-6);
    assert_eq!(
        std::fs::read(artifact_dir.join("model.bpk")).unwrap(),
        weights_before
    );
    assert_eq!(
        TrainingConfig::<1, 1>::load(artifact_dir.join("config.json"))
            .unwrap()
            .to_string(),
        saved.to_string()
    );
}

#[test]
#[ignore = "requires downloaded data; set MICRO_AUTOENC_DATASET to the Parquet directory"]
fn downloaded_validation_streams_to_completion() {
    let directory = std::env::var_os("MICRO_AUTOENC_DATASET").expect("set MICRO_AUTOENC_DATASET");
    let dataset =
        VoiceBankDataset::<256>::load(directory, DatasetSplit::Validation, &["p282", "p287"])
            .unwrap();
    let expected = dataset.len();
    let mut frames_seen = 0;

    for frame in dataset.frames() {
        let frame = frame.unwrap();
        assert!(frame.id.starts_with("p282_") || frame.id.starts_with("p287_"));
        assert_eq!(frame.offset % 256, 0);
        frames_seen += 1;
    }

    assert_eq!(frames_seen, expected);
    println!(
        "Streamed {frames_seen} frames from {} recordings",
        dataset.recording_count()
    );
}
