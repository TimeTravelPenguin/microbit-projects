//! Typed CardKB output values, independent of the hardware transport.
//!
//! The mappings follow the [CardKB firmware key table]. A byte is the output
//! after the keyboard has applied its modifier mode, rather than a physical
//! press or release event.
//!
//! [CardKB firmware key table]: https://github.com/m5stack/M5-ProductExampleCodes/blob/master/Unit/CARDKB/firmware_328p/CardKeyBoard/CardKeyBoard.ino

use num_enum::{IntoPrimitive, TryFromPrimitive};

/// A recognised output from the CardKB firmware.
///
/// Uppercase, lowercase, punctuation, and Fn combinations retain their distinct
/// output values. Modifier keys do not produce separate events.
///
/// The legacy [`Delete`](Self::Delete) output is accepted for compatibility with
/// older firmware. CardKB v1.1 documents Backspace in its place.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash, IntoPrimitive, TryFromPrimitive)]
#[repr(u8)]
pub enum Key {
    Backspace = 0x08,
    Tab = 0x09,
    Enter = 0x0D,
    Escape = 0x1B,

    Space = b' ',
    ExclamationMark = b'!',
    DoubleQuote = b'"',
    Hash = b'#',
    Dollar = b'$',
    Percent = b'%',
    Ampersand = b'&',
    SingleQuote = b'\'',
    LeftParenthesis = b'(',
    RightParenthesis = b')',
    Asterisk = b'*',
    Plus = b'+',
    Comma = b',',
    Minus = b'-',
    Period = b'.',
    Slash = b'/',
    Digit0 = b'0',
    Digit1 = b'1',
    Digit2 = b'2',
    Digit3 = b'3',
    Digit4 = b'4',
    Digit5 = b'5',
    Digit6 = b'6',
    Digit7 = b'7',
    Digit8 = b'8',
    Digit9 = b'9',
    Colon = b':',
    Semicolon = b';',
    LessThan = b'<',
    Equal = b'=',
    GreaterThan = b'>',
    QuestionMark = b'?',
    At = b'@',
    UpperA = b'A',
    UpperB = b'B',
    UpperC = b'C',
    UpperD = b'D',
    UpperE = b'E',
    UpperF = b'F',
    UpperG = b'G',
    UpperH = b'H',
    UpperI = b'I',
    UpperJ = b'J',
    UpperK = b'K',
    UpperL = b'L',
    UpperM = b'M',
    UpperN = b'N',
    UpperO = b'O',
    UpperP = b'P',
    UpperQ = b'Q',
    UpperR = b'R',
    UpperS = b'S',
    UpperT = b'T',
    UpperU = b'U',
    UpperV = b'V',
    UpperW = b'W',
    UpperX = b'X',
    UpperY = b'Y',
    UpperZ = b'Z',
    LeftBracket = b'[',
    Backslash = b'\\',
    RightBracket = b']',
    Caret = b'^',
    Underscore = b'_',
    Backtick = b'`',
    LowerA = b'a',
    LowerB = b'b',
    LowerC = b'c',
    LowerD = b'd',
    LowerE = b'e',
    LowerF = b'f',
    LowerG = b'g',
    LowerH = b'h',
    LowerI = b'i',
    LowerJ = b'j',
    LowerK = b'k',
    LowerL = b'l',
    LowerM = b'm',
    LowerN = b'n',
    LowerO = b'o',
    LowerP = b'p',
    LowerQ = b'q',
    LowerR = b'r',
    LowerS = b's',
    LowerT = b't',
    LowerU = b'u',
    LowerV = b'v',
    LowerW = b'w',
    LowerX = b'x',
    LowerY = b'y',
    LowerZ = b'z',
    LeftBrace = b'{',
    Pipe = b'|',
    RightBrace = b'}',
    Tilde = b'~',

    /// Delete, emitted by some older firmware revisions.
    Delete = 0x7F,

    FnEscape = 0x80,
    FnDigit1 = 0x81,
    FnDigit2 = 0x82,
    FnDigit3 = 0x83,
    FnDigit4 = 0x84,
    FnDigit5 = 0x85,
    FnDigit6 = 0x86,
    FnDigit7 = 0x87,
    FnDigit8 = 0x88,
    FnDigit9 = 0x89,
    FnDigit0 = 0x8A,
    FnBackspace = 0x8B,
    FnTab = 0x8C,
    FnQ = 0x8D,
    FnW = 0x8E,
    FnE = 0x8F,
    FnR = 0x90,
    FnT = 0x91,
    FnY = 0x92,
    FnU = 0x93,
    FnI = 0x94,
    FnO = 0x95,
    FnP = 0x96,
    FnArrowLeft = 0x98,
    FnArrowUp = 0x99,
    FnA = 0x9A,
    FnS = 0x9B,
    FnD = 0x9C,
    FnF = 0x9D,
    FnG = 0x9E,
    FnH = 0x9F,
    FnJ = 0xA0,
    FnK = 0xA1,
    FnL = 0xA2,
    FnEnter = 0xA3,
    FnArrowDown = 0xA4,
    FnArrowRight = 0xA5,
    FnZ = 0xA6,
    FnX = 0xA7,
    FnC = 0xA8,
    FnV = 0xA9,
    FnB = 0xAA,
    FnN = 0xAB,
    FnM = 0xAC,
    FnComma = 0xAD,
    FnPeriod = 0xAE,
    FnSpace = 0xAF,

    ArrowLeft = 0xB4,
    ArrowUp = 0xB5,
    ArrowDown = 0xB6,
    ArrowRight = 0xB7,
}

/// An unsupported CardKB output, preserved in the error's `number` field.
pub type DecodeError = num_enum::TryFromPrimitiveError<Key>;

impl Key {
    /// Returns the original CardKB output byte.
    pub const fn to_byte(self) -> u8 {
        self as u8
    }

    /// Returns a character for printable ASCII outputs, including Space.
    ///
    /// Control keys, navigation keys, and Fn combinations return `None`.
    pub const fn as_char(self) -> Option<char> {
        match self.to_byte() {
            byte @ b' '..=b'~' => Some(byte as char),
            _ => None,
        }
    }
}

/// Decodes an output byte, treating zero as no available input.
///
/// Unsupported nonzero bytes return an error containing the original value.
pub fn decode_key(byte: u8) -> Result<Option<Key>, DecodeError> {
    if byte == 0 {
        return Ok(None);
    }

    Key::try_from(byte).map(Some)
}

pub trait KeyExt {
    fn is_key(&self, key: Key) -> bool;
}

impl KeyExt for Key {
    fn is_key(&self, key: Key) -> bool {
        *self == key
    }
}

impl KeyExt for Option<Key> {
    fn is_key(&self, key: Key) -> bool {
        match self {
            Some(k) => *k == key,
            None => false,
        }
    }
}

#[cfg(test)]
mod tests;
