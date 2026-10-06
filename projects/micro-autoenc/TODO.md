# micro-autoenc TODO: useful speech denoising on micro:bit v2

Created: 2026-10-01. Status: review documented; implementation tasks are pending.

This is the durable plan for resuming the project a task at a time. It records
the review, the user's experiments, proposed changes, and the evidence required
to accept each change. The documentation request did not start a new training
run or implement the proposed architecture.

## How to resume

Ask, for example, **“Work on T01 in projects/micro-autoenc/TODO.md”** or
**“Continue with the next ready task in this TODO.”**

- Inspect the working tree and applicable `AGENTS.md` instructions first. There
  were substantial user edits and an active experiment during the review.
- Read the selected task, its dependencies, and the evidence below. Recheck
  current code rather than assuming the dated snapshot is still current.
- Implement a bounded task, verify its acceptance criteria, and update its
  checkbox and the work log. Do not mark an experiment successful just because
  training ran or the loss decreased.
- Record the exact configuration, artifact location, measurements, unresolved
  issues, and next ready task. Keep completed evidence available for later work.
- Preserve existing experiments. Use unique run directories and output names;
  do not use `--overwrite` as a convenience when continuing this plan.
- Follow the user's readable variable naming and blank-line separation rules.
  Prefer small, understandable Rust changes and reuse the current streaming
  infrastructure. Avoid building a general experiment platform.
- Stop at the selected task's completion boundary unless the user requested a
  larger sequence. This document is not a recurring automation.

**Suggested start:** T01, then T02. T03/T04 improve the existing baseline;
T05 and T06 begin the deployment and signal-processing investigations.

## Objective and open decisions

Build a streaming audio denoiser that audibly reduces noise while preserving
speech detail, fits the micro:bit v2 application processor, and meets the audio
processing deadline. Training remains on the computer; the board performs
inference and signal processing only.

Speech is the current working assumption because the project uses
VoiceBank-DEMAND. Confirm these details during T02, without blocking unrelated
test repairs or desktop signal-processing work:

- [ ] Confirm whether the target is speech, music/general audio, or a particular
  sound. A speech-trained model should not be treated as a general audio denoiser.
- [ ] Record representative noises and recording conditions to support first.
- [ ] Confirm microphone and output paths: onboard microphone, external input,
  onboard speaker, external output, or streamed audio.
- [ ] Set an acceptable latency and speech-distortion/noise-suppression tradeoff.
- [ ] Record firmware/runtime features sharing RAM and CPU, including any radio,
  display, or Bluetooth use. The chip's full memory is not automatically free.

Hardware reference: 64 MHz Cortex-M4 with FPU, 128 KB RAM, 512 KB flash. Budget
flash, peak RAM, and execution time separately. No complete on-device denoising
implementation or measured firmware fit was established by the review.

## Review evidence to preserve

### What appears correct

- Clean/noisy recordings are paired from the same dataset row, framed at the
  same offsets, and scaled with `i16_sample / 32768.0` on both sides.
- The WAV processing path uses the same scaling. There was no observed reason
  to independently normalize the clean and noisy recordings.
- Train/validation separation happens by speaker before framing; held-out
  speakers are `p282` and `p287`. Official test shards are separate.
- The loader bounds host-side audio memory by streaming Parquet row groups and
  recording pairs. Host training memory is separate from device inference RAM.
- Backpropagation and training/inference mode handling looked consistent;
  dropout is disabled during inference. No definite optimizer or gradient-flow
  failure was found. The warmup/cosine schedule was not identified as a cause.
- In a review sample of 150 training recordings, cross-correlation peaked at
  zero lag within the inspected +/-10 ms range for every pair. This is a useful
  alignment check, not a proof about every recording.

### Quantitative baseline snapshot

Measured on all 730 validation recordings: 129,754 complete 256-sample frames,
or 2,076.064 seconds. Recording tails shorter than a frame were excluded to match
the existing evaluator. These are historical review measurements; save a
reproducible report in T02/T04 instead of relying on mutable `artifacts/` files.

| Output | Sample-weighted waveform MSE | Equal-weight mean over batches of 128 |
| --- | ---: | ---: |
| Unchanged noisy input | 0.0019731285158226027 | 0.001974492086584765 |
| All-zero output | 0.0038289863479673888 | 0.003828916164220099 |
| Later reviewed run, epoch 7 | Not independently recomputed | 0.0010095171184077163 |

