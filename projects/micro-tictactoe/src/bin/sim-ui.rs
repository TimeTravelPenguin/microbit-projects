use embedded_graphics::{geometry::Size, pixelcolor::BinaryColor, primitives::Rectangle};
use embedded_graphics_simulator::{
    BinaryColorTheme, OutputSettingsBuilder, SimulatorDisplay, SimulatorEvent, Window,
    sdl2::{Keycode, Mod},
};
use embedded_layout::align::{Alignment, HorizontalAlignment, horizontal};

use micro_tictactoe::{
    app::{App, AppEffect},
    input::{NavigationKey, navigation_action},
    settings::Settings,
};

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

    println!("Tab/Down: next | Shift+Tab/Up: previous | Enter: select | Escape: back | T: align");
    println!("Editing: Up/Down: change character | Left/Right: cursor | Delete/Backspace: delete");
    println!("Editing: Enter: accept | Escape: cancel | Tab/Shift+Tab: ignored");

    let mut needs_redraw = true;

    'running: loop {
        if needs_redraw {
            app.draw_aligned(&mut display, current_alignment)?;
            needs_redraw = false;
        }

        window.update(&display);

        for event in window.events() {
            let key = match event {
                SimulatorEvent::Quit => break 'running,
                SimulatorEvent::KeyDown {
                    keycode,
                    keymod,
                    repeat: false,
                } => match keycode {
                    Keycode::T => {
                        current_alignment = match current_alignment {
                            MenuAlignment::Left => MenuAlignment::Center,
                            MenuAlignment::Center => MenuAlignment::Right,
                            MenuAlignment::Right => MenuAlignment::Left,
                        };

                        needs_redraw = true;

                        None
                    }

                    _ => navigation_key(keycode, keymod),
                },

                _ => None,
            };

            if let Some(action) = key.and_then(|key| navigation_action(key, app.is_editing())) {
                let update = app.handle(action)?;
                needs_redraw |= update.redraw;

                if let Some(effect) = update.effect {
                    report_effect(effect);
                }
            }
        }
    }

    Ok(())
}

fn navigation_key(key: Keycode, modifiers: Mod) -> Option<NavigationKey> {
    match key {
        Keycode::Up => Some(NavigationKey::Up),
        Keycode::Down => Some(NavigationKey::Down),
        Keycode::Left => Some(NavigationKey::Left),
        Keycode::Right => Some(NavigationKey::Right),
        Keycode::Tab if modifiers.intersects(Mod::LSHIFTMOD | Mod::RSHIFTMOD) => {
            Some(NavigationKey::BackTab)
        }

        Keycode::Tab => Some(NavigationKey::Tab),
        Keycode::Return => Some(NavigationKey::Select),
        Keycode::Escape => Some(NavigationKey::Back),
        Keycode::Delete | Keycode::Backspace => Some(NavigationKey::Delete),
        _ => None,
    }
}

fn report_effect(effect: AppEffect) {
    match effect {
        AppEffect::NewGame => println!("New game requested"),
        AppEffect::JoinGame => println!("Join game requested"),
        AppEffect::SaveSettings(settings) => {
            println!("Settings changed in simulator: {settings:?}");
        }
    }
}
