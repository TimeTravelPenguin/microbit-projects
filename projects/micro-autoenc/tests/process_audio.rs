#![cfg(feature = "train")]

use std::{
    fs,
    path::Path,
    process::{Command, Output},
};

use burn::{
    config::Config,
    module::{Module, ModuleMapper, Param},
    optim::AdamConfig,
    tensor::{Device, Tensor, TensorData},
};
use hound::{Sample, SampleFormat, WavReader, WavSpec, WavWriter};
use micro_autoenc::{AutoencoderConfig, training::TrainingConfig};
use tempfile::tempdir;

// Known weights make the complete CLI path checkable without training a model.
struct TestWeights {
    diagonal: Option<f32>,
}

impl ModuleMapper for TestWeights {
    fn map_float<const D: usize>(&mut self, param: Param<Tensor<D>>) -> Param<Tensor<D>> {
        let tensor = param.val();
        let shape = tensor.dims();
        let mut values = vec![0.0_f32; shape.iter().product()];

        if D == 2 {
            if let Some(diagonal) = self.diagonal {
                for idx in 0..shape[0] {
                    values[idx * shape[1] + idx] = diagonal;
                }
            } else {
                // Two averaging matrices still yield the original frame mean.
                values.fill(1.0 / shape[0] as f32);
            }
        }

        param.map(|_| Tensor::from_data(TensorData::new(values, shape), &tensor.device()))
    }
}

fn save_model(directory: &Path, diagonal: Option<f32>) {
    fs::create_dir(directory).unwrap();
    let config = TrainingConfig::new(AutoencoderConfig::new(256, 256, vec![], vec![]))
        .with_optimizer(AdamConfig::new())
        .with_dataset_dir("unused-dataset-directory");
    config.save(directory.join("config.json")).unwrap();
    config
        .model
        .init(&Device::flex())
        .map(&mut TestWeights { diagonal })
        .into_record()
        .save(directory.join("model.bpk"))
        .unwrap();
}

fn pcm_spec() -> WavSpec {
    WavSpec {
        channels: 1,
        sample_rate: 16_000,
        bits_per_sample: 16,
        sample_format: SampleFormat::Int,
    }
}

fn write_wav<T: Sample + Copy>(path: &Path, spec: WavSpec, samples: &[T]) {
    let mut writer = WavWriter::create(path, spec).unwrap();

    for &sample in samples {
        writer.write_sample(sample).unwrap();
    }

    writer.finalize().unwrap();
}

fn process(model: &Path, input: &Path, output: &Path) -> Output {
    Command::new(env!("CARGO_BIN_EXE_micro-autoenc"))
        .args(["--device", "cpu", "process"])
        .arg(model)
        .arg(input)
        .arg(output)
        .output()
        .unwrap()
}

fn read_output(output: Output, path: &Path) -> Vec<i16> {
    assert!(
        output.status.success(),
        "{}",
        String::from_utf8_lossy(&output.stderr)
    );
    let mut reader = WavReader::open(path).unwrap();
    assert_eq!(reader.spec(), pcm_spec());

    reader.samples::<i16>().collect::<Result<_, _>>().unwrap()
}

#[test]
fn identity_model_preserves_pcm_values_and_recording_length() {
    let directory = tempdir().unwrap();
    let model = directory.path().join("model with spaces");
    save_model(&model, Some(1.0));
    let input = directory.path().join("noisy input.wav");
    let levels = [i16::MIN, -16384, -1, 0, 1, 16384, i16::MAX];

    for length in [1, 255, 256, 257, 513] {
        let samples: Vec<_> = levels.into_iter().cycle().take(length).collect();
        write_wav(&input, pcm_spec(), &samples);
        let output = directory.path().join(format!("denoised {length}.wav"));

        assert_eq!(
            read_output(process(&model, &input, &output), &output),
            samples
        );
        assert!(
            String::from_utf8(process(&model, &input, &input).stderr)
                .unwrap()
                .contains("must not already exist")
        );
        assert_eq!(
            WavReader::open(&input)
                .unwrap()
                .into_samples::<i16>()
                .collect::<Result<Vec<_>, _>>()
                .unwrap(),
            samples
        );
    }
}

