#![no_main]
#![no_std]

mod line;

use cortex_m_rt::entry;
use heapless::Vec;
use line::{LineError, LineReader};
use microbit::hal::uarte::{self, Baudrate, Parity};
use microbit::hal::{Timer, timer};
use panic_rtt_target as _;
use rtt_target::{rprintln, rtt_init_print};
use thiserror::Error;

use serial_setup::UartePort;

const INPUT_TIMEOUT_US: u32 = 10_000_000;

#[derive(Debug, Error)]
enum SerialError {
    #[error("UART error: {0}")]
    Uart(#[from] uarte::Error),
    #[error(transparent)]
    Input(#[from] LineError),
}

#[entry]
fn main() -> ! {
    rtt_init_print!();
    let board = microbit::Board::take().unwrap();

    let mut serial = {
        let serial = uarte::Uarte::new(
            board.UARTE0,
            board.uart.into(),
            Parity::EXCLUDED,
            Baudrate::BAUD115200,
        );

        UartePort::new(serial)
    };

    let mut line_reader = LineReader::<32>::new();
    let mut idle_timer = Timer::new(board.TIMER0);

    loop {
        let mut buffer = match read_line(&mut serial, &mut line_reader, &mut idle_timer) {
            Ok(buffer) => buffer,
            Err(error) => {
                rprintln!("Error reading from serial: {:?}", error);
                continue;
            }
        };

        buffer.reverse();

        let result = serial
            .write_all(&buffer)
            .and_then(|_| serial.write_crlf())
            .and_then(|_| serial.flush());

        if let Err(error) = result {
            rprintln!("Error writing to serial: {:?}", error);
        }
    }
}

fn read_line<T, I, const N: usize>(
    serial: &mut UartePort<T>,
    line_reader: &mut LineReader<N>,
    idle_timer: &mut Timer<I>,
) -> Result<Vec<u8, N>, SerialError>
where
    T: uarte::Instance,
    I: timer::Instance,
{
    let mut timer_active = false;

    loop {
        match serial.try_read() {
            Ok(Some(byte)) => {
                let result = line_reader.push(byte);
                timer_active = line_reader.needs_timeout();

                if timer_active {
                    idle_timer.start(INPUT_TIMEOUT_US);
                }

                if let Some(result) = result {
                    return result.map_err(SerialError::from);
                }
            }

            Ok(None) => {
                if timer_active && idle_timer.reset_if_finished() {
                    timer_active = false;

                    if let Some(error) = line_reader.timeout() {
                        return Err(error.into());
                    }
                }
            }

            Err(error) => {
                line_reader.discard();

                return Err(error.into());
            }
        }

        core::hint::spin_loop();
    }
}
