//! Millisecond clock with a periodic wake-up for the cooperative main loop.
//! Keep interrupt handlers and critical sections shorter than one clock tick.

use core::{
    cell::RefCell,
    sync::atomic::{AtomicU32, Ordering},
};
use cortex_m::{
    interrupt::{Mutex, free},
    peripheral::NVIC,
};
use micro_arcade::scheduler::INPUT_SAMPLE_INTERVAL_MS;
use microbit::{
    hal::{Timer, timer::Periodic},
    pac::{self, interrupt},
};

static TIMER: Mutex<RefCell<Option<Timer<pac::TIMER0, Periodic>>>> = Mutex::new(RefCell::new(None));
static ELAPSED_MS: AtomicU32 = AtomicU32::new(0);

pub fn initialise(timer: pac::TIMER0) {
    let mut timer = Timer::periodic(timer);
    timer.enable_interrupt();
    timer.start(INPUT_SAMPLE_INTERVAL_MS * 1_000);

    free(|cs| {
        TIMER.borrow(cs).replace(Some(timer));
    });

    NVIC::unpend(pac::Interrupt::TIMER0);

    // SAFETY: the shared timer is initialized before its handler can run.
    unsafe { NVIC::unmask(pac::Interrupt::TIMER0) };
}

/// Time advances in 5 ms steps and wraps after u32::MAX milliseconds.
pub fn now_ms() -> u32 {
    ELAPSED_MS.load(Ordering::Relaxed)
}

#[interrupt]
fn TIMER0() {
    free(|cs| {
        if let Some(timer) = TIMER.borrow(cs).borrow_mut().as_mut()
            && timer.reset_if_finished()
        {
            ELAPSED_MS.fetch_add(INPUT_SAMPLE_INTERVAL_MS, Ordering::Relaxed);
        }
    });
}
