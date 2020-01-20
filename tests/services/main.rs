use lorri::ops::services;
use std::time::Instant;

#[test]
pub fn service_starts() -> std::io::Result<()> {
    let tempdir = tempfile::tempdir()?;
    let services_nix = tempdir.as_ref().join("services.nix");
    let file_to_touch = tempdir.as_ref().join("touchit");
    std::fs::write(
        &services_nix,
        format!(
            r#"[ {{ name = "say hi"; program = "touch"; args = [ "{}" ]; }} ]"#,
            file_to_touch.display()
        ),
    )?;

    std::thread::spawn(|| services::main(services_nix).unwrap());

    let now = Instant::now();
    let mut file_touched = false;
    while now.elapsed().as_secs() < 10 {
        if file_to_touch.is_file() {
            file_touched = true;
            break;
        }
        std::thread::sleep(std::time::Duration::from_millis(500));
    }

    assert!(file_touched, "service did not run successfully");

    drop(tempdir);
    Ok(())
}
