//! Configurable graph message-passing layers, followed by a scalar grade head.

use burn::{
    module::Module,
    nn::{Linear, LinearConfig},
    tensor::{Device, Tensor, activation::relu},
};

#[derive(Module, Debug)]
pub struct GradeRegressor {
    first: Linear,
    hidden: Vec<Linear>,
    output: Linear,
}

impl GradeRegressor {
    /// `hidden_layers` counts layers after the input projection, for a total
    /// message-passing depth of `1 + hidden_layers`.
    pub fn new(hidden_width: usize, hidden_layers: usize, device: &Device) -> Self {
        Self {
            first: LinearConfig::new(1, hidden_width).init(device),
            hidden: (0..hidden_layers)
                .map(|_| LinearConfig::new(hidden_width, hidden_width).init(device))
                .collect(),
            output: LinearConfig::new(hidden_width, 1).init(device),
        }
    }

    /// `adjacency = None` runs the identical feature-only MLP baseline.
    pub fn forward(&self, features: Tensor<2>, adjacency: Option<Tensor<2>>) -> Tensor<2> {
        let features = match adjacency.as_ref() {
            Some(adjacency) => adjacency.clone().matmul(features),
            None => features,
        };

        let mut hidden = relu(self.first.forward(features));

        for layer in &self.hidden {
            if let Some(adjacency) = &adjacency {
                hidden = adjacency.clone().matmul(hidden);
            }

            hidden = relu(layer.forward(hidden));
        }

        self.output.forward(hidden)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use burn::{
        nn::{
            Initializer,
            loss::{MseLoss, Reduction},
        },
        optim::{AdamConfig, GradientsParams},
    };

    fn known_model(hidden_layers: usize, device: &Device) -> GradeRegressor {
        let layer = || {
            LinearConfig::new(1, 1)
                .with_initializer(Initializer::Constant { value: 1.0 })
                .with_bias(false)
                .init(device)
        };

        GradeRegressor {
            first: layer(),
            hidden: (0..hidden_layers).map(|_| layer()).collect(),
            output: layer(),
        }
    }

    #[test]
    fn a_second_hop_changes_a_node_prediction() {
        let device = Device::flex();
        let model = known_model(1, &device);
        let features = Tensor::from_data([[0.0], [0.0], [1.0]], &device);
        let adjacency = Tensor::from_data(
            [
                [0.5, 0.5, 0.0],
                [1.0 / 3.0, 1.0 / 3.0, 1.0 / 3.0],
                [0.0, 0.5, 0.5],
            ],
            &device,
        );
        let first_hop = adjacency
            .clone()
            .matmul(features.clone())
            .to_data()
            .try_to_vec::<f32>()
            .unwrap();
        assert_eq!(first_hop[0], 0.0);

        let graph_output = model
            .forward(features.clone(), Some(adjacency))
            .to_data()
            .try_to_vec::<f32>()
            .unwrap();
        let mlp_output = model
            .forward(features, None)
            .to_data()
            .try_to_vec::<f32>()
            .unwrap();
        assert!(graph_output[0] > 0.0);
        assert_eq!(mlp_output[0], 0.0);
    }

    #[test]
    fn depth_controls_how_far_information_travels() {
        let device = Device::flex();
        let features = Tensor::from_data([[0.0], [0.0], [0.0], [1.0]], &device);
        let adjacency = Tensor::from_data(
            [
                [0.0, 1.0, 0.0, 0.0],
                [0.0, 0.0, 1.0, 0.0],
                [0.0, 0.0, 0.0, 1.0],
                [0.0, 0.0, 0.0, 1.0],
            ],
            &device,
        );

        for (hidden_layers, expected) in [
            (0, vec![0.0, 0.0, 1.0, 1.0]),
            (1, vec![0.0, 1.0, 1.0, 1.0]),
            (2, vec![1.0, 1.0, 1.0, 1.0]),
        ] {
            let model = known_model(hidden_layers, &device);
            let graph_output = model
                .forward(features.clone(), Some(adjacency.clone()))
                .to_data()
                .try_to_vec::<f32>()
                .unwrap();
            let mlp_output = model
                .forward(features.clone(), None)
                .to_data()
                .try_to_vec::<f32>()
                .unwrap();
            assert_eq!(
                graph_output, expected,
                "extra hidden layers: {hidden_layers}"
            );
            assert_eq!(mlp_output, vec![0.0, 0.0, 0.0, 1.0]);
        }
    }

    fn weight_values(model: &GradeRegressor) -> Vec<f32> {
        std::iter::once(&model.first)
            .chain(model.hidden.iter())
            .chain(std::iter::once(&model.output))
            .map(|layer| layer.weight.val().into_scalar::<f32>())
            .collect()
    }

    #[test]
    fn graph_weights_receive_gradients_and_optimizer_updates() {
        let device = Device::flex().autodiff();
        let model = known_model(3, &device);
        let features = Tensor::from_data([[1.0], [2.0]], &device);
        let adjacency = Tensor::from_data([[0.5, 0.5], [0.5, 0.5]], &device);
        let targets = Tensor::from_data([[0.0], [0.0]], &device);
        let loss = MseLoss::new().forward(
            model.forward(features, Some(adjacency)),
            targets,
            Reduction::Mean,
        );
        let grads = GradientsParams::from_grads(loss.backward(), &model);
        assert_eq!(grads.len(), 5);

        let original = weight_values(&model);
        let mut optimizer = AdamConfig::new().init();
        let updated = optimizer.step(0.01, model, grads);

        for (original, changed) in original.into_iter().zip(weight_values(&updated)) {
            assert!(changed < original);
        }
    }

    #[test]
    fn variable_depth_weights_round_trip() {
        let temporary = tempfile::tempdir().unwrap();
        let device = Device::flex();
        let features = Tensor::from_data([[1.0], [2.0]], &device);
        let adjacency = Tensor::from_data([[0.5, 0.5], [0.5, 0.5]], &device);

        for hidden_layers in [0, 3] {
            let model = GradeRegressor::new(4, hidden_layers, &device);
            let expected = model
                .forward(features.clone(), Some(adjacency.clone()))
                .to_data()
                .try_to_vec::<f32>()
                .unwrap();
            let path = temporary.path().join(format!("depth-{hidden_layers}.bpk"));
            model.into_record().save(&path).unwrap();
            let loaded = GradeRegressor::new(4, hidden_layers, &device)
                .try_load_file(&path)
                .unwrap();
            let actual = loaded
                .forward(features.clone(), Some(adjacency.clone()))
                .to_data()
                .try_to_vec::<f32>()
                .unwrap();
            assert_eq!(loaded.hidden.len(), hidden_layers);
            assert_eq!(actual, expected);
        }
    }
}
