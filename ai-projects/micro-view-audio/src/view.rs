use core::fmt::Write;

use embedded_graphics::{
    mono_font::{
        MonoTextStyle,
        ascii::{FONT_4X6, FONT_6X10},
    },
    pixelcolor::BinaryColor,
    prelude::*,
    primitives::{Line, PrimitiveStyle, Rectangle},
    text::{Baseline, Text},
};
use heapless::String;

use crate::analysis::{Analysis, BAND_COUNT, HISTORY_LEN, scale_spectrum};

const LEVEL_FLOOR_DBFS: i16 = -100;
const LEVEL_MIN_SPAN_DB: i16 = 40;
const LEVEL_PADDING_DB: i16 = 4;

/// The four views share live audio data, so changing modes never loses history.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Mode {
    Waveform,
    Level,
    Spectrum,
    Spectrogram,
}

/// Time represented by plot histories and the averaged FFT bars.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum HistoryDuration {
    Short,
    Medium,
    Long,
    ExtraLong,
}

impl HistoryDuration {
    /// Number of 16 ms analysis hops combined into each history column.
    pub const fn hops_per_column(self) -> u8 {
        match self {
            Self::Short => 1,
            Self::Medium => 2,
            Self::Long => 4,
            Self::ExtraLong => 8,
        }
    }

    /// Rounded span of the full history, suitable for the OLED footer.
    pub const fn label(self) -> &'static str {
        match self {
            Self::Short => "1.7s",
            Self::Medium => "3.3s",
            Self::Long => "6.7s",
            Self::ExtraLong => "13.3s",
        }
    }

    const fn next(self) -> Self {
        match self {
            Self::Short => Self::Medium,
            Self::Medium => Self::Long,
            Self::Long => Self::ExtraLong,
            Self::ExtraLong => Self::Short,
        }
    }
}

/// Audio history and a fixed 128×64 monochrome OLED layout.
pub struct AudioView {
    mode: Mode,
    history_duration: HistoryDuration,
    latest: Option<Analysis>,
    level_history: [i16; HISTORY_LEN],
    spectrum_history: [[u8; BAND_COUNT]; HISTORY_LEN],
    spectrum_power_history: [[f32; BAND_COUNT]; HISTORY_LEN],
    history_len: usize,
    next_column: usize,
    pending_hops: u8,
    pending_level: i16,
    pending_spectrum: [u8; BAND_COUNT],
    pending_spectrum_power: [f32; BAND_COUNT],
}

impl AudioView {
    pub const fn new() -> Self {
        Self {
            mode: Mode::Waveform,
            history_duration: HistoryDuration::Short,
            latest: None,
            level_history: [LEVEL_FLOOR_DBFS; HISTORY_LEN],
            spectrum_history: [[0; BAND_COUNT]; HISTORY_LEN],
            spectrum_power_history: [[0.0; BAND_COUNT]; HISTORY_LEN],
            history_len: 0,
            next_column: 0,
            pending_hops: 0,
            pending_level: LEVEL_FLOOR_DBFS,
            pending_spectrum: [0; BAND_COUNT],
            pending_spectrum_power: [0.0; BAND_COUNT],
        }
    }

    pub const fn mode(&self) -> Mode {
        self.mode
    }

    pub const fn history_duration(&self) -> HistoryDuration {
        self.history_duration
    }

    /// Clear histories and the FFT average while keeping the mode and live data.
    pub fn next_duration(&mut self) {
        self.history_duration = self.history_duration.next();
        self.clear_history();
    }

    pub fn previous_mode(&mut self) {
        self.mode = match self.mode {
            Mode::Waveform => Mode::Spectrogram,
            Mode::Level => Mode::Waveform,
            Mode::Spectrum => Mode::Level,
            Mode::Spectrogram => Mode::Spectrum,
        };
    }

    pub fn next_mode(&mut self) {
        self.mode = match self.mode {
            Mode::Waveform => Mode::Level,
            Mode::Level => Mode::Spectrum,
            Mode::Spectrum => Mode::Spectrogram,
            Mode::Spectrogram => Mode::Waveform,
        };
    }

    /// Keep live measurements every hop; group history at the selected duration.
    /// History plots retain peaks; averaged FFT bars accumulate linear power.
    pub fn update(&mut self, analysis: Analysis) {
        self.latest = Some(analysis);
        self.pending_level = self.pending_level.max(analysis.rms_dbfs);

        for (peak, magnitude) in self.pending_spectrum.iter_mut().zip(analysis.bands) {
            *peak = (*peak).max(magnitude);
        }

        for (sum, power) in self
            .pending_spectrum_power
            .iter_mut()
            .zip(analysis.band_power)
        {
            *sum += power;
        }

        self.pending_hops += 1;

        if self.pending_hops < self.history_duration.hops_per_column() {
            return;
        }

        self.level_history[self.next_column] = self.pending_level;
        self.spectrum_history[self.next_column] = self.pending_spectrum;
        self.spectrum_power_history[self.next_column] = self.pending_spectrum_power;
        self.next_column = (self.next_column + 1) % HISTORY_LEN;
        self.history_len = (self.history_len + 1).min(HISTORY_LEN);
        self.clear_pending();
    }

