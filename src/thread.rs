//! A thread pool for panicking immediately after any monitored threads
//! panic.
//!
//! The key implementation detail is each thread spawned gets a
//! DeathCertificate which sends a message on Drop. This allows us to
//! join a thread once we know it has completed execution, meaning
//! we don't block joining one thread while another thread has panicked
//! already.

use crossbeam_channel as chan;
use std::collections::HashMap;
use std::thread;
use std::thread::ThreadId;

struct DeathCertificate {
    tx: chan::Sender<ThreadId>,
}

impl Drop for DeathCertificate {
    fn drop(&mut self) {
        self.tx
            .send(thread::current().id())
            .expect("failed to send thread shut-down message!");
    }
}

/// A thread pool for joining many threads at once, panicking
/// if any of the threads panicked.
pub struct Pool {
    threads: HashMap<ThreadId, thread::JoinHandle<()>>,
    tx: chan::Sender<ThreadId>,
    rx: chan::Receiver<ThreadId>,
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
    pub fn spawn<N, F, T>(&mut self, name: N, f: F) -> Result<(), std::io::Error>
    where
        N: Into<String>,
        F: FnOnce() -> T,
        F: Send + 'static,
        T: Send + 'static,
    {
        let builder = thread::Builder::new().name(name.into());

        let tx = self.tx.clone();
        let handle = builder.spawn(move || {
            let certificate = DeathCertificate { tx };

            f();
            drop(certificate);
        })?;

        self.threads.insert(handle.thread().id(), handle);

        Ok(())
    }

    /// Attempt to join all threads, and if any of them panicked,
    /// also panic this thread.
    pub fn join_all_or_panic(mut self) {
        loop {
            if self.threads.is_empty() {
                return;
            }

            let thread_id = self
                .rx
                .recv()
                .expect("Failed to receive a ThreadResult, even though there are more threads.");

            let handle = self
                .threads
                .remove(&thread_id)
                .expect("Failed to find thread ID in handle table");

            handle
                .join()
                .expect("Failed to join thread, despite catch_unwind!");
        }
    }
}
