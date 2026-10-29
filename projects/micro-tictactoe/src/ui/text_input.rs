//! A bounded text field with menu focus and a separate character editor.
//!
//! Values and labels use printable ASCII. Character changes cycle through a
//! space, `a`–`z`, `A`–`Z`, `0`–`9`, then ASCII punctuation. Navigation wraps
//! through the value and an empty append position while capacity remains.
//! Incrementing that empty position appends `a`; decrementing it appends `~`.
//! Callers map their own controls to the public editing methods.

use embedded_graphics::{
    Drawable,
    draw_target::{DrawTarget, DrawTargetExt},
    geometry::{Dimensions, Point, Size},
    mono_font::{MonoFont, MonoTextStyle},
    pixelcolor::PixelColor,
    primitives::Rectangle,
    text::{Baseline, Text},
    transform::Transform,
};
use heapless::String;
use thiserror::Error;

use super::MenuStyle;

const ALPHABET: &[u8] =
    b" abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~";

#[derive(Clone, Copy, Debug, Error, PartialEq, Eq)]
pub enum TextInputError {
    #[error("Text input label exceeds its capacity")]
    LabelTooLong,
    #[error("Text input value exceeds its capacity")]
    ValueTooLong,
    #[error("Text input accepts printable ASCII characters only")]
    UnsupportedCharacter,
}

/// An allocation-free field with independent menu focus and editing state.
///
/// `value()` exposes the current draft while editing. `finish_edit()` accepts
/// it, and `cancel_edit()` restores the value present when editing began.
/// Normal dimensions reserve `N` characters so changing a value never moves
/// surrounding menu rows. Editing occupies the draw target, hides the label,
/// and centers the existing value, scrolling to keep the cursor visible. The
/// append box appears only when selected and follows the final character.
#[derive(Clone, Debug)]
pub struct TextInput<C: PixelColor, const N: usize> {
    label: String<N>,
    value: String<N>,
    original_value: String<N>,
    editable: bool,
    editing: bool,
    focused: bool,
    character_index: usize,
    position: Point,
    style: MenuStyle<C>,
}

impl<C: PixelColor, const N: usize> TextInput<C, N>
where
    MenuStyle<C>: Default,
{
    pub fn new(label: &str, value: &str, editable: bool) -> Result<Self, TextInputError> {
        Self::with_style(label, value, editable, MenuStyle::default())
    }
}

impl<C: PixelColor, const N: usize> TextInput<C, N> {
    pub fn with_style(
        label: &str,
        value: &str,
        editable: bool,
        style: MenuStyle<C>,
    ) -> Result<Self, TextInputError> {
        let label = Self::bounded_text(label, TextInputError::LabelTooLong)?;
        let value = Self::bounded_text(value, TextInputError::ValueTooLong)?;

        Ok(Self {
            label,
            original_value: value.clone(),
            value,
            editable,
            editing: false,
            focused: false,
            character_index: 0,
            position: Point::zero(),
            style,
        })
    }

    pub fn set_style(mut self, style: MenuStyle<C>) -> Self {
        self.style = style;

        self
    }

    pub fn label(&self) -> &str {
        self.label.as_str()
    }

    pub fn value(&self) -> &str {
        self.value.as_str()
    }

    pub fn is_editable(&self) -> bool {
        self.editable
    }

    pub fn is_editing(&self) -> bool {
        self.editing
    }

    /// Returns the active byte/character index, including the append position.
    pub fn selected_character(&self) -> Option<usize> {
        self.editing.then_some(self.character_index)
    }

    pub fn set_focused(&mut self, focused: bool) {
        self.focused = focused;
    }

    /// Making an editing field read-only accepts its current draft.
    pub fn set_editable(&mut self, editable: bool) {
        if !editable {
            self.finish_edit();
        }

        self.editable = editable;
    }

