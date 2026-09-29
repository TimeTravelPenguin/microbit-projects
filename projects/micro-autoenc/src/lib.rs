#![cfg_attr(not(feature = "train"), no_std)]

pub mod model;

#[cfg(feature = "train")]
pub mod dataset;

pub use model::{Autoencoder, AutoencoderConfig, DenseBlock, MlpHalf, MlpHalfConfig};

#[cfg(feature = "train")]
pub use model::DenoisingBatch;
