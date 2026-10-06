use super::*;

extern crate std;

use embedded_hal::{digital, i2c};
use std::{cell::RefCell, collections::VecDeque, rc::Rc, vec, vec::Vec};

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
struct Fault;

impl i2c::Error for Fault {
    fn kind(&self) -> i2c::ErrorKind {
        i2c::ErrorKind::Other
    }
}

impl digital::Error for Fault {
    fn kind(&self) -> digital::ErrorKind {
        digital::ErrorKind::Other
    }
}

#[derive(Debug)]
enum Step {
    Write(&'static [u8], Result<(), Fault>),
    Read(&'static [u8], Result<(), Fault>),
    Pin(Result<bool, Fault>),
    Delay(u32),
}

#[derive(Clone)]
struct Script(Rc<RefCell<VecDeque<Step>>>);

impl Script {
    fn next(&self) -> Step {
        self.0
            .borrow_mut()
            .pop_front()
            .expect("unexpected operation")
    }

    fn assert_finished(&self) {
        assert!(
            self.0.borrow().is_empty(),
            "missing operations: {:?}",
            self.0.borrow()
        );
    }
}

struct Bus(Script);
struct InterruptPin(Script);
struct Delay(Script);

impl i2c::ErrorType for Bus {
    type Error = Fault;
}

impl I2c for Bus {
    fn transaction(
        &mut self,
        address: u8,
        operations: &mut [i2c::Operation<'_>],
    ) -> Result<(), Self::Error> {
        assert_eq!(address, 0x70);
        assert_eq!(operations.len(), 1, "each operation needs its own STOP");

        match (&mut operations[0], self.0.next()) {
            (i2c::Operation::Write(bytes), Step::Write(expected, result)) => {
                assert_eq!(*bytes, expected);
                result
            }

            (i2c::Operation::Read(bytes), Step::Read(response, result)) => {
                assert_eq!(bytes.len(), 12);

                if result.is_ok() {
                    bytes.fill(0);
                    bytes[..response.len()].copy_from_slice(response);
                }

                result
            }

            (operation, step) => panic!("unexpected {operation:?}; expected {step:?}"),
        }
    }
}

impl digital::ErrorType for InterruptPin {
    type Error = Fault;
}

impl InputPin for InterruptPin {
    fn is_low(&mut self) -> Result<bool, Self::Error> {
        match self.0.next() {
            Step::Pin(result) => result,
            step => panic!("unexpected pin read; expected {step:?}"),
        }
    }

    fn is_high(&mut self) -> Result<bool, Self::Error> {
        self.is_low().map(|is_low| !is_low)
    }
}

impl DelayNs for Delay {
    fn delay_ns(&mut self, ns: u32) {
        match self.0.next() {
            Step::Delay(ms) => assert_eq!(ns, ms * 1_000_000),
            step => panic!("unexpected delay; expected {step:?}"),
        }
    }
}

fn setup(steps: Vec<Step>) -> (PowerManager<Bus, InterruptPin>, Delay, Script) {
    let script = Script(Rc::new(RefCell::new(steps.into())));
    let manager = PowerManager::new(Bus(script.clone()), InterruptPin(script.clone()));
    let delay = Delay(script.clone());

    (manager, delay, script)
}

fn receive(response: &'static [u8]) -> [Step; 3] {
    [
        Step::Pin(Ok(true)),
        Step::Write(&[0x00], Ok(())),
        Step::Read(response, Ok(())),
    ]
}

fn acknowledged_write(command: &'static [u8], response: &'static [u8]) -> [Step; 6] {
    [
        Step::Write(&[0x00], Ok(())),
        Step::Write(command, Ok(())),
        Step::Delay(1),
        Step::Pin(Ok(true)),
        Step::Write(&[0x00], Ok(())),
        Step::Read(response, Ok(())),
    ]
}

fn shutdown_commands() -> Vec<Step> {
    let mut steps = Vec::new();
    steps.extend(acknowledged_write(&[0x12, 0x08, 0x01, 0x00], &[0x13, 0x08]));
    steps.extend(acknowledged_write(&[0x12, 0x07, 0x01, 0x08], &[0x13, 0x07]));
    steps.push(Step::Delay(10));

    steps
}

#[test]
fn inactive_interrupt_does_not_access_i2c() {
    let (mut manager, _, script) = setup(vec![Step::Pin(Ok(false))]);

    assert_eq!(manager.poll(), Ok(false));
    script.assert_finished();
}

#[test]
fn pending_boot_event_latches_shutdown_without_further_io() {
    let (mut manager, _, script) = setup(receive(&[0x11, 0x09, 0x01, 0x03]).into());

    assert_eq!(manager.poll(), Ok(true));
    assert_eq!(manager.poll(), Ok(true));
    assert_eq!(manager.poll(), Ok(true));
    script.assert_finished();
}

#[test]
fn other_events_malformed_events_and_transient_errors_do_not_request_shutdown() {
    let responses: &[&[u8]] = &[
        &[0x11, 0x09, 0x01, 0x01],
        &[0x11, 0x09, 0x01, 0x02],
        &[0x11, 0x09, 0x02, 0x03],
        &[0x11, 0x08, 0x01, 0x03],
        &[0x13, 0x09, 0x01, 0x03],
        &[0x20, 0x39],
        &[0x20, 0x31],
    ];
    let steps = responses
        .iter()
        .flat_map(|response| receive(response))
        .collect();
    let (mut manager, _, script) = setup(steps);

    for _ in responses {
        assert_eq!(manager.poll(), Ok(false));
    }

    script.assert_finished();
}

#[test]
fn interface_errors_are_reported_and_later_poll_can_receive_shutdown() {
    let mut steps = Vec::from(receive(&[0x20, 0x30]));
    steps.extend(receive(&[0x11, 0x09, 0x01, 0x03]));
    let (mut manager, _, script) = setup(steps);

    assert_eq!(manager.poll(), Err(Error::Interface(0x30)));
    assert_eq!(manager.poll(), Ok(true));
    script.assert_finished();
}

#[test]
fn shutdown_acknowledges_led_then_power_mode_and_waits_for_interrupt_release() {
    let mut steps = Vec::from(receive(&[0x11, 0x09, 0x01, 0x03]));
    steps.extend(shutdown_commands());
    steps.extend([Step::Pin(Ok(true)), Step::Delay(1), Step::Pin(Ok(false))]);
    let (mut manager, mut delay, script) = setup(steps);

    assert_eq!(manager.poll(), Ok(true));
    assert_eq!(manager.prepare_power_off(&mut delay), Ok(()));
    let _ = manager.into_parts();
    script.assert_finished();
}

#[test]
fn command_wait_retries_busy_and_latches_interleaved_shutdown_event() {
    let mut steps = vec![
        Step::Write(&[0x00], Ok(())),
        Step::Write(&[0x12, 0x08, 0x01, 0x00], Ok(())),
        Step::Delay(1),
    ];
    steps.extend(receive(&[0x20, 0x39]));
    steps.push(Step::Delay(1));
    steps.extend(receive(&[0x20, 0x31]));
    steps.push(Step::Delay(1));
    steps.extend(receive(&[0x11, 0x09, 0x01, 0x03]));
    steps.push(Step::Delay(1));
    steps.extend(receive(&[0x13, 0x08]));
    steps.extend(acknowledged_write(&[0x12, 0x07, 0x01, 0x08], &[0x13, 0x07]));
    steps.extend([Step::Delay(10), Step::Pin(Ok(false))]);
    let (mut manager, mut delay, script) = setup(steps);

    assert_eq!(manager.prepare_power_off(&mut delay), Ok(()));
    assert_eq!(manager.poll(), Ok(true));
    script.assert_finished();
}

#[test]
fn missing_ack_times_out_before_sending_power_down() {
    let mut steps = vec![
        Step::Write(&[0x00], Ok(())),
        Step::Write(&[0x12, 0x08, 0x01, 0x00], Ok(())),
    ];

    for _ in 0..50 {
        steps.extend([Step::Delay(1), Step::Pin(Ok(false))]);
    }

    let (mut manager, mut delay, script) = setup(steps);

    assert_eq!(manager.prepare_power_off(&mut delay), Err(Error::Timeout));
    script.assert_finished();
}

#[test]
fn ack_timeout_retry_waits_for_existing_reply_without_resending_command() {
    let mut steps = vec![
        Step::Write(&[0x00], Ok(())),
        Step::Write(&[0x12, 0x08, 0x01, 0x00], Ok(())),
    ];

    for _ in 0..50 {
        steps.extend([Step::Delay(1), Step::Pin(Ok(false))]);
    }

    steps.push(Step::Delay(1));
    steps.extend(receive(&[0x13, 0x08]));
    steps.extend(acknowledged_write(&[0x12, 0x07, 0x01, 0x08], &[0x13, 0x07]));
    steps.extend([Step::Delay(10), Step::Pin(Ok(false))]);
    let (mut manager, mut delay, script) = setup(steps);

    assert_eq!(manager.prepare_power_off(&mut delay), Err(Error::Timeout));
    assert_eq!(manager.prepare_power_off(&mut delay), Ok(()));
    script.assert_finished();
}

#[test]
fn held_interrupt_prevents_successful_shutdown_preparation() {
    let mut steps = shutdown_commands();

    for _ in 0..50 {
        steps.extend([Step::Pin(Ok(true)), Step::Delay(1)]);
    }

    let (mut manager, mut delay, script) = setup(steps);

    assert_eq!(
        manager.prepare_power_off(&mut delay),
        Err(Error::InterruptActive)
    );
    script.assert_finished();
}

#[test]
fn shutdown_failure_keeps_request_latched_for_retry() {
    let mut steps = Vec::from(receive(&[0x11, 0x09, 0x01, 0x03]));
    steps.extend([
        Step::Write(&[0x00], Ok(())),
        Step::Write(&[0x12, 0x08, 0x01, 0x00], Err(Fault)),
    ]);
    steps.extend(shutdown_commands());
    steps.push(Step::Pin(Ok(false)));
    let (mut manager, mut delay, script) = setup(steps);

    assert_eq!(manager.poll(), Ok(true));
    assert_eq!(
        manager.prepare_power_off(&mut delay),
        Err(Error::I2c(Fault))
    );
    assert_eq!(manager.poll(), Ok(true));
    assert_eq!(manager.prepare_power_off(&mut delay), Ok(()));
    script.assert_finished();
}

#[test]
fn failed_ack_read_retries_the_pending_reply_without_resending_command() {
    let mut steps = vec![
        Step::Write(&[0x00], Ok(())),
        Step::Write(&[0x12, 0x08, 0x01, 0x00], Ok(())),
        Step::Delay(1),
        Step::Pin(Ok(true)),
        Step::Write(&[0x00], Ok(())),
        Step::Read(&[], Err(Fault)),
        Step::Delay(1),
    ];
    steps.extend(receive(&[0x13, 0x08]));
    steps.extend(acknowledged_write(&[0x12, 0x07, 0x01, 0x08], &[0x13, 0x07]));
    steps.extend([Step::Delay(10), Step::Pin(Ok(false))]);
    let (mut manager, mut delay, script) = setup(steps);

    assert_eq!(
        manager.prepare_power_off(&mut delay),
        Err(Error::I2c(Fault))
    );
    assert_eq!(manager.prepare_power_off(&mut delay), Ok(()));
    script.assert_finished();
}

#[test]
fn retry_after_power_down_only_waits_for_interrupt_release() {
    let mut steps = shutdown_commands();

    for _ in 0..50 {
        steps.extend([Step::Pin(Ok(true)), Step::Delay(1)]);
    }

    steps.push(Step::Pin(Ok(false)));
    let (mut manager, mut delay, script) = setup(steps);

    assert_eq!(
        manager.prepare_power_off(&mut delay),
        Err(Error::InterruptActive)
    );
    assert_eq!(manager.prepare_power_off(&mut delay), Ok(()));
    script.assert_finished();
}

#[test]
fn pin_and_i2c_failures_are_reported() {
    let (mut manager, _, script) = setup(vec![Step::Pin(Err(Fault))]);

    assert_eq!(manager.poll(), Err(Error::Pin(Fault)));
    script.assert_finished();

    let (mut manager, _, script) = setup(vec![
        Step::Pin(Ok(true)),
        Step::Write(&[0x00], Ok(())),
        Step::Read(&[], Err(Fault)),
    ]);

    assert_eq!(manager.poll(), Err(Error::I2c(Fault)));
    script.assert_finished();
}
