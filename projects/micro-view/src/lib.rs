#![no_std]

use core::fmt::Write;

use embedded_graphics::{
    mono_font::{
        MonoTextStyle,
        ascii::{FONT_4X6, FONT_6X10},
    },
    pixelcolor::BinaryColor,
    prelude::*,
    primitives::{Line, PrimitiveStyle},
    text::{Baseline, Text},
};
use heapless::String;

mod buttons;

pub use buttons::{ButtonPresses, Buttons, DebouncedButton};

/// One sample per graph column: 10.4 seconds at 10 Hz.
const HISTORY_LEN: usize = 104;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Axis {
    X,
    Y,
    Z,
}

impl Axis {
    pub const fn label(self) -> &'static str {
        match self {
            Self::X => "X",
            Self::Y => "Y",
            Self::Z => "Z",
        }
    }

    pub const fn select(self, acceleration: [i32; 3]) -> i32 {
        match self {
            Self::X => acceleration[0],
            Self::Y => acceleration[1],
            Self::Z => acceleration[2],
        }
    }
}

/// Accelerometer history and a 128×64 monochrome screen layout.
pub struct Plot {
    axis: Axis,
    paused: bool,
    history: [i32; HISTORY_LEN],
    sample_count: usize,
    latest: Option<i32>,
}

impl Plot {
    pub const fn new() -> Self {
        Self {
            axis: Axis::X,
            paused: false,
            history: [0; HISTORY_LEN],
            sample_count: 0,
            latest: None,
        }
    }

    pub const fn axis(&self) -> Axis {
        self.axis
    }

    pub const fn paused(&self) -> bool {
        self.paused
    }

    pub fn toggle_pause(&mut self) {
        self.paused = !self.paused;
    }

    /// Start a fresh graph when moving to the next accelerometer axis.
    pub fn next_axis(&mut self) {
        self.axis = match self.axis {
            Axis::X => Axis::Y,
            Axis::Y => Axis::Z,
            Axis::Z => Axis::X,
        };

        self.history.fill(0);
        self.sample_count = 0;
        self.latest = None;
    }

    /// Record a reading in milligravity (1,000 mg = 1 g), unless held.
    pub fn record(&mut self, acceleration: [i32; 3]) {
        if self.paused {
            return;
        }

        let sample = self.axis.select(acceleration);

        if self.sample_count == HISTORY_LEN {
            self.history.copy_within(1.., 0);
            self.history[HISTORY_LEN - 1] = sample;
        } else {
            self.history[self.sample_count] = sample;
            self.sample_count += 1;
        }

        self.latest = Some(sample);
    }

    /// Draw into the OLED's buffer. The caller flushes that buffer over I²C.
    pub fn render<Display>(&self, display: &mut Display) -> Result<(), Display::Error>
    where
        Display: DrawTarget<Color = BinaryColor>,
    {
        display.clear(BinaryColor::Off)?;

        let text_style = MonoTextStyle::new(&FONT_6X10, BinaryColor::On);
        let header = self.header_text();
        Text::with_baseline(header.as_str(), Point::zero(), text_style, Baseline::Top)
            .draw(display)?;

        let axis_style = MonoTextStyle::new(&FONT_4X6, BinaryColor::On);

        for (label, y) in [("+1g", 14), ("0", 29), ("-1g", 45)] {
            Text::with_baseline(label, Point::new(0, y), axis_style, Baseline::Top)
                .draw(display)?;
        }

        let line_style = PrimitiveStyle::with_stroke(BinaryColor::On, 1);
        Line::new(Point::new(22, 14), Point::new(22, 50))
            .into_styled(line_style)
            .draw(display)?;

        for x in (24..128).step_by(4) {
            Pixel(Point::new(x, 32), BinaryColor::On).draw(display)?;
        }

        let first_x = 128 - self.sample_count as i32;
        let mut previous = None;

        for (idx, sample) in self.history[..self.sample_count].iter().enumerate() {
            let point = Point::new(first_x + idx as i32, plot_y(*sample));

            if let Some(previous_point) = previous {
                Line::new(previous_point, point)
                    .into_styled(line_style)
                    .draw(display)?;
            } else {
                Pixel(point, BinaryColor::On).draw(display)?;
            }

            previous = Some(point);
        }

        let footer = if self.paused {
            "A:live B:axis"
        } else {
            "A:hold B:axis"
        };

        Text::with_baseline(footer, Point::new(0, 54), text_style, Baseline::Top).draw(display)?;

        Ok(())
    }

    fn header_text(&self) -> String<32> {
        let mut header = String::new();
        let mode = if self.paused { "HOLD" } else { "LIVE" };

        // Even an i32 minimum reading fits in this fixed-size string.
        if let Some(sample) = self.latest {
            let _ = write!(header, "{} {sample:+}mg {mode}", self.axis.label());
        } else {
            let _ = write!(header, "{} --mg {mode}", self.axis.label());
        }

        header
    }
}

