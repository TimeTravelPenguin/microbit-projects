#![cfg(feature = "train")]

use burn::{
    config::Config,
    optim::AdamConfig,
    tensor::{Device, Tensor},
};
use micro_autoenc::{
    AutoencoderConfig, MlpHalfConfig,
    training::{TrainingConfig, train},
};
use tempfile::tempdir;

#[test]
fn runtime_training_config_roundtrips_through_burn_file_api() {
    let model =
        AutoencoderConfig::new(8, 2, vec![6, 4], vec![5]).with_dropout(vec![0.1, 0.2], vec![0.3]);
    let mut config: TrainingConfig = TrainingConfig::new(model, AdamConfig::new())
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
    let restored = TrainingConfig::load(&path).unwrap();

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
fn array_constructor_inputs_and_training_defaults_are_preserved() {
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
    assert_eq!(config.model.encoder_hidden(), &[12, 8, 6, 4]);
    assert_eq!(config.model.encoder_dropout(), &[0.0; 4]);
    assert_eq!(config.model.decoder_dropout(), &[0.0; 4]);
}

#[test]
fn vectors_support_runtime_depths_including_zero_and_more_than_32_layers() {
    let device = Device::flex();

    for (encoder_depth, decoder_depth) in [(0, 0), (0, 2), (2, 0), (1, 1), (2, 3), (33, 34)] {
        let model = AutoencoderConfig::new(8, 2, vec![4; encoder_depth], vec![4; decoder_depth])
            .with_dropout(vec![0.25; encoder_depth], vec![0.5; decoder_depth]);
        let config = TrainingConfig::new(model, AdamConfig::new());
        let restored = TrainingConfig::load_binary(config.to_string().as_bytes()).unwrap();

        assert_eq!(restored.model.encoder_hidden(), vec![4; encoder_depth]);
        assert_eq!(restored.model.decoder_hidden(), vec![4; decoder_depth]);
        assert_eq!(restored.model.encoder_dropout(), vec![0.25; encoder_depth]);
        assert_eq!(restored.model.decoder_dropout(), vec![0.5; decoder_depth]);

        let model = restored.model.init(&device);
        let encoded = model.encode(Tensor::<2>::zeros([2, 8], &device));
        assert_eq!(encoded.dims(), [2, 2]);
        assert_eq!(model.decode(encoded).dims(), [2, 8]);
    }
}

#[test]
fn mismatched_dropout_lengths_from_json_fail_before_creating_artifacts() {
    let directory = tempdir().unwrap();
    let artifact_dir = directory.path().join("run");
    let config = TrainingConfig::new(AutoencoderConfig::new(8, 2, [6, 4], [5]), AdamConfig::new());
    let json = config.to_string();

    for field in ["encoder_dropout", "decoder_dropout"] {
        let split = field.split('_').next().unwrap();
        let field_start = json.find(&format!("\"{field}\"")).unwrap();
        let list_start = field_start + json[field_start..].find('[').unwrap();
        let list_end = list_start + json[list_start..].find(']').unwrap();

        for replacement in ["[]", "[0.5, 0.5, 0.5]"] {
            let malformed = format!(
                "{}{replacement}{}",
                &json[..list_start],
                &json[list_end + 1..]
            );
            let invalid = TrainingConfig::load_binary(malformed.as_bytes()).unwrap();
            let error = train::<8>(&artifact_dir, invalid, Device::flex()).unwrap_err();
            assert!(
                error
                    .to_string()
                    .contains(&format!("{split} dropout length"))
            );
            assert!(!artifact_dir.exists());
        }
    }
}

#[test]
fn model_validation_rejects_invalid_dimensions_and_dropout() {
    for (model, expected) in [
        (AutoencoderConfig::new(0, 2, [4], [4]), "input size"),
        (AutoencoderConfig::new(8, 0, [4], [4]), "latent size"),
        (AutoencoderConfig::new(8, 2, [0], [4]), "hidden layer size"),
        (AutoencoderConfig::new(8, 2, [4], [0]), "hidden layer size"),
        (
            AutoencoderConfig::new(8, 2, [4], [4]).with_dropout([f64::NAN], [0.0]),
            "dropout probabilities",
        ),
        (
            AutoencoderConfig::new(8, 2, [4], [4]).with_dropout([0.0], [f64::INFINITY]),
            "dropout probabilities",
        ),
        (
            AutoencoderConfig::new(8, 2, [4], [4]).with_dropout([-0.1], [0.0]),
            "dropout probabilities",
        ),
        (
            AutoencoderConfig::new(8, 2, [4], [4]).with_dropout([0.0], [1.1]),
            "dropout probabilities",
        ),
    ] {
        assert!(model.validate().unwrap_err().contains(expected));
    }

    assert!(
        MlpHalfConfig::new(8, vec![4, 3], 2)
            .with_dropout(vec![0.0])
            .validate()
            .is_err()
    );
    assert!(MlpHalfConfig::new(8, vec![], 2).validate().is_ok());
    assert!(MlpHalfConfig::new(8, vec![4], 0).validate().is_err());
}

#[test]
fn invalid_training_settings_fail_before_creating_artifacts() {
    let directory = tempdir().unwrap();
    let artifact_dir = directory.path().join("run");
    let config = TrainingConfig::new(AutoencoderConfig::new(8, 2, [6, 4], [5]), AdamConfig::new());
    let device = Device::flex();
    let error = train::<4>(&artifact_dir, config.clone(), device.clone()).unwrap_err();
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
        let error = train::<8>(&artifact_dir, invalid, device.clone()).unwrap_err();
        assert!(error.to_string().contains(expected));
        assert!(!artifact_dir.exists());
    }
}
