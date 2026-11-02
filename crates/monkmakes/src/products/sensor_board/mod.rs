//! Drivers for the MonkMakes [Sensor Board].
//!
//! Both drivers configure a 12-bit ADC with a VDD/4 reference and 1/4 gain.
//! Readings therefore represent fractions of the microcontroller's supply
//! voltage, rather than assuming a fixed 3 V supply. Power the sensor board
//! from the same supply and connect its ground to the microcontroller's ground.
//!
//! The microphone output is an audio waveform with a DC bias. Individual sound
//! readings are samples, not measurements in decibels. Light readings are
//! relative values, not lux. Temperature uses the board's 100 kΩ NTC thermistor
//! and 100 kΩ divider resistor, with the manufacturer's beta value of 4275 K.
//!
//! The thermistor model follows the [manufacturer's conversion code], using
//! the constants in its [datasheet]. Raw values can be converted without
//! acquiring a second set of samples:
//!
//! ```
//! use monkmakes::sensor_board::RawReadings;
//!
//! let raw = RawReadings {
//!     sound: 2048,
//!     temperature: 2048,
//!     light: 4095,
//! };
//!
//! let readings = raw.convert().unwrap();
//! assert!((readings.temperature_celsius - 25.0).abs() < 0.001);
//! assert_eq!(readings.light_fraction, 1.0);
//! assert_eq!(raw.temperature, 2048);
//! ```
//!
//! [Sensor Board]: https://monkmakes.com/mb_sensor
//! [manufacturer's conversion code]: https://github.com/monkmakes/pxt-sensor/blob/master/main.ts
//! [datasheet]: https://www.monkmakes.com/downloads/datasheet_sensor_for_mb.pdf

#[cfg(feature = "async")]
pub mod r#async;

#[cfg(feature = "blocking")]
pub mod blocking;

/// Largest representable positive reading from the configured 12-bit ADC.
pub const ADC_MAX: i16 = 4095;

// The SAADC transfer function uses 2^resolution, not the largest ADC code.
const ADC_FULL_SCALE: f32 = 4096.0;
const THERMISTOR_BETA: f32 = 4275.0;
const REFERENCE_TEMPERATURE_KELVIN: f32 = 298.15;
const CELSIUS_OFFSET: f32 = 273.15;

/// A failed acquisition, unusable thermistor reading, or empty sound window.
#[derive(Clone, Copy, Debug, PartialEq, Eq, thiserror::Error)]
pub enum Error {
    /// The blocking ADC could not acquire the requested channel.
    #[error("ADC acquisition failed")]
    Adc,
    /// The thermistor reading is at a rail, saturated, or outside the ADC range.
    #[error("invalid thermistor ADC reading: {0}")]
    InvalidTemperature(i16),
    /// At least one microphone sample is required to measure an amplitude.
    #[error("sound sample window is empty")]
    EmptySoundWindow,
}

/// Sensor values converted from the board's raw ADC readings.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Readings {
    /// Thermistor temperature in degrees Celsius, using the beta model.
    pub temperature_celsius: f32,
    /// Relative light intensity from 0.0 to 1.0; this is not lux.
    pub light_fraction: f32,
    /// Instantaneous microphone voltage fraction, including its DC bias.
    ///
    /// This is a waveform sample, not a sound level. Use the driver's
    /// `read_sound_level` method to measure amplitude over a window instead.
    pub sound_fraction: f32,
}

/// Raw ADC readings for the board's three analog outputs.
///
/// Nominal readings are `0..=ADC_MAX`. Signed values preserve small negative
/// ADC offsets close to ground, rather than wrapping them to large positives.
/// Samples are acquired in sound, temperature, light order; they are not
/// simultaneous. The microphone's DC bias is retained in `sound`.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct RawReadings {
    /// Instantaneous microphone sample, retaining the DC bias.
    pub sound: i16,
    /// Thermistor divider sample; larger values indicate a warmer thermistor.
    pub temperature: i16,
    /// Phototransistor sample; larger values indicate more light.
    pub light: i16,
}

impl RawReadings {
    /// Convert raw values to Celsius and relative light/microphone fractions.
    ///
    /// Raw values remain available even when an invalid temperature prevents
    /// this conversion from succeeding.
    pub fn convert(&self) -> Result<Readings, Error> {
        Ok(Readings {
            temperature_celsius: self.temperature_celsius()?,
            light_fraction: self.light_fraction(),
            sound_fraction: self.sound_fraction(),
        })
    }