    /// A capture gap breaks the time axis; start fresh while keeping the mode.
    pub fn reset_history(&mut self) {
        self.latest = None;
        self.clear_history();
    }

    fn clear_history(&mut self) {
        self.level_history.fill(LEVEL_FLOOR_DBFS);
        self.spectrum_history.fill([0; BAND_COUNT]);
        self.spectrum_power_history.fill([0.0; BAND_COUNT]);
        self.history_len = 0;
        self.next_column = 0;
        self.clear_pending();
    }

    fn clear_pending(&mut self) {
        self.pending_hops = 0;
        self.pending_level = LEVEL_FLOOR_DBFS;
        self.pending_spectrum.fill(0);
        self.pending_spectrum_power.fill(0.0);
    }

    /// Draw one frame. The caller flushes its OLED buffer over I²C.
    pub fn render<Display>(&self, display: &mut Display) -> Result<(), Display::Error>
    where
        Display: DrawTarget<Color = BinaryColor>,
    {
        display.clear(BinaryColor::Off)?;

        let text_style = MonoTextStyle::new(&FONT_6X10, BinaryColor::On);
        let header = self.header_text();
        Text::with_baseline(header.as_str(), Point::zero(), text_style, Baseline::Top)
            .draw(display)?;

        match self.mode {
            Mode::Waveform => self.render_waveform(display)?,
            Mode::Level => self.render_level(display)?,
            Mode::Spectrum => self.render_spectrum(display)?,
            Mode::Spectrogram => self.render_spectrogram(display)?,
        }

        let footer = self.footer_text();

        Text::with_baseline(
            footer.as_str(),
            Point::new(0, 54),
            text_style,
            Baseline::Top,
        )
        .draw(display)?;

        Ok(())
    }

    fn footer_text(&self) -> String<32> {
        let mut footer = String::new();
        let _ = footer.push_str("A:< B:>");

        if self.mode != Mode::Waveform {
            let _ = write!(footer, " {}", self.history_duration.label());
        }

        footer
    }

    fn header_text(&self) -> String<32> {
        let mut header = String::new();

        match (self.mode, &self.latest) {
            (Mode::Waveform, Some(latest)) => {
                let _ = write!(
                    header,
                    "WAVE auto {}dB",
                    latest.rms_dbfs.clamp(LEVEL_FLOOR_DBFS, 0)
                );
            }

            (Mode::Waveform, None) => {
                let _ = header.push_str("WAVE auto --dB");
            }

            (Mode::Level, Some(latest)) => {
                let _ = write!(
                    header,
                    "LEVEL {}dBFS auto",
                    latest.rms_dbfs.clamp(LEVEL_FLOOR_DBFS, 0)
                );
            }

            (Mode::Level, None) => {
                let _ = header.push_str("LEVEL --dBFS auto");
            }

            (Mode::Spectrum, _) => {
                let _ = header.push_str("FFT avg auto");
            }

            (Mode::Spectrogram, Some(latest)) => {
                let _ = write!(header, "STFT {}Hz auto", latest.peak_hz);
            }

            (Mode::Spectrogram, None) => {
                let _ = header.push_str("STFT --Hz auto");
            }
        }

        header
    }

    fn render_waveform<Display>(&self, display: &mut Display) -> Result<(), Display::Error>
    where
        Display: DrawTarget<Color = BinaryColor>,
    {
        draw_labels(display, &[("+", 14), ("0", 29), ("-", 45)])?;
        draw_vertical_axis(display, 14, 50)?;

        for x in (24..128).step_by(4) {
            Pixel(Point::new(x, 32), BinaryColor::On).draw(display)?;
        }

        if let Some(latest) = &self.latest {
            // Convert before taking abs: i16::MIN is a valid microphone sample.
            let amplitude = latest
                .waveform
                .iter()
                .map(|sample| i32::from(*sample).abs())
                .max()
                .unwrap_or(0)
                .max(4);
            let points = latest.waveform.iter().enumerate().map(|(idx, sample)| {
                Point::new(24 + idx as i32, 32 - i32::from(*sample) * 18 / amplitude)
            });

            draw_trace(display, points)?;
        }

        Ok(())
    }

    fn render_level<Display>(&self, display: &mut Display) -> Result<(), Display::Error>
    where
        Display: DrawTarget<Color = BinaryColor>,
    {
        let (floor, ceiling) = self.level_range();
        let span = ceiling - floor;
        let mut top_label = String::<8>::new();
        let mut middle_label = String::<8>::new();
        let mut bottom_label = String::<8>::new();
        let _ = write!(top_label, "{ceiling}");
        let _ = write!(middle_label, "{}", ceiling - span / 2);
        let _ = write!(bottom_label, "{floor}");
        draw_labels(
            display,
            &[
                (top_label.as_str(), 14),
                (middle_label.as_str(), 29),
                (bottom_label.as_str(), 45),
            ],
        )?;

        draw_vertical_axis(display, 14, 50)?;

        for x in (24..128).step_by(4) {
            Pixel(Point::new(x, 32), BinaryColor::On).draw(display)?;
        }

        let first_x = 128 - self.history_len as i32;
        let points = (0..self.history_len).map(|column| {
            let level = self.level_history[self.history_index(column)].clamp(floor, ceiling);
            let y = 14 + i32::from(ceiling - level) * 36 / i32::from(span);

            Point::new(first_x + column as i32, y)
        });

        draw_trace(display, points)?;

        Ok(())
    }

