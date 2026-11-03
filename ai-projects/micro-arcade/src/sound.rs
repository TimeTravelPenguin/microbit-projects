//! Blocking playback of mono, 16-bit PCM WAV audio through the built-in speaker.

#[cfg(not(test))]
use microbit::hal::{
    Timer,
    gpio::{Output, Pin, PushPull},
    pac::{PWM0, TIMER1},
    pwm::{Channel, Pwm, PwmEvent, Seq},
};

#[cfg(not(test))]
const PWM_FREQUENCY_HZ: u32 = 64_000;
const MICROSECONDS_PER_SECOND: u32 = 1_000_000;

/// A WAV file that cannot be played by the speaker.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum SoundError {
    InvalidWav,
    UnsupportedFormat,
    UnsupportedSampleRate,
    TooLong,
}

/// Owns a PWM peripheral and a separate timer so display delays remain independent.
#[cfg(not(test))]
pub struct Speaker {
    pwm: Pwm<PWM0>,
    timer: Timer<TIMER1>,
}

#[cfg(not(test))]
impl Speaker {
    pub fn new(pwm: PWM0, timer: TIMER1, pin: Pin<Output<PushPull>>) -> Self {
        let pwm = Pwm::new(pwm);
        pwm.set_max_duty((16_000_000 / PWM_FREQUENCY_HZ) as u16);
        pwm.set_output_pin(Channel::C0, pin);
        pwm.disable_channel(Channel::C0);
        pwm.disable();

        Self {
            pwm,
            timer: Timer::new(timer),
        }
    }

    /// Plays the entire clip once, then returns the speaker pin to its idle state.
    ///
    /// Samples stay in flash; only the HAL's single PWM duty value lives in RAM.
    pub fn play(&mut self, bytes: &[u8]) -> Result<(), SoundError> {
        let clip = PcmClip::parse(bytes)?;

        if clip.samples.is_empty() {
            return Ok(());
        }

        let sample_period_us = MICROSECONDS_PER_SECOND / clip.sample_rate;
        let sample_remainder = MICROSECONDS_PER_SECOND % clip.sample_rate;
        let mut deadline_us = 0;
        let mut remainder = 0;

        self.pwm.enable_channel(Channel::C0);
        self.timer.start(u32::MAX);

        for sample_bytes in clip.samples.as_chunks::<2>().0 {
            let sample = i16::from_le_bytes([sample_bytes[0], sample_bytes[1]]);
            self.pwm.reset_event(PwmEvent::SeqStarted(Seq::Seq0));
            self.pwm
                .set_duty_on_common(sample_duty(sample, self.pwm.max_duty()));

            // Keep deadlines relative to the start, so decoding overhead cannot
            // accumulate. The remainder preserves rates such as 16 kHz (62.5 us).
            deadline_us += sample_period_us;
            remainder += sample_remainder;

            if remainder >= clip.sample_rate {
                deadline_us += 1;
                remainder -= clip.sample_rate;
            }

            while self.timer.read() < deadline_us {
                core::hint::spin_loop();
            }
        }

        self.timer
            .task_stop()
            .write(|writer| unsafe { writer.bits(1) });
        self.pwm.reset_event(PwmEvent::Stopped);
        self.pwm.stop();
        self.pwm.disable_channel(Channel::C0);
        self.pwm.disable();

        Ok(())
    }
}

struct PcmClip<'a> {
    sample_rate: u32,
    samples: &'a [u8],
}

impl<'a> PcmClip<'a> {
    fn parse(bytes: &'a [u8]) -> Result<Self, SoundError> {
        if bytes.get(..4) != Some(b"RIFF") || bytes.get(8..12) != Some(b"WAVE") {
            return Err(SoundError::InvalidWav);
        }

        let riff_end = little_endian_u32(&bytes[4..8])
            .checked_add(8)
            .ok_or(SoundError::InvalidWav)? as usize;
        let bytes = bytes.get(..riff_end).ok_or(SoundError::InvalidWav)?;
        let mut offset: usize = 12;
        let mut format = None;
        let mut samples = None;

        while let Some(header) = bytes.get(offset..offset.saturating_add(8)) {
            let chunk_length = little_endian_u32(&header[4..8]) as usize;
            let chunk_start = offset + 8;
            let chunk_end = chunk_start
                .checked_add(chunk_length)
                .ok_or(SoundError::InvalidWav)?;
            let chunk = bytes
                .get(chunk_start..chunk_end)
                .ok_or(SoundError::InvalidWav)?;

            match &header[..4] {
                b"fmt " => format = Some(chunk),
                b"data" => samples = Some(chunk),
                _ => {}
            }

            offset = chunk_end
                .checked_add(chunk_length % 2)
                .ok_or(SoundError::InvalidWav)?;
        }

        if offset != bytes.len() {
            return Err(SoundError::InvalidWav);
        }

        let format = format
            .filter(|format| format.len() >= 16)
            .ok_or(SoundError::InvalidWav)?;
        let samples = samples.ok_or(SoundError::InvalidWav)?;

        if little_endian_u16(&format[..2]) != 1
            || little_endian_u16(&format[2..4]) != 1
            || little_endian_u16(&format[12..14]) != 2
            || little_endian_u16(&format[14..16]) != 16
        {
            return Err(SoundError::UnsupportedFormat);
        }

        let sample_rate = little_endian_u32(&format[4..8]);

        if !(1_000..=16_000).contains(&sample_rate) {
            return Err(SoundError::UnsupportedSampleRate);
        }

        if samples.len() % 2 != 0 || little_endian_u32(&format[8..12]) != sample_rate * 2 {
            return Err(SoundError::InvalidWav);
        }

        let duration_us = (samples.len() / 2) as u64 * u64::from(MICROSECONDS_PER_SECOND)
            / u64::from(sample_rate);

        if duration_us >= u64::from(u32::MAX) {
            return Err(SoundError::TooLong);
        }

        Ok(Self {
            sample_rate,
            samples,
        })
    }
}

fn sample_duty(sample: i16, max_duty: u16) -> u16 {
    let unsigned_sample = (i32::from(sample) + 32_768) as u32;

    ((unsigned_sample * u32::from(max_duty)) >> 16) as u16
}

fn little_endian_u16(bytes: &[u8]) -> u16 {
    u16::from_le_bytes([bytes[0], bytes[1]])
}

fn little_endian_u32(bytes: &[u8]) -> u32 {
    u32::from_le_bytes([bytes[0], bytes[1], bytes[2], bytes[3]])
}

#[cfg(test)]
#[path = "sound/tests.rs"]
mod tests;
