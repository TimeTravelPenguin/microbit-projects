use crate::{
    led_matrix::{
        DIGIT_0, DIGIT_2, DIGIT_6, EMPTY, LETTER_A, LETTER_B, LETTER_H, LETTER_L, LETTER_R,
        LETTER_S, LETTER_T, LETTER_U, from_char,
    },
    scrolling::{scroll_frames, scroll_text},
};

extern crate std;

use std::{vec, vec::Vec};

type Matrix = [[u8; 5]; 5];

// Build the complete message independently, then slide a five-column window.
fn reference_frames(glyphs: &[Matrix]) -> Vec<Matrix> {
    let mut strip: [Vec<u8>; 5] = std::array::from_fn(|_| vec![0; 5]);

    for (glyph_idx, glyph) in glyphs.iter().enumerate() {
        for (row_idx, row) in strip.iter_mut().enumerate() {
            if glyph_idx > 0 {
                row.push(0);
            }

            row.extend_from_slice(&glyph[row_idx][1..4]);
        }
    }

    for row in &mut strip {
        row.extend_from_slice(&[0; 5]);
    }

    let mut frames = Vec::new();

    for offset in 0..=strip[0].len() - 5 {
        let frame = std::array::from_fn(|row_idx| {
            strip[row_idx][offset..offset + 5]
                .try_into()
                .expect("each window has five columns")
        });

        frames.push(frame);
    }

    frames
}

#[test]
fn empty_message_yields_one_blank_frame() {
    let mut frames = scroll_text("");

    assert_eq!(frames.next(), Some(EMPTY));
    assert_eq!(frames.next(), None);
    assert_eq!(frames.next(), None);

    let mut annotated_frames = scroll_frames("");
    let blank_frame = annotated_frames.next().expect("initial blank frame");

    assert_eq!(blank_frame.pixels, EMPTY);
    assert!(!blank_frame.text_complete);
    assert!(annotated_frames.next().is_none());
    assert!(annotated_frames.next().is_none());
}

#[test]
fn mixed_message_matches_every_reference_frame() {
    let glyphs = [
        LETTER_R, LETTER_U, LETTER_S, LETTER_T, EMPTY, DIGIT_2, DIGIT_0, DIGIT_2, DIGIT_6,
    ];

    let expected = reference_frames(&glyphs);
    let actual: Vec<_> = scroll_text("Rust 2026").collect();

    assert_eq!(actual, expected);
    assert_eq!(actual.len(), 4 * glyphs.len() + 5);
    assert_eq!(actual.first(), Some(&EMPTY));
    assert_eq!(actual.last(), Some(&EMPTY));
}

#[test]
fn single_glyph_keeps_both_edge_columns() {
    let frames: Vec<_> = scroll_text("R").collect();
    let first_column_entering = [[0, 0, 0, 0, 1]; 5];
    let last_column_leaving = [
        [0, 0, 0, 0, 0],
        [1, 0, 0, 0, 0],
        [0, 0, 0, 0, 0],
        [1, 0, 0, 0, 0],
        [1, 0, 0, 0, 0],
    ];

    assert_eq!(frames.len(), 9);
    assert_eq!(frames[1], first_column_entering);
    assert_eq!(frames[4], LETTER_R);
    assert_eq!(frames[7], last_column_leaving);
    assert_eq!(frames[8], EMPTY);
}

#[test]
fn adjacent_glyphs_have_one_blank_column_between_them() {
    let frames: Vec<_> = scroll_text("AB").collect();
    let next_glyph_entering_after_separator = [
        [0, 1, 0, 0, 1],
        [1, 0, 1, 0, 1],
        [1, 1, 1, 0, 1],
        [1, 0, 1, 0, 1],
        [1, 0, 1, 0, 1],
    ];

    assert_eq!(frames, reference_frames(&[LETTER_A, LETTER_B]));
    assert_eq!(frames[4], LETTER_A);
    assert_eq!(frames[5], next_glyph_entering_after_separator);
    assert_eq!(frames[8], LETTER_B);
}

#[test]
fn lowercase_and_unsupported_unicode_map_once_per_character() {
    let text = "a é🦀!b";
    let glyphs = [LETTER_A, EMPTY, EMPTY, EMPTY, EMPTY, LETTER_B];
    let frames: Vec<_> = scroll_text(text).collect();

    assert_eq!(from_char('a'), LETTER_A);
    assert_eq!(from_char('b'), LETTER_B);

    for unsupported in [' ', 'é', '🦀', '!'] {
        assert_eq!(from_char(unsupported), EMPTY);
    }

    assert_eq!(frames, reference_frames(&glyphs));
    assert_eq!(frames.len(), 4 * text.chars().count() + 5);
    assert_eq!(frames, scroll_text("A    B").collect::<Vec<_>>());
}

