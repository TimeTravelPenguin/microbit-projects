//! Audited baseline friendship graphs with classroom-disjoint evaluation splits.

use std::{collections::BTreeSet, fs, path::Path};

use anyhow::{Context, Result, ensure};
use burn::tensor::{Device, Tensor, TensorData};
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Deserialize, Serialize)]
pub struct ClassroomGraph {
    pub classroom_id: String,
    pub classroom_type: String,
    pub split: String,
    pub student_ids: Vec<String>,
    pub features: Vec<Vec<f32>>,
    pub targets: Vec<f32>,
    /// Each undirected edge occurs once, using local indices into `student_ids`.
    pub edges: Vec<[usize; 2]>,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
pub struct Dataset {
    pub schema_version: u32,
    pub source: serde_json::Value,
    pub preprocessing: serde_json::Value,
    pub split: serde_json::Value,
    pub graphs: Vec<ClassroomGraph>,
}

#[derive(Clone, Copy, Debug, Deserialize, Serialize)]
pub struct FeatureScaling {
    pub mean: f32,
    pub std: f32,
}

/// One split as a disjoint union. Off-diagonal classroom blocks remain zero.
pub struct GraphBatch {
    pub features: Tensor<2>,
    pub targets: Tensor<2>,
    pub adjacency: Tensor<2>,
    pub student_ids: Vec<String>,
    pub classroom_ids: Vec<String>,
    pub prior_grades: Vec<f32>,
    pub target_values: Vec<f32>,
}

impl Dataset {
    pub fn load(path: &Path) -> Result<Self> {
        let bytes = fs::read(path).with_context(|| format!("reading {}", path.display()))?;
        let dataset: Self = serde_json::from_slice(&bytes).context("parsing classroom data")?;
        dataset.validate()?;

        Ok(dataset)
    }

    pub fn validate(&self) -> Result<()> {
        ensure!(self.schema_version == 1, "unsupported classroom schema");
        ensure!(
            self.preprocessing["feature_names"] == serde_json::json!(["grade_start"])
                && self.preprocessing["target_name"] == "grade_end"
                && self.preprocessing["network_wave"] == "start",
            "expected baseline grades/friendships and later-grade targets"
        );

        let mut classrooms = BTreeSet::new();
        let mut students = BTreeSet::new();

        for graph in &self.graphs {
            let nodes = graph.student_ids.len();
            ensure!(nodes > 0, "empty classroom {}", graph.classroom_id);
            ensure!(
                classrooms.insert(&graph.classroom_id),
                "duplicate classroom"
            );
            ensure!(
                matches!(graph.split.as_str(), "train" | "validation" | "test"),
                "invalid split"
            );
            ensure!(
                graph.features.len() == nodes && graph.targets.len() == nodes,
                "feature/target/ID count mismatch"
            );

            for ((student_id, features), target) in graph
                .student_ids
                .iter()
                .zip(&graph.features)
                .zip(&graph.targets)
            {
                ensure!(
                    students.insert(student_id),
                    "student occurs in multiple graphs"
                );
                ensure!(
                    features.len() == 1
                        && features[0].is_finite()
                        && (1.0..=5.0).contains(&features[0])
                        && target.is_finite()
                        && (1.0..=5.0).contains(target),
                    "invalid baseline feature or grade target"
                );
            }

            let mut edges = BTreeSet::new();

            for &[source, target] in &graph.edges {
                ensure!(
                    source < target && target < nodes,
                    "invalid local edge indices"
                );
                ensure!(edges.insert((source, target)), "duplicate edge");
            }
        }

        for split in ["train", "validation", "test"] {
            ensure!(
                self.graphs.iter().any(|graph| graph.split == split),
                "empty {split} split"
            );
            let declared: BTreeSet<_> = self.split[split]
                .as_array()
                .context("missing split manifest")?
                .iter()
                .map(|value| value.as_str().context("non-string classroom ID"))
                .collect::<Result<_>>()?;
            let actual: BTreeSet<_> = self
                .graphs
                .iter()
                .filter(|graph| graph.split == split)
                .map(|graph| graph.classroom_id.as_str())
                .collect();
            ensure!(actual == declared, "split manifest disagrees with graphs");
        }

        Ok(())
    }

    /// This calculation deliberately never reads validation/test feature values.
    pub fn fit_scaling(&self) -> FeatureScaling {
        let features: Vec<_> = self
            .graphs
            .iter()
            .filter(|graph| graph.split == "train")
            .flat_map(|graph| graph.features.iter().map(|features| features[0]))
            .collect();
        let mean = features.iter().sum::<f32>() / features.len() as f32;
        let variance = features
            .iter()
            .map(|value| (value - mean).powi(2))
            .sum::<f32>()
            / features.len() as f32;

        FeatureScaling {
            mean,
            std: variance.sqrt().max(1.0e-6),
        }
    }

