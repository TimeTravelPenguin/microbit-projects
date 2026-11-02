extern crate std;

use std::vec::Vec;

#[cfg(feature = "async")]
use core::{
    future::{Future, poll_fn},
    pin::pin,
    task::{Context, Poll, Waker},
};

#[cfg(all(feature = "blocking", not(feature = "async")))]
use embedded_hal::i2c::{Error as I2cError, ErrorKind, ErrorType, Operation};

#[cfg(feature = "async")]
use embedded_hal_async::i2c::{Error as I2cError, ErrorKind, ErrorType, Operation};

use crate::{DISPLAY_I2C_ADDR, DISPLAY_SIZE, DisplayError};

#[derive(Debug)]
struct BusError;

impl I2cError for BusError {
    fn kind(&self) -> ErrorKind {
        ErrorKind::Other
    }
}

#[derive(Default)]
struct FakeBus {
    writes: Vec<Vec<u8>>,
    fail_at: Option<usize>,
}

impl ErrorType for FakeBus {
    type Error = BusError;
}

impl FakeBus {
    fn write_transaction(
        &mut self,
        address: u8,
        operations: &mut [Operation<'_>],
    ) -> Result<(), BusError> {
        assert_eq!(address, DISPLAY_I2C_ADDR);
        assert_eq!(operations.len(), 1);

        let Operation::Write(bytes) = &operations[0] else {
            panic!("display initialization must only write to the bus");
        };

        let write_index = self.writes.len();
        self.writes.push(bytes.to_vec());

        if self.fail_at == Some(write_index) {
            return Err(BusError);
        }

        Ok(())
    }
}

#[cfg(feature = "blocking")]
impl embedded_hal::i2c::I2c for FakeBus {
    fn transaction(
        &mut self,
        address: u8,
        operations: &mut [Operation<'_>],
    ) -> Result<(), Self::Error> {
        self.write_transaction(address, operations)
    }
}

#[cfg(feature = "async")]
impl embedded_hal_async::i2c::I2c for FakeBus {
    async fn transaction(
        &mut self,
        address: u8,
        operations: &mut [Operation<'_>],
    ) -> Result<(), Self::Error> {
        let mut yielded = false;
        poll_fn(|context| {
            if !yielded {
                yielded = true;
                context.waker().wake_by_ref();

                return Poll::Pending;
            }

            Poll::Ready(())
        })
        .await;

        self.write_transaction(address, operations)
    }
}

#[cfg(feature = "async")]
fn finish<Output>(future: impl Future<Output = Output>) -> Output {
    let mut future = pin!(future);
    let mut context = Context::from_waker(Waker::noop());
    assert!(future.as_mut().poll(&mut context).is_pending());

    loop {
        if let Poll::Ready(output) = future.as_mut().poll(&mut context) {
            return output;
        }
    }
}

fn assert_blank_display(writes: &[Vec<u8>]) {
    assert_eq!(
        writes.first().map(Vec::as_slice),
        Some([0, 0xAE].as_slice())
    );
    assert_eq!(writes.last().map(Vec::as_slice), Some([0, 0xAF].as_slice()));

    let mut pixel_bytes = 0;

    for bytes in writes.iter().filter(|bytes| bytes[0] == 0x40) {
        assert!(bytes[1..].iter().all(|byte| *byte == 0));
        pixel_bytes += bytes.len() - 1;
    }

    assert_eq!(pixel_bytes, 128 * 64 / 8);
}

fn failure_indices(writes: &[Vec<u8>]) -> [usize; 3] {
    [
        0,
        writes
            .iter()
            .position(|bytes| bytes[0] == 0x40)
            .expect("initialization must flush the framebuffer"),
        writes.len() - 1,
    ]
}

#[cfg(feature = "blocking")]
#[test]
fn blocking_initialization_clears_all_pixels_and_turns_display_on() {
    let mut bus = FakeBus::default();
    let _display = crate::blocking::init_display(&mut bus, DISPLAY_SIZE).unwrap();

    assert_blank_display(&bus.writes);
}

#[cfg(feature = "blocking")]
#[test]
fn blocking_bus_errors_stop_initialization_clearing_and_enabling() {
    let mut successful_bus = FakeBus::default();
    let _display = crate::blocking::init_display(&mut successful_bus, DISPLAY_SIZE).unwrap();

    for fail_at in failure_indices(&successful_bus.writes) {
        let mut bus = FakeBus {
            fail_at: Some(fail_at),
            ..FakeBus::default()
        };

        let result = crate::blocking::init_display(&mut bus, DISPLAY_SIZE);
        assert!(matches!(result, Err(DisplayError::BusWriteError)));
        assert_eq!(bus.writes.len(), fail_at + 1);
    }
}

#[cfg(feature = "async")]
#[test]
fn async_initialization_clears_all_pixels_and_turns_display_on() {
    let mut bus = FakeBus::default();
    let _display = finish(crate::r#async::init_display(&mut bus, DISPLAY_SIZE)).unwrap();

    assert_blank_display(&bus.writes);
}

#[cfg(feature = "async")]
#[test]
fn async_bus_errors_stop_initialization_clearing_and_enabling() {
    let mut successful_bus = FakeBus::default();
    let _display = finish(crate::r#async::init_display(
        &mut successful_bus,
        DISPLAY_SIZE,
    ))
    .unwrap();

    for fail_at in failure_indices(&successful_bus.writes) {
        let mut bus = FakeBus {
            fail_at: Some(fail_at),
            ..FakeBus::default()
        };

        let result = finish(crate::r#async::init_display(&mut bus, DISPLAY_SIZE));
        assert!(matches!(result, Err(DisplayError::BusWriteError)));
        assert_eq!(bus.writes.len(), fail_at + 1);
    }
}
