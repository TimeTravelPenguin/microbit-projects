//! Bounded Parquet-to-Burn streaming for `JacobLinCool/VoiceBank-DEMAND-16k`.
//!
//! Only recording metadata is retained between epochs. Polars reads one physical
//! row group at a time; audio is decoded one recording at a time. Training can
//! shuffle row groups and use a bounded frame buffer without random frame I/O.

use std::{
    collections::HashSet,
    fs::{self, File},
    io::Cursor,
    ops::Range,
    path::{Path, PathBuf},
    sync::{
        Arc,
        atomic::{AtomicU64, Ordering},
    },
};

use anyhow::{Context, Result, ensure};
use burn::{
    data::{
        dataloader::{DataLoader, DataLoaderIterator, Progress, batcher::Batcher},
        dataset::DatasetError,
    },
    tensor::{Device, Tensor, TensorData},
};
use hound::{SampleFormat, WavReader};
use polars::prelude::{BinaryChunked, ParallelStrategy, ParquetReader, SerReader, StringChunked};
use rand::{RngExt, SeedableRng, rngs::StdRng, seq::SliceRandom};

use crate::DenoisingBatch;

pub const SAMPLE_RATE: u32 = 16_000;

/// Validation speakers are held out from the source training shards.
/// The source test shards are opened only for `Test`.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum DatasetSplit {
    Train,
    Validation,
    Test,
}

/// Synchronized waveform frames with fixed PCM scaling (`sample / 32768.0`).
#[derive(Clone, Debug)]
pub struct DenoisingFrame<const N: usize> {
    pub id: Arc<str>,
    pub offset: usize,
    pub noisy: [f32; N],
    pub clean: [f32; N],
}

#[derive(Debug)]
struct RecordingIndex {
    id: Arc<str>,
    row: usize,
    samples: usize,
    frames: Range<usize>,
}

#[derive(Debug)]
struct RowGroup {
    path: Arc<PathBuf>,
    row_start: usize,
    row_count: usize,
    frames: Range<usize>,
    recordings: Vec<RecordingIndex>,
}

/// A small index of recordings and frame counts, with no resident audio.
///
/// Use [`Self::frames`] or [`VoiceBankDataLoader`] to stream it. Deliberately does
/// not implement Burn's random-access `Dataset`: globally shuffled frame lookups
/// would repeatedly decompress row groups.
#[derive(Clone, Debug)]
pub struct VoiceBankDataset<const N: usize> {
    groups: Arc<[RowGroup]>,
    frame_count: usize,
    recording_count: usize,
}

