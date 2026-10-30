pub use cardkb::r#async::CardKb;
use embassy_nrf::{
    Peri, PeripheralType, bind_interrupts,
    gpio::{AnyPin, Pin},
    peripherals,
    twim::{self, Twim},
};

use ssd1306::{
    I2CDisplayInterface, Ssd1306Async, mode::BufferedGraphicsModeAsync, prelude::*,
    size::DisplaySizeAsync,
};

bind_interrupts!(struct Irqs {
    TWISPI0 => twim::InterruptHandler<peripherals::TWISPI0>;
    TWISPI1 => twim::InterruptHandler<peripherals::TWISPI1>;
});

pub const DISPLAY_SIZE: DisplaySize128x64 = DisplaySize128x64;

pub type Oled<I2c, Size> = Ssd1306Async<I2CInterface<I2c>, Size, BufferedGraphicsModeAsync<Size>>;

pub struct Hardware<'d, Size: DisplaySizeAsync> {
    pub display: Oled<Twim<'d>, Size>,
    pub cardkb: CardKb<Twim<'d>>,
}

impl<'d, Size> Hardware<'d, Size>
where
    Size: DisplaySizeAsync,
{
    pub async fn new(busses: Busses<'d>, display_size: Size) -> Self {
        let display = init_display(busses.display, display_size).await;
        let cardkb = init_cardkb(busses.cardkb);

        Self { display, cardkb }
    }
}

/// An I²C peripheral, its pins, and optional transmit scratch storage.
pub struct BusParts<'d, Peripheral: PeripheralType> {
    pub peripheral: Peri<'d, Peripheral>,
    pub sda: Peri<'d, AnyPin>,
    pub scl: Peri<'d, AnyPin>,
    /// RAM scratch space for transmitting data stored in flash. It can be
    /// empty when all transmitted data is already in RAM.
    pub tx_buffer: &'d mut [u8],
}

impl<'d, Peripheral: PeripheralType> BusParts<'d, Peripheral> {
    pub fn new(
        peripheral: Peri<'d, Peripheral>,
        sda: Peri<'d, impl Pin>,
        scl: Peri<'d, impl Pin>,
    ) -> Self {
        Self {
            peripheral,
            sda: sda.into(),
            scl: scl.into(),
            tx_buffer: &mut [],
        }
    }
}

/// Convert a `(peripheral, SDA, SCL)` tuple with empty transmit scratch storage.
impl<'d, Peripheral, Sda, Scl> From<(Peri<'d, Peripheral>, Peri<'d, Sda>, Peri<'d, Scl>)>
    for BusParts<'d, Peripheral>
where
    Peripheral: PeripheralType,
    Sda: Pin,
    Scl: Pin,
{
    fn from((peripheral, sda, scl): (Peri<'d, Peripheral>, Peri<'d, Sda>, Peri<'d, Scl>)) -> Self {
        Self::new(peripheral, sda, scl)
    }
}

pub type DisplayBusParts<'d> = BusParts<'d, peripherals::TWISPI0>;
pub type CardKbBusParts<'d> = BusParts<'d, peripherals::TWISPI1>;

pub struct Busses<'d> {
    display: Twim<'d>,
    cardkb: Twim<'d>,
}

impl<'d> Busses<'d> {
    pub fn new(display: DisplayBusParts<'d>, cardkb: CardKbBusParts<'d>) -> Self {
        let mut display_config = twim::Config::default();
        display_config.frequency = twim::Frequency::K400;

        let display = Twim::new(
            display.peripheral,
            Irqs,
            display.sda,
            display.scl,
            display_config,
            display.tx_buffer,
        );

        let mut cardkb_config = twim::Config::default();
        cardkb_config.frequency = twim::Frequency::K100;

        let cardkb = Twim::new(
            cardkb.peripheral,
            Irqs,
            cardkb.sda,
            cardkb.scl,
            cardkb_config,
            cardkb.tx_buffer,
        );

        Self { display, cardkb }
    }
}

pub async fn init_display<'d, Size>(bus: Twim<'d>, size: Size) -> Oled<Twim<'d>, Size>
where
    Size: DisplaySizeAsync,
{
    let interface = I2CDisplayInterface::new(bus);
    let mut display =
        Ssd1306Async::new(interface, size, DisplayRotation::Rotate0).into_buffered_graphics_mode();

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
