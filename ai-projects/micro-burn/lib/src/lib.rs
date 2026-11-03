//! A reusable training pager for Burn applications.
//!
//! The default build is a dependency-free `no_std` wire protocol for firmware.
//! Enable `host` for the Bluetooth monitor and `burn` for Burn 0.22.0-pre.4 hooks.
//! Training reports never wait for a Bluetooth connection.

#![cfg_attr(not(feature = "host"), no_std)]

pub mod protocol;

#[cfg(feature = "host")]
pub mod host;

#[cfg(feature = "burn")]
pub mod burn;
