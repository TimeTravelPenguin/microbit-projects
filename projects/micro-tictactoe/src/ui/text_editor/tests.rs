use embedded_graphics::{
    draw_target::DrawTargetExt,
    geometry::{Point, Size},
    mock_display::MockDisplay,
    pixelcolor::{BinaryColor, PixelColor},
    primitives::{PointsIter, Rectangle},
};

use super::{MenuStyle, TextEditor, TextInputError};

fn mock_display<C: PixelColor>() -> MockDisplay<C> {
    let mut display = MockDisplay::new();
    display.set_allow_overdraw(true);

    display
}

#[test]
fn editor_tracks_its_draft_without_changing_the_original_value() {
    let mut editor = TextEditor::<4>::new("abc").unwrap();

    assert_eq!(editor.value(), "abc");
    assert_eq!(editor.original_value(), "abc");
    assert_eq!(editor.selected_character(), 0);
    assert!(!editor.changed());
    assert!(editor.increment());
    assert_eq!(editor.draft().as_str(), "bbc");
    assert_eq!(editor.original_value(), "abc");
    assert!(editor.changed());
    assert!(editor.decrement());
    assert!(!editor.changed());
    assert!(editor.previous_character());
    assert_eq!(editor.selected_character(), 3);
    assert!(editor.increment());
    assert_eq!(editor.original_value(), "abc");
    assert_eq!(editor.into_value().as_str(), "abca");
}

#[test]
fn zero_capacity_editor_controls_are_safe_and_its_viewport_is_cleared() {
    let mut editor = TextEditor::<0>::new("").unwrap();

    assert_eq!(editor.selected_character(), 0);
    assert!(!editor.next_character());
    assert!(!editor.previous_character());
    assert!(!editor.increment());
    assert!(!editor.decrement());
    assert!(!editor.delete_character());
    assert!(!editor.changed());

    let viewport = Rectangle::new(Point::new(3, 4), Size::new(12, 10));
    let mut display = mock_display();
    editor
        .draw(&mut display.clipped(&viewport), &MenuStyle::default())
        .unwrap();

    assert_eq!(display.affected_area(), viewport);

    for point in viewport.points() {
        assert_eq!(display.get_pixel(point), Some(BinaryColor::Off));
    }

    assert_eq!(editor.into_value().as_str(), "");
}

#[test]
fn editor_rejects_values_outside_its_ascii_capacity() {
    assert!(matches!(
        TextEditor::<2>::new("abc"),
        Err(TextInputError::ValueTooLong)
    ));
    assert!(matches!(
        TextEditor::<2>::new("é"),
        Err(TextInputError::UnsupportedCharacter)
    ));
}
