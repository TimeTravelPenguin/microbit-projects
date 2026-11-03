use core::f32::consts::PI;

/// Microphone sample rate in samples per second.
pub const SAMPLE_RATE: u32 = 8_000;
/// A 64 ms FFT window, with 15.625 Hz between frequency bins.
pub const FFT_LEN: usize = 512;
/// Advance the FFT by 16 ms, retaining 75% of the previous window.
pub const HOP_LEN: usize = 128;
/// Eight FFT bins per displayed band: 125 Hz per band.
pub const BAND_COUNT: usize = 32;
pub const HISTORY_LEN: usize = 104;

const ADC_FULL_SCALE: f32 = 8_192.0;
const SPECTRUM_FLOOR_DB: f32 = -90.0;
const SPECTRUM_FLOOR_POWER: f32 = 0.000_000_001;
const SPECTRUM_RANGE_DB: f32 = 40.0;
const SPECTRUM_HEADROOM_DB: f32 = 6.0;
const SPECTRUM_RELEASE: f32 = 0.05;
const RMS_FLOOR_DB: f32 = -100.0;
const RMS_FLOOR_POWER: f32 = 0.000_000_000_1;
const BAND_HEIGHT: f32 = 40.0;
const BINS_PER_BAND: usize = FFT_LEN / 2 / BAND_COUNT;

/// Measurements from the latest complete microphone window.
///
/// Levels are relative to the ADC's full-scale AC amplitude, not calibrated SPL.
#[derive(Clone, Copy, Debug)]
pub struct Analysis {
    /// The latest 104 individual samples, with the window's DC mean removed.
    pub waveform: [i16; HISTORY_LEN],
    /// RMS over the 512-sample window, rounded to integer dBFS.
    pub rms_dbfs: i16,
    /// Frequency of the strongest non-DC FFT bin; zero below the display floor.
    pub peak_hz: u16,
    /// Upper end of the automatically adjusted 40 dB spectrum display range.
    pub spectrum_ceiling_dbfs: i16,
    /// Strongest bin's linear power per band, relative to full-scale amplitude squared.
    /// Average these powers before applying display gain or converting to dB.
    pub band_power: [f32; BAND_COUNT],
    /// Maximum bin amplitude in each band, mapped into the current range as 0..40.
    pub bands: [u8; BAND_COUNT],
}

/// Fixed-size, allocation-free overlapping FFT analysis.
pub struct Analyzer {
    samples: [i16; FFT_LEN],
    filled: usize,
    window: [f32; FFT_LEN],
    fft_buffer: [f32; FFT_LEN],
    spectrum_ceiling: Option<f32>,
}

impl Analyzer {
    pub fn new() -> Self {
        let mut window = [0.0; FFT_LEN];

        for (idx, coefficient) in window.iter_mut().enumerate() {
            // A periodic Hann window sums to N/2, simplifying amplitude scaling.
            *coefficient = 0.5 - 0.5 * libm::cosf(2.0 * PI * idx as f32 / FFT_LEN as f32);
        }

        Self {
            samples: [0; FFT_LEN],
            filled: 0,
            window,
            fft_buffer: [0.0; FFT_LEN],
            spectrum_ceiling: None,
        }
    }

    /// Produce a result after four initial blocks, then after every new block.
    pub fn push(&mut self, block: &[i16; HOP_LEN]) -> Option<Analysis> {
        self.samples.copy_within(HOP_LEN.., 0);
        self.samples[FFT_LEN - HOP_LEN..].copy_from_slice(block);
        self.filled = (self.filled + HOP_LEN).min(FFT_LEN);

        if self.filled < FFT_LEN {
            return None;
        }

        Some(self.analyze())
    }

    /// Discard overlap after a capture gap so disjoint samples never share an FFT.
    pub fn reset(&mut self) {
        self.samples.fill(0);
        self.filled = 0;
        self.spectrum_ceiling = None;
    }

