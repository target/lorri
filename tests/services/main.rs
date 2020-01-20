use lorri::cli::Command;
use lorri::logging;
use lorri::ops::services;
use slog_scope::info;
use std::time::Instant;

#[test]
pub fn service_starts() -> std::io::Result<()> {
    let log = logging::root(1, &Command::Daemon);
    let _guard = slog_scope::set_global_logger(log);

    let tempdir = tempfile::tempdir()?;
    let services_nix = tempdir.as_ref().join("services.nix");
    let file_to_touch = tempdir.as_ref().join("touchit");
    info!("file to touch: {}", file_to_touch.display());
    std::fs::write(
        &services_nix,
        format!(
            r#"[ {{ name = "say hi"; program = "touch"; args = [ "{}" ]; }} ]"#,
            file_to_touch.display()
        ),
    )?;

    let _build_thread = std::thread::spawn(|| services::main(services_nix).unwrap());

    let now = Instant::now();
    let mut file_touched = false;
    while now.elapsed().as_secs() < 60 {
        if file_to_touch.is_file() {
            file_touched = true;
            info!("file touched!");
            break;
        }
        std::thread::sleep(std::time::Duration::from_millis(500));
    }

    info!("stopped waiting");
    assert!(file_touched, "service did not run successfully");

    drop(_build_thread);
    drop(tempdir);
    drop(_guard);
    Ok(())
}
