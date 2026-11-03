use super::*;

fn worker(reporter: Reporter) -> (Worker, mpsc::Receiver<HostEvent>) {
    let (events, receiver) = mpsc::sync_channel(128);

    (
        Worker {
            reporter,
            events,
            state_path: None,
            manager: None,
            adapter: None,
            devices: HashMap::new(),
            selected: None,
            connection: None,
            actions: VecDeque::new(),
            sent: VecDeque::new(),
            received: None,
            last_saved: None,
        },
        receiver,
    )
}

#[test]
fn reporting_requires_no_bluetooth_or_runtime_and_retains_terminal_outcome() {
    let reporter = Reporter::new("GCN");
    let mut snapshot = reporter.begin_run("GCN");
    snapshot.phase = Phase::Training;
    snapshot.train_loss = Some(0.4);
    let observed = reporter.publish(snapshot).unwrap();
    assert!(observed.sequence > snapshot.sequence);
    snapshot = observed;
    snapshot.phase = Phase::Succeeded;
    snapshot.mae = Some(0.3);
    let terminal = reporter.publish(snapshot).unwrap();
    assert_ne!(terminal.event_id, 0);
    assert_eq!(*reporter.shared.terminal.lock().unwrap(), Some(terminal));
    assert_eq!(
        reporter.snapshot_at(terminal.run_id, observed.sequence),
        Some(observed)
    );
}

#[test]
fn stale_training_observations_do_not_undo_an_alert_policy_change() {
    let reporter = Reporter::new("GCN");
    let old = reporter.begin_run("GCN");
    reporter.set_alert_policy(AlertPolicy::Muted);
    let observed = reporter.publish(old).unwrap();
    assert_eq!(observed.alert_policy, AlertPolicy::Muted);
}

#[test]
fn acknowledgement_targets_the_actual_terminal_event() {
    let reporter = Reporter::new("GCN");
    let mut snapshot = reporter.begin_run("GCN");
    snapshot.phase = Phase::Failed;
    let snapshot = reporter.publish(snapshot).unwrap();
    let (mut worker, events) = worker(reporter.clone());
    let mut action = DeviceEvent {
        run_id: snapshot.run_id,
        sequence: snapshot.sequence,
        event_id: snapshot.event_id + 1,
        action_id: 1,
        kind: ActionKind::Acknowledged,
        value: 0,
    };

    assert!(!worker.apply_action(action));
    assert!(!reporter.snapshot().acknowledged);
    action.event_id = snapshot.event_id;
    assert!(worker.apply_action(action));
    assert!(reporter.snapshot().acknowledged);
    assert!(matches!(events.try_recv(), Ok(HostEvent::Action(_))));
    assert!(reporter.publish(snapshot).unwrap().acknowledged);
}

#[test]
fn bookmark_records_the_displayed_snapshot_instead_of_latest_training_step() {
    let reporter = Reporter::new("GCN");
    let original = reporter.begin_run("GCN");
    let mut next = original;
    next.epoch = 7;
    reporter.publish(next).unwrap();
    let (mut worker, events) = worker(reporter);
    let action = DeviceEvent {
        run_id: original.run_id,
        sequence: original.sequence,
        event_id: 0,
        action_id: 2,
        kind: ActionKind::Bookmark,
        value: 0,
    };

    assert!(worker.apply_action(action));
    let HostEvent::Bookmark { snapshot, .. } = events.try_recv().unwrap() else {
        panic!("expected a bookmark");
    };

    assert_eq!(snapshot, original);
}

#[tokio::test]
async fn repeated_actions_do_not_create_duplicate_bookmarks() {
    let reporter = Reporter::new("GCN");
    let snapshot = reporter.begin_run("GCN");
    let (mut worker, events) = worker(reporter);
    let action = DeviceEvent {
        run_id: snapshot.run_id,
        sequence: snapshot.sequence,
        event_id: 0,
        action_id: 8,
        kind: ActionKind::Bookmark,
        value: 0,
    };

    worker.action(action).await.unwrap();
    worker.action(action).await.unwrap();
    assert_eq!(
        events
            .try_iter()
            .filter(|event| matches!(event, HostEvent::Bookmark { .. }))
            .count(),
        1
    );
}

