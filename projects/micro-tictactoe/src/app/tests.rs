use core::convert::Infallible;

use embedded_graphics::{
    Drawable, Pixel,
    draw_target::DrawTarget,
    geometry::{OriginDimensions, Size},
    pixelcolor::BinaryColor,
};

use super::{Action, App, AppEffect, AppError, AppUpdate, Screen};
use crate::{settings::Settings, ui::TextInputError};

fn apply(app: &mut App, action: Action) -> AppUpdate {
    app.handle(action).unwrap()
}

fn settings_app() -> App {
    let settings = Settings {
        user_name: "abc".try_into().unwrap(),
    };

    let mut app = App::new(settings).unwrap();
    assert!(apply(&mut app, Action::SelectPrevious).redraw);
    assert_eq!(
        apply(&mut app, Action::SelectItem),
        AppUpdate {
            redraw: true,
            effect: None,
        }
    );
    assert_eq!(app.screen(), Screen::Settings);

    app
}

#[test]
fn main_menu_routes_typed_actions_and_opens_settings() {
    let mut app = App::new(Settings::default()).unwrap();
    assert_eq!(app.screen(), Screen::MainMenu);
    assert_eq!(
        apply(&mut app, Action::SelectItem).effect,
        Some(AppEffect::NewGame)
    );

    assert!(apply(&mut app, Action::SelectNext).redraw);
    assert_eq!(
        apply(&mut app, Action::SelectItem).effect,
        Some(AppEffect::JoinGame)
    );

    assert!(apply(&mut app, Action::SelectNext).redraw);
    let update = apply(&mut app, Action::SelectItem);
    assert!(update.redraw);
    assert_eq!(update.effect, None);
    assert_eq!(app.screen(), Screen::Settings);
    assert_eq!(app.settings().user_name, "Player");
    assert!(!app.is_editing());
    assert!(app.active_editor().is_none());
}

#[test]
fn accepting_an_edit_updates_settings_and_returns_one_save_snapshot() {
    let mut app = settings_app();
    assert!(apply(&mut app, Action::SelectItem).redraw);
    assert!(app.is_editing());

    for action in [
        Action::Increment,
        Action::NextCharacter,
        Action::Increment,
        Action::PreviousCharacter,
        Action::Decrement,
    ] {
        let update = apply(&mut app, action);
        assert!(update.redraw);
        assert_eq!(update.effect, None);
    }

    assert_eq!(app.active_editor().unwrap().value(), "acc");
    assert_eq!(app.settings().user_name, "abc");

    let update = apply(&mut app, Action::FinishEdit);
    assert!(update.redraw);
    assert_eq!(
        update.effect,
        Some(AppEffect::SaveSettings(Settings {
            user_name: "acc".try_into().unwrap(),
        }))
    );
    assert_eq!(app.settings().user_name, "acc");
    assert!(!app.is_editing());
    assert_eq!(apply(&mut app, Action::FinishEdit), AppUpdate::default());
}

#[test]
fn selecting_again_accepts_a_changed_username() {
    let mut app = settings_app();
    assert!(apply(&mut app, Action::SelectItem).redraw);
    assert!(apply(&mut app, Action::Increment).redraw);

    let update = apply(&mut app, Action::SelectItem);
    assert!(update.redraw);
    assert_eq!(
        update.effect,
        Some(AppEffect::SaveSettings(Settings {
            user_name: "bbc".try_into().unwrap(),
        }))
    );
    assert_eq!(app.settings().user_name, "bbc");
    assert!(!app.is_editing());
}

#[test]
fn accepting_an_unchanged_edit_requests_redraw_without_saving() {
    let mut app = settings_app();
    assert!(apply(&mut app, Action::SelectItem).redraw);
    assert!(apply(&mut app, Action::Increment).redraw);
    assert!(apply(&mut app, Action::Decrement).redraw);

    assert_eq!(
        apply(&mut app, Action::FinishEdit),
        AppUpdate {
            redraw: true,
            effect: None,
        }
    );
    assert!(!app.is_editing());
    assert_eq!(app.settings().user_name, "abc");
}

#[test]
fn cancelling_discards_the_draft_without_updating_settings_or_saving() {
    let mut app = settings_app();
    assert!(apply(&mut app, Action::SelectItem).redraw);
    assert!(apply(&mut app, Action::Increment).redraw);
    assert_ne!(app.active_editor().unwrap().value(), "abc");

    assert_eq!(
        apply(&mut app, Action::Back),
        AppUpdate {
            redraw: true,
            effect: None,
        }
    );
    assert_eq!(app.screen(), Screen::Settings);
    assert!(app.active_editor().is_none());
    assert_eq!(app.settings().user_name, "abc");
    assert_eq!(apply(&mut app, Action::FinishEdit), AppUpdate::default());

    assert!(apply(&mut app, Action::SelectItem).redraw);
    assert_eq!(app.active_editor().unwrap().value(), "abc");
}

#[test]
fn menu_navigation_stays_on_the_active_editor_until_it_finishes() {
    let mut app = settings_app();
    assert!(apply(&mut app, Action::SelectItem).redraw);

    assert_eq!(apply(&mut app, Action::SelectNext), AppUpdate::default());
    assert!(app.is_editing());
    assert_eq!(
        apply(&mut app, Action::SelectPrevious),
        AppUpdate::default()
    );
    assert!(app.is_editing());
    let update = apply(&mut app, Action::FinishEdit);
    assert!(update.redraw);
    assert_eq!(update.effect, None);

    assert!(apply(&mut app, Action::SelectNext).redraw);
    assert!(apply(&mut app, Action::SelectItem).redraw);
    assert_eq!(app.screen(), Screen::MainMenu);
}

