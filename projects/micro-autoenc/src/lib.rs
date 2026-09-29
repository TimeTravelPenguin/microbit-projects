#![cfg_attr(not(feature = "train"), no_std)]

pub mod model;

pub use model::{Autoencoder, AutoencoderConfig, DenseBlock, MlpHalf, MlpHalfConfig};

#[cfg(feature = "train")]
pub use model::DenoisingBatch;