#[tokio::test]
async fn retained_result_round_trips_and_recovery_never_overwrites_a_new_run() {
    let path = std::env::temp_dir().join(format!(
        "micro-burn-{}-{}.json",
        std::process::id(),
        next_run_id()
    ));
    let reporter = Reporter::new("GCN");
    let mut snapshot = reporter.begin_run("GCN");
    snapshot.phase = Phase::Succeeded;
    snapshot.acknowledged = true;
    let snapshot = reporter.publish(snapshot).unwrap();
    write_retained(&path, &snapshot).await.unwrap();
    let recovered = Reporter::new("other");
    let (mut worker, events) = worker(recovered.clone());
    worker.state_path = Some(path.clone());
    worker.restore().await;
    assert_eq!(recovered.snapshot(), snapshot);
    assert!(matches!(events.try_recv(), Ok(HostEvent::Recovered(_))));
    let new = recovered.begin_run("new training");
    worker.restore().await;
    assert_eq!(recovered.snapshot(), new);
    tokio::fs::remove_file(path).await.unwrap();
}

#[test]
fn alert_interaction_and_heartbeats_do_not_make_trainer_data_fresh() {
    let reporter = Reporter::new("GCN");
    reporter.begin_run("GCN");
    *reporter.shared.last_observation.lock().unwrap() = Instant::now() - Duration::from_secs(30);
    reporter.set_alert_policy(AlertPolicy::Muted);
    assert!(reporter.snapshot().trainer_age_secs >= 30);
    let observation = reporter.snapshot();
    let observed = reporter.publish(observation).unwrap();
    assert_eq!(observed.trainer_age_secs, 0);
}

#[test]
fn transmitted_history_preserves_a_bookmark_during_fast_training() {
    let reporter = Reporter::new("GCN");
    let displayed = reporter.begin_run("GCN");
    let (mut worker, events) = worker(reporter.clone());
    worker.sent.push_back(displayed);

    for _ in 0..HISTORY_LIMIT + 10 {
        reporter.publish(reporter.snapshot()).unwrap();
    }

    assert!(
        reporter
            .snapshot_at(displayed.run_id, displayed.sequence)
            .is_none()
    );
    let action = DeviceEvent {
        run_id: displayed.run_id,
        sequence: displayed.sequence,
        event_id: 0,
        action_id: 3,
        kind: ActionKind::Bookmark,
        value: 0,
    };

    assert!(worker.apply_action(action));
    assert!(
        matches!(events.try_recv(), Ok(HostEvent::Bookmark { snapshot, .. }) if snapshot == displayed)
    );
}

#[tokio::test]
async fn receipt_confirms_delivery_without_acknowledging_the_user_alert() {
    let reporter = Reporter::new("GCN");
    let mut snapshot = reporter.begin_run("GCN");
    snapshot.phase = Phase::Succeeded;
    let snapshot = reporter.publish(snapshot).unwrap();
    let (mut worker, events) = worker(reporter.clone());
    worker.sent.push_back(snapshot);
    let receipt = DeviceEvent {
        run_id: snapshot.run_id,
        sequence: snapshot.sequence,
        event_id: snapshot.event_id,
        action_id: 0,
        kind: ActionKind::Received,
        value: 0,
    };

    worker.action(receipt).await.unwrap();
    worker.action(receipt).await.unwrap();
    assert_eq!(worker.received, Some((snapshot.run_id, snapshot.sequence)));
    assert!(!reporter.snapshot().acknowledged);
    assert_eq!(events.try_iter().count(), 1);
}