impl<const N: usize> VoiceBankDataset<N> {
    /// Indexes the local shards in sorted order, one Parquet row group at a time.
    /// WAV headers, sample counts, and the last sample are checked without
    /// decoding or retaining entire recordings. This is one initial scan; each
    /// epoch subsequently streams the selected row groups again.
    ///
    /// Supply the same held-out speakers to train and validation. Test ignores
    /// this list. Only mono PCM16 at 16 kHz is supported. Frames do not overlap,
    /// and incomplete tails are dropped. Keep source files unchanged while using
    /// this index; read failures or changed IDs/lengths are errors during iteration.
    pub fn load(
        directory: impl AsRef<Path>,
        split: DatasetSplit,
        validation_speakers: &[&str],
    ) -> Result<Self> {
        ensure!(N > 0, "frame size must be greater than zero");
        ensure!(
            split != DatasetSplit::Validation || !validation_speakers.is_empty(),
            "validation requires at least one held-out speaker"
        );

        let mut groups = Vec::new();
        let mut frame_count: usize = 0;
        let mut recording_count = 0;
        let mut seen_ids = HashSet::new();
        let mut seen_speakers = HashSet::new();

        for path in shard_paths(directory.as_ref(), split)? {
            let path = Arc::new(path);
            let mut reader = ParquetReader::new(File::open(path.as_ref())?);
            let row_counts: Vec<_> = reader
                .get_metadata()
                .with_context(|| format!("reading metadata for {}", path.display()))?
                .row_groups
                .iter()
                .map(|group| group.num_rows())
                .collect();
            let mut row_start = 0;

            for row_count in row_counts {
                let columns = read_group(&path, row_start, row_count)?;
                let mut group = RowGroup {
                    path: path.clone(),
                    row_start,
                    row_count,
                    frames: frame_count..frame_count,
                    recordings: Vec::new(),
                };

                for row in 0..row_count {
                    let id = columns.ids.get(row).with_context(|| {
                        format!("{} row {}: missing id", path.display(), row_start + row)
                    })?;
                    let (speaker, _) = id
                        .split_once('_')
                        .filter(|(speaker, utterance)| !speaker.is_empty() && !utterance.is_empty())
                        .with_context(|| {
                            format!("{}: invalid recording id {id:?}", path.display())
                        })?;

                    ensure!(
                        seen_ids.insert(id.to_owned()),
                        "{}: duplicate recording id {id:?}",
                        path.display()
                    );
                    seen_speakers.insert(speaker.to_owned());
                    let held_out = validation_speakers.contains(&speaker);
                    let include = match split {
                        DatasetSplit::Train => !held_out,
                        DatasetSplit::Validation => held_out,
                        DatasetSplit::Test => true,
                    };

                    if !include {
                        continue;
                    }

                    let samples = columns.sample_count(row).with_context(|| {
                        format!("{} row {}, {id}", path.display(), row_start + row)
                    })?;
                    let frames = samples / N;

                    if frames == 0 {
                        continue;
                    }

                    let frame_start = frame_count;
                    frame_count = frame_count.checked_add(frames).context("too many frames")?;
                    group.recordings.push(RecordingIndex {
                        id: Arc::from(id),
                        row,
                        samples,
                        frames: frame_start..frame_count,
                    });
                    recording_count += 1;
                }

                group.frames.end = frame_count;

                if !group.recordings.is_empty() {
                    groups.push(group);
                }

                row_start += row_count;
            }
        }

        if split != DatasetSplit::Test {
            for speaker in validation_speakers {
                ensure!(
                    seen_speakers.contains(*speaker),
                    "validation speaker {speaker:?} was not found in the training shards"
                );
            }
        }

        ensure!(
            frame_count > 0,
            "{split:?} contains no complete {N}-sample frames"
        );

        Ok(Self {
            groups: groups.into(),
            frame_count,
            recording_count,
        })
    }

    pub fn recording_count(&self) -> usize {
        self.recording_count
    }

    pub fn len(&self) -> usize {
        self.frame_count
    }

    pub fn is_empty(&self) -> bool {
        self.frame_count == 0
    }

    /// Starts a fresh ordered pass. I/O starts on the first `next()` call.
    pub fn frames(&self) -> VoiceBankFrames<N> {
        self.frames_in(0..self.len(), None)
    }

    fn frames_in(&self, range: Range<usize>, rng: Option<&mut StdRng>) -> VoiceBankFrames<N> {
        let mut pending: Vec<_> = self
            .groups
            .iter()
            .enumerate()
            .filter(|(_, group)| overlaps(&group.frames, &range))
            .map(|(index, _)| index)
            .collect();

        if let Some(rng) = rng {
            pending.shuffle(rng);
        }

        VoiceBankFrames {
            dataset: self.clone(),
            range,
            pending: pending.into_iter(),
            group: None,
            recording: None,
            failed: false,
        }
    }
}

type AudioReader<'a> = WavReader<Cursor<&'a [u8]>>;

struct AudioColumns {
    ids: StringChunked,
    clean: BinaryChunked,
    noisy: BinaryChunked,
}

impl AudioColumns {
    fn readers(&self, row: usize) -> Result<(AudioReader<'_>, AudioReader<'_>)> {
        let clean = wav_reader(self.clean.get(row).context("missing clean.bytes")?)
            .context("clean audio")?;
        let noisy = wav_reader(self.noisy.get(row).context("missing noisy.bytes")?)
            .context("noisy audio")?;
        ensure!(
            clean.len() == noisy.len(),
            "clean/noisy lengths differ ({} versus {})",
            clean.len(),
            noisy.len()
        );

        Ok((clean, noisy))
    }

    fn sample_count(&self, row: usize) -> Result<usize> {
        let (clean, _) = self.readers(row)?;

        Ok(clean.len() as usize)
    }
}

