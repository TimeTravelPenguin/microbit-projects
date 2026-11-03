#![no_main]
#![no_std]

mod clock;

use core::cell::RefCell;
use cortex_m::{
    interrupt::{Mutex, free},
    peripheral::NVIC,
};
use cortex_m_rt::entry;
use micro_arcade::{
    arcade::{Arcade, GameAction, Matrix},
    buttons::{ButtonPress, Buttons},
    scheduler::Scheduler,
};
use microbit::{
    board::Board,
    display::nonblocking::{Display, Frame, GreyscaleImage, MicrobitFrame},
    hal::Rng as HardwareRng,
    pac::{self, interrupt},
};
use microbit_power::power_off;
use panic_rtt_target as _;
use rand::{Rng, SeedableRng, rngs::SmallRng, seq::IteratorRandom};
use rtt_target::{rprintln, rtt_init_print};

// The main loop and timer handler share the display through critical sections.
static DISPLAY: Mutex<RefCell<Option<Display<pac::TIMER1>>>> = Mutex::new(RefCell::new(None));

#[entry]
fn main() -> ! {
    rtt_init_print!();
    rprintln!("Starting arcade tower game");

    let board = Board::take().unwrap();
    let mut power = power_off!(board);

    initialise_display(Display::new(board.TIMER1, board.display_pins));

    let mut hardware_rng = HardwareRng::new(board.RNG);
    let rng = SmallRng::from_rng(&mut hardware_rng);
    let mut buttons = Buttons::new(board.buttons.button_a, board.buttons.button_b);
    let mut arcade = Arcade::new(rng);

    clock::initialise(board.TIMER0);

    let mut scheduler = Scheduler::new(clock::now_ms());
    show_matrix(arcade.matrix());

    power.run(|| {
        let now_ms = clock::now_ms();
        let mut frame_dirty = false;

        // Input takes priority when a press and movement are ready together.
        if scheduler.input_due(now_ms)
            && let Some(button) = buttons.poll(now_ms)
        {
            let action = match button {
                ButtonPress::A => GameAction::Restart,
                ButtonPress::B => GameAction::PlaceBlocks,
            };

            arcade.handle_action(action);
            scheduler.restart_movement(clock::now_ms());
            frame_dirty = true;
        }

        if scheduler.movement_due(clock::now_ms(), arcade.move_interval_ms()) {
            arcade.tick();
            frame_dirty = true;
            rprintln!("Logical row: {}", arcade.active_row());
        }

        if frame_dirty {
            show_matrix(arcade.matrix());
        }

        // TIMER0 wakes the loop regularly; TIMER1 keeps refreshing the display.
        cortex_m::asm::wfi();
    })
}

fn initialise_display(display: Display<pac::TIMER1>) {
    free(|cs| {
        DISPLAY.borrow(cs).replace(Some(display));
    });

    // SAFETY: the shared display is initialized before its handler can run.
    unsafe { NVIC::unmask(pac::Interrupt::TIMER1) };
}

fn show_matrix(matrix: &Matrix) {
    // Prepare the image while interrupts can still refresh the LEDs.
    let mut frame = MicrobitFrame::default();
    frame.set(&GreyscaleImage::new(matrix));

    free(|cs| {
        if let Some(display) = DISPLAY.borrow(cs).borrow_mut().as_mut() {
            display.show_frame(&frame);
        }
    });
}

#[interrupt]
fn TIMER1() {
    free(|cs| {
        if let Some(display) = DISPLAY.borrow(cs).borrow_mut().as_mut() {
            display.handle_display_event();
        }
    });
}

// Standalone rain and sine demos, retained for later use.

fn rain(matrix: &mut [[u8; 5]; 5], rng: &mut SmallRng) {
    step_droplets(matrix);

    if should_spawn_droplet(rng) {
        spawn_droplet(matrix, rng);
    }
}

fn spawn_droplet(matrix: &mut [[u8; 5]; 5], rng: &mut SmallRng) {
    if let Some(x) = (0..5).filter(|&x| matrix[0][x] == 0).choose(rng) {
        rprintln!("Spawning droplet at column {}", x);
        matrix[0][x] = 5;
    }
}

fn should_spawn_droplet(rng: &mut SmallRng) -> bool {
    rng.random_bool(0.7)
}

fn step_droplets(matrix: &mut [[u8; 5]; 5]) {
    // Remove droplets leaving the display, then move the others down.
    matrix[4] = [0; 5];

    const BRIGHTNESS_ROW_VALUES: [u8; 5] = [4, 7, 5, 3, 1];

    for row in (0..4u8).rev() {
        for col in 0..5 {
            let row_idx = row as usize;
            if matrix[row_idx][col] > 0 {
                let new_value = BRIGHTNESS_ROW_VALUES[row_idx + 1];
                matrix[row_idx + 1][col] = new_value;
                matrix[row_idx][col] = 0;
            }
        }
    }
}

/// Update the matrix to show a sine wave pattern based on the tick count.
/// The black wave moves right; each side shares one brightness, pulsing in opposite phases.
fn sine(tick: u32, matrix: &mut [[u8; 5]; 5]) {
    let min_brightness = 3.0;
    let max_brightness = 8.0;
    let pulse_frequency = 0.5; // Relative to the main wave: 0.5 runs at half its frequency.
    let brightness_midpoint = (min_brightness + max_brightness) / 2.0;
    let brightness_amplitude = (max_brightness - min_brightness) / 2.0;

    const PERIOD_FRAMES: u32 = 32;
    let phase = (tick % PERIOD_FRAMES) as f32 * (core::f32::consts::TAU / PERIOD_FRAMES as f32);

    // The pulse has its own phase, so it continues when the main wave repeats.
    let pulse_cycles = f64::from(tick) * pulse_frequency / f64::from(PERIOD_FRAMES);
    let pulse_phase = libm::fmod(pulse_cycles, 1.0) as f32 * core::f32::consts::TAU;
    let center_angle = (matrix[0].len() / 2) as f32 - pulse_phase;
    let pulse_offset = libm::sinf(center_angle);
    let top_brightness = libm::roundf(brightness_midpoint + brightness_amplitude * pulse_offset)
        .clamp(min_brightness, max_brightness) as u8;
    let bottom_brightness = libm::roundf(brightness_midpoint - brightness_amplitude * pulse_offset)
        .clamp(min_brightness, max_brightness) as u8;

    for x in 0..5 {
        let angle = x as f32 - phase;
        let wave_offset = libm::sinf(angle);
        let wave_row = libm::roundf(2.0 + wave_offset).clamp(1.0, 3.0) as usize;

        for (row_idx, row) in matrix.iter_mut().enumerate() {
            row[x] = if row_idx < wave_row {
                top_brightness
            } else if row_idx == wave_row {
                0
            } else {
                bottom_brightness
            };
        }
    }
}
