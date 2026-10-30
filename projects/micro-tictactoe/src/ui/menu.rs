//! A bounded menu whose active editor produces a typed command.
//!
//! Text rows read committed values from the supplied model. Only the active
//! editing session owns a draft; accepting it returns the row's command, while
//! cancelling discards it. Drawing a view always reads the current model.
//!
//! ```
//! use micro_tictactoe::ui::{Menu, MenuAction};
//! use embedded_graphics::pixelcolor::BinaryColor;
//!
//! let mut menu = Menu::<BinaryColor, 24, 4>::new_with_items(&["New game", "Join game"])?;
//! assert!(menu.handle_action(MenuAction::NextItem, &())?.redraw);
//! assert_eq!(menu.handle_action(MenuAction::SelectItem, &())?.command, Some(1));
//! # Ok::<(), Box<dyn std::error::Error>>(())
//! ```
//!
//! Bind text rows to a model reader and a command constructor:
//!
//! ```
//! use embedded_graphics::pixelcolor::BinaryColor;
//! use heapless::String;
//! use micro_tictactoe::ui::{Menu, MenuAction};
//!
//! struct Settings { name: String<8> }
//! #[derive(Clone, Debug, PartialEq, Eq)]
//! enum Command { SetName(String<8>) }
//!
//! let settings = Settings { name: "abc".try_into().unwrap() };
//! let mut menu = Menu::<BinaryColor, 8, 1, Settings, Command>::new();
//! menu.add_text_field("Name", |settings| &settings.name, Command::SetName)?;
//! assert!(menu.handle_action(MenuAction::SelectItem, &settings)?.redraw);
//! assert!(menu.handle_action(MenuAction::Increment, &settings)?.redraw);
//! let update = menu.handle_action(MenuAction::FinishEdit, &settings)?;
//! assert_eq!(update.command, Some(Command::SetName("bbc".try_into().unwrap())));
//! assert_eq!(settings.name, "abc"); // The caller applies the command.
//! # Ok::<(), Box<dyn std::error::Error>>(())
//! ```

use embedded_graphics::{geometry::Point, pixelcolor::PixelColor};
use heapless::{String, Vec};
use thiserror::Error;

use super::{
    text_editor::TextEditor,
    text_input::{TextInput, TextInputError},
};

mod style;
mod view;

pub use style::MenuStyle;
pub use view::MenuView;