fn read_group(path: &Path, row_start: usize, row_count: usize) -> Result<AudioColumns> {
    let read = || -> Result<AudioColumns> {
        let frame = ParquetReader::new(File::open(path)?)
            .with_columns(Some(vec!["id".into(), "clean".into(), "noisy".into()]))
            .with_slice(Some((row_start, row_count)))
            // This strategy skips non-overlapping groups before decoding. The
            // slice intersects exactly one group, so only that group is read.
            .read_parallel(ParallelStrategy::RowGroups)
            .finish()?;
        ensure!(frame.height() == row_count, "Parquet row count changed");
        let clean = frame.column("clean")?.struct_()?.field_by_name("bytes")?;
        let noisy = frame.column("noisy")?.struct_()?.field_by_name("bytes")?;

        Ok(AudioColumns {
            ids: frame.column("id")?.str()?.clone(),
            clean: clean.binary()?.clone(),
            noisy: noisy.binary()?.clone(),
        })
    };

    read().with_context(|| {
        format!(
            "reading {} rows {row_start}..{}",
            path.display(),
            row_start + row_count
        )
    })
}

struct LoadedGroup {
    index: usize,
    columns: AudioColumns,
    next_recording: usize,
}

struct RecordingFrames<const N: usize> {
    id: Arc<str>,
    clean: Vec<i16>,
    noisy: Vec<i16>,
    offsets: Range<usize>,
}

impl<const N: usize> Iterator for RecordingFrames<N> {
    type Item = DenoisingFrame<N>;

    fn next(&mut self) -> Option<Self::Item> {
        if self.offsets.is_empty() {
            return None;
        }

        let offset = self.offsets.start;
        self.offsets.start += N;

        Some(DenoisingFrame {
            id: self.id.clone(),
            offset,
            clean: std::array::from_fn(|sample| f32::from(self.clean[offset + sample]) / 32768.0),
            noisy: std::array::from_fn(|sample| f32::from(self.noisy[offset + sample]) / 32768.0),
        })
    }
}

/// Ordered or row-group-shuffled stream; at most one group and one decoded pair
/// are retained. An error is yielded once, then the iterator terminates.
pub struct VoiceBankFrames<const N: usize> {
    dataset: VoiceBankDataset<N>,
    range: Range<usize>,
    pending: std::vec::IntoIter<usize>,
    group: Option<LoadedGroup>,
    recording: Option<RecordingFrames<N>>,
    failed: bool,
}

impl<const N: usize> VoiceBankFrames<N> {
    fn next_frame(&mut self) -> Result<Option<DenoisingFrame<N>>> {
        loop {
            if let Some(recording) = &mut self.recording
                && let Some(frame) = recording.next()
            {
                return Ok(Some(frame));
            }

            self.recording = None;

            if let Some(loaded) = &mut self.group {
                let group = &self.dataset.groups[loaded.index];

                if let Some(recording) = group.recordings.get(loaded.next_recording) {
                    loaded.next_recording += 1;

                    if !overlaps(&recording.frames, &self.range) {
                        continue;
                    }

                    let decode = || -> Result<RecordingFrames<N>> {
                        ensure!(
                            loaded.columns.ids.get(recording.row) == Some(&recording.id),
                            "recording ID changed since indexing"
                        );
                        let (mut clean, mut noisy) = loaded.columns.readers(recording.row)?;
                        ensure!(
                            clean.len() as usize == recording.samples,
                            "recording length changed since indexing"
                        );
                        let clean = clean
                            .samples::<i16>()
                            .collect::<std::result::Result<Vec<_>, _>>()?;
                        let noisy = noisy
                            .samples::<i16>()
                            .collect::<std::result::Result<Vec<_>, _>>()?;
                        let start =
                            self.range.start.max(recording.frames.start) - recording.frames.start;
                        let end = self.range.end.min(recording.frames.end) - recording.frames.start;

                        Ok(RecordingFrames {
                            id: recording.id.clone(),
                            clean,
                            noisy,
                            offsets: start * N..end * N,
                        })
                    };

                    self.recording = Some(decode().with_context(|| {
                        format!(
                            "{} row {}, {}",
                            group.path.display(),
                            group.row_start + recording.row,
                            recording.id
                        )
                    })?);

                    continue;
                }
            }

            // Release the previous group's buffers before reading the next.
            self.group = None;
            let Some(index) = self.pending.next() else {
                return Ok(None);
            };

            let group = &self.dataset.groups[index];
            let columns = read_group(&group.path, group.row_start, group.row_count)?;
            self.group = Some(LoadedGroup {
                index,
                columns,
                next_recording: 0,
            });
        }
    }
}

