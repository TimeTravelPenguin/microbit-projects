use core::cell::RefCell;

use cortex_m::interrupt::{self, Mutex};
use embassy_embedded_hal::adapter::BlockingAsync;
use embassy_futures::block_on;
use heapless::String;
use microbit::pac::{self, NVMC};
use nrf52833_hal::nvmc::{Nvmc, NvmcError};
use sequential_storage::{
    cache::{Cache, Uncached},
    map::{MapConfig, MapStorage, PostcardValue},
};
use serde::{Deserialize, Serialize};
use thiserror::Error;

const SETTINGS_FLASH_SIZE: u32 = 8192;
const SETTINGS_KEY: u8 = 0;

type Storage =
    MapStorage<u8, BlockingAsync<Nvmc<pac::NVMC>>, Cache<Uncached, Uncached, Uncached, u8>>;

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

const NAME_CAPACITY: usize = 8;

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

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Settings {
    pub user_name: String<NAME_CAPACITY>, // Size: 1 + NAME_CAPACITY
}

impl PostcardValue<'_> for Settings {}

pub fn init(nvmc: pac::NVMC) -> Result<(), SettingsError> {
    let nvmc = Nvmc::new(nvmc, unsafe { settings_flash() });

    let storage = MapStorage::new(
        BlockingAsync::new(nvmc),
        const { MapConfig::new(0..SETTINGS_FLASH_SIZE) },
        Cache::new_uncached(),
    );

    let mut err = false;

    interrupt::free(|ctx| {
        let mut slot = STORAGE.borrow(ctx).borrow_mut();

        if slot.is_some() {
            err = true;
            return;
        }

        *slot = Some(storage);
    });

    if err {
        return Err(SettingsError::AlreadyInitialized);
    }

    Ok(())
}

pub fn load() -> Result<Settings, SettingsError> {
    interrupt::free(|ctx| {
        let mut slot = STORAGE.borrow(ctx).borrow_mut();
        let storage = slot.as_mut().expect("Call settings::init first");
        let mut scratch = [0u8; SETTINGS_SCRATCH_SIZE];

        let settings = block_on(storage.fetch_item::<Settings>(&mut scratch, &SETTINGS_KEY))
            .map_err(SettingsError::ReadError)
            .map(|s| {
                s.unwrap_or_else(|| Settings {
                    user_name: String::try_from("Player")
                        .expect("Failed to create default user name"),
                })
            })?;

        Ok(settings)
    })
}

pub fn save(settings: &Settings) -> Result<(), SettingsError> {
    interrupt::free(|ctx| {
        let mut slot = STORAGE.borrow(ctx).borrow_mut();
        let storage = slot.as_mut().expect("Call settings::init first");
        let mut scratch = [0u8; SETTINGS_SCRATCH_SIZE];

        block_on(storage.store_item(&mut scratch, &SETTINGS_KEY, settings))
            .map_err(SettingsError::WriteError)
    })
}

unsafe fn settings_flash() -> &'static mut [u8] {
    unsafe extern "C" {
        static mut _settings_start: u8;
        static _settings_end: u8;
    }

    let start = core::ptr::addr_of_mut!(_settings_start);
    let length = core::ptr::addr_of!(_settings_end) as usize - start as usize;
    assert_eq!(
        length, SETTINGS_FLASH_SIZE as usize,
        "Settings flash size mismatch"
    );

    // SAFETY: caller guarantees exclusive access to these reserved flash pages.
    unsafe { core::slice::from_raw_parts_mut(start, length) }
}
