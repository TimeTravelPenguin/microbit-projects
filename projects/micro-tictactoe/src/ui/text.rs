//! Shared bounded ASCII validation and text geometry for the UI widgets.

use embedded_graphics::{geometry::Size, mono_font::MonoFont, pixelcolor::PixelColor};
use heapless::String;
use thiserror::Error;

use super::MenuStyle;

#[derive(Clone, Copy, Debug, Error, PartialEq, Eq)]
pub enum TextInputError {
    #[error("Text input label exceeds its capacity")]
    LabelTooLong,
    #[error("Text input value exceeds its capacity")]
    ValueTooLong,
    #[error("Text input accepts printable ASCII characters only")]
    UnsupportedCharacter,
}

pub(super) fn bounded_text<const N: usize>(
    text: &str,
    capacity_error: TextInputError,
) -> Result<String<N>, TextInputError> {
    if !text
        .bytes()
        .all(|character| (b' '..=b'~').contains(&character))
    {
        return Err(TextInputError::UnsupportedCharacter);
    }

    let mut bounded = String::new();
    bounded.push_str(text).map_err(|_| capacity_error)?;

    Ok(bounded)
}

pub(super) fn text_width(character_count: usize, font: &MonoFont<'_>) -> u32 {
    character_count as u32 * font.character_size.width
        + character_count.saturating_sub(1) as u32 * font.character_spacing
}

pub(super) fn value_padding<C: PixelColor>(style: &MenuStyle<C>) -> Size {
    Size::new(style.padding.width.max(1), style.padding.height.max(1))
}