    /// Fit the axis to committed columns, so older sounds remain comparable.
    /// Keep at least 40 dB of range instead of magnifying small noise changes.
    fn level_range(&self) -> (i16, i16) {
        if self.history_len == 0 {
            return (-LEVEL_MIN_SPAN_DB, 0);
        }

        let mut minimum = 0;
        let mut maximum = LEVEL_FLOOR_DBFS;

        for column in 0..self.history_len {
            let level = self.level_history[self.history_index(column)].clamp(LEVEL_FLOOR_DBFS, 0);
            minimum = minimum.min(level);
            maximum = maximum.max(level);
        }

        let padded_floor = (minimum - LEVEL_PADDING_DB).max(LEVEL_FLOOR_DBFS);
        let padded_ceiling = (maximum + LEVEL_PADDING_DB).min(0);
        let span = (padded_ceiling - padded_floor).max(LEVEL_MIN_SPAN_DB);
        let floor = ((padded_floor + padded_ceiling - span) / 2).clamp(LEVEL_FLOOR_DBFS, -span);

        (floor, floor + span)
    }

    fn render_spectrum<Display>(&self, display: &mut Display) -> Result<(), Display::Error>
    where
        Display: DrawTarget<Color = BinaryColor>,
    {
        let averaged_power = self.average_spectrum();
        let (bands, _) = scale_spectrum(&averaged_power, None);
        let fill = PrimitiveStyle::with_fill(BinaryColor::On);

        for (idx, magnitude) in bands.iter().enumerate() {
            let height = u32::from(*magnitude) * 32 / 40;

            if height > 0 {
                Rectangle::new(
                    Point::new(idx as i32 * 4, 47 - height as i32),
                    Size::new(3, height),
                )
                .into_styled(fill)
                .draw(display)?;
            }
        }

        let axis_style = MonoTextStyle::new(&FONT_4X6, BinaryColor::On);

        for (label, x) in [("0", 0), ("2k", 60), ("4k", 120)] {
            Text::with_baseline(label, Point::new(x, 48), axis_style, Baseline::Top)
                .draw(display)?;
        }

        Ok(())
    }

    /// Average all collected hops in complete groups, without diluting startup.
    fn average_spectrum(&self) -> [f32; BAND_COUNT] {
        let mut average = [0.0; BAND_COUNT];

        if self.history_len == 0 {
            return average;
        }

        // Resum valid entries instead of subtracting evicted powers: a loud
        // sound must not leave roundoff that hides quiet audio after it expires.
        for column in 0..self.history_len {
            let group = &self.spectrum_power_history[self.history_index(column)];

            for (sum, power) in average.iter_mut().zip(group) {
                *sum += power;
            }
        }

        let hop_count = self.history_len * usize::from(self.history_duration.hops_per_column());

        for power in &mut average {
            *power /= hop_count as f32;
        }

        average
    }

    fn render_spectrogram<Display>(&self, display: &mut Display) -> Result<(), Display::Error>
    where
        Display: DrawTarget<Color = BinaryColor>,
    {
        draw_labels(display, &[("4k", 14), ("2k", 29), ("0", 46)])?;
        draw_vertical_axis(display, 16, 47)?;

        let first_x = 128 - self.history_len as i32;

        for column in 0..self.history_len {
            let x = first_x + column as i32;
            let spectrum = &self.spectrum_history[self.history_index(column)];

            for (bin, magnitude) in spectrum.iter().enumerate() {
                let y = 47 - bin as i32;

                if dither_lit(*magnitude, x, y) {
                    Pixel(Point::new(x, y), BinaryColor::On).draw(display)?;
                }
            }
        }

        Ok(())
    }

    /// Resolve an oldest-to-newest column without moving history on every hop.
    fn history_index(&self, column: usize) -> usize {
        let oldest = if self.history_len == HISTORY_LEN {
            self.next_column
        } else {
            0
        };

        (oldest + column) % HISTORY_LEN
    }
}

impl Default for AudioView {
    fn default() -> Self {
        Self::new()
    }
}

fn draw_labels<Display>(display: &mut Display, labels: &[(&str, i32)]) -> Result<(), Display::Error>
where
    Display: DrawTarget<Color = BinaryColor>,
{
    let style = MonoTextStyle::new(&FONT_4X6, BinaryColor::On);

    for (label, y) in labels {
        Text::with_baseline(label, Point::new(0, *y), style, Baseline::Top).draw(display)?;
    }

    Ok(())
}

fn draw_vertical_axis<Display>(
    display: &mut Display,
    top: i32,
    bottom: i32,
) -> Result<(), Display::Error>
where
    Display: DrawTarget<Color = BinaryColor>,
{
    Line::new(Point::new(22, top), Point::new(22, bottom))
        .into_styled(PrimitiveStyle::with_stroke(BinaryColor::On, 1))
        .draw(display)?;

    Ok(())
}

