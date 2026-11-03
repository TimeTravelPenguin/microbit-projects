//! Timer/PPI-triggered microphone capture, independent of foreground OLED writes.
//!
//! TIMER0 samples AIN3 every 125 µs. PPI restarts SAADC immediately at END so
//! its double-buffered pointer switches to the other 128-sample DMA buffer.
//! The interrupt copies the completed buffer into an eight-block queue; FFT
//! and drawing code only see those copies and never borrow DMA memory.

use core::{
    cell::{RefCell, UnsafeCell},
    ptr,
    sync::atomic::{Ordering, compiler_fence},
};

use cortex_m::{
    interrupt::{Mutex, free},
    peripheral::NVIC,
};
use embedded_hal::digital::OutputPin;
use micro_view_audio::{AudioBlock, BlockQueue, HOP_LEN, SAMPLE_RATE};
use microbit::{
    hal::{
        gpio::{Floating, Input, OpenDrain, Output, p0::P0_05, p0::P0_20},
        ppi::{ConfigurablePpi, Ppi, Ppi0, Ppi1},
    },
    pac::{self, interrupt},
};

const SAMPLE_INTERVAL_US: u32 = 1_000_000 / SAMPLE_RATE;

// EasyDMA requires writable RAM with an address that never changes. No Rust
// reference to these samples is created: hardware writes one buffer while
// only the SAADC handler reads the other through raw pointers after END.
#[repr(align(4))]
struct DmaBuffer(UnsafeCell<[i16; HOP_LEN]>);

// SAFETY: only EasyDMA and the SAADC handler access the contents, with the
// completion/STARTED protocol below assigning each buffer to one of them.
unsafe impl Sync for DmaBuffer {}

static DMA_BUFFERS: [DmaBuffer; 2] = [
    DmaBuffer(UnsafeCell::new([0; HOP_LEN])),
    DmaBuffer(UnsafeCell::new([0; HOP_LEN])),
];

struct Sampler {
    adc: pac::SAADC,
    timer: pac::TIMER0,
    sample_ppi: Ppi0,
    restart_ppi: Ppi1,
    _mic_input: P0_05<Input<Floating>>,
    mic_enable: P0_20<Output<OpenDrain>>,
    completed_buffer: usize,
    queue: BlockQueue,
}

static SAMPLER: Mutex<RefCell<Option<Sampler>>> = Mutex::new(RefCell::new(None));

/// Start capture after powering the microphone and allowing it to settle.
///
/// The caller supplies the BSP's high-drive microphone enable pin already high.
/// TIMER0 and PPI channels 0/1 remain exclusively owned by this module. Interrupt
/// handlers and foreground critical sections must finish within the 16 ms hop;
/// reset capture after halting with a debugger because PPI keeps running.
pub fn initialise(
    adc: pac::SAADC,
    timer: pac::TIMER0,
    mut sample_ppi: Ppi0,
    mut restart_ppi: Ppi1,
    mic_input: P0_05<Input<Floating>>,
    mic_enable: P0_20<Output<OpenDrain>>,
) {
    NVIC::mask(pac::Interrupt::SAADC);
    sample_ppi.disable();
    restart_ppi.disable();
    timer
        .tasks_stop
        .write(|writer| writer.tasks_stop().trigger());
    timer
        .intenclr
        .write(|writer| unsafe { writer.bits(u32::MAX) });
    timer.mode.write(|writer| writer.mode().timer());
    timer.bitmode.write(|writer| writer.bitmode()._16bit());
    timer
        .prescaler
        .write(|writer| unsafe { writer.prescaler().bits(4) });
    timer.cc[0].write(|writer| unsafe { writer.cc().bits(SAMPLE_INTERVAL_US) });
    timer
        .shorts
        .write(|writer| writer.compare0_clear().enabled());
    timer.events_compare[0].reset();
    timer
        .tasks_clear
        .write(|writer| writer.tasks_clear().trigger());

    adc.intenclr
        .write(|writer| unsafe { writer.bits(u32::MAX) });
    adc.enable.write(|writer| writer.enable().enabled());
    adc.resolution.write(|writer| writer.val()._14bit());
    adc.oversample.write(|writer| writer.oversample().over4x());
    adc.samplerate.write(|writer| writer.mode().task());

    for channel in &adc.ch {
        channel.pselp.write(|writer| writer.pselp().nc());
        channel.pseln.write(|writer| writer.pseln().nc());
    }

    adc.ch[0].config.write(|writer| {
        writer.resp().bypass();
        writer.resn().bypass();
        // Match CODAL's microphone gain/reference: the board biases its mic
        // around VDD/34, so a VDD/16 input range captures quiet AC detail.
        writer.gain().gain4();
        writer.refsel().vdd1_4();
        writer.tacq()._10us();
        writer.mode().se();
        // Four conversions fit within each 125 us sample period. BURST emits
        // one averaged result per trigger, preserving the 8 kHz output rate.
        writer.burst().enabled()
    });

    adc.ch[0]
        .pselp
        .write(|writer| writer.pselp().analog_input3());
    adc.result
        .maxcnt
        .write(|writer| unsafe { writer.maxcnt().bits(HOP_LEN as u16) });
    queue_buffer(&adc, 0);

    adc.events_calibratedone.reset();
    adc.tasks_calibrateoffset
        .write(|writer| writer.tasks_calibrateoffset().trigger());

    while adc.events_calibratedone.read().bits() == 0 {}

    // Like nrfx, latch a disposable buffer and stop after calibration so any
    // spurious calibration samples cannot become the first audio samples.
    adc.events_started.reset();
    adc.tasks_start
        .write(|writer| writer.tasks_start().trigger());

    while adc.events_started.read().bits() == 0 {}

    stop_adc(&adc);
    adc.events_calibratedone.reset();
    adc.events_done.reset();
    adc.events_resultdone.reset();
    adc.events_end.reset();
    adc.events_started.reset();

    // START latches buffer 0. Only after STARTED may PTR safely be changed to
    // buffer 1, which the next START will latch without changing active DMA.
    queue_buffer(&adc, 0);
    adc.tasks_start
        .write(|writer| writer.tasks_start().trigger());

    while adc.events_started.read().bits() == 0 {}

    adc.events_started.reset();
    queue_buffer(&adc, 1);

    sample_ppi.set_event_endpoint(&timer.events_compare[0]);
    sample_ppi.set_task_endpoint(&adc.tasks_sample);
    restart_ppi.set_event_endpoint(&adc.events_end);
    restart_ppi.set_task_endpoint(&adc.tasks_start);

    free(|cs| {
        let mut sampler = SAMPLER.borrow(cs).borrow_mut();
        assert!(sampler.is_none(), "microphone already initialized");
        *sampler = Some(Sampler {
            adc,
            timer,
            sample_ppi,
            restart_ppi,
            _mic_input: mic_input,
            mic_enable,
            completed_buffer: 0,
            queue: BlockQueue::new(),
        });
    });

    NVIC::unpend(pac::Interrupt::SAADC);

    free(|cs| {
        let mut sampler = SAMPLER.borrow(cs).borrow_mut();
        let sampler = sampler.as_mut().unwrap();
        sampler.adc.intenset.write(|writer| writer.end().set());
        sampler.sample_ppi.enable();
        sampler.restart_ppi.enable();
        sampler
            .timer
            .tasks_start
            .write(|writer| writer.tasks_start().trigger());
    });

    // SAFETY: all interrupt-owned state and both DMA pointers are ready.
    unsafe { NVIC::unmask(pac::Interrupt::SAADC) };
}