impl Default for Plot {
    fn default() -> Self {
        Self::new()
    }
}

fn plot_y(sample: i32) -> i32 {
    32 - sample.clamp(-1_000, 1_000) * 18 / 1_000
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

    #[test]
    fn scrolling_preserves_chronology_and_the_newest_sample() {
        let mut plot = Plot::new();

        for sample in 0..HISTORY_LEN as i32 + 3 {
            plot.record([sample, 0, 0]);
        }

        assert_eq!(plot.sample_count, HISTORY_LEN);
        assert_eq!(plot.latest, Some(106));

        for (idx, sample) in plot.history.iter().enumerate() {
            assert_eq!(*sample, idx as i32 + 3);
        }
    }

    #[test]
    fn pause_freezes_both_the_reading_and_history() {
        let mut plot = Plot::default();
        plot.record([20, 30, 40]);
        let history = plot.history;
        plot.toggle_pause();
        plot.record([900, 800, 700]);

        assert!(plot.paused());
        assert_eq!(plot.latest, Some(20));
        assert_eq!(plot.sample_count, 1);
        assert_eq!(plot.history, history);

        plot.toggle_pause();
        plot.record([900, 800, 700]);

        assert!(!plot.paused());
        assert_eq!(plot.latest, Some(900));
        assert_eq!(plot.sample_count, 2);
    }

    #[test]
    fn switching_axis_clears_history_and_preserves_pause() {
        let mut plot = Plot::new();
        plot.record([100, 200, 300]);
        plot.toggle_pause();
        plot.next_axis();

        assert_eq!(plot.axis(), Axis::Y);
        assert!(plot.paused());
        assert_eq!(plot.sample_count, 0);
        assert_eq!(plot.latest, None);
        assert_eq!(plot.history, [0; HISTORY_LEN]);

        plot.toggle_pause();
        plot.record([100, 200, 300]);
        assert_eq!(plot.latest, Some(200));

        plot.next_axis();
        plot.record([100, 200, 300]);
        assert_eq!(plot.axis(), Axis::Z);
        assert_eq!(plot.latest, Some(300));

        plot.next_axis();
        assert_eq!(plot.axis(), Axis::X);
        assert_eq!(plot.latest, None);
    }

    #[test]
    fn readings_map_to_the_graph_and_extremes_are_clipped() {
        for (sample, y) in [
            (i32::MIN, 50),
            (-1_001, 50),
            (-1_000, 50),
            (-500, 41),
            (0, 32),
            (500, 23),
            (1_000, 14),
            (1_001, 14),
            (i32::MAX, 14),
        ] {
            assert_eq!(plot_y(sample), y);
        }
    }

    #[test]
    fn startup_samples_are_right_aligned_and_connected() {
        let mut plot = Plot::new();
        let mut display = Framebuffer::new();
        plot.record([1_000, 0, 0]);
        plot.render(&mut display).unwrap();

        assert_eq!(display.pixels[14][127], BinaryColor::On);
        assert_eq!(display.pixels[14][126], BinaryColor::Off);

        plot.record([-1_000, 0, 0]);
        plot.render(&mut display).unwrap();

        assert_eq!(display.pixels[14][126], BinaryColor::On);
        assert_eq!(display.pixels[50][127], BinaryColor::On);
        assert!(
            display.pixels[23][126] == BinaryColor::On
                || display.pixels[23][127] == BinaryColor::On
        );
    }

    #[test]
    fn a_full_extreme_trace_stays_in_bounds_and_clears_the_screen() {
        let mut plot = Plot::new();
        let mut display = Framebuffer::new();

        for idx in 0..HISTORY_LEN {
            let sample = if idx % 2 == 0 { i32::MAX } else { i32::MIN };
            plot.record([sample, 0, 0]);
        }

        plot.render(&mut display).unwrap();

        assert_eq!(display.pixels[14][24], BinaryColor::On);
        assert_eq!(display.pixels[50][127], BinaryColor::On);
        assert_eq!(display.pixels[52][0], BinaryColor::Off);
        assert_eq!(plot.header_text().as_str(), "X -2147483648mg LIVE");
    }

    #[test]
    fn the_header_shows_axis_signed_units_and_hold_state() {
        let mut plot = Plot::new();
        assert_eq!(plot.header_text().as_str(), "X --mg LIVE");

        plot.record([123, 0, 0]);
        assert_eq!(plot.header_text().as_str(), "X +123mg LIVE");

        plot.toggle_pause();
        assert_eq!(plot.header_text().as_str(), "X +123mg HOLD");

        plot.next_axis();
        assert_eq!(plot.header_text().as_str(), "Y --mg HOLD");
    }
}