#[test]
fn exhausted_iterator_stays_finished_and_fresh_iteration_restarts() {
    let mut frames = scroll_text("A2");
    let first_run: Vec<_> = frames.by_ref().collect();

    assert_eq!(first_run, reference_frames(&[LETTER_A, DIGIT_2]));
    assert_eq!(frames.next(), None);
    assert_eq!(frames.next(), None);
    assert_eq!(scroll_text("A2").collect::<Vec<_>>(), first_run);
}

#[test]
fn completion_marker_fires_once_when_the_final_character_enters() {
    for text in ["R", "AB", "Rust 2026", "a é🦀!b", "A🦀"] {
        let frames: Vec<_> = scroll_frames(text).collect();
        let pixels: Vec<_> = frames.iter().map(|frame| frame.pixels).collect();
        let completion_indices: Vec<_> = frames
            .iter()
            .enumerate()
            .filter_map(|(frame_idx, frame)| frame.text_complete.then_some(frame_idx))
            .collect();

        assert_eq!(pixels, scroll_text(text).collect::<Vec<_>>(), "{text}");
        assert_eq!(frames.len(), 4 * text.chars().count() + 5, "{text}");
        assert_eq!(
            completion_indices,
            vec![4 * text.chars().count() - 1],
            "{text}"
        );
    }
}

#[test]
fn completion_marker_precedes_the_trailing_separator() {
    let frames: Vec<_> = scroll_frames("R").collect();
    let final_column_entering = [
        [0, 0, 1, 1, 0],
        [0, 0, 1, 0, 1],
        [0, 0, 1, 1, 0],
        [0, 0, 1, 0, 1],
        [0, 0, 1, 0, 1],
    ];

    assert_eq!(frames[3].pixels, final_column_entering);
    assert!(frames[3].text_complete);
    assert_eq!(frames[4].pixels, LETTER_R);
    assert!(!frames[4].text_complete);
    assert!(frames[4..].iter().all(|frame| !frame.text_complete));

    let frames: Vec<_> = scroll_frames("AB").collect();

    assert!(frames[7].text_complete);
    assert_eq!(frames[8].pixels, LETTER_B);
    assert!(frames[8..].iter().all(|frame| !frame.text_complete));
}

#[test]
fn display_then_sound_playback_fires_once_per_fresh_run() {
    #[derive(Debug, PartialEq)]
    enum PlaybackEvent {
        Display(Matrix),
        Sound,
    }

    let expected_pixels = reference_frames(&[LETTER_A, LETTER_B]);
    let mut expected_events: Vec<_> = expected_pixels[..8]
        .iter()
        .map(|pixels| PlaybackEvent::Display(*pixels))
        .collect();

    expected_events.push(PlaybackEvent::Sound);
    expected_events.extend(
        expected_pixels[8..]
            .iter()
            .map(|pixels| PlaybackEvent::Display(*pixels)),
    );

    for _ in 0..2 {
        let mut events = Vec::new();
        let mut frames = scroll_frames("AB");

        for frame in frames.by_ref() {
            events.push(PlaybackEvent::Display(frame.pixels));

            if frame.text_complete {
                events.push(PlaybackEvent::Sound);
            }
        }

        assert_eq!(events, expected_events);
        assert!(frames.next().is_none());
        assert!(frames.next().is_none());
    }
}

#[test]
fn h_and_l_use_centered_three_column_shapes() {
    let expected_h = [
        [0, 1, 0, 1, 0],
        [0, 1, 0, 1, 0],
        [0, 1, 1, 1, 0],
        [0, 1, 0, 1, 0],
        [0, 1, 0, 1, 0],
    ];

    let expected_l = [
        [0, 1, 0, 0, 0],
        [0, 1, 0, 0, 0],
        [0, 1, 0, 0, 0],
        [0, 1, 0, 0, 0],
        [0, 1, 1, 1, 0],
    ];

    assert_eq!(LETTER_H, expected_h);
    assert_eq!(LETTER_L, expected_l);
}

#[test]
fn every_letter_and_digit_has_blank_outer_columns_and_a_unique_shape() {
    let glyphs: Vec<_> = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        .chars()
        .map(|character| (character, from_char(character)))
        .collect();

    for (glyph_idx, (character, glyph)) in glyphs.iter().enumerate() {
        assert_ne!(*glyph, EMPTY, "{character} must have a visible shape");

        for row in glyph {
            assert_eq!(row[0], 0, "{character} must have a blank left column");
            assert_eq!(row[4], 0, "{character} must have a blank right column");
        }

        for (other_character, other_glyph) in &glyphs[glyph_idx + 1..] {
            assert_ne!(
                glyph, other_glyph,
                "{character} and {other_character} must have distinct shapes"
            );
        }
    }
}
