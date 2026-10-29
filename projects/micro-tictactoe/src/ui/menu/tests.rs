use embedded_graphics::{
    Drawable,
    draw_target::DrawTarget,
    geometry::{Dimensions, Point, Size},
    mock_display::MockDisplay,
    mono_font::{
        MonoTextStyle,
        ascii::{FONT_5X8, FONT_6X10},
    },
    pixelcolor::{BinaryColor, PixelColor, Rgb888, RgbColor},
    primitives::{PointsIter, Rectangle},
    text::{Alignment, Baseline, Text},
    transform::Transform,
};
use embedded_layout::align::{Align, horizontal, vertical};

use super::{Menu, MenuAction, MenuError, MenuStyle};
use crate::ui::TextInput;

fn mock_display<C: PixelColor>() -> MockDisplay<C> {
    let mut display = MockDisplay::new();
    display.set_allow_overdraw(true);

    display
}

#[test]
fn selected_row_fills_the_longest_width_and_inverts_the_glyph() {
    let menu = Menu::<BinaryColor, 4, 2>::new_with_items(&["A", "AAAA"]).unwrap();
    let mut display = mock_display();
    menu.draw(&mut display).unwrap();

    assert_eq!(menu.bounding_box().size, Size::new(24, 21));

    let glyph_bounds = Rectangle::new(Point::new(2, 1), Size::new(5, 8));

    for point in Rectangle::new(Point::zero(), Size::new(24, 10)).points() {
        if !glyph_bounds.contains(point) {
            assert_eq!(display.get_pixel(point), Some(BinaryColor::On));
        }
    }

    let mut glyph_pixels = 0;

    for point in glyph_bounds.points() {
        let selected_color = display.get_pixel(point).unwrap();
        let normal_color = display.get_pixel(point + Point::new(0, 11)).unwrap();
        assert_eq!(selected_color, normal_color.invert());
        glyph_pixels += usize::from(selected_color == BinaryColor::Off);
    }

    assert!(glyph_pixels > 0 && glyph_pixels < 40);
    assert_eq!(display.get_pixel(Point::new(0, 10)), Some(BinaryColor::Off));
}

#[test]
fn navigation_wraps_and_only_activation_returns_an_index() {
    let mut menu = Menu::<BinaryColor, 5, 3>::new_with_items(&["One", "Two", "Three"]).unwrap();

    for expected_index in [1, 2, 0] {
        assert_eq!(menu.handle_action(MenuAction::NextItem), None);
        assert_eq!(menu.selected_index(), Some(expected_index));
    }

    for expected_index in [2, 1, 0] {
        assert_eq!(menu.handle_action(MenuAction::PreviousItem), None);
        assert_eq!(menu.selected_index(), Some(expected_index));
        assert_eq!(
            menu.handle_action(MenuAction::SelectItem),
            Some(expected_index)
        );
    }

    assert_eq!(menu.selected_item(), Some("One"));
}

#[test]
fn empty_and_single_item_menus_handle_every_action() {
    let mut empty = Menu::<BinaryColor, 1, 0>::new();
    let mut single = Menu::<BinaryColor, 1, 1>::new_with_items(&["A"]).unwrap();

    for action in [
        MenuAction::NextItem,
        MenuAction::PreviousItem,
        MenuAction::SelectItem,
    ] {
        assert_eq!(empty.handle_action(action), None);
        single.handle_action(action);
        assert_eq!(single.selected_index(), Some(0));
        assert_eq!(single.selected_item(), Some("A"));
    }

    let mut display = mock_display();
    empty.draw(&mut display).unwrap();

    assert_eq!(empty.selected_item(), None);
    assert_eq!(empty.bounding_box().size, Size::zero());
    assert_eq!(display.affected_area().size, Size::zero());
    assert_eq!(empty.add_item("A"), Err(MenuError::MenuFull));
}

#[test]
fn failed_additions_preserve_selection_and_do_not_consume_capacity() {
    let mut menu = Menu::<BinaryColor, 4, 2>::new_with_items(&["A"]).unwrap();
    let initial_bounds = menu.bounding_box();

    assert_eq!(menu.add_item("ééé"), Err(MenuError::ItemTooLong));
    assert_eq!(menu.selected_index(), Some(0));
    assert_eq!(menu.selected_item(), Some("A"));
    assert_eq!(menu.bounding_box(), initial_bounds);

    menu.add_item("éé").unwrap();
    menu.handle_action(MenuAction::NextItem);

    let mut before = mock_display();
    menu.draw(&mut before).unwrap();

    assert_eq!(menu.add_item("B"), Err(MenuError::MenuFull));
    assert_eq!(menu.selected_index(), Some(1));
    assert_eq!(menu.selected_item(), Some("éé"));

    let mut after = mock_display();
    menu.draw(&mut after).unwrap();

    assert_eq!(after, before);
}

