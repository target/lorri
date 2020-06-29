//! A thread pool for panicking immediately after any monitored threads
//! panic.
//!
//! The key implementation detail is each thread spawned gets a
//! DeathCertificate which sends a message on Drop. This allows us to
//! join a thread once we know it has completed execution, meaning
//! we don't block joining one thread while another thread has panicked
//! already.

use crossbeam_channel as chan;
use std::any::Any;
use std::collections::HashMap;
use std::thread;
use std::thread::ThreadId;

struct Thread {
    name: String,
    join_handle: thread::JoinHandle<()>,
}

struct Dead {
    thread_id: ThreadId,
    cause: Cause,
}

enum Cause {
    Natural,
    Paniced(Box<dyn Any + Send>),
}

/// A thread pool for joining many threads at once, panicking
/// if any of the threads panicked.
pub struct Pool {
    threads: HashMap<ThreadId, Thread>,
    tx: chan::Sender<Dead>,
    rx: chan::Receiver<Dead>,
}

impl Default for Pool {
    fn default() -> Self {
        let (tx, rx) = chan::unbounded();
        Pool {
            threads: HashMap::new(),
            tx,
            rx,
        }
    }
}

impl Pool {
    /// Construct a new thread pool.
    /// ```should_panic
    /// extern crate lorri;
    /// use lorri::thread::Pool;
    /// let mut pool = Pool::new();
    /// pool.spawn("example-1", || panic!("Whoops!"));
    /// pool.join_all_or_panic();
    /// ```
    pub fn new() -> Pool {
        Self::default()
    }

    /// Spawn a sub-thread which is joined at the same time as all the
    /// remaining threads.
    pub fn spawn<N, F>(&mut self, name: N, f: F) -> Result<(), std::io::Error>
    where
        N: Into<String>,
        F: FnOnce() -> () + std::panic::UnwindSafe,
        F: Send + 'static,
    {
        let name = name.into();
        let builder = thread::Builder::new().name(name.clone());

        let tx = self.tx.clone();
        let handle = builder.spawn(move || {
            let thread_id = thread::current().id();
            let cause = match std::panic::catch_unwind(|| f()) {
                Ok(()) => Cause::Natural,
                Err(panic) => Cause::Paniced(panic),
            };
            tx.send(Dead { thread_id, cause })
                .expect("failed to send thread shut-down message!")
        })?;

        self.threads.insert(
            handle.thread().id(),
            Thread {
                name,
                join_handle: handle,
            },
        );

        Ok(())
    }

    /// Attempt to join all threads, and if any of them panicked,
    /// also panic this thread.
    pub fn join_all_or_panic(mut self) {
        loop {
            if self.threads.is_empty() {
                return;
            }

            let death = self
                .rx
                .recv()
                .expect("thread pool: Failed to receive a ThreadResult, even though there are more threads.");

            let thread = self
                .threads
                .remove(&death.thread_id)
                .expect("thread pool: Failed to find thread ID in handle table");

            let name = thread.name;
            thread
                .join_handle
                .join()
                // If the thread panics without an unwindable panic,
                // there’s nothing we can do here.
                // Otherwise the stack is unrolled via Cause::Paniced
                .unwrap_or_else(|_any| {
                    panic!(
                        "thread pool: thread {} paniced and we were unable to unwind it",
                        name
                    )
                });

            match death.cause {
                Cause::Natural => {}
                Cause::Paniced(panic) => std::panic::resume_unwind(panic),
            }
        }
    }
}
