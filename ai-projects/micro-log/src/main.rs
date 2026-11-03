#![no_std]
#![no_main]

use core::fmt::{self, Write};

use cortex_m_rt::entry;
use embedded_hal::digital::InputPin;
use lsm303agr::{AccelMode, AccelOutputDataRate, Lsm303agr, MagMode, MagOutputDataRate};
use micro_log::{Log, Sample};
use microbit::{
    display::blocking::Display,
    hal::{Clocks, Rtc, Timer, Twim, nvmc::Nvmc, twim::Frequency, uarte},
    pac,
};
use microbit_input::Buttons;
use panic_rtt_target as _;
use rtt_target::{rprintln, rtt_init_print};
use serial_setup::UartePort;

type FlashLog = Log<Nvmc<pac::NVMC>>;
type Serial = UartePort<pac::UARTE0>;

// The RTC runs independently of flash writes and serial exports at 8 ticks/sec.
const TICKS_PER_SAMPLE: u32 = 8;
const RTC_MASK: u32 = 0x00ff_ffff;
const PAUSED: [[u8; 5]; 5] = [[0, 1, 0, 1, 0]; 5];
const RECORDING: [[u8; 5]; 5] = [
    [0, 0, 0, 0, 0],
    [0, 1, 1, 1, 0],
    [0, 1, 1, 1, 0],
    [0, 1, 1, 1, 0],
    [0, 0, 0, 0, 0],
];

const FULL: [[u8; 5]; 5] = [
    [1, 0, 0, 0, 1],
    [0, 1, 0, 1, 0],
    [0, 0, 1, 0, 0],
    [0, 1, 0, 1, 0],
    [1, 0, 0, 0, 1],
];

#[entry]
fn main() -> ! {
    rtt_init_print!();

    let board = microbit::Board::take().unwrap();
    let _clocks = Clocks::new(board.CLOCK)
        .enable_ext_hfosc()
        .set_lfclk_src_synth()
        .start_lfclk();
    let rtc = Rtc::new(board.RTC0, 4095).unwrap();
    rtc.enable_counter();

    let mut delay = Timer::new(board.TIMER0);
    let mut display = Display::new(board.display_pins);
    let mut button_a = board.buttons.button_a;
    let mut button_b = board.buttons.button_b;
    let mut buttons = Buttons::new();
    let mut serial = Serial::new(uarte::Uarte::new(
        board.UARTE0,
        board.uart.into(),
        uarte::Parity::EXCLUDED,
        uarte::Baudrate::BAUD115200,
    ));

    // SAFETY: memory.x excludes these pages from firmware and RAM. This is the
    // only call creating a reference to them; NVMC owns it for the whole run.
    let flash = Nvmc::new(board.NVMC, unsafe { reserved_flash() });
    let mut log = Log::open(flash).expect("Cannot scan flash log");

    // Erasing is an explicit startup gesture, never part of normal boot.
    if button_a.is_low().unwrap() && button_b.is_low().unwrap() {
        let held_since = rtc.get_counter();

        while button_a.is_low().unwrap() && button_b.is_low().unwrap() {
            display.show(&mut delay, FULL, 10);

            if rtc_elapsed(rtc.get_counter(), held_since) >= 16 {
                log.clear().expect("Cannot erase log; retry A+B on reset");
                writeln!(serial, "# Log erased\r").unwrap();

                while button_a.is_low().unwrap() || button_b.is_low().unwrap() {
                    display.show(&mut delay, PAUSED, 10);
                }

                break;
            }
        }
    }

    let bus = Twim::new(board.TWIM0, board.i2c_internal.into(), Frequency::K100);
    let mut sensor = Lsm303agr::new_with_i2c(bus);
    sensor.init().expect("LSM303AGR initialization failed");
    sensor
        .set_mag_mode_and_odr(&mut delay, MagMode::HighResolution, MagOutputDataRate::Hz10)
        .expect("Magnetometer configuration failed");

    let Ok(mut sensor) = sensor.into_mag_continuous() else {
        panic!("Cannot start continuous magnetometer measurements");
    };

    sensor
        .set_accel_mode_and_odr(&mut delay, AccelMode::Normal, AccelOutputDataRate::Hz10)
        .expect("Accelerometer configuration failed");

    let mut recording = false;
    let mut last_sample = rtc.get_counter();
    writeln!(
        serial,
        "# Ready: {} saved rows, {} free slots, session {}. A: record/pause; B or d: CSV\r",
        log.count(),
        log.capacity() - log.used_slots(),
        log.session(),
    )
    .unwrap();
    rprintln!("micro-log ready: A records/pauses; B exports USB serial CSV at 115200");

    loop {
        buttons.sample(button_a.is_low().unwrap(), button_b.is_low().unwrap());
        let presses = buttons.take_presses();
        let export_requested = serial.try_read().expect("USB UART read failed") == Some(b'd');

        if presses.button_b > 0 || export_requested {
            recording = false;
            display.clear();
            export_csv(&mut log, &mut serial).expect("CSV export failed");
        } else if presses.button_a > 0 {
            recording = !recording && !log.is_full();
            last_sample = rtc.get_counter();
            writeln!(
                serial,
                "# {}\r",
                if recording { "Recording" } else { "Paused" },
            )
            .unwrap();
        }

        let now = rtc.get_counter();

        if recording && rtc_elapsed(now, last_sample) >= TICKS_PER_SAMPLE {
            last_sample = now;
            // These are the latest independent 10 Hz sensor conversions;
            // the two measurements are not synchronized to one another.
            let acceleration = sensor.acceleration().expect("Accelerometer read failed");
            let magnetic_field = sensor.magnetic_field().expect("Magnetometer read failed");
            let sample = Sample {
                uptime_ms: now * 125,
                acceleration_mg: [
                    acceleration.x_mg(),
                    acceleration.y_mg(),
                    acceleration.z_mg(),
                ],
                magnetic_field_nt: [
                    magnetic_field.x_nt(),
                    magnetic_field.y_nt(),
                    magnetic_field.z_nt(),
                ],
            };

            log.append(sample).expect("Flash append failed");

            if log.is_full() {
                recording = false;
                writeln!(serial, "# Log full; export before erasing\r").unwrap();
            }
        }

        let image = if log.is_full() {
            FULL
        } else if recording {
            RECORDING
        } else {
            PAUSED
        };

        // One scan takes 10 ms; four equal button samples debounce a press.
        display.show(&mut delay, image, 10);
    }
}