    /// Convert the thermistor reading to degrees Celsius using the beta model.
    ///
    /// The manufacturer's divider has the thermistor above a fixed 100 kΩ
    /// resistor, and both resistors equal 100 kΩ at 25 °C. For ADC count `raw`,
    /// the equations are `ratio = (4096 - raw) / raw` and
    /// `celsius = 1 / (1 / 298.15 + ln(ratio) / 4275) - 273.15`.
    /// Here 4096 is the nominal ADC full scale (`2^12`); the highest
    /// representable code is 4095 and is treated as saturation.
    ///
    /// Half scale (`2048`) corresponds to 25 °C. Higher readings indicate a
    /// warmer thermistor. Rail and saturated readings return an error instead
    /// of producing a misleading finite value. Component tolerances and supply
    /// differences still affect accuracy; this is not a calibrated thermometer.
    pub fn temperature_celsius(&self) -> Result<f32, Error> {
        if self.temperature <= 0 || self.temperature >= ADC_MAX {
            return Err(Error::InvalidTemperature(self.temperature));
        }

        // R_NTC / R_25 = (VDD - Vout) / Vout because R_fixed = R_25.
        // This orientation follows the manufacturer's MakeCode extension:
        // https://github.com/monkmakes/pxt-sensor/blob/master/main.ts
        let resistance_ratio = ADC_FULL_SCALE / f32::from(self.temperature) - 1.0;
        let inverse_kelvin =
            REFERENCE_TEMPERATURE_KELVIN.recip() + libm::logf(resistance_ratio) / THERMISTOR_BETA;

        Ok(inverse_kelvin.recip() - CELSIUS_OFFSET)
    }

    /// Return relative light intensity from 0.0 (ground) to 1.0 (ADC maximum).
    ///
    /// ADC noise outside the nominal range is clamped. This scales the raw
    /// code span linearly as `clamp(light, 0, 4095) / 4095`; it does not convert
    /// the phototransistor to lux or model its nonlinear response to light.
    pub fn light_fraction(&self) -> f32 {
        f32::from(self.light.clamp(0, ADC_MAX)) / f32::from(ADC_MAX)
    }

    /// Return the instantaneous, DC-biased microphone sample scaled to 0.0..=1.0.
    ///
    /// This computes `clamp(sound, 0, 4095) / 4095`. It is a relative voltage
    /// fraction rather than a measurement of sound level; the signal's DC bias
    /// is retained and is not assumed to be exactly half of the ADC range.
    pub fn sound_fraction(&self) -> f32 {
        f32::from(self.sound.clamp(0, ADC_MAX)) / f32::from(ADC_MAX)
    }
}

/// Return a microphone window's peak-to-peak amplitude in ADC counts.
///
/// An empty window returns `None`. A constant waveform returns `Some(0)`,
/// regardless of its DC bias. Choose the sampling rate and window duration in
/// application code; this function does not imply a calibrated sound level.
pub fn sound_peak_to_peak(samples: &[i16]) -> Option<u16> {
    let (&first, remaining) = samples.split_first()?;
    let (minimum, maximum) = remaining.iter().fold((first, first), |acc, &sample| {
        (acc.0.min(sample), acc.1.max(sample))
    });

    Some((i32::from(maximum) - i32::from(minimum)) as u16)
}

/// Convert raw microphone samples to a relative peak-to-peak sound amplitude.
///
/// The result is `clamp((max(samples) - min(samples)) / 4096, 0, 1)`. The
/// nominal ADC span is 4096 counts. Taking the difference removes a constant
/// DC bias without assuming its voltage. An empty window returns
/// [`Error::EmptySoundWindow`]; a single sample has zero measured amplitude.
///
/// This is a voltage-span fraction rather than decibels. The window duration,
/// sample spacing, and microphone clipping affect the measured amplitude.
pub fn sound_level(samples: &[i16]) -> Result<f32, Error> {
    let amplitude = sound_peak_to_peak(samples).ok_or(Error::EmptySoundWindow)?;

    Ok((f32::from(amplitude) / ADC_FULL_SCALE).clamp(0.0, 1.0))
}

#[cfg(test)]
mod tests;
