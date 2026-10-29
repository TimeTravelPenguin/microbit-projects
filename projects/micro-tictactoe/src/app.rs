//! Screen flow shared by firmware and simulator. Controls call these public
//! methods; widgets do not depend on a keyboard or button layout.

use embedded_graphics::{
    Drawable, draw_target::DrawTarget, mono_font::ascii::FONT_6X10, pixelcolor::BinaryColor,
    text::Alignment,
};
use embedded_layout::align::{Align, HorizontalAlignment, horizontal, vertical};

use crate::{
    settings::{NAME_CAPACITY, Settings},
    ui::{Menu, MenuStyle, TextInput, TextInputError},
};

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Screen {
    MainMenu,
    Settings,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum AppEvent {
    NewGame,
    JoinGame,
    SettingsChanged,
}

pub struct App {
    main_menu: Menu<BinaryColor, 24, 3>,
    settings_menu: Menu<BinaryColor, NAME_CAPACITY, 2>,
    settings: Settings,
    screen: Screen,
}

impl App {
    pub fn new(settings: Settings) -> Result<Self, TextInputError> {
        let style = MenuStyle {
            font: &FONT_6X10,
            text_alignment: Alignment::Center,
            ..Default::default()
        };

        let main_menu = Menu::new_with_items(&["New game", "Join game", "Settings"])
            .expect("Main menu fits its capacities")
            .set_style(style);
        let mut settings_menu = Menu::with_style(style);
        settings_menu
            .add_text_input(TextInput::new("Username", &settings.user_name, true)?)
            .expect("Username fits in the settings menu");
        settings_menu
            .add_item("Back")
            .expect("Back fits in the settings menu");

        Ok(Self {
            main_menu,
            settings_menu,
            settings,
            screen: Screen::MainMenu,
        })
    }

    pub fn screen(&self) -> Screen {
        self.screen
    }

    pub fn settings(&self) -> &Settings {
        &self.settings
    }

    pub fn user_name_input(&self) -> &TextInput<BinaryColor, NAME_CAPACITY> {
        self.settings_menu
            .text_input(0)
            .expect("First settings row is the username input")
    }

    fn user_name_input_mut(&mut self) -> &mut TextInput<BinaryColor, NAME_CAPACITY> {
        self.settings_menu
            .text_input_mut(0)
            .expect("First settings row is the username input")
    }

    pub fn is_editing(&self) -> bool {
        self.screen == Screen::Settings && self.settings_menu.is_editing()
    }

    pub fn select_next(&mut self) {
        match self.screen {
            Screen::MainMenu => self.main_menu.select_next(),
            Screen::Settings => self.settings_menu.select_next(),
        }
    }

    pub fn select_previous(&mut self) {
        match self.screen {
            Screen::MainMenu => self.main_menu.select_previous(),
            Screen::Settings => self.settings_menu.select_previous(),
        }
    }

    /// Activates a menu row, or accepts the current edit. Only accepting a
    /// changed username updates settings and emits `SettingsChanged`.
    pub fn select_item(&mut self) -> Option<AppEvent> {
        if self.is_editing() {
            return self.finish_edit();
        }

        match self.screen {
            Screen::MainMenu => match self.main_menu.select_item()? {
                0 => Some(AppEvent::NewGame),
                1 => Some(AppEvent::JoinGame),
                2 => {
                    self.screen = Screen::Settings;

                    None
                }

                _ => unreachable!(),
            },

            Screen::Settings => {
                if self.settings_menu.select_item() == Some(1) {
                    self.screen = Screen::MainMenu;
                }

                None
            }
        }
    }

    pub fn finish_edit(&mut self) -> Option<AppEvent> {
        if !self.is_editing() {
            return None;
        }

        self.user_name_input_mut().finish_edit();
        let user_name = self.user_name_input().value();

        if user_name == self.settings.user_name.as_str() {
            return None;
        }

        self.settings.user_name = user_name
            .try_into()
            .expect("Input and settings have the same username capacity");

        Some(AppEvent::SettingsChanged)
    }

    /// Cancels an unaccepted edit, or returns from Settings to the main menu.
    pub fn back(&mut self) -> bool {
        if self.is_editing() {
            return self.user_name_input_mut().cancel_edit();
        }

        if self.screen == Screen::Settings {
            self.screen = Screen::MainMenu;

            return true;
        }

        false
    }

    pub fn next_character(&mut self) -> bool {
        self.is_editing() && self.user_name_input_mut().next_character()
    }

    pub fn previous_character(&mut self) -> bool {
        self.is_editing() && self.user_name_input_mut().previous_character()
    }

    pub fn increment(&mut self) -> bool {
        self.is_editing() && self.user_name_input_mut().increment()
    }

    pub fn decrement(&mut self) -> bool {
        self.is_editing() && self.user_name_input_mut().decrement()
    }

    pub fn delete_character(&mut self) -> bool {
        self.is_editing() && self.user_name_input_mut().delete_character()
    }

    /// Positions the active menu; editing always centers the value on screen.
    pub fn draw_aligned<D, A>(&self, target: &mut D, alignment: A) -> Result<(), D::Error>
    where
        D: DrawTarget<Color = BinaryColor>,
        A: HorizontalAlignment,
    {
        target.clear(BinaryColor::Off)?;
        let area = target.bounding_box();

        match self.screen {
            Screen::MainMenu => self
                .main_menu
                .clone()
                .align_to(&area, alignment, vertical::Center)
                .draw(target),
            Screen::Settings => self
                .settings_menu
                .clone()
                .align_to(&area, alignment, vertical::Center)
                .draw(target),
        }
    }
}

impl Drawable for App {
    type Color = BinaryColor;
    type Output = ();

    fn draw<D>(&self, target: &mut D) -> Result<(), D::Error>
    where
        D: DrawTarget<Color = BinaryColor>,
    {
        self.draw_aligned(target, horizontal::Center)
    }
}

#[cfg(test)]
mod tests;