The epoch-7 value came from the completed validation log for the saved
`256 -> 128 -> 64 -> 32 -> 64 -> 128 -> 256` run. Against the matching batch
baseline it is about 49% less squared error. This establishes useful numerical
learning, not satisfactory perceived quality or final convergence.

An earlier run, with latent size 16, had epoch-3 validation MSE 0.0015582996,
about 21% below the matching noisy baseline. The run/configuration changed during
review. **These are different experiment snapshots, not one learning curve.**

About 44% of validation frames had clean RMS below -40 dBFS. These are low-energy
frames, not necessarily literal silence. Their count alone does not demonstrate
that silence dominates the loss or that the network collapsed to zero.

### User-reported experiments: do not repeat by default

The user has already tried inexpensive tests. Loss falls, plateaus quickly, and
the final output remains poor, including muffling. The exact configurations,
metrics, and whether a clean-to-clean reconstruction test was included were not
recorded in this conversation.

- Treat the plateau and muffling as established user observations.
- Do not prescribe the same broad tiny-set/overfit tests as the next obligatory
  step. Retrieve existing evidence if available; only repeat a narrowly targeted
  diagnostic to answer a remaining question.
- If clean-to-clean reconstruction was also muffled, that strengthens the
  hypothesis that reconstruction capacity is limiting quality before denoising.
  Do not claim that particular experiment has been confirmed.
- A small correctness check of the *new spectral pipeline* is still appropriate;
  it tests a different implementation and should remain bounded.

### Confirmed limitations and defects

1. **Independent waveform frames:** `RecordingFrames::next` in `src/dataset.rs`
   advances by the whole frame size; `denoise_frames` in `src/audio.rs` predicts
   and concatenates adjacent frames without overlap or temporal state.
2. **Boundary artifacts in saved output:** the later inspected `output.wav`
   had boundary sample-jump RMS 0.01468 versus 0.005049 inside frames, a ratio
   of about 2.9. The input ratio was about 0.92. Both files had 70,774 samples
   at 16 kHz. The output's checkpoint provenance was unknown; the measurement
   supports a continuity concern but does not prove which configuration caused it.
3. **Restricted waveform reconstruction:** the entire signal passes through a
   bottleneck, with no original-signal bypass. The final linear decoder also
   confines output to an affine subspace whose dimension cannot exceed its
   input width. Earlier nonlinear layers do not remove that final constraint.
4. **Only waveform MSE is optimized/reported during training:** loss can improve
   while speech loses detail. Squared amplitude error emphasizes stronger signal
   components; quieter consonants and audible discontinuities need explicit
   evaluation. This is a limitation, not proof that MSE always causes muffling.
5. **Final rather than best checkpoint:** `training::train` saves `result.model`
   to `model.bpk`. The inspected Burn learner returns the last model; early
   stopping does not automatically restore the best validation epoch.
6. **Current optimizer/test mismatch:** `TrainingConfig` now uses `AdamWConfig`,
   but `tests/dataset.rs`, `tests/process_audio.rs`, and
   `tests/training_config.rs` still pass `AdamConfig`. The latest reviewed test
   run failed to compile. An earlier snapshot passed 30 tests with one ignored.
7. **Stale documentation:** README examples use the old optimizer and two-argument
   `TrainingConfig::new`, advertise a missing `--learning-rate` flag, and give an
   outdated fixed learning rate. Current defaults warm up from `1e-5` to `1e-3`
   and use cosine annealing. The CLI also now has a destructive `--overwrite`
   option, while README describes exclusively new/empty run directories.

### Memory and compute snapshot

Parameters include biases. KiB means 1,024 bytes. Float32 sizes below are raw
parameter storage, not complete firmware or process memory.

| Model source at review | Widths | Parameters | Float32 storage | Dense MAC/s at 16 kHz, hop 256 |
| --- | --- | ---: | ---: | ---: |
| CLI default | 256, 64, 32, 8, 32, 64, 256 | 37,832 | 147.8 KiB | 2.336 million |
| Earlier saved run | 256, 128, 32, 16, 32, 128, 256 | 75,344 | 294.3 KiB | 4.672 million |
| Later saved run | 256, 128, 64, 32, 64, 128, 256 | 86,688 | 338.6 KiB | 5.376 million |
| Edited root config | 256, 128, 96, 64, 94, 128, 256 | 102,782 | 401.5 KiB | 6.376 million |

