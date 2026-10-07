//! Tower-game state and rules, independent of buttons, timers, and the display.

use rand::{Rng, rngs::SmallRng};
use rtt_target::rprintln;

pub const MATRIX_SIZE: usize = 5;
pub type Matrix = [[u8; MATRIX_SIZE]; MATRIX_SIZE];

const INITIAL_BLOCK_COUNT: u8 = 3;
const BLOCK_BRIGHTNESS: u8 = 5;
const INITIAL_MOVE_INTERVAL_MS: u32 = 200;
const FASTEST_MOVE_INTERVAL_MS: u32 = 50;

#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub enum GameAction {
    Restart,
    PlaceBlocks,
}

#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub enum GameOutcome {
    Won,
    Lost,
}

/// Starting with three blocks, place each moving row on top of the tower.
/// Completion rules and outcome handling are still unfinished.
pub struct Arcade {
    rng: SmallRng,
    matrix: Matrix,
    move_interval_ms: u32,
    stack_height: u8,
    health: u8,
    move_direction: MoveDirection,
}

#[derive(Copy, Clone, Debug, PartialEq, Eq)]
enum MoveDirection {
    Left,
    Right,
}

impl MoveDirection {
    fn random(rng: &mut SmallRng) -> Self {
        if rng.random_bool(0.5) {
            Self::Left
        } else {
            Self::Right
        }
    }

    fn shift(self, row: &mut [u8; MATRIX_SIZE]) {
        match self {
            Self::Left => row.rotate_left(1),
            Self::Right => row.rotate_right(1),
        }
    }

    /// Return the next direction after a row has been shifted, reversing if the row has reached an edge.
    fn after_move(self, row: &[u8; MATRIX_SIZE]) -> Self {
        match self {
            Self::Left if row[0] > 0 => Self::Right,
            Self::Right if row[MATRIX_SIZE - 1] > 0 => Self::Left,
            direction => direction,
        }
    }
}

impl Arcade {
    pub fn new(mut rng: SmallRng) -> Self {
        let move_direction = MoveDirection::random(&mut rng);

        let mut arcade = Self {
            rng,
            matrix: [[0; MATRIX_SIZE]; MATRIX_SIZE],
            move_interval_ms: INITIAL_MOVE_INTERVAL_MS,
            stack_height: 0,
            health: INITIAL_BLOCK_COUNT,
            move_direction,
        };

        arcade.initialise_row();

        arcade
    }

    pub fn matrix(&self) -> &Matrix {
        &self.matrix
    }

    pub fn move_interval_ms(&self) -> u32 {
        self.move_interval_ms
    }

    pub fn active_row(&self) -> usize {
        (MATRIX_SIZE - 1).saturating_sub(self.stack_height as usize)
    }

    pub fn handle_action(&mut self, action: GameAction) {
        match action {
            GameAction::Restart => {
                rprintln!("Restarting game");
                self.reset();
            }
            GameAction::PlaceBlocks => {
                rprintln!("Dropping row");
                self.place_blocks();
            }
        }

        // A new row or restarted game must be scheduled at its current speed.
        self.update_move_interval();
    }

    /// Advance one movement tick; scheduling belongs to the application loop.
    pub fn tick(&mut self) {
        self.shift_row();
        self.update_direction();
        self.update_move_interval();
    }

    /// Placeholder for deciding whether the tower is complete or no blocks remain.
    pub fn outcome(&self) -> Option<GameOutcome> {
        // TODO: Define and evaluate the win and loss conditions.
        None
    }

    /// Placeholder for the game-over response and restart flow.
    pub fn handle_outcome(&mut self, _outcome: GameOutcome) {
        // TODO: Stop progression and present the result when outcomes are implemented.
    }

    fn reset(&mut self) {
        self.matrix = [[0; MATRIX_SIZE]; MATRIX_SIZE];
        self.stack_height = 0;
        self.health = INITIAL_BLOCK_COUNT;
        self.move_direction = MoveDirection::random(&mut self.rng);

        self.initialise_row();
    }

    fn initialise_row(&mut self) {
        if self.stack_height == 0 {
            self.initialise_first_row();
        } else {
            self.initialise_next_row();
        }
    }

    fn initialise_first_row(&mut self) {
        let row = self.active_row();
        let start_col = (MATRIX_SIZE - INITIAL_BLOCK_COUNT as usize) / 2;
        let block_columns = start_col..start_col + INITIAL_BLOCK_COUNT as usize;

        for (col, block) in self.matrix[row].iter_mut().enumerate() {
            *block = if block_columns.contains(&col) {
                BLOCK_BRIGHTNESS
            } else {
                0
            };
        }
    }

    fn initialise_next_row(&mut self) {
        let row = self.active_row();
        let previous_row = self.matrix[row + 1];

        for (block, previous_block) in self.matrix[row].iter_mut().zip(previous_row) {
            *block = if previous_block > 0 {
                BLOCK_BRIGHTNESS
            } else {
                0
            };
        }
    }

    fn shift_row(&mut self) {
        let row = self.active_row();
        self.move_direction.shift(&mut self.matrix[row]);
    }

    fn update_direction(&mut self) {
        let row = self.active_row();
        self.move_direction = self.move_direction.after_move(&self.matrix[row]);
    }

    fn place_blocks(&mut self) {
        if self.stack_height == 0 {
            self.raise_stack();
            return;
        }

        let row = self.active_row();
        let previous_row = self.matrix[row + 1];

        // TODO: Revisit health accounting; this still subtracts for empty columns.
        for (block, supporting_block) in self.matrix[row].iter_mut().zip(previous_row) {
            if !(*block > 0 && supporting_block > 0) {
                *block = 0;
                self.health = self.health.saturating_sub(1);
            }
        }

        self.raise_stack();
    }

    fn raise_stack(&mut self) {
        self.stack_height = self.stack_height.saturating_add(1);

        // TODO: Evaluate and handle outcomes before preparing another row.
        self.initialise_row();
    }

    fn update_move_interval(&mut self) {
        let progress = self.stack_height as f32 / MATRIX_SIZE as f32;
        let initial_interval = INITIAL_MOVE_INTERVAL_MS as f32;
        let fastest_interval = FASTEST_MOVE_INTERVAL_MS as f32;
        let interval = initial_interval + (fastest_interval - initial_interval) * progress;

        self.move_interval_ms =
            libm::roundf(interval).clamp(fastest_interval, initial_interval) as u32;
    }
}

#[cfg(test)]
mod tests;
