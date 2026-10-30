#![no_std]
#![no_main]

use cardkb::{Key, key::KeyExt};
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
    app::App,
    hardware::{Busses, Hardware},
    input::buttons::{self, ButtonPresses},
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
        needs_redraw |= handle_inputs(&mut app, key, presses);

        if needs_redraw {
            app.draw(display).expect("Failed to draw screen");
            display.flush().await.expect("Failed to flush display");
            needs_redraw = false;
        }

        Timer::after_millis(5).await;
    }
}

type FnKey = fn(Option<Key>) -> bool;
type FnPresses = fn(ButtonPresses) -> bool;

struct InputEvent {
    key: FnKey,
    presses: FnPresses,
}

impl InputEvent {
    fn new(key: FnKey, presses: FnPresses) -> Self {
        Self { key, presses }
    }

    fn eval(&self, key: Option<Key>, presses: ButtonPresses) -> bool {
        (self.key)(key) || (self.presses)(presses)
    }
}

struct InputEvents {
    select_next: InputEvent,
    select_previous: InputEvent,
    select_item: InputEvent,
    back: InputEvent,
}

impl InputEvents {
    fn new() -> Self {
        Self {
            select_next: InputEvent::new(
                |key| key.is_key(Key::ArrowDown),
                |presses| presses.button_a > 0 && presses.button_b == 0,
            ),
            select_previous: InputEvent::new(
                |key| key.is_key(Key::ArrowUp),
                |presses| presses.button_b > 0 && presses.button_a == 0,
            ),
            select_item: InputEvent::new(
                |key| key.is_key(Key::Enter),
                |presses| presses.button_b > 0 && presses.button_a == 0,
            ),
            back: InputEvent::new(|key| key.is_key(Key::Escape), |_| false),
        }
    }
}

fn handle_inputs(app: &mut App, key: Option<Key>, presses: ButtonPresses) -> bool {
    let mut needs_redraw = false;

    let input_events = InputEvents::new();

    if input_events.select_next.eval(key, presses) {
        app.select_next();
        needs_redraw = true;
    } else if input_events.select_previous.eval(key, presses) {
        app.select_previous();
        needs_redraw = true;
    } else if input_events.select_item.eval(key, presses) {
        app.select_item();
        needs_redraw = true;
    } else if input_events.back.eval(key, presses) {
        app.back();
        needs_redraw = true;
    }

    needs_redraw
}
