//! Allocation-free widgets for the OLED display and desktop simulator.

pub mod menu;
pub mod text_input;

pub use menu::{Menu, MenuAction, MenuError, MenuItem, MenuStyle};
pub use text_input::{TextInput, TextInputError};
