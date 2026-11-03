use embedded_storage::nor_flash::{
    ErrorType, NorFlash, NorFlashError, NorFlashErrorKind, ReadNorFlash,
};
use std::{boxed::Box, vec, vec::Vec};

use super::*;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
enum FakeError {
    PowerCut,
    InvalidAccess,
    RewrittenWord,
}

impl NorFlashError for FakeError {
    fn kind(&self) -> NorFlashErrorKind {
        NorFlashErrorKind::Other
    }
}

struct FakeFlash {
    bytes: Box<[u8]>,
    written_words: Vec<bool>,
    writes_until_cut: Option<usize>,
    torn_word_at: Option<usize>,
    corrupt_after_commit: bool,
    erase_pages_until_cut: Option<usize>,
    erase_count: usize,
}

impl FakeFlash {
    fn new() -> Self {
        Self {
            bytes: vec![0xff; REGION_SIZE].into_boxed_slice(),
            written_words: vec![false; REGION_SIZE / 4],
            writes_until_cut: None,
            torn_word_at: None,
            corrupt_after_commit: false,
            erase_pages_until_cut: None,
            erase_count: 0,
        }
    }

    fn resume_power(&mut self) {
        self.writes_until_cut = None;
        self.torn_word_at = None;
        self.erase_pages_until_cut = None;
    }
}

impl ErrorType for FakeFlash {
    type Error = FakeError;
}

impl ReadNorFlash for FakeFlash {
    const READ_SIZE: usize = 1;

    fn read(&mut self, offset: u32, bytes: &mut [u8]) -> Result<(), Self::Error> {
        let start = offset as usize;
        let source = self
            .bytes
            .get(start..start + bytes.len())
            .ok_or(FakeError::InvalidAccess)?;
        bytes.copy_from_slice(source);

        Ok(())
    }

    fn capacity(&self) -> usize {
        self.bytes.len()
    }
}

impl NorFlash for FakeFlash {
    const WRITE_SIZE: usize = 4;
    const ERASE_SIZE: usize = 4096;

    fn erase(&mut self, from: u32, to: u32) -> Result<(), Self::Error> {
        let start = from as usize;
        let end = to as usize;

        if start % Self::ERASE_SIZE != 0
            || end % Self::ERASE_SIZE != 0
            || end > self.bytes.len()
            || start > end
        {
            return Err(FakeError::InvalidAccess);
        }

        self.erase_count += 1;

        for page_start in (start..end).step_by(Self::ERASE_SIZE) {
            let page_end = page_start + Self::ERASE_SIZE;
            self.bytes[page_start..page_end].fill(0xff);
            self.written_words[page_start / 4..page_end / 4].fill(false);

            if let Some(pages_left) = &mut self.erase_pages_until_cut {
                *pages_left -= 1;

                if *pages_left == 0 {
                    return Err(FakeError::PowerCut);
                }
            }
        }

        Ok(())
    }

    fn write(&mut self, offset: u32, bytes: &[u8]) -> Result<(), Self::Error> {
        let start = offset as usize;

        if start % 4 != 0 || bytes.len() % 4 != 0 || start + bytes.len() > self.bytes.len() {
            return Err(FakeError::InvalidAccess);
        }

        for (word_offset, word) in bytes.chunks_exact(4).enumerate() {
            let address = start + word_offset * 4;
            let word_index = address / 4;

            if self.written_words[word_index] {
                return Err(FakeError::RewrittenWord);
            }

            let word_is_torn = self.torn_word_at == Some(address);
            let programmed_bytes = if word_is_torn { 2 } else { 4 };

            for (stored, input) in self.bytes[address..address + programmed_bytes]
                .iter_mut()
                .zip(word)
            {
                if *stored & *input != *input {
                    return Err(FakeError::InvalidAccess);
                }

                *stored &= *input;
            }

            self.written_words[word_index] = true;

            // A power cut can interrupt an individual word, too. Only the
            // first half reaches flash; the rest stays in its erased state.
            if word_is_torn {
                self.torn_word_at = None;

                return Err(FakeError::PowerCut);
            }

            // Fail after programming a word, including the commit word. This
            // models losing power before the caller receives success.
            if let Some(words_left) = &mut self.writes_until_cut {
                *words_left -= 1;

                if *words_left == 0 {
                    self.writes_until_cut = None;

                    return Err(FakeError::PowerCut);
                }
            }
        }

        if self.corrupt_after_commit && start % SLOT_SIZE == COMMIT_OFFSET {
            self.bytes[start - COMMIT_OFFSET + 16] ^= 1;
        }

        Ok(())
    }
}

