//! Active screen types, typed menu commands, and screen construction.

use embedded_graphics::{mono_font::ascii::FONT_6X10, pixelcolor::BinaryColor, text::Alignment};
use heapless::String;

use crate::{
    settings::{NAME_CAPACITY, Settings},
    ui::{Menu, MenuStyle},
};

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Screen {
    MainMenu,
    Settings,
}

#[derive(Clone, Copy)]
pub(super) enum MainCommand {
    NewGame,
    JoinGame,
    OpenSettings,
}

#[derive(Clone)]
pub(super) enum SettingsCommand {
    SetUserName(String<NAME_CAPACITY>),
    Back,
}

pub(super) type MainMenu = Menu<BinaryColor, 24, 3, (), MainCommand>;
pub(super) type SettingsMenu = Menu<BinaryColor, NAME_CAPACITY, 2, Settings, SettingsCommand>;

pub(super) enum ScreenState {
    MainMenu(MainMenu),
    Settings(SettingsMenu),
}

pub(super) fn main_menu() -> MainMenu {
    let mut menu: MainMenu = Menu::with_style(style());
    menu.add_action("New game", MainCommand::NewGame)
        .expect("New game fits in the main menu");
    menu.add_action("Join game", MainCommand::JoinGame)
        .expect("Join game fits in the main menu");
    menu.add_action("Settings", MainCommand::OpenSettings)
        .expect("Settings fits in the main menu");

    menu
}

pub(super) fn settings_menu() -> SettingsMenu {
    let mut menu: SettingsMenu = Menu::with_style(style());
    menu.add_text_field(
        "Username",
        |settings| &settings.user_name,
        SettingsCommand::SetUserName,
    )
    .expect("Username fits in the settings menu");
    menu.add_action("Back", SettingsCommand::Back)
        .expect("Back fits in the settings menu");

    menu
}

fn style() -> MenuStyle<BinaryColor> {
    MenuStyle {
        font: &FONT_6X10,
        text_alignment: Alignment::Center,
        ..Default::default()
    }
}