#[test]
fn redrawing_selection_removes_the_previous_highlight_without_clearing() {
    let mut menu = Menu::<BinaryColor, 4, 2>::new_with_items(&["A", "BBBB"]).unwrap();
    let mut display = mock_display();
    menu.draw(&mut display).unwrap();

    assert_eq!(display.get_pixel(Point::zero()), Some(BinaryColor::On));

    menu.handle_action(MenuAction::NextItem);
    menu.draw(&mut display).unwrap();

    let mut fresh = mock_display();
    menu.draw(&mut fresh).unwrap();

    assert_eq!(display, fresh);
    assert_eq!(display.get_pixel(Point::zero()), Some(BinaryColor::Off));
    assert_eq!(display.get_pixel(Point::new(0, 11)), Some(BinaryColor::On));
}

#[test]
fn alignment_and_translation_place_all_drawing_inside_the_reported_bounds() {
    let menu = Menu::<BinaryColor, 2, 2>::new_with_items(&["A", "BB"])
        .unwrap()
        .align_to(
            &Rectangle::new(Point::new(4, 6), Size::new(50, 41)),
            horizontal::Center,
            vertical::Center,
        )
        .translate(Point::new(3, 5));
    let expected_bounds = Rectangle::new(Point::new(25, 21), Size::new(14, 21));
    let mut display = mock_display();
    menu.draw(&mut display).unwrap();

    assert_eq!(menu.bounding_box(), expected_bounds);
    assert_eq!(display.affected_area(), expected_bounds);
    assert_eq!(display.get_pixel(Point::new(24, 21)), None);
    assert_eq!(display.get_pixel(Point::new(39, 21)), None);
}

#[test]
fn custom_font_padding_spacing_and_rgb_colors_are_used_together() {
    let mut style = MenuStyle::new(&FONT_6X10, Rgb888::GREEN, Rgb888::BLUE);
    style.selected_text_color = Rgb888::RED;
    style.selected_background_color = Rgb888::WHITE;
    style.padding = Size::new(1, 2);
    style.spacing = 3;

    let mut menu = Menu::<Rgb888, 1, 2>::with_style(style);
    menu.add_item("A").unwrap();
    menu.add_item("A").unwrap();

    let mut display = mock_display();
    menu.draw(&mut display).unwrap();

    assert_eq!(menu.bounding_box().size, Size::new(8, 31));
    assert_eq!(display.get_pixel(Point::zero()), Some(Rgb888::WHITE));
    assert_eq!(display.get_pixel(Point::new(0, 16)), Some(Rgb888::BLUE));
    assert_eq!(display.get_pixel(Point::new(0, 17)), Some(Rgb888::BLUE));

    let mut glyph_pixels = 0;

    for point in Rectangle::new(Point::new(1, 2), Size::new(6, 10)).points() {
        let selected_color = display.get_pixel(point).unwrap();
        let expected_normal_color = if selected_color == Rgb888::RED {
            glyph_pixels += 1;
            Rgb888::GREEN
        } else {
            assert_eq!(selected_color, Rgb888::WHITE);
            Rgb888::BLUE
        };

        assert_eq!(
            display.get_pixel(point + Point::new(0, 17)),
            Some(expected_normal_color)
        );
    }

    assert!(glyph_pixels > 0);
}

#[test]
fn blank_lines_reserve_space_before_the_following_row() {
    let menu = Menu::<BinaryColor, 3, 2>::new_with_items(&["\nA\n", "B"]).unwrap();
    let mut display = mock_display();
    menu.draw(&mut display).unwrap();

    let expected_bounds = Rectangle::new(Point::zero(), Size::new(9, 37));
    assert_eq!(menu.bounding_box(), expected_bounds);
    assert_eq!(display.affected_area(), expected_bounds);
    assert_eq!(display.get_pixel(Point::new(0, 25)), Some(BinaryColor::On));
    assert_eq!(display.get_pixel(Point::new(0, 26)), Some(BinaryColor::Off));
    assert_eq!(display.get_pixel(Point::new(0, 27)), Some(BinaryColor::Off));

    let first_blank_line = Rectangle::new(Point::new(2, 1), Size::new(5, 8));
    let last_blank_line = Rectangle::new(Point::new(2, 17), Size::new(5, 8));

    for point in first_blank_line.points().chain(last_blank_line.points()) {
        assert_eq!(display.get_pixel(point), Some(BinaryColor::On));
    }

    assert!(
        Rectangle::new(Point::new(2, 9), Size::new(5, 8))
            .points()
            .any(|point| display.get_pixel(point) == Some(BinaryColor::Off))
    );
}