fn draw_trace<Display>(
    display: &mut Display,
    points: impl IntoIterator<Item = Point>,
) -> Result<(), Display::Error>
where
    Display: DrawTarget<Color = BinaryColor>,
{
    let style = PrimitiveStyle::with_stroke(BinaryColor::On, 1);
    let mut previous = None;

    for point in points {
        if let Some(previous_point) = previous {
            Line::new(previous_point, point)
                .into_styled(style)
                .draw(display)?;
        } else {
            Pixel(point, BinaryColor::On).draw(display)?;
        }

        previous = Some(point);
    }

    Ok(())
}

/// Turn strength into pixel density, keeping the time/frequency axes fixed.
fn dither_lit(magnitude: u8, x: i32, y: i32) -> bool {
    // Every frequency row visits all thresholds over 16 time columns. A 2D
    // Bayer matrix can hide a quiet, steady tone in rows with high thresholds.
    const THRESHOLDS: [u8; 16] = [0, 8, 4, 12, 2, 10, 6, 14, 1, 9, 5, 13, 3, 11, 7, 15];

    let density = (u16::from(magnitude.min(40)) * 16 + 20) / 40;
    let phase = (x as usize + y as usize * 5) % THRESHOLDS.len();

    u16::from(THRESHOLDS[phase]) < density
}

#[cfg(test)]
mod tests {
    use core::convert::Infallible;

    use super::*;

    struct Framebuffer {
        pixels: [[BinaryColor; 128]; 64],
    }

    impl Framebuffer {
        fn new() -> Self {
            Self {
                pixels: [[BinaryColor::On; 128]; 64],
            }
        }
    }

    impl OriginDimensions for Framebuffer {
        fn size(&self) -> Size {
            Size::new(128, 64)
        }
    }

    impl DrawTarget for Framebuffer {
        type Color = BinaryColor;
        type Error = Infallible;

        fn draw_iter<Pixels>(&mut self, pixels: Pixels) -> Result<(), Self::Error>
        where
            Pixels: IntoIterator<Item = Pixel<Self::Color>>,
        {
            for Pixel(point, color) in pixels {
                assert!((0..128).contains(&point.x), "x out of bounds: {point:?}");
                assert!((0..64).contains(&point.y), "y out of bounds: {point:?}");
                self.pixels[point.y as usize][point.x as usize] = color;
            }

            Ok(())
        }
    }

    fn analysis(level: i16, band: u8) -> Analysis {
        Analysis {
            waveform: [0; HISTORY_LEN],
            rms_dbfs: level,
            peak_hz: 1_000,
            spectrum_ceiling_dbfs: -60,
            band_power: [f32::from(band) / 40.0; BAND_COUNT],
            bands: [band; BAND_COUNT],
        }
    }

    fn select_duration(view: &mut AudioView, duration: HistoryDuration) {
        while view.history_duration() != duration {
            view.next_duration();
        }
    }

    #[test]
    fn duration_cycles_through_four_spans_and_wraps_to_the_default() {
        let mut view = AudioView::new();
        assert_eq!(view.history_duration(), HistoryDuration::Short);

        for (duration, hops, label) in [
            (HistoryDuration::Medium, 2, "3.3s"),
            (HistoryDuration::Long, 4, "6.7s"),
            (HistoryDuration::ExtraLong, 8, "13.3s"),
            (HistoryDuration::Short, 1, "1.7s"),
        ] {
            view.next_duration();
            assert_eq!(view.history_duration(), duration);
            assert_eq!(duration.hops_per_column(), hops);
            assert_eq!(duration.label(), label);
        }
    }

    #[test]
    fn every_duration_commits_complete_columns_at_its_selected_cadence() {
        for duration in [
            HistoryDuration::Short,
            HistoryDuration::Medium,
            HistoryDuration::Long,
            HistoryDuration::ExtraLong,
        ] {
            let mut view = AudioView::new();
            select_duration(&mut view, duration);
            let hops_per_column = usize::from(duration.hops_per_column());
            let full_columns = HISTORY_LEN + 2;
            let total_hops = full_columns * hops_per_column + hops_per_column - 1;

            for hop in 0..total_hops {
                view.update(analysis(hop as i16, 0));
                let complete_columns = (hop + 1) / hops_per_column;
                assert_eq!(view.history_len, complete_columns.min(HISTORY_LEN));
                assert_eq!(view.next_column, complete_columns % HISTORY_LEN);
                assert_eq!(view.latest.as_ref().unwrap().rms_dbfs, hop as i16);
            }

            // Group maxima and ring ordering must survive a complete wrap.
            for column in 0..HISTORY_LEN {
                let group = full_columns - HISTORY_LEN + column;
                let expected_level = (group + 1) * hops_per_column - 1;
                assert_eq!(
                    view.level_history[view.history_index(column)],
                    expected_level as i16
                );
            }
        }
    }

    #[test]
    fn grouped_columns_preserve_brief_level_and_frequency_peaks() {
        for duration in [
            HistoryDuration::Medium,
            HistoryDuration::Long,
            HistoryDuration::ExtraLong,
        ] {
            let mut view = AudioView::new();
            select_duration(&mut view, duration);
            let mut burst = analysis(-8, 0);
            burst.bands[7] = 37;
            view.update(burst);
            assert_eq!(view.history_len, 0);

            for hop in 1..duration.hops_per_column() {
                let mut quiet = analysis(-60, 0);

                if hop == 1 {
                    quiet.bands[18] = 25;
                }

                view.update(quiet);
            }

            assert_eq!(view.history_len, 1);
            assert_eq!(view.level_history[0], -8);
            assert_eq!(view.spectrum_history[0][7], 37);
            assert_eq!(view.spectrum_history[0][18], 25);
            assert_eq!(view.latest.as_ref().unwrap().rms_dbfs, -60);
            assert_eq!(view.latest.as_ref().unwrap().bands[7], 0);
            assert_eq!(view.pending_hops, 0);

            for _ in 0..duration.hops_per_column() {
                view.update(analysis(-70, 0));
            }

            assert_eq!(view.level_history[1], -70);
            assert_eq!(view.spectrum_history[1], [0; BAND_COUNT]);
        }
    }

