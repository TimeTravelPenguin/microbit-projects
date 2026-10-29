//! Sample and debounce buttons independently of foreground I²C transfers.

use core::cell::RefCell;

use crate::{
    ButtonPresses, Buttons,
    logo::{LogoDetector, elapsed_charge_us},
};
use cortex_m::{
    interrupt::{Mutex, free},
    peripheral::NVIC,
};
use embedded_hal::digital::InputPin;
use microbit::{
    hal::{
        Timer,
        gpio::{Floating, Input, OpenDrainIO, Output, p0::P0_14, p0::P0_23, p1::P1_04},
        ppi::{ConfigurablePpi, Ppi, Ppi2},
        timer::Periodic,
    },
    pac::{self, interrupt},
};

const SAMPLE_INTERVAL_US: u32 = 2_000;
const LOGO_SAMPLE_MAX_US: u32 = 1_000;
const DEADLINE_WRITE_MARGIN_US: u32 = 16;

struct LogoSampler {
    pin: P1_04<Output<OpenDrainIO>>,
    gpiote: pac::GPIOTE,
    ppi: Ppi2,
    detector: LogoDetector,
    measuring: bool,
    start_us: u32,
}

impl LogoSampler {
    fn new(
        pin: P1_04<Output<OpenDrainIO>>,
        gpiote: pac::GPIOTE,
        mut ppi: Ppi2,
        timer: &Timer<pac::TIMER2, Periodic>,
    ) -> Self {
        ppi.disable();
        gpiote.config[0].reset();
        gpiote.events_in[0].reset();
        gpiote.intenclr.write(|writer| writer.in0().clear());
        ppi.set_event_endpoint(&gpiote.events_in[0]);
        ppi.set_task_endpoint(timer.task_capture_cc2());

        Self {
            pin,
            gpiote,
            ppi,
            detector: LogoDetector::new(),
            measuring: false,
            start_us: 0,
        }
    }

    fn sample(&mut self, timer: &Timer<pac::TIMER2, Periodic>) {
        // SAFETY: this input sampler owns TIMER2. CC0 schedules the input ticks,
        // CC1 belongs to Timer::read(), and CC2 exclusively to logo capture.
        let capture = unsafe { &(*pac::TIMER2::ptr()).cc[2] };

        if self.measuring {
            self.ppi.disable();
            self.gpiote.config[0].reset();

            // Disabling GPIOTE restores GPIO output-low, draining the pad for
            // the next 2 ms. No rising edge is needed for a timeout reading.
            let captured_us = capture.read().bits();
            let elapsed_us = if self.gpiote.events_in[0].read().bits() != 0 {
                elapsed_charge_us(captured_us, self.start_us, LOGO_SAMPLE_MAX_US)
            } else {
                LOGO_SAMPLE_MAX_US
            };

            self.detector.sample(elapsed_us as u16);
            self.measuring = false;
        } else {
            self.gpiote.events_in[0].reset();
            capture.write(|writer| unsafe { writer.cc().bits(u32::MAX) });
            self.ppi.enable();
            self.start_us = timer.read();

            // GPIOTE Event mode overrides output-low to input. The board's
            // 10 MΩ pull-up charges the logo, and PPI timestamps its rising
            // edge without interrupt latency, OLED writes, or busy waiting.
            self.gpiote.config[0].write(|writer| {
                writer.mode().event();
                // SAFETY: P1.04 is the logo pin exclusively owned here.
                unsafe { writer.psel().bits(4) };
                writer.port().set_bit();
                writer.polarity().lo_to_hi()
            });

            self.measuring = true;
        }
    }

    fn stop(mut self) {
        self.ppi.disable();
        self.gpiote.config[0].reset();
        self.gpiote.events_in[0].reset();
        self.gpiote.intenclr.write(|writer| writer.in0().clear());
        self.pin.into_disconnected();
    }
}

struct InputSampler {
    timer: Timer<pac::TIMER2, Periodic>,
    next_tick_us: u32,
    button_a: P0_14<Input<Floating>>,
    button_b: P0_23<Input<Floating>>,
    buttons: Buttons,
    logo: Option<LogoSampler>,
}

static INPUT: Mutex<RefCell<Option<InputSampler>>> = Mutex::new(RefCell::new(None));

