//! Screen flow shared by firmware and simulator. Controls produce semantic
//! actions; the caller executes effects such as saving accepted settings.

mod action;
mod screen;
mod update;

pub use action::Action;
pub use screen::Screen;
pub use update::{AppEffect, AppUpdate};

use embedded_graphics::{Drawable, draw_target::DrawTarget, pixelcolor::BinaryColor};
use embedded_layout::align::{Align, HorizontalAlignment, horizontal, vertical};
use thiserror::Error;

use crate::{
    settings::{NAME_CAPACITY, Settings},
    ui::{MenuError, TextEditor, TextInputError},
};
use screen::{MainCommand, ScreenState, SettingsCommand};

#[derive(Debug, Error)]
pub enum AppError {
    #[error("Text input error: {0}")]
    TextInput(#[from] TextInputError),
    #[error("Menu error: {0}")]
    Menu(#[from] MenuError),
}

struct NavigationMemory {
    main_menu: Option<usize>,
    settings: Option<usize>,
}

pub struct App {
    settings: Settings,
    screen: ScreenState,
    navigation: NavigationMemory,
}

impl App {
    pub fn new(settings: Settings) -> Result<Self, AppError> {
        screen::settings_menu().validate_model(&settings)?;

        Ok(Self {
            settings,
            screen: ScreenState::MainMenu(screen::main_menu()),
            navigation: NavigationMemory {
                main_menu: Some(0),
                settings: Some(0),
            },
        })
    }

    pub fn screen(&self) -> Screen {
        match &self.screen {
            ScreenState::MainMenu(_) => Screen::MainMenu,
            ScreenState::Settings(_) => Screen::Settings,
        }
    }

    pub fn settings(&self) -> &Settings {
        &self.settings
    }

    pub fn active_editor(&self) -> Option<&TextEditor<NAME_CAPACITY>> {
        match &self.screen {
            ScreenState::MainMenu(_) => None,
            ScreenState::Settings(menu) => menu.editor(),
        }
    }

    pub fn is_editing(&self) -> bool {
        self.active_editor().is_some()
    }

    /// Updates the active screen and returns work for the firmware or simulator.
    pub fn handle(&mut self, action: Action) -> Result<AppUpdate, AppError> {
        if action == Action::Back
            && matches!(&self.screen, ScreenState::Settings(menu) if !menu.is_editing())
        {
            self.open_main_menu();

            return Ok(AppUpdate {
                redraw: true,
                effect: None,
            });
        }

        match &mut self.screen {
            ScreenState::MainMenu(menu) => {
                let update = menu.handle_action(action.into(), &())?;
                let mut redraw = update.redraw;
                let effect = match update.command {
                    Some(MainCommand::NewGame) => Some(AppEffect::NewGame),
                    Some(MainCommand::JoinGame) => Some(AppEffect::JoinGame),
                    Some(MainCommand::OpenSettings) => {
                        self.open_settings();
                        redraw = true;

                        None
                    }

                    None => None,
                };

                Ok(AppUpdate { redraw, effect })
            }

            ScreenState::Settings(menu) => {
                let update = menu.handle_action(action.into(), &self.settings)?;
                let mut redraw = update.redraw;
                let effect = match update.command {
                    Some(SettingsCommand::SetUserName(user_name))
                        if user_name != self.settings.user_name =>
                    {
                        // trim can only make the string shorter, so this is safe to unwrap
                        self.settings.user_name = user_name.trim().try_into().unwrap();
                        Some(AppEffect::SaveSettings(self.settings.clone()))
                    }

                    Some(SettingsCommand::Back) => {
                        self.open_main_menu();
                        redraw = true;

                        None
                    }

                    Some(SettingsCommand::SetUserName(_)) | None => None,
                };

                Ok(AppUpdate { redraw, effect })
            }
        }
    }

    pub fn select_next(&mut self) -> Result<AppUpdate, AppError> {
        self.handle(Action::SelectNext)
    }

    pub fn select_previous(&mut self) -> Result<AppUpdate, AppError> {
        self.handle(Action::SelectPrevious)
    }

    pub fn select_item(&mut self) -> Result<AppUpdate, AppError> {
        self.handle(Action::SelectItem)
    }

    pub fn finish_edit(&mut self) -> Result<AppUpdate, AppError> {
        self.handle(Action::FinishEdit)
    }

    pub fn back(&mut self) -> Result<AppUpdate, AppError> {
        self.handle(Action::Back)
    }

    pub fn next_character(&mut self) -> Result<AppUpdate, AppError> {
        self.handle(Action::NextCharacter)
    }

    pub fn previous_character(&mut self) -> Result<AppUpdate, AppError> {
        self.handle(Action::PreviousCharacter)
    }

    pub fn increment(&mut self) -> Result<AppUpdate, AppError> {
        self.handle(Action::Increment)
    }

    pub fn decrement(&mut self) -> Result<AppUpdate, AppError> {
        self.handle(Action::Decrement)
    }

    pub fn delete_character(&mut self) -> Result<AppUpdate, AppError> {
        self.handle(Action::DeleteCharacter)
    }

    /// Positions the active menu; editing always centers the draft on screen.
    pub fn draw_aligned<D, A>(&self, target: &mut D, alignment: A) -> Result<(), D::Error>
    where
        D: DrawTarget<Color = BinaryColor>,
        A: HorizontalAlignment,
    {
        target.clear(BinaryColor::Off)?;
        let area = target.bounding_box();

        match &self.screen {
            ScreenState::MainMenu(menu) => menu
                .view(&())
                .align_to(&area, alignment, vertical::Center)
                .draw(target),
            ScreenState::Settings(menu) => menu
                .view(&self.settings)
                .align_to(&area, alignment, vertical::Center)
                .draw(target),
        }
    }

    fn open_settings(&mut self) {
        if let ScreenState::MainMenu(menu) = &self.screen {
            self.navigation.main_menu = menu.selected_index();
        }

        let mut menu = screen::settings_menu();
        menu.set_selected_index(self.navigation.settings);
        self.screen = ScreenState::Settings(menu);
    }

    fn open_main_menu(&mut self) {
        if let ScreenState::Settings(menu) = &self.screen {
            self.navigation.settings = menu.selected_index();
        }

        let mut menu = screen::main_menu();
        menu.set_selected_index(self.navigation.main_menu);
        self.screen = ScreenState::MainMenu(menu);
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