All exceed 128 KiB if their float32 parameters are resident in RAM. This does
not make inference inherently impossible: an appropriate runtime can read
constant weights from flash and reuse activation buffers. Flash must also hold
firmware and other constants. Int8 conversion requires scales, wider biases/
accumulators, compatible kernels, and quality checks; it is not just a smaller
file extension. A Burn `.bpk` file is not an established embedded deployment path.

The host command `cargo check -p micro-autoenc --no-default-features --lib` passed
during review. That is not an ARM target build, linked firmware memory check, or
runtime measurement. The ARM target was not installed at that time. `alloc::Vec`
and backend allocations also require a deliberate embedded allocation strategy.

## Working design to investigate

Keep the existing waveform model as a reproducible baseline. The proposed new
model predicts spectral attenuation gains rather than recreating PCM samples.

```text
16 kHz mono PCM
  -> overlapping 512-sample analysis windows, hop 256
  -> real FFT: retain the original complex spectrum
  -> approximately 32 log-energy frequency-band features
  -> current features plus two preceding feature frames (96 inputs)
  -> dense 96 -> 32 -> 32, sigmoid output gains
  -> interpolate gains across FFT bins
  -> multiply the original complex spectrum by the gains
  -> inverse FFT and correctly normalized overlap-add
  -> PCM output
```

This initial network has 4,096 weights plus 64 biases: **4,160 parameters,
16.25 KiB float32**, and about 256,000 dense MAC/s at the proposed hop. FFTs,
feature extraction, nonlinearities, buffering, and firmware costs are additional.
The design is a hypothesis to test, not a demonstrated quality or device-fit claim.

- The window spans 32 ms; updates occur every 16 ms. Neither number alone is
  the end-to-end latency. Specify buffering, alignment, startup, and output delay.
- Use past/current features only. A centered offline transform must not silently
  introduce future context that deployment cannot provide.
- A reasonable starting window is periodic square-root Hann for analysis and
  synthesis at 50% overlap, with correct boundary handling and overlap
  normalization. Prove reconstruction numerically before relying on it.
- Select and save a fixed perceptual band layout, for example Bark- or ERB-like
  triangular bands. Ensure gain interpolation covers DC through Nyquist and that
  all-one band gains produce an all-one bin mask.
- Keep the noisy complex spectrum. Band energies, mel features, or MFCCs alone
  are not sufficient to reconstruct the waveform.
- Bounded gains preserve the noisy phase; they cannot restore arbitrary phase
  errors or amplify a clean component reduced by destructive interference.
  Coarse bands also limit suppression between speech harmonics. T08 tests the
  practical consequences before committing to this representation.
- Keep PCM scaling unchanged for the initial comparison. Do not independently
  peak-normalize noisy and clean pairs. Any later common gain transform must
  preserve their relationship and be reproducible at inference.
- Keep absolute level information in features. If feature standardization is
  used, fit constants only on training data, save them, and freeze them for
  validation, testing, and device inference.
- Dropout, extra layers, recurrence, loss mixtures, and quantization are not
  prerequisites for the first useful spectral baseline.

## Task roadmap

Each checkbox represents a bounded deliverable. “Done when” is the acceptance
gate, not a promise that the experiment will succeed. If a quality gate fails,
record that outcome and investigate it before starting dependent optimization.

### T01 — Restore tests and align current documentation

- [ ] **T01 complete**
- **Depends on:** nothing; recheck whether the user already fixed it.
- Update test optimizer imports/construction to the intended current optimizer;
  retain meaningful test semantics rather than merely suppressing type errors.
- Correct README constructor examples, optimizer name, learning-rate schedule,
  available CLI flags, and actual overwrite behavior. Keep help text consistent.
- **Done when:** `cargo test -p micro-autoenc` passes, the inference-only host
  check passes, and documented examples/options agree with current code. Note
  any optional downloaded-data test that remains ignored and why.

### T02 — Preserve a reproducible baseline and define success