    /// Replaces the value atomically and resets the cancellation baseline.
    /// Failed validation leaves both the draft and its original value intact.
    pub fn set_value(&mut self, value: &str) -> Result<(), TextInputError> {
        let value = Self::bounded_text(value, TextInputError::ValueTooLong)?;
        self.original_value = value.clone();
        self.value = value;
        self.character_index = 0;

        Ok(())
    }

    /// Enters editing at the first character. Read-only, zero-capacity, and
    /// already-editing fields return `false` without changing state.
    pub fn begin_edit(&mut self) -> bool {
        if !self.editable || self.editing || N == 0 {
            return false;
        }

        self.original_value = self.value.clone();
        self.character_index = 0;
        self.editing = true;

        true
    }

    pub fn finish_edit(&mut self) -> bool {
        if !self.editing {
            return false;
        }

        self.editing = false;
        self.original_value = self.value.clone();

        true
    }

    pub fn cancel_edit(&mut self) -> bool {
        if !self.editing {
            return false;
        }

        self.value = self.original_value.clone();
        self.editing = false;

        true
    }

    /// Moves to the next character or append position, wrapping at the end.
    pub fn next_character(&mut self) -> bool {
        if !self.editing {
            return false;
        }

        let next_index = (self.character_index + 1) % self.slot_count();
        let changed = next_index != self.character_index;
        self.character_index = next_index;

        changed
    }

