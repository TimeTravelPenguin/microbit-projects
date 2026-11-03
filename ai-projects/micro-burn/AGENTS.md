# micro-burn

Read `SPEC.md` before planning or changing this project. It is the implementation
contract; `DATASETS.md` contains the evidence behind the proposed learning task.

- Keep the three parts: reusable Burn library, micro:bit firmware, and Iced GNN app.
- Preserve the acceptance criteria and record material design changes in the spec.
- Distinguish verified dataset facts from proposals. Complete the raw-data audit
  before committing to features, targets, or evaluation splits.
- Do not substitute synthetic relationships or another dataset without explaining
  the change to the user.
- Follow milestone dependencies. The data audit gates model/data decisions;
  independent protocol and hardware work may proceed in parallel. Update evidence
  as work completes; do not mark hardware validation complete from a simulation.
- Keep training independent of Bluetooth availability. Preserve explicit outcome,
  stale-data, reconnection, and alert-acknowledgement semantics.
- Follow the user's Rust naming and spacing preferences. Use `clap` with `derive`
  and `wrap_help` if command-line parsing is needed.
