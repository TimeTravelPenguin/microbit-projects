//! A bounded text field with menu focus and a separate character editor.
//!
//! Values and labels use printable ASCII. Callers map their own controls to
//! the public editing methods, which delegate to an active `TextEditor`.

pub use super::text::TextInputError;
use embedded_graphics::{
    Drawable,
    draw_target::{DrawTarget, DrawTargetExt},
    geometry::{Dimensions, Point, Size},
    mono_font::MonoTextStyle,
    pixelcolor::PixelColor,
    primitives::Rectangle,
    text::{Baseline, Text},
    transform::Transform,
};
use heapless::String;

use super::{
    LABEL_CAPACITY, MenuStyle,
    text::{bounded_text, text_width, value_padding},
    text_editor::TextEditor,
};

#[derive(Clone, Debug)]
enum TextInputState<const N: usize> {
    Idle(String<N>),
    Editing(TextEditor<N>),
}

/// An allocation-free field with independent menu focus and editing state.
///
/// `value()` exposes the current draft while editing. `finish_edit()` accepts
/// it, and `cancel_edit()` restores the value present when editing began.
/// Labels use [`super::LABEL_CAPACITY`] bytes independently of the value's `N`.
/// Normal dimensions reserve `N` characters so changing a value never moves
/// surrounding menu rows. Editing occupies the draw target, hides the label,
/// and centers the existing value, scrolling to keep the cursor visible. The
/// append box appears only when selected and follows the final character.
#[derive(Clone, Debug)]
pub struct TextInput<C: PixelColor, const N: usize> {
    label: String<LABEL_CAPACITY>,
    state: TextInputState<N>,
    editable: bool,
    focused: bool,
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
        let label = bounded_text(label, TextInputError::LabelTooLong)?;
        let value = bounded_text(value, TextInputError::ValueTooLong)?;

        Ok(Self {
            label,
            state: TextInputState::Idle(value),
            editable,
            focused: false,
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
        match &self.state {
            TextInputState::Idle(value) => value.as_str(),
            TextInputState::Editing(editor) => editor.value(),
        }
    }

    pub fn is_editable(&self) -> bool {
        self.editable
    }

    pub fn is_editing(&self) -> bool {
        matches!(self.state, TextInputState::Editing(_))
    }

    /// Returns the active byte/character index, including the append position.
    pub fn selected_character(&self) -> Option<usize> {
        match &self.state {
            TextInputState::Idle(_) => None,
            TextInputState::Editing(editor) => Some(editor.selected_character()),
        }
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
        let value = bounded_text(value, TextInputError::ValueTooLong)?;
        self.state = match self.state {
            TextInputState::Idle(_) => TextInputState::Idle(value),
            TextInputState::Editing(_) => TextInputState::Editing(TextEditor::from_value(value)),
        };

        Ok(())
    }

    /// Enters editing at the first character. Read-only, zero-capacity, and
    /// already-editing fields return `false` without changing state.
    pub fn begin_edit(&mut self) -> bool {
        if !self.editable || self.is_editing() || N == 0 {
            return false;
        }

        let TextInputState::Idle(value) = &self.state else {
            return false;
        };

        self.state = TextInputState::Editing(TextEditor::from_value(value.clone()));

        true
    }

    pub fn finish_edit(&mut self) -> bool {
        let state = core::mem::replace(&mut self.state, TextInputState::Idle(String::new()));
        let (value, finished) = match state {
            TextInputState::Idle(value) => (value, false),
            TextInputState::Editing(editor) => (editor.into_value(), true),
        };

        self.state = TextInputState::Idle(value);

        finished
    }

    pub fn cancel_edit(&mut self) -> bool {
        let state = core::mem::replace(&mut self.state, TextInputState::Idle(String::new()));
        let (value, cancelled) = match state {
            TextInputState::Idle(value) => (value, false),
            TextInputState::Editing(editor) => (editor.into_original_value(), true),
        };

        self.state = TextInputState::Idle(value);

        cancelled
    }

    /// Moves to the next character or append position, wrapping at the end.
    pub fn next_character(&mut self) -> bool {
        self.editor_mut().is_some_and(TextEditor::next_character)
    }

    /// Moves to the previous character or append position, wrapping at the start.
    pub fn previous_character(&mut self) -> bool {
        self.editor_mut()
            .is_some_and(TextEditor::previous_character)
    }

    pub fn increment(&mut self) -> bool {
        self.editor_mut().is_some_and(TextEditor::increment)
    }

    pub fn decrement(&mut self) -> bool {
        self.editor_mut().is_some_and(TextEditor::decrement)
    }

    /// Deletes the selected character. The empty append position has nothing
    /// to delete; deleting the final character leaves that position selected.
    pub fn delete_character(&mut self) -> bool {
        self.editor_mut().is_some_and(TextEditor::delete_character)
    }

    fn editor_mut(&mut self) -> Option<&mut TextEditor<N>> {
        match &mut self.state {
            TextInputState::Idle(_) => None,
            TextInputState::Editing(editor) => Some(editor),
        }
    }

    pub(crate) fn row_size(&self, style: &MenuStyle<C>) -> Size {
        Self::row_size_for(self.label(), style)
    }

    pub(crate) fn row_size_for(label: &str, style: &MenuStyle<C>) -> Size {
        let padding = value_padding(style);
        let value_width = text_width(N.max(1), style.font) + padding.width * 2;
        let label_width = text_width(label.len(), style.font);
        let gap = if label.is_empty() {
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
        Self::draw_row_value(self.label(), self.value(), target, bounds, style, focused)
    }

    pub(crate) fn draw_row_value<D>(
        label: &str,
        value: &str,
        target: &mut D,
        bounds: Rectangle,
        style: &MenuStyle<C>,
        focused: bool,
    ) -> Result<(), D::Error>
    where
        D: DrawTarget<Color = C>,
    {
        let padding = value_padding(style);
        let value_width = (text_width(N.max(1), style.font) + padding.width * 2)
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
            label,
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
            value,
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
        match &self.state {
            TextInputState::Idle(_) => Ok(()),
            TextInputState::Editing(editor) => editor.draw(target, style),
        }
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
        if self.is_editing() {
            return self.draw_editor(target, &self.style);
        }

        let bounds = self.bounding_box();
        target.fill_solid(&bounds, self.style.background_color)?;
        self.draw_row(target, bounds, &self.style, self.focused)
    }
}

#[cfg(test)]
mod tests;
