use alloc::{vec, vec::Vec};

use burn::{
    module::Module,
    nn::{Dropout, DropoutConfig, LeakyRelu, LeakyReluConfig, Linear, LinearConfig},
    tensor::{Device, Tensor},
};

/// A single hidden layer used by an [`MlpHalf`].
///
/// The transformation performed is:
///
/// ```text
/// input
///   │
///   ▼
/// Linear
///   │
///   ▼
/// LeakyReLU
///   │
///   ▼
/// Dropout
///   │
///   ▼
/// output
/// ```
///
/// Dropout is automatically inactive when the module is used in
/// validation/inference mode.
#[derive(Module, Debug)]
pub struct DenseBlock {
    linear: Linear,
    activation: LeakyRelu,
    dropout: Dropout,
}

impl DenseBlock {
    /// Creates a new dense hidden block.
    fn new(d_input: usize, d_output: usize, dropout: f64, device: &Device) -> Self {
        Self {
            linear: LinearConfig::new(d_input, d_output).init(device),
            activation: LeakyReluConfig::new().init(),
            dropout: DropoutConfig::new(dropout).init(),
        }
    }

    /// Applies the block to the input tensor.
    ///
    /// The final dimension of `input` must be `d_input`.
    pub fn forward<const D: usize>(&self, input: Tensor<D>) -> Tensor<D> {
        let x = self.linear.forward(input);
        let x = self.activation.forward(x);

        self.dropout.forward(x)
    }
}

/// One half of an autoencoder.
///
/// The number of hidden blocks is configured at runtime. The final output layer
/// is kept separate because it intentionally has no activation or dropout.
#[derive(Module, Debug)]
pub struct MlpHalf {
    hidden: Vec<DenseBlock>,
    output: Linear,
}

impl MlpHalf {
    pub fn forward<const D: usize>(&self, mut input: Tensor<D>) -> Tensor<D> {
        for block in &self.hidden {
            input = block.forward(input);
        }

        self.output.forward(input)
    }
}

/// Configuration for one [`MlpHalf`].
///
/// The length of `hidden_sizes` determines the number of hidden layers.
///
/// The architecture is:
///
/// ```text
/// input_size
///     -> hidden_sizes[0]
///     -> hidden_sizes[1]
///     -> ...
///     -> hidden_sizes[last]
///     -> output_size
/// ```
///
/// Each hidden layer has a corresponding dropout probability.
#[derive(Clone, Debug)]
pub struct MlpHalfConfig {
    input_size: usize,
    hidden_sizes: Vec<usize>,
    output_size: usize,
    dropout: Vec<f64>,
}

impl MlpHalfConfig {
    /// Creates a configuration with dropout disabled.
    pub fn new(input_size: usize, hidden_sizes: impl Into<Vec<usize>>, output_size: usize) -> Self {
        let hidden_sizes = hidden_sizes.into();
        let dropout = vec![0.0; hidden_sizes.len()];

        Self {
            input_size,
            hidden_sizes,
            output_size,
            dropout,
        }
    }

    /// Sets the dropout probability independently for every hidden layer.
    ///
    /// Each probability must lie in `[0, 1]`, with one entry per hidden layer.
    pub fn with_dropout(mut self, dropout: impl Into<Vec<f64>>) -> Self {
        self.dropout = dropout.into();

        self
    }

    /// Returns the number of input features.
    pub const fn input_size(&self) -> usize {
        self.input_size
    }

    /// Returns the hidden layer sizes.
    pub fn hidden_sizes(&self) -> &[usize] {
        &self.hidden_sizes
    }

    /// Returns the number of output features.
    pub const fn output_size(&self) -> usize {
        self.output_size
    }

    /// Returns the dropout probabilities.
    pub fn dropout(&self) -> &[f64] {
        &self.dropout
    }

    /// Checks dimensions and the dropout entry for each hidden layer.
    pub fn validate(&self) -> Result<(), &'static str> {
        if self.input_size == 0 {
            return Err("input size must be greater than zero");
        }

        if self.output_size == 0 {
            return Err("output size must be greater than zero");
        }

        validate_hidden_layers(&self.hidden_sizes, &self.dropout)
    }

    /// Initializes the module on `device`, panicking if the configuration is invalid.
    pub fn init(&self, device: &Device) -> MlpHalf {
        self.validate().expect("invalid MLP configuration");
        let mut hidden = Vec::with_capacity(self.hidden_sizes.len());
        let mut input_size = self.input_size;

        for (&size, &dropout) in self.hidden_sizes.iter().zip(&self.dropout) {
            hidden.push(DenseBlock::new(input_size, size, dropout, device));
            input_size = size;
        }

        let output = LinearConfig::new(input_size, self.output_size).init(device);

        MlpHalf { hidden, output }
    }
}

/// A fully-connected denoising autoencoder.
///
/// Encoder and decoder depths are determined by their configured width lists.
///
/// For example:
///
/// ```text
/// 256 -> 128 -> 64 -> 16 -> 64 -> 128 -> 256
///         encoder       |       decoder
/// ```
///
/// can be represented by:
///
/// ```text
/// encoder_hidden = [128, 64]
/// latent_size    = 16
/// decoder_hidden = [64, 128]
/// ```
#[derive(Module, Debug)]
pub struct Autoencoder {
    encoder: MlpHalf,
    decoder: MlpHalf,
}

impl Autoencoder {
    /// Encodes input into the latent representation.
    ///
    /// The final dimension of `input` must equal the autoencoder input size.
    pub fn encode<const R: usize>(&self, input: Tensor<R>) -> Tensor<R> {
        self.encoder.forward(input)
    }