#[test]
fn partial_frame_is_zero_padded_without_repeating_previous_samples() {
    let directory = tempdir().unwrap();
    let model = directory.path().join("model");
    save_model(&model, None);
    let input = directory.path().join("input.wav");
    let output = directory.path().join("output.wav");
    let mut samples = vec![16384_i16; 256];
    samples.push(8192);
    write_wav(&input, pcm_spec(), &samples);
    let mut expected = vec![16384; 256];
    expected.push(32); // 8192 / 256, with the other 255 samples padded to zero.

    assert_eq!(
        read_output(process(&model, &input, &output), &output),
        expected
    );
}

#[test]
fn predictions_are_clipped_to_pcm16_without_wrapping() {
    let directory = tempdir().unwrap();
    let model = directory.path().join("model");
    save_model(&model, Some(2.0)); // Two linear layers multiply by four in total.
    let input = directory.path().join("input.wav");
    let output = directory.path().join("output.wav");
    write_wav(
        &input,
        pcm_spec(),
        &[i16::MIN, -10000, -1, 0, 1, 10000, i16::MAX],
    );

    assert_eq!(
        read_output(process(&model, &input, &output), &output),
        [i16::MIN, i16::MIN, -4, 0, 4, i16::MAX, i16::MAX]
    );
}

#[test]
fn invalid_and_truncated_wavs_fail_without_leaving_an_output() {
    let directory = tempdir().unwrap();
    let model = directory.path().join("model");
    save_model(&model, Some(1.0));
    let input = directory.path().join("input.wav");
    let output = directory.path().join("output.wav");

    for (spec, message) in [
        (
            WavSpec {
                channels: 2,
                ..pcm_spec()
            },
            "mono",
        ),
        (
            WavSpec {
                sample_rate: 8000,
                ..pcm_spec()
            },
            "16000 Hz",
        ),
        (
            WavSpec {
                bits_per_sample: 24,
                ..pcm_spec()
            },
            "16-bit integer PCM",
        ),
    ] {
        write_wav(&input, spec, &[0_i32, 1]);
        let result = process(&model, &input, &output);
        assert!(!result.status.success());
        assert!(String::from_utf8_lossy(&result.stderr).contains(message));
        assert!(!output.exists());
    }

    write_wav(
        &input,
        WavSpec {
            bits_per_sample: 32,
            sample_format: SampleFormat::Float,
            ..pcm_spec()
        },
        &[0.1_f32],
    );
    let result = process(&model, &input, &output);
    assert!(!result.status.success());
    assert!(String::from_utf8_lossy(&result.stderr).contains("16-bit integer PCM"));
    assert!(!output.exists());

    write_wav::<i16>(&input, pcm_spec(), &[]);
    let result = process(&model, &input, &output);
    assert!(!result.status.success());
    assert!(String::from_utf8_lossy(&result.stderr).contains("empty"));
    assert!(!output.exists());

    write_wav(&input, pcm_spec(), &[1_i16; 257]);
    let mut truncated = fs::read(&input).unwrap();
    truncated.pop();
    fs::write(&input, truncated).unwrap();
    let result = process(&model, &input, &output);
    assert!(!result.status.success());
    assert!(String::from_utf8_lossy(&result.stderr).contains("decoding PCM samples"));
    assert!(!output.exists());
}

#[test]
fn non_finite_predictions_fail_and_remove_incomplete_output() {
    let directory = tempdir().unwrap();
    let model = directory.path().join("model");
    save_model(&model, Some(f32::NAN));
    let input = directory.path().join("input.wav");
    let output = directory.path().join("output.wav");
    write_wav(&input, pcm_spec(), &[1_i16]);
    let result = process(&model, &input, &output);

    assert!(!result.status.success());
    assert!(String::from_utf8_lossy(&result.stderr).contains("non-finite"));
    assert!(!output.exists());
}

#[test]
fn existing_output_is_not_overwritten() {
    let directory = tempdir().unwrap();
    let model = directory.path().join("model");
    save_model(&model, Some(1.0));
    let input = directory.path().join("input.wav");
    let output = directory.path().join("output.wav");
    write_wav(&input, pcm_spec(), &[1_i16]);
    fs::write(&output, b"existing output").unwrap();
    let result = process(&model, &input, &output);

    assert!(!result.status.success());
    assert!(String::from_utf8_lossy(&result.stderr).contains("must not already exist"));
    assert_eq!(fs::read(&output).unwrap(), b"existing output");
}
