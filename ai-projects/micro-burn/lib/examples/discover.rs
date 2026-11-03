//! List real training pagers without creating a model or connecting automatically.

use std::time::{Duration, Instant};

use micro_burn::host::Monitor;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut monitor = Monitor::new("Pager discovery", None)?;
    monitor.scan();
    let deadline = Instant::now() + Duration::from_secs(6);

    while Instant::now() < deadline {
        while let Ok(event) = monitor.try_recv() {
            println!("{event:?}");
        }

        std::thread::sleep(Duration::from_millis(50));
    }

    monitor.shutdown()?;
    Ok(())
}
