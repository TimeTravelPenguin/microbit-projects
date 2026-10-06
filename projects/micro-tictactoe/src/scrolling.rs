//! Scrolling text frames for the 5x5 display, without allocating a message buffer.

use crate::led_matrix::{EMPTY, GLYPH_COLUMNS, from_char};

#[cfg(test)]
#[path = "scrolling/tests.rs"]
mod tests;

/// A display frame and the milestone reached after displaying it.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct ScrollFrame {
    pub pixels: [[u8; 5]; 5],
    /// True once, when the final character has fully entered the display,
    /// before the first trailing blank column. Empty text never sets this flag.
    pub text_complete: bool,
}

/// Scroll a message from right to left, one column per frame.
///
/// The first and last frames are blank, allowing the whole message to enter
/// and leave the display. Each character occupies three columns, with a single
/// blank column between characters. Spaces and unsupported characters occupy
/// a blank glyph; ASCII lowercase letters use their uppercase glyphs.
///
/// Empty text yields one blank frame. The iterator borrows the text and uses
/// fixed memory regardless of message length. Send each frame to the display
/// driver and delay between frames to set the scrolling speed.
pub fn scroll_text(text: &str) -> impl Iterator<Item = [[u8; 5]; 5]> + '_ {
    scroll_frames(text).map(|frame| frame.pixels)
}

/// Scroll with a completion flag for actions between the final glyph and its
/// trailing blank columns. Display each frame before handling `text_complete`.
///
/// The pixels and spacing are identical to [`scroll_text`].
pub fn scroll_frames(text: &str) -> impl Iterator<Item = ScrollFrame> + '_ {
    let columns = text.char_indices().flat_map(move |(byte_idx, character)| {
        let glyph = from_char(character);
        let is_final_character = byte_idx + character.len_utf8() == text.len();

        GLYPH_COLUMNS
            .map(move |col_idx| {
                let column = core::array::from_fn(|row_idx| glyph[row_idx][col_idx]);
                let text_complete = is_final_character && col_idx == GLYPH_COLUMNS.end - 1;

                (column, text_complete)
            })
            .chain(core::iter::once(([0; 5], false)))
    });

    // The last character's separator supplies the first trailing blank column.
    let trailing_columns = if text.is_empty() { 0 } else { 4 };

    let initial_frame = ScrollFrame {
        pixels: EMPTY,
        text_complete: false,
    };

    core::iter::once(initial_frame).chain(
        columns
            .chain(core::iter::repeat_n(([0; 5], false), trailing_columns))
            .scan(EMPTY, |pixels, (column, text_complete)| {
                for (row, pixel) in pixels.iter_mut().zip(column) {
                    row.copy_within(1.., 0);
                    row[4] = pixel;
                }

                Some(ScrollFrame {
                    pixels: *pixels,
                    text_complete,
                })
            }),
    )
}
