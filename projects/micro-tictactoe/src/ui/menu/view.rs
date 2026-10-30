//! Layout and drawing of a menu against a borrowed committed model.

use embedded_graphics::{
    Drawable,
    draw_target::DrawTarget,
    geometry::{Dimensions, Point, Size},
    mono_font::MonoTextStyle,
    pixelcolor::PixelColor,
    primitives::Rectangle,
    text::{Alignment, Baseline, Text, TextStyleBuilder},
    transform::Transform,
};

use super::{Menu, MenuItem};
use crate::ui::text_input::TextInput;

/// A borrowed view keeps drawing and layout tied to the supplied model.
/// Translation moves only the view and never clones the model or menu.
pub struct MenuView<'a, C: PixelColor, const N: usize, const MAX_ITEMS: usize, Model, Command> {
    menu: &'a Menu<C, N, MAX_ITEMS, Model, Command>,
    model: &'a Model,
    position: Point,
}

impl<C: PixelColor, const N: usize, const MAX_ITEMS: usize, Model, Command> Clone
    for MenuView<'_, C, N, MAX_ITEMS, Model, Command>
{
    fn clone(&self) -> Self {
        *self
    }
}

impl<C: PixelColor, const N: usize, const MAX_ITEMS: usize, Model, Command> Copy
    for MenuView<'_, C, N, MAX_ITEMS, Model, Command>
{
}

impl<'a, C: PixelColor, const N: usize, const MAX_ITEMS: usize, Model, Command>
    MenuView<'a, C, N, MAX_ITEMS, Model, Command>
{
    pub(super) fn new(menu: &'a Menu<C, N, MAX_ITEMS, Model, Command>, model: &'a Model) -> Self {
        Self {
            menu,
            model,
            position: menu.position,
        }
    }

    fn item_size(&self, item: &MenuItem<Model, Command, N>) -> Size {
        let label = match item {
            MenuItem::TextField { label, .. } => {
                return TextInput::<C, N>::row_size_for(label, &self.menu.style);
            }

            MenuItem::Action { label, .. } => label.as_str(),
        };

        let style = &self.menu.style;
        let text_style = MonoTextStyle::new(style.font, style.text_color);
        let text_size = Text::with_baseline(label, Point::zero(), text_style, Baseline::Top)
            .bounding_box()
            .size;
        // Include blank lines, which have no glyph bounding box.
        let text_height = label.split('\n').count() as u32 * style.font.character_size.height;

        Size::new(
            text_size.width + style.padding.width * 2,
            text_height + style.padding.height * 2,
        )
    }
}

impl<C: PixelColor, const N: usize, const MAX_ITEMS: usize, Model, Command> Dimensions
    for MenuView<'_, C, N, MAX_ITEMS, Model, Command>
{
    fn bounding_box(&self) -> Rectangle {
        let mut size = Size::zero();

        for (index, item) in self.menu.items.iter().enumerate() {
            let item_size = self.item_size(item);
            size.width = size.width.max(item_size.width);
            size.height += item_size.height;

            if index > 0 {
                size.height += self.menu.style.spacing;
            }
        }

        Rectangle::new(self.position, size)
    }
}

impl<C: PixelColor, const N: usize, const MAX_ITEMS: usize, Model, Command> Transform
    for MenuView<'_, C, N, MAX_ITEMS, Model, Command>
{
    fn translate(&self, by: Point) -> Self {
        let mut view = *self;
        view.translate_mut(by);

        view
    }

    fn translate_mut(&mut self, by: Point) -> &mut Self {
        self.position += by;

        self
    }
}

impl<C: PixelColor, const N: usize, const MAX_ITEMS: usize, Model, Command> Drawable
    for MenuView<'_, C, N, MAX_ITEMS, Model, Command>
{
    type Color = C;
    type Output = ();

    fn draw<D>(&self, target: &mut D) -> Result<(), D::Error>
    where
        D: DrawTarget<Color = C>,
    {
        let menu = self.menu;
        let style = &menu.style;

        if let Some(editor) = menu.editor() {
            return editor.draw(target, style);
        }

        if menu.items.is_empty() {
            return Ok(());
        }

        let bounds = self.bounding_box();
        target.fill_solid(&bounds, style.background_color)?;

        let content_width = bounds.size.width - style.padding.width * 2;
        let anchor_offset = match style.text_alignment {
            Alignment::Left => 0,
            Alignment::Center => content_width.saturating_sub(1) / 2,
            Alignment::Right => content_width.saturating_sub(1),
        };

        let text_style = TextStyleBuilder::new()
            .alignment(style.text_alignment)
            .baseline(Baseline::Top)
            .build();

        let mut position = self.position;

        for (index, item) in menu.items.iter().enumerate() {
            let row_height = self.item_size(item).height;

            if let MenuItem::TextField { label, read, .. } = item {
                TextInput::<C, N>::draw_row_value(
                    label,
                    read(self.model),
                    target,
                    Rectangle::new(position, Size::new(bounds.size.width, row_height)),
                    style,
                    Some(index) == menu.selected_index(),
                )?;

                position.y += (row_height + style.spacing) as i32;

                continue;
            }

            let text_color = if Some(index) == menu.selected_index() {
                let row = Rectangle::new(position, Size::new(bounds.size.width, row_height));
                target.fill_solid(&row, style.selected_background_color)?;

                style.selected_text_color
            } else {
                style.text_color
            };

            let mut text_position = position
                + Point::new(
                    (style.padding.width + anchor_offset) as i32,
                    style.padding.height as i32,
                );

            for line in item.label().split('\n') {
                let line = line.strip_suffix('\r').unwrap_or(line);
                Text::with_text_style(
                    line,
                    text_position,
                    MonoTextStyle::new(style.font, text_color),
                    text_style,
                )
                .draw(target)?;

                text_position.y += style.font.character_size.height as i32;
            }

            position.y += (row_height + style.spacing) as i32;
        }

        Ok(())
    }
}

impl<C: PixelColor, const N: usize, const MAX_ITEMS: usize> Dimensions for Menu<C, N, MAX_ITEMS> {
    fn bounding_box(&self) -> Rectangle {
        self.view(&()).bounding_box()
    }
}

impl<C: PixelColor, const N: usize, const MAX_ITEMS: usize> Transform for Menu<C, N, MAX_ITEMS> {
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

impl<C: PixelColor, const N: usize, const MAX_ITEMS: usize> Drawable for Menu<C, N, MAX_ITEMS> {
    type Color = C;
    type Output = ();

    fn draw<D>(&self, target: &mut D) -> Result<(), D::Error>
    where
        D: DrawTarget<Color = C>,
    {
        self.view(&()).draw(target)
    }
}