fn rtc_elapsed(now: u32, earlier: u32) -> u32 {
    now.wrapping_sub(earlier) & RTC_MASK
}

fn export_csv(log: &mut FlashLog, serial: &mut Serial) -> fmt::Result {
    writeln!(serial, "# BEGIN MICRO_LOG\r")?;
    writeln!(
        serial,
        "session,uptime_ms,acc_x_mg,acc_y_mg,acc_z_mg,mag_x_nt,mag_y_nt,mag_z_nt\r",
    )?;

    for slot in 0..log.used_slots() {
        let Some(record) = log.read(slot).expect("Cannot read saved row") else {
            continue;
        };

        let sample = record.sample;
        writeln!(
            serial,
            "{},{},{},{},{},{},{},{}\r",
            record.session,
            sample.uptime_ms,
            sample.acceleration_mg[0],
            sample.acceleration_mg[1],
            sample.acceleration_mg[2],
            sample.magnetic_field_nt[0],
            sample.magnetic_field_nt[1],
            sample.magnetic_field_nt[2],
        )?;
    }

    writeln!(serial, "# END MICRO_LOG\r")?;
    serial.flush().map_err(|_| fmt::Error)
}

unsafe fn reserved_flash() -> &'static mut [u8] {
    unsafe extern "C" {
        static mut _log_start: u8;
        static _log_end: u8;
    }

    let start = core::ptr::addr_of_mut!(_log_start);
    let length = core::ptr::addr_of!(_log_end) as usize - start as usize;
    assert_eq!(length, 64 * 1024);

    // SAFETY: caller ensures unique ownership. Linker symbols delimit mapped,
    // page-aligned flash, with no executable code or initialized data in it.
    unsafe { core::slice::from_raw_parts_mut(start, length) }
}
