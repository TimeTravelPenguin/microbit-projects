use core::convert::Infallible;

use embedded_graphics::pixelcolor::BinaryColor;
use rand::{SeedableRng, rngs::SmallRng};

use super::*;

struct Framebuffer {
    pixels: [[BinaryColor; 64]; 64],
}

impl Framebuffer {
    fn new() -> Self {
        Self {
            pixels: [[BinaryColor::On; 64]; 64],
        }
    }
}

impl OriginDimensions for Framebuffer {
    fn size(&self) -> Size {
        Size::new(64, 64)
    }
}

impl DrawTarget for Framebuffer {
    type Color = BinaryColor;
    type Error = Infallible;

    fn draw_iter<Pixels>(&mut self, pixels: Pixels) -> Result<(), Self::Error>
    where
        Pixels: IntoIterator<Item = Pixel<Self::Color>>,
    {
        for Pixel(point, color) in pixels {
            assert!(self.bounding_box().contains(point));
            self.pixels[point.y as usize][point.x as usize] = color;
        }

        Ok(())
    }
}

fn new_maze(seed: u64) -> MazeBuilder<SmallRng> {
    MazeBuilder::new(SmallRng::seed_from_u64(seed))
}

fn walls(maze: &MazeBuilder<SmallRng>) -> [(bool, bool); MAX_TILES] {
    core::array::from_fn(|idx| (maze.tiles[idx].top_wall, maze.tiles[idx].right_wall))
}

fn finish(maze: &mut MazeBuilder<SmallRng>) {
    for _ in 0..2 * MAX_TILES - 1 {
        assert!(maze.step());
    }

    assert!(maze.is_complete());
}

#[test]
fn starts_at_first_tile_with_every_wall_closed() {
    let maze = new_maze(0);

    assert_eq!(MAZE_COLUMNS, 8);
    assert_eq!(MAZE_ROWS, 8);
    assert_eq!(maze.tiles.len(), MAZE_COLUMNS * MAZE_ROWS);
    assert!(
        maze.tiles
            .iter()
            .all(|tile| tile.top_wall && tile.right_wall)
    );
    assert_eq!(maze.current_tile(), Some(0));
    assert!(!maze.is_complete());
}

#[test]
fn each_step_carves_one_correct_shared_wall_or_backtracks() {
    let mut carved_left = false;
    let mut carved_down = false;

    for seed in 0..16 {
        let mut maze = new_maze(seed);
        let mut visited = [false; MAX_TILES];
        visited[0] = true;

        for _ in 0..2 * MAX_TILES - 1 {
            let previous = maze.current_tile().unwrap();
            let before = walls(&maze);
            assert!(maze.step());

            let mut removed = None;

            for (idx, (top_wall, right_wall)) in before.into_iter().enumerate() {
                let tile = &maze.tiles[idx];
                assert!(!tile.top_wall || top_wall, "a top wall was added");
                assert!(!tile.right_wall || right_wall, "a right wall was added");

                for (changed, is_top) in [
                    (top_wall && !tile.top_wall, true),
                    (right_wall && !tile.right_wall, false),
                ] {
                    if changed {
                        assert!(removed.replace((idx, is_top)).is_none());
                    }
                }
            }

            if let Some((owner, is_top)) = removed {
                let current = maze.current_tile().unwrap();
                assert!(!visited[current], "carving must visit a new tile");
                visited[current] = true;

                if current / MAZE_COLUMNS == previous / MAZE_COLUMNS {
                    assert_eq!(current.abs_diff(previous), 1);
                    assert!(!is_top);
                    assert_eq!(owner, current.min(previous));
                    carved_left |= current < previous;
                } else {
                    assert_eq!(current.abs_diff(previous), MAZE_COLUMNS);
                    assert!(is_top);
                    assert_eq!(owner, current.max(previous));
                    carved_down |= current > previous;
                }
            } else if let Some(current) = maze.current_tile() {
                assert!(
                    visited[current],
                    "backtracking must return to a visited tile"
                );
            }
        }

        assert!(visited.into_iter().all(|tile_visited| tile_visited));
        assert!(maze.is_complete());
        assert_eq!(maze.current_tile(), None);
    }

    assert!(carved_left, "seeds must exercise leftward carving");
    assert!(carved_down, "seeds must exercise downward carving");
}