pub fn take_block() -> Option<AudioBlock> {
    free(|cs| {
        SAMPLER
            .borrow(cs)
            .borrow_mut()
            .as_mut()
            .and_then(|sampler| sampler.queue.pop())
    })
}

pub fn dropped_blocks() -> u32 {
    free(|cs| {
        SAMPLER
            .borrow(cs)
            .borrow()
            .as_ref()
            .map_or(0, |sampler| sampler.queue.dropped_blocks())
    })
}

/// Stop capture and microphone power before System OFF; also safe before init.
pub fn stop() {
    NVIC::mask(pac::Interrupt::SAADC);
    let sampler = free(|cs| SAMPLER.borrow(cs).borrow_mut().take());

    if let Some(mut sampler) = sampler {
        sampler
            .timer
            .tasks_stop
            .write(|writer| writer.tasks_stop().trigger());
        sampler.sample_ppi.disable();
        sampler.restart_ppi.disable();
        sampler
            .adc
            .intenclr
            .write(|writer| unsafe { writer.bits(u32::MAX) });

        // No PPI restart remains possible. Do not hold a critical section while
        // waiting; TIMER2 can continue servicing buttons until it is stopped.
        stop_adc(&sampler.adc);
        compiler_fence(Ordering::SeqCst);
        sampler
            .adc
            .enable
            .write(|writer| writer.enable().disabled());
        sampler.adc.events_end.reset();
        sampler.adc.events_started.reset();
        sampler.mic_enable.set_low().unwrap();
    }

    NVIC::unpend(pac::Interrupt::SAADC);
}

fn stop_adc(adc: &pac::SAADC) {
    adc.events_stopped.reset();
    adc.tasks_stop.write(|writer| writer.tasks_stop().trigger());

    while adc.events_stopped.read().bits() == 0 {}

    adc.events_stopped.reset();
}

fn buffer_ptr(buffer: usize) -> *mut i16 {
    DMA_BUFFERS[buffer].0.get().cast::<i16>()
}

fn queue_buffer(adc: &pac::saadc::RegisterBlock, buffer: usize) {
    compiler_fence(Ordering::SeqCst);

    // SAFETY: the selected static, aligned RAM allocation stays alive forever;
    // STARTED ensures this write only changes the next transfer's pointer.
    adc.result
        .ptr
        .write(|writer| unsafe { writer.ptr().bits(buffer_ptr(buffer) as u32) });
}

#[interrupt]
fn SAADC() {
    // SAFETY: the handle is exclusively owned by SAMPLER. Foreground register
    // access occurs only before unmasking or after masking this interrupt.
    let adc = unsafe { &*pac::SAADC::ptr() };

    if adc.events_end.read().bits() == 0 {
        return;
    }

    adc.events_end.reset();

    // END -> START happens in PPI, independent of interrupt latency. STARTED
    // confirms the other pointer has latched before recycling the completed
    // allocation. This hardware wait lasts a few µs, outside a critical section.
    while adc.events_started.read().bits() == 0 {}

    adc.events_started.reset();
    compiler_fence(Ordering::SeqCst);

    free(|cs| {
        if let Some(sampler) = SAMPLER.borrow(cs).borrow_mut().as_mut() {
            let completed = sampler.completed_buffer;
            queue_buffer(adc, completed);
            let completed_ptr = buffer_ptr(completed);
            let mut samples = [0; HOP_LEN];

            for (idx, sample) in samples.iter_mut().enumerate() {
                // SAFETY: END completed all DMA writes to this allocation,
                // STARTED moved DMA to the other allocation, and it cannot be
                // reused for another 16 ms. This bounded copy takes a few µs.
                *sample = unsafe { ptr::read_volatile(completed_ptr.add(idx)) };
            }

            sampler.completed_buffer ^= 1;
            sampler.queue.push(samples);
        }
    });
}
