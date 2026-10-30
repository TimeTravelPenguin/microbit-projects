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
use heapless::String;

use super::{EditOutcome, Menu, MenuAction, MenuError, MenuStyle, MenuUpdate};
use crate::ui::{LABEL_CAPACITY, TextInput, TextInputError};

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
        assert_eq!(
            menu.handle_action(MenuAction::NextItem, &())
                .unwrap()
                .command,
            None
        );
        assert_eq!(menu.selected_index(), Some(expected_index));
    }

    for expected_index in [2, 1, 0] {
        assert_eq!(
            menu.handle_action(MenuAction::PreviousItem, &())
                .unwrap()
                .command,
            None
        );
        assert_eq!(menu.selected_index(), Some(expected_index));
        assert_eq!(
            menu.handle_action(MenuAction::SelectItem, &())
                .unwrap()
                .command,
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
        assert_eq!(empty.handle_action(action, &()).unwrap().command, None);
        let _ = single.handle_action(action, &()).unwrap();
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
    let label_bytes = [b'A'; LABEL_CAPACITY + 1];
    let overlong_label = core::str::from_utf8(&label_bytes).unwrap();

    assert_eq!(menu.add_item(overlong_label), Err(MenuError::ItemTooLong));
    assert_eq!(menu.selected_index(), Some(0));
    assert_eq!(menu.selected_item(), Some("A"));
    assert_eq!(menu.bounding_box(), initial_bounds);

    menu.add_item("ééé").unwrap();
    let _ = menu.handle_action(MenuAction::NextItem, &()).unwrap();

    let mut before = mock_display();
    menu.draw(&mut before).unwrap();

    assert_eq!(menu.add_item("B"), Err(MenuError::MenuFull));
    assert_eq!(menu.selected_index(), Some(1));
    assert_eq!(menu.selected_item(), Some("ééé"));

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

    let _ = menu.handle_action(MenuAction::NextItem, &()).unwrap();
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

#[derive(Debug, PartialEq, Eq)]
struct FieldModel {
    name: String<4>,
    tag: String<4>,
}

#[derive(Clone, Debug, PartialEq, Eq)]
enum FieldCommand {
    SetName(String<4>),
    SetTag(String<4>),
    Back,
}

fn field_model() -> FieldModel {
    FieldModel {
        name: "abc".try_into().unwrap(),
        tag: "xyz".try_into().unwrap(),
    }
}

fn apply_command(model: &mut FieldModel, command: FieldCommand) {
    match command {
        FieldCommand::SetName(value) => model.name = value,
        FieldCommand::SetTag(value) => model.tag = value,
        FieldCommand::Back => {}
    }
}

#[test]
fn action_and_field_labels_share_the_global_capacity() {
    let model = field_model();
    let mut menu = Menu::<BinaryColor, 4, 3, FieldModel, FieldCommand>::new();
    let label_bytes = [b'A'; LABEL_CAPACITY + 1];
    let label = core::str::from_utf8(&label_bytes).unwrap();
    let longest_label = &label[..LABEL_CAPACITY];

    assert_eq!(
        menu.add_action(label, FieldCommand::Back),
        Err(MenuError::ItemTooLong)
    );
    assert_eq!(
        menu.add_text_field(label, |model| &model.name, FieldCommand::SetName),
        Err(MenuError::TextInput(TextInputError::LabelTooLong))
    );
    assert_eq!(
        menu.add_read_only_field(label, |model| &model.name),
        Err(MenuError::TextInput(TextInputError::LabelTooLong))
    );
    assert_eq!(menu.selected_index(), None);

    menu.add_action(longest_label, FieldCommand::Back).unwrap();
    menu.add_text_field(longest_label, |model| &model.name, FieldCommand::SetName)
        .unwrap();
    menu.add_read_only_field(longest_label, |model| &model.tag)
        .unwrap();

    assert!(menu.items.iter().all(|item| item.label() == longest_label));
    assert_eq!(menu.selected_index(), Some(0));
    assert_eq!(menu.validate_model(&model), Ok(()));
}

#[test]
fn input_focus_changes_only_its_value_and_repaints_when_navigation_moves() {
    let model = field_model();
    let mut menu = Menu::<BinaryColor, 4, 2, FieldModel, FieldCommand>::new();
    menu.add_text_field("Name", |model| &model.name, FieldCommand::SetName)
        .unwrap();
    menu.add_action("Back", FieldCommand::Back).unwrap();

    let mut focused = mock_display();
    menu.view(&model).draw(&mut focused).unwrap();

    assert_eq!(
        menu.handle_action(MenuAction::NextItem, &model).unwrap(),
        MenuUpdate {
            redraw: true,
            command: None,
        }
    );

    let mut unfocused = mock_display();
    menu.view(&model).draw(&mut unfocused).unwrap();

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

    menu.view(&model).draw(&mut focused).unwrap();
    assert_eq!(focused, unfocused);
}

#[test]
fn selecting_an_input_starts_editing_and_locks_menu_navigation() {
    let model = field_model();
    let mut menu = Menu::<BinaryColor, 4, 2, FieldModel, FieldCommand>::new();
    menu.add_action("Back", FieldCommand::Back).unwrap();
    menu.add_text_field("Name", |model| &model.name, FieldCommand::SetName)
        .unwrap();

    let _ = menu.handle_action(MenuAction::NextItem, &model).unwrap();
    assert_eq!(menu.selected_item(), Some("Name"));
    assert_eq!(
        menu.handle_action(MenuAction::SelectItem, &model).unwrap(),
        MenuUpdate {
            redraw: true,
            command: None,
        }
    );

    assert!(menu.is_editing());

    for action in [MenuAction::NextItem, MenuAction::PreviousItem] {
        assert_eq!(
            menu.handle_action(action, &model).unwrap(),
            MenuUpdate::default()
        );
    }

    assert_eq!(menu.selected_index(), Some(1));

    let _ = menu.handle_action(MenuAction::Increment, &model).unwrap();
    let _ = menu.handle_action(MenuAction::Back, &model).unwrap();
    assert_eq!(model.name, "abc");
    assert!(!menu.is_editing());

    let _ = menu.handle_action(MenuAction::NextItem, &model).unwrap();
    assert_eq!(
        menu.handle_action(MenuAction::SelectItem, &model).unwrap(),
        MenuUpdate {
            redraw: false,
            command: Some(FieldCommand::Back),
        }
    );
}

#[test]
fn selecting_a_read_only_input_leaves_menu_navigation_available() {
    let model = field_model();
    let mut menu = Menu::<BinaryColor, 4, 2, FieldModel, FieldCommand>::new();
    menu.add_read_only_field("Name", |model| &model.name)
        .unwrap();
    menu.add_action("Back", FieldCommand::Back).unwrap();

    assert_eq!(
        menu.handle_action(MenuAction::SelectItem, &model).unwrap(),
        MenuUpdate::default()
    );

    assert!(!menu.is_editing());

    let _ = menu.handle_action(MenuAction::NextItem, &model).unwrap();
    assert_eq!(
        menu.handle_action(MenuAction::SelectItem, &model)
            .unwrap()
            .command,
        Some(FieldCommand::Back)
    );

    assert_eq!(model.name, "abc");
}

#[test]
fn menu_editor_uses_menu_style_and_fills_the_display_instead_of_a_row() {
    let mut style = MenuStyle::new(&FONT_6X10, Rgb888::GREEN, Rgb888::BLUE);
    style.padding = Size::new(1, 1);

    let model = field_model();
    let mut menu = Menu::<Rgb888, 4, 2, FieldModel, FieldCommand>::with_style(style);
    menu.add_text_field("Name", |model| &model.name, FieldCommand::SetName)
        .unwrap();

    let _ = menu.handle_action(MenuAction::SelectItem, &model).unwrap();
    let mut display = mock_display();
    menu.view(&model).draw(&mut display).unwrap();

    assert_eq!(display.affected_area(), display.bounding_box());
    assert_eq!(display.get_pixel(Point::zero()), Some(Rgb888::BLUE));

    for point in display.bounding_box().points() {
        assert!(matches!(
            display.get_pixel(point),
            Some(Rgb888::GREEN | Rgb888::BLUE)
        ));
    }
}

#[test]
fn editing_routes_commands_to_the_selected_binding_and_leaves_the_model_to_the_caller() {
    let mut model = field_model();
    let mut menu = Menu::<BinaryColor, 4, 3, FieldModel, FieldCommand>::new();
    menu.add_action("Back", FieldCommand::Back).unwrap();
    menu.add_text_field("Tag", |model| &model.tag, FieldCommand::SetTag)
        .unwrap();
    menu.add_text_field("Name", |model| &model.name, FieldCommand::SetName)
        .unwrap();

    let changed = MenuUpdate {
        redraw: true,
        command: None,
    };

    assert_eq!(
        menu.handle_action(MenuAction::NextItem, &model).unwrap(),
        changed
    );
    assert_eq!(
        menu.handle_action(MenuAction::SelectItem, &model).unwrap(),
        changed
    );
    assert_eq!(menu.editor().unwrap().original_value(), "xyz");

    for action in [MenuAction::NextItem, MenuAction::PreviousItem] {
        assert_eq!(
            menu.handle_action(action, &model).unwrap(),
            MenuUpdate::default()
        );
    }

    menu.set_selected_index(Some(2));
    assert_eq!(menu.selected_index(), Some(1));

    for action in [
        MenuAction::Increment,
        MenuAction::NextCharacter,
        MenuAction::Increment,
        MenuAction::PreviousCharacter,
        MenuAction::Decrement,
        MenuAction::DeleteCharacter,
    ] {
        assert_eq!(menu.handle_action(action, &model).unwrap(), changed);
    }

    assert_eq!(menu.editor().unwrap().value(), "zz");
    assert_eq!(model, field_model());
    assert_eq!(
        menu.handle_action(MenuAction::Back, &model).unwrap(),
        changed
    );
    assert!(menu.editor().is_none());
    assert_eq!(model, field_model());

    assert_eq!(
        menu.handle_action(MenuAction::SelectItem, &model).unwrap(),
        changed
    );
    assert_eq!(menu.editor().unwrap().value(), "xyz");
    assert_eq!(
        menu.handle_action(MenuAction::Decrement, &model).unwrap(),
        changed
    );

    let accepted = menu.handle_action(MenuAction::FinishEdit, &model).unwrap();
    assert_eq!(
        accepted,
        MenuUpdate {
            redraw: true,
            command: Some(FieldCommand::SetTag("wyz".try_into().unwrap())),
        }
    );

    assert_eq!(model, field_model());
    apply_command(&mut model, accepted.command.unwrap());
    assert_eq!(model.tag, "wyz");
    assert_eq!(model.name, "abc");
    assert_eq!(
        menu.handle_action(MenuAction::FinishEdit, &model).unwrap(),
        MenuUpdate::default()
    );

    assert_eq!(
        menu.handle_action(MenuAction::NextItem, &model).unwrap(),
        changed
    );
    assert_eq!(menu.selected_index(), Some(2));
    assert_eq!(
        menu.handle_action(MenuAction::SelectItem, &model).unwrap(),
        changed
    );
    assert_eq!(
        menu.handle_action(MenuAction::Increment, &model).unwrap(),
        changed
    );

    let outcome = menu.finish_edit();
    assert_eq!(
        outcome,
        EditOutcome::Accepted(FieldCommand::SetName("bbc".try_into().unwrap()))
    );

    let EditOutcome::Accepted(command) = outcome else {
        panic!("A changed draft must produce its field's command");
    };

    apply_command(&mut model, command);
    assert_eq!(model.name, "bbc");
    assert_eq!(model.tag, "wyz");
    assert_eq!(menu.finish_edit(), EditOutcome::Inactive);

    assert_eq!(
        menu.handle_action(MenuAction::SelectItem, &model).unwrap(),
        changed
    );
    assert_eq!(
        menu.handle_action(MenuAction::FinishEdit, &model).unwrap(),
        changed
    );
    assert!(!menu.is_editing());
    assert_eq!(
        menu.handle_action(MenuAction::FinishEdit, &model).unwrap(),
        MenuUpdate::default()
    );
}

#[test]
fn views_and_new_edits_read_the_latest_committed_model_value() {
    let mut model = field_model();
    let mut menu = Menu::<BinaryColor, 4, 1, FieldModel, FieldCommand>::new();
    menu.add_text_field("Name", |model| &model.name, FieldCommand::SetName)
        .unwrap();

    let mut before = mock_display();
    menu.view(&model).draw(&mut before).unwrap();
    model.name = "xyz".try_into().unwrap();

    let mut after = mock_display();
    menu.view(&model).draw(&mut after).unwrap();
    assert_ne!(after, before);

    let mut expected_input = TextInput::<BinaryColor, 4>::new("Name", "xyz", true).unwrap();
    expected_input.set_focused(true);
    let mut expected = mock_display();
    expected_input.draw(&mut expected).unwrap();
    assert_eq!(after, expected);

    let _ = menu.handle_action(MenuAction::SelectItem, &model).unwrap();
    assert_eq!(menu.editor().unwrap().value(), "xyz");
    assert_eq!(menu.editor().unwrap().original_value(), "xyz");
    let _ = menu.handle_action(MenuAction::Increment, &model).unwrap();
    let _ = menu.handle_action(MenuAction::Back, &model).unwrap();
    assert_eq!(model.name, "xyz");

    let _ = menu.handle_action(MenuAction::SelectItem, &model).unwrap();
    assert_eq!(menu.finish_edit(), EditOutcome::Unchanged);
}

#[test]
fn invalid_field_labels_and_values_preserve_browsing_state() {
    let mut model = field_model();
    let mut menu = Menu::<BinaryColor, 4, 2, FieldModel, FieldCommand>::new();
    menu.add_action("Back", FieldCommand::Back).unwrap();

    for invalid_label in ["\n", "é"] {
        assert_eq!(
            menu.add_text_field(invalid_label, |model| &model.name, FieldCommand::SetName),
            Err(MenuError::TextInput(TextInputError::UnsupportedCharacter))
        );
        assert_eq!(
            menu.add_read_only_field(invalid_label, |model| &model.name),
            Err(MenuError::TextInput(TextInputError::UnsupportedCharacter))
        );
    }

    assert_eq!(menu.selected_index(), Some(0));
    assert_eq!(menu.selected_item(), Some("Back"));
    menu.add_text_field("Name", |model| &model.name, FieldCommand::SetName)
        .unwrap();
    let _ = menu.handle_action(MenuAction::NextItem, &model).unwrap();

    model.name = "é".try_into().unwrap();
    assert_eq!(
        menu.validate_model(&model),
        Err(TextInputError::UnsupportedCharacter)
    );
    assert_eq!(
        menu.handle_action(MenuAction::SelectItem, &model),
        Err(TextInputError::UnsupportedCharacter)
    );

    assert!(!menu.is_editing());
    assert!(menu.editor().is_none());
    assert_eq!(menu.selected_index(), Some(1));
    let _ = menu.handle_action(MenuAction::NextItem, &model).unwrap();
    assert_eq!(menu.selected_item(), Some("Back"));
}

#[test]
fn zero_capacity_text_fields_cannot_start_an_editor() {
    let model = String::<0>::new();
    let mut menu = Menu::<BinaryColor, 0, 1, String<0>, ()>::new();
    menu.add_text_field("", |value| value, |_| ()).unwrap();

    assert_eq!(menu.validate_model(&model), Ok(()));
    assert_eq!(
        menu.handle_action(MenuAction::SelectItem, &model).unwrap(),
        MenuUpdate::default()
    );

    assert!(!menu.is_editing());
    assert!(menu.editor().is_none());
    assert_eq!(menu.finish_edit(), EditOutcome::Inactive);
}