pub fn initialise(
    timer: pac::TIMER2,
    button_a: P0_14<Input<Floating>>,
    button_b: P0_23<Input<Floating>>,
) {
    initialise_sampler(timer, button_a, button_b, None);
}

/// Sample A/B and the capacitive logo independently of foreground work.
///
/// Supply P1.04 configured as open-drain input/output, output-low, with no
/// internal pull or SENSE. TIMER2 CC2, GPIOTE channel 0, and PPI channel 2 are
/// reserved for capacitive timing; other PPI channels remain available.
pub fn initialise_with_logo(
    timer: pac::TIMER2,
    button_a: P0_14<Input<Floating>>,
    button_b: P0_23<Input<Floating>>,
    logo_pin: P1_04<Output<OpenDrainIO>>,
    gpiote: pac::GPIOTE,
    ppi2: Ppi2,
) {
    initialise_sampler(timer, button_a, button_b, Some((logo_pin, gpiote, ppi2)));
}

fn initialise_sampler(
    timer: pac::TIMER2,
    button_a: P0_14<Input<Floating>>,
    button_b: P0_23<Input<Floating>>,
    logo_hardware: Option<(P1_04<Output<OpenDrainIO>>, pac::GPIOTE, Ppi2)>,
) {
    NVIC::mask(pac::Interrupt::TIMER2);

    let mut timer = Timer::periodic(timer);
    let logo = logo_hardware.map(|(pin, gpiote, ppi)| LogoSampler::new(pin, gpiote, ppi, &timer));

    // Keep the 1 MHz, 32-bit counter running across ticks. Clearing it at CC0
    // could make a logo edge during ISR latency look like a short charge.
    // SAFETY: TIMER2 was exclusively transferred into this input sampler.
    unsafe { &(*pac::TIMER2::ptr()).shorts }.reset();

    timer.enable_interrupt();
    timer.start(SAMPLE_INTERVAL_US);

    free(|cs| {
        INPUT.borrow(cs).replace(Some(InputSampler {
            timer,
            next_tick_us: SAMPLE_INTERVAL_US,
            button_a,
            button_b,
            buttons: Buttons::new(),
            logo,
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

/// Drain queued logo touches; returns zero when logo sampling is not enabled.
pub fn take_logo_presses() -> u8 {
    free(|cs| {
        INPUT
            .borrow(cs)
            .borrow_mut()
            .as_mut()
            .and_then(|input| input.logo.as_mut())
            .map_or(0, |logo| logo.detector.take_presses())
    })
}

/// Stop input sampling before entering System OFF, including under a debugger.
pub fn stop() {
    NVIC::mask(pac::Interrupt::TIMER2);

    free(|cs| {
        if let Some(mut input) = INPUT.borrow(cs).borrow_mut().take() {
            input.timer.disable_interrupt();
            input
                .timer
                .task_stop()
                .write(|writer| writer.tasks_stop().trigger());
            input.timer.reset_event();

            if let Some(logo) = input.logo.take() {
                logo.stop();
            }
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
            let now_us = input.timer.read();
            let deadline_us = input.next_tick_us.wrapping_add(SAMPLE_INTERVAL_US);
            let remaining_us = deadline_us.wrapping_sub(now_us);

            // Retain the nominal 2 ms cadence. Recover after a delayed ISR,
            // including a debugger halt, instead of waiting for a full wrap.
            // Leave enough time to program CC0 before the deadline arrives.
            input.next_tick_us =
                if !(DEADLINE_WRITE_MARGIN_US..=SAMPLE_INTERVAL_US).contains(&remaining_us) {
                    now_us.wrapping_add(SAMPLE_INTERVAL_US)
                } else {
                    deadline_us
                };

            // SAFETY: only this sampler programs TIMER2's tick comparator.
            unsafe { &(*pac::TIMER2::ptr()).cc[0] }
                .write(|writer| unsafe { writer.cc().bits(input.next_tick_us) });

            let button_a_pressed = input.button_a.is_low().unwrap();
            let button_b_pressed = input.button_b.is_low().unwrap();
            input.buttons.sample(button_a_pressed, button_b_pressed);

            if let Some(logo) = input.logo.as_mut() {
                logo.sample(&input.timer);
            }
        }
    });
}
