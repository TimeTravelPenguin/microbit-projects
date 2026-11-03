//! Render the real pager drawing code using synthetic observations, without hardware.

use std::{convert::Infallible, fs, io::Write, path::Path};

use embedded_graphics::{pixelcolor::BinaryColor, prelude::*};
use micro_burn::protocol::{Label, Phase, Snapshot};
use micro_burn_firmware::{Button, Pager};

const WIDTH: usize = 128;
const HEIGHT: usize = 64;
const OUTPUT: &str = "/tmp/micro-burn-oled-preview";

struct PixelBuffer {
    pixels: [u8; WIDTH * HEIGHT],
}

impl PixelBuffer {
    fn new() -> Self {
        Self {
            pixels: [0; WIDTH * HEIGHT],
        }
    }

    fn save(&self, path: &Path) -> std::io::Result<()> {
        let mut file = fs::File::create(path)?;
        write!(file, "P5\n{WIDTH} {HEIGHT}\n255\n")?;
        file.write_all(&self.pixels)
    }
}

impl OriginDimensions for PixelBuffer {
    fn size(&self) -> Size {
        Size::new(WIDTH as u32, HEIGHT as u32)
    }
}

impl DrawTarget for PixelBuffer {
    type Color = BinaryColor;
    type Error = Infallible;

    fn draw_iter<DrawPixels>(&mut self, pixels: DrawPixels) -> Result<(), Self::Error>
    where
        DrawPixels: IntoIterator<Item = Pixel<Self::Color>>,
    {
        for Pixel(point, color) in pixels {
            if point.x >= 0 && point.x < WIDTH as i32 && point.y >= 0 && point.y < HEIGHT as i32 {
                let idx = point.y as usize * WIDTH + point.x as usize;
                self.pixels[idx] = if color == BinaryColor::On { 255 } else { 0 };
            }
        }

        Ok(())
    }
}

fn render(name: &str, pager: &Pager, now_ms: u64) -> Result<(), Box<dyn std::error::Error>> {
    let mut display = PixelBuffer::new();
    pager.draw(&mut display, now_ms)?;
    let path = Path::new(OUTPUT).join(format!("{name}.pgm"));
    display.save(&path)?;
    println!("Synthetic screen: {}", path.display());

    Ok(())
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    fs::create_dir_all(OUTPUT)?;
    let mut pager = Pager::new();
    render("waiting", &pager, 0)?;
    pager.set_connected(true);

    for sequence in 1..=64 {
        pager.apply(
            Snapshot {
                run_id: 42,
                sequence,
                phase: Phase::Training,
                epoch: 24,
                epochs: 150,
                progress_permille: 160,
                elapsed_secs: 180,
                eta_secs: Some(900),
                train_loss: Some(0.4 + (64 - sequence) as f32 * 0.01),
                valid_loss: Some(0.43),
                learning_rate: Some(0.001),
                label: Label::new("GNN sample data"),
                ..Snapshot::default()
            },
            u64::from(sequence) * 1_000,
        );
    }

    render("overview", &pager, 64_000)?;
    pager.press(Button::A, 64_000);
    render("metrics", &pager, 64_000)?;
    pager.press(Button::A, 64_000);
    render("details", &pager, 64_000)?;
    pager.press(Button::B, 64_000);
    render("menu", &pager, 64_000)?;

    pager.apply(
        Snapshot {
            run_id: 42,
            sequence: 65,
            event_id: 1,
            phase: Phase::Succeeded,
            progress_permille: 1_000,
            mae: Some(0.52),
            rmse: Some(0.71),
            label: Label::new("GNN sample data"),
            ..Snapshot::default()
        },
        65_000,
    );
    render("complete", &pager, 65_000)?;
    pager.set_connected(false);
    render("disconnected", &pager, 90_000)?;

    Ok(())
}
