//! Render the same screen on the host, using synthetic readings instead of hardware.

use std::{
    convert::Infallible,
    io::{self, Write},
};

use embedded_graphics::{pixelcolor::BinaryColor, prelude::*};
use micro_view::Plot;

struct Screen {
    pixels: [[bool; 128]; 64],
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
                self.pixels[point.y as usize][point.x as usize] = color == BinaryColor::On;
            }
        }

        Ok(())
    }
}

fn main() -> io::Result<()> {
    let mut plot = Plot::new();
    let mut screen = Screen {
        pixels: [[false; 128]; 64],
    };

    for sample_idx in 0..104 {
        let phase = sample_idx as f32 * 0.13;
        let acceleration_mg = (phase.sin() * 850.0) as i32;
        plot.record([acceleration_mg, 0, 0]);
    }

    plot.render(&mut screen).unwrap();

    // Portable graymap output: white OLED pixels are 255, the background is 0.
    let mut output = io::BufWriter::new(io::stdout().lock());
    write!(output, "P5\n128 64\n255\n")?;

    for row in screen.pixels {
        let brightness = row.map(|lit| if lit { 255 } else { 0 });
        output.write_all(&brightness)?;
    }

    output.flush()
}