#[test]
fn item_alignment_positions_labels_inside_translated_padded_rows() {
    for (font, row_size, short_offsets) in [
        (&FONT_5X8, Size::new(21, 12), [0, 5, 10]),
        (&FONT_6X10, Size::new(24, 14), [0, 6, 12]),
    ] {
        for (alignment, short_offset) in [Alignment::Left, Alignment::Center, Alignment::Right]
            .into_iter()
            .zip(short_offsets)
        {
            let style = MenuStyle {
                font,
                text_alignment: alignment,
                padding: Size::new(3, 2),
                spacing: 2,
                ..Default::default()
            };

            let menu = Menu::<BinaryColor, 3, 2>::new_with_items(&["A", "AAA"])
                .unwrap()
                .set_style(style)
                .translate(Point::new(4, 3));
            let expected_bounds = Rectangle::new(
                Point::new(4, 3),
                Size::new(row_size.width, row_size.height * 2 + 2),
            );
            let mut display = mock_display();
            menu.draw(&mut display).unwrap();

            let mut expected = mock_display();
            expected
                .fill_solid(&expected_bounds, BinaryColor::Off)
                .unwrap();
            expected
                .fill_solid(&Rectangle::new(Point::new(4, 3), row_size), BinaryColor::On)
                .unwrap();

            Text::with_baseline(
                "A",
                Point::new(7 + short_offset, 5),
                MonoTextStyle::new(font, BinaryColor::Off),
                Baseline::Top,
            )
            .draw(&mut expected)
            .unwrap();

            Text::with_baseline(
                "AAA",
                Point::new(7, 7 + row_size.height as i32),
                MonoTextStyle::new(font, BinaryColor::On),
                Baseline::Top,
            )
            .draw(&mut expected)
            .unwrap();

            assert_eq!(menu.bounding_box(), expected_bounds);
            assert_eq!(display.affected_area(), expected_bounds);
            assert_eq!(display, expected, "alignment {alignment:?}, font {font:?}");
        }
    }
}

#[test]
fn multiline_item_alignment_handles_each_line_and_preserves_blank_lines() {
    for (alignment, short_x, longer_x) in [
        (Alignment::Left, 5, 5),
        (Alignment::Center, 12, 10),
        (Alignment::Right, 20, 15),
    ] {
        let style = MenuStyle {
            text_alignment: alignment,
            ..Default::default()
        };

        let menu = Menu::<BinaryColor, 7, 2>::new_with_items(&["\nA\r\nBB\n", "AAAA"])
            .unwrap()
            .set_style(style)
            .translate(Point::new(3, 4));
        let expected_bounds = Rectangle::new(Point::new(3, 4), Size::new(24, 45));
        let mut display = mock_display();
        menu.draw(&mut display).unwrap();

        let mut expected = mock_display();
        expected
            .fill_solid(&expected_bounds, BinaryColor::Off)
            .unwrap();
        expected
            .fill_solid(
                &Rectangle::new(Point::new(3, 4), Size::new(24, 34)),
                BinaryColor::On,
            )
            .unwrap();

        for (label, position, color) in [
            ("A", Point::new(short_x, 13), BinaryColor::Off),
            ("BB", Point::new(longer_x, 21), BinaryColor::Off),
            ("AAAA", Point::new(5, 40), BinaryColor::On),
        ] {
            Text::with_baseline(
                label,
                position,
                MonoTextStyle::new(&FONT_5X8, color),
                Baseline::Top,
            )
            .draw(&mut expected)
            .unwrap();
        }

        assert_eq!(menu.bounding_box(), expected_bounds);
        assert_eq!(display.affected_area(), expected_bounds);
        assert_eq!(display, expected, "alignment {alignment:?}");
    }
}

