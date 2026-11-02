//! Blocking sensor board acquisition with the nRF52833 SAADC.

use nrf52833_hal::{
    pac::SAADC,
    saadc::{Channel, Gain, Oversample, Reference, Resolution, Saadc, SaadcConfig, Time},
};

use super::{Error, RawReadings, Readings, sound_level};

/// Owns the ADC and the pins connected to sound, temperature, and light.
///
/// Keep the analog pins in their disconnected or floating-input state. Pass
/// typed pins directly (for example `board.edge.e00`); degrading a pin erases
/// the ADC channel information required by this HAL.
pub struct SensorBoard<SoundPin, TemperaturePin, LightPin> {
    adc: Saadc,
    sound_pin: SoundPin,
    temperature_pin: TemperaturePin,
    light_pin: LightPin,
}

impl<SoundPin: Channel, TemperaturePin: Channel, LightPin: Channel>
    SensorBoard<SoundPin, TemperaturePin, LightPin>
{
    /// Configure and calibrate the ADC, taking ownership of all three inputs.
    ///
    /// Pin order is sound, temperature, light. Only analog-capable pins are
    /// accepted. No additional delay or executor is required for calibration.
    pub fn new(
        peripheral: SAADC,
        sound_pin: SoundPin,
        temperature_pin: TemperaturePin,
        light_pin: LightPin,
    ) -> Self {
        let config = SaadcConfig {
            resolution: Resolution::_12BIT,
            oversample: Oversample::BYPASS,
            reference: Reference::VDD1_4,
            gain: Gain::GAIN1_4,
            time: Time::_20US,
            ..SaadcConfig::default()
        };

        Self {
            adc: Saadc::new(peripheral, config),
            sound_pin,
            temperature_pin,
            light_pin,
        }
    }

    /// Acquire Celsius, relative light, and a normalized microphone waveform sample.
    ///
    /// Use [`Self::read_sound_level`] to measure sound amplitude over a window.
    pub fn read(&mut self) -> Result<Readings, Error> {
        self.read_raw()?.convert()
    }

    /// Acquire one raw reading from each sensor, in sound/temperature/light order.
    pub fn read_raw(&mut self) -> Result<RawReadings, Error> {
        let sound = self
            .adc
            .read_channel(&mut self.sound_pin)
            .map_err(|()| Error::Adc)?;
        let temperature = self
            .adc
            .read_channel(&mut self.temperature_pin)
            .map_err(|()| Error::Adc)?;
        let light = self
            .adc
            .read_channel(&mut self.light_pin)
            .map_err(|()| Error::Adc)?;

        Ok(RawReadings {
            sound,
            temperature,
            light,
        })
    }

    /// Fill a raw microphone window and return relative peak-to-peak amplitude.
    ///
    /// The result is `clamp((max(samples) - min(samples)) / 4096, 0, 1)`, a
    /// fraction of the ADC's nominal full-scale span rather than decibels.
    /// The sampling rate is determined by ADC acquisition overhead;
    /// no delay is inserted. The buffer length determines the window duration.
    /// An empty buffer returns [`Error::EmptySoundWindow`].
    pub fn read_sound_level(&mut self, samples: &mut [i16]) -> Result<f32, Error> {
        if samples.is_empty() {
            return Err(Error::EmptySoundWindow);
        }

        for sample in samples.iter_mut() {
            *sample = self
                .adc
                .read_channel(&mut self.sound_pin)
                .map_err(|()| Error::Adc)?;
        }

        sound_level(samples)
    }

    /// Disable the ADC and return its peripheral together with the owned pins.
    pub fn free(self) -> (SAADC, SoundPin, TemperaturePin, LightPin) {
        (
            self.adc.free(),
            self.sound_pin,
            self.temperature_pin,
            self.light_pin,
        )
    }
}
