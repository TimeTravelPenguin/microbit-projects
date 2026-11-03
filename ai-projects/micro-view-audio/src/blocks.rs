use crate::analysis::HOP_LEN;

/// Eight 16 ms hops provide 128 ms of foreground processing headroom.
pub const BLOCK_QUEUE_LEN: usize = 8;

/// An owned snapshot of one completed microphone DMA buffer.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct AudioBlock {
    pub samples: [i16; HOP_LEN],
    pub sequence: u32,
}

impl AudioBlock {
    const EMPTY: Self = Self {
        samples: [0; HOP_LEN],
        sequence: 0,
    };
}

/// A bounded FIFO whose sequence numbers reveal dropped capture blocks.
pub struct BlockQueue {
    blocks: [AudioBlock; BLOCK_QUEUE_LEN],
    head: usize,
    len: usize,
    next_sequence: u32,
    dropped: u32,
}

impl BlockQueue {
    pub const fn new() -> Self {
        Self {
            blocks: [AudioBlock::EMPTY; BLOCK_QUEUE_LEN],
            head: 0,
            len: 0,
            next_sequence: 0,
            dropped: 0,
        }
    }

    /// Keep the newest audio when processing falls behind a full queue.
    pub fn push(&mut self, samples: [i16; HOP_LEN]) {
        if self.len == BLOCK_QUEUE_LEN {
            self.head = (self.head + 1) % BLOCK_QUEUE_LEN;
            self.len -= 1;
            self.dropped = self.dropped.saturating_add(1);
        }

        let tail = (self.head + self.len) % BLOCK_QUEUE_LEN;
        self.blocks[tail] = AudioBlock {
            samples,
            sequence: self.next_sequence,
        };

        self.len += 1;
        self.next_sequence = self.next_sequence.wrapping_add(1);
    }

    /// Return an owned copy so later capture never changes an in-flight block.
    pub fn pop(&mut self) -> Option<AudioBlock> {
        if self.len == 0 {
            return None;
        }

        let block = self.blocks[self.head];
        self.head = (self.head + 1) % BLOCK_QUEUE_LEN;
        self.len -= 1;

        Some(block)
    }

    pub const fn dropped_blocks(&self) -> u32 {
        self.dropped
    }
}

impl Default for BlockQueue {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn fifo_returns_owned_copies_and_empty_queues_return_none() {
        let mut queue = BlockQueue::new();
        assert!(queue.pop().is_none());

        let mut samples = [123; HOP_LEN];
        queue.push(samples);
        samples.fill(456);
        queue.push(samples);

        let first = queue.pop().unwrap();
        assert_eq!(first.sequence, 0);
        assert_eq!(first.samples, [123; HOP_LEN]);

        let second = queue.pop().unwrap();
        assert_eq!(second.sequence, 1);
        assert_eq!(second.samples, [456; HOP_LEN]);
        assert!(queue.pop().is_none());

        // Reuse every queue slot while the caller still holds the first block.
        for sample in 0..BLOCK_QUEUE_LEN as i16 {
            queue.push([sample; HOP_LEN]);
        }

        assert_eq!(first.samples, [123; HOP_LEN]);
        assert_eq!(queue.dropped_blocks(), 0);
    }

    #[test]
    fn overflow_keeps_the_newest_eight_and_exposes_a_sequence_gap() {
        let mut queue = BlockQueue::new();
        queue.push([0; HOP_LEN]);
        let last_consumed = queue.pop().unwrap();

        for sequence in 1..=BLOCK_QUEUE_LEN + 3 {
            queue.push([sequence as i16; HOP_LEN]);
        }

        assert_eq!(queue.dropped_blocks(), 3);

        let first_retained = queue.pop().unwrap();
        assert_eq!(first_retained.sequence, 4);
        assert_ne!(
            first_retained.sequence,
            last_consumed.sequence.wrapping_add(1)
        );
        assert_eq!(first_retained.samples, [4; HOP_LEN]);

        for expected in 5..=11 {
            let block = queue.pop().unwrap();
            assert_eq!(block.sequence, expected);
            assert_eq!(block.samples, [expected as i16; HOP_LEN]);
        }

        assert!(queue.pop().is_none());

        // The diagnostic counter saturates rather than wrapping to zero.
        queue.dropped = u32::MAX;

        for _ in 0..=BLOCK_QUEUE_LEN {
            queue.push([0; HOP_LEN]);
        }

        assert_eq!(queue.dropped_blocks(), u32::MAX);
    }

    #[test]
    fn sequence_wrap_preserves_all_blocks_and_continuity() {
        let mut queue = BlockQueue::new();
        queue.next_sequence = u32::MAX - 1;

        for sample in 0..4 {
            queue.push([sample; HOP_LEN]);
        }

        let mut expected = u32::MAX - 1;

        for sample in 0..4 {
            let block = queue.pop().unwrap();
            assert_eq!(block.sequence, expected);
            assert_eq!(block.samples, [sample; HOP_LEN]);
            expected = expected.wrapping_add(1);
        }

        assert!(queue.pop().is_none());
        assert_eq!(queue.dropped_blocks(), 0);
    }
}
