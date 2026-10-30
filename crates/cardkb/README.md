# CardKB

This crate exists to provide an abstract interface for the CardKB.

## Why does this crate exist?

Originally, I was using [`cardkb-driver`][cardkb-driver]. However, it only provides an
async interface and raw keyboard values. Furthermore, it did not take ownership over the
I2C interface, which made it awkward to use without passing around both the `CardKb` type
_and_ the I2C interface together.

## Usage

Below is a simple abstract example on how to use this crate. The example uses the
`"blocking"` feature.

```rs
use cardkb::{CardKb, Key, KeyExt};

let mut cardkb = CardKb(interface);
let key: Option<Key> = cardkb.read_key().unwrap()
// if async:
// let key: Option<Key> = cardkb.read_key().await.unwrap()

if key.is_none() {
    // no key pressed
}

// `KeyExt` gives `is_key` for `Option<Key>`
if key.is_key(Key::Asterisk) {
    // asterisk was pressed!
}
```

This crate includes both async and synchronous implementations of `CardKb`, which takes
ownership over the I2C interface. If you need to share the interface, wrap it in something
like [`RefCellDevice`][RefCellDevice] from the [`embedded-hal-bus`][embedded-hal-bus]
crate. You can use `CardKb` by including the feature `"blocking"` or `"async"` (default is
blocking).

When reading from the CardKB, the returned result is a `Result<Option<Key>, cardkb::Error>`.
When no key is pressed, the value will be `Some(None)`. If a valid key is pressed, the
value will be `Some(Ok(k))`, where `k` is of type `cardkb::Key`.

This crate was tested on a CardKB v1.1, but older versions should still work. Importantly,
`Key::Delete` exists solely for backwards compatibility.

## Features

| Feature                | Description                                        |
| ---------------------- | -------------------------------------------------- |
| `"blocking"` (default) | Enables the synchronous implementation of `CardKb` |
| `"async"`              | Enables the async implementation of `CardKb`       |

Note: When only one of `"blocking"` or `"async"` is enabled, `CardKb` can be directly
imported from the crate. Otherwise, you will need to import it from the particular module.

```rs
// If only one of `"blocking"` or `"async"` is enabled
use cardkb::CardKb;

// If both are enabled
use cardkb::async::CardKb as CardKbAsync;
use cardkb::blocking::CardKb as CardKbBlocking;
```

[cardkb-driver]: https://crates.io/crates/cardkb-driver
[RefCellDevice]: https://docs.rs/embedded-hal-bus/latest/embedded_hal_bus/i2c/struct.RefCellDevice.html
[embedded-hal-bus]: https://crates.io/crates/embedded-hal-bus
