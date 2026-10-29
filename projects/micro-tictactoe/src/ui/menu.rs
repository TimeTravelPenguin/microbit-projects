//! A bounded, allocation-free menu with configurable row highlighting.
//!
//! Clear the display before drawing a complete frame. The menu repaints its own
//! bounds, so changing selection also works without clearing the whole display.
//! Moving the menu or changing its size requires clearing its previous bounds.
//!
//! ```
//! use embedded_graphics::{pixelcolor::BinaryColor, prelude::*};
//! use embedded_layout::prelude::*;
//! use micro_tictactoe::ui::{Menu, MenuAction};
//!
//! let mut menu = Menu::<BinaryColor, 24, 4>::new_with_items(&["New game", "Join game"])?;
//! menu = menu.align_to(
//!     &embedded_graphics::primitives::Rectangle::new(Point::zero(), Size::new(128, 64)),
//!     horizontal::Center,
//!     vertical::Center,
//! );
//!
//! menu.handle_action(MenuAction::NextItem);
//! assert_eq!(menu.handle_action(MenuAction::SelectItem), Some(1));
//! # Ok::<(), micro_tictactoe::ui::MenuError>(())
//! ```

use embedded_graphics::{
    Drawable,
    draw_target::DrawTarget,
    geometry::{Dimensions, Point, Size},
    mono_font::{MonoFont, MonoTextStyle, ascii::FONT_5X8},
    pixelcolor::{BinaryColor, PixelColor},
    primitives::Rectangle,
    text::{Alignment, Baseline, Text, TextStyleBuilder},
    transform::Transform,
};
use heapless::{String, Vec};
use thiserror::Error;

use super::text_input::TextInput;