fn sample(uptime_ms: u32) -> Sample {
    Sample {
        uptime_ms,
        acceleration_mg: [-1000, 7, 999],
        magnetic_field_nt: [125, -23_456, 34_567],
    }
}

#[test]
fn stores_signed_axes_and_starts_a_new_session_after_reboot() {
    let mut log = Log::open(FakeFlash::new()).unwrap();
    assert_eq!(log.session(), 1);
    log.append(sample(120)).unwrap();
    log.append(sample(240)).unwrap();

    let mut reopened = Log::open(log.into_inner()).unwrap();
    assert_eq!(reopened.count(), 2);
    assert_eq!(reopened.used_slots(), 2);
    assert_eq!(reopened.session(), 2);
    assert_eq!(
        reopened.read(0).unwrap(),
        Some(Record {
            session: 1,
            sample: sample(120),
        })
    );

    reopened.append(sample(12)).unwrap();
    assert_eq!(reopened.read(2).unwrap().unwrap().session, 2);
    assert_eq!(reopened.into_inner().erase_count, 0);
}

#[test]
fn every_word_power_cut_preserves_old_rows_and_skips_the_interrupted_slot() {
    for cut_after_word in 1..=SLOT_SIZE / 4 {
        let mut log = Log::open(FakeFlash::new()).unwrap();
        log.append(sample(10)).unwrap();
        let mut flash = log.into_inner();
        flash.writes_until_cut = Some(cut_after_word);
        let mut log = Log::open(flash).unwrap();
        assert_eq!(
            log.append(sample(20)),
            Err(Error::Flash(FakeError::PowerCut))
        );
        assert_eq!(log.used_slots(), 2);

        let mut flash = log.into_inner();
        flash.resume_power();
        let mut reopened = Log::open(flash).unwrap();
        assert_eq!(reopened.used_slots(), 2, "cut after word {cut_after_word}");
        assert_eq!(reopened.read(0).unwrap().unwrap().sample, sample(10));

        if cut_after_word == SLOT_SIZE / 4 {
            // Commit finished before the power cut: it is a complete row.
            assert_eq!(reopened.count(), 2);
            assert_eq!(reopened.read(1).unwrap().unwrap().sample, sample(20));
            assert_eq!(reopened.session(), 3);
        } else {
            assert_eq!(reopened.count(), 1);
            assert_eq!(reopened.read(1).unwrap(), None);
            assert_eq!(reopened.session(), 2);
        }

        reopened.append(sample(30)).unwrap();
        assert_eq!(reopened.read(2).unwrap().unwrap().sample, sample(30));
        assert_eq!(reopened.into_inner().erase_count, 0);
    }
}

#[test]
fn a_failed_append_consumes_its_slot_even_without_a_reboot() {
    let mut flash = FakeFlash::new();
    flash.writes_until_cut = Some(3);
    let mut log = Log::open(flash).unwrap();
    assert_eq!(
        log.append(sample(10)),
        Err(Error::Flash(FakeError::PowerCut))
    );

    log.append(sample(20)).unwrap();
    assert_eq!(log.used_slots(), 2);
    assert_eq!(log.count(), 1);
    assert_eq!(log.read(0).unwrap(), None);
    assert_eq!(log.read(1).unwrap().unwrap().sample, sample(20));
}

#[test]
fn a_partial_write_inside_each_word_including_commit_is_not_a_record() {
    for torn_word in 0..SLOT_SIZE / 4 {
        let mut log = Log::open(FakeFlash::new()).unwrap();
        log.append(sample(10)).unwrap();
        let mut flash = log.into_inner();
        flash.torn_word_at = Some(SLOT_SIZE + torn_word * 4);
        let mut log = Log::open(flash).unwrap();
        assert_eq!(
            log.append(sample(20)),
            Err(Error::Flash(FakeError::PowerCut))
        );
        let mut reopened = Log::open(log.into_inner()).unwrap();
        assert_eq!(reopened.count(), 1, "partially written word {torn_word}");
        assert_eq!(reopened.used_slots(), 2);
        assert_eq!(reopened.read(0).unwrap().unwrap().sample, sample(10));
        assert_eq!(reopened.read(1).unwrap(), None);
        reopened.append(sample(30)).unwrap();
        assert_eq!(reopened.read(2).unwrap().unwrap().sample, sample(30));
    }
}

