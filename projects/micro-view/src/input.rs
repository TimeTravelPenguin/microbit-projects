//! Sample and debounce buttons independently of foreground I²C transfers.

use core::cell::RefCell;

use cortex_m::{
    interrupt::{Mutex, free},
    peripheral::NVIC,
};
use embedded_hal::digital::InputPin;
use micro_view::{ButtonPresses, Buttons};
use microbit::{
    hal::{
        Timer,
        gpio::{Floating, Input, p0::P0_14, p0::P0_23},
        timer::Periodic,
    },
    pac::{self, interrupt},
};

const SAMPLE_INTERVAL_US: u32 = 2_000;

struct InputSampler {
    timer: Timer<pac::TIMER2, Periodic>,
    button_a: P0_14<Input<Floating>>,
    button_b: P0_23<Input<Floating>>,
    buttons: Buttons,
}

static INPUT: Mutex<RefCell<Option<InputSampler>>> = Mutex::new(RefCell::new(None));

pub fn initialise(
    timer: pac::TIMER2,
    button_a: P0_14<Input<Floating>>,
    button_b: P0_23<Input<Floating>>,
) {
    NVIC::mask(pac::Interrupt::TIMER2);

    let mut timer = Timer::periodic(timer);
    timer.enable_interrupt();
    timer.start(SAMPLE_INTERVAL_US);

    free(|cs| {
        INPUT.borrow(cs).replace(Some(InputSampler {
            timer,
            button_a,
            button_b,
            buttons: Buttons::new(),
        }));
    });

    NVIC::unpend(pac::Interrupt::TIMER2);

    // SAFETY: all interrupt-owned state is installed before enabling its handler.
    unsafe { NVIC::unmask(pac::Interrupt::TIMER2) };
}

pub fn take_presses() -> ButtonPresses {
    free(|cs| {
        INPUT
            .borrow(cs)
            .borrow_mut()
            .as_mut()
            .map_or_else(ButtonPresses::default, |input| input.buttons.take_presses())
    })
}

/// Stop input sampling before entering System OFF, including under a debugger.
pub fn stop() {
    NVIC::mask(pac::Interrupt::TIMER2);

    free(|cs| {
        if let Some(input) = INPUT.borrow(cs).borrow_mut().as_mut() {
            input.timer.disable_interrupt();
            input
                .timer
                .task_stop()
                .write(|writer| writer.tasks_stop().trigger());
            input.timer.reset_event();
        }
    });

    NVIC::unpend(pac::Interrupt::TIMER2);
}

#[interrupt]
fn TIMER2() {
    free(|cs| {
        if let Some(input) = INPUT.borrow(cs).borrow_mut().as_mut()
            && input.timer.reset_if_finished()
        {
            let button_a_pressed = input.button_a.is_low().unwrap();
            let button_b_pressed = input.button_b.is_low().unwrap();
            input.buttons.sample(button_a_pressed, button_b_pressed);
        }
    });
}
