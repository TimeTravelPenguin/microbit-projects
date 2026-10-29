use heapless::String;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum PlayerSymbol {
    X,
    O,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Player {
    pub name: String<8>,
    pub wins: u32,
    pub losses: u32,
}

/// A simple game of Tic-Tac-Toe implemented for the Micro:bit.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Game {
    players: [Player; 2],
    board: [[Option<PlayerSymbol>; 3]; 3],
    current_player: usize,
}

impl Game {
    pub fn new(host: Player, challenger: Player, host_first: bool) -> Self {
        Self {
            players: [host, challenger],
            board: [[None; 3]; 3],
            current_player: if host_first { 0 } else { 1 },
        }
    }
}