#[test]
fn full_log_stops_without_erasing_or_overwriting() {
    let mut log = Log::open(FakeFlash::new()).unwrap();

    for row in 0..CAPACITY {
        log.append(sample(row as u32)).unwrap();
    }

    assert_eq!(log.capacity(), 1024);
    assert_eq!(log.count(), CAPACITY);
    assert!(log.is_full());
    assert_eq!(log.append(sample(9999)), Err(Error::Full));
    assert_eq!(log.read(0).unwrap().unwrap().sample, sample(0));
    let mut reopened = Log::open(log.into_inner()).unwrap();
    assert!(reopened.is_full());
    assert_eq!(
        reopened.read(CAPACITY - 1).unwrap().unwrap().sample,
        sample(1023)
    );
    assert_eq!(reopened.into_inner().erase_count, 0);
}

#[test]
fn clear_erases_explicitly_and_restarts_the_log() {
    let mut log = Log::open(FakeFlash::new()).unwrap();
    log.append(sample(10)).unwrap();
    let mut log = Log::open(log.into_inner()).unwrap();
    assert_eq!(log.session(), 2);
    log.clear().unwrap();
    assert_eq!(log.count(), 0);
    assert_eq!(log.used_slots(), 0);
    assert_eq!(log.session(), 1);
    assert_eq!(log.read(0).unwrap(), None);
    log.append(sample(20)).unwrap();
    assert_eq!(log.read(0).unwrap().unwrap().session, 1);
    assert_eq!(log.into_inner().erase_count, 1);
}

#[test]
fn corrupt_records_and_blank_holes_are_never_reused() {
    let mut log = Log::open(FakeFlash::new()).unwrap();

    for row in 0..4 {
        log.append(sample(row)).unwrap();
    }

    let mut flash = log.into_inner();
    flash.bytes[..SLOT_SIZE].fill(0xff);
    flash.bytes[SLOT_SIZE + 16] ^= 1;
    flash.bytes[2 * SLOT_SIZE + COMMIT_OFFSET] ^= 1;
    let mut log = Log::open(flash).unwrap();
    assert_eq!(log.count(), 1);
    assert_eq!(log.used_slots(), 4);
    assert_eq!(log.read(0).unwrap(), None);
    assert_eq!(log.read(1).unwrap(), None);
    assert_eq!(log.read(2).unwrap(), None);
    assert_eq!(log.read(3).unwrap().unwrap().sample, sample(3));
    log.append(sample(40)).unwrap();
    assert_eq!(log.read(4).unwrap().unwrap().sample, sample(40));
}

#[test]
fn failed_clear_can_be_reopened_past_all_remaining_rows() {
    let mut log = Log::open(FakeFlash::new()).unwrap();

    for row in 0..70 {
        log.append(sample(row)).unwrap();
    }

    let mut flash = log.into_inner();
    flash.erase_pages_until_cut = Some(1);
    let mut log = Log::open(flash).unwrap();
    assert_eq!(log.clear(), Err(Error::Flash(FakeError::PowerCut)));
    assert_eq!(log.append(sample(90)), Err(Error::Full));
    let mut flash = log.into_inner();
    flash.resume_power();
    let mut reopened = Log::open(flash).unwrap();
    assert_eq!(reopened.count(), 6);
    assert_eq!(reopened.used_slots(), 70);
    assert_eq!(reopened.read(0).unwrap(), None);
    assert_eq!(reopened.read(69).unwrap().unwrap().sample, sample(69));
    reopened.append(sample(100)).unwrap();
    assert_eq!(reopened.read(70).unwrap().unwrap().sample, sample(100));
}

#[test]
fn verification_detects_a_failed_program() {
    let mut flash = FakeFlash::new();
    flash.corrupt_after_commit = true;
    let mut log = Log::open(flash).unwrap();
    assert_eq!(log.append(sample(10)), Err(Error::VerifyFailed));
    assert_eq!(log.count(), 0);
    assert_eq!(log.used_slots(), 1);
}

#[test]
fn session_counter_never_wraps() {
    let mut flash = FakeFlash::new();
    let bytes = encode(Record {
        session: u32::MAX,
        sample: sample(10),
    });

    flash.write(0, &bytes).unwrap();
    assert!(matches!(Log::open(flash), Err(Error::SessionExhausted)));
}

#[test]
fn rejects_out_of_bounds_slots() {
    let mut log = Log::open(FakeFlash::new()).unwrap();
    assert_eq!(log.read(CAPACITY), Err(Error::SlotOutOfBounds));
    assert_eq!(log.read(usize::MAX), Err(Error::SlotOutOfBounds));
}

#[test]
fn crc_matches_the_standard_check_value() {
    assert_eq!(crc32(b"123456789"), 0xcbf4_3926);
}
