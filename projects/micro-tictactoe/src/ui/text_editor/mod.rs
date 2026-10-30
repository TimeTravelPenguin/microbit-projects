//! A bounded, allocation-free text editing session.
//!
//! Values use printable ASCII. Character changes cycle through a space,
//! `a`–`z`, `A`–`Z`, `0`–`9`, then ASCII punctuation. Navigation wraps through
//! the value and an empty append position while capacity remains.
//! Incrementing that empty position appends `a`; decrementing it appends `~`.

use embedded_graphics::{
    Drawable,
    draw_target::{DrawTarget, DrawTargetExt},
    geometry::{Point, Size},
    mono_font::MonoTextStyle,
    pixelcolor::PixelColor,
    primitives::Rectangle,
    text::{Baseline, Text},
};
use heapless::String;

use super::{
    MenuStyle,
    text::{TextInputError, bounded_text, value_padding},
};

pub(super) const ALPHABET: &[u8] =
    b" abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~";

/// An active, allocation-free text edit with its own cancellation baseline.
#[derive(Clone, Debug)]
pub struct TextEditor<const N: usize> {
    draft: String<N>,
    original_value: String<N>,
    character_index: usize,
}

impl<const N: usize> TextEditor<N> {
    pub fn new(value: &str) -> Result<Self, TextInputError> {
        let value = bounded_text(value, TextInputError::ValueTooLong)?;

        Ok(Self::from_value(value))
    }

    pub(super) fn from_value(value: String<N>) -> Self {
        Self {
            original_value: value.clone(),
            draft: value,
            character_index: 0,
        }
    }

    pub fn value(&self) -> &str {
        self.draft.as_str()
    }

    pub fn draft(&self) -> &String<N> {
        &self.draft
    }

    pub fn original_value(&self) -> &str {
        self.original_value.as_str()
    }

    pub fn changed(&self) -> bool {
        self.draft != self.original_value
    }

    pub fn into_value(self) -> String<N> {
        self.draft
    }

    pub(super) fn into_original_value(self) -> String<N> {
        self.original_value
    }

    /// Returns the active byte/character index, including the append position.
    pub fn selected_character(&self) -> usize {
        self.character_index
    }

    /// Moves to the next character or append position, wrapping at the end.
    pub fn next_character(&mut self) -> bool {
        let slot_count = self.slot_count();

        if slot_count == 0 {
            return false;
        }

        let next_index = (self.character_index + 1) % slot_count;
        let changed = next_index != self.character_index;
        self.character_index = next_index;

        changed
    }

    /// Moves to the previous character or append position, wrapping at the start.
    pub fn previous_character(&mut self) -> bool {
        let slot_count = self.slot_count();

        if slot_count == 0 {
            return false;
        }

        let previous_index = if self.character_index == 0 {
            slot_count - 1
        } else {
            self.character_index - 1
        };

        let changed = previous_index != self.character_index;
        self.character_index = previous_index;

        changed
    }

    pub fn increment(&mut self) -> bool {
        self.change_character(true)
    }

    pub fn decrement(&mut self) -> bool {
        self.change_character(false)
    }

    /// Deletes the selected character. The empty append position has nothing
    /// to delete; deleting the final character leaves that position selected.
    pub fn delete_character(&mut self) -> bool {
        if self.character_index >= self.draft.len() {
            return false;
        }

        self.draft.remove(self.character_index);
        self.character_index = self.character_index.min(self.slot_count() - 1);

        true
    }

    /// Draws the editor across the target using the containing widget's style.
    pub fn draw<C, D>(&self, target: &mut D, style: &MenuStyle<C>) -> Result<(), D::Error>
    where
        C: PixelColor,
        D: DrawTarget<Color = C>,
    {
        let bounds = target.bounding_box();
        target.fill_solid(&bounds, style.background_color)?;

        if bounds.size.width == 0 || bounds.size.height == 0 || self.slot_count() == 0 {
            return Ok(());
        }

        let padding = value_padding(style);
        let slot_size = Size::new(
            (style.font.character_size.width + padding.width * 2).min(bounds.size.width),
            (style.font.character_size.height + padding.height * 2).min(bounds.size.height),
        );

        let append_selected = self.character_index == self.draft.len();
        let displayed_count =
            self.draft.len().max(1) + usize::from(append_selected && !self.draft.is_empty());
        let advance = slot_size.width + style.font.character_spacing;
        let visible_count = displayed_count
            .min(((bounds.size.width + style.font.character_spacing) / advance).max(1) as usize);
        let first_index = self.character_index.saturating_sub(visible_count - 1);
        let visible_width = visible_count as u32 * advance - style.font.character_spacing;
        let visible_value_count = self
            .draft
            .len()
            .saturating_sub(first_index)
            .min(visible_count)
            .max(1);
        let value_width = visible_value_count as u32 * advance - style.font.character_spacing;
        let horizontal_offset = (bounds.size.width.saturating_sub(value_width) / 2)
            .min(bounds.size.width.saturating_sub(visible_width));
        let origin = bounds.top_left
            + Point::new(
                horizontal_offset as i32,
                bounds.size.height.saturating_sub(slot_size.height) as i32 / 2,
            );

        let mut editor_target = target.clipped(&bounds);

        for slot_offset in 0..visible_count {
            let character_index = first_index + slot_offset;
            let slot_bounds = Rectangle::new(
                origin + Point::new(slot_offset as i32 * advance as i32, 0),
                slot_size,
            );

            let focused = character_index == self.character_index;

            if focused {
                editor_target.fill_solid(&slot_bounds, style.selected_background_color)?;
            }

            if character_index < self.draft.len() {
                Text::with_baseline(
                    &self.draft.as_str()[character_index..character_index + 1],
                    slot_bounds.top_left + Point::new(padding.width as i32, padding.height as i32),
                    MonoTextStyle::new(
                        style.font,
                        if focused {
                            style.selected_text_color
                        } else {
                            style.text_color
                        },
                    ),
                    Baseline::Top,
                )
                .draw(&mut editor_target)?;
            }
        }

        Ok(())
    }

    fn slot_count(&self) -> usize {
        self.draft.len() + usize::from(self.draft.len() < N)
    }

    fn change_character(&mut self, forward: bool) -> bool {
        let current_character = self
            .draft
            .as_bytes()
            .get(self.character_index)
            .copied()
            .unwrap_or(b' ');
        let alphabet_index = ALPHABET
            .iter()
            .position(|character| *character == current_character)
            .expect("values contain only the documented ASCII alphabet");
        let next_index = if forward {
            (alphabet_index + 1) % ALPHABET.len()
        } else {
            (alphabet_index + ALPHABET.len() - 1) % ALPHABET.len()
        };

        let next_character = ALPHABET[next_index] as char;

        if self.character_index == self.draft.len() {
            return self.draft.push(next_character).is_ok();
        }

        self.draft.remove(self.character_index);
        self.draft
            .insert(self.character_index, next_character)
            .expect("replacing one ASCII character preserves capacity");

        true
    }
}

#[cfg(test)]
mod tests;