    #[test]
    fn changing_duration_clears_history_and_partial_columns_but_keeps_live_data() {
        let mut view = AudioView::new();
        select_duration(&mut view, HistoryDuration::Medium);
        view.previous_mode();
        view.update(analysis(-20, 12));
        view.update(analysis(-30, 10));
        view.update(analysis(-5, 39));
        assert_eq!(view.history_len, 1);
        assert_eq!(view.pending_hops, 1);
        view.next_duration();

        assert_eq!(view.mode(), Mode::Spectrogram);
        assert_eq!(view.history_duration(), HistoryDuration::Long);
        assert_eq!(view.history_len, 0);
        assert_eq!(view.next_column, 0);
        assert_eq!(view.pending_hops, 0);
        assert_eq!(view.pending_level, LEVEL_FLOOR_DBFS);
        assert_eq!(view.pending_spectrum, [0; BAND_COUNT]);
        assert_eq!(view.pending_spectrum_power, [0.0; BAND_COUNT]);
        assert_eq!(view.level_history, [LEVEL_FLOOR_DBFS; HISTORY_LEN]);
        assert_eq!(view.spectrum_history, [[0; BAND_COUNT]; HISTORY_LEN]);
        assert_eq!(
            view.spectrum_power_history,
            [[0.0; BAND_COUNT]; HISTORY_LEN]
        );
        assert_eq!(view.average_spectrum(), [0.0; BAND_COUNT]);
        assert_eq!(view.level_range(), (-40, 0));
        assert_eq!(view.latest.as_ref().unwrap().rms_dbfs, -5);
        assert_eq!(view.latest.as_ref().unwrap().bands, [39; BAND_COUNT]);

        for _ in 0..HistoryDuration::Long.hops_per_column() {
            view.update(analysis(-70, 0));
        }

        assert_eq!(view.history_len, 1);
        assert_eq!(view.level_history[0], -70);
        assert_eq!(view.spectrum_history[0], [0; BAND_COUNT]);
    }

    #[test]
    fn capture_gap_discards_partial_columns_and_preserves_duration() {
        let mut view = AudioView::new();
        select_duration(&mut view, HistoryDuration::ExtraLong);
        view.next_mode();

        for _ in 0..10 {
            view.update(analysis(-8, 38));
        }

        assert_eq!(view.history_len, 1);
        assert_eq!(view.pending_hops, 2);
        view.reset_history();

        assert_eq!(view.mode(), Mode::Level);
        assert_eq!(view.history_duration(), HistoryDuration::ExtraLong);
        assert_eq!(view.history_len, 0);
        assert!(view.latest.is_none());
        assert_eq!(view.level_range(), (-40, 0));
        assert_eq!(view.pending_hops, 0);
        assert_eq!(view.pending_spectrum_power, [0.0; BAND_COUNT]);
        assert_eq!(view.average_spectrum(), [0.0; BAND_COUNT]);

        for _ in 0..7 {
            view.update(analysis(-70, 0));
            assert_eq!(view.history_len, 0);
        }

        view.update(analysis(-70, 0));
        assert_eq!(view.history_len, 1);
        assert_eq!(view.level_history[0], -70);
        assert_eq!(view.spectrum_history[0], [0; BAND_COUNT]);
    }

    #[test]
    fn buttons_wrap_modes_in_both_directions() {
        let mut view = AudioView::default();
        assert_eq!(view.mode(), Mode::Waveform);

        for expected in [
            Mode::Spectrogram,
            Mode::Spectrum,
            Mode::Level,
            Mode::Waveform,
        ] {
            view.previous_mode();
            assert_eq!(view.mode(), expected);
        }

        for expected in [
            Mode::Level,
            Mode::Spectrum,
            Mode::Spectrogram,
            Mode::Waveform,
        ] {
            view.next_mode();
            assert_eq!(view.mode(), expected);
        }
    }

    #[test]
    fn every_hop_updates_both_histories_across_modes_and_ring_wraps() {
        let mut view = AudioView::new();

        for hop in 0..HISTORY_LEN * 2 + 3 {
            view.update(analysis(hop as i16, (hop % 40) as u8));
            view.next_mode();
        }

        assert_eq!(view.history_len, HISTORY_LEN);

        for column in 0..HISTORY_LEN {
            let expected_hop = HISTORY_LEN + 3 + column;
            let idx = view.history_index(column);
            assert_eq!(view.level_history[idx], expected_hop as i16);
            assert_eq!(
                view.spectrum_history[idx],
                [(expected_hop % 40) as u8; BAND_COUNT]
            );
        }

        let latest = view.latest.as_ref().unwrap();
        assert_eq!(latest.rms_dbfs, (HISTORY_LEN * 2 + 2) as i16);
    }