#[test]
fn finished_maze_is_connected_has_no_cycles_and_stays_complete() {
    for seed in 0..16 {
        let mut maze = new_maze(seed);
        finish(&mut maze);

        let passage_count = maze
            .tiles
            .iter()
            .map(|tile| usize::from(!tile.top_wall) + usize::from(!tile.right_wall))
            .sum::<usize>();
        assert_eq!(passage_count, MAX_TILES - 1);

        for column in 0..MAZE_COLUMNS {
            assert!(maze.tiles[column].top_wall, "outer top wall was opened");
        }

        for row in 0..MAZE_ROWS {
            assert!(maze.tiles[row * MAZE_COLUMNS + MAZE_COLUMNS - 1].right_wall);
        }

        for idx in 0..MAX_TILES {
            let left_wall = idx % MAZE_COLUMNS == 0 || maze.tiles[idx - 1].right_wall;
            let bottom_wall =
                idx / MAZE_COLUMNS == MAZE_ROWS - 1 || maze.tiles[idx + MAZE_COLUMNS].top_wall;
            assert_eq!(maze.has_left_wall(idx), left_wall);
            assert_eq!(maze.has_bottom_wall(idx), bottom_wall);
        }

        let mut reached = [false; MAX_TILES];
        let mut pending = [0; MAX_TILES];
        let mut pending_count = 1;
        let mut next = 0;
        reached[0] = true;

        while next < pending_count {
            let idx = pending[next];
            next += 1;

            let column = idx % MAZE_COLUMNS;
            let row = idx / MAZE_COLUMNS;
            let neighbours = [
                (column > 0).then(|| (idx - 1, !maze.tiles[idx - 1].right_wall)),
                (column + 1 < MAZE_COLUMNS).then(|| (idx + 1, !maze.tiles[idx].right_wall)),
                (row > 0).then(|| (idx - MAZE_COLUMNS, !maze.tiles[idx].top_wall)),
                (row + 1 < MAZE_ROWS)
                    .then(|| (idx + MAZE_COLUMNS, !maze.tiles[idx + MAZE_COLUMNS].top_wall)),
            ];

            for (neighbour, open) in neighbours.into_iter().flatten() {
                if open && !reached[neighbour] {
                    reached[neighbour] = true;
                    pending[pending_count] = neighbour;
                    pending_count += 1;
                }
            }
        }

        assert!(reached.into_iter().all(|tile_reached| tile_reached));

        let completed_walls = walls(&maze);

        for _ in 0..3 {
            assert!(!maze.step());
            assert!(maze.is_complete());
            assert_eq!(maze.current_tile(), None);
            assert_eq!(walls(&maze), completed_walls);
        }
    }
}

#[test]
fn render_uses_six_pixel_pitch_and_two_pixel_walls() {
    let maze = new_maze(0);
    let mut display = Framebuffer::new();
    maze.render(&mut display).unwrap();

    assert_eq!(TILE_SIZE, 6);
    assert_eq!(WALL_THICKNESS, 2);

    for offset in 0..50 {
        for thickness in 0..2 {
            assert_eq!(display.pixels[thickness][offset], BinaryColor::On);
            assert_eq!(display.pixels[48 + thickness][offset], BinaryColor::On);
            assert_eq!(display.pixels[offset][thickness], BinaryColor::On);
            assert_eq!(display.pixels[offset][48 + thickness], BinaryColor::On);
        }
    }

    for thickness in 0..2 {
        assert_eq!(display.pixels[6 + thickness][9], BinaryColor::On);
        assert_eq!(display.pixels[9][12 + thickness], BinaryColor::On);
    }

    for (column, row) in [(9, 5), (9, 8), (11, 9), (14, 9), (50, 0), (0, 50), (63, 63)] {
        assert_eq!(display.pixels[row][column], BinaryColor::Off);
    }

    for row in 3..5 {
        for column in 3..5 {
            assert_eq!(display.pixels[row][column], BinaryColor::On);
        }
    }

    assert_eq!(display.pixels[3][2], BinaryColor::Off);
    assert_eq!(display.pixels[3][5], BinaryColor::Off);
}

#[test]
fn redraw_erases_carved_passages_and_moves_then_removes_cursor() {
    let mut maze = new_maze(3);
    let mut display = Framebuffer::new();
    maze.render(&mut display).unwrap();
    assert!(maze.step());
    maze.render(&mut display).unwrap();

    assert_eq!(display.pixels[3][3], BinaryColor::Off);

    let current = maze.current_tile().unwrap();
    let cursor_column = current % MAZE_COLUMNS * 6 + 3;
    let cursor_row = current / MAZE_COLUMNS * 6 + 3;
    assert_eq!(display.pixels[cursor_row][cursor_column], BinaryColor::On);

    for _ in 1..2 * MAX_TILES - 1 {
        assert!(maze.step());
        maze.render(&mut display).unwrap();

        for (idx, tile) in maze.tiles.iter().enumerate() {
            let column = idx % MAZE_COLUMNS * 6;
            let row = idx / MAZE_COLUMNS * 6;

            for thickness in 0..2 {
                assert_eq!(
                    display.pixels[row + thickness][column + 3],
                    BinaryColor::from(tile.top_wall)
                );
                assert_eq!(
                    display.pixels[row + 3][column + 6 + thickness],
                    BinaryColor::from(tile.right_wall)
                );
            }
        }
    }

    assert!(maze.is_complete());

    for idx in 0..MAX_TILES {
        let column = idx % MAZE_COLUMNS * 6 + 3;
        let row = idx / MAZE_COLUMNS * 6 + 3;
        assert_eq!(display.pixels[row][column], BinaryColor::Off);
    }
}
