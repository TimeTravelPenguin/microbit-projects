#![no_std]

pub mod app;
pub mod game;
#[cfg(target_arch = "arm")]
pub mod hardware;
pub mod input;
pub mod settings;
pub mod ui;