    fn analyze(&mut self) -> Analysis {
        let sum: i32 = self.samples.iter().map(|sample| i32::from(*sample)).sum();
        let mean = sum as f32 / FFT_LEN as f32;
        let mut mean_square = 0.0;

        for (idx, sample) in self.samples.iter().enumerate() {
            let centered = (*sample as f32 - mean) / ADC_FULL_SCALE;
            mean_square += centered * centered;
            self.fft_buffer[idx] = centered * self.window[idx];
        }

        mean_square /= FFT_LEN as f32;

        let mut waveform = [0; HISTORY_LEN];

        for (sample, output) in self.samples[FFT_LEN - HISTORY_LEN..]
            .iter()
            .zip(&mut waveform)
        {
            // Float-to-integer casts saturate if an out-of-range sample is supplied.
            *output = libm::roundf(*sample as f32 - mean) as i16;
        }

        let spectrum = microfft::real::rfft_512(&mut self.fft_buffer);
        let amplitude_scale = 4.0 / FFT_LEN as f32;
        let power_scale = amplitude_scale * amplitude_scale;
        let mut band_power = [0.0_f32; BAND_COUNT];
        let mut peak_power = 0.0;
        let mut peak_bin = 0;

        // microfft packs Nyquist into bin zero's imaginary component. Skipping
        // bin zero excludes both DC and the exact 4 kHz Nyquist endpoint.
        for (bin, coefficient) in spectrum.iter().enumerate().skip(1) {
            let power =
                (coefficient.re * coefficient.re + coefficient.im * coefficient.im) * power_scale;
            let band = bin / BINS_PER_BAND;
            band_power[band] = band_power[band].max(power);

            if power > peak_power {
                peak_power = power;
                peak_bin = bin;
            }
        }

        let (bands, ceiling) = scale_spectrum(&band_power, self.spectrum_ceiling);
        self.spectrum_ceiling = Some(ceiling);

        let peak_hz = if peak_power < SPECTRUM_FLOOR_POWER {
            0
        } else {
            ((peak_bin as u32 * SAMPLE_RATE + FFT_LEN as u32 / 2) / FFT_LEN as u32) as u16
        };

        Analysis {
            waveform,
            rms_dbfs: libm::roundf(power_dbfs(mean_square, RMS_FLOOR_POWER, RMS_FLOOR_DB)) as i16,
            peak_hz,
            spectrum_ceiling_dbfs: libm::roundf(ceiling) as i16,
            band_power,
            bands,
        }
    }
}

impl Default for Analyzer {
    fn default() -> Self {
        Self::new()
    }
}

/// Map physical powers to bars; only live spectra need additional gain smoothing.
pub(crate) fn scale_spectrum(
    band_power: &[f32; BAND_COUNT],
    previous_ceiling: Option<f32>,
) -> ([u8; BAND_COUNT], f32) {
    let peak_power = band_power.iter().copied().fold(0.0_f32, f32::max);
    let peak_dbfs = power_dbfs(peak_power, SPECTRUM_FLOOR_POWER, SPECTRUM_FLOOR_DB);
    let target_ceiling =
        (peak_dbfs + SPECTRUM_HEADROOM_DB).clamp(SPECTRUM_FLOOR_DB + SPECTRUM_HEADROOM_DB, 0.0);
    let ceiling = previous_ceiling.map_or(target_ceiling, |previous| {
        if target_ceiling >= previous {
            target_ceiling
        } else {
            previous + (target_ceiling - previous) * SPECTRUM_RELEASE
        }
    });

    let lower_edge = ceiling - SPECTRUM_RANGE_DB;
    let mut bands = [0; BAND_COUNT];

    for (power, height) in band_power.iter().zip(&mut bands) {
        // A fixed absolute floor prevents gain from lighting DC/silent bins.
        if *power <= SPECTRUM_FLOOR_POWER {
            continue;
        }

        let dbfs = power_dbfs(*power, SPECTRUM_FLOOR_POWER, SPECTRUM_FLOOR_DB);
        let scaled = (dbfs - lower_edge) * BAND_HEIGHT / SPECTRUM_RANGE_DB;
        *height = libm::roundf(scaled.clamp(0.0, BAND_HEIGHT)) as u8;
    }

    (bands, ceiling)
}

