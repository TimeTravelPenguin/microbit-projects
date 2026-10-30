use super::{NavigationKey, button_action, cardkb_action, firmware_action, navigation_action};
use crate::{
    app::{Action, App, AppEffect, AppUpdate, Screen},
    settings::Settings,
};
use cardkb::Key;

fn press_key(app: &mut App, key: Key) -> AppUpdate {
    let action = cardkb_action(key, app.is_editing()).expect("The test key is a control");

    app.handle(action).unwrap()
}

fn editing_app() -> App {
    let settings = Settings {
        user_name: "abc".try_into().unwrap(),
    };

    let mut app = App::new(settings).unwrap();
    let _ = press_key(&mut app, Key::ArrowUp);
    let _ = press_key(&mut app, Key::Enter);
    let _ = press_key(&mut app, Key::Enter);
    assert_eq!(app.screen(), Screen::Settings);
    assert!(app.is_editing());

    app
}

#[test]
fn navigation_uses_context_and_keeps_tab_out_of_the_editor() {
    for (key, browsing, editing) in [
        (
            NavigationKey::Up,
            Some(Action::SelectPrevious),
            Some(Action::Increment),
        ),
        (
            NavigationKey::Down,
            Some(Action::SelectNext),
            Some(Action::Decrement),
        ),
        (NavigationKey::Left, None, Some(Action::PreviousCharacter)),
        (NavigationKey::Right, None, Some(Action::NextCharacter)),
        (NavigationKey::Tab, Some(Action::SelectNext), None),
        (NavigationKey::BackTab, Some(Action::SelectPrevious), None),
        (
            NavigationKey::Select,
            Some(Action::SelectItem),
            Some(Action::SelectItem),
        ),
        (NavigationKey::Back, Some(Action::Back), Some(Action::Back)),
        (NavigationKey::Delete, None, Some(Action::DeleteCharacter)),
    ] {
        assert_eq!(navigation_action(key, false), browsing, "{key:?}");
        assert_eq!(navigation_action(key, true), editing, "{key:?}");
    }
}

#[test]
fn cardkb_controls_share_navigation_mapping_and_ignore_character_keys() {
    for (key, navigation) in [
        (Key::ArrowUp, NavigationKey::Up),
        (Key::ArrowDown, NavigationKey::Down),
        (Key::ArrowLeft, NavigationKey::Left),
        (Key::ArrowRight, NavigationKey::Right),
        (Key::Tab, NavigationKey::Tab),
        (Key::Enter, NavigationKey::Select),
        (Key::Escape, NavigationKey::Back),
        (Key::Delete, NavigationKey::Delete),
        (Key::Backspace, NavigationKey::Delete),
    ] {
        for editing in [false, true] {
            assert_eq!(
                cardkb_action(key, editing),
                navigation_action(navigation, editing)
            );
        }
    }

    for key in [Key::LowerA, Key::UpperZ, Key::Space, Key::FnEnter] {
        assert_eq!(cardkb_action(key, false), None);
        assert_eq!(cardkb_action(key, true), None);
    }
}

#[test]
fn buttons_have_distinct_navigation_editing_and_selection_actions() {
    for (button_a, button_b, browsing, editing) in [
        (false, false, None, None),
        (
            true,
            false,
            Some(Action::SelectNext),
            Some(Action::Increment),
        ),
        (
            false,
            true,
            Some(Action::SelectPrevious),
            Some(Action::NextCharacter),
        ),
        (
            true,
            true,
            Some(Action::SelectItem),
            Some(Action::SelectItem),
        ),
    ] {
        assert_eq!(button_action(button_a, button_b, false), browsing);
        assert_eq!(button_action(button_a, button_b, true), editing);
    }
}

#[test]
fn recognized_keyboard_controls_take_priority_over_buttons_in_the_same_batch() {
    assert_eq!(
        firmware_action(Some(Key::Enter), true, false, false),
        Some(Action::SelectItem)
    );
    assert_eq!(
        firmware_action(Some(Key::Escape), true, true, true),
        Some(Action::Back)
    );
    assert_eq!(firmware_action(Some(Key::Tab), true, false, true), None);
    assert_eq!(
        firmware_action(Some(Key::LowerA), true, false, true),
        Some(Action::Increment)
    );
    assert_eq!(
        firmware_action(None, false, true, false),
        Some(Action::SelectPrevious)
    );
    assert_eq!(firmware_action(None, false, false, false), None);
    assert_eq!(firmware_action(None, false, false, true), None);
    assert_eq!(
        firmware_action(Some(Key::LowerA), false, false, false),
        None
    );
    assert_eq!(firmware_action(Some(Key::LowerA), false, false, true), None);
}

#[test]
fn keyboard_editing_returns_the_accepted_settings_snapshot() {
    let mut app = editing_app();

    for key in [
        Key::ArrowUp,
        Key::ArrowRight,
        Key::ArrowDown,
        Key::ArrowLeft,
        Key::Delete,
    ] {
        assert_eq!(
            press_key(&mut app, key),
            AppUpdate {
                redraw: true,
                effect: None
            }
        );
    }

    assert_eq!(app.active_editor().unwrap().value(), "ac");
    assert_eq!(app.settings().user_name, "abc");
    let accepted = press_key(&mut app, Key::Enter);
    let expected = Settings {
        user_name: "ac".try_into().unwrap(),
    };

    assert_eq!(
        accepted,
        AppUpdate {
            redraw: true,
            effect: Some(AppEffect::SaveSettings(expected.clone()))
        }
    );

    assert_eq!(app.settings(), &expected);
    assert!(!app.is_editing());
}

#[test]
fn keyboard_acceptance_without_changes_and_cancellation_do_not_request_a_save() {
    let mut app = editing_app();
    assert_eq!(
        press_key(&mut app, Key::Enter),
        AppUpdate {
            redraw: true,
            effect: None
        }
    );
    assert!(!app.is_editing());

    let _ = press_key(&mut app, Key::Enter);
    let _ = press_key(&mut app, Key::ArrowUp);
    assert_eq!(app.active_editor().unwrap().value(), "bbc");
    assert_eq!(
        press_key(&mut app, Key::Escape),
        AppUpdate {
            redraw: true,
            effect: None
        }
    );
    assert!(!app.is_editing());
    assert_eq!(app.settings().user_name, "abc");

    let _ = press_key(&mut app, Key::Enter);
    assert_eq!(app.active_editor().unwrap().value(), "abc");
    assert_eq!(cardkb_action(Key::LowerA, app.is_editing()), None);
    assert_eq!(cardkb_action(Key::Tab, app.is_editing()), None);
    assert_eq!(app.active_editor().unwrap().value(), "abc");
}
