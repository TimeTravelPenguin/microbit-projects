use super::{Key, decode_key};

#[test]
fn decodes_the_complete_output_space_and_preserves_invalid_bytes() {
    let mut recognised_count = 0;

    for byte in u8::MIN..=u8::MAX {
        let recognised = matches!(
            byte,
            0x08 | 0x09 | 0x0D | 0x1B | 0x7F | 0x20..=0x7E
                | 0x80..=0x96 | 0x98..=0xAF | 0xB4..=0xB7
        );

        if recognised {
            let key = Key::try_from(byte).expect("recognised CardKB output");
            let converted_byte: u8 = key.into();
            recognised_count += 1;

            assert_eq!(key.to_byte(), byte);
            assert_eq!(converted_byte, byte);
            assert_eq!(decode_key(byte), Ok(Some(key)));
        } else {
            let error = Key::try_from(byte).expect_err("unsupported CardKB output");
            assert_eq!(error.number, byte);

            if byte == 0 {
                assert_eq!(decode_key(byte), Ok(None));
            } else {
                assert_eq!(decode_key(byte).unwrap_err().number, byte);
            }
        }
    }

    assert_eq!(recognised_count, 151);
}

#[test]
fn maps_fn_outputs_to_their_physical_combinations() {
    // Firmware table order, including its unused 0x97 slot.
    let expected = [
        Some(Key::FnEscape),
        Some(Key::FnDigit1),
        Some(Key::FnDigit2),
        Some(Key::FnDigit3),
        Some(Key::FnDigit4),
        Some(Key::FnDigit5),
        Some(Key::FnDigit6),
        Some(Key::FnDigit7),
        Some(Key::FnDigit8),
        Some(Key::FnDigit9),
        Some(Key::FnDigit0),
        Some(Key::FnBackspace),
        Some(Key::FnTab),
        Some(Key::FnQ),
        Some(Key::FnW),
        Some(Key::FnE),
        Some(Key::FnR),
        Some(Key::FnT),
        Some(Key::FnY),
        Some(Key::FnU),
        Some(Key::FnI),
        Some(Key::FnO),
        Some(Key::FnP),
        None,
        Some(Key::FnArrowLeft),
        Some(Key::FnArrowUp),
        Some(Key::FnA),
        Some(Key::FnS),
        Some(Key::FnD),
        Some(Key::FnF),
        Some(Key::FnG),
        Some(Key::FnH),
        Some(Key::FnJ),
        Some(Key::FnK),
        Some(Key::FnL),
        Some(Key::FnEnter),
        Some(Key::FnArrowDown),
        Some(Key::FnArrowRight),
        Some(Key::FnZ),
        Some(Key::FnX),
        Some(Key::FnC),
        Some(Key::FnV),
        Some(Key::FnB),
        Some(Key::FnN),
        Some(Key::FnM),
        Some(Key::FnComma),
        Some(Key::FnPeriod),
        Some(Key::FnSpace),
    ];

    for (byte, expected_key) in (0x80..=0xAF).zip(expected) {
        assert_eq!(Key::try_from(byte).ok(), expected_key);
    }
}

#[test]
fn preserves_character_case_symbols_and_named_controls() {
    let examples = [
        (b'A', Key::UpperA),
        (b'Z', Key::UpperZ),
        (b'a', Key::LowerA),
        (b'z', Key::LowerZ),
        (b'0', Key::Digit0),
        (b'9', Key::Digit9),
        (b'!', Key::ExclamationMark),
        (b'"', Key::DoubleQuote),
        (b'\'', Key::SingleQuote),
        (b'\\', Key::Backslash),
        (b'`', Key::Backtick),
        (b'|', Key::Pipe),
        (b'~', Key::Tilde),
        (0x08, Key::Backspace),
        (0x09, Key::Tab),
        (0x0D, Key::Enter),
        (0x1B, Key::Escape),
        (0x7F, Key::Delete),
        (0xB4, Key::ArrowLeft),
        (0xB5, Key::ArrowUp),
        (0xB6, Key::ArrowDown),
        (0xB7, Key::ArrowRight),
    ];

    for (byte, expected_key) in examples {
        assert_eq!(Key::try_from(byte), Ok(expected_key));
    }
}

#[test]
fn converts_only_printable_outputs_to_characters() {
    for byte in u8::MIN..=u8::MAX {
        let Ok(key) = Key::try_from(byte) else {
            continue;
        };

        let expected_char = if byte.is_ascii_graphic() || byte == b' ' {
            Some(char::from(byte))
        } else {
            None
        };

        assert_eq!(key.as_char(), expected_char);
    }
}