fn power_dbfs(power: f32, floor_power: f32, floor_db: f32) -> f32 {
    (10.0 * libm::log10f(power.max(floor_power))).clamp(floor_db, 0.0)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn tone(sample: usize, frequency: f32, amplitude: f32) -> f32 {
        amplitude * libm::sinf(2.0 * PI * frequency * sample as f32 / SAMPLE_RATE as f32)
    }

    fn analyze_signal(signal: impl Fn(usize) -> i16) -> Analysis {
        let mut analyzer = Analyzer::new();
        let mut result = None;

        for block_idx in 0..FFT_LEN / HOP_LEN {
            let block = core::array::from_fn(|idx| signal(block_idx * HOP_LEN + idx));
            result = analyzer.push(&block);
        }

        result.unwrap()
    }

    #[test]
    fn initialization_requires_a_complete_window_then_emits_each_hop() {
        let mut analyzer = Analyzer::new();
        let block = [8_192; HOP_LEN];

        for _ in 0..3 {
            assert!(analyzer.push(&block).is_none());
        }

        assert!(analyzer.push(&block).is_some());
        assert!(analyzer.push(&block).is_some());
    }

    #[test]
    fn silence_and_dc_offsets_have_no_ac_level_or_spectral_peak() {
        for dc_level in [0, 1_234, 8_192, 16_383] {
            let analysis = analyze_signal(|_| dc_level);
            assert_eq!(analysis.waveform, [0; HISTORY_LEN]);
            assert_eq!(analysis.rms_dbfs, -100);
            assert_eq!(analysis.peak_hz, 0);
            assert_eq!(analysis.spectrum_ceiling_dbfs, -84);
            assert_eq!(analysis.bands, [0; BAND_COUNT]);
        }
    }

    #[test]
    fn a_one_kilohertz_tone_uses_bin_64_and_has_correct_relative_level() {
        let analysis =
            analyze_signal(|sample| libm::roundf(8_192.0 + tone(sample, 1_000.0, 4_096.0)) as i16);

        assert_eq!(analysis.peak_hz, 1_000);
        assert_eq!(analysis.rms_dbfs, -9);
        assert_eq!(analysis.bands[8], 34);
        assert_eq!(analysis.spectrum_ceiling_dbfs, 0);
        assert!((analysis.band_power[8] - 0.25).abs() < 0.0001);
        assert!(analysis.bands[8] > analysis.bands[6]);
        assert!(analysis.bands[8] > analysis.bands[10]);
    }

    #[test]
    fn a_mixed_signal_selects_the_stronger_tone() {
        let analysis = analyze_signal(|sample| {
            libm::roundf(8_192.0 + tone(sample, 500.0, 512.0) + tone(sample, 1_000.0, 2_048.0))
                as i16
        });

        assert_eq!(analysis.peak_hz, 1_000);
        assert!(analysis.bands[8] > analysis.bands[4]);
        assert!(analysis.bands[4] > 0);
    }

    #[test]
    fn a_fifth_hop_retains_overlap_and_the_latest_samples_in_order() {
        let mut analyzer = Analyzer::new();

        for block_idx in 0..4 {
            let block = core::array::from_fn(|idx| (block_idx * HOP_LEN + idx) as i16);
            analyzer.push(&block);
        }

        let block = core::array::from_fn(|idx| (1_000 + idx * 2) as i16);
        let analysis = analyzer.push(&block).unwrap();
        assert_eq!(analyzer.samples[0], 128);
        assert_eq!(analyzer.samples[FFT_LEN - HOP_LEN - 1], 511);
        assert_eq!(analyzer.samples[FFT_LEN - HOP_LEN], 1_000);
        assert_eq!(analyzer.samples[FFT_LEN - 1], 1_254);

        let expected_mean = (128..512).sum::<i32>() as f32 / FFT_LEN as f32
            + (0..HOP_LEN).map(|idx| 1_000 + idx * 2).sum::<usize>() as f32 / FFT_LEN as f32;

        for (idx, sample) in analysis.waveform.iter().enumerate() {
            let expected = 1_000 + (HOP_LEN - HISTORY_LEN + idx) * 2;
            assert_eq!(
                *sample,
                libm::roundf(expected as f32 - expected_mean) as i16
            );
        }
    }

    #[test]
    fn resetting_discards_old_overlap_and_requires_a_new_complete_window() {
        let mut analyzer = Analyzer::new();

        for block_idx in 0..3 {
            let block = core::array::from_fn(|idx| {
                libm::roundf(8_192.0 + tone(block_idx * HOP_LEN + idx, 1_000.0, 4_096.0)) as i16
            });
            assert!(analyzer.push(&block).is_none());
        }

        analyzer.reset();

        for _ in 0..3 {
            assert!(analyzer.push(&[1_234; HOP_LEN]).is_none());
        }

        let analysis = analyzer.push(&[1_234; HOP_LEN]).unwrap();
        assert_eq!(analysis.peak_hz, 0);
        assert_eq!(analysis.rms_dbfs, -100);
        assert_eq!(analysis.waveform, [0; HISTORY_LEN]);
        assert_eq!(analysis.spectrum_ceiling_dbfs, -84);
    }

    #[test]
    fn automatic_gain_makes_quiet_tones_visible_without_changing_measured_rms() {
        for amplitude in [2.0, 4.0, 8.0, 16.0] {
            let analysis = analyze_signal(|sample| {
                libm::roundf(8_192.0 + tone(sample, 1_000.0, amplitude)) as i16
            });

            assert_eq!(analysis.peak_hz, 1_000);
            assert!(analysis.bands[8] > 20);
            assert!(analysis.rms_dbfs < -50);
            assert!(analysis.spectrum_ceiling_dbfs < -40);
            assert!(analysis.bands.iter().all(|height| *height <= 40));
        }
    }

    #[test]
    fn gain_recovers_after_loud_audio_and_reacts_immediately_to_louder_audio() {
        let mut analyzer = Analyzer::new();
        let loud =
            core::array::from_fn(|idx| libm::roundf(8_192.0 + tone(idx, 1_000.0, 4_096.0)) as i16);
        let quiet =
            core::array::from_fn(|idx| libm::roundf(8_192.0 + tone(idx, 1_000.0, 16.0)) as i16);

        for _ in 0..4 {
            analyzer.push(&loud);
        }

        let first_quiet = analyzer.push(&quiet).unwrap();
        let mut recovered = first_quiet;

        for _ in 1..40 {
            recovered = analyzer.push(&quiet).unwrap();
        }

        assert_eq!(recovered.peak_hz, 1_000);
        assert!(recovered.bands[8] >= 25);
        assert!(recovered.spectrum_ceiling_dbfs < first_quiet.spectrum_ceiling_dbfs);
        assert!(recovered.rms_dbfs < -50);

        let louder = analyzer.push(&loud).unwrap();
        assert!(louder.spectrum_ceiling_dbfs > recovered.spectrum_ceiling_dbfs);
        assert!(louder.bands.iter().all(|height| *height <= 40));

        analyzer.reset();
        assert!(analyzer.spectrum_ceiling.is_none());

        for _ in 0..3 {
            assert!(analyzer.push(&quiet).is_none());
        }

        let after_reset = analyzer.push(&quiet).unwrap();
        assert_eq!(after_reset.bands[8], 34);
    }
}
