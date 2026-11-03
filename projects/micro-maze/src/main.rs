#![no_std]
#![no_main]

use cortex_m_rt::entry;
use display_interface::DisplayError;
use embedded_graphics::{
    Drawable,
    geometry::{Dimensions, Point},
    mono_font::{MonoTextStyle, MonoTextStyleBuilder, ascii::FONT_9X18_BOLD},
    pixelcolor::BinaryColor,
    primitives::{Primitive, PrimitiveStyleBuilder, StrokeAlignment},
    text::{Baseline, Text},
    transform::Transform,
};
use micro_maze::MazeBuilder;
use microbit::{
    hal::{Clocks, Rng, Timer},
    pac::{self, TWIM1},
};
use microbit_input::input;
use nrf52833_hal::{
    Twim,
    gpio::{p0, p1},
    twim::{Frequency, Pins},
};
use panic_rtt_target as _;
use rtt_target::{rprintln, rtt_init_print};
use ssd1306::{Ssd1306, mode::BufferedGraphicsMode, prelude::*};

type Oled =
    Ssd1306<I2CInterface<Twim<TWIM1>>, DisplaySize128x64, BufferedGraphicsMode<DisplaySize128x64>>;

#[entry]
fn main() -> ! {
    rtt_init_print!();

    let peripherals = pac::Peripherals::take().expect("Failed to take peripherals");

    let _clocks = Clocks::new(peripherals.CLOCK).enable_ext_hfosc();
    let rng = Rng::new(peripherals.RNG);
    let mut timer = Timer::new(peripherals.TIMER0);
    let mut maze = MazeBuilder::new(rng);

    let port0 = p0::Parts::new(peripherals.P0);
    let port1 = p1::Parts::new(peripherals.P1);

    let mut display = init_display(
        peripherals.TWIM1,
        Pins {
            scl: port0.p0_26.into_floating_input().degrade(),
            sda: port1.p1_00.into_floating_input().degrade(),
        },
    )
    .expect("Failed to initialize display");

    input::initialise(
        peripherals.TIMER2,
        port0.p0_14.into_floating_input(), // A
        port0.p0_23.into_floating_input(), // B
    );

    let paused_text_style = MonoTextStyleBuilder::new()
        .font(&FONT_9X18_BOLD)
        .text_color(BinaryColor::Off)
        .build();

    let mut paused = false;
    timer.start(50_000);

    loop {
        let presses = input::take_presses();

        if presses.button_a > 0 {
            rprintln!("A pressed");
            paused = !paused && !maze.is_complete();
        }

        if presses.button_b > 0 {
            rprintln!("B pressed");
            paused = false;
            maze.reset();
        }

        if !paused && !maze.is_complete() && timer.reset_if_finished() {
            maze.step();
            maze.render(&mut display).expect("Failed to draw maze");
            display.flush().expect("Failed to flush display");

            if maze.is_retracing() {
                timer.start(5_000);
            } else {
                timer.start(50_000);
            }
        }

        if paused {
            render_paused(&mut display, &paused_text_style).expect("Failed to render paused text");
            display.flush().expect("Failed to flush display");
        }

        cortex_m::asm::wfi();
    }
}

fn render_paused(
    display: &mut Oled,
    text_style: &MonoTextStyle<BinaryColor>,
) -> Result<(), DisplayError> {
    let text = Text::with_baseline("Paused", Point::zero(), *text_style, Baseline::Top);
    let text = text.translate(display.bounding_box().center() - text.bounding_box().center());

    // Expand the measured text bounds to leave four pixels of white padding.
    let bg_style = PrimitiveStyleBuilder::new()
        .fill_color(BinaryColor::On)
        .stroke_color(BinaryColor::Off)
        .stroke_alignment(StrokeAlignment::Outside)
        .stroke_width(2)
        .build();

    text.bounding_box()
        .offset(4)
        .into_styled(bg_style)
        .draw(display)?;

    text.draw(display)?;

    Ok(())
}

fn init_display(controller: TWIM1, pins: Pins) -> Result<Oled, DisplayError> {
    let external_i2c = Twim::new(controller, pins, Frequency::K400);

    let interface = I2CInterface::new(external_i2c, 0x3C, 0x40);
    let mut display = Ssd1306::new(interface, DisplaySize128x64, DisplayRotation::Rotate0)
        .into_buffered_graphics_mode();

    display.init()?;
    display.clear_buffer();
    display.flush()?;
    display.set_display_on(true)?;

    Ok(display)
}
