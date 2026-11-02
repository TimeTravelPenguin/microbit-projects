#![no_std]
#![no_main]

use embassy_executor::Spawner;
use embassy_nrf::{
    bind_interrupts,
    config::{Config, HfclkSource},
    gpio::{Input, Pull},
    mode::Async,
    peripherals,
    rng::{self, Rng},
    twim::{self, Twim},
};
use embassy_time::Timer;
use embedded_graphics::{
    Drawable,
    draw_target::DrawTarget,
    geometry::{OriginDimensions, Point, Size},
    mono_font::{MonoTextStyle, ascii::FONT_6X10},
    pixelcolor::{BinaryColor, PixelColor},
    primitives::{Primitive, PrimitiveStyle, Rectangle},
    text::{Baseline, Text, renderer::TextRenderer},
};
use heapless::{Deque, Vec, format};
use kitronik_view::{DISPLAY_SIZE, r#async::init_display};
use microbit_input::r#async as buttons;
use microbit_input::r#async::sample;
use panic_rtt_target as _;
use rtt_target::{rprintln, rtt_init_print};

bind_interrupts!(struct Irqs {
    TWISPI0 => twim::InterruptHandler<peripherals::TWISPI0>;
    RNG => rng::InterruptHandler<peripherals::RNG>;
});

pub const CELL_SIZE: usize = 4;
pub const DISPLAY_HEIGHT: usize = 64;
pub const DISPLAY_WIDTH: usize = 128;
pub const ROW_CELLS: usize = DISPLAY_WIDTH / CELL_SIZE;
pub const COL_CELLS: usize = DISPLAY_HEIGHT / CELL_SIZE;

#[embassy_executor::main]
async fn main(spawner: Spawner) {
    rtt_init_print!();

    let mut config = Config::default();
    config.hfclk_source = HfclkSource::ExternalXtal;

    let peripherals = embassy_nrf::init(config);

    spawner.spawn(
        sample_buttons(
            Input::new(peripherals.P0_14, Pull::None),
            Input::new(peripherals.P0_23, Pull::None),
        )
        .expect("Failed to create button task"),
    );

    let mut rng = Rng::new(peripherals.RNG, Irqs);
    rng.set_bias_correction(true);

    let mut bus_config = twim::Config::default();
    bus_config.frequency = twim::Frequency::K400;

    let mut tx_buffer = [0_u8; 32];
    let bus = Twim::new(
        peripherals.TWISPI0,
        Irqs,
        peripherals.P1_00,
        peripherals.P0_26,
        bus_config,
        &mut tx_buffer,
    );

    let mut display = init_display(bus, DISPLAY_SIZE)
        .await
        .expect("Failed to initialize :VIEW");

    display
        .clear(BinaryColor::Off)
        .expect("Failed to clear display");

    let mut cellular_display = CellularDisplay::new(184, true, BinaryColor::On);

    let initial_state = random_state(&mut rng).await;
    cellular_display.set_initial_state(initial_state);

    let mut rate = 200;
    loop {
        let presses = buttons::take_presses();

        if presses.button_a > 0 && presses.button_b > 0 {
            let new_rule = random_rule(&mut rng).await;
            cellular_display.set_rule(new_rule);

            let initial_state = random_state(&mut rng).await;
            cellular_display.set_initial_state(initial_state);
        } else if presses.button_a > 0 {
            rate = (rate + 20).min(1000);
        } else if presses.button_b > 0 {
            rate = (rate - 20).max(20);
        }

        cellular_display.next();
        display
            .clear(BinaryColor::Off)
            .expect("Failed to clear display");

        cellular_display
            .draw(&mut display)
            .expect("Failed to draw cellular display");

        display.flush().await.expect("Failed to flush display");

        Timer::after_millis(rate).await;
    }
}

#[embassy_executor::task]
async fn sample_buttons(button_a: Input<'static>, button_b: Input<'static>) {
    buttons::sample(button_a, button_b)
        .await
        .expect("Failed to sample buttons");
}

pub async fn random_rule(rng: &mut Rng<'_, Async>) -> u8 {
    let mut rule = [0; 1];
    rng.fill_bytes(&mut rule).await;
    rule[0]
}

pub async fn random_state(rng: &mut Rng<'_, Async>) -> [u8; ROW_CELLS] {
    let mut bytes = [0; ROW_CELLS];

    while bytes.iter().all(|&b| b == 0) {
        rng.fill_bytes(&mut bytes).await;
    }

    bytes.iter_mut().for_each(|b| *b %= 2); // Convert to binary (0 or 1)

    rprintln!("Generated random initial state: {:?}", bytes);
    bytes
}

pub struct CellularDisplay<C> {
    periodic: bool,
    state: Deque<[bool; ROW_CELLS], COL_CELLS>,
    initial_state: [bool; ROW_CELLS],
    rule: u8,
    color: C,
}

impl<C> CellularDisplay<C> {
    pub fn new(rule: u8, periodic: bool, color: C) -> Self {
        let mut state = Deque::new();
        let initial_state = [false; ROW_CELLS];
        state.push_back(initial_state).unwrap();

        Self {
            state,
            rule,
            periodic,
            color,
            initial_state,
        }
    }

    pub fn reset(&mut self) {
        self.state.clear();
        self.state.push_back(self.initial_state).unwrap();
    }

    pub fn set_rule(&mut self, rule: u8) {
        self.rule = rule;
        self.reset();
    }

    pub fn set_initial_state(&mut self, initial_state: [u8; ROW_CELLS]) {
        self.initial_state = initial_state.map(|b| b != 0);
        self.reset();
    }

    pub fn next(&mut self) {
        let current_row = self.state.back().unwrap();
        let mut next_row = [false; ROW_CELLS];

        for i in 0..ROW_CELLS {
            let left = if i == 0 {
                if self.periodic {
                    current_row[ROW_CELLS - 1]
                } else {
                    false
                }
            } else {
                current_row[i - 1]
            };

            let center = current_row[i];

            let right = if i == ROW_CELLS - 1 {
                if self.periodic { current_row[0] } else { false }
            } else {
                current_row[i + 1]
            };

            let neighbours = [left, center, right];
            next_row[i] = next_cell(self.rule, neighbours);
        }

        if self.state.len() == COL_CELLS {
            self.state.pop_front();
        }

        self.state.push_back(next_row).unwrap();
    }
}

#[inline(always)]
fn next_cell(rule: u8, neighbours: [bool; 3]) -> bool {
    let [left, center, right] = neighbours;

    let index = ((left as u8) << 2) | ((center as u8) << 1) | (right as u8);

    ((rule >> index) & 1) != 0
}

impl<C: PixelColor> Drawable for CellularDisplay<C> {
    type Color = C;
    type Output = Point;

    fn draw<D>(&self, target: &mut D) -> Result<Point, D::Error>
    where
        D: DrawTarget<Color = Self::Color>,
    {
        let mut y = 0;

        for row in self.state.iter() {
            for (x, &cell) in row.iter().enumerate() {
                if cell {
                    Rectangle::new(
                        Point::new((x * CELL_SIZE) as i32, y),
                        Size::new(CELL_SIZE as u32, CELL_SIZE as u32),
                    )
                    .into_styled(PrimitiveStyle::with_fill(self.color))
                    .draw(target)?;
                }
            }

            y += CELL_SIZE as i32;
        }

        Ok(Point::new(0, y))
    }
}
