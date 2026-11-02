use super::{ADC_MAX, Error, RawReadings, sound_level, sound_peak_to_peak};

fn readings(temperature: i16, light: i16) -> RawReadings {
    RawReadings {
        sound: 2048,
        temperature,
        light,
    }
}

#[test]
fn equal_divider_resistances_produce_25_degrees_at_half_scale() {
    let temperature = readings(2048, 0).temperature_celsius().unwrap();
    assert!((temperature - 25.0).abs() < 0.001);
}

#[test]
fn higher_divider_readings_mean_a_warmer_ntc_thermistor() {
    let cold = readings(1024, 0).temperature_celsius().unwrap();
    let reference = readings(2048, 0).temperature_celsius().unwrap();
    let warm = readings(3072, 0).temperature_celsius().unwrap();

    assert!(cold < reference);
    assert!(reference < warm);
    assert!((cold - 3.781_462).abs() < 0.001);
    assert!((warm - 49.739_88).abs() < 0.001);
}

#[test]
fn thermistor_rails_and_out_of_range_readings_are_rejected() {
    for raw in [i16::MIN, -1, 0, ADC_MAX, ADC_MAX + 1, i16::MAX] {
        assert_eq!(
            readings(raw, 0).temperature_celsius(),
            Err(Error::InvalidTemperature(raw))
        );
    }
}

#[test]
fn valid_readings_adjacent_to_the_rails_still_convert() {
    for raw in [1, ADC_MAX - 1] {
        assert!(readings(raw, 0).temperature_celsius().unwrap().is_finite());
    }
}

#[test]
fn light_fraction_scales_the_raw_span_and_clamps_adc_noise() {
    assert_eq!(readings(2048, i16::MIN).light_fraction(), 0.0);
    assert_eq!(readings(2048, 0).light_fraction(), 0.0);
    assert!((readings(2048, 2048).light_fraction() - 0.5).abs() < 0.001);
    assert_eq!(readings(2048, ADC_MAX).light_fraction(), 1.0);
    assert_eq!(readings(2048, i16::MAX).light_fraction(), 1.0);
}

#[test]
fn converted_readings_preserve_units_and_leave_raw_values_available() {
    let raw = RawReadings {
        sound: 1024,
        temperature: 2048,
        light: ADC_MAX,
    };

    let converted = raw.convert().unwrap();
    assert!((converted.temperature_celsius - 25.0).abs() < 0.001);
    assert_eq!(converted.light_fraction, 1.0);
    assert!((converted.sound_fraction - 0.25).abs() < 0.001);
    assert_eq!(raw.sound, 1024);
    assert_eq!(raw.temperature, 2048);
    assert_eq!(raw.light, ADC_MAX);

    let invalid = readings(0, ADC_MAX);
    assert_eq!(invalid.convert(), Err(Error::InvalidTemperature(0)));
    assert_eq!(invalid.light_fraction(), 1.0);
}

#[test]
fn sound_window_removes_dc_bias_without_assuming_a_supply_voltage() {
    assert_eq!(sound_peak_to_peak(&[]), None);
    assert_eq!(sound_peak_to_peak(&[1700]), Some(0));
    assert_eq!(sound_peak_to_peak(&[1700, 1700, 1700]), Some(0));
    assert_eq!(sound_peak_to_peak(&[1600, 1700, 1900, 1650]), Some(300));
    assert_eq!(sound_peak_to_peak(&[i16::MIN, i16::MAX]), Some(u16::MAX));
}

#[test]
fn sound_level_normalizes_amplitude_and_rejects_an_empty_window() {
    assert_eq!(sound_level(&[]), Err(Error::EmptySoundWindow));
    assert_eq!(sound_level(&[1800, 1800]), Ok(0.0));
    assert_eq!(sound_level(&[1024, 3072]), Ok(0.5));
    assert_eq!(sound_level(&[i16::MIN, i16::MAX]), Ok(1.0));
}
