#![no_std]
#![no_main]

use cardkb::{Key, key::KeyExt};
use cortex_m_rt::entry;
use embedded_graphics::Drawable;
use micro_tictactoe::{
    app::{App, AppEvent},
    hardware, settings,
};
use microbit::{
    hal::{Clocks, Rng},
    pac::{self},
};
use microbit_input::input;
use nrf52833_hal::{
    gpio::{p0, p1},
    twim::Pins,
};
use panic_rtt_target as _;
use rtt_target::{rprintln, rtt_init_print};

#[entry]
fn main() -> ! {
    rtt_init_print!();

    let peripherals = pac::Peripherals::take().expect("Failed to take peripherals");

    settings::init(peripherals.NVMC).expect("Failed to initialize settings");
    let settings = settings::load().expect("Failed to load settings");
    let mut app = App::new(settings).expect("Failed to create menus");

    let _clocks = Clocks::new(peripherals.CLOCK).enable_ext_hfosc();
    let _rng = Rng::new(peripherals.RNG);

    let port0 = p0::Parts::new(peripherals.P0);
    let port1 = p1::Parts::new(peripherals.P1);

    input::initialise(
        peripherals.TIMER2,
        port0.p0_14.into_floating_input(), // A
        port0.p0_23.into_floating_input(), // B
    );

    let display_pins = Pins {
        scl: port0.p0_26.into_floating_input().degrade(),
        sda: port1.p1_00.into_floating_input().degrade(),
    };

    let cardkb_pins = Pins {
        scl: port0.p0_02.into_floating_input().degrade(), // P0
        sda: port0.p0_01.into_floating_input().degrade(), // P14
    };

    let mut display = hardware::init_display(peripherals.TWIM0, display_pins);
    let mut cardkb = hardware::init_cardkb(peripherals.TWIM1, cardkb_pins);
    let mut needs_redraw = true;

    loop {
        let key = cardkb.read_key().unwrap_or_else(|_| {
            rprintln!("Failed to read from cardkb");

            None
        });

        if let Some(key) = key {
            rprintln!("Key pressed: {:?}", key);
        }

        let presses = input::take_presses();

        if key.is_key(Key::ArrowDown) || (presses.button_a > 0 && presses.button_b == 0) {
            app.select_next();
            needs_redraw = true;
        } else if key.is_key(Key::ArrowUp) {
            app.select_previous();
            needs_redraw = true;
        }

        if key.is_key(Key::Enter) || (presses.button_b > 0 && presses.button_a == 0) {
            if let Some(event) = app.select_item() {
                rprintln!("Menu event: {:?}", event);

                if event == AppEvent::SettingsChanged {
                    settings::save(app.settings()).expect("Failed to save settings");
                }
            }

            needs_redraw = true;
        }

        if needs_redraw {
            app.draw(&mut display).expect("Failed to draw screen");
            display.flush().expect("Failed to flush display");
            needs_redraw = false;
        }
    }
}