impl<const N: usize> Iterator for VoiceBankFrames<N> {
    type Item = Result<DenoisingFrame<N>>;

    fn next(&mut self) -> Option<Self::Item> {
        if self.failed {
            return None;
        }

        match self.next_frame() {
            Ok(frame) => frame.map(Ok),
            Err(error) => {
                self.failed = true;
                self.group = None;
                self.recording = None;

                Some(Err(error))
            }
        }
    }
}

/// Burn data loader with sequential Parquet I/O and optional bounded shuffling.
///
/// Each epoch reopens the source files. Shuffling permutes row groups and mixes
/// individual frames through a fixed-size buffer; it is not a uniform global
/// frame permutation. No custom worker threads, full-dataset cache, or disk cache
/// are created. Separate concurrent iterators each own their bounded buffers.
pub struct VoiceBankDataLoader<const N: usize> {
    dataset: VoiceBankDataset<N>,
    range: Range<usize>,
    batch_size: usize,
    device: Device,
    shuffle: Option<(u64, usize)>,
    epoch: AtomicU64,
}

impl<const N: usize> VoiceBankDataLoader<N> {
    pub fn new(dataset: VoiceBankDataset<N>, batch_size: usize, device: Device) -> Result<Self> {
        ensure!(batch_size > 0, "batch size must be greater than zero");
        let range = 0..dataset.len();

        Ok(Self {
            dataset,
            range,
            batch_size,
            device,
            shuffle: None,
            epoch: AtomicU64::new(0),
        })
    }

    /// Reproducible shuffling, with a different order each epoch. The buffer
    /// holds at most `buffer_frames` waveform pairs (about `8 * N` bytes each).
    pub fn shuffle(mut self, seed: u64, buffer_frames: usize) -> Result<Self> {
        ensure!(
            buffer_frames > 0,
            "shuffle buffer must be greater than zero"
        );
        self.shuffle = Some((seed, buffer_frames));
        self.epoch = AtomicU64::new(0);

        Ok(self)
    }

    fn copy_for(&self, range: Range<usize>, device: Device) -> Self {
        Self {
            dataset: self.dataset.clone(),
            range,
            batch_size: self.batch_size,
            device,
            shuffle: self.shuffle,
            epoch: AtomicU64::new(self.epoch.load(Ordering::Relaxed)),
        }
    }
}

impl<const N: usize> DataLoader<DenoisingBatch> for VoiceBankDataLoader<N> {
    fn iter(&self) -> Box<dyn DataLoaderIterator<DenoisingBatch> + '_> {
        let mut rng = self.shuffle.map(|(seed, _)| {
            StdRng::seed_from_u64(seed.wrapping_add(self.epoch.fetch_add(1, Ordering::Relaxed)))
        });

        Box::new(StreamingBatches {
            source: self.dataset.frames_in(self.range.clone(), rng.as_mut()),
            rng,
            buffer: Vec::with_capacity(
                self.shuffle
                    .map_or(0, |(_, capacity)| capacity.min(self.num_items())),
            ),
            buffer_capacity: self.shuffle.map_or(0, |(_, capacity)| capacity),
            batch_size: self.batch_size,
            device: self.device.clone(),
            processed: 0,
            total: self.num_items(),
            failed: false,
        })
    }

    fn num_items(&self) -> usize {
        self.range.len()
    }

    fn to_device(&self, device: &Device) -> Arc<dyn DataLoader<DenoisingBatch>> {
        Arc::new(self.copy_for(self.range.clone(), device.clone()))
    }

    fn slice(&self, start: usize, end: usize) -> Arc<dyn DataLoader<DenoisingBatch>> {
        assert!(
            start <= end && end <= self.num_items(),
            "data loader slice out of bounds"
        );

        Arc::new(self.copy_for(
            self.range.start + start..self.range.start + end,
            self.device.clone(),
        ))
    }
}

struct StreamingBatches<const N: usize> {
    source: VoiceBankFrames<N>,
    rng: Option<StdRng>,
    buffer: Vec<DenoisingFrame<N>>,
    buffer_capacity: usize,
    batch_size: usize,
    device: Device,
    processed: usize,
    total: usize,
    failed: bool,
}