#[derive(Debug, Error, PartialEq, Eq)]
pub enum MenuError {
    #[error("Menu item capacity exceeded")]
    MenuFull,
    #[error("Menu item length exceeded")]
    ItemTooLong,
    #[error("Invalid text field: {0}")]
    TextInput(#[from] TextInputError),
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum MenuAction {
    NextItem,
    PreviousItem,
    SelectItem,
    FinishEdit,
    Back,
    NextCharacter,
    PreviousCharacter,
    Increment,
    Decrement,
    DeleteCharacter,
}

/// A visible transition and, independently, a command to apply to the model.
#[must_use]
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct MenuUpdate<Command> {
    pub redraw: bool,
    pub command: Option<Command>,
}

impl<Command> Default for MenuUpdate<Command> {
    fn default() -> Self {
        Self {
            redraw: false,
            command: None,
        }
    }
}

/// Accepting an unchanged draft still closes the editor and needs a redraw.
#[must_use]
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum EditOutcome<Command> {
    Inactive,
    Unchanged,
    Accepted(Command),
}

/// Text fields describe how to read and accept a value, without storing it.
#[derive(Clone, Debug)]
pub enum MenuItem<Model, Command, const N: usize> {
    Action {
        label: String<N>,
        command: Command,
    },
    TextField {
        label: String<N>,
        read: fn(&Model) -> &String<N>,
        commit: Option<fn(String<N>) -> Command>,
    },
}

impl<Model, Command, const N: usize> MenuItem<Model, Command, N> {
    pub fn label(&self) -> &str {
        match self {
            Self::Action { label, .. } | Self::TextField { label, .. } => label,
        }
    }
}

#[derive(Clone, Debug)]
enum MenuState<Command, const N: usize> {
    Browsing {
        selected: Option<usize>,
    },
    Editing {
        selected: usize,
        editor: TextEditor<N>,
        commit: fn(String<N>) -> Command,
    },
}

/// Owns row definitions and exactly one current interaction state.
/// Use `view(model)` to draw rows from their committed values.
#[derive(Clone, Debug)]
pub struct Menu<C: PixelColor, const N: usize, const MAX_ITEMS: usize, Model = (), Command = usize>
{
    items: Vec<MenuItem<Model, Command, N>, MAX_ITEMS>,
    state: MenuState<Command, N>,
    position: Point,
    style: MenuStyle<C>,
}

impl<C: PixelColor, const N: usize, const MAX_ITEMS: usize, Model, Command> Default
    for Menu<C, N, MAX_ITEMS, Model, Command>
where
    MenuStyle<C>: Default,
{
    fn default() -> Self {
        Self::new()
    }
}

impl<C: PixelColor, const N: usize, const MAX_ITEMS: usize, Model, Command>
    Menu<C, N, MAX_ITEMS, Model, Command>
where
    MenuStyle<C>: Default,
{
    pub fn new() -> Self {
        Self::with_style(MenuStyle::default())
    }
}

// Simple label-only menus retain their indexed convenience API.
impl<C: PixelColor, const N: usize, const MAX_ITEMS: usize> Menu<C, N, MAX_ITEMS>
where
    MenuStyle<C>: Default,
{
    pub fn new_with_items(items: &[&str]) -> Result<Self, MenuError> {
        let mut menu = Self::new();
        menu.set_items(items)?;

        Ok(menu)
    }
}

impl<C: PixelColor, const N: usize, const MAX_ITEMS: usize> Menu<C, N, MAX_ITEMS> {
    pub fn add_item(&mut self, label: &str) -> Result<(), MenuError> {
        self.add_action(label, self.items.len())
    }

    pub fn set_items(&mut self, items: &[&str]) -> Result<(), MenuError> {
        self.items.clear();
        self.state = MenuState::Browsing { selected: None };

        for item in items {
            self.add_item(item)?;
        }

        Ok(())
    }

    pub fn select_next(&mut self) {
        let _ = self.handle_action(MenuAction::NextItem, &());
    }

    pub fn select_previous(&mut self) {
        let _ = self.handle_action(MenuAction::PreviousItem, &());
    }

    pub fn select_item(&mut self) -> Option<usize> {
        self.handle_action(MenuAction::SelectItem, &())
            .expect("Label-only menus have no text values to validate")
            .command
    }
}

impl<C: PixelColor, const N: usize, const MAX_ITEMS: usize, Model, Command>
    Menu<C, N, MAX_ITEMS, Model, Command>
{
    pub fn with_style(style: MenuStyle<C>) -> Self {
        Self {
            items: Vec::new(),
            state: MenuState::Browsing { selected: None },
            position: Point::zero(),
            style,
        }
    }

    pub fn set_style(mut self, style: MenuStyle<C>) -> Self {
        self.style = style;

        self
    }

    pub fn add_action(&mut self, label: &str, command: Command) -> Result<(), MenuError> {
        self.ensure_capacity()?;
        let label = label.try_into().map_err(|_| MenuError::ItemTooLong)?;

        self.push_item(MenuItem::Action { label, command })
    }

    pub fn add_text_field(
        &mut self,
        label: &str,
        read: fn(&Model) -> &String<N>,
        commit: fn(String<N>) -> Command,
    ) -> Result<(), MenuError> {
        self.add_field(label, read, Some(commit))
    }

    pub fn add_read_only_field(
        &mut self,
        label: &str,
        read: fn(&Model) -> &String<N>,
    ) -> Result<(), MenuError> {
        self.add_field(label, read, None)
    }

    fn add_field(
        &mut self,
        label: &str,
        read: fn(&Model) -> &String<N>,
        commit: Option<fn(String<N>) -> Command>,
    ) -> Result<(), MenuError> {
        self.ensure_capacity()?;
        // Use the same printable-ASCII and capacity rules as standalone inputs.
        let input = TextInput::<C, N>::with_style(label, "", false, self.style)?;
        let label = input.label().try_into().expect("The label was validated");

        self.push_item(MenuItem::TextField {
            label,
            read,
            commit,
        })
    }

    fn ensure_capacity(&self) -> Result<(), MenuError> {
        if self.items.is_full() {
            return Err(MenuError::MenuFull);
        }

        Ok(())
    }

    fn push_item(&mut self, item: MenuItem<Model, Command, N>) -> Result<(), MenuError> {
        self.items.push(item).map_err(|_| MenuError::MenuFull)?;

        if let MenuState::Browsing { selected } = &mut self.state {
            *selected = selected.or(Some(0));
        }

        Ok(())
    }

    /// Validates model values at construction without keeping cached copies.
    pub fn validate_model(&self, model: &Model) -> Result<(), TextInputError> {
        for item in &self.items {
            if let MenuItem::TextField { read, .. } = item {
                TextEditor::<N>::new(read(model))?;
            }
        }

        Ok(())
    }

    pub fn selected_index(&self) -> Option<usize> {
        match &self.state {
            MenuState::Browsing { selected } => *selected,
            MenuState::Editing { selected, .. } => Some(*selected),
        }
    }

    /// Restores navigation focus. Active edits cannot be moved to another row.
    pub fn set_selected_index(&mut self, selected: Option<usize>) {
        if let MenuState::Browsing { selected: current } = &mut self.state {
            *current = if self.items.is_empty() {
                None
            } else {
                Some(selected.unwrap_or(0).min(self.items.len() - 1))
            };
        }
    }

    pub fn selected_item(&self) -> Option<&str> {
        self.items.get(self.selected_index()?).map(MenuItem::label)
    }

    pub fn editor(&self) -> Option<&TextEditor<N>> {
        match &self.state {
            MenuState::Editing { editor, .. } => Some(editor),
            MenuState::Browsing { .. } => None,
        }
    }

    pub fn is_editing(&self) -> bool {
        matches!(self.state, MenuState::Editing { .. })
    }

    /// Prepares the command before closing the editor. There is no unrelated
    /// field inspection and callers cannot bypass the row's commit binding.
    pub fn finish_edit(&mut self) -> EditOutcome<Command> {
        let MenuState::Editing {
            selected,
            editor,
            commit,
        } = &self.state
        else {
            return EditOutcome::Inactive;
        };

        let outcome = if editor.changed() {
            EditOutcome::Accepted(commit(editor.draft().clone()))
        } else {
            EditOutcome::Unchanged
        };

        self.state = MenuState::Browsing {
            selected: Some(*selected),
        };

        outcome
    }

    pub fn view<'a>(&'a self, model: &'a Model) -> MenuView<'a, C, N, MAX_ITEMS, Model, Command> {
        MenuView::new(self, model)
    }
}

impl<C: PixelColor, const N: usize, const MAX_ITEMS: usize, Model, Command: Clone>
    Menu<C, N, MAX_ITEMS, Model, Command>
{
    pub fn handle_action(
        &mut self,
        action: MenuAction,
        model: &Model,
    ) -> Result<MenuUpdate<Command>, TextInputError> {
        match &mut self.state {
            MenuState::Editing {
                selected, editor, ..
            } => {
                let redraw = match action {
                    MenuAction::NextItem | MenuAction::PreviousItem => false,
                    MenuAction::NextCharacter => editor.next_character(),
                    MenuAction::PreviousCharacter => editor.previous_character(),
                    MenuAction::Increment => editor.increment(),
                    MenuAction::Decrement => editor.decrement(),
                    MenuAction::DeleteCharacter => editor.delete_character(),
                    MenuAction::Back => {
                        self.state = MenuState::Browsing {
                            selected: Some(*selected),
                        };

                        true
                    }

                    MenuAction::SelectItem | MenuAction::FinishEdit => {
                        return Ok(match self.finish_edit() {
                            EditOutcome::Inactive => MenuUpdate::default(),
                            EditOutcome::Unchanged => MenuUpdate {
                                redraw: true,
                                command: None,
                            },
                            EditOutcome::Accepted(command) => MenuUpdate {
                                redraw: true,
                                command: Some(command),
                            },
                        });
                    }
                };

                Ok(MenuUpdate {
                    redraw,
                    command: None,
                })
            }

            MenuState::Browsing { selected } => {
                let Some(selected_index) = *selected else {
                    return Ok(MenuUpdate::default());
                };

                match action {
                    MenuAction::NextItem | MenuAction::PreviousItem => {
                        let next_index = if action == MenuAction::NextItem {
                            (selected_index + 1) % self.items.len()
                        } else {
                            (selected_index + self.items.len() - 1) % self.items.len()
                        };

                        *selected = Some(next_index);

                        Ok(MenuUpdate {
                            redraw: next_index != selected_index,
                            command: None,
                        })
                    }

                    MenuAction::SelectItem => match &self.items[selected_index] {
                        MenuItem::Action { command, .. } => Ok(MenuUpdate {
                            redraw: false,
                            command: Some(command.clone()),
                        }),
                        MenuItem::TextField {
                            read,
                            commit: Some(commit),
                            ..
                        } if N > 0 => {
                            let editor = TextEditor::new(read(model))?;
                            self.state = MenuState::Editing {
                                selected: selected_index,
                                editor,
                                commit: *commit,
                            };

                            Ok(MenuUpdate {
                                redraw: true,
                                command: None,
                            })
                        }

                        MenuItem::TextField { .. } => Ok(MenuUpdate::default()),
                    },
                    MenuAction::FinishEdit
                    | MenuAction::Back
                    | MenuAction::NextCharacter
                    | MenuAction::PreviousCharacter
                    | MenuAction::Increment
                    | MenuAction::Decrement
                    | MenuAction::DeleteCharacter => Ok(MenuUpdate::default()),
                }
            }
        }
    }
}

#[cfg(test)]
mod tests;
