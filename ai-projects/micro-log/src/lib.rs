#![no_std]

//! A small, append-only sensor log in a dedicated flash partition.
//!
//! Flash starts erased (`0xff`). Each sample uses a fresh 64-byte slot: first
//! its contents and checksum, then a separate commit word. On boot, scanning
//! skips unfinished or damaged records and never overwrites a used slot.
//! Nothing is erased automatically, including when the partition fills up.

use embedded_storage::nor_flash::NorFlash;

/// The firmware reserves this many bytes independently of its program image.
pub const REGION_SIZE: usize = 64 * 1024;
/// Every record occupies sixteen flash words, including the final commit word.
pub const SLOT_SIZE: usize = 64;
pub const CAPACITY: usize = REGION_SIZE / SLOT_SIZE;

const MAGIC: [u8; 4] = *b"MBLG";
const VERSION: u32 = 1;
const COMMIT: [u8; 4] = *b"DONE";
const CRC_OFFSET: usize = 56;
const COMMIT_OFFSET: usize = 60;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct Sample {
    /// Time since this boot, rather than a calendar timestamp.
    pub uptime_ms: u32,
    pub acceleration_mg: [i32; 3],
    pub magnetic_field_nt: [i32; 3],
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct Record {
    /// A new session starts whenever the log is opened after a reboot.
    pub session: u32,
    pub sample: Sample,
}

#[derive(Debug, Eq, PartialEq)]
pub enum Error<FlashError> {
    Flash(FlashError),
    Full,
    SessionExhausted,
    SlotOutOfBounds,
    VerifyFailed,
}

pub struct Log<Flash> {
    flash: Flash,
    next_slot: usize,
    count: usize,
    session: u32,
}

impl<Flash: NorFlash> Log<Flash> {
    /// Open an existing partition without changing any flash contents.
    ///
    /// Addresses are relative to the supplied flash partition, which must be
    /// at least 64 KiB. This example uses one-byte reads, four-byte writes, and
    /// a whole number of erase pages. Supplying the dedicated partition keeps
    /// writes away from the firmware itself.
    pub fn open(mut flash: Flash) -> Result<Self, Error<Flash::Error>> {
        assert_eq!(Flash::READ_SIZE, 1);
        assert_eq!(Flash::WRITE_SIZE, 4);
        assert!(Flash::ERASE_SIZE > 0);
        assert_eq!(REGION_SIZE % Flash::ERASE_SIZE, 0);
        assert!(flash.capacity() >= REGION_SIZE);

        let mut next_slot = 0;
        let mut count = 0;
        let mut last_session = 0;
        let mut bytes = [0xff; SLOT_SIZE];

        // Scan every slot: a failed erase can leave blank holes before later
        // records, so stopping at the first erased slot would be unsafe.
        for slot in 0..CAPACITY {
            flash
                .read((slot * SLOT_SIZE) as u32, &mut bytes)
                .map_err(Error::Flash)?;

            if bytes.iter().any(|byte| *byte != 0xff) {
                next_slot = slot + 1;
            }

            if let Some(record) = decode(&bytes) {
                count += 1;
                last_session = last_session.max(record.session);
            }
        }

        let session = last_session.checked_add(1).ok_or(Error::SessionExhausted)?;

        Ok(Self {
            flash,
            next_slot,
            count,
            session,
        })
    }

    /// Number of valid records found at boot or successfully appended.
    pub fn count(&self) -> usize {
        self.count
    }

    /// Slots consumed, including damaged rows and gaps before the last row.
    pub fn used_slots(&self) -> usize {
        self.next_slot
    }

    pub fn capacity(&self) -> usize {
        CAPACITY
    }

    pub fn session(&self) -> u32 {
        self.session
    }

    pub fn is_full(&self) -> bool {
        self.next_slot == CAPACITY
    }

    /// Append once, without erasing or wrapping around to older records.
    ///
    /// The commit word is programmed separately and last. CRC32 detects torn
    /// or damaged contents. The slot is consumed even if a write fails, so a
    /// retry never programs the same flash word a second time.
    pub fn append(&mut self, sample: Sample) -> Result<(), Error<Flash::Error>> {
        if self.is_full() {
            return Err(Error::Full);
        }

        let slot = self.next_slot;
        self.next_slot += 1;

        let record = Record {
            session: self.session,
            sample,
        };

        let bytes = encode(record);
        let offset = (slot * SLOT_SIZE) as u32;
        self.flash
            .write(offset, &bytes[..COMMIT_OFFSET])
            .map_err(Error::Flash)?;
        self.flash
            .write(offset + COMMIT_OFFSET as u32, &bytes[COMMIT_OFFSET..])
            .map_err(Error::Flash)?;

        // In particular, the nRF HAL's read waits for NVMC to become ready.
        // Readback also catches a write that returned success but lost data.
        if self.read(slot)? != Some(record) {
            return Err(Error::VerifyFailed);
        }

        self.count += 1;

        Ok(())
    }

    /// Read a physical slot. Erased, incomplete, or damaged rows return None.
    ///
    /// Iterate `0..used_slots()` and skip None to export all intact records.
    pub fn read(&mut self, slot: usize) -> Result<Option<Record>, Error<Flash::Error>> {
        if slot >= CAPACITY {
            return Err(Error::SlotOutOfBounds);
        }

        let mut bytes = [0xff; SLOT_SIZE];
        self.flash
            .read((slot * SLOT_SIZE) as u32, &mut bytes)
            .map_err(Error::Flash)?;

        Ok(decode(&bytes))
    }

    /// Explicitly erase the entire partition and restart with session 1.
    ///
    /// Erasing is not transactional: a power cut may preserve some old rows
    /// and erase others. Reopening scans the whole partition and resumes after
    /// the last nonblank slot. After an erase error, reopen the log before
    /// using its counts; appending is disabled until a successful clear/reopen.
    pub fn clear(&mut self) -> Result<(), Error<Flash::Error>> {
        // An interrupted erase may dirty previously blank pages. Block writes
        // unless the whole erase succeeds, or a fresh scan reconstructs them.
        self.next_slot = CAPACITY;
        self.count = 0;
        self.flash
            .erase(0, REGION_SIZE as u32)
            .map_err(Error::Flash)?;

        self.next_slot = 0;
        self.session = 1;

        Ok(())
    }

    pub fn into_inner(self) -> Flash {
        self.flash
    }
}

fn encode(record: Record) -> [u8; SLOT_SIZE] {
    let mut bytes = [0xff; SLOT_SIZE];
    bytes[..4].copy_from_slice(&MAGIC);
    bytes[4..8].copy_from_slice(&VERSION.to_le_bytes());
    bytes[8..12].copy_from_slice(&record.session.to_le_bytes());
    bytes[12..16].copy_from_slice(&record.sample.uptime_ms.to_le_bytes());

    for (axis, value) in record
        .sample
        .acceleration_mg
        .iter()
        .chain(record.sample.magnetic_field_nt.iter())
        .enumerate()
    {
        let offset = 16 + axis * 4;
        bytes[offset..offset + 4].copy_from_slice(&value.to_le_bytes());
    }

    // Bytes 40..56 are reserved for a future format version.
    let checksum = crc32(&bytes[..CRC_OFFSET]);
    bytes[CRC_OFFSET..COMMIT_OFFSET].copy_from_slice(&checksum.to_le_bytes());
    bytes[COMMIT_OFFSET..].copy_from_slice(&COMMIT);

    bytes
}

fn decode(bytes: &[u8; SLOT_SIZE]) -> Option<Record> {
    if bytes[..4] != MAGIC
        || read_u32(bytes, 4) != VERSION
        || bytes[COMMIT_OFFSET..] != COMMIT
        || crc32(&bytes[..CRC_OFFSET]) != read_u32(bytes, CRC_OFFSET)
    {
        return None;
    }

    Some(Record {
        session: read_u32(bytes, 8),
        sample: Sample {
            uptime_ms: read_u32(bytes, 12),
            acceleration_mg: [
                read_u32(bytes, 16) as i32,
                read_u32(bytes, 20) as i32,
                read_u32(bytes, 24) as i32,
            ],
            magnetic_field_nt: [
                read_u32(bytes, 28) as i32,
                read_u32(bytes, 32) as i32,
                read_u32(bytes, 36) as i32,
            ],
        },
    })
}

fn read_u32(bytes: &[u8], offset: usize) -> u32 {
    u32::from_le_bytes(bytes[offset..offset + 4].try_into().unwrap())
}

/// CRC-32/ISO-HDLC, the same polynomial used by ZIP and Ethernet.
fn crc32(bytes: &[u8]) -> u32 {
    let mut crc = u32::MAX;

    for byte in bytes {
        crc ^= u32::from(*byte);

        for _bit in 0..8 {
            let low_bit = crc & 1;
            crc >>= 1;

            if low_bit != 0 {
                crc ^= 0xedb8_8320;
            }
        }
    }

    !crc
}

#[cfg(test)]
extern crate std;

#[cfg(test)]
mod tests;
