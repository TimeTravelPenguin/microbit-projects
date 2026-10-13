use core::cell::RefCell;
use embedded_hal::i2c::{AddressMode, ErrorType, I2c, Operation};

/// Shares an I²C bus between drivers running at the same interrupt priority.
///
/// Each transaction borrows the bus only until that transaction returns. This
/// keeps interrupts enabled, so unrelated input handlers can continue running
/// during a transfer. Never use these handles from multiple interrupt priorities;
/// overlapping transactions would fail the `RefCell` runtime borrow check.
pub struct SharedI2c<'bus, Bus> {
    bus: &'bus RefCell<Bus>,
}

impl<'bus, Bus> SharedI2c<'bus, Bus> {
    /// Creates a driver handle borrowing a bus owned by the application.
    pub const fn new(bus: &'bus RefCell<Bus>) -> Self {
        Self { bus }
    }
}

impl<Bus: ErrorType> ErrorType for SharedI2c<'_, Bus> {
    type Error = Bus::Error;
}

impl<Bus, Address> I2c<Address> for SharedI2c<'_, Bus>
where
    Bus: I2c<Address>,
    Address: AddressMode,
{
    fn transaction(
        &mut self,
        address: Address,
        operations: &mut [Operation<'_>],
    ) -> Result<(), Self::Error> {
        self.bus.borrow_mut().transaction(address, operations)
    }
}

#[cfg(test)]
mod tests {
    extern crate std;

    use std::vec::Vec;

    use super::*;
    use embedded_hal::i2c::{Error, ErrorKind};

    #[derive(Debug, Eq, PartialEq)]
    struct BusError;

    impl Error for BusError {
        fn kind(&self) -> ErrorKind {
            ErrorKind::Other
        }
    }

    #[derive(Default)]
    struct FakeBus {
        transactions: usize,
        addresses: Vec<u8>,
        writes: Vec<u8>,
        fail: bool,
    }

    impl ErrorType for FakeBus {
        type Error = BusError;
    }

    impl I2c for FakeBus {
        fn transaction(
            &mut self,
            address: u8,
            operations: &mut [Operation<'_>],
        ) -> Result<(), Self::Error> {
            if self.fail {
                return Err(BusError);
            }

            self.transactions += 1;
            self.addresses.push(address);

            for operation in operations {
                match operation {
                    Operation::Read(bytes) => bytes.fill(0xa5),
                    Operation::Write(bytes) => self.writes.extend_from_slice(bytes),
                }
            }

            Ok(())
        }
    }

    #[test]
    fn forwards_transaction_address_operations_and_read_data() {
        let bus = RefCell::new(FakeBus::default());
        let mut device = SharedI2c::new(&bus);
        let mut read = [0; 2];

        device.write_read(0x19, &[0x28], &mut read).unwrap();

        assert_eq!(read, [0xa5; 2]);
        let bus = bus.borrow();
        assert_eq!(bus.transactions, 1);
        assert_eq!(bus.addresses, [0x19]);
        assert_eq!(bus.writes, [0x28]);
    }

    #[test]
    fn shares_bus_between_handles_and_releases_each_borrow() {
        let bus = RefCell::new(FakeBus::default());
        let mut sensor = SharedI2c::new(&bus);
        let mut power = SharedI2c::new(&bus);

        sensor.write(0x19, &[0x20, 0x47]).unwrap();
        assert!(bus.try_borrow_mut().is_ok());
        power.write(0x70, &[0x00]).unwrap();
        assert!(bus.try_borrow_mut().is_ok());

        let bus = bus.borrow();
        assert_eq!(bus.transactions, 2);
        assert_eq!(bus.addresses, [0x19, 0x70]);
        assert_eq!(bus.writes, [0x20, 0x47, 0x00]);
    }

    #[test]
    fn preserves_bus_errors_and_releases_borrow_after_failure() {
        let bus = RefCell::new(FakeBus {
            fail: true,
            ..FakeBus::default()
        });

        let mut device = SharedI2c::new(&bus);

        assert_eq!(device.write(0x70, &[0x00]), Err(BusError));
        bus.borrow_mut().fail = false;
        device.write(0x70, &[0x00]).unwrap();
        assert_eq!(bus.borrow().transactions, 1);
    }
}