    #[test]
    fn capture_gap_clears_history_and_preserves_the_selected_mode() {
        let mut view = AudioView::new();
        view.previous_mode();
        view.update(analysis(-20, 35));
        view.reset_history();

        assert_eq!(view.mode(), Mode::Spectrogram);
        assert_eq!(view.history_len, 0);
        assert_eq!(view.next_column, 0);
        assert!(view.latest.is_none());

        view.update(analysis(-40, 10));
        assert_eq!(view.history_len, 1);
        assert_eq!(view.level_history[view.history_index(0)], -40);
        assert_eq!(
            view.spectrum_history[view.history_index(0)],
            [10; BAND_COUNT]
        );
    }

    #[test]
    fn all_modes_stay_inside_the_screen_at_startup_and_with_extreme_input() {
        let mut view = AudioView::new();
        let mut screen = Framebuffer::new();

        let mut extreme = analysis(i16::MIN, u8::MAX);
        extreme.peak_hz = u16::MAX;

        for (idx, sample) in extreme.waveform.iter_mut().enumerate() {
            *sample = if idx % 2 == 0 { i16::MIN } else { i16::MAX };
        }

        for _ in 0..4 {
            for _ in 0..4 {
                view.render(&mut screen).unwrap();
                view.next_mode();
            }

            extreme.rms_dbfs = i16::MIN;

            for _ in 0..HISTORY_LEN * usize::from(view.history_duration().hops_per_column()) + 3 {
                view.update(extreme);
            }

            for _ in 0..4 {
                view.render(&mut screen).unwrap();
                view.next_mode();
            }

            extreme.rms_dbfs = i16::MAX;
            view.update(extreme);

            for _ in 0..4 {
                view.render(&mut screen).unwrap();
                view.next_mode();
            }

            view.next_duration();
        }
    }

    #[test]
    fn spectrogram_places_low_frequencies_at_the_bottom_and_newest_at_the_right() {
        let mut view = AudioView::new();
        view.previous_mode();
        let mut low_tone = analysis(-20, 0);
        low_tone.bands[0] = 40;
        view.update(low_tone);

        let mut high_tone = analysis(-20, 0);
        high_tone.bands[BAND_COUNT - 1] = 40;
        view.update(high_tone);

        let mut screen = Framebuffer::new();
        view.render(&mut screen).unwrap();

        assert_eq!(screen.pixels[47][126], BinaryColor::On);
        assert_eq!(screen.pixels[16][126], BinaryColor::Off);
        assert_eq!(screen.pixels[16][127], BinaryColor::On);
        assert_eq!(screen.pixels[47][127], BinaryColor::Off);
        assert_eq!(screen.pixels[32][126], BinaryColor::Off);
        assert_eq!(screen.pixels[32][127], BinaryColor::Off);
        assert_eq!(screen.pixels[47][125], BinaryColor::Off);
    }

    #[test]
    fn quiet_steady_tones_remain_equally_visible_at_every_frequency() {
        let mut view = AudioView::new();
        view.previous_mode();

        for _ in 0..16 {
            view.update(analysis(-45, 10));
        }

        let mut screen = Framebuffer::new();
        view.render(&mut screen).unwrap();

        // Equal, quarter-strength bands should all remain visible, including
        // frequency rows where a 4×4 Bayer pattern would draw no pixels.
        for row in &screen.pixels[16..48] {
            let lit_pixels = row[112..]
                .iter()
                .filter(|pixel| **pixel == BinaryColor::On)
                .count();
            assert_eq!(lit_pixels, 4);
        }
    }

    #[test]
    fn spectrum_has_separate_bars_and_a_visible_frequency_scale() {
        let mut view = AudioView::new();
        view.next_mode();
        view.next_mode();
        let mut tone = analysis(-20, 0);
        tone.bands[8] = 40;
        tone.band_power[8] = 1.0;
        view.update(tone);

        let mut screen = Framebuffer::new();
        view.render(&mut screen).unwrap();

        assert_eq!(screen.pixels[15][32], BinaryColor::On);
        assert_eq!(screen.pixels[46][34], BinaryColor::On);
        assert_eq!(screen.pixels[32][35], BinaryColor::Off);
        assert_eq!(screen.pixels[32][36], BinaryColor::Off);
        assert!(
            screen.pixels[48..54]
                .iter()
                .any(|row| row[..4].contains(&BinaryColor::On))
        );
    }

    #[test]
    fn averaged_fft_retains_sound_when_the_latest_spectrum_is_silent() {
        for duration in [
            HistoryDuration::Short,
            HistoryDuration::Medium,
            HistoryDuration::Long,
            HistoryDuration::ExtraLong,
        ] {
            let mut view = AudioView::new();
            view.next_mode();
            view.next_mode();
            select_duration(&mut view, duration);

            for _ in 0..duration.hops_per_column() {
                view.update(analysis(-10, 40));
            }

            for _ in 0..duration.hops_per_column() {
                view.update(analysis(-100, 0));
            }

            let mut screen = Framebuffer::new();
            view.render(&mut screen).unwrap();

            assert!(
                screen.pixels[15..47]
                    .iter()
                    .any(|row| row[..3].contains(&BinaryColor::On)),
                "FFT dropped recent sound at {duration:?}"
            );
        }
    }

