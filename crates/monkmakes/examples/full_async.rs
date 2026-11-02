//! Show temperature and light readings on the display; A/B toggle the mode.
//!
//! Connect display RX/arrow to edge P0 (P0.02), sensor temperature to P1
//! (P0.03), and light to P2 (P0.04). Both boards share the micro:bit's 3V and GND.
//! The microphone is omitted: leave the sensor board's sound output disconnected.
//! The three-channel driver still reserves P0.31 (edge P3) as an unused ADC
//! input. Leave P3 unwired; its floating sound reading is ignored.
//!
//! Temperature is shown with one decimal place and C when it fits four display
//! positions, otherwise as a rounded integer with C. Light is shown as a
//! percentage of the ADC signal range with two decimal places, falling back to
//! one decimal at 100% to fit four positions. Multiplying the driver's light
//! fraction by 100 converts it to this percentage; it is not calibrated lux or
//! perceived brightness. Indoor signals can occupy only a small part of the ADC
//! range, so decimal places preserve readings that would round to zero as whole
//! percentages. A sensor error shows Err; values too wide to display show ----.
//! Startup shows 8888 before ADC calibration, then temperature. The display
//! updates at most five times a second.

#![no_std]
#![no_main]

use core::cell::RefCell;

use cortex_m::interrupt::{Mutex, free};
use embassy_executor::Spawner;
use embassy_nrf::{
    bind_interrupts,
    config::HfclkSource,
    gpio::{Input, Pull},
    saadc, uarte,
};
use embassy_time::Timer;
use heapless::{Deque, format};
use microbit_input::{ButtonPresses, Buttons};
use monkmakes::{sensor_board::r#async::SensorBoard, seven_segment::r#async::SevenSegment};
use panic_rtt_target as _;
use rtt_target::{rprintln, rtt_init_print};

static BUTTONS: Mutex<RefCell<Buttons>> = Mutex::new(RefCell::new(Buttons::new()));

bind_interrupts!(struct Irqs {
    SAADC => saadc::InterruptHandler;
    UARTE0 => uarte::InterruptHandler<embassy_nrf::peripherals::UARTE0>;
});

#[derive(Clone, Copy, Debug)]
enum DisplayMode {
    Temperature,
    Light,
}

#[embassy_executor::task]
async fn sample(button_a: Input<'static>, button_b: Input<'static>) {
    loop {
        free(|ctx| {
            BUTTONS
                .borrow(ctx)
                .borrow_mut()
                .sample(button_a.is_low(), button_b.is_low());
        });

        Timer::after_millis(2).await;
    }
}

fn take_presses() -> ButtonPresses {
    free(|ctx| BUTTONS.borrow(ctx).borrow_mut().take_presses())
}

#[embassy_executor::main]
async fn main(spawner: Spawner) {
    rtt_init_print!();

    let mut config = embassy_nrf::config::Config::default();
    config.hfclk_source = HfclkSource::ExternalXtal;

    let peripherals = embassy_nrf::init(config);

    let button_a = Input::new(peripherals.P0_14, Pull::Up);
    let button_b = Input::new(peripherals.P0_23, Pull::Up);
    spawner.spawn(sample(button_a, button_b).unwrap());

    let mut display = SevenSegment::new(peripherals.UARTE0, Irqs, peripherals.P0_02);

    // Check the display before awaiting sensor initialization.
    Timer::after_millis(100).await;
    display.clear().await.unwrap();
    display.display("8888,").await.unwrap();
    rprintln!("Display ready on edge P0 (P0.02): 8888");
    Timer::after_millis(500).await;

    rprintln!("Calibrating sensor ADC");
    // The driver's required third input stays unwired because sound is omitted.
    let mut sensors = SensorBoard::new(
        peripherals.SAADC,
        Irqs,
        peripherals.P0_31,
        peripherals.P0_03,
        peripherals.P0_04,
    )
    .await;

    rprintln!("Sensor ADC ready");

    // Values are stored in a fixed-size deque to compute a moving average
    let mut values: Deque<f32, 10> = Deque::new();
    let mut mode = DisplayMode::Temperature;

    loop {
        let presses = take_presses();

        let press_count = u16::from(presses.button_a) + u16::from(presses.button_b);

        if press_count % 2 == 1 {
            mode = match mode {
                DisplayMode::Temperature => DisplayMode::Light,
                DisplayMode::Light => DisplayMode::Temperature,
            };

            values.clear();
        }

        let text = match sensors.read().await {
            Ok(readings) => match mode {
                DisplayMode::Temperature => {
                    if values.push_back(readings.temperature_celsius).is_err() {
                        values.pop_front();
                        values.push_back(readings.temperature_celsius).unwrap();
                    }

                    let average_temp: f32 = values.iter().sum::<f32>() / values.len() as f32;

                    rprintln!("Temperature: {:.1} C", average_temp);

                    // The decimal point uses one byte but no additional display position.
                    format!(5; "{:>4.1}C", average_temp)
                        // The average temperature may be too wide to display with one decimal place.
                        .or_else(|_| format!(5; "{:>3.0}C", average_temp))
                }
                DisplayMode::Light => {
                    let light_level = readings.light_fraction * 1023.0;

                    if values.push_back(light_level).is_err() {
                        values.pop_front();
                        values.push_back(light_level).unwrap();
                    }

                    let average_light: f32 = values.iter().sum::<f32>() / values.len() as f32;
                    let average_light: u32 = (average_light + 0.5) as u32;

                    rprintln!("Light: {:.2}", average_light);

                    format!(5; "{:>5}", average_light)
                }
            },
            Err(error) => {
                rprintln!("{:?} reading failed: {:?}", mode, error);
                format!(5; "Err")
            }
        };

        let text = text.as_deref().unwrap_or("----");
        let frame = format!(10; "    {},", text).unwrap();

        display.display(&frame).await.unwrap();
        Timer::after_millis(200).await;
    }
}
