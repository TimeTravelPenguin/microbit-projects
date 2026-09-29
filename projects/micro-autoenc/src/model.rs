use burn::{
    module::Module,
    nn::{Dropout, DropoutConfig, Linear, LinearConfig, Relu},
    tensor::{Device, Tensor},
};

#[cfg(feature = "train")]
use burn::{
    nn::loss::{MseLoss, Reduction},
    train::{InferenceStep, RegressionOutput, TrainOutput, TrainStep},
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
/// ReLU
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
    activation: Relu,
    dropout: Dropout,
}

impl DenseBlock {
    /// Creates a new dense hidden block.
    fn new(d_input: usize, d_output: usize, dropout: f64, device: &Device) -> Self {
        Self {
            linear: LinearConfig::new(d_input, d_output).init(device),
            activation: Relu::new(),
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
/// `N` is the number of hidden blocks. The final output layer is kept
/// separate because it intentionally has no activation or dropout.
#[derive(Module, Debug)]
pub struct MlpHalf<const N: usize> {
    hidden: [DenseBlock; N],
    output: Linear,
}

impl<const N: usize> MlpHalf<N> {
    pub fn forward<const D: usize>(&self, mut input: Tensor<D>) -> Tensor<D> {
        for block in &self.hidden {
            input = block.forward(input);
        }

        self.output.forward(input)
    }
}

/// Configuration for one [`MlpHalf`].
///
/// `N` determines the number of hidden layers.
///
/// The architecture is:
///
/// ```text
/// input_size
///     -> hidden_sizes[0]
///     -> hidden_sizes[1]
///     -> ...
///     -> hidden_sizes[N - 1]
///     -> output_size
/// ```
///
/// Each hidden layer has a corresponding dropout probability.
#[derive(Clone, Copy, Debug)]
pub struct MlpHalfConfig<const N: usize> {
    input_size: usize,
    hidden_sizes: [usize; N],
    output_size: usize,
    dropout: [f64; N],
}

impl<const N: usize> MlpHalfConfig<N> {
    /// Creates a configuration with dropout disabled.
    pub const fn new(input_size: usize, hidden_sizes: [usize; N], output_size: usize) -> Self {
        Self {
            input_size,
            hidden_sizes,
            output_size,
            dropout: [0.0; N],
        }
    }

    /// Sets the dropout probability independently for every hidden layer.
    ///
    /// Each probability must lie in `[0, 1]`.
    pub const fn with_dropout(mut self, dropout: [f64; N]) -> Self {
        self.dropout = dropout;
        self
    }

    /// Returns the number of input features.
    pub const fn input_size(&self) -> usize {
        self.input_size
    }

    /// Returns the hidden layer sizes.
    pub const fn hidden_sizes(&self) -> &[usize; N] {
        &self.hidden_sizes
    }

    /// Returns the number of output features.
    pub const fn output_size(&self) -> usize {
        self.output_size
    }

    /// Returns the dropout probabilities.
    pub const fn dropout(&self) -> &[f64; N] {
        &self.dropout
    }

    /// Initializes the module on `device`.
    pub fn init(&self, device: &Device) -> MlpHalf<N> {
        assert!(self.input_size > 0, "input size must be greater than zero");

        assert!(
            self.output_size > 0,
            "output size must be greater than zero"
        );

        for &size in &self.hidden_sizes {
            assert!(size > 0, "hidden layer size must be greater than zero");
        }

        let hidden = core::array::from_fn(|i| {
            let d_input = if i == 0 {
                self.input_size
            } else {
                self.hidden_sizes[i - 1]
            };

            DenseBlock::new(d_input, self.hidden_sizes[i], self.dropout[i], device)
        });

        let output_input_size = if N == 0 {
            self.input_size
        } else {
            self.hidden_sizes[N - 1]
        };

        let output = LinearConfig::new(output_input_size, self.output_size).init(device);

        MlpHalf { hidden, output }
    }
}

/// A fully-connected denoising autoencoder.
///
/// `E` is the number of encoder hidden layers.
///
/// `D` is the number of decoder hidden layers.
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
/// E = 2
/// D = 2
///
/// encoder_hidden = [128, 64]
/// latent_size    = 16
/// decoder_hidden = [64, 128]
/// ```
#[derive(Module, Debug)]
pub struct Autoencoder<const E: usize, const D: usize> {
    encoder: MlpHalf<E>,
    decoder: MlpHalf<D>,
}

impl<const E: usize, const D: usize> Autoencoder<E, D> {
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
    pub const fn encoder(&self) -> &MlpHalf<E> {
        &self.encoder
    }

    /// Returns the decoder.
    pub const fn decoder(&self) -> &MlpHalf<D> {
        &self.decoder
    }
}

/// Configuration for an [`Autoencoder`].
///
/// The encoder always ends at `latent_size`, while the decoder always
/// maps from `latent_size` back to `input_size`.
#[derive(Clone, Copy, Debug)]
pub struct AutoencoderConfig<const E: usize, const D: usize> {
    input_size: usize,
    latent_size: usize,

    encoder_hidden: [usize; E],
    decoder_hidden: [usize; D],

    encoder_dropout: [f64; E],
    decoder_dropout: [f64; D],
}

impl<const E: usize, const D: usize> AutoencoderConfig<E, D> {
    /// Creates a new autoencoder configuration with dropout disabled.
    pub const fn new(
        input_size: usize,
        latent_size: usize,
        encoder_hidden: [usize; E],
        decoder_hidden: [usize; D],
    ) -> Self {
        Self {
            input_size,
            latent_size,

            encoder_hidden,
            decoder_hidden,

            encoder_dropout: [0.0; E],
            decoder_dropout: [0.0; D],
        }
    }

    /// Sets dropout probabilities for the encoder and decoder hidden
    /// layers.
    pub const fn with_dropout(
        mut self,
        encoder_dropout: [f64; E],
        decoder_dropout: [f64; D],
    ) -> Self {
        self.encoder_dropout = encoder_dropout;
        self.decoder_dropout = decoder_dropout;

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
    pub const fn encoder_hidden(&self) -> &[usize; E] {
        &self.encoder_hidden
    }

    /// Returns the decoder hidden layer sizes.
    pub const fn decoder_hidden(&self) -> &[usize; D] {
        &self.decoder_hidden
    }

    /// Returns the encoder dropout probabilities.
    pub const fn encoder_dropout(&self) -> &[f64; E] {
        &self.encoder_dropout
    }

    /// Returns the decoder dropout probabilities.
    pub const fn decoder_dropout(&self) -> &[f64; D] {
        &self.decoder_dropout
    }

    /// Initializes the autoencoder on `device`.
    pub fn init(&self, device: &Device) -> Autoencoder<E, D> {
        assert!(self.input_size > 0, "input size must be greater than zero");

        assert!(
            self.latent_size > 0,
            "latent size must be greater than zero"
        );

        let encoder = MlpHalfConfig::new(self.input_size, self.encoder_hidden, self.latent_size)
            .with_dropout(self.encoder_dropout)
            .init(device);

        let decoder = MlpHalfConfig::new(self.latent_size, self.decoder_hidden, self.input_size)
            .with_dropout(self.decoder_dropout)
            .init(device);

        Autoencoder { encoder, decoder }
    }
}

/// A training/validation/testing batch for a denoising autoencoder.
///
/// Both tensors have shape:
///
/// ```text
/// [batch_size, input_size]
/// ```
///
/// `noisy` is supplied to the autoencoder as its input.
///
/// `clean` is the reconstruction target.
#[cfg(feature = "train")]
#[derive(Clone, Debug)]
pub struct DenoisingBatch {
    pub noisy: Tensor<2>,
    pub clean: Tensor<2>,
}

#[cfg(feature = "train")]
impl DenoisingBatch {
    /// Creates a denoising batch.
    pub const fn new(noisy: Tensor<2>, clean: Tensor<2>) -> Self {
        Self { noisy, clean }
    }
}

#[cfg(feature = "train")]
impl<const E: usize, const D: usize> Autoencoder<E, D> {
    /// Runs a denoising batch through the network and calculates MSE.
    ///
    /// This helper is shared by:
    ///
    /// - training,
    /// - validation,
    /// - testing/evaluation.
    fn forward_regression(&self, batch: DenoisingBatch) -> RegressionOutput {
        let targets = batch.clean;
        let output = self.forward(batch.noisy);

        let loss = MseLoss::new().forward(output.clone(), targets.clone(), Reduction::Mean);

        RegressionOutput::new(loss, output, targets)
    }
}

/// Training implementation.
///
/// This performs:
///
/// ```text
/// noisy
///   ↓
/// autoencoder
///   ↓
/// reconstruction
///   ↓
/// MSE(reconstruction, clean)
///   ↓
/// backward()
/// ```
#[cfg(feature = "train")]
impl<const E: usize, const D: usize> TrainStep for Autoencoder<E, D> {
    type Input = DenoisingBatch;
    type Output = RegressionOutput;

    fn step(&self, batch: Self::Input) -> TrainOutput<Self::Output> {
        let output = self.forward_regression(batch);
        let gradients = output.loss.backward();

        TrainOutput::new(self, gradients, output)
    }
}

/// Validation and testing/evaluation implementation.
///
/// No backward pass is performed here.
#[cfg(feature = "train")]
impl<const E: usize, const D: usize> InferenceStep for Autoencoder<E, D> {
    type Input = DenoisingBatch;
    type Output = RegressionOutput;

    fn step(&self, batch: Self::Input) -> Self::Output {
        self.forward_regression(batch)
    }
}
