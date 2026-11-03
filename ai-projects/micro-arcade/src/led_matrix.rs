//! Compact 3x5 uppercase letters and decimal digits for the 5x5 LED matrix.
//!
//! Each three-bit value describes one row, from top to bottom and left to right.
//! Glyphs are centered in the display, leaving the outer columns blank.

pub(crate) const GLYPH_COLUMNS: core::ops::Range<usize> = 1..4;

const fn bitmap(rows: [u8; 5]) -> [[u8; 5]; 5] {
    let mut matrix = [[0; 5]; 5];
    let mut row_idx = 0;

    while row_idx < 5 {
        assert!(rows[row_idx] <= 0b111, "bitmap rows must fit in three bits");

        let mut col_idx = GLYPH_COLUMNS.start;

        while col_idx < GLYPH_COLUMNS.end {
            matrix[row_idx][col_idx] = (rows[row_idx] >> (GLYPH_COLUMNS.end - 1 - col_idx)) & 1;
            col_idx += 1;
        }

        row_idx += 1;
    }

    matrix
}

pub const LETTER_A: [[u8; 5]; 5] = bitmap([0b010, 0b101, 0b111, 0b101, 0b101]);
pub const LETTER_B: [[u8; 5]; 5] = bitmap([0b110, 0b101, 0b110, 0b101, 0b110]);
pub const LETTER_C: [[u8; 5]; 5] = bitmap([0b011, 0b100, 0b100, 0b100, 0b011]);
pub const LETTER_D: [[u8; 5]; 5] = bitmap([0b110, 0b101, 0b101, 0b101, 0b110]);
pub const LETTER_E: [[u8; 5]; 5] = bitmap([0b111, 0b100, 0b110, 0b100, 0b111]);
pub const LETTER_F: [[u8; 5]; 5] = bitmap([0b111, 0b100, 0b110, 0b100, 0b100]);
pub const LETTER_G: [[u8; 5]; 5] = bitmap([0b011, 0b100, 0b101, 0b101, 0b011]);
pub const LETTER_H: [[u8; 5]; 5] = bitmap([0b101, 0b101, 0b111, 0b101, 0b101]);
pub const LETTER_I: [[u8; 5]; 5] = bitmap([0b111, 0b010, 0b010, 0b010, 0b111]);
pub const LETTER_J: [[u8; 5]; 5] = bitmap([0b001, 0b001, 0b001, 0b101, 0b010]);
pub const LETTER_K: [[u8; 5]; 5] = bitmap([0b101, 0b101, 0b110, 0b101, 0b101]);
pub const LETTER_L: [[u8; 5]; 5] = bitmap([0b100, 0b100, 0b100, 0b100, 0b111]);
pub const LETTER_M: [[u8; 5]; 5] = bitmap([0b101, 0b111, 0b101, 0b101, 0b101]);
pub const LETTER_N: [[u8; 5]; 5] = bitmap([0b101, 0b111, 0b111, 0b111, 0b101]);
pub const LETTER_O: [[u8; 5]; 5] = bitmap([0b010, 0b101, 0b101, 0b101, 0b010]);
pub const LETTER_P: [[u8; 5]; 5] = bitmap([0b110, 0b101, 0b110, 0b100, 0b100]);
pub const LETTER_Q: [[u8; 5]; 5] = bitmap([0b010, 0b101, 0b101, 0b111, 0b011]);
pub const LETTER_R: [[u8; 5]; 5] = bitmap([0b110, 0b101, 0b110, 0b101, 0b101]);
pub const LETTER_S: [[u8; 5]; 5] = bitmap([0b011, 0b100, 0b010, 0b001, 0b110]);
pub const LETTER_T: [[u8; 5]; 5] = bitmap([0b111, 0b010, 0b010, 0b010, 0b010]);
pub const LETTER_U: [[u8; 5]; 5] = bitmap([0b101, 0b101, 0b101, 0b101, 0b111]);
pub const LETTER_V: [[u8; 5]; 5] = bitmap([0b101, 0b101, 0b101, 0b101, 0b010]);
pub const LETTER_W: [[u8; 5]; 5] = bitmap([0b101, 0b101, 0b101, 0b111, 0b101]);
pub const LETTER_X: [[u8; 5]; 5] = bitmap([0b101, 0b101, 0b010, 0b101, 0b101]);
pub const LETTER_Y: [[u8; 5]; 5] = bitmap([0b101, 0b101, 0b010, 0b010, 0b010]);
pub const LETTER_Z: [[u8; 5]; 5] = bitmap([0b111, 0b001, 0b010, 0b100, 0b111]);

// Zero has a square outline; LETTER_O is rounded.
pub const DIGIT_0: [[u8; 5]; 5] = bitmap([0b111, 0b101, 0b101, 0b101, 0b111]);
pub const DIGIT_1: [[u8; 5]; 5] = bitmap([0b010, 0b110, 0b010, 0b010, 0b111]);
pub const DIGIT_2: [[u8; 5]; 5] = bitmap([0b110, 0b001, 0b010, 0b100, 0b111]);
pub const DIGIT_3: [[u8; 5]; 5] = bitmap([0b110, 0b001, 0b010, 0b001, 0b110]);
pub const DIGIT_4: [[u8; 5]; 5] = bitmap([0b101, 0b101, 0b111, 0b001, 0b001]);
pub const DIGIT_5: [[u8; 5]; 5] = bitmap([0b111, 0b100, 0b110, 0b001, 0b110]);
pub const DIGIT_6: [[u8; 5]; 5] = bitmap([0b011, 0b100, 0b111, 0b101, 0b111]);
pub const DIGIT_7: [[u8; 5]; 5] = bitmap([0b111, 0b001, 0b010, 0b010, 0b010]);
pub const DIGIT_8: [[u8; 5]; 5] = bitmap([0b111, 0b101, 0b111, 0b101, 0b111]);
pub const DIGIT_9: [[u8; 5]; 5] = bitmap([0b111, 0b101, 0b111, 0b001, 0b110]);

pub const EMPTY: [[u8; 5]; 5] = [[0; 5]; 5];

/// Return the glyph for an ASCII letter or digit, accepting either letter case.
///
/// Spaces and unsupported characters render as a blank 5x5 glyph.
pub fn from_char(character: char) -> [[u8; 5]; 5] {
    match character.to_ascii_uppercase() {
        'A' => LETTER_A,
        'B' => LETTER_B,
        'C' => LETTER_C,
        'D' => LETTER_D,
        'E' => LETTER_E,
        'F' => LETTER_F,
        'G' => LETTER_G,
        'H' => LETTER_H,
        'I' => LETTER_I,
        'J' => LETTER_J,
        'K' => LETTER_K,
        'L' => LETTER_L,
        'M' => LETTER_M,
        'N' => LETTER_N,
        'O' => LETTER_O,
        'P' => LETTER_P,
        'Q' => LETTER_Q,
        'R' => LETTER_R,
        'S' => LETTER_S,
        'T' => LETTER_T,
        'U' => LETTER_U,
        'V' => LETTER_V,
        'W' => LETTER_W,
        'X' => LETTER_X,
        'Y' => LETTER_Y,
        'Z' => LETTER_Z,
        '0' => DIGIT_0,
        '1' => DIGIT_1,
        '2' => DIGIT_2,
        '3' => DIGIT_3,
        '4' => DIGIT_4,
        '5' => DIGIT_5,
        '6' => DIGIT_6,
        '7' => DIGIT_7,
        '8' => DIGIT_8,
        '9' => DIGIT_9,
        _ => EMPTY,
    }
}
