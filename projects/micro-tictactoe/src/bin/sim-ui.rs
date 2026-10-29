use embedded_graphics::{
    Drawable,
    draw_target::DrawTarget,
    geometry::{Dimensions, Size},
    mono_font::iso_8859_10::FONT_6X10,
    pixelcolor::BinaryColor,
    primitives::Rectangle,
    text::Alignment as TextAlignment,
};
use embedded_graphics_simulator::{
    BinaryColorTheme, OutputSettingsBuilder, SimulatorDisplay, SimulatorEvent, Window,
    sdl2::{Keycode, Mod},
};
use embedded_layout::align::{Align, Alignment, HorizontalAlignment, horizontal, vertical};

use micro_tictactoe::ui::{Menu, MenuAction, MenuStyle};

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
    let display_area = display.bounding_box();

    let mut current_alignment = MenuAlignment::Center;
    let menu_style = MenuStyle {
        font: &FONT_6X10,
        text_alignment: TextAlignment::Center,
        ..Default::default()
    };

    let mut menu =
        Menu::<BinaryColor, 24, 4>::new_with_items(&["New game", "Join game", "Settings"])?
            .set_style(menu_style)
            .align_to(&display_area, current_alignment, vertical::Center);

    let output_settings = OutputSettingsBuilder::new()
        .theme(BinaryColorTheme::OledWhite)
        .build();

    let mut window = Window::new("Tic-tac-toe menu", &output_settings);

    println!("Tab/Down: next | Shift+Tab/Up: previous | Enter: select | T: align");

    'running: loop {
        display.clear(BinaryColor::Off)?;
        menu.draw(&mut display)?;
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
                        menu.handle_action(MenuAction::PreviousItem);
                    }

                    Keycode::Tab | Keycode::Down => {
                        menu.handle_action(MenuAction::NextItem);
                    }

                    Keycode::Up => {
                        menu.handle_action(MenuAction::PreviousItem);
                    }

                    Keycode::Return => {
                        if let (Some(index), Some(item)) = (
                            menu.handle_action(MenuAction::SelectItem),
                            menu.selected_item(),
                        ) {
                            println!("Selected item {index}: {item}");
                        }
                    }

                    Keycode::T => {
                        current_alignment = match current_alignment {
                            MenuAlignment::Left => MenuAlignment::Center,
                            MenuAlignment::Center => MenuAlignment::Right,
                            MenuAlignment::Right => MenuAlignment::Left,
                        };

                        menu = menu.align_to(&display_area, current_alignment, vertical::Center);
                    }

                    _ => {}
                },

                _ => {}
            }
        }
    }

    Ok(())
}
