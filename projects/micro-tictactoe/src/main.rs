#![no_std]
#![no_main]

use embassy_executor::Spawner;
use embassy_nrf::{
    config::{Config, HfclkSource},
    gpio::{Input, Pull},
};

use embassy_time::Timer;
use embedded_graphics::Drawable;
use panic_rtt_target as _;
use rtt_target::{rprintln, rtt_init_print};

use micro_tictactoe::{
    app::{App, AppEffect},
    hardware::{Busses, Hardware},
    input::{buttons, firmware_action},
    settings,
};

#[embassy_executor::main]
async fn main(spawner: Spawner) {
    rtt_init_print!();

    let mut config = Config::default();
    config.hfclk_source = HfclkSource::ExternalXtal;

    let peripherals = embassy_nrf::init(config);

    settings::init(peripherals.NVMC).expect("Failed to initialize settings");
    let settings = settings::load().expect("Failed to load settings");

    let mut app = App::new(settings).expect("Failed to create menus");

    let busses = Busses::new(
        // Display SDA is edge connector P20; SCL is edge connector P19.
        (peripherals.TWISPI0, peripherals.P1_00, peripherals.P0_26).into(),
        // CardKB SDA is edge connector P14; SCL is edge connector P0.
        (peripherals.TWISPI1, peripherals.P0_01, peripherals.P0_02).into(),
    );

    let mut hardware = Hardware::new(busses).await;
    let display = &mut hardware.display;
    let cardkb = &mut hardware.cardkb;

    spawner.spawn(
        buttons::sample(
            Input::new(peripherals.P0_14, Pull::None),
            Input::new(peripherals.P0_23, Pull::None),
        )
        .expect("Failed to create button task"),
    );

    let mut needs_redraw = true;

    loop {
        let key = cardkb.read_key().await.unwrap_or_else(|_| {
            rprintln!("Failed to read from cardkb");

            None
        });

        if let Some(key) = key {
            rprintln!("Key pressed: {:?}", key);
        }

        let presses = buttons::take_presses();

        if let Some(action) = firmware_action(
            key,
            presses.button_a > 0,
            presses.button_b > 0,
            app.is_editing(),
        ) {
            match app.handle(action) {
                Ok(update) => {
                    needs_redraw |= update.redraw;

                    if let Some(effect) = update.effect {
                        handle_effect(effect);
                    }
                }

                Err(error) => {
                    rprintln!("Failed to handle input: {:?}", error);
                }
            }
        }

        if needs_redraw {
            app.draw(display).expect("Failed to draw screen");
            display.flush().await.expect("Failed to flush display");
            needs_redraw = false;
        }

        Timer::after_millis(5).await;
    }
}

fn handle_effect(effect: AppEffect) {
    match effect {
        AppEffect::NewGame => {
            rprintln!("New game requested");
        }

        AppEffect::JoinGame => {
            rprintln!("Join game requested");
        }

        AppEffect::SaveSettings(settings) => {
            if let Err(error) = settings::save(&settings) {
                rprintln!("Failed to save settings: {:?}", error);
            }
        }
    }
}
