//! Appearance shared by action rows, text fields, and the active editor.

use embedded_graphics::{
    geometry::Size,
    mono_font::{MonoFont, ascii::FONT_5X8},
    pixelcolor::{BinaryColor, PixelColor},
    text::Alignment,
};

/// Appearance shared by all menu rows. Selected action rows span the menu;
/// selected text inputs highlight only their value with the selected colors.
#[derive(Clone, Copy, Debug)]
pub struct MenuStyle<C: PixelColor> {
    pub font: &'static MonoFont<'static>,
    /// Aligns each text line within the padded row, independently of menu placement.
    pub text_alignment: Alignment,
    pub text_color: C,
    pub background_color: C,
    pub selected_text_color: C,
    pub selected_background_color: C,
    /// Padding on each side of a label, in pixels.
    pub padding: Size,
    /// Vertical gap between rows, in pixels.
    pub spacing: u32,
}

impl<C: PixelColor> MenuStyle<C> {
    /// Creates a style whose selected rows invert the normal colors.
    pub const fn new(font: &'static MonoFont<'static>, text_color: C, background_color: C) -> Self {
        Self {
            font,
            text_alignment: Alignment::Left,
            text_color,
            background_color,
            selected_text_color: background_color,
            selected_background_color: text_color,
            padding: Size::new(2, 1),
            spacing: 1,
        }
    }
}

impl Default for MenuStyle<BinaryColor> {
    fn default() -> Self {
        Self::new(&FONT_5X8, BinaryColor::On, BinaryColor::Off)
    }
}