#[test]
fn changing_item_alignment_and_selection_repaints_the_same_bounds() {
    let mut menu = Menu::<BinaryColor, 4, 2>::new_with_items(&["A", "AAAA"])
        .unwrap()
        .translate(Point::new(3, 4));
    let original_bounds = menu.bounding_box();
    let mut display = mock_display();
    menu.draw(&mut display).unwrap();

    menu = menu.set_style(MenuStyle {
        text_alignment: Alignment::Right,
        ..Default::default()
    });

    menu.select_next();
    menu.draw(&mut display).unwrap();

    let mut fresh = mock_display();
    menu.draw(&mut fresh).unwrap();

    assert_eq!(menu.bounding_box(), original_bounds);
    assert_eq!(display.affected_area(), original_bounds);
    assert_eq!(display, fresh);
}

#[test]
fn input_focus_changes_only_its_value_and_repaints_when_navigation_moves() {
    let input = TextInput::new("Name", "abc", true).unwrap();
    let mut menu = Menu::<BinaryColor, 4, 2>::new();
    menu.add_text_input(input).unwrap();
    menu.add_item("Back").unwrap();

    let mut focused = mock_display();
    menu.draw(&mut focused).unwrap();

    menu.select_next();
    let mut unfocused = mock_display();
    menu.draw(&mut unfocused).unwrap();

    // The label occupies the left of the row and must never be highlighted.
    for point in Rectangle::new(Point::zero(), Size::new(24, 10)).points() {
        assert_eq!(focused.get_pixel(point), unfocused.get_pixel(point));
    }

    // The full value box, including glyphs, uses the same inversion as actions.
    for point in Rectangle::new(Point::new(24, 0), Size::new(24, 10)).points() {
        assert_eq!(
            focused.get_pixel(point),
            unfocused.get_pixel(point).map(BinaryColor::invert)
        );
    }

    assert_eq!(focused.get_pixel(Point::new(24, 0)), Some(BinaryColor::On));
    assert_eq!(
        unfocused.get_pixel(Point::new(24, 0)),
        Some(BinaryColor::Off)
    );
    assert_eq!(
        unfocused.get_pixel(Point::new(0, 11)),
        Some(BinaryColor::On)
    );

    menu.draw(&mut focused).unwrap();
    assert_eq!(focused, unfocused);
}

#[test]
fn selecting_an_input_starts_editing_and_locks_menu_navigation() {
    let mut menu = Menu::<BinaryColor, 4, 2>::new();
    menu.add_item("Back").unwrap();
    menu.add_text_input(TextInput::new("Name", "abc", true).unwrap())
        .unwrap();

    menu.select_next();
    assert_eq!(menu.selected_item(), Some("Name"));
    assert_eq!(menu.select_item(), None);
    assert!(menu.is_editing());

    menu.select_next();
    menu.select_previous();
    assert_eq!(menu.selected_index(), Some(1));

    let input = menu.selected_text_input_mut().unwrap();
    input.increment();
    input.cancel_edit();
    assert_eq!(menu.text_input(1).unwrap().value(), "abc");

    menu.select_next();
    assert_eq!(menu.select_item(), Some(0));
}

#[test]
fn selecting_a_read_only_input_leaves_menu_navigation_available() {
    let mut menu = Menu::<BinaryColor, 4, 2>::new();
    menu.add_text_input(TextInput::new("Name", "abc", false).unwrap())
        .unwrap();
    menu.add_item("Back").unwrap();

    assert_eq!(menu.select_item(), None);
    assert!(!menu.is_editing());

    menu.select_next();
    assert_eq!(menu.select_item(), Some(1));
    assert_eq!(menu.text_input(0).unwrap().value(), "abc");
}

#[test]
fn menu_editor_uses_menu_style_and_fills_the_display_instead_of_a_row() {
    let mut style = MenuStyle::new(&FONT_6X10, Rgb888::GREEN, Rgb888::BLUE);
    style.padding = Size::new(1, 1);

    let mut menu = Menu::<Rgb888, 4, 2>::with_style(style);
    menu.add_text_input(
        TextInput::with_style(
            "Name",
            "abc",
            true,
            MenuStyle::new(&FONT_5X8, Rgb888::RED, Rgb888::WHITE),
        )
        .unwrap(),
    )
    .unwrap();

    menu.select_item();
    let mut display = mock_display();
    menu.draw(&mut display).unwrap();

    assert_eq!(display.affected_area(), display.bounding_box());
    assert_eq!(display.get_pixel(Point::zero()), Some(Rgb888::BLUE));

    for point in display.bounding_box().points() {
        assert!(matches!(
            display.get_pixel(point),
            Some(Rgb888::GREEN | Rgb888::BLUE)
        ));
    }
}
