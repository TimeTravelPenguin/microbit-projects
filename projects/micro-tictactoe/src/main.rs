#![no_std]
#![no_main]

use cardkb::{Key, blocking::CardKb, key::KeyExt};
use cortex_m_rt::entry;
use display_interface::DisplayError;
use embedded_graphics::{
    mono_font::ascii::FONT_6X10,
    pixelcolor::BinaryColor,
    prelude::*,
    text::{Alignment, Text},
};
use embedded_hal::i2c::I2c;
use embedded_layout::align::{Align, horizontal, vertical};
use heapless::format;
use micro_tictactoe::{
    settings,
    ui::{Menu, MenuStyle},
};
use microbit::{
    hal::{Clocks, Rng},
    pac::{self},
};
use microbit_input::input;
use nrf52833_hal::{
    Twim,
    gpio::{p0, p1},
    twim::{Frequency, Pins},
};
use panic_rtt_target as _;
use rtt_target::{rprintln, rtt_init_print};
use ssd1306::{I2CDisplayInterface, Ssd1306, mode::BufferedGraphicsMode, prelude::*};

type Oled<I> = Ssd1306<I2CInterface<I>, DisplaySize128x64, BufferedGraphicsMode<DisplaySize128x64>>;

#[entry]
fn main() -> ! {
    rtt_init_print!();

    let peripherals = pac::Peripherals::take().expect("Failed to take peripherals");

    settings::init(peripherals.NVMC).expect("Failed to initialize settings");
    let mut settings = settings::load().expect("Failed to load settings");

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

    let mut display = display(peripherals.TWIM0, display_pins);
    let mut cardkb = cardkb(peripherals.TWIM1, cardkb_pins);

    let menu_style = MenuStyle {
        font: &FONT_6X10,
        text_alignment: Alignment::Center,
        ..Default::default()
    };

    let display_area = display.bounding_box();
    let mut menu =
        Menu::<BinaryColor, 24, 4>::new_with_items(&["New game", "Join game", "Settings"])
            .expect("Failed to create menu")
            .set_style(menu_style)
            .align_to(&display_area, horizontal::Center, vertical::Center);

    menu.draw(&mut display).expect("Failed to draw menu");

    let mut needs_redraw = true;
    let mut key = None;

    loop {
        if let Ok(key_pressed) = cardkb.read_key() {
            if key != key_pressed {
                key = key_pressed;
                rprintln!("Key pressed: {:?}", key_pressed);
            }

            needs_redraw = true;
        } else {
            rprintln!("Failed to read from cardkb");
            key = None;
        }

        if needs_redraw {
            display.clear_buffer();
            menu.draw(&mut display).unwrap();
            display.flush().unwrap();
            needs_redraw = false;
        }

        let presses = input::take_presses();

        if key.is_key(Key::ArrowDown) || (presses.button_a > 0 && presses.button_b == 0) {
            menu.select_next();
            needs_redraw = true;

            rprintln!("Selecting next menu item");
        } else if key.is_key(Key::ArrowUp) {
            menu.select_previous();
            needs_redraw = true;

            rprintln!("Selecting previous menu item");
        }

        if key.is_key(Key::Enter) || (presses.button_b > 0 && presses.button_a == 0) {
            let idx = menu.select_item().map(|x| x as isize).unwrap_or(-1);
            needs_redraw = true;

            rprintln!("Selected menu item index: {:?}", idx);
            show_message_screen(
                &mut display,
                &format!(64; "Username:\n{}", settings.user_name)
                    .expect("Failed to format message"),
            )
            .expect("Failed to show message screen");

            settings.user_name = format!(8; "User{}", idx).expect("Failed to format username");
            settings::save(&settings).expect("Failed to save settings");
        }
    }
}

fn display(twim0: pac::TWIM0, pins: Pins) -> Oled<Twim<pac::TWIM0>> {
    let display_bus = Twim::new(twim0, pins, Frequency::K400);

    init_display(display_bus).expect("Failed to initialize display")
}

fn init_display<I: I2c>(i2c: I) -> Result<Oled<I>, DisplayError> {
    let interface = I2CDisplayInterface::new(i2c);
    let mut display = Ssd1306::new(interface, DisplaySize128x64, DisplayRotation::Rotate0)
        .into_buffered_graphics_mode();

    display.init()?;
    display.clear_buffer();
    display.flush()?;
    display.set_display_on(true)?;

    Ok(display)
}

fn cardkb(twim1: pac::TWIM1, pins: Pins) -> CardKb<Twim<pac::TWIM1>> {
    let cardkb_bus = Twim::new(twim1, pins, Frequency::K100);
    CardKb::new(cardkb_bus)
}

fn show_message_screen<I: I2c>(display: &mut Oled<I>, message: &str) -> Result<(), DisplayError> {
    display.clear_buffer();
    let text_style = embedded_graphics::mono_font::MonoTextStyleBuilder::new()
        .font(&FONT_6X10)
        .text_color(BinaryColor::On)
        .build();

    let text = Text::with_alignment(
        message,
        display.bounding_box().center(),
        text_style,
        Alignment::Center,
    );

    text.draw(display)?;
    display.flush()?;

    loop {
        let presses = input::take_presses();

        if presses.button_a > 0 {
            break;
        }
    }

    Ok(())
}
