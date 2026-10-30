//! Shared control mappings, with hardware sampling isolated to the ARM target.

mod navigation;

pub use navigation::{
    NavigationKey, button_action, cardkb_action, firmware_action, navigation_action,
};

#[cfg(target_arch = "arm")]
pub mod buttons;
