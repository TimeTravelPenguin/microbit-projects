use cardkb::Key;

use crate::app::Action;

/// Controls shared by the CardKB and desktop simulator.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum NavigationKey {
    Up,
    Down,
    Left,
    Right,
    Tab,
    BackTab,
    Select,
    Back,
    Delete,
}

/// Maps arrows to menu navigation or editor controls according to the active context.
/// While editing, Up/Down change the character, Left/Right move the cursor, and
/// Delete removes the selected character. Select accepts and Back cancels an edit.
/// Tab and BackTab navigate menus only; editing ignores them.
pub fn navigation_action(key: NavigationKey, editing: bool) -> Option<Action> {
    match key {
        NavigationKey::Up => Some(if editing {
            Action::Increment
        } else {
            Action::SelectPrevious
        }),
        NavigationKey::Down => Some(if editing {
            Action::Decrement
        } else {
            Action::SelectNext
        }),
        NavigationKey::Left => editing.then_some(Action::PreviousCharacter),
        NavigationKey::Right => editing.then_some(Action::NextCharacter),
        NavigationKey::Tab => (!editing).then_some(Action::SelectNext),
        NavigationKey::BackTab => (!editing).then_some(Action::SelectPrevious),
        NavigationKey::Select => Some(Action::SelectItem),
        NavigationKey::Back => Some(Action::Back),
        NavigationKey::Delete => editing.then_some(Action::DeleteCharacter),
    }
}

/// Uses CardKB arrows, Tab, Enter, Escape, and either Delete or Backspace.
/// Other keys produce no action; text is changed through the character controls.
pub fn cardkb_action(key: Key, editing: bool) -> Option<Action> {
    cardkb_navigation_key(key).and_then(|key| navigation_action(key, editing))
}

/// Browsing: A selects the next row, B the previous row, and A+B selects the row.
/// Editing: A increments the character, B moves to the next character, and A+B
/// accepts the edit. A+B means both sampled press counts were received together.
pub fn button_action(
    button_a_pressed: bool,
    button_b_pressed: bool,
    editing: bool,
) -> Option<Action> {
    match (button_a_pressed, button_b_pressed) {
        (true, true) => Some(Action::SelectItem),
        (true, false) => Some(if editing {
            Action::Increment
        } else {
            Action::SelectNext
        }),
        (false, true) => Some(if editing {
            Action::NextCharacter
        } else {
            Action::SelectPrevious
        }),
        (false, false) => None,
    }
}

/// Resolves one firmware input batch with recognized keyboard controls first.
/// A recognized control that is ignored in this context, such as Tab during an
/// edit, still takes priority. Other keys allow a pending button action through.
pub fn firmware_action(
    key: Option<Key>,
    button_a_pressed: bool,
    button_b_pressed: bool,
    editing: bool,
) -> Option<Action> {
    match key.and_then(cardkb_navigation_key) {
        Some(key) => navigation_action(key, editing),
        None => button_action(button_a_pressed, button_b_pressed, editing),
    }
}

fn cardkb_navigation_key(key: Key) -> Option<NavigationKey> {
    match key {
        Key::ArrowUp => Some(NavigationKey::Up),
        Key::ArrowDown => Some(NavigationKey::Down),
        Key::ArrowLeft => Some(NavigationKey::Left),
        Key::ArrowRight => Some(NavigationKey::Right),
        Key::Tab => Some(NavigationKey::Tab),
        Key::Enter => Some(NavigationKey::Select),
        Key::Escape => Some(NavigationKey::Back),
        Key::Delete | Key::Backspace => Some(NavigationKey::Delete),
        _ => None,
    }
}

#[cfg(test)]
mod tests;