- [ ] **T02 complete**
- **Depends on:** T01 for running the current executable; context collection can
  begin independently.
- Record the objective decisions above and existing small-test evidence. Keep
  speech as the explicit provisional assumption until confirmed.
- Identify a completed existing run and its actual checkpoint; preserve its
  configuration, source revision/diff reference, seed, data split, metrics, and
  representative input/clean/output recordings in a uniquely named location.
  Do not copy a checkpoint while a writer is still updating it.
- Preserve both configuration provenance and output provenance. Root
  `autoenc-config.json`, saved `artifacts/config.json`, and loose WAVs were not
  interchangeable sources of truth during review.
- Choose a fixed validation listening subset including speech, quiet consonants,
  clean/high-SNR speech, noise-only intervals, and several noise conditions.
- **Done when:** a later session can reproduce the reference outputs and knows
  what “better” means. Record the baseline metric definitions, aggregation, and
  provisional numeric quality/latency/memory gates. Keep test data out of tuning.

### T03 — Export the best validation checkpoint

- [ ] **T03 complete**
- **Depends on:** T01; use T02's run conventions.
- Explicitly select and reload the lowest-validation-loss checkpoint for the
  inference export. Ensure checkpoint retention preserves the selected epoch.
- Record selected epoch, metric name/value, aggregation, and selection rule.
  Preserve the last checkpoint for continuation/debugging where appropriate;
  distinguish last and best in documentation and output names.
- Define deterministic ties and behavior on interrupted/incomplete runs. Do not
  silently advertise incomplete training as a successfully selected model.
- **Done when:** a controlled case with an earlier best epoch exports that
  epoch's predictions, including after early stopping; reload parity holds.

### T04 — Evaluate complete audio and preserve speech quality

- [ ] **T04 complete**
- **Depends on:** T01/T02; can proceed alongside T03.
- Add per-recording reports for noisy input, silence, and model output against
  clean audio. Retain sample-weighted MSE and distinguish it from equal-batch
  averages and per-recording means. The current evaluator already weights MSE
  correctly by frame count; preserve that behavior.
- Evaluate full reconstructed recordings, including joins and tails, with an
  explicit latency/alignment convention. Keep a separately labeled legacy
  complete-frame metric when comparing the historical measurements above.
- Add utterance-level SI-SDR improvement and output-level/clipping statistics;
  handle silent/near-silent references explicitly rather than emitting misleading
  infinities. SI-SDR is scale-invariant and cannot replace gain measurements.
- Report speech-active quality and noise-only residuals with a documented
  segmentation rule. Add STOI later if a suitable implementation is available;
  perceptual metrics supplement listening, not replace it.
- Save reproducible listening examples and spectrograms with consistent scales.
  Keep original playback levels available; label any loudness-matched copies.
- **Done when:** identity and zero-output controls behave as defined, aggregate
  metrics are insensitive to batch partitioning, and complete recordings can be
  compared without hidden alignment/normalization changes.

### T05 — Probe the embedded route early

- [ ] **T05 complete**
- **Depends on:** T01; independent of successful model training.
- Check support for the Cortex-M4F target `thumbv7em-none-eabihf` and the chosen
  board setup. Recheck tool availability before proposing dependency installs.
- Decide whether Burn inference is practical or whether to keep Burn for
  training and export to small Rust kernels or a suitable embedded library.
  Evaluate FFT support and allocation requirements as part of this choice.
- Make a small linked firmware proof, with dummy/static coefficients if needed;
  inspect its memory map rather than treating a library check as a firmware fit.
- Record reserved RAM/flash, stack/heap strategy, audio-buffer requirements, and
  the first timing measurements if hardware is available.
- **Done when:** there is an evidence-based deployment route and provisional
  resource budget, or a precise documented blocker. Lack of attached hardware
  need not block independent desktop work; do not mark hardware timing verified.

### T06 — Implement and prove streaming analysis/synthesis identity

- [ ] **T06 complete**
- **Depends on:** T02's provisional format/latency decisions; coordinate with T05.
- Build shared signal-processing code for training/evaluation and inference,
  using the proposed 512 window / 256 hop initially. Keep the existing waveform
  path available. Separate window size, hop size, FFT-bin count, and model width.
