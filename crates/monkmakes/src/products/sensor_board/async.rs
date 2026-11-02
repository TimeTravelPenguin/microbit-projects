//! Asynchronous sensor board acquisition with Embassy's nRF SAADC driver.

use embassy_nrf::{
    Peri,
    interrupt::typelevel::{Binding, SAADC as SaadcInterrupt},
    peripherals::SAADC,
    saadc::{self, ChannelConfig, Input, InterruptHandler, Saadc},
};

use super::{Error, RawReadings, Readings, sound_level};

/// Owns an Embassy SAADC configured for the board's three analog outputs.
pub struct SensorBoard<'d> {
    adc: Saadc<'d, 3>,
}

impl<'d> SensorBoard<'d> {
    /// Configure and asynchronously calibrate the ADC before returning.
    ///
    /// Pin order is sound, temperature, light. Supply a binding from the SAADC
    /// interrupt to [`saadc::InterruptHandler`], as required by Embassy. The
    /// caller initializes Embassy; this constructor does not take peripherals
    /// globally or configure clocks.
    pub async fn new(
        peripheral: Peri<'d, SAADC>,
        interrupts: impl Binding<SaadcInterrupt, InterruptHandler> + 'd,
        sound_pin: impl Input + 'd,
        temperature_pin: impl Input + 'd,
        light_pin: impl Input + 'd,
    ) -> Self {
        let mut config = saadc::Config::default();
        config.resolution = saadc::Resolution::_12bit;
        config.oversample = saadc::Oversample::Bypass;

        let channels = [
            channel_config(sound_pin),
            channel_config(temperature_pin),
            channel_config(light_pin),
        ];

        let adc = Saadc::new(peripheral, interrupts, config, channels);
        adc.calibrate().await;

        Self { adc }
    }

    /// Acquire Celsius, relative light, and a normalized microphone waveform sample.
    ///
    /// Use [`Self::read_sound_level`] to measure sound amplitude over a window.
    pub async fn read(&mut self) -> Result<Readings, Error> {
        self.read_raw().await?.convert()
    }

    /// Acquire one raw reading from each sensor, in sound/temperature/light order.
    ///
    /// The result type matches the blocking driver. Embassy's one-shot sample
    /// acquisition itself is infallible.
    pub async fn read_raw(&mut self) -> Result<RawReadings, Error> {
        let mut samples = [0; 3];
        self.adc.sample(&mut samples).await;

        Ok(RawReadings {
            sound: samples[0],
            temperature: samples[1],
            light: samples[2],
        })
    }

    /// Fill a raw microphone window and return relative peak-to-peak amplitude.
    ///
    /// The result is `clamp((max(samples) - min(samples)) / 4096, 0, 1)`, a
    /// fraction of the ADC's nominal full-scale span rather than decibels.
    /// Each microphone sample comes from a three-channel ADC scan.
    /// Sampling is unpaced and its rate depends on scan/executor overhead, so
    /// window lengths are not directly comparable to the blocking driver.
    /// An empty buffer returns [`Error::EmptySoundWindow`].
    pub async fn read_sound_level(&mut self, samples: &mut [i16]) -> Result<f32, Error> {
        if samples.is_empty() {
            return Err(Error::EmptySoundWindow);
        }

        for sample in samples.iter_mut() {
            let mut readings = [0; 3];
            self.adc.sample(&mut readings).await;
            *sample = readings[0];
        }

        sound_level(samples)
    }

    /// Return the owned three-channel Embassy ADC.
    pub fn into_inner(self) -> Saadc<'d, 3> {
        self.adc
    }
}

fn channel_config<'d>(pin: impl Input + 'd) -> ChannelConfig<'d> {
    let mut config = ChannelConfig::single_ended(pin);
    config.reference = saadc::Reference::VDD1_4;
    config.gain = saadc::Gain::Gain1_4;
    config.time = saadc::Time::_20US;

    config
}
