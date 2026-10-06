//! Streaming WAV inference for the command-line application.

use std::{
    fs::File,
    io::{BufReader, BufWriter, Read, Seek, Write},
    path::Path,
};

use anyhow::{Context, Result, ensure};
use burn::tensor::{Device, Tensor};
use hound::{SampleFormat, WavReader, WavWriter};
use micro_autoenc::{Autoencoder, dataset::SAMPLE_RATE};
use tempfile::NamedTempFile;

use crate::FRAME_SIZE;

/// Writes a new denoised WAV, preserving the input sample count.
pub fn denoise(model: &Autoencoder, device: &Device, input: &Path, output: &Path) -> Result<usize> {
    let mut reader = open_input(input)?;
    ensure!(
        !output.try_exists()?,
        "output {} must not already exist",
        output.display()
    );
    let sample_count = reader.len() as usize;

    // The temporary file cleans itself up on error. Publish only a finalized WAV.
    let directory = output.parent().unwrap_or(Path::new("."));
    let mut pending = NamedTempFile::new_in(directory)
        .with_context(|| format!("creating output in {}", directory.display()))?;
    let mut writer = WavWriter::new(BufWriter::new(pending.as_file_mut()), reader.spec())
        .context("writing WAV header")?;

    denoise_frames(model, device, &mut reader, &mut writer)?;
    writer.finalize().context("finalizing WAV output")?;
    pending
        .persist_noclobber(output)
        .map_err(|error| error.error)
        .with_context(|| {
            format!(
                "saving {} (destination must not already exist)",
                output.display()
            )
        })?;

    Ok(sample_count)
}

fn open_input(path: &Path) -> Result<WavReader<BufReader<File>>> {
    let reader =
        WavReader::open(path).with_context(|| format!("reading WAV file {}", path.display()))?;
    let spec = reader.spec();
    ensure!(
        spec.channels == 1,
        "expected mono WAV, got {} channels",
        spec.channels
    );
    ensure!(
        spec.sample_rate == SAMPLE_RATE,
        "expected {SAMPLE_RATE} Hz WAV, got {} Hz",
        spec.sample_rate
    );
    ensure!(
        spec.sample_format == SampleFormat::Int && spec.bits_per_sample == 16,
        "expected 16-bit integer PCM WAV, got {:?}/{} bits",
        spec.sample_format,
        spec.bits_per_sample
    );
    ensure!(reader.len() > 0, "input WAV is empty");

    Ok(reader)
}

fn denoise_frames(
    model: &Autoencoder,
    device: &Device,
    reader: &mut WavReader<impl Read>,
    writer: &mut WavWriter<impl Write + Seek>,
) -> Result<()> {
    let sample_count = reader.len() as usize;
    let mut samples = reader.samples::<i16>();

    for offset in (0..sample_count).step_by(FRAME_SIZE) {
        let frame_len = (sample_count - offset).min(FRAME_SIZE);
        let mut frame = [0.0_f32; FRAME_SIZE];

        for sample in &mut frame[..frame_len] {
            let pcm = samples
                .next()
                .context("unexpected end of WAV samples")?
                .context("decoding PCM samples")?;
            *sample = f32::from(pcm) / 32768.0;
        }

        let prediction = model
            .forward(Tensor::<2>::from_data([frame], device))
            .try_into_data()
            .context("reading denoised frame")?;
        let denoised = prediction.as_slice::<f32>().map_err(anyhow::Error::msg)?;

        // Discard the padded portion of the final frame.
        for &sample in &denoised[..frame_len] {
            writer
                .write_sample(to_pcm16(sample)?)
                .context("writing PCM samples")?;
        }
    }

    Ok(())
}

fn to_pcm16(sample: f32) -> Result<i16> {
    ensure!(
        sample.is_finite(),
        "model produced a non-finite audio sample"
    );

    Ok((sample * 32768.0)
        .round()
        .clamp(f32::from(i16::MIN), f32::from(i16::MAX)) as i16)
}
