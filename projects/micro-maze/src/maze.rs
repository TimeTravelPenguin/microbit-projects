use embedded_graphics::{
    pixelcolor::BinaryColor,
    prelude::*,
    primitives::{PrimitiveStyle, Rectangle},
};
use heapless::Vec;
use rand::{RngCore, seq::IteratorRandom};

pub const MAZE_COLUMNS: usize = 21;
pub const MAZE_ROWS: usize = 10;
pub const MAX_TILES: usize = MAZE_COLUMNS * MAZE_ROWS;
/// Cell spacing: four pixels of passage and two pixels of shared wall.
pub const TILE_SIZE: u32 = 6;
pub const WALL_THICKNESS: u32 = 2;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct MazeBuilderTile {
    pub top_wall: bool,
    pub right_wall: bool,
}

impl Default for MazeBuilderTile {
    fn default() -> Self {
        Self {
            top_wall: true,
            right_wall: true,
        }
    }
}

/// A randomized depth-first search, using fixed-capacity storage and no recursion.
pub struct MazeBuilder<Random> {
    /// Row-major tiles: `row * MAZE_COLUMNS + column`.
    pub tiles: [MazeBuilderTile; MAX_TILES],
    rng: Random,
    visited: [bool; MAX_TILES],
    path: Vec<usize, MAX_TILES>,
    currently_retracing: bool,
}

impl<Random: RngCore> MazeBuilder<Random> {
    /// Start with every wall closed and the top-left tile visited.
    pub fn new(rng: Random) -> Self {
        let mut visited = [false; MAX_TILES];
        visited[0] = true;

        let mut path = Vec::new();
        path.push(0).expect("The first tile fits in the path");

        Self {
            tiles: [MazeBuilderTile::default(); MAX_TILES],
            currently_retracing: false,
            rng,
            visited,
            path,
        }
    }

    pub fn reset(&mut self) {
        self.tiles = [MazeBuilderTile::default(); MAX_TILES];
        self.currently_retracing = false;
        self.visited.fill(false);
        self.visited[0] = true;
        self.path.clear();
        self.path.push(0).expect("The first tile fits in the path");
    }

    pub fn is_retracing(&self) -> bool {
        self.currently_retracing
    }

    /// Carve one passage to an unvisited neighbour, or backtrack one tile.
    /// Returns false once complete; further calls leave the maze unchanged.
    pub fn step(&mut self) -> bool {
        let Some(current) = self.current_tile() else {
            self.currently_retracing = false;
            return false;
        };

        let column = current % MAZE_COLUMNS;
        let row = current / MAZE_COLUMNS;
        let neighbours = [
            current.checked_sub(MAZE_COLUMNS),
            (column + 1 < MAZE_COLUMNS).then(|| current + 1),
            (row + 1 < MAZE_ROWS).then(|| current + MAZE_COLUMNS),
            (column > 0).then(|| current - 1),
        ];

        let next = neighbours
            .into_iter()
            .flatten()
            .filter(|&neighbour| !self.visited[neighbour])
            .choose(&mut self.rng);

        if let Some(next) = next {
            self.currently_retracing = false;

            // Each shared wall belongs to the tile below it or to its left.
            if next + MAZE_COLUMNS == current {
                self.tiles[current].top_wall = false;
            } else if next == current + 1 {
                self.tiles[current].right_wall = false;
            } else if next == current + MAZE_COLUMNS {
                self.tiles[next].top_wall = false;
            } else {
                self.tiles[next].right_wall = false;
            }

            self.visited[next] = true;
            // Only unvisited tiles are pushed, so the path cannot exceed MAX_TILES.
            self.path.push(next).expect("The path fits in the maze");
        } else {
            self.currently_retracing = true;
            self.path.pop();
        }

        true
    }

    pub fn is_complete(&self) -> bool {
        self.path.is_empty()
    }

    /// The tile at the search cursor, or None after generation finishes.
    pub fn current_tile(&self) -> Option<usize> {
        self.path.last().copied()
    }

    /// Query the neighbour's right wall, treating the left edge as closed.
    pub fn has_left_wall(&self, tile_idx: usize) -> bool {
        assert!(tile_idx < MAX_TILES);
        tile_idx.is_multiple_of(MAZE_COLUMNS) || self.tiles[tile_idx - 1].right_wall
    }

    /// Query the neighbour's top wall, treating the bottom edge as closed.
    pub fn has_bottom_wall(&self, tile_idx: usize) -> bool {
        assert!(tile_idx < MAX_TILES);
        tile_idx / MAZE_COLUMNS == MAZE_ROWS - 1 || self.tiles[tile_idx + MAZE_COLUMNS].top_wall
    }

    /// Redraw the maze and a 2×2 search cursor; the caller flushes the display.
    /// The extra outer wall makes the default 8×8 maze 50×50 pixels overall.
    pub fn render<Display>(&self, display: &mut Display) -> Result<(), Display::Error>
    where
        Display: DrawTarget<Color = BinaryColor>,
    {
        display.clear(BinaryColor::Off)?;

        let wall_style = PrimitiveStyle::with_fill(BinaryColor::On);
        let width = MAZE_COLUMNS as u32 * TILE_SIZE + WALL_THICKNESS;
        let height = MAZE_ROWS as u32 * TILE_SIZE + WALL_THICKNESS;

        Rectangle::new(Point::zero(), Size::new(WALL_THICKNESS, height))
            .into_styled(wall_style)
            .draw(display)?;

        Rectangle::new(
            Point::new(0, (height - WALL_THICKNESS) as i32),
            Size::new(width, WALL_THICKNESS),
        )
        .into_styled(wall_style)
        .draw(display)?;

        for (tile_idx, tile) in self.tiles.iter().enumerate() {
            let x = (tile_idx % MAZE_COLUMNS) as u32 * TILE_SIZE;
            let y = (tile_idx / MAZE_COLUMNS) as u32 * TILE_SIZE;

            if tile.top_wall {
                Rectangle::new(
                    Point::new(x as i32, y as i32),
                    Size::new(TILE_SIZE + WALL_THICKNESS, WALL_THICKNESS),
                )
                .into_styled(wall_style)
                .draw(display)?;
            }

            if tile.right_wall {
                Rectangle::new(
                    Point::new((x + TILE_SIZE) as i32, y as i32),
                    Size::new(WALL_THICKNESS, TILE_SIZE + WALL_THICKNESS),
                )
                .into_styled(wall_style)
                .draw(display)?;
            }
        }

        if let Some(current) = self.current_tile() {
            let x = (current % MAZE_COLUMNS) as u32 * TILE_SIZE + WALL_THICKNESS + 1;
            let y = (current / MAZE_COLUMNS) as u32 * TILE_SIZE + WALL_THICKNESS + 1;

            Rectangle::new(Point::new(x as i32, y as i32), Size::new(2, 2))
                .into_styled(wall_style)
                .draw(display)?;
        }

        Ok(())
    }
}

#[cfg(test)]
mod tests;