#[test]
fn character_controls_do_nothing_outside_the_editor() {
    let mut app = App::new(Settings::default()).unwrap();
    let editing_actions = [
        Action::NextCharacter,
        Action::PreviousCharacter,
        Action::Increment,
        Action::Decrement,
        Action::DeleteCharacter,
        Action::FinishEdit,
    ];

    for action in editing_actions {
        assert_eq!(apply(&mut app, action), AppUpdate::default());
    }

    assert_eq!(apply(&mut app, Action::Back), AppUpdate::default());
    assert!(apply(&mut app, Action::SelectPrevious).redraw);
    assert!(apply(&mut app, Action::SelectItem).redraw);

    for action in editing_actions {
        assert_eq!(apply(&mut app, action), AppUpdate::default());
    }

    assert_eq!(app.settings().user_name, "Player");
    assert!(apply(&mut app, Action::Back).redraw);
    assert_eq!(app.screen(), Screen::MainMenu);
}

#[test]
fn each_screen_restores_its_selection_when_its_menu_is_recreated() {
    let mut app = settings_app();
    assert!(apply(&mut app, Action::SelectNext).redraw);
    assert!(apply(&mut app, Action::SelectItem).redraw);
    assert_eq!(app.screen(), Screen::MainMenu);

    assert!(apply(&mut app, Action::SelectItem).redraw);
    assert_eq!(app.screen(), Screen::Settings);
    assert!(apply(&mut app, Action::SelectItem).redraw);
    assert_eq!(app.screen(), Screen::MainMenu);

    assert!(apply(&mut app, Action::SelectItem).redraw);
    assert!(apply(&mut app, Action::SelectPrevious).redraw);
    assert!(apply(&mut app, Action::SelectItem).redraw);
    assert!(app.is_editing());
}

#[test]
fn save_effect_owns_the_accepted_snapshot_even_after_later_edits() {
    let mut app = settings_app();
    assert!(apply(&mut app, Action::SelectItem).redraw);
    assert!(apply(&mut app, Action::Increment).redraw);
    let first_save = apply(&mut app, Action::FinishEdit).effect;

    assert!(apply(&mut app, Action::SelectItem).redraw);
    assert!(apply(&mut app, Action::Increment).redraw);
    let second_save = apply(&mut app, Action::FinishEdit).effect;

    assert_eq!(
        first_save,
        Some(AppEffect::SaveSettings(Settings {
            user_name: "bbc".try_into().unwrap(),
        }))
    );
    assert_eq!(
        second_save,
        Some(AppEffect::SaveSettings(Settings {
            user_name: "cbc".try_into().unwrap(),
        }))
    );
    assert_eq!(app.settings().user_name, "cbc");
}

#[test]
fn invalid_initial_text_returns_an_app_error_before_opening_settings() {
    let settings = Settings {
        user_name: "é".try_into().unwrap(),
    };

    assert!(matches!(
        App::new(settings),
        Err(AppError::TextInput(TextInputError::UnsupportedCharacter))
    ));
}

struct ScreenDisplay {
    pixels: [BinaryColor; 128 * 64],
}

impl OriginDimensions for ScreenDisplay {
    fn size(&self) -> Size {
        Size::new(128, 64)
    }
}

impl DrawTarget for ScreenDisplay {
    type Color = BinaryColor;
    type Error = Infallible;

    fn draw_iter<I>(&mut self, pixels: I) -> Result<(), Self::Error>
    where
        I: IntoIterator<Item = Pixel<Self::Color>>,
    {
        for Pixel(point, color) in pixels {
            assert!((0..128).contains(&point.x) && (0..64).contains(&point.y));
            self.pixels[point.y as usize * 128 + point.x as usize] = color;
        }

        Ok(())
    }
}

#[test]
fn full_screens_fit_the_oled_and_repaint_after_cancelling_and_returning() {
    let mut display = ScreenDisplay {
        pixels: [BinaryColor::Off; 128 * 64],
    };

    let mut app = App::new(Settings::default()).unwrap();
    assert!(apply(&mut app, Action::SelectPrevious).redraw);
    app.draw(&mut display).unwrap();
    let main_frame = display.pixels;

    assert!(apply(&mut app, Action::SelectItem).redraw);
    app.draw(&mut display).unwrap();
    let settings_frame = display.pixels;
    assert_ne!(main_frame, settings_frame);

    for action in [
        Action::SelectItem,
        Action::Increment,
        Action::NextCharacter,
        Action::DeleteCharacter,
    ] {
        assert!(apply(&mut app, action).redraw);
    }

    app.draw(&mut display).unwrap();
    assert_ne!(display.pixels, settings_frame);

    assert!(apply(&mut app, Action::Back).redraw);
    app.draw(&mut display).unwrap();
    assert_eq!(display.pixels, settings_frame);

    assert!(apply(&mut app, Action::SelectNext).redraw);
    assert!(apply(&mut app, Action::SelectItem).redraw);
    app.draw(&mut display).unwrap();
    assert_eq!(display.pixels, main_frame);
}
