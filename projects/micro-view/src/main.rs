#![no_main]
#![no_std]

mod input;

use core::cell::RefCell;

use cortex_m_rt::entry;
use lsm303agr::{
    AccelMode, AccelOutputDataRate, Lsm303agr, interface::I2cInterface, mode::MagOneShot,
};
use micro_view::Plot;
use microbit::{
    hal::{
        Timer, Twim,
        gpio::{p0, p1},
        twim::{Frequency, Pins},
    },
    pac,
};
use microbit_power::{PowerOff, SharedI2c};
use panic_rtt_target as _;
use rtt_target::{rprintln, rtt_init_print};
use ssd1306::{I2CDisplayInterface, Ssd1306, mode::BufferedGraphicsMode, prelude::*};

type Oled = Ssd1306<
    I2CInterface<Twim<pac::TWIM1>>,
    DisplaySize128x64,
    BufferedGraphicsMode<DisplaySize128x64>,
>;
type Accelerometer<'bus> = Lsm303agr<I2cInterface<SharedI2c<'bus, Twim<pac::TWIM0>>>, MagOneShot>;

// The address is seven-bit: use 0x3D only if the VIEW's selector was changed.
const OLED_ADDRESS: u8 = 0x3C;
const SAMPLE_INTERVAL_US: u32 = 100_000;

#[entry]
fn main() -> ! {
    rtt_init_print!();

    // Take the peripherals directly to retain both independent I2C controllers.
    // microbit-v2 0.16's Board exposes TWIM0 but does not retain TWIM1.
    let peripherals = pac::Peripherals::take().unwrap();
    let port0 = p0::Parts::new(peripherals.P0);
    let port1 = p1::Parts::new(peripherals.P1);
    let mut delay = Timer::new(peripherals.TIMER0);

    // The edge connector connects the VIEW to P19 (SCL) and P20 (SDA).
    let display_bus = Twim::new(
        peripherals.TWIM1,
        Pins {
            scl: port0.p0_26.into_floating_input().degrade(),
            sda: port1.p1_00.into_floating_input().degrade(),
        },
        Frequency::K400,
    );

    let interface = I2CDisplayInterface::new_custom_address(display_bus, OLED_ADDRESS);
    let mut oled = Some(
        Ssd1306::new(interface, DisplaySize128x64, DisplayRotation::Rotate0)
            .into_buffered_graphics_mode(),
    );

    // The accelerometer has its own internal bus on micro:bit V2.
    let internal_bus = RefCell::new(Twim::new(
        peripherals.TWIM0,
        Pins {
            scl: port0.p0_08.into_floating_input().degrade(),
            sda: port0.p0_16.into_floating_input().degrade(),
        },
        Frequency::K100,
    ));

    // Both clients borrow the internal bus only for a foreground transaction.
    // I2C transfers keep interrupts enabled so button sampling can continue.
    let mut sensor = Lsm303agr::new_with_i2c(SharedI2c::new(&internal_bus));
    let mut power = PowerOff::new_shared(
        &internal_bus,
        port0.p0_25,
        peripherals.TIMER3,
        peripherals.POWER,
    );

    // A long reset-button press restarts the CPU before posting its power event.
    // Check before initializing or lighting the OLED, including cleanup for a
    // display or sensor that was left running across that reset.
    power.check_startup_with(|| shutdown(&mut oled, &mut sensor, &mut delay));

    oled.as_mut()
        .unwrap()
        .init()
        .expect("VIEW initialization failed: check power/address");
    sensor.init().expect("LSM303AGR initialization failed");
    sensor
        .set_accel_mode_and_odr(&mut delay, AccelMode::Normal, AccelOutputDataRate::Hz50)
        .expect("Accelerometer configuration failed");

    input::initialise(
        peripherals.TIMER2,
        port0.p0_14.into_floating_input(),
        port0.p0_23.into_floating_input(),
    );

    let mut plot = Plot::new();

    let display = oled.as_mut().unwrap();
    plot.render(display).unwrap();
    display.flush().expect("VIEW write failed");
    rprintln!("VIEW ready: tilt the board; A pauses, B switches axis");

    // A separate periodic timer keeps sampling independent of drawing time.
    let mut sample_timer = Timer::new(peripherals.TIMER1).into_periodic();
    sample_timer.start(SAMPLE_INTERVAL_US);

    loop {
        // Blocking transfers from the preceding frame have completed here.
        power.check_with(|| shutdown(&mut oled, &mut sensor, &mut delay));

        let presses = input::take_presses();
        let mut redraw = false;

        for _ in 0..presses.button_a {
            plot.toggle_pause();
        }

        for _ in 0..presses.button_b {
            plot.next_axis();
        }

        redraw |= presses.button_a != 0 || presses.button_b != 0;

        if sample_timer.reset_if_finished() && !plot.paused() {
            let acceleration = sensor.acceleration().expect("Accelerometer read failed");
            plot.record([
                acceleration.x_mg(),
                acceleration.y_mg(),
                acceleration.z_mg(),
            ]);

            redraw = true;
        }

        if redraw {
            // Drawing changes the 1 KiB RAM framebuffer. flush sends it to the OLED.
            let display = oled.as_mut().unwrap();
            plot.render(display).unwrap();
            display.flush().expect("VIEW write failed");
        }

        // TIMER2 wakes us every 2 ms and records presses even during OLED writes.
        cortex_m::asm::wfi();
    }
}

fn shutdown(
    oled: &mut Option<Oled>,
    sensor: &mut Accelerometer<'_>,
    delay: &mut Timer<pac::TIMER0>,
) {
    input::stop();

    if let Err(error) = sensor.set_accel_mode_and_odr(delay, AccelMode::PowerDown, None) {
        rprintln!("Accelerometer shutdown failed: {:?}", error);
    }

    if let Some(mut display) = oled.take() {
        if let Err(error) = display.set_display_on(false) {
            rprintln!("VIEW shutdown failed: {:?}", error);
        }

        // Display writes have completed; it is now safe to stop its controller.
        display.release().release().disable();
    }
}
