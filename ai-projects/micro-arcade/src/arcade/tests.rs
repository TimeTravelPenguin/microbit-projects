use super::*;
use rand::SeedableRng;

fn arcade() -> Arcade {
    Arcade::new(SmallRng::seed_from_u64(42))
}

#[test]
fn starts_with_three_centered_blocks_on_the_bottom_row() {
    let game = arcade();

    assert_eq!(game.matrix()[4], [0, 5, 5, 5, 0]);
    assert_eq!(&game.matrix()[..4], &[[0; MATRIX_SIZE]; 4]);
    assert_eq!(game.move_interval_ms(), 1_000);
}

#[test]
fn movement_preserves_placed_rows_and_bounces_at_the_edge() {
    let mut game = arcade();
    game.handle_action(GameAction::PlaceBlocks);
    game.move_direction = MoveDirection::Left;
    let placed_row = game.matrix()[4];

    game.tick();

    assert_eq!(game.matrix()[3], [5, 5, 5, 0, 0]);
    assert_eq!(game.matrix()[4], placed_row);
    assert_eq!(game.move_direction, MoveDirection::Right);

    game.tick();

    assert_eq!(game.matrix()[3], [0, 5, 5, 5, 0]);
    assert_eq!(game.matrix()[4], placed_row);
}

#[test]
fn placement_retains_aligned_blocks_and_copies_them_to_the_next_row() {
    let mut game = arcade();
    game.handle_action(GameAction::PlaceBlocks);
    game.matrix[3] = [5, 5, 5, 0, 0];

    game.handle_action(GameAction::PlaceBlocks);

    assert_eq!(game.stack_height, 2);
    assert_eq!(game.matrix()[3], [0, 5, 5, 0, 0]);
    assert_eq!(game.matrix()[2], [0, 5, 5, 0, 0]);
    assert_eq!(game.matrix()[4], [0, 5, 5, 5, 0]);
}

#[test]
fn placing_a_row_updates_its_interval_before_the_next_movement() {
    let mut game = arcade();

    game.handle_action(GameAction::PlaceBlocks);

    assert_eq!(game.active_row(), 3);
    assert_eq!(game.move_interval_ms(), 810);

    game.handle_action(GameAction::PlaceBlocks);

    assert_eq!(game.active_row(), 2);
    assert_eq!(game.move_interval_ms(), 620);
}

#[test]
fn movement_interval_follows_stack_height_and_stays_clamped() {
    let mut game = arcade();

    for (height, expected_interval) in [(0, 1_000), (1, 810), (4, 240), (5, 50), (8, 50)] {
        game.stack_height = height;
        game.tick();

        assert_eq!(game.move_interval_ms(), expected_interval);
    }
}

#[test]
fn restart_clears_the_tower_and_restores_the_initial_row() {
    let mut game = arcade();
    game.handle_action(GameAction::PlaceBlocks);
    game.tick();

    game.handle_action(GameAction::Restart);

    assert_eq!(game.stack_height, 0);
    assert_eq!(game.health, INITIAL_BLOCK_COUNT);
    assert_eq!(game.matrix()[4], [0, 5, 5, 5, 0]);
    assert_eq!(&game.matrix()[..4], &[[0; MATRIX_SIZE]; 4]);
    assert_eq!(game.move_interval_ms(), 1_000);

    game.tick();

    assert_eq!(game.move_interval_ms(), 1_000);
}
