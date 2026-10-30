//! Allocation-free widgets for the OLED display and desktop simulator.

pub mod menu;
mod text;
pub mod text_editor;
pub mod text_input;

pub use menu::{
    EditOutcome, Menu, MenuAction, MenuError, MenuItem, MenuStyle, MenuUpdate, MenuView,
};
pub use text_editor::TextEditor;
pub use text_input::{TextInput, TextInputError};