    #[test]
    fn fft_averages_linear_power_in_complete_groups_without_diluting_startup() {
        for duration in [
            HistoryDuration::Short,
            HistoryDuration::Medium,
            HistoryDuration::Long,
            HistoryDuration::ExtraLong,
        ] {
            let mut view = AudioView::new();
            select_duration(&mut view, duration);
            let hops_per_column = usize::from(duration.hops_per_column());

            for hop in 0..4 * hops_per_column {
                let mut spectrum = analysis(-20, 0);
                spectrum.band_power[3] = if hop % 4 == 0 { 1.0 } else { 0.0 };
                spectrum.band_power[4] = 0.1;
                view.update(spectrum);

                if hop + 1 < hops_per_column {
                    assert_eq!(view.average_spectrum(), [0.0; BAND_COUNT]);
                } else {
                    // Unfilled history slots must not dilute a steady signal.
                    assert!((view.average_spectrum()[4] - 0.1).abs() < 0.000001);
                }
            }

            // One energetic hop in each four contributes one quarter power,
            // including mixed groups at the longer duration settings.
            assert_eq!(view.average_spectrum()[3], 0.25);
        }
    }

    #[test]
    fn fft_average_preserves_relative_power_despite_instantaneous_display_gain() {
        let mut view = AudioView::new();
        view.next_mode();
        view.next_mode();
        let mut loud = analysis(-20, 0);
        loud.band_power[7] = 0.01;
        loud.bands[7] = 34;
        view.update(loud);

        let mut quiet = analysis(-60, 0);
        quiet.band_power[14] = 0.000001;
        quiet.bands[14] = 34;
        view.update(quiet);
        let average = view.average_spectrum();
        assert!((average[7] - 0.005).abs() < 0.0000001);
        assert!((average[14] - 0.0000005).abs() < 0.00000000001);

        let mut screen = Framebuffer::new();
        view.render(&mut screen).unwrap();

        // Both incoming bars had the same height, but their physical powers
        // differ by 40 dB. Only the stronger band fits the averaged display.
        assert!(
            screen.pixels[15..47]
                .iter()
                .any(|row| row[28..31].contains(&BinaryColor::On))
        );
        assert!(
            screen.pixels[15..47]
                .iter()
                .all(|row| row[56..59].iter().all(|pixel| *pixel == BinaryColor::Off))
        );
        assert_eq!(view.header_text().as_str(), "FFT avg auto");
    }

    #[test]
    fn fft_average_expires_loud_audio_without_leaving_residual_power() {
        for duration in [
            HistoryDuration::Short,
            HistoryDuration::Medium,
            HistoryDuration::Long,
            HistoryDuration::ExtraLong,
        ] {
            let mut view = AudioView::new();
            select_duration(&mut view, duration);
            let mut loud = analysis(-10, 0);
            loud.band_power[5] = 1.0;
            let mut quiet = analysis(-80, 0);
            quiet.band_power[9] = 0.00000001;

            for _ in 0..duration.hops_per_column() {
                view.update(loud);
            }

            for _ in 1..HISTORY_LEN {
                for _ in 0..duration.hops_per_column() {
                    view.update(quiet);
                }

                assert!(view.average_spectrum()[5] > 0.009);
            }

            for _ in 1..duration.hops_per_column() {
                view.update(quiet);
                assert!(view.average_spectrum()[5] > 0.009);
            }

            view.update(quiet);
            let average = view.average_spectrum();
            assert_eq!(average[5], 0.0);
            assert!((average[9] - 0.00000001).abs() < 0.0000000000001);

            // Switching modes retains the accumulated average; quiet sounds
            // become visible again as soon as the loud history has expired.
            view.next_mode();
            view.next_mode();
            let mut screen = Framebuffer::new();
            view.render(&mut screen).unwrap();

            assert!(
                screen.pixels[15..47]
                    .iter()
                    .any(|row| row[36..39].contains(&BinaryColor::On))
            );
        }
    }

    #[test]
    fn duration_is_visible_only_in_modes_that_use_it() {
        let mut view = AudioView::new();
        let mut screen = Framebuffer::new();

        for _ in 0..4 {
            for _ in 0..4 {
                view.render(&mut screen).unwrap();
                let duration_is_drawn = screen.pixels[54..]
                    .iter()
                    .any(|row| row[48..].contains(&BinaryColor::On));

                assert_eq!(duration_is_drawn, view.mode() != Mode::Waveform);
                view.next_mode();
            }

            view.next_duration();
        }
    }

    #[test]
    fn silent_waveform_remains_centered_without_dividing_by_zero() {
        let mut view = AudioView::new();
        view.update(analysis(-80, 0));
        let mut screen = Framebuffer::new();
        view.render(&mut screen).unwrap();

        assert!(
            screen.pixels[32][24..]
                .iter()
                .all(|pixel| *pixel == BinaryColor::On)
        );
        assert!(
            screen.pixels[14][24..]
                .iter()
                .all(|pixel| *pixel == BinaryColor::Off)
        );
        assert!(
            screen.pixels[50][24..]
                .iter()
                .all(|pixel| *pixel == BinaryColor::Off)
        );
    }

