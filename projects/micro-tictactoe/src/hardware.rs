use cardkb::r#async::CardKb;
use embassy_nrf::twim::Twim;
use ssd1306::{I2CDisplayInterface, Ssd1306Async, mode::BufferedGraphicsModeAsync, prelude::*};

pub type Oled<I> =
    Ssd1306Async<I2CInterface<I>, DisplaySize128x64, BufferedGraphicsModeAsync<DisplaySize128x64>>;

pub async fn init_display<'d>(bus: Twim<'d>) -> Oled<Twim<'d>> {
    let interface = I2CDisplayInterface::new(bus);
    let mut display = Ssd1306Async::new(interface, DisplaySize128x64, DisplayRotation::Rotate0)
        .into_buffered_graphics_mode();

    display.init().await.expect("Failed to initialize display");
    display.clear_buffer();
    display.flush().await.expect("Failed to flush display");
    display
        .set_display_on(true)
        .await
        .expect("Failed to turn on display");

    display
}

pub fn init_cardkb<'d>(bus: Twim<'d>) -> CardKb<Twim<'d>> {
    CardKb::new(bus)
}
