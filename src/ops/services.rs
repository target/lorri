//! Control development services.

use crate::build_loop::{BuildExitFailure, BuildLoop, BuildResults, Event};
use crate::builder::OutputPaths;
use crate::ops::error::{ok, ExitError, OpResult};
use crate::project::Project;
use crossbeam_channel as chan;
use futures_channel::oneshot;
use futures_util::{
    future::{self, Either},
    stream::{self, Stream, StreamExt},
};
use slog_scope::{debug, error, info, warn};
use std::collections::HashMap;
use std::fmt::Debug;
use std::fs::File;
use std::path::PathBuf;
use std::process::Stdio;
use tokio::io::AsyncBufReadExt;
use tokio::io::BufReader;
use tokio::process::{Child, Command};
use tokio::runtime::Builder;
use tokio::sync::mpsc;

enum Fd {
    Stdout,
    Stderr,
}

#[derive(Deserialize)]
struct Services {
    services: Vec<Service>,
}

#[derive(Clone, Debug, Deserialize, PartialEq, Eq, Hash)]
struct Service {
    name: String,
    program: PathBuf,
    args: Vec<String>,
}

/// See the documentation for lorri::cli::Command::Services.
pub fn main(services_nix: PathBuf) -> OpResult {
    let nix_file = crate::NixFile::Services(
        services_nix
            .canonicalize()
            .expect("failed to canonicalize services nix file path"),
    );
    let mut runtime = Builder::new()
        .threaded_scheduler()
        .enable_all()
        .core_threads(3) // 3 threads are strictly required.
        .build()
        .expect("failed to create threaded runtime");
    match runtime.block_on(main_async(nix_file)) {
        Ok(()) => ok(),
        Err(e) => Err(ExitError::panic(format!("{}", e))),
    }
}

async fn main_async(nix_file: crate::NixFile) -> Result<(), tokio::task::JoinError> {
    let (tx, rx) = chan::unbounded();
    let (service_tx, service_rx) = mpsc::channel(1024);

    // BuildLoop::forever is blocking, so this needs to be wrapped in a tokio::spawn.
    let build_loop = tokio::spawn(async {
        let paths = &crate::ops::get_paths().unwrap();
        let project =
            Project::new(nix_file, &paths.gc_root_dir(), paths.cas_store().clone()).unwrap();

        let mut build_loop = BuildLoop::new(&project);

        // No need to react to pings, hence the `chan::never()`
        build_loop.forever(tx, chan::never());
    });

    // stream::iter is blocking, so this needs to be wrapped in a tokio::spawn.
    let logger = tokio::spawn(async move {
        stream::iter(rx.iter())
            .inspect(|msg| match msg {
                Event::Failure(BuildExitFailure { log_lines }) => {
                    error!("build failure: {:#?}", log_lines)
                }
                _ => debug!("build msg: {:?}", msg),
            })
            .filter_map(|msg| {
                future::ready(match msg {
                    Event::Completed(build) => Some(build),
                    _ => None,
                })
            })
            .for_each(|result| {
                let mut service_tx = service_tx.clone();
                async move { service_tx.send(result).await.unwrap() }
            })
            .await;
    });

    let service_manager = consume_build_results(service_rx);

    match future::join3(build_loop, logger, service_manager).await {
        (Err(e), _, _) => Err(e),
        (_, Err(e), _) => Err(e),
        _ => Ok(()),
    }
}

async fn consume_build_results(build_rx: mpsc::Receiver<BuildResults>) -> ProcessGroup {
    build_rx
        .filter_map(
            |BuildResults {
                 output_paths: OutputPaths { shell_gc_root },
             }| {
                async move {
                    let services_json =
                        PathBuf::from(shell_gc_root.as_os_str()).join("services.json");
                    match read_services(services_json) {
                        Ok(Services { services }) => Some(services),
                        Err(e) => {
                            error!("{}", e);
                            None
                        }
                    }
                }
            },
        )
        .fold(ProcessGroup::default(), |running, services| {
            async move {
                let mut new_group = ProcessGroup::default();
                for proc in diff(running, services) {
                    match proc {
                        ServiceProc::AlreadyRunning(proc) => new_group.adopt(proc),
                        ServiceProc::ToStart(service) => {
                            let (stop, stopped) = oneshot::channel();
                            new_group.insert(service.clone(), stop);
                            tokio::spawn(start_service(service, stopped));
                        }
                    }
                }
                new_group
            }
        })
        .await
}

fn diff(mut running: ProcessGroup, services: Vec<Service>) -> Vec<ServiceProc> {
    let procs = services
        .into_iter()
        .map(|service| match running.take(&service) {
            Some(proc) => {
                debug!("adopting service {:?} from running group", &service);
                ServiceProc::AlreadyRunning(proc)
            }
            None => {
                debug!("spawning service {:?}", &service);
                ServiceProc::ToStart(service)
            }
        })
        .collect::<Vec<_>>();

    drop(running);
    procs
}

fn read_services(path: PathBuf) -> Result<Services, String> {
    let f = File::open(&path).map_err(|e| {
        format!(
            "failed to open services definition '{}' for reading, error: {}",
            path.display(),
            e
        )
    })?;
    serde_json::from_reader(std::io::BufReader::new(f)).map_err(|e| {
        format!(
            "failed to parse '{}' as a list of services, error: {}",
            path.display(),
            e
        )
    })
}