- Specify FFT scaling, periodic window convention, normalization by the sum of
  overlapping analysis/synthesis window products, startup padding, end flush,
  delay, exact sample count, and state reset at recording boundaries.
- Test all-one masks before adding a neural model. Include impulses at the
  beginning/end and joins, silence, DC, sine waves, random signals, short
  recordings, and lengths not divisible by the hop. Test chunk-size independence.
- **Done when:** input reconstruction meets a recorded float tolerance before
  PCM conversion, output length/alignment is exact after documented trimming,
  there is no periodic join error, and live buffers remain bounded.

### T07 — Define reproducible features and gain targets

- [ ] **T07 complete**
- **Depends on:** T06.
- Specify the 32-band layout, energy calculation, log floor, input feature
  ordering, gain interpolation, sigmoid output range, and treatment of DC and
  Nyquist. Save preprocessing constants with the model.
- Start with a clearly defined band target such as
  `clamp(sqrt(clean_band_energy / (noisy_band_energy + epsilon)), 0, 1)`.
  Define near-zero-energy behavior and training weights explicitly; the formula
  is a candidate attenuation target, not guaranteed optimal reconstruction.
- Treat targets above one before clipping as useful diagnostics of the bounded
  mask's limitations, not arithmetic errors. Use identical windows and alignment
  for clean and noisy feature calculations.
- Ensure gain interpolation is a partition of unity, and that silence produces
  finite features, targets, losses, and output.
- **Done when:** deterministic fixtures reproduce known band energies/gains,
  all-one gains preserve the spectrum, and preprocessing can be reproduced from
  saved configuration without consulting validation/test statistics.

### T08 — Test oracle gains and a conventional baseline

- [ ] **T08 complete**
- **Depends on:** T04/T06/T07.
- Apply gains computed from clean targets to noisy validation audio, without a
  trained network. Label this an oracle diagnostic, never deployable inference.
- Compare band oracle gains with a finer per-bin oracle if needed to isolate
  coarse-band limits from noisy-phase or bounded-gain limits. These candidate
  masks are diagnostics, not mathematical upper bounds on every enhancement method.
- Add one simple conventional spectral noise suppressor, such as a Wiener-style
  baseline, with documented noise estimation and no clean-reference access.
- **Done when:** reports and listening examples establish whether the proposed
  representation can preserve enough speech detail. If even oracle output is
  unacceptable, investigate bands/window/phase limits before training a network.

### T09 — Build context-aware streaming training examples

- [ ] **T09 complete**
- **Depends on:** T07; T08's result may alter the representation.
- Construct current plus two preceding feature frames in recording order,
  then shuffle complete examples. Do not assemble context from shuffled raw
  frames or adjacent recordings/speakers. Use past context only.
- Reset context at every recording boundary; specify startup padding consistent
  with inference. Preserve speaker-disjoint splits, bounded row-group loading,
  deterministic seeded epochs, and complete coverage of intended examples.
- Define tail/flush and target-frame semantics for overlapping frames. The
  current const-generic raw-waveform frame API should not silently acquire
  different meaning for existing consumers.
- **Done when:** fixtures prove chronology, no future leakage or cross-recording
  contamination, reproducible coverage, and bounded host memory. If recurrence
  is added later, replace frame shuffling with an appropriate sequence loader.

### T10 — Add the compact gain-prediction network

- [ ] **T10 complete**
- **Depends on:** T07 and the T08 representation decision; T09 supplies data.
- Implement the initial `96 -> 32 -> 32` model with a simple hidden activation
  and sigmoid gains. Input feature width and output gain count are different;
  do not force it into the current equal-input/output autoencoder contract.
- Keep the waveform autoencoder identifiable as a separate baseline. Start with
  no dropout and no weight decay to minimize regularization confounds.
- **Done when:** output shape/range and inference determinism are correct,
  gradients reach trainable layers, and parameter/MAC counts match the recorded
  design. Update counts if the architecture changes.

### T11 — Integrate versioned configuration, training, and WAV processing

- [ ] **T11 complete**
- **Depends on:** T03/T06/T09/T10.
- Add an explicit model kind and preprocessing/version metadata sufficient to
  reconstruct the pipeline: sample rate, window/hop, band definitions, features,
  context order, constants, architecture, loss, optimizer, and checkpoint choice.
