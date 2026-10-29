use embedded_graphics::{geometry::Size, pixelcolor::BinaryColor, primitives::Rectangle};
use embedded_graphics_simulator::{
    BinaryColorTheme, OutputSettingsBuilder, SimulatorDisplay, SimulatorEvent, Window,
    sdl2::{Keycode, Mod},
};
use embedded_layout::align::{Alignment, HorizontalAlignment, horizontal};

use micro_tictactoe::{app::App, settings::Settings};

#[derive(Clone, Copy, Default)]
enum MenuAlignment {
    Left,
    #[default]
    Center,
    Right,
}

impl Alignment for MenuAlignment {
    fn align_with_offset(&self, what: Rectangle, reference: Rectangle, offset: i32) -> i32 {
        match self {
            MenuAlignment::Left => horizontal::Left.align_with_offset(what, reference, offset),
            MenuAlignment::Center => horizontal::Center.align_with_offset(what, reference, offset),
            MenuAlignment::Right => horizontal::Right.align_with_offset(what, reference, offset),
        }
    }
}

impl HorizontalAlignment for MenuAlignment {}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut display = SimulatorDisplay::<BinaryColor>::new(Size::new(128, 64));
    let mut current_alignment = MenuAlignment::Center;
    let mut app = App::new(Settings::default())?;

    let output_settings = OutputSettingsBuilder::new()
        .theme(BinaryColorTheme::OledWhite)
        .build();

    let mut window = Window::new("Tic-tac-toe menu", &output_settings);

    println!("Tab/Down: next | Shift+Tab/Up: previous | Enter: select | T: align");

    'running: loop {
        app.draw_aligned(&mut display, current_alignment)?;
        window.update(&display);

        for event in window.events() {
            match event {
                SimulatorEvent::Quit => break 'running,
                SimulatorEvent::KeyDown {
                    keycode,
                    keymod,
                    repeat: false,
                } => match keycode {
                    Keycode::Tab if keymod.intersects(Mod::LSHIFTMOD | Mod::RSHIFTMOD) => {
                        app.select_previous();
                    }

                    Keycode::Tab | Keycode::Down => {
                        app.select_next();
                    }

                    Keycode::Up => {
                        app.select_previous();
                    }

                    Keycode::Return => {
                        if let Some(event) = app.select_item() {
                            println!("Menu event: {event:?}");
                        }
                    }

                    Keycode::T => {
                        current_alignment = match current_alignment {
                            MenuAlignment::Left => MenuAlignment::Center,
                            MenuAlignment::Center => MenuAlignment::Right,
                            MenuAlignment::Right => MenuAlignment::Left,
                        };
                    }

                    _ => {}
                },

                _ => {}
            }
        }
    }

    Ok(())
}
