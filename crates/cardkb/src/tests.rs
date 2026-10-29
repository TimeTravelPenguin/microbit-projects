use crate::{Error, Key};

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

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
struct BusError(u8);

impl I2cError for BusError {
    fn kind(&self) -> ErrorKind {
        ErrorKind::Other
    }
}

const TYPED_READS: &[Result<u8, BusError>] =
    &[Ok(0x0D), Ok(0), Ok(0x97), Err(BusError(7)), Ok(0x09)];
const RAW_READS: &[Result<u8, BusError>] = &[Ok(0), Ok(0x97), Err(BusError(7)), Ok(0x0D)];

struct FakeBus {
    outcomes: &'static [Result<u8, BusError>],
    read_count: usize,
}

impl ErrorType for FakeBus {
    type Error = BusError;
}

impl FakeBus {
    const fn new(outcomes: &'static [Result<u8, BusError>]) -> Self {
        Self {
            outcomes,
            read_count: 0,
        }
    }

    fn read_transaction(
        &mut self,
        address: u8,
        operations: &mut [Operation<'_>],
    ) -> Result<(), BusError> {
        assert_eq!(address, 0x5F);
        assert_eq!(operations.len(), 1);

        let Operation::Read(buffer) = &mut operations[0] else {
            panic!("expected one read operation");
        };

        assert_eq!(buffer.len(), 1);
        let outcome = self.outcomes[self.read_count];
        self.read_count += 1;

        match outcome {
            Ok(byte) => {
                buffer[0] = byte;
                Ok(())
            }
            Err(error) => Err(error),
        }
    }
}

#[cfg(feature = "blocking")]
impl embedded_hal::i2c::I2c for FakeBus {
    fn transaction(
        &mut self,
        address: u8,
        operations: &mut [Operation<'_>],
    ) -> Result<(), Self::Error> {
        self.read_transaction(address, operations)
    }
}

#[cfg(feature = "async")]
impl embedded_hal_async::i2c::I2c for FakeBus {
    async fn transaction(
        &mut self,
        address: u8,
        operations: &mut [Operation<'_>],
    ) -> Result<(), Self::Error> {
        let mut polled_once = false;
        poll_fn(|context| {
            if !polled_once {
                polled_once = true;
                context.waker().wake_by_ref();
                return Poll::Pending;
            }

            Poll::Ready(())
        })
        .await;

        self.read_transaction(address, operations)
    }
}

#[cfg(feature = "async")]
fn finish_read<Output>(future: impl Future<Output = Output>) -> Output {
    let mut future = pin!(future);
    let mut context = Context::from_waker(Waker::noop());
    assert!(matches!(future.as_mut().poll(&mut context), Poll::Pending));

    match future.as_mut().poll(&mut context) {
        Poll::Ready(result) => result,
        Poll::Pending => panic!("the fake bus should finish on the second poll"),
    }
}

#[cfg(feature = "blocking")]
#[test]
fn blocking_read_decodes_input_and_recovers_after_bus_errors() {
    let mut bus = FakeBus::new(TYPED_READS);

    {
        let mut keyboard = crate::blocking::CardKb::new(&mut bus);
        assert!(matches!(keyboard.read_key(), Ok(Some(Key::Enter))));
        assert!(matches!(keyboard.read_key(), Ok(None)));
        assert!(matches!(
            keyboard.read_key(),
            Err(Error::Decode(error)) if error.number == 0x97
        ));

        assert!(matches!(keyboard.read_key(), Err(Error::I2C(BusError(7)))));
        assert!(matches!(keyboard.read_key(), Ok(Some(Key::Tab))));
    }

    assert_eq!(bus.read_count, TYPED_READS.len());
}

#[cfg(feature = "blocking")]
#[test]
fn blocking_raw_read_preserves_bytes_and_bus_errors() {
    let mut keyboard = crate::blocking::CardKb::new(FakeBus::new(RAW_READS));
    assert!(matches!(keyboard.read_key_raw(), Ok(0)));
    assert!(matches!(keyboard.read_key_raw(), Ok(0x97)));
    assert!(matches!(
        keyboard.read_key_raw(),
        Err(Error::I2C(BusError(7)))
    ));

    assert!(matches!(keyboard.read_key_raw(), Ok(0x0D)));
}

#[cfg(feature = "async")]
#[test]
fn async_read_decodes_input_and_recovers_after_bus_errors() {
    let mut bus = FakeBus::new(TYPED_READS);

    {
        let mut keyboard = crate::r#async::CardKb::new(&mut bus);
        assert!(matches!(
            finish_read(keyboard.read_key()),
            Ok(Some(Key::Enter))
        ));

        assert!(matches!(finish_read(keyboard.read_key()), Ok(None)));
        assert!(matches!(
            finish_read(keyboard.read_key()),
            Err(Error::Decode(error)) if error.number == 0x97
        ));

        assert!(matches!(
            finish_read(keyboard.read_key()),
            Err(Error::I2C(BusError(7)))
        ));

        assert!(matches!(
            finish_read(keyboard.read_key()),
            Ok(Some(Key::Tab))
        ));
    }

    assert_eq!(bus.read_count, TYPED_READS.len());
}

#[cfg(feature = "async")]
#[test]
fn async_raw_read_preserves_bytes_and_bus_errors() {
    let mut keyboard = crate::r#async::CardKb::new(FakeBus::new(RAW_READS));
    assert!(matches!(finish_read(keyboard.read_key_raw()), Ok(0)));
    assert!(matches!(finish_read(keyboard.read_key_raw()), Ok(0x97)));
    assert!(matches!(
        finish_read(keyboard.read_key_raw()),
        Err(Error::I2C(BusError(7)))
    ));

    assert!(matches!(finish_read(keyboard.read_key_raw()), Ok(0x0D)));
}