#[tokio::test]
async fn bookmark_journal_deduplicates_a_retry_after_process_restart() {
    let path = std::env::temp_dir().join(format!(
        "micro-burn-bookmark-{}-{}.jsonl",
        std::process::id(),
        next_run_id()
    ));
    let reporter = Reporter::new("GCN");
    let snapshot = reporter.begin_run("GCN");
    let event = DeviceEvent {
        run_id: snapshot.run_id,
        sequence: snapshot.sequence,
        event_id: 0,
        action_id: 15,
        kind: ActionKind::Bookmark,
        value: 0,
    };

    write_bookmark(&path, event, &snapshot).await.unwrap();
    write_bookmark(&path, event, &snapshot).await.unwrap();
    let journal = tokio::fs::read_to_string(&path).await.unwrap();
    assert_eq!(journal.lines().count(), 1);
    let record: serde_json::Value = serde_json::from_str(journal.lines().next().unwrap()).unwrap();
    assert_eq!(
        record["snapshot"]["sequence"].as_u64(),
        Some(snapshot.sequence as u64)
    );
    tokio::fs::remove_file(path).await.unwrap();
}

#[test]
fn immediate_shutdown_flushes_terminal_state_without_bluetooth_access() {
    let path = std::env::temp_dir().join(format!(
        "micro-burn-shutdown-{}-{}.json",
        std::process::id(),
        next_run_id()
    ));
    let mut monitor = Monitor::new("GCN", Some(path.clone())).unwrap();
    let mut snapshot = monitor.reporter.begin_run("GCN");
    snapshot.phase = Phase::Succeeded;
    let snapshot = monitor.reporter.publish(snapshot).unwrap();
    monitor.shutdown().unwrap();
    let saved: Snapshot = serde_json::from_slice(&std::fs::read(&path).unwrap()).unwrap();
    assert_eq!(saved, snapshot);
    std::fs::remove_file(path).unwrap();
}

#[tokio::test]
async fn reconnect_is_never_authorized_without_an_explicit_selection() {
    let reporter = Reporter::new("GCN");
    let (mut worker, _) = worker(reporter);
    assert!(worker.connect().await.is_err());
    assert!(worker.adapter.is_none());
    assert!(worker.manager.is_none());
}

#[tokio::test]
async fn connection_loss_preserves_selection_and_pending_terminal_result() {
    let reporter = Reporter::new("GCN");
    let mut snapshot = reporter.begin_run("GCN");
    snapshot.phase = Phase::Succeeded;
    let snapshot = reporter.publish(snapshot).unwrap();
    let (mut worker, _) = worker(reporter.clone());
    worker.selected = Some("selected-platform-id".into());
    worker.received = Some((snapshot.run_id, snapshot.sequence));
    worker.disconnect().await;
    assert_eq!(worker.selected.as_deref(), Some("selected-platform-id"));
    assert_eq!(worker.received, None);
    assert_eq!(reporter.snapshot().event_id, snapshot.event_id);
    assert!(!reporter.snapshot().acknowledged);
    assert!(worker.adapter.is_none());
}

#[tokio::test]
async fn starting_another_run_cannot_recover_the_previous_success_after_a_crash() {
    let path = std::env::temp_dir().join(format!(
        "micro-burn-active-{}-{}.json",
        std::process::id(),
        next_run_id()
    ));
    let reporter = Reporter::new("GCN");
    let mut previous = reporter.begin_run("previous");
    previous.phase = Phase::Succeeded;
    reporter.publish(previous).unwrap();
    let (mut previous_worker, _) = worker(reporter.clone());
    previous_worker.state_path = Some(path.clone());
    previous_worker.persist().await;
    let active = reporter.begin_run("unfinished");
    previous_worker.persist().await;
    let saved: Snapshot = serde_json::from_slice(&tokio::fs::read(&path).await.unwrap()).unwrap();
    assert_eq!(saved.run_id, active.run_id);
    assert!(!saved.phase.is_terminal());
    let fresh_reporter = Reporter::new("GCN");
    let (mut restarted, events) = worker(fresh_reporter.clone());
    restarted.state_path = Some(path.clone());
    restarted.restore().await;
    assert_eq!(fresh_reporter.snapshot().phase, Phase::Idle);
    let events: Vec<_> = events.try_iter().collect();
    assert!(
        !events
            .iter()
            .any(|event| matches!(event, HostEvent::Recovered(_)))
    );
    assert!(events.iter().any(
        |event| matches!(event, HostEvent::Error(message) if message.contains("status unknown"))
    ));
    tokio::fs::remove_file(path).await.unwrap();
}
