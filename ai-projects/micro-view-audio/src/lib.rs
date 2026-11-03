#![no_std]

pub mod analysis;
pub mod blocks;
pub mod view;

pub use analysis::{Analysis, Analyzer, BAND_COUNT, FFT_LEN, HISTORY_LEN, HOP_LEN, SAMPLE_RATE};
pub use blocks::{AudioBlock, BLOCK_QUEUE_LEN, BlockQueue};
pub use view::{AudioView, HistoryDuration, Mode};
