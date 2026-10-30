use embedded_graphics::{
    Drawable,
    draw_target::{DrawTarget, DrawTargetExt},
    geometry::{Dimensions, Point, Size},
    mock_display::MockDisplay,
    mono_font::{MonoTextStyle, ascii::FONT_5X8},
    pixelcolor::{BinaryColor, PixelColor, Rgb888, RgbColor},
    primitives::{PointsIter, Rectangle},
    text::{Baseline, Text},
    transform::Transform,
};

use crate::ui::text_editor::ALPHABET;

use super::{MenuStyle, TextInput, TextInputError};

fn mock_display<C: PixelColor>() -> MockDisplay<C> {
    let mut display = MockDisplay::new();
    display.set_allow_overdraw(true);

    display
}

#[test]
fn public_controls_can_spell_abc_and_wrap_at_capacity() {
    let mut input = TextInput::<BinaryColor, 3>::new("Key", "", true).unwrap();

    assert_eq!(input.selected_character(), None);
    assert!(!input.increment());
    assert!(!input.decrement());
    assert!(!input.next_character());
    assert!(!input.previous_character());
    assert!(input.begin_edit());
    assert!(!input.begin_edit());
    assert_eq!(input.selected_character(), Some(0));
    assert!(!input.next_character());
    assert!(input.increment());
    assert_eq!(input.value(), "a");
    assert!(input.next_character());
    assert!(input.increment());
    assert!(input.increment());
    assert_eq!(input.value(), "ab");
    assert!(input.next_character());
    assert!(input.increment());
    assert!(input.increment());
    assert!(input.increment());
    assert_eq!(input.value(), "abc");
    assert!(input.next_character());
    assert_eq!(input.selected_character(), Some(0));
    assert!(input.previous_character());
    assert_eq!(input.selected_character(), Some(2));
    assert!(input.finish_edit());
    assert_eq!(input.value(), "abc");
    assert_eq!(input.selected_character(), None);
    assert!(!input.finish_edit());
    assert!(!input.cancel_edit());
}

#[test]
fn cancellation_restores_the_entire_original_and_finish_updates_it() {
    let mut input = TextInput::<BinaryColor, 8>::new("Name", "Player", true).unwrap();
    input.begin_edit();
    input.increment();
    input.previous_character();
    input.increment();

    assert_eq!(input.value(), "Qlayera");
    assert!(input.cancel_edit());
    assert_eq!(input.value(), "Player");
    assert!(input.begin_edit());
    assert_eq!(input.selected_character(), Some(0));
    input.increment();
    input.finish_edit();
    input.begin_edit();
    input.increment();
    input.cancel_edit();

    assert_eq!(input.value(), "Qlayer");
}

#[test]
fn read_only_fields_ignore_editing_and_disabling_editing_accepts_the_draft() {
    let mut input = TextInput::<BinaryColor, 4>::new("Name", "a", false).unwrap();

    assert!(!input.is_editable());
    assert!(!input.begin_edit());
    assert!(!input.is_editing());
    assert!(!input.increment());
    assert!(!input.previous_character());
    assert_eq!(input.value(), "a");

    input.set_editable(true);
    assert!(input.begin_edit());
    input.increment();
    input.set_editable(false);

    assert!(!input.is_editing());
    assert!(!input.is_editable());
    assert_eq!(input.value(), "b");
    assert!(!input.cancel_edit());
}

#[test]
fn invalid_updates_preserve_the_draft_cursor_and_cancellation_baseline() {
    let mut input = TextInput::<BinaryColor, 4>::new("Name", "ab", true).unwrap();
    input.begin_edit();
    input.next_character();
    input.increment();

    for (invalid, expected_error) in [
        ("abcde", TextInputError::ValueTooLong),
        ("é", TextInputError::UnsupportedCharacter),
        ("a\nb", TextInputError::UnsupportedCharacter),
        ("a\0b", TextInputError::UnsupportedCharacter),
    ] {
        assert_eq!(input.set_value(invalid), Err(expected_error));
        assert_eq!(input.value(), "ac");
        assert_eq!(input.selected_character(), Some(1));
        assert!(input.is_editing());
    }

    input.cancel_edit();
    assert_eq!(input.value(), "ab");

    assert!(matches!(
        TextInput::<BinaryColor, 3>::new("Name", "a", true),
        Err(TextInputError::LabelTooLong)
    ));
    assert!(matches!(
        TextInput::<BinaryColor, 4>::new("N\n", "a", true),
        Err(TextInputError::UnsupportedCharacter)
    ));
}

