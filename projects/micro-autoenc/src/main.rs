use std::fs;

use burn::{
    backend::{Autodiff, Wgpu, WgpuDevice, wgpu::graphics::WebGpu},
    prelude::*,
};

const DATASET_PATH: &str = "../datasets/VoiceBank-DEMAND-16k/data";

fn main() {
    // let device = Device::wgpu(Default::default());

    // All the training artifacts will be saved in this directory
    let artifact_dir = "artifacts";

    // Train the model
    // training::train::<MyAutodiffBackend>(
    //     artifact_dir,
    //     TrainingConfig::new(ModelConfig::new(10, 512), AdamConfig::new()),
    //     device.clone(),
    // );
    //
    // // Infer the model
    // inference::infer::<MyBackend>(
    //     artifact_dir,
    //     device,
    //     burn::data::dataset::vision::MnistDataset::test()
    //         .get(42)
    //         .unwrap(),
    // );

    let dataset = fs::read_dir(DATASET_PATH).unwrap();
    println!("Dataset files:");
    for entry in dataset {
        let entry = entry.unwrap();
        let path = entry.path();

        println!("{}", path.display());
    }
}