impl<const N: usize> StreamingBatches<N> {
    fn next_frame(&mut self) -> Result<Option<DenoisingFrame<N>>> {
        let Some(rng) = &mut self.rng else {
            return self.source.next().transpose();
        };

        while self.buffer.len() < self.buffer_capacity {
            match self.source.next().transpose()? {
                Some(frame) => self.buffer.push(frame),
                None => break,
            }
        }

        if self.buffer.is_empty() {
            return Ok(None);
        }

        let index = rng.random_range(..self.buffer.len());
        let frame = match self.source.next().transpose()? {
            Some(frame) => std::mem::replace(&mut self.buffer[index], frame),
            None => self.buffer.swap_remove(index),
        };

        Ok(Some(frame))
    }
}

impl<const N: usize> Iterator for StreamingBatches<N> {
    type Item = std::result::Result<DenoisingBatch, DatasetError>;

    fn next(&mut self) -> Option<Self::Item> {
        if self.failed {
            return None;
        }

        let mut items = Vec::with_capacity(self.batch_size);

        while items.len() < self.batch_size {
            match self.next_frame() {
                Ok(Some(frame)) => items.push(frame),
                Ok(None) => break,
                Err(error) => {
                    self.failed = true;
                    self.buffer.clear();

                    return Some(Err(DatasetError::new(std::io::Error::other(format!(
                        "{error:#}"
                    )))));
                }
            }
        }

        if items.is_empty() {
            return None;
        }

        self.processed += items.len();

        Some(Ok(DenoisingBatcher.batch(items, &self.device)))
    }
}

impl<const N: usize> DataLoaderIterator<DenoisingBatch> for StreamingBatches<N> {
    fn progress(&self) -> Progress {
        Progress::new(self.processed, self.total, Some("frames".into()))
    }
}

/// Stacks waveform pairs into `[batch_size, N]` tensors on Burn's supplied device.
#[derive(Clone, Debug, Default)]
pub struct DenoisingBatcher;

impl<const N: usize> Batcher<DenoisingFrame<N>, DenoisingBatch> for DenoisingBatcher {
    fn batch(&self, items: Vec<DenoisingFrame<N>>, device: &Device) -> DenoisingBatch {
        assert!(
            N > 0 && !items.is_empty(),
            "cannot batch empty audio frames"
        );
        let shape = [items.len(), N];
        let mut noisy = Vec::with_capacity(items.len() * N);
        let mut clean = Vec::with_capacity(items.len() * N);

        for item in items {
            noisy.extend_from_slice(&item.noisy);
            clean.extend_from_slice(&item.clean);
        }

        DenoisingBatch::new(
            Tensor::from_data(TensorData::new(noisy, shape), device),
            Tensor::from_data(TensorData::new(clean, shape), device),
        )
    }
}

fn overlaps(left: &Range<usize>, right: &Range<usize>) -> bool {
    !left.is_empty() && !right.is_empty() && left.start < right.end && right.start < left.end
}

fn shard_paths(directory: &Path, split: DatasetSplit) -> Result<Vec<PathBuf>> {
    let prefix = match split {
        DatasetSplit::Train | DatasetSplit::Validation => "train-",
        DatasetSplit::Test => "test-",
    };

    let mut paths = Vec::new();

    for entry in fs::read_dir(directory)
        .with_context(|| format!("reading dataset directory {}", directory.display()))?
    {
        let entry = entry?;
        let path = entry.path();
        let matches = path
            .file_name()
            .and_then(|name| name.to_str())
            .is_some_and(|name| name.starts_with(prefix) && name.ends_with(".parquet"));

        if matches && entry.file_type()?.is_file() {
            paths.push(path);
        }
    }

    paths.sort();
    ensure!(
        !paths.is_empty(),
        "no {prefix}*.parquet shards in {}",
        directory.display()
    );

    Ok(paths)
}

fn wav_reader(bytes: &[u8]) -> Result<AudioReader<'_>> {
    let mut reader = WavReader::new(Cursor::new(bytes)).context("invalid WAV data")?;
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
    ensure!(reader.len() > 0, "empty WAV");

    // Every bit pattern is valid PCM16. Checking the last sample proves that the
    // declared data is present, without allocating or decoding the whole WAV.
    reader
        .seek(reader.duration() - 1)
        .context("invalid WAV seek")?;
    reader
        .samples::<i16>()
        .next()
        .context("empty WAV")?
        .context("invalid or truncated PCM samples")?;
    reader.seek(0)?;

    Ok(reader)
}
