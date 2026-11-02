//! Sample A/B buttons asynchronously, independently of foreground work.
//!
//! Await [`sample`] in an application-owned task with the active-low A/B inputs.
//! Drain [`take_presses`] from the application loop. The sampler runs every 2 ms
//! and preserves presses while display transfers or other async tasks run.

use core::cell::RefCell;

use cortex_m::interrupt::{Mutex, free};
use embassy_time::Timer;
use embedded_hal::digital::InputPin;

use crate::{ButtonPresses, Buttons};

static BUTTONS: Mutex<RefCell<Buttons>> = Mutex::new(RefCell::new(Buttons::new()));

/// Sample both inputs every 2 ms until a pin read fails or the future is dropped.
///
/// Inputs must read low while pressed. Configure their pull resistors in the
/// application. The sampler owns its pins and supports one A/B pair. Both pins
/// must use the same error type; a read failure is returned to the caller.
pub async fn sample<ButtonA, ButtonB>(
    mut button_a: ButtonA,
    mut button_b: ButtonB,
) -> Result<(), ButtonA::Error>
where
    ButtonA: InputPin,
    ButtonB: InputPin<Error = ButtonA::Error>,
{
    loop {
        let button_a_pressed = button_a.is_low()?;
        let button_b_pressed = button_b.is_low()?;

        free(|ctx| {
            BUTTONS
                .borrow(ctx)
                .borrow_mut()
                .sample(button_a_pressed, button_b_pressed);
        });

        Timer::after_millis(2).await;
    }
}

/// Drain queued presses without disturbing debounce or held-button state.
pub fn take_presses() -> ButtonPresses {
    free(|ctx| BUTTONS.borrow(ctx).borrow_mut().take_presses())
}
