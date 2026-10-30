//! Allocation-free widgets for the OLED display and desktop simulator.

/// Maximum label length in bytes, independent of editable value capacities.
pub const LABEL_CAPACITY: usize = 12;

pub mod menu;
mod text;
pub mod text_editor;
pub mod text_input;

pub use menu::{
    EditOutcome, Menu, MenuAction, MenuError, MenuItem, MenuStyle, MenuUpdate, MenuView,
};
pub use text_editor::TextEditor;
pub use text_input::{TextInput, TextInputError};