#[test]
fn setting_a_value_while_editing_resets_the_cursor_and_cancellation_baseline() {
    let mut input = TextInput::<BinaryColor, 4>::new("Name", "abc", true).unwrap();
    input.begin_edit();
    input.increment();
    input.next_character();
    input.set_value("xy").unwrap();

    assert!(input.is_editing());
    assert_eq!(input.value(), "xy");
    assert_eq!(input.selected_character(), Some(0));
    input.increment();
    assert_eq!(input.value(), "yy");
    assert!(input.cancel_edit());
    assert_eq!(input.value(), "xy");
}

#[test]
fn deleting_characters_can_shorten_or_clear_a_value_and_cancel_restores_it() {
    let mut input = TextInput::<BinaryColor, 3>::new("Key", "abc", true).unwrap();
    assert!(!input.delete_character());
    input.begin_edit();
    input.next_character();

    assert!(input.delete_character());
    assert_eq!(input.value(), "ac");
    assert_eq!(input.selected_character(), Some(1));
    assert!(input.delete_character());
    assert_eq!(input.value(), "a");
    assert_eq!(input.selected_character(), Some(1));
    assert!(!input.delete_character());
    input.previous_character();
    assert!(input.delete_character());
    assert_eq!(input.value(), "");
    assert_eq!(input.selected_character(), Some(0));
    assert!(!input.delete_character());
    assert!(input.increment());
    assert_eq!(input.value(), "a");
    input.cancel_edit();

    assert_eq!(input.value(), "abc");
}

#[test]
fn alphabet_covers_each_printable_ascii_character_once_and_wraps() {
    assert_eq!(ALPHABET.len(), 95);

    for character in b' '..=b'~' {
        assert_eq!(
            ALPHABET.iter().filter(|entry| **entry == character).count(),
            1
        );
    }

    let mut input = TextInput::<BinaryColor, 1>::new("", "~", true).unwrap();
    input.begin_edit();
    input.increment();
    assert_eq!(input.value(), " ");
    input.decrement();
    assert_eq!(input.value(), "~");
    assert!(!input.next_character());
    assert!(!input.previous_character());
}

#[test]
fn zero_capacity_and_empty_values_have_defined_behavior() {
    let mut zero_capacity = TextInput::<BinaryColor, 0>::new("", "", true).unwrap();
    assert!(!zero_capacity.begin_edit());
    assert_eq!(zero_capacity.selected_character(), None);
    assert!(!zero_capacity.increment());
    assert!(!zero_capacity.next_character());
    zero_capacity.draw(&mut mock_display()).unwrap();

    let mut empty = TextInput::<BinaryColor, 2>::new("", "", true).unwrap();
    assert!(empty.begin_edit());
    assert!(!empty.previous_character());
    assert!(empty.decrement());
    assert_eq!(empty.value(), "~");
    assert!(empty.previous_character());
    assert_eq!(empty.selected_character(), Some(1));
}

#[test]
fn normal_focus_inverts_only_the_value_and_keeps_row_dimensions_stable() {
    let mut input = TextInput::<BinaryColor, 4>::new("Name", "ab", true)
        .unwrap()
        .translate(Point::new(4, 3));
    let original_bounds = input.bounding_box();
    let mut unfocused = mock_display();
    input.draw(&mut unfocused).unwrap();
    input.set_focused(true);

    let mut focused = mock_display();
    input.draw(&mut focused).unwrap();

    assert_eq!(
        original_bounds,
        Rectangle::new(Point::new(4, 3), Size::new(50, 10))
    );
    assert_eq!(focused.get_pixel(Point::new(28, 3)), Some(BinaryColor::On));
    assert_eq!(
        unfocused.get_pixel(Point::new(28, 3)),
        Some(BinaryColor::Off)
    );

    for y in 3..13 {
        for x in 4..28 {
            let point = Point::new(x, y);
            assert_eq!(focused.get_pixel(point), unfocused.get_pixel(point));
        }
    }

    for point in Rectangle::new(Point::new(30, 4), Size::new(10, 8)).points() {
        assert_eq!(
            focused.get_pixel(point),
            unfocused.get_pixel(point).map(BinaryColor::invert)
        );
    }

    input.set_value("abcd").unwrap();
    assert_eq!(input.bounding_box(), original_bounds);
    input.set_value("").unwrap();
    assert_eq!(input.bounding_box(), original_bounds);
}

