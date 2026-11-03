//! Render the real UI using a synthetic chirp, without microphone hardware.

use std::{
    convert::Infallible,
    io::{self, Write},
};

use embedded_graphics::{pixelcolor::BinaryColor, prelude::*};
use micro_view_audio::{Analyzer, AudioView, HOP_LEN, SAMPLE_RATE};

struct Screen {
    pixels: [[u8; 128]; 64],
}

impl OriginDimensions for Screen {
    fn size(&self) -> Size {
        Size::new(128, 64)
    }
}

impl DrawTarget for Screen {
    type Color = BinaryColor;
    type Error = Infallible;

    fn draw_iter<Pixels>(&mut self, pixels: Pixels) -> Result<(), Self::Error>
    where
        Pixels: IntoIterator<Item = Pixel<Self::Color>>,
    {
        for Pixel(point, color) in pixels {
            if (0..128).contains(&point.x) && (0..64).contains(&point.y) {
                self.pixels[point.y as usize][point.x as usize] =
                    if color == BinaryColor::On { 255 } else { 0 };
            }
        }

        Ok(())
    }
}

fn main() -> io::Result<()> {
    let mut analyzer = Analyzer::new();
    let mut view = AudioView::new();

    for block_idx in 0..108 {
        let block = core::array::from_fn(|idx| {
            let time = (block_idx * HOP_LEN + idx) as f32 / SAMPLE_RATE as f32;
            let phase = std::f32::consts::TAU * (150.0 * time + 550.0 * time * time);
            let amplitude = 48.0 * (0.5 + 0.3 * (time * 5.0).sin());
            (7_700.0 + amplitude * phase.sin()).round() as i16
        });

        if let Some(analysis) = analyzer.push(&block) {
            view.update(analysis);
        }
    }

    let mut preview = [[0; 256]; 128];
    let mut screen = Screen {
        pixels: [[0; 128]; 64],
    };

    for mode_idx in 0..4 {
        view.render(&mut screen).unwrap();
        let x_offset = mode_idx % 2 * 128;
        let y_offset = mode_idx / 2 * 64;

        for (row_idx, row) in screen.pixels.iter().enumerate() {
            preview[y_offset + row_idx][x_offset..x_offset + 128].copy_from_slice(row);
        }

        view.next_mode();
    }

    let mut output = io::BufWriter::new(io::stdout().lock());
    write!(output, "P5\n256 128\n255\n")?;

    for row in preview {
        output.write_all(&row)?;
    }

    output.flush()
}