- Resolve compatibility for old waveform and Adam-era configurations. Preserve
  supported legacy runs or reject unsupported formats with clear guidance;
  do not silently reinterpret Adam settings as AdamW or old weights as masks.
- Integrate training/evaluation/inference paths using shared preprocessing and
  record-level state. Remove assumptions that all dimensions equal `FRAME_SIZE`.
- Keep current PCM validation, finite-value checks, clipping policy, exact output
  length, and atomic/non-overwriting WAV publication behavior.
- **Done when:** a small new-model run can save, reload, evaluate, and process a
  WAV consistently; legacy behavior follows the documented compatibility policy.

### T12 — Train a bounded first spectral baseline

- [ ] **T12 complete**
- **Depends on:** T04/T08/T11.
- Run a small correctness experiment on the new pipeline, then a recorded,
  bounded training run. This is not a repeat of the user's old waveform tests.
- Start with one documented gain-domain loss, such as energy-weighted gain MSE,
  and inspect the consequences of the weighting. Do not simultaneously change
  architecture, augmentation, normalization, optimizer, and several losses.
- Log noisy/silence baselines, validation metrics, selected checkpoint, and fixed
  listening examples. Exclude oracle information from inference inputs.
- **Done when:** a reproducible spectral checkpoint exists and its behavior is
  measured, including whether it improves on a trivial/untrained predictor.
  Record failures and diagnostic evidence rather than extending training blindly.

### T13 — Decide whether the spectral baseline is worth pursuing

- [ ] **T13 complete**
- **Depends on:** T12.
- Compare unchanged input, the preserved waveform model, conventional denoising,
  oracle gains, and the learned spectral model on the same validation material.
- Evaluate noise reduction, consonant clarity, muffling, transient preservation,
  pumping/musical artifacts, clean-speech damage, and join continuity. Include
  per-recording results so easy recordings do not hide failures.
- Compare measured or estimated deployment cost alongside audio quality. Decide
  the next change from the observed failure mode, not loss alone.
- **Done when:** the report gives a keep/change/reject decision against T02's
  quality criteria, with evidence and the next bounded experiment. Do not proceed
  to costly optimization of a model whose sound remains unacceptable.

### T14 — Refine loss, gains, or context only as evidence requires

- [ ] **T14 complete or explicitly deferred**
- **Depends on:** T13.
- Consider compressed-magnitude/log-spectral reconstruction losses, gain-domain
  loss shaping, or a small waveform term; document floors and weighting so
  silence and very quiet speech do not destabilize training.
- Compare speech preservation and suppression separately. Tune causal gain
  smoothing or a gain floor only if needed; measure residual noise, onset
  smearing, and latency. Apply postprocessing consistently in evaluation/export.
- If context is insufficient, compare a modest causal context extension or small
  recurrent model. Longer context is not automatically a larger audio lookahead;
  recurrence requires ordered sequence training and explicit state reset.
- A residual/skip-connected waveform model is an optional alternative if spectral
  limits are demonstrated, not another mandatory model family to implement now.
- **Done when:** each retained change beats the previous validated version on
  its stated goal without unacceptable regressions. Record rejected variants.

### T15 — Improve training coverage and microphone robustness

- [ ] **T15 complete or explicitly deferred**
- **Depends on:** T13; coordinate with real capture findings in T18.
- Add controlled common gain augmentation and, where clean/noise components
  permit it, varied SNR/noise mixtures. Preserve sample alignment and avoid
  unintended clipping or independently normalized targets.
- Include clean speech, noise-only intervals, varied levels, and relevant noise
  types. Add realistic microphone frequency-response variation when evidence
  supports it. Do not remove all quiet frames or normalize silence to high gain.
- Keep augmented versions with their original split and avoid leakage through
  shared source recordings. Keep validation stable while comparing augmentation.
- **Done when:** held-out conditions improve without degrading established
  speech quality; save augmentation settings and random-seed policy.

### T16 — Export inference weights and prove desktop/runtime parity

- [ ] **T16 complete**
- **Depends on:** T05 and a quality-approved checkpoint from T13 or later.
- Export coefficients and preprocessing metadata to the selected embedded route.
  Prefer flash-resident read-only weights and reusable buffers where supported.