    /// Moves to the previous character or append position, wrapping at the start.
    pub fn previous_character(&mut self) -> bool {
        if !self.editing {
            return false;
        }

        let previous_index = if self.character_index == 0 {
            self.slot_count() - 1
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
        if !self.editing || self.character_index >= self.value.len() {
            return false;
        }

        self.value.remove(self.character_index);
        self.character_index = self.character_index.min(self.slot_count() - 1);

        true
    }

    pub(crate) fn row_size(&self, style: &MenuStyle<C>) -> Size {
        let padding = Self::value_padding(style);
        let value_width = Self::text_width(N.max(1), style.font) + padding.width * 2;
        let label_width = Self::text_width(self.label.len(), style.font);
        let gap = if self.label.is_empty() {
            0
        } else {
            style.padding.width.max(1)
        };

        Size::new(
            label_width + gap + value_width + style.padding.width * 2,
            style.font.character_size.height + padding.height * 2,
        )
    }

    /// Draws a menu row without filling it. Focus is limited to the value box.
    pub(crate) fn draw_row<D>(
        &self,
        target: &mut D,
        bounds: Rectangle,
        style: &MenuStyle<C>,
        focused: bool,
    ) -> Result<(), D::Error>
    where
        D: DrawTarget<Color = C>,
    {
        let padding = Self::value_padding(style);
        let value_width = (Self::text_width(N.max(1), style.font) + padding.width * 2)
            .min(bounds.size.width.saturating_sub(style.padding.width * 2));
        let value_height =
            (style.font.character_size.height + padding.height * 2).min(bounds.size.height);
        let value_bounds = Rectangle::new(
            bounds.top_left
                + Point::new(
                    bounds
                        .size
                        .width
                        .saturating_sub(style.padding.width + value_width)
                        as i32,
                    bounds.size.height.saturating_sub(value_height) as i32 / 2,
                ),
            Size::new(value_width, value_height),
        );

        let mut row_target = target.clipped(&bounds);

        if focused {
            row_target.fill_solid(&value_bounds, style.selected_background_color)?;
        }

        let label_bounds = Rectangle::new(
            bounds.top_left,
            Size::new(
                (value_bounds.top_left.x - bounds.top_left.x)
                    .max(0)
                    .saturating_sub(style.padding.width.max(1) as i32) as u32,
                bounds.size.height,
            ),
        );

        Text::with_baseline(
            self.label.as_str(),
            bounds.top_left
                + Point::new(
                    style.padding.width as i32,
                    bounds
                        .size
                        .height
                        .saturating_sub(style.font.character_size.height)
                        as i32
                        / 2,
                ),
            MonoTextStyle::new(style.font, style.text_color),
            Baseline::Top,
        )
        .draw(&mut row_target.clipped(&label_bounds))?;

        let value_content = Rectangle::new(
            value_bounds.top_left + Point::new(padding.width as i32, padding.height as i32),
            Size::new(
                value_bounds.size.width.saturating_sub(padding.width * 2),
                value_bounds.size.height.saturating_sub(padding.height * 2),
            ),
        );

        Text::with_baseline(
            self.value.as_str(),
            value_content.top_left,
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
        .draw(&mut row_target.clipped(&value_content))?;

        Ok(())
    }

    /// Draws the modal character editor using the containing menu's style.
    pub(crate) fn draw_editor<D>(
        &self,
        target: &mut D,
        style: &MenuStyle<C>,
    ) -> Result<(), D::Error>
    where
        D: DrawTarget<Color = C>,
    {
        let bounds = target.bounding_box();
        target.fill_solid(&bounds, style.background_color)?;

        if bounds.size.width == 0 || bounds.size.height == 0 || self.slot_count() == 0 {
            return Ok(());
        }

        let padding = Self::value_padding(style);
        let slot_size = Size::new(
            (style.font.character_size.width + padding.width * 2).min(bounds.size.width),
            (style.font.character_size.height + padding.height * 2).min(bounds.size.height),
        );

        let append_selected = self.character_index == self.value.len();
        let displayed_count =
            self.value.len().max(1) + usize::from(append_selected && !self.value.is_empty());
        let advance = slot_size.width + style.font.character_spacing;
        let visible_count = displayed_count
            .min(((bounds.size.width + style.font.character_spacing) / advance).max(1) as usize);
        let first_index = self.character_index.saturating_sub(visible_count - 1);
        let visible_width = visible_count as u32 * advance - style.font.character_spacing;
        let visible_value_count = self
            .value
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

            let focused = self.editing && character_index == self.character_index;

            if focused {
                editor_target.fill_solid(&slot_bounds, style.selected_background_color)?;
            }

            if character_index < self.value.len() {
                Text::with_baseline(
                    &self.value.as_str()[character_index..character_index + 1],
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

    fn bounded_text(
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

    fn slot_count(&self) -> usize {
        self.value.len() + usize::from(self.value.len() < N)
    }

    fn change_character(&mut self, forward: bool) -> bool {
        if !self.editing {
            return false;
        }

        let current_character = self
            .value
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

        if self.character_index == self.value.len() {
            return self.value.push(next_character).is_ok();
        }

        self.value.remove(self.character_index);
        self.value
            .insert(self.character_index, next_character)
            .expect("replacing one ASCII character preserves capacity");

        true
    }

    fn text_width(character_count: usize, font: &MonoFont<'_>) -> u32 {
        character_count as u32 * font.character_size.width
            + character_count.saturating_sub(1) as u32 * font.character_spacing
    }

    fn value_padding(style: &MenuStyle<C>) -> Size {
        Size::new(style.padding.width.max(1), style.padding.height.max(1))
    }
}

impl<C: PixelColor, const N: usize> Dimensions for TextInput<C, N> {
    fn bounding_box(&self) -> Rectangle {
        Rectangle::new(self.position, self.row_size(&self.style))
    }
}

impl<C: PixelColor, const N: usize> Transform for TextInput<C, N> {
    fn translate(&self, by: Point) -> Self {
        let mut input = self.clone();
        input.translate_mut(by);

        input
    }

    fn translate_mut(&mut self, by: Point) -> &mut Self {
        self.position += by;

        self
    }
}

impl<C: PixelColor, const N: usize> Drawable for TextInput<C, N> {
    type Color = C;
    type Output = ();

    fn draw<D>(&self, target: &mut D) -> Result<(), D::Error>
    where
        D: DrawTarget<Color = C>,
    {
        if self.editing {
            return self.draw_editor(target, &self.style);
        }

        let bounds = self.bounding_box();
        target.fill_solid(&bounds, self.style.background_color)?;
        self.draw_row(target, bounds, &self.style, self.focused)
    }
}

#[cfg(test)]
mod tests;
