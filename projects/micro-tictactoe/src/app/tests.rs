use core::convert::Infallible;

use embedded_graphics::{
    Drawable, Pixel,
    draw_target::DrawTarget,
    geometry::{OriginDimensions, Size},
    pixelcolor::BinaryColor,
};

use super::{App, AppEvent, Screen};
use crate::settings::Settings;

fn settings_app() -> App {
    let settings = Settings {
        user_name: "abc".try_into().unwrap(),
    };

    let mut app = App::new(settings).unwrap();
    app.select_previous();
    assert_eq!(app.select_item(), None);
    assert_eq!(app.screen(), Screen::Settings);

    app
}

#[test]
fn main_menu_routes_actions_and_opens_settings() {
    let mut app = App::new(Settings::default()).unwrap();
    assert_eq!(app.screen(), Screen::MainMenu);
    assert_eq!(app.select_item(), Some(AppEvent::NewGame));

    app.select_next();
    assert_eq!(app.select_item(), Some(AppEvent::JoinGame));

    app.select_next();
    assert_eq!(app.select_item(), None);
    assert_eq!(app.screen(), Screen::Settings);
    assert_eq!(app.user_name_input().value(), "Player");
    assert!(!app.is_editing());
}

#[test]
fn accepting_an_edit_updates_settings_and_emits_one_event() {
    let mut app = settings_app();
    assert_eq!(app.select_item(), None);
    assert!(app.is_editing());

    assert!(app.increment());
    assert!(app.next_character());
    assert!(app.increment());
    assert!(app.previous_character());
    assert!(app.decrement());
    assert_eq!(app.user_name_input().value(), "acc");
    assert_eq!(app.settings().user_name, "abc");

    assert_eq!(app.finish_edit(), Some(AppEvent::SettingsChanged));
    assert_eq!(app.settings().user_name, "acc");
    assert!(!app.is_editing());
    assert_eq!(app.finish_edit(), None);
}

#[test]
fn selecting_again_accepts_a_changed_username() {
    let mut app = settings_app();
    app.select_item();
    assert!(app.increment());

    assert_eq!(app.select_item(), Some(AppEvent::SettingsChanged));
    assert_eq!(app.settings().user_name, "bbc");
    assert!(!app.is_editing());
}

#[test]
fn cancelling_restores_the_value_without_updating_settings() {
    let mut app = settings_app();
    app.select_item();
    assert!(app.increment());
    assert_ne!(app.user_name_input().value(), "abc");

    assert!(app.back());
    assert_eq!(app.screen(), Screen::Settings);
    assert!(!app.is_editing());
    assert_eq!(app.user_name_input().value(), "abc");
    assert_eq!(app.settings().user_name, "abc");
    assert_eq!(app.finish_edit(), None);
}

#[test]
fn menu_navigation_stays_on_the_input_until_editing_finishes() {
    let mut app = settings_app();
    app.select_item();

    app.select_next();
    assert!(app.is_editing());
    app.select_previous();
    assert!(app.is_editing());
    assert_eq!(app.finish_edit(), None);

    app.select_next();
    assert_eq!(app.select_item(), None);
    assert_eq!(app.screen(), Screen::MainMenu);
}

#[test]
fn character_controls_do_nothing_outside_the_editor() {
    let mut app = App::new(Settings::default()).unwrap();
    assert!(!app.next_character());
    assert!(!app.previous_character());
    assert!(!app.increment());
    assert!(!app.decrement());
    assert!(!app.delete_character());
    assert_eq!(app.finish_edit(), None);
    assert!(!app.back());

    app.select_previous();
    app.select_item();
    assert!(!app.next_character());
    assert!(!app.previous_character());
    assert!(!app.increment());
    assert!(!app.decrement());
    assert!(!app.delete_character());
    assert_eq!(app.settings().user_name, "Player");
    assert!(app.back());
    assert_eq!(app.screen(), Screen::MainMenu);
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
    app.select_previous();
    app.draw(&mut display).unwrap();
    let main_frame = display.pixels;

    app.select_item();
    app.draw(&mut display).unwrap();
    let settings_frame = display.pixels;
    assert_ne!(main_frame, settings_frame);

    app.select_item();
    app.increment();
    app.next_character();
    app.delete_character();
    app.draw(&mut display).unwrap();
    assert_ne!(display.pixels, settings_frame);

    app.back();
    app.draw(&mut display).unwrap();
    assert_eq!(display.pixels, settings_frame);

    app.select_next();
    app.select_item();
    app.draw(&mut display).unwrap();
    assert_eq!(display.pixels, main_frame);
}