#[derive(Debug, Error, PartialEq, Eq)]
pub enum MenuError {
    #[error("Menu item capacity exceeded")]
    MenuFull,
    #[error("Menu item length exceeded")]
    ItemTooLong,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum MenuAction {
    NextItem,
    PreviousItem,
    SelectItem,
}

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

/// A menu row is either an action label or a labelled text input.
#[derive(Clone, Debug)]
pub enum MenuItem<C: PixelColor, const MAX_ITEM_LEN: usize> {
    Action(String<MAX_ITEM_LEN>),
    TextInput(TextInput<C, MAX_ITEM_LEN>),
}

impl<C: PixelColor, const MAX_ITEM_LEN: usize> MenuItem<C, MAX_ITEM_LEN> {
    pub fn label(&self) -> &str {
        match self {
            Self::Action(label) => label,
            Self::TextInput(input) => input.label(),
        }
    }
}

/// Owns rows and selection; drawing derives the rows directly from this state.
/// Implements `Dimensions` and `Transform` for use with `embedded-layout`.
#[derive(Clone, Debug)]
pub struct Menu<C: PixelColor, const MAX_ITEM_LEN: usize, const MAX_ITEMS: usize> {
    items: Vec<MenuItem<C, MAX_ITEM_LEN>, MAX_ITEMS>,
    selected_index: Option<usize>,
    position: Point,
    style: MenuStyle<C>,
}

impl<C: PixelColor, const MAX_ITEM_LEN: usize, const MAX_ITEMS: usize> Default
    for Menu<C, MAX_ITEM_LEN, MAX_ITEMS>
where
    MenuStyle<C>: Default,
{
    fn default() -> Self {
        Self::new()
    }
}

impl<C: PixelColor, const MAX_ITEM_LEN: usize, const MAX_ITEMS: usize>
    Menu<C, MAX_ITEM_LEN, MAX_ITEMS>
where
    MenuStyle<C>: Default,
{
    pub fn new() -> Self {
        Self::with_style(MenuStyle::default())
    }

    pub fn new_with_items(items: &[&str]) -> Result<Self, MenuError> {
        let mut menu = Self::new();
        menu.set_items(items)?;

        Ok(menu)
    }
}

impl<C: PixelColor, const MAX_ITEM_LEN: usize, const MAX_ITEMS: usize>
    Menu<C, MAX_ITEM_LEN, MAX_ITEMS>
{
    pub fn with_style(style: MenuStyle<C>) -> Self {
        Self {
            items: Vec::new(),
            selected_index: None,
            position: Point::zero(),
            style,
        }
    }

    pub fn set_style(mut self, style: MenuStyle<C>) -> Self {
        self.style = style;

        self
    }

    pub fn add_item(&mut self, item: &str) -> Result<(), MenuError> {
        if self.items.is_full() {
            return Err(MenuError::MenuFull);
        }

        let mut item_string = String::new();
        item_string
            .push_str(item)
            .map_err(|_| MenuError::ItemTooLong)?;

        self.push_item(MenuItem::Action(item_string))
    }

    pub fn add_text_input(&mut self, input: TextInput<C, MAX_ITEM_LEN>) -> Result<(), MenuError> {
        self.push_item(MenuItem::TextInput(input))
    }

    fn push_item(&mut self, item: MenuItem<C, MAX_ITEM_LEN>) -> Result<(), MenuError> {
        self.items.push(item).map_err(|_| MenuError::MenuFull)?;

        if self.selected_index.is_none() {
            self.selected_index = Some(0);
        }

        Ok(())
    }

    pub fn set_items(&mut self, items: &[&str]) -> Result<(), MenuError> {
        self.items.clear();
        self.selected_index = None;

        for item in items {
            self.add_item(item)?;
        }

        Ok(())
    }

    pub fn selected_index(&self) -> Option<usize> {
        self.selected_index
    }

    pub fn selected_item(&self) -> Option<&str> {
        self.selected_index.map(|index| self.items[index].label())
    }

    pub fn text_input(&self, index: usize) -> Option<&TextInput<C, MAX_ITEM_LEN>> {
        match self.items.get(index)? {
            MenuItem::TextInput(input) => Some(input),
            MenuItem::Action(_) => None,
        }
    }

    pub fn text_input_mut(&mut self, index: usize) -> Option<&mut TextInput<C, MAX_ITEM_LEN>> {
        match self.items.get_mut(index)? {
            MenuItem::TextInput(input) => Some(input),
            MenuItem::Action(_) => None,
        }
    }

    pub fn selected_text_input(&self) -> Option<&TextInput<C, MAX_ITEM_LEN>> {
        self.text_input(self.selected_index?)
    }

    pub fn selected_text_input_mut(&mut self) -> Option<&mut TextInput<C, MAX_ITEM_LEN>> {
        self.text_input_mut(self.selected_index?)
    }

    pub fn is_editing(&self) -> bool {
        self.selected_text_input()
            .is_some_and(TextInput::is_editing)
    }

    /// Navigation wraps at both ends. Selecting an action returns its index;
    /// selecting an editable input starts its editor. Navigation is suspended
    /// until the caller finishes or cancels editing through the input's API.
    pub fn handle_action(&mut self, action: MenuAction) -> Option<usize> {
        let selected_index = self.selected_index?;

        if self.is_editing() {
            return None;
        }

        self.selected_index = Some(match action {
            MenuAction::NextItem => (selected_index + 1) % self.items.len(),
            MenuAction::PreviousItem => {
                if selected_index == 0 {
                    self.items.len() - 1
                } else {
                    selected_index - 1
                }
            }

            MenuAction::SelectItem => {
                if let Some(input) = self.selected_text_input_mut() {
                    input.begin_edit();

                    return None;
                }

                return Some(selected_index);
            }
        });

        None
    }

    pub fn select_next(&mut self) {
        self.handle_action(MenuAction::NextItem);
    }

    pub fn select_previous(&mut self) {
        self.handle_action(MenuAction::PreviousItem);
    }

    pub fn select_item(&mut self) -> Option<usize> {
        self.handle_action(MenuAction::SelectItem)
    }

    fn item_size(&self, item: &MenuItem<C, MAX_ITEM_LEN>) -> Size {
        let item = match item {
            MenuItem::TextInput(input) => return input.row_size(&self.style),
            MenuItem::Action(label) => label.as_str(),
        };

        let text_style = MonoTextStyle::new(self.style.font, self.style.text_color);
        let text_size = Text::with_baseline(item, Point::zero(), text_style, Baseline::Top)
            .bounding_box()
            .size;

        // Count blank lines too: a text bounding box only includes nonempty lines.
        let text_height = item.split('\n').count() as u32 * self.style.font.character_size.height;

        Size::new(
            text_size.width + self.style.padding.width * 2,
            text_height + self.style.padding.height * 2,
        )
    }
}

impl<C: PixelColor, const MAX_ITEM_LEN: usize, const MAX_ITEMS: usize> Dimensions
    for Menu<C, MAX_ITEM_LEN, MAX_ITEMS>
{
    fn bounding_box(&self) -> Rectangle {
        let mut size = Size::zero();

        for (index, item) in self.items.iter().enumerate() {
            let item_size = self.item_size(item);
            size.width = size.width.max(item_size.width);
            size.height += item_size.height;

            if index > 0 {
                size.height += self.style.spacing;
            }
        }

        Rectangle::new(self.position, size)
    }
}

impl<C: PixelColor, const MAX_ITEM_LEN: usize, const MAX_ITEMS: usize> Transform
    for Menu<C, MAX_ITEM_LEN, MAX_ITEMS>
{
    fn translate(&self, by: Point) -> Self {
        let mut menu = self.clone();
        menu.translate_mut(by);

        menu
    }

    fn translate_mut(&mut self, by: Point) -> &mut Self {
        self.position += by;

        self
    }
}

impl<C: PixelColor, const MAX_ITEM_LEN: usize, const MAX_ITEMS: usize> Drawable
    for Menu<C, MAX_ITEM_LEN, MAX_ITEMS>
{
    type Color = C;
    type Output = ();

    fn draw<D>(&self, target: &mut D) -> Result<(), D::Error>
    where
        D: DrawTarget<Color = C>,
    {
        if let Some(input) = self
            .selected_text_input()
            .filter(|input| input.is_editing())
        {
            return input.draw_editor(target, &self.style);
        }

        if self.items.is_empty() {
            return Ok(());
        }

        let bounds = self.bounding_box();
        target.fill_solid(&bounds, self.style.background_color)?;

        let content_width = bounds.size.width - self.style.padding.width * 2;
        let anchor_offset = match self.style.text_alignment {
            Alignment::Left => 0,
            Alignment::Center => content_width.saturating_sub(1) / 2,
            Alignment::Right => content_width.saturating_sub(1),
        };

        let text_style = TextStyleBuilder::new()
            .alignment(self.style.text_alignment)
            .baseline(Baseline::Top)
            .build();

        let mut position = self.position;

        for (index, item) in self.items.iter().enumerate() {
            let row_height = self.item_size(item).height;

            if let MenuItem::TextInput(input) = item {
                input.draw_row(
                    target,
                    Rectangle::new(position, Size::new(bounds.size.width, row_height)),
                    &self.style,
                    Some(index) == self.selected_index,
                )?;

                position.y += (row_height + self.style.spacing) as i32;

                continue;
            }

            let text_color = if Some(index) == self.selected_index {
                let row = Rectangle::new(position, Size::new(bounds.size.width, row_height));
                target.fill_solid(&row, self.style.selected_background_color)?;

                self.style.selected_text_color
            } else {
                self.style.text_color
            };

            let mut text_position = position
                + Point::new(
                    (self.style.padding.width + anchor_offset) as i32,
                    self.style.padding.height as i32,
                );

            for line in item.label().split('\n') {
                // Strip CR before alignment so Windows line endings don't shift text.
                let line = line.strip_suffix('\r').unwrap_or(line);
                Text::with_text_style(
                    line,
                    text_position,
                    MonoTextStyle::new(self.style.font, text_color),
                    text_style,
                )
                .draw(target)?;

                text_position.y += self.style.font.character_size.height as i32;
            }

            position.y += (row_height + self.style.spacing) as i32;
        }

        Ok(())
    }
}

#[cfg(test)]
mod tests;