#[test]
fn editing_hides_the_label_and_centers_the_value_with_one_inverted_character() {
    let mut input = TextInput::<BinaryColor, 4>::new("Name", "ab", true).unwrap();
    input.begin_edit();

    let viewport = Rectangle::new(Point::new(8, 10), Size::new(36, 20));
    let mut display = mock_display();
    input.draw(&mut display.clipped(&viewport)).unwrap();

    let mut expected = mock_display();
    expected.fill_solid(&viewport, BinaryColor::Off).unwrap();
    expected
        .fill_solid(
            &Rectangle::new(Point::new(17, 15), Size::new(9, 10)),
            BinaryColor::On,
        )
        .unwrap();

    for (character, position, color) in [
        ("a", Point::new(19, 16), BinaryColor::Off),
        ("b", Point::new(28, 16), BinaryColor::On),
    ] {
        Text::with_baseline(
            character,
            position,
            MonoTextStyle::new(&FONT_5X8, color),
            Baseline::Top,
        )
        .draw(&mut expected)
        .unwrap();
    }

    assert_eq!(display, expected);
    assert_eq!(display.affected_area(), viewport);
}

#[test]
fn append_focus_keeps_the_value_centered_when_it_fits_and_scrolls_when_needed() {
    let mut input = TextInput::<BinaryColor, 4>::new("Name", "ab", true).unwrap();
    input.begin_edit();
    input.previous_character();

    let viewport = Rectangle::new(Point::new(8, 10), Size::new(36, 20));
    let mut display = mock_display();
    input.draw(&mut display.clipped(&viewport)).unwrap();

    let mut expected = mock_display();
    expected.fill_solid(&viewport, BinaryColor::Off).unwrap();

    for (character, position) in [("a", Point::new(19, 16)), ("b", Point::new(28, 16))] {
        Text::with_baseline(
            character,
            position,
            MonoTextStyle::new(&FONT_5X8, BinaryColor::On),
            Baseline::Top,
        )
        .draw(&mut expected)
        .unwrap();
    }

    expected
        .fill_solid(
            &Rectangle::new(Point::new(35, 15), Size::new(9, 10)),
            BinaryColor::On,
        )
        .unwrap();

    assert_eq!(display, expected);

    let narrow_viewport = Rectangle::new(Point::new(8, 10), Size::new(18, 20));
    let mut narrow_display = mock_display();
    input
        .draw(&mut narrow_display.clipped(&narrow_viewport))
        .unwrap();

    for point in Rectangle::new(Point::new(17, 15), Size::new(9, 10)).points() {
        assert_eq!(narrow_display.get_pixel(point), Some(BinaryColor::On));
    }

    assert_eq!(input.selected_character(), Some(2));
    assert_eq!(narrow_display.affected_area(), narrow_viewport);
}

#[test]
fn editor_scrolls_to_the_cursor_and_repaints_old_focus() {
    let mut input = TextInput::<BinaryColor, 8>::new("Name", "abcdefgh", true).unwrap();
    input.begin_edit();

    let viewport = Rectangle::new(Point::new(4, 5), Size::new(18, 12));
    let mut display = mock_display();
    input.draw(&mut display.clipped(&viewport)).unwrap();
    input.previous_character();
    input.draw(&mut display.clipped(&viewport)).unwrap();

    let mut fresh = mock_display();
    input.draw(&mut fresh.clipped(&viewport)).unwrap();

    assert_eq!(input.selected_character(), Some(7));
    assert_eq!(display, fresh);
    assert_eq!(display.affected_area(), viewport);
    assert_eq!(display.get_pixel(Point::new(13, 6)), Some(BinaryColor::On));
    assert_eq!(display.get_pixel(Point::new(4, 6)), Some(BinaryColor::Off));
    assert_eq!(display.get_pixel(Point::new(22, 6)), None);
}