    #[test]
    fn quiet_waveforms_with_a_few_adc_counts_use_the_visible_plot_height() {
        for amplitude in [4, 8] {
            let mut view = AudioView::new();
            let mut quiet = analysis(-70, 0);

            for (idx, sample) in quiet.waveform.iter_mut().enumerate() {
                *sample = if idx % 2 == 0 { amplitude } else { -amplitude };
            }

            view.update(quiet);
            let mut screen = Framebuffer::new();
            view.render(&mut screen).unwrap();

            assert_eq!(screen.pixels[14][24], BinaryColor::On);
            assert_eq!(screen.pixels[50][25], BinaryColor::On);
        }
    }

    #[test]
    fn visible_history_does_not_clip_after_a_loud_or_quiet_change() {
        for duration in [
            HistoryDuration::Short,
            HistoryDuration::Medium,
            HistoryDuration::Long,
            HistoryDuration::ExtraLong,
        ] {
            for (first_level, next_level) in [(-10, -75), (-75, -10)] {
                let mut view = AudioView::new();
                view.next_mode();
                select_duration(&mut view, duration);

                for _ in 0..duration.hops_per_column() {
                    view.update(analysis(first_level, 0));
                }

                // Almost a second of new audio must not clip the older level
                // that is still part of the visible history.
                for _ in 0..62 {
                    view.update(analysis(next_level, 0));
                }

                let mut screen = Framebuffer::new();
                view.render(&mut screen).unwrap();

                assert!(
                    screen.pixels[14][24..]
                        .iter()
                        .all(|pixel| *pixel == BinaryColor::Off),
                    "top clipping at {duration:?}: {first_level} -> {next_level}"
                );
                assert!(
                    screen.pixels[50][24..]
                        .iter()
                        .all(|pixel| *pixel == BinaryColor::Off),
                    "bottom clipping at {duration:?}: {first_level} -> {next_level}"
                );
            }
        }
    }

    #[test]
    fn quiet_level_trace_uses_a_dynamic_axis_and_keeps_the_actual_dbfs_header() {
        let mut view = AudioView::new();
        view.next_mode();
        view.update(analysis(-70, 0));
        let mut screen = Framebuffer::new();
        view.render(&mut screen).unwrap();

        assert_eq!(view.level_range(), (-90, -50));
        assert_eq!(view.header_text().as_str(), "LEVEL -70dBFS auto");
        assert_eq!(screen.pixels[32][127], BinaryColor::On);
        assert_eq!(screen.pixels[50][127], BinaryColor::Off);
    }

    #[test]
    fn level_axis_keeps_extrema_until_their_columns_leave_the_visible_history() {
        for duration in [
            HistoryDuration::Short,
            HistoryDuration::Medium,
            HistoryDuration::Long,
            HistoryDuration::ExtraLong,
        ] {
            let mut view = AudioView::new();
            select_duration(&mut view, duration);

            for _ in 0..duration.hops_per_column() {
                view.update(analysis(-10, 0));
            }

            for _ in 1..HISTORY_LEN {
                for _ in 0..duration.hops_per_column() {
                    view.update(analysis(-75, 0));
                }

                assert_eq!(view.level_range(), (-79, -6));
            }

            // The scale changes only when the complete next column overwrites
            // the loud sound, including at the longest history duration.
            for _ in 1..duration.hops_per_column() {
                view.update(analysis(-75, 0));
                assert_eq!(view.level_range(), (-79, -6));
            }

            view.update(analysis(-75, 0));
            assert_eq!(view.level_range(), (-95, -55));
            assert_eq!(view.level_history[view.history_index(0)], -75);
        }
    }

    #[test]
    fn unplotted_live_readings_do_not_move_the_level_axis() {
        let mut view = AudioView::new();
        select_duration(&mut view, HistoryDuration::ExtraLong);
        view.update(analysis(-70, 0));
        assert_eq!(view.level_range(), (-40, 0));

        for _ in 1..HistoryDuration::ExtraLong.hops_per_column() {
            view.update(analysis(-70, 0));
        }

        assert_eq!(view.level_range(), (-90, -50));
        view.update(analysis(-5, 0));
        assert_eq!(view.latest.as_ref().unwrap().rms_dbfs, -5);
        assert_eq!(view.level_range(), (-90, -50));

        for _ in 1..HistoryDuration::ExtraLong.hops_per_column() {
            view.update(analysis(-70, 0));
        }

        assert_eq!(view.level_range(), (-74, -1));
    }

    #[test]
    fn level_axis_contains_visible_values_within_the_dbfs_limits() {
        for level in [i16::MIN, -100, -70, -20, 0, i16::MAX] {
            let mut view = AudioView::new();
            view.update(analysis(level, 0));
            let (floor, ceiling) = view.level_range();

            assert!(floor >= LEVEL_FLOOR_DBFS);
            assert!(ceiling <= 0);
            assert!(ceiling - floor >= LEVEL_MIN_SPAN_DB);
            assert!((floor..=ceiling).contains(&level.clamp(LEVEL_FLOOR_DBFS, 0)));
        }

        let mut view = AudioView::new();
        view.update(analysis(i16::MIN, 0));
        view.update(analysis(i16::MAX, 0));
        assert_eq!(view.level_range(), (-100, 0));
    }
}