async fn start_service(service: Service, stop: oneshot::Receiver<()>) {
    info!("starting {}", &service.name; "name" => &service.name);
    let mut cmd = Command::new(&service.program);
    cmd.args(&service.args)
        .stdin(Stdio::null())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped());
    match cmd.spawn() {
        Ok(mut child) => {
            let stdout = log_stream(
                BufReader::new(child.stdout.take().unwrap()).lines(),
                service.name.to_string(),
                Fd::Stdout,
            );
            let stderr = log_stream(
                BufReader::new(child.stderr.take().unwrap()).lines(),
                service.name.to_string(),
                Fd::Stderr,
            );
            let cleanup = cleanup(child, service.name, stop);
            future::join3(stdout, stderr, cleanup).await;
        }
        Err(e) => {
            error!("failed to start service {}", &service.name; "name" => &service.name, "cmd" => ?cmd, "error" => ?e)
        }
    }
}

async fn log_stream<'a, L>(mut lines: L, name: String, fd: Fd)
where
    L: Stream<Item = tokio::io::Result<String>> + std::marker::Unpin,
{
    while let Some(Ok(message)) = lines.next().await {
        match fd {
            Fd::Stdout => info!("{}", message; "name" => &name),
            Fd::Stderr => warn!("{}", message; "name" => &name),
        }
    }
}

async fn cleanup(mut child: Child, name: String, cancel: oneshot::Receiver<()>) {
    let operation = future::select(cancel, &mut child).await;

    match operation {
        Either::Left(_) => {
            info!("terminating service {}", &name; "name" => &name);
            child.kill().unwrap()
        }
        Either::Right((status, _)) => {
            let status = status.unwrap();
            info!("service {} exited", &name; "name" => &name);
            let code = status
                .code()
                .map_or("<unknown>".to_string(), |c| format!("{}", c));
            if status.success() {
                warn!("service {} exited", &name; "name" => &name, "code" => code);
            } else {
                error!("service {} exited", &name; "name" => &name, "code" => code);
            }
        }
    };
}

enum ServiceProc {
    AlreadyRunning(ProcessGroupMember),
    ToStart(Service),
}

#[derive(Default, Debug)]
struct ProcessGroup {
    processes: HashMap<Service, oneshot::Sender<()>>,
}

impl ProcessGroup {
    fn insert(&mut self, service: Service, kill: oneshot::Sender<()>) {
        self.processes.insert(service, kill);
    }

    fn take(&mut self, service: &Service) -> Option<ProcessGroupMember> {
        let (service, stop) = self.processes.remove_entry(&service)?;
        Some(ProcessGroupMember(service, stop))
    }

    fn adopt(&mut self, member: ProcessGroupMember) {
        self.processes.insert(member.0, member.1);
    }
}

impl Drop for ProcessGroup {
    fn drop(&mut self) {
        self.processes.drain().for_each(|(service, stop)| {
            if stop.send(()).is_err() {
                debug!(
                    "Failed to send stop message to service: {:#?} (it probably died.)",
                    &service
                );
            }
        });
    }
}

struct ProcessGroupMember(Service, oneshot::Sender<()>);

#[cfg(test)]
mod tests {
    use super::*;
    use tokio::runtime::Runtime;

    #[test]
    fn diff_correct() {
        let (tx1, mut rx1) = oneshot::channel();
        let (tx2, rx2) = oneshot::channel();
        let (tx3, rx3) = oneshot::channel();

        let new_service = |name: &str, program: &str, arg: &str| Service {
            name: name.to_string(),
            args: vec![arg.to_string()],
            program: PathBuf::from(program),
        };
        let service1 = new_service("service1", "arg1", "program1");
        let service2 = new_service("service2", "arg2", "program2");
        let service3 = new_service("service3", "arg3", "program3");

        let running = {
            let mut group = ProcessGroup::default();
            group.insert(service1.clone(), tx1);
            group.insert(service2.clone(), tx2);
            group.insert(service3.clone(), tx3);
            group
        };

        // Service 2: different argument
        let service2_changed = Service {
            args: vec!["arg2_CHANGED".to_string()],
            ..service2
        };
        // Service 3: different program
        let service3_changed = Service {
            program: PathBuf::from("program3_CHANGED"),
            ..service3
        };
        // Service 4: new
        let service4_new = new_service("service4", "program4", "arg4");

        let diff = diff(
            running,
            vec![
                service1.clone(),
                service2_changed.clone(),
                service3_changed.clone(),
                service4_new.clone(),
            ],
        );

        let running_eq = |running: &ServiceProc, service: &Service| {
            if let ServiceProc::AlreadyRunning(ProcessGroupMember(service1, _)) = running {
                assert_eq!(service, service1);
            } else {
                assert!(false, "service should already be running");
            }
        };
        let tostart_eq = |tostart: &ServiceProc, service: &Service| {
            if let ServiceProc::ToStart(service1) = tostart {
                assert_eq!(service, service1);
            } else {
                assert!(false, "service should get started");
            }
        };

        // Check return values
        running_eq(&diff[0], &service1);
        tostart_eq(&diff[1], &service2_changed);
        tostart_eq(&diff[2], &service3_changed);
        tostart_eq(&diff[3], &service4_new);

        // Check stop signals
        assert!(
            rx1.try_recv().unwrap().is_none(),
            "service 1 should not have received a stop signal"
        );
        match Runtime::new().unwrap().block_on(future::join(rx2, rx3)) {
            (Ok(()), Ok(())) => (),
            _ => assert!(
                false,
                "did not successfully receive stop signal for services 2 and 3"
            ),
        };
    }
}
