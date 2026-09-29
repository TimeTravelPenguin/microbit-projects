#![cfg_attr(not(feature = "train"), no_std)]

pub mod model;

#[cfg(feature = "cli")]
pub mod cli;

#[cfg(feature = "train")]
pub mod training;

#[cfg(feature = "train")]
pub mod dataset;

pub use model::{Autoencoder, AutoencoderConfig, DenseBlock, MlpHalf, MlpHalfConfig};

#[cfg(feature = "train")]
pub use training::DenoisingBatch;
