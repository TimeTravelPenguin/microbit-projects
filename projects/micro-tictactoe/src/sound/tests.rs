use super::*;

const SOUND_BYTES: &[u8] = include_bytes!("../../assets/noot_compressed.wav");

#[test]
fn bundled_clip_is_mono_pcm16_at_16_khz() {
    let clip = PcmClip::parse(SOUND_BYTES).unwrap();

    assert_eq!(clip.sample_rate, 16_000);
    assert_eq!(clip.samples.len(), 35_108);
}

#[test]
fn skips_unknown_chunks_and_their_padding() {
    let mut bytes = SOUND_BYTES.to_vec();
    bytes.splice(12..12, *b"JUNK\x01\x00\x00\x00\x42\x00");
    let riff_length = (bytes.len() - 8) as u32;
    bytes[4..8].copy_from_slice(&riff_length.to_le_bytes());
    let clip = PcmClip::parse(&bytes).unwrap();

    assert_eq!(clip.samples, &SOUND_BYTES[44..]);
}

#[test]
fn rejects_truncated_data() {
    let bytes = &SOUND_BYTES[..SOUND_BYTES.len() - 1];

    assert!(matches!(PcmClip::parse(bytes), Err(SoundError::InvalidWav)));
}

#[test]
fn rejects_compressed_and_stereo_audio() {
    for field_offset in [20, 22] {
        let mut bytes = SOUND_BYTES.to_vec();
        bytes[field_offset..field_offset + 2].copy_from_slice(&2_u16.to_le_bytes());

        assert!(matches!(
            PcmClip::parse(&bytes),
            Err(SoundError::UnsupportedFormat)
        ));
    }
}

#[test]
fn rejects_invalid_sample_rates() {
    let mut bytes = SOUND_BYTES.to_vec();
    bytes[24..28].copy_from_slice(&0_u32.to_le_bytes());

    assert!(matches!(
        PcmClip::parse(&bytes),
        Err(SoundError::UnsupportedSampleRate)
    ));
}

#[test]
fn converts_signed_samples_to_pwm_levels() {
    assert_eq!(sample_duty(i16::MIN, 250), 0);
    assert_eq!(sample_duty(0, 250), 125);
    assert_eq!(sample_duty(i16::MAX, 250), 249);
}