- Specify tensor orientation, bias layout, activation formulas, feature order,
  FFT conventions, gain interpolation, and state initialization explicitly.
- Compare shared fixtures stage by stage: features, gains, spectrum, and final
  waveform. A final WAV-only comparison can hide compensating errors.
- Inspect linked sections and actual allocation behavior; do not infer flash
  residency from a `const` declaration or model-file size alone.
- **Done when:** reference and exported inference agree within declared numeric
  tolerances, reset/chunk behavior matches, and memory ownership is documented.

### T17 — Quantize only if resource measurements justify it

- [ ] **T17 complete or explicitly deferred**
- **Depends on:** T16 and resource evidence from T05/T19.
- Establish a float reference first. If useful, evaluate int8 weights/activations
  with representative training calibration, correct bias/accumulator widths,
  scales/zero points, saturation behavior, and supported kernels.
- Account for sigmoid, feature/log processing, FFTs, scratch storage, and any
  dequantization costs. Do not assume quantizing dense layers quantizes everything.
- Consider quantization-aware training only if simpler conversion loses too much
  quality. Keep the float checkpoint and complete conversion metadata.
- **Done when:** measured RAM/flash/timing improves and validation quality stays
  within recorded limits, or float inference is explicitly retained as sufficient.

### T18 — Match the actual device's capture and output paths

- [ ] **T18 complete**
- **Depends on:** T05; can begin capture work before T16 is complete.
- Verify sample rate, ADC representation, bias/centering, gain, clipping, clock
  behavior, and any filtering/resampling against the training input contract.
  Add DC removal or resampling only where needed and apply a consistent policy.
- Capture representative device audio and compare its levels/spectrum with
  training data. Preserve originals and record capture settings.
- Evaluate model output separately from limitations of the onboard speaker or
  acoustic feedback. Use captured output or a suitable external playback path
  when deciding whether the model itself causes muffling.
- **Done when:** the capture-to-feature contract and output route are measured,
  documented, and reproducible, with identified domain mismatch addressed or
  recorded as an outstanding limitation.

### T19 — Prove complete firmware memory fit and real-time behavior

- [ ] **T19 complete**
- **Depends on:** T16/T18; T17 if quantization was selected.
- Integrate streaming capture, preprocessing, inference, synthesis, and output
  with bounded state. Avoid per-hop allocation in the steady-state audio path.
- Measure linked flash/static RAM and runtime peak stack/heap, double buffers,
  FFT scratch, model activations, context, overlap-add state, and runtime overhead.
- Time the complete processing hop under realistic interrupts/peripherals. For
  hop 256 at 16 kHz the deadline is 16 ms; record worst-case execution and margin,
  not just average dense-layer speed. Record startup/end-to-end latency separately.
- Test sustained operation, clipping, resets, long silence, loud inputs, and
  underrun/overrun behavior. Record the exact firmware/runtime configuration.
- **Done when:** the full application meets the agreed memory and timing budgets
  with margin and acceptable audio, demonstrated on hardware. Compilation alone
  does not satisfy this task.

### T20 — Freeze the design and perform final evaluation

- [ ] **T20 complete**
- **Depends on:** T13, T19, and any retained refinements.
- Freeze model, preprocessing, postprocessing, and checkpoint selection before
  evaluating official test data. Report aggregate and per-recording results
  against the same baselines, including desktop versus deployed output parity.
- Do not tune against the official test results. If further development follows,
  label that evaluation history and maintain an appropriate untouched final set.
- Write reproducible training, export, flash, and evaluation instructions; record
  final RAM/flash/timing/latency, known failure cases, and representative audio.
- **Done when:** another session can reproduce the chosen result, the device
  demonstration meets the defined objective, and remaining limitations are clear.

## Existing commands and implementation boundaries

Run from the workspace root. These are current commands, not instructions to
launch long-running work as part of documentation:

```sh
cargo test -p micro-autoenc
cargo check -p micro-autoenc --no-default-features --lib
cargo run -p micro-autoenc -- config
cargo run -p micro-autoenc -- --device cpu train --help
cargo run -p micro-autoenc -- --device cpu test --split validation --artifact-dir artifacts/RUN_NAME
cargo run -p micro-autoenc -- --device cpu process artifacts/RUN_NAME input.wav new-output.wav
```

