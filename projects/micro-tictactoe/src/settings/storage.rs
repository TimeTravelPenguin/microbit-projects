use core::cell::RefCell;

use cortex_m::interrupt::{self, Mutex};
use embassy_embedded_hal::adapter::BlockingAsync;
use embassy_futures::block_on;
use embassy_nrf::{
    Peri,
    nvmc::{Error as NvmcError, Nvmc},
    peripherals::NVMC,
};
use sequential_storage::{
    cache::{Cache, Uncached},
    map::{MapConfig, MapStorage, PostcardValue},
};
use thiserror::Error;

use super::{NAME_CAPACITY, Settings};

const SETTINGS_FLASH_SIZE: u32 = 8192;
const SETTINGS_KEY: u8 = 0;

type Storage =
    MapStorage<u8, BlockingAsync<Nvmc<'static>>, Cache<Uncached, Uncached, Uncached, u8>>;

pub type StorageError = sequential_storage::Error<NvmcError>;

static STORAGE: Mutex<RefCell<Option<Storage>>> = Mutex::new(RefCell::new(None));

#[derive(Debug, Error)]
pub enum SettingsError {
    #[error("Settings storage is uninitialized")]
    Uninitialized,
    #[error("Settings storage is already initialized")]
    AlreadyInitialized,
    #[error("Failed to read settings from flash")]
    ReadError(StorageError),
    #[error("Failed to write settings to flash")]
    WriteError(StorageError),
}

/*
Info about the maximum size of a serialized Settings struct in Postcard format.

|     Field type     | Maximum Postcard bytes |
|--------------------|-----------------------:|
| `bool`, `u8`, `i8` |           1            |
| `u16`, `i16`       |           3            |
| `u32`, `i32`       |           5            |
| `u64`, `i64`       |           10           |
| `f32`              |           4            |
| `String<N>`        | N + length-prefix size |

The string length prefix is 1 byte for capacities below 128,
then grows as needed. Integers use variable-length encoding.
*/

// Include the u8 key, then round up to four-byte alignment.
const SETTINGS_SCRATCH_SIZE: usize = (1 + SETTINGS_MAX_SERIALIZED_SIZE).next_multiple_of(4);
const SETTINGS_MAX_SERIALIZED_SIZE: usize = 1 + NAME_CAPACITY; // length prefix + contents

impl PostcardValue<'_> for Settings {}

pub fn init(nvmc: Peri<'static, NVMC>) -> Result<(), SettingsError> {
    let nvmc = Nvmc::new(nvmc);

    let storage = MapStorage::new(
        BlockingAsync::new(nvmc),
        MapConfig::new(settings_flash_range()),
        Cache::new_uncached(),
    );

    interrupt::free(|ctx| {
        let mut slot = STORAGE.borrow(ctx).borrow_mut();

        if slot.is_some() {
            return Err(SettingsError::AlreadyInitialized);
        }

        *slot = Some(storage);

        Ok(())
    })
}

pub fn load() -> Result<Settings, SettingsError> {
    interrupt::free(|ctx| {
        let mut slot = STORAGE.borrow(ctx).borrow_mut();
        let storage = slot.as_mut().ok_or(SettingsError::Uninitialized)?;

        let mut scratch = [0u8; SETTINGS_SCRATCH_SIZE];

        let settings = block_on(storage.fetch_item::<Settings>(&mut scratch, &SETTINGS_KEY))
            .map_err(SettingsError::ReadError)?
            .unwrap_or_default();

        Ok(settings)
    })
}

pub fn save(settings: &Settings) -> Result<(), SettingsError> {
    interrupt::free(|ctx| {
        let mut slot = STORAGE.borrow(ctx).borrow_mut();
        let storage = slot.as_mut().ok_or(SettingsError::Uninitialized)?;

        let mut scratch = [0u8; SETTINGS_SCRATCH_SIZE];

        block_on(storage.store_item(&mut scratch, &SETTINGS_KEY, settings))
            .map_err(SettingsError::WriteError)
    })
}

fn settings_flash_range() -> core::ops::Range<u32> {
    unsafe extern "C" {
        static _settings_start: u8;
        static _settings_end: u8;
    }

    let start = core::ptr::addr_of!(_settings_start) as u32;
    let end = core::ptr::addr_of!(_settings_end) as u32;

    assert_eq!(
        end - start,
        SETTINGS_FLASH_SIZE,
        "Settings flash size mismatch"
    );

    start..end
}
