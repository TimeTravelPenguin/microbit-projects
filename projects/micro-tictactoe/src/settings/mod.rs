use heapless::String;
use serde::{Deserialize, Serialize};

#[cfg(target_arch = "arm")]
mod storage;

#[cfg(target_arch = "arm")]
pub use storage::{SettingsError, StorageError, init, load, save};

pub const NAME_CAPACITY: usize = 8;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct Settings {
    pub user_name: String<NAME_CAPACITY>,
}

impl Default for Settings {
    fn default() -> Self {
        Self {
            user_name: String::try_from("Player").expect("Failed to create default user name"),
        }
    }
}