    /// Decodes a latent representation back into the input space.
    ///
    /// The final dimension of `latent` must equal the latent size.
    pub fn decode<const R: usize>(&self, latent: Tensor<R>) -> Tensor<R> {
        self.decoder.forward(latent)
    }

    /// Runs the complete autoencoder.
    ///
    /// ```text
    /// input -> encoder -> latent -> decoder -> reconstruction
    /// ```
    pub fn forward<const R: usize>(&self, input: Tensor<R>) -> Tensor<R> {
        let latent = self.encode(input);

        self.decode(latent)
    }

    /// Returns the encoder.
    pub const fn encoder(&self) -> &MlpHalf {
        &self.encoder
    }

    /// Returns the decoder.
    pub const fn decoder(&self) -> &MlpHalf {
        &self.decoder
    }
}

/// Configuration for an [`Autoencoder`].
///
/// The encoder always ends at `latent_size`, while the decoder always
/// maps from `latent_size` back to `input_size`.
#[derive(Clone, Debug)]
#[cfg_attr(
    feature = "train",
    derive(burn::serde::Serialize, burn::serde::Deserialize)
)]
#[cfg_attr(feature = "train", serde(crate = "burn::serde"))]
pub struct AutoencoderConfig {
    input_size: usize,
    latent_size: usize,

    encoder_hidden: Vec<usize>,
    decoder_hidden: Vec<usize>,

    encoder_dropout: Vec<f64>,
    decoder_dropout: Vec<f64>,
}

impl AutoencoderConfig {
    /// Creates a new autoencoder configuration with dropout disabled.
    pub fn new(
        input_size: usize,
        latent_size: usize,
        encoder_hidden: impl Into<Vec<usize>>,
        decoder_hidden: impl Into<Vec<usize>>,
    ) -> Self {
        let encoder_hidden = encoder_hidden.into();
        let decoder_hidden = decoder_hidden.into();
        let encoder_dropout = vec![0.0; encoder_hidden.len()];
        let decoder_dropout = vec![0.0; decoder_hidden.len()];

        Self {
            input_size,
            latent_size,

            encoder_hidden,
            decoder_hidden,

            encoder_dropout,
            decoder_dropout,
        }
    }

    /// Sets dropout probabilities for the encoder and decoder hidden
    /// layers. Each list must have one probability per hidden layer.
    pub fn with_dropout(
        mut self,
        encoder_dropout: impl Into<Vec<f64>>,
        decoder_dropout: impl Into<Vec<f64>>,
    ) -> Self {
        self.encoder_dropout = encoder_dropout.into();
        self.decoder_dropout = decoder_dropout.into();

        self
    }

    /// Returns the input dimensionality.
    pub const fn input_size(&self) -> usize {
        self.input_size
    }

    /// Returns the latent-space dimensionality.
    pub const fn latent_size(&self) -> usize {
        self.latent_size
    }

    /// Returns the encoder hidden layer sizes.
    pub fn encoder_hidden(&self) -> &[usize] {
        &self.encoder_hidden
    }

    /// Returns the decoder hidden layer sizes.
    pub fn decoder_hidden(&self) -> &[usize] {
        &self.decoder_hidden
    }

    /// Returns the encoder dropout probabilities.
    pub fn encoder_dropout(&self) -> &[f64] {
        &self.encoder_dropout
    }

    /// Returns the decoder dropout probabilities.
    pub fn decoder_dropout(&self) -> &[f64] {
        &self.decoder_dropout
    }

    /// Checks dimensions and the dropout entry for each hidden layer.
    pub fn validate(&self) -> Result<(), &'static str> {
        if self.input_size == 0 {
            return Err("input size must be greater than zero");
        }

        if self.latent_size == 0 {
            return Err("latent size must be greater than zero");
        }

        if self.encoder_hidden.len() != self.encoder_dropout.len() {
            return Err("encoder dropout length must match encoder hidden layer count");
        }

        if self.decoder_hidden.len() != self.decoder_dropout.len() {
            return Err("decoder dropout length must match decoder hidden layer count");
        }

        validate_hidden_layers(&self.encoder_hidden, &self.encoder_dropout)?;
        validate_hidden_layers(&self.decoder_hidden, &self.decoder_dropout)
    }

    /// Initializes the autoencoder on `device`, panicking if the configuration is invalid.
    pub fn init(&self, device: &Device) -> Autoencoder {
        self.validate().expect("invalid autoencoder configuration");

        let encoder = MlpHalfConfig::new(
            self.input_size,
            self.encoder_hidden.clone(),
            self.latent_size,
        )
        .with_dropout(self.encoder_dropout.clone())
        .init(device);

        let decoder = MlpHalfConfig::new(
            self.latent_size,
            self.decoder_hidden.clone(),
            self.input_size,
        )
        .with_dropout(self.decoder_dropout.clone())
        .init(device);

        Autoencoder { encoder, decoder }
    }
}

fn validate_hidden_layers(hidden_sizes: &[usize], dropout: &[f64]) -> Result<(), &'static str> {
    if hidden_sizes.len() != dropout.len() {
        return Err("dropout length must match hidden layer count");
    }

    if hidden_sizes.contains(&0) {
        return Err("hidden layer size must be greater than zero");
    }

    if dropout
        .iter()
        .any(|probability| !(0.0..=1.0).contains(probability))
    {
        return Err("dropout probabilities must be finite and between zero and one");
    }

    Ok(())
}
