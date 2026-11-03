use super::*;

fn snapshot(sequence: u32) -> Snapshot {
    Snapshot {
        run_id: 72,
        sequence,
        phase: Phase::Training,
        epoch: 3,
        epochs: 50,
        progress_permille: 67,
        elapsed_secs: 21,
        eta_secs: Some(292),
        train_loss: Some(0.25),
        valid_loss: None,
        learning_rate: Some(0.001),
        label: Label::new("Czech GCN"),
        ..Snapshot::default()
    }
}

#[test]
fn complete_snapshot_round_trips_out_of_order_and_preserves_unavailable_values() {
    let original = snapshot(4);
    let frames = original.frames();
    let mut assembler = SnapshotAssembler::new();

    for idx in [7, 2, 5, 0, 6, 1, 3] {
        assert_eq!(assembler.push(&frames[idx], 10), Ok(None));
    }

    assert_eq!(assembler.push(&frames[4], 10), Ok(Some(original)));
}

#[test]
fn fragments_from_two_snapshots_never_form_a_mixed_observation() {
    let old = snapshot(1).frames();
    let newer = snapshot(2);
    let frames = newer.frames();
    let mut assembler = SnapshotAssembler::new();
    assert_eq!(assembler.push(&old[0], 0), Ok(None));
    assert_eq!(assembler.push(&frames[1], 1), Ok(None));
    assert_eq!(assembler.push(&old[2], 2), Err(ProtocolError::Outdated));

    for idx in [0, 2, 3, 4, 5, 6] {
        assert_eq!(assembler.push(&frames[idx], 3), Ok(None));
    }

    assert_eq!(assembler.push(&frames[7], 3), Ok(Some(newer)));
}

#[test]
fn expired_assembly_requires_all_fragments_again() {
    let frames = snapshot(3).frames();
    let mut assembler = SnapshotAssembler::new();
    assembler.push(&frames[0], 0).unwrap();

    for frame in &frames[1..] {
        assert_eq!(assembler.push(frame, 4_000), Ok(None));
    }

    assert_eq!(assembler.push(&frames[0], 4_001), Ok(Some(snapshot(3))));
}

#[test]
fn malformed_frames_and_nonfinite_metrics_are_rejected() {
    let mut assembler = SnapshotAssembler::new();
    assert_eq!(
        assembler.push(&[0; 19], 0),
        Err(ProtocolError::InvalidLength)
    );
    let mut frames = snapshot(9).frames();
    frames[0][0] = VERSION + 1;
    assert_eq!(
        assembler.push(&frames[0], 0),
        Err(ProtocolError::UnsupportedVersion)
    );
    let mut invalid = snapshot(9);
    invalid.train_loss = Some(f32::INFINITY);
    assert_eq!(invalid.validate(), Err(ProtocolError::InvalidValue));
    invalid.train_loss = Some(f32::NAN);
    assert_eq!(invalid.validate(), Err(ProtocolError::InvalidValue));
}

#[test]
fn terminal_results_and_action_ids_round_trip() {
    let event = DeviceEvent {
        run_id: 9,
        sequence: 701,
        event_id: 32,
        action_id: 4,
        kind: ActionKind::Acknowledged,
        value: 0,
    };

    assert_eq!(DeviceEvent::decode(&event.encode()), Ok(event));
    let result = ActionResult {
        run_id: event.run_id,
        sequence: event.sequence,
        action_id: event.action_id,
        accepted: true,
    };

    assert_eq!(ActionResult::decode(&result.encode()), Ok(result));
    let status = DeviceStatus {
        run_id: 9,
        sequence: 701,
        event_id: 32,
        acknowledged: true,
        alert_policy: AlertPolicy::ErrorsOnly,
    };

    assert_eq!(DeviceStatus::decode(&status.encode()), Ok(status));
}

#[test]
fn completed_sequences_reject_stale_data_and_accept_wrapping_sequence() {
    let mut assembler = SnapshotAssembler::new();

    for frame in snapshot(u32::MAX).frames() {
        assembler.push(&frame, 0).unwrap();
    }

    let original = snapshot(0);
    let mut complete = None;

    for frame in original.frames() {
        complete = assembler.push(&frame, 1).unwrap();
    }

    assert_eq!(complete, Some(original));
    assert_eq!(
        assembler.push(&snapshot(u32::MAX - 1).frames()[0], 1),
        Err(ProtocolError::Outdated)
    );
}

#[test]
fn labels_are_printable_and_bounded() {
    assert_eq!(Label::new("GNN\nCzech 🎓").as_str(), "GNN?Czech ?");
    assert_eq!(
        Label::new("0123456789abcdefextra").as_str(),
        "0123456789abcdef"
    );
}