    pub fn target_mean(&self) -> f64 {
        let targets: Vec<_> = self
            .graphs
            .iter()
            .filter(|graph| graph.split == "train")
            .flat_map(|graph| graph.targets.iter().copied())
            .collect();

        targets.iter().map(|target| f64::from(*target)).sum::<f64>() / targets.len() as f64
    }

    pub fn batch(&self, split: &str, scaling: FeatureScaling, device: &Device) -> GraphBatch {
        let graphs: Vec<_> = self
            .graphs
            .iter()
            .filter(|graph| graph.split == split)
            .collect();
        let nodes: usize = graphs.iter().map(|graph| graph.student_ids.len()).sum();
        let mut adjacency = vec![0.0_f32; nodes * nodes];
        let mut features = Vec::with_capacity(nodes);
        let mut targets = Vec::with_capacity(nodes);
        let mut student_ids = Vec::with_capacity(nodes);
        let mut classroom_ids = Vec::with_capacity(nodes);
        let mut prior_grades = Vec::with_capacity(nodes);
        let mut offset = 0;

        for graph in graphs {
            for (idx, student_id) in graph.student_ids.iter().enumerate() {
                let baseline = graph.features[idx][0];
                features.push((baseline - scaling.mean) / scaling.std);
                targets.push(graph.targets[idx]);
                prior_grades.push(baseline);
                student_ids.push(student_id.clone());
                classroom_ids.push(graph.classroom_id.clone());
                adjacency[(offset + idx) * nodes + offset + idx] = 1.0;
            }

            for &[source, target] in &graph.edges {
                adjacency[(offset + source) * nodes + offset + target] = 1.0;
                adjacency[(offset + target) * nodes + offset + source] = 1.0;
            }

            offset += graph.student_ids.len();
        }

        let degrees: Vec<_> = adjacency
            .chunks(nodes)
            .map(|row| row.iter().sum::<f32>())
            .collect();

        for (source, row) in adjacency.chunks_mut(nodes).enumerate() {
            for (target, weight) in row.iter_mut().enumerate() {
                *weight /= (degrees[source] * degrees[target]).sqrt();
            }
        }

        GraphBatch {
            features: Tensor::from_data(TensorData::new(features, [nodes, 1]), device),
            targets: Tensor::from_data(TensorData::new(targets.clone(), [nodes, 1]), device),
            adjacency: Tensor::from_data(TensorData::new(adjacency, [nodes, nodes]), device),
            student_ids,
            classroom_ids,
            prior_grades,
            target_values: targets,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn audited_data() -> Dataset {
        Dataset::load(&Path::new(env!("CARGO_MANIFEST_DIR")).join("../data/classrooms.json"))
            .unwrap()
    }

    #[test]
    fn audited_split_and_edges_are_preserved() {
        let dataset = audited_data();
        assert_eq!(dataset.graphs.len(), 12);
        assert_eq!(
            dataset
                .graphs
                .iter()
                .map(|graph| graph.student_ids.len())
                .sum::<usize>(),
            250
        );
        assert_eq!(
            dataset
                .graphs
                .iter()
                .map(|graph| graph.edges.len())
                .sum::<usize>(),
            1173
        );

        for (split, count) in [("train", 166), ("validation", 40), ("test", 44)] {
            let nodes = dataset
                .graphs
                .iter()
                .filter(|graph| graph.split == split)
                .map(|graph| graph.student_ids.len())
                .sum::<usize>();
            assert_eq!(nodes, count);
        }
    }

    #[test]
    fn held_out_features_do_not_change_training_scaling() {
        let mut dataset = audited_data();
        let original = dataset.fit_scaling();

        for graph in dataset
            .graphs
            .iter_mut()
            .filter(|graph| graph.split != "train")
        {
            for feature in &mut graph.features {
                feature[0] = 1000.0;
            }
        }

        let unchanged = dataset.fit_scaling();
        assert_eq!(original.mean, unchanged.mean);
        assert_eq!(original.std, unchanged.std);
    }

    #[test]
    fn duplicate_students_and_future_networks_are_rejected() {
        let mut dataset = audited_data();
        dataset.graphs[1].student_ids[0] = dataset.graphs[0].student_ids[0].clone();
        assert!(dataset.validate().is_err());

        let mut dataset = audited_data();
        dataset.preprocessing["network_wave"] = "end".into();
        assert!(dataset.validate().is_err());
    }
}