#[test]
fn empty_editor_and_tiny_targets_are_clipped_without_panicking() {
    let mut input = TextInput::<BinaryColor, 4>::new("Name", "", true).unwrap();
    input.begin_edit();

    for size in [
        Size::zero(),
        Size::new(1, 1),
        Size::new(5, 3),
        Size::new(12, 12),
    ] {
        let viewport = Rectangle::new(Point::new(4, 5), size);
        let mut display = mock_display();
        input.draw(&mut display.clipped(&viewport)).unwrap();

        if size.width > 0 && size.height > 0 {
            assert_eq!(display.affected_area(), viewport);
        }

        if size.width > 0 && size.width <= 5 {
            assert_eq!(display.get_pixel(Point::new(4, 5)), Some(BinaryColor::On));
            assert_eq!(
                display.get_pixel(Point::new(3 + size.width as i32, 4 + size.height as i32)),
                Some(BinaryColor::On)
            );
        }
    }
}

#[test]
fn empty_input_centers_its_single_blank_cursor() {
    let mut input = TextInput::<BinaryColor, 4>::new("Name", "", true).unwrap();
    input.begin_edit();

    let viewport = Rectangle::new(Point::new(4, 5), Size::new(12, 12));
    let mut display = mock_display();
    input.draw(&mut display.clipped(&viewport)).unwrap();

    let mut expected = mock_display();
    expected.fill_solid(&viewport, BinaryColor::Off).unwrap();
    expected
        .fill_solid(
            &Rectangle::new(Point::new(5, 6), Size::new(9, 10)),
            BinaryColor::On,
        )
        .unwrap();

    assert_eq!(display, expected);
}

#[test]
fn custom_selected_colors_apply_to_the_value_and_active_character_only() {
    let mut style = MenuStyle::new(&FONT_5X8, Rgb888::GREEN, Rgb888::BLUE);
    style.selected_text_color = Rgb888::RED;
    style.selected_background_color = Rgb888::WHITE;

    let mut input = TextInput::<Rgb888, 4>::with_style("Name", "ab", true, style).unwrap();
    input.set_focused(true);

    let mut row = mock_display();
    input.draw(&mut row).unwrap();

    let mut expected_row = mock_display();
    expected_row
        .fill_solid(&input.bounding_box(), Rgb888::BLUE)
        .unwrap();
    expected_row
        .fill_solid(
            &Rectangle::new(Point::new(24, 0), Size::new(24, 10)),
            Rgb888::WHITE,
        )
        .unwrap();

    for (text, position, color) in [
        ("Name", Point::new(2, 1), Rgb888::GREEN),
        ("ab", Point::new(26, 1), Rgb888::RED),
    ] {
        Text::with_baseline(
            text,
            position,
            MonoTextStyle::new(&FONT_5X8, color),
            Baseline::Top,
        )
        .draw(&mut expected_row)
        .unwrap();
    }

    assert_eq!(row, expected_row);
    input.begin_edit();

    let viewport = Rectangle::new(Point::new(8, 10), Size::new(36, 20));
    let mut editor = mock_display();
    input.draw(&mut editor.clipped(&viewport)).unwrap();

    let mut expected_editor = mock_display();
    expected_editor.fill_solid(&viewport, Rgb888::BLUE).unwrap();
    expected_editor
        .fill_solid(
            &Rectangle::new(Point::new(17, 15), Size::new(9, 10)),
            Rgb888::WHITE,
        )
        .unwrap();

    for (text, position, color) in [
        ("a", Point::new(19, 16), Rgb888::RED),
        ("b", Point::new(28, 16), Rgb888::GREEN),
    ] {
        Text::with_baseline(
            text,
            position,
            MonoTextStyle::new(&FONT_5X8, color),
            Baseline::Top,
        )
        .draw(&mut expected_editor)
        .unwrap();
    }

    assert_eq!(editor, expected_editor);
}
