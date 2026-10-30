#![no_std]
#![no_main]

use cardkb::{Key, key::KeyExt};
use embassy_executor::Spawner;
use embassy_nrf::{
    bind_interrupts,
    config::{Config, HfclkSource},
    gpio::{Input, Pull},
    peripherals,
    twim::{self, Twim},
};
use embassy_time::Timer;
use embedded_graphics::Drawable;
use micro_tictactoe::input::buttons::{self, ButtonPresses};
use micro_tictactoe::{app::App, hardware, settings};
use panic_rtt_target as _;
use rtt_target::{rprintln, rtt_init_print};

bind_interrupts!(struct Irqs {
    TWISPI0 => twim::InterruptHandler<peripherals::TWISPI0>;
    TWISPI1 => twim::InterruptHandler<peripherals::TWISPI1>;
});

#[embassy_executor::main]
async fn main(spawner: Spawner) {
    rtt_init_print!();

    let mut config = Config::default();
    config.hfclk_source = HfclkSource::ExternalXtal;

    let peripherals = embassy_nrf::init(config);

    settings::init(peripherals.NVMC).expect("Failed to initialize settings");
    let settings = settings::load().expect("Failed to load settings");

    let mut app = App::new(settings).expect("Failed to create menus");

    let mut display_tx_buffer = [0u8; 32];
    let mut cardkb_tx_buffer = [0u8; 32];

    let mut display_config = twim::Config::default();
    display_config.frequency = twim::Frequency::K400;

    let display_bus = Twim::new(
        peripherals.TWISPI0,
        Irqs,
        peripherals.P1_00, // SDA
        peripherals.P0_26, // SCL
        display_config,
        &mut display_tx_buffer,
    );

    let mut cardkb_config = twim::Config::default();
    cardkb_config.frequency = twim::Frequency::K100;

    let cardkb_bus = Twim::new(
        peripherals.TWISPI1,
        Irqs,
        peripherals.P0_01, // SDA: edge connector P14
        peripherals.P0_02, // SCL: edge connector P0
        cardkb_config,
        &mut cardkb_tx_buffer,
    );

    let mut display = hardware::init_display(display_bus).await;
    let mut cardkb = hardware::init_cardkb(cardkb_bus);

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
            app.draw(&mut display).expect("Failed to draw screen");
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
