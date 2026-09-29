#![cfg(feature = "train")]

use burn::{config::Config, optim::AdamConfig, tensor::Device};
use micro_autoenc::{
    AutoencoderConfig,
    training::{TrainingConfig, train},
};
use tempfile::tempdir;

#[test]
fn generic_training_config_roundtrips_through_burn_file_api() {
    let model = AutoencoderConfig::new(8, 2, [6, 4], [5]).with_dropout([0.1, 0.2], [0.3]);
    let mut config: TrainingConfig<2, 1> = TrainingConfig::new(model, AdamConfig::new())
        .with_num_epochs(3)
        .with_batch_size(7)
        .with_dataset_dir("audio/shards")
        .with_validation_speakers(vec!["p282".into()])
        .with_shuffle_buffer_frames(13)
        .with_seed(11)
        .with_learning_rate_range(0.0001, 0.001)
        .with_warmup_fraction(0.2);
    config.patience = Some(4);

    let directory = tempdir().unwrap();
    let path = directory.path().join("config.json");
    config.save(&path).unwrap();
    let restored = TrainingConfig::<2, 1>::load(&path).unwrap();

    assert_eq!(restored.model.input_size(), 8);
    assert_eq!(restored.model.latent_size(), 2);
    assert_eq!(restored.model.encoder_hidden(), &[6, 4]);
    assert_eq!(restored.model.decoder_hidden(), &[5]);
    assert_eq!(restored.model.encoder_dropout(), &[0.1, 0.2]);
    assert_eq!(restored.model.decoder_dropout(), &[0.3]);
    assert_eq!(restored.num_epochs, 3);
    assert_eq!(restored.batch_size, 7);
    assert_eq!(restored.dataset_dir, std::path::Path::new("audio/shards"));
    assert_eq!(restored.validation_speakers, ["p282"]);
    assert_eq!(restored.shuffle_buffer_frames, 13);
    assert_eq!(restored.seed, 11);
    assert_eq!(restored.min_learning_rate, 0.0001);
    assert_eq!(restored.max_learning_rate, 0.001);
    assert_eq!(restored.warmup_fraction, 0.2);
    assert_eq!(restored.patience, Some(4));
    assert_eq!(restored.to_string(), config.to_string());
}

#[test]
fn default_depths_and_constructor_defaults_are_preserved() {
    let config: TrainingConfig = TrainingConfig::new(
        AutoencoderConfig::new(16, 2, [12, 8, 6, 4], [4, 6, 8, 12]),
        AdamConfig::new(),
    );

    assert_eq!(config.num_epochs, 50);
    assert_eq!(config.batch_size, 64);
    assert!(
        config
            .dataset_dir
            .ends_with("datasets/VoiceBank-DEMAND-16k/data")
    );
    assert_eq!(config.validation_speakers, ["p282", "p287"]);
    assert_eq!(config.shuffle_buffer_frames, 4096);
    assert_eq!(config.seed, 42);
    assert_eq!(config.min_learning_rate, 1.0e-5);
    assert_eq!(config.max_learning_rate, 1.0e-3);
    assert_eq!(config.warmup_fraction, 0.05);
    assert_eq!(config.patience, None);
}

#[test]
fn arrays_support_zero_and_more_than_32_hidden_layers() {
    fn roundtrip<const E: usize, const D: usize>() {
        let model = AutoencoderConfig::new(8, 2, [4; E], [4; D]).with_dropout([0.25; E], [0.5; D]);
        let config = TrainingConfig::new(model, AdamConfig::new());
        let restored = TrainingConfig::<E, D>::load_binary(config.to_string().as_bytes()).unwrap();

        assert_eq!(restored.model.encoder_hidden(), &[4; E]);
        assert_eq!(restored.model.decoder_hidden(), &[4; D]);
        assert_eq!(restored.model.encoder_dropout(), &[0.25; E]);
        assert_eq!(restored.model.decoder_dropout(), &[0.5; D]);
    }

    roundtrip::<0, 0>();
    roundtrip::<0, 2>();
    roundtrip::<2, 0>();
    roundtrip::<33, 34>();
}

#[test]
fn incompatible_depths_and_dropout_lengths_are_rejected() {
    let config = TrainingConfig::new(AutoencoderConfig::new(8, 2, [6, 4], [5]), AdamConfig::new());

    let json = config.to_string();
    assert!(TrainingConfig::<3, 1>::load_binary(json.as_bytes()).is_err());
    assert!(TrainingConfig::<2, 2>::load_binary(json.as_bytes()).is_err());

    for field in ["encoder_dropout", "decoder_dropout"] {
        let malformed = json.replacen(
            &format!("\"{field}\": ["),
            &format!("\"{field}\": [0.5,"),
            1,
        );
        let error = TrainingConfig::<2, 1>::load_binary(malformed.as_bytes()).unwrap_err();
        assert!(error.to_string().contains("entries, got"));
    }
}

#[test]
fn invalid_training_settings_fail_before_creating_artifacts() {
    let directory = tempdir().unwrap();
    let artifact_dir = directory.path().join("run");
    let config = TrainingConfig::new(AutoencoderConfig::new(8, 2, [6, 4], [5]), AdamConfig::new());
    let device = Device::flex();
    let error = train::<4, 2, 1>(&artifact_dir, config.clone(), device.clone()).unwrap_err();
    assert!(
        error
            .to_string()
            .contains("model input size 8 must equal frame size 4")
    );

    for (invalid, expected) in [
        (config.clone().with_num_epochs(0), "number of epochs"),
        (config.clone().with_batch_size(0), "batch size"),
        (
            config.clone().with_shuffle_buffer_frames(0),
            "shuffle buffer size",
        ),
        (
            config.clone().with_learning_rate_range(f64::NAN, 0.001),
            "minimum learning rate",
        ),
        (
            config.clone().with_learning_rate_range(0.0, 0.001),
            "minimum learning rate",
        ),
        (
            config.clone().with_learning_rate_range(0.0001, f64::NAN),
            "maximum learning rate",
        ),
        (
            config.clone().with_learning_rate_range(0.0001, 0.0),
            "maximum learning rate",
        ),
        (
            config.clone().with_learning_rate_range(0.0001, 0.0001),
            "maximum learning rate",
        ),
        (
            config.clone().with_learning_rate_range(0.0001, 1.1),
            "maximum learning rate",
        ),
        (
            config.clone().with_warmup_fraction(f64::NAN),
            "warmup fraction",
        ),
        (config.clone().with_warmup_fraction(0.0), "warmup fraction"),
        (config.clone().with_warmup_fraction(1.0), "warmup fraction"),
        (config.with_validation_speakers(vec![]), "held-out speaker"),
    ] {
        let error = train::<8, 2, 1>(&artifact_dir, invalid, device.clone()).unwrap_err();
        assert!(error.to_string().contains(expected));
        assert!(!artifact_dir.exists());
    }
}
