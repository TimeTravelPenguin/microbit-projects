use heapless::Vec;
use thiserror::Error;

#[derive(Clone, Copy, Debug, Error, PartialEq, Eq)]
pub enum LineError {
    #[error("buffer overflow")]
    BufferOverflow,
    #[error("input must contain only ASCII characters")]
    NonAscii,
    #[error("incomplete line timed out")]
    Timeout,
}

/// Collects ASCII lines, discarding rejected input through the next newline.
pub struct LineReader<const N: usize> {
    buffer: Vec<u8, N>,
    discarding: bool,
    pending_error: Option<LineError>,
}

impl<const N: usize> LineReader<N> {
    pub fn new() -> Self {
        Self {
            buffer: Vec::new(),
            discarding: false,
            pending_error: None,
        }
    }

    /// Accepts LF and CRLF; carriage returns do not consume buffer capacity.
    pub fn push(&mut self, byte: u8) -> Option<Result<Vec<u8, N>, LineError>> {
        if byte == b'\n' {
            if self.discarding {
                self.discarding = false;

                return self.pending_error.take().map(Err);
            }

            return Some(Ok(core::mem::take(&mut self.buffer)));
        }

        if self.discarding || byte == b'\r' {
            return None;
        }

        if !byte.is_ascii() {
            self.reject(LineError::NonAscii);

            return None;
        }

        if self.buffer.push(byte).is_err() {
            self.reject(LineError::BufferOverflow);
        }

        None
    }

    /// A silent connection is allowed; only unfinished, unreported input expires.
    pub fn needs_timeout(&self) -> bool {
        !self.buffer.is_empty() || self.pending_error.is_some()
    }

    pub fn timeout(&mut self) -> Option<LineError> {
        if !self.needs_timeout() {
            return None;
        }

        let error = self.pending_error.take().unwrap_or(LineError::Timeout);
        self.discard();

        Some(error)
    }

    /// Call after a reported UART error or timeout to drop the rest of its line.
    pub fn discard(&mut self) {
        self.buffer.clear();
        self.discarding = true;
        self.pending_error = None;
    }

    fn reject(&mut self, error: LineError) {
        self.discard();
        self.pending_error = Some(error);
    }
}

impl<const N: usize> Default for LineReader<N> {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
extern crate std;

#[cfg(test)]
mod tests {
    use super::{LineError, LineReader};

    fn feed<const N: usize>(
        reader: &mut LineReader<N>,
        input: &[u8],
    ) -> std::vec::Vec<Result<heapless::Vec<u8, N>, LineError>> {
        input.iter().filter_map(|&byte| reader.push(byte)).collect()
    }

    #[test]
    fn accepts_exact_capacity_and_the_next_line() {
        let mut reader = LineReader::<4>::new();
        let events = feed(&mut reader, b"abcd\nx\n");
        assert_eq!(events.len(), 2);
        assert_eq!(events[0].as_ref().unwrap().as_slice(), b"abcd");
        assert_eq!(events[1].as_ref().unwrap().as_slice(), b"x");
    }

    #[test]
    fn rejects_an_oversized_line_and_discards_its_suffix() {
        let mut reader = LineReader::<4>::new();
        let events = feed(&mut reader, b"abcdeTAIL\nok\n");
        assert_eq!(events.len(), 2);
        assert_eq!(events[0], Err(LineError::BufferOverflow));
        assert_eq!(events[1].as_ref().unwrap().as_slice(), b"ok");
    }

    #[test]
    fn accepts_crlf_at_exact_capacity() {
        let mut reader = LineReader::<4>::new();
        let events = feed(&mut reader, b"abcd\r\n");
        assert_eq!(events.len(), 1);
        assert_eq!(events[0].as_ref().unwrap().as_slice(), b"abcd");
    }

    #[test]
    fn rejects_non_ascii_and_recovers_at_the_newline() {
        let mut reader = LineReader::<8>::new();
        let events = feed(&mut reader, "caféTAIL\nokay\n".as_bytes());
        assert_eq!(events.len(), 2);
        assert_eq!(events[0], Err(LineError::NonAscii));
        assert_eq!(events[1].as_ref().unwrap().as_slice(), b"okay");
    }

    #[test]
    fn preserves_the_first_error_in_a_rejected_line() {
        let mut reader = LineReader::<1>::new();
        let events = feed(&mut reader, b"ab\xff\n");
        assert_eq!(events.as_slice(), &[Err(LineError::BufferOverflow)]);
    }

    #[test]
    fn accepts_empty_lines_without_a_timeout() {
        let mut reader = LineReader::<4>::new();
        let events = feed(&mut reader, b"\n\r\n");
        assert_eq!(events.len(), 2);
        assert!(
            events
                .iter()
                .all(|event| event.as_ref().unwrap().is_empty())
        );
        assert!(!reader.needs_timeout());
        assert_eq!(reader.timeout(), None);
    }

    #[test]
    fn times_out_once_and_discards_the_abandoned_suffix() {
        let mut reader = LineReader::<8>::new();
        assert!(feed(&mut reader, b"old").is_empty());
        assert!(reader.needs_timeout());
        assert_eq!(reader.timeout(), Some(LineError::Timeout));
        assert_eq!(reader.timeout(), None);
        assert!(!reader.needs_timeout());

        let events = feed(&mut reader, b"tail\nnew\n");
        assert_eq!(events.len(), 1);
        assert_eq!(events[0].as_ref().unwrap().as_slice(), b"new");
    }

    #[test]
    fn reports_overflow_when_the_rejected_line_times_out() {
        let mut reader = LineReader::<1>::new();
        assert!(feed(&mut reader, b"ab").is_empty());
        assert_eq!(reader.timeout(), Some(LineError::BufferOverflow));
        assert_eq!(reader.timeout(), None);
        assert!(feed(&mut reader, b"tail\n").is_empty());
    }

    #[test]
    fn reports_non_ascii_when_the_rejected_line_times_out() {
        let mut reader = LineReader::<4>::new();
        assert!(feed(&mut reader, b"\xff").is_empty());
        assert_eq!(reader.timeout(), Some(LineError::NonAscii));
    }

    #[test]
    fn discards_partial_input_after_a_uart_error() {
        let mut reader = LineReader::<8>::new();
        assert!(feed(&mut reader, b"old").is_empty());
        reader.discard();

        let events = feed(&mut reader, b"tail\nnew\n");
        assert_eq!(events.len(), 1);
        assert_eq!(events[0].as_ref().unwrap().as_slice(), b"new");
    }

    #[test]
    fn permits_empty_lines_but_rejects_data_with_zero_capacity() {
        let mut reader = LineReader::<0>::new();
        let events = feed(&mut reader, b"\na\n");
        assert_eq!(events.len(), 2);
        assert!(events[0].as_ref().unwrap().is_empty());
        assert_eq!(events[1], Err(LineError::BufferOverflow));
    }
}
