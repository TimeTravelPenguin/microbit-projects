#![no_main]
#![no_std]

use cortex_m_rt::entry;
use microbit::{
    board::Board,
    display::blocking::Display,
    hal::{Rng as HardwareRng, Timer},
};

use microbit_power::power_off;
use panic_rtt_target as _;
use rand::{Rng, SeedableRng, rngs::SmallRng};
use rtt_target::rtt_init_print;

#[entry]
fn main() -> ! {
    rtt_init_print!();

    let board = Board::take().unwrap();
    let mut power = power_off!(board);

    let mut timer = Timer::new(board.TIMER0);
    let mut display = Display::new(board.display_pins);

    let mut hardware_rng = HardwareRng::new(board.RNG);
    let mut rng = SmallRng::from_rng(&mut hardware_rng);

    let mut matrix = [[0; 5]; 5];
    matrix.iter_mut().for_each(|row| {
        row.iter_mut()
            .for_each(|col| *col = rng.random_range(0..=1))
    });

    power.run(|| {
        display.show(&mut timer, matrix, 100);
        incr_binary(&mut matrix);
    })
}

fn incr_binary(matrix: &mut [[u8; 5]; 5]) {
    let mut carry = 1;

    for row in matrix.iter_mut().rev() {
        for col in row.iter_mut().rev() {
            let sum = *col + carry;
            *col = sum % 2;
            carry = sum / 2;
        }
    }
}