`RUN_NAME` and WAV names are placeholders. The `test` command defaults to the
official test split, so pass `--split validation` during development. `process`
currently loads `model.bpk`, not an arbitrary epoch checkpoint. Config output is
not a checkpoint resume. The default device is Metal; CPU must be selected when
that is the intended backend. Do not use the workspace notification wrapper for
routine verification; direct Cargo commands avoid its external notifications.

The latest source also resolves the default dataset path with
`canonicalize().expect(...)`. Revisit this if configuration generation or tests
must work on a machine without the local download; do not mistake that path
failure for a model or training issue.

| File | Relevant responsibility |
| --- | --- |
| [src/model.rs](src/model.rs) | Existing waveform model, dimensions, activations, dropout |
| [src/dataset.rs](src/dataset.rs) | Pairing, splits, PCM scaling, framing, bounded shuffle |
| [src/training.rs](src/training.rs) | Optimizer/config, loss, schedule, learner, checkpoint export |
| [src/training/export.rs](src/training/export.rs) | Loss/learning-rate reports and aggregation |
| [src/main.rs](src/main.rs) | Defaults, fixed frame size, loading, CLI evaluation |
| [src/audio.rs](src/audio.rs) | Streaming WAV validation, inference, output publication |
| [src/cli.rs](src/cli.rs) | Command options and device selection |
| [src/lib.rs](src/lib.rs), [Cargo.toml](Cargo.toml) | Feature gates and embedded dependency boundary |
| [tests/dataset.rs](tests/dataset.rs) | Loading, shuffling, training and CLI integration checks |
| [tests/process_audio.rs](tests/process_audio.rs) | PCM values, tails, clipping, file protection |
| [tests/training_config.rs](tests/training_config.rs) | Config validation and optimizer construction |
| [README.md](README.md) | User-facing usage and model/artifact contracts |
| `../../autoenc-config.json` | User-edited experiment input; may differ from a saved run |
| `../../artifacts/` | Mutable/ignored experiment data; preserve named completed runs |

## Work log and handoff record

| Date | Task | Outcome and evidence | Next action |
| --- | --- | --- | --- |
| 2026-10-01 | Initial review | Pairing/scaling looked consistent; validation improvement and frame-join concern measured; memory estimates and checkpoint issue recorded above. Later AdamW edit left tests failing to compile. No model changes made by the reviewer. | T01 |
| 2026-10-01 | TODO documentation | Captured user-reported plateau/muffling, historical snapshots, proposed spectral approach, and independently finishable tasks. No new experiment launched. | T01, then T02 |

For each completed task, add a short entry containing:

- Task ID, date, outcome, and any changed design decision with its reason.
- Files changed and exact commands/checks that passed or failed.
- Artifact/configuration identifiers, selected checkpoint, and relevant metrics.
- Listening observations and measured hardware results where applicable.
- Outstanding limitations and the next ready task ID.

## References and rationale

- [micro:bit hardware](https://tech.microbit.org/hardware/): application processor,
  memory, clock, microphone, and output hardware constraints.
- [RNNoise paper](https://arxiv.org/abs/1709.08243) and
  [author's explanation](https://jmvalin.ca/demo/rnnoise/): motivation for combining
  conventional signal processing with learned band gains and temporal context.
  This plan borrows the principle; it does not claim the complete RNNoise system
  is suitable for micro:bit without adaptation and measurements.
- [SciPy ShortTimeFFT documentation](https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.ShortTimeFFT.html):
  analysis/synthesis windows and overlap-add reconstruction concepts. Useful as
  a reference, not a requirement to add Python to the Rust implementation.
- [SI-SDR paper](https://arxiv.org/abs/1811.02508): complementary signal-quality
  measurement; retain explicit level measurements and listening comparisons.
- [CMSIS-NN](https://github.com/ARM-software/CMSIS-NN): a possible optimized
  embedded-kernel route to investigate, not a selected dependency or an automatic
  conversion path from Burn.
- [VoiceBank-DEMAND-16k dataset](https://huggingface.co/datasets/JacobLinCool/VoiceBank-DEMAND-16k):
  existing paired audio source. Preserve speaker separation and the distinction
  between development validation and final test evaluation.
