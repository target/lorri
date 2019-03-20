//! Iterator for timeout_recv()ing and filtering an MPSC channel,
//! while strictly following the timeout.
//!
//! Example:
//!
//!     use std::sync::mpsc::channel;
//!     use std::time::Duration;
//!     use lorri::mpsc::FilterTimeoutIterator;
//!
//!     let (sender, receiver) = channel();
//!     sender.send(String::from("Tag!")).unwrap();
//!     sender.send(String::from("Hello!")).unwrap();
//!
//!     let mut iter = FilterTimeoutIterator::new(
//!         &receiver,
//!         Duration::from_secs(5),
//!         |msg| msg.starts_with("H")
//!     );
//!
//!     assert_eq!(iter.next(), Some(Ok(String::from("Hello!"))));

use std::sync::mpsc::Receiver;
use std::sync::mpsc::RecvError;
use std::sync::mpsc::RecvTimeoutError;
use std::time::{Duration, Instant};

/// A FilterTimeoutIterator is an abstraction over an MPSC Receiver.
///
/// The iterator returns a Some value if a message is selected
/// by the `predicate` function within the duration specified
/// by `timeout`.
///
/// Each call to the iterator's `next()` function will restart
/// the timeout.
///
/// `next()` does not return `None` immediately if a received message
/// is rejected by the `predicate`. Instead, it retries until a
/// relevant message is received or the timeout is reached.
///
/// Because of the timeout, this iterator can return `None`, even if
/// more messages could be received in the future.
///
/// # Basic Example:
///
///     use std::sync::mpsc::channel;
///     use std::time::Duration;
///     use lorri::mpsc::FilterTimeoutIterator;
///
///     let (sender, receiver) = channel();
///     sender.send(String::from("Tag!")).unwrap();
///     sender.send(String::from("Hello!")).unwrap();
///
///     let mut iter = FilterTimeoutIterator::new(
///         &receiver,
///         Duration::from_secs(5),
///         |msg| msg.starts_with("H")
///     );
///
///     assert_eq!(iter.next(), Some(Ok(String::from("Hello!"))));
///
/// # Internal Timeout Semantics
///
/// When `next()` receives a message the message is checked to see if
/// it is filtered in. If the message does not match, the elapsed time
/// spent in `next()` is deducted from the original Duration and a new
/// recieve is attempted with the reduced duration.
///
/// For this reason, a `next()` should never return `None` unless the
/// Duration has elapsed.
///
/// ## Concrete Example
///
///     use std::sync::mpsc::channel;
///     use std::thread;
///     use std::time::Duration;
///     use lorri::mpsc::FilterTimeoutIterator;
///
///     let (sender, receiver) = channel::<String>();
///
///     let thread = thread::spawn(move || {
///        thread::sleep(Duration::from_millis(750));
///         sender.send(String::from("Tag!")).unwrap();
///         thread::sleep(Duration::from_millis(750));
///         sender.send(String::from("Hello!")).unwrap();
///     });
///
///     let mut iter = FilterTimeoutIterator::new(
///         &receiver,
///         Duration::from_secs(1),
///         |msg| msg.starts_with("H")
///     );
///
///     // will return None in 1s because `Tag!` didn't match and `Hello!` won't
///     // arrive in time.
///     assert_eq!(iter.next(), None);
pub struct FilterTimeoutIterator<'a, T, P>
where
    P: Fn(&T) -> bool,
{
    receiver: &'a Receiver<T>,
    predicate: P,
    timeout: Duration,
}

impl<'a, T, P> FilterTimeoutIterator<'a, T, P>
where
    P: Fn(&T) -> bool,
{
    /// Construct a new FilterTimeoutIterator with the specified timeout
    /// duration.
    pub fn new(
        receiver: &'a Receiver<T>,
        timeout: Duration,
        predicate: P,
    ) -> FilterTimeoutIterator<'a, T, P> {
        Self {
            receiver,
            timeout,
            predicate,
        }
    }

    /// Receive an item, and filter.
    fn next_timeout(&self, timeout: Duration) -> Option<Result<T, RecvTimeoutError>> {
        match self.receiver.recv_timeout(timeout) {
            Ok(value) => {
                if (self.predicate)(&value) {
                    Some(Ok(value))
                } else {
                    None
                }
            }
            otherwise => Some(otherwise),
        }
    }
}

impl<'a, T, P> Iterator for FilterTimeoutIterator<'a, T, P>
where
    P: Fn(&T) -> bool,
{
    type Item = Result<T, RecvError>;

    fn next(&mut self) -> Option<Result<T, RecvError>> {
        let mut timeout = self.timeout;
        let start = Instant::now();

        loop {
            if let Some(result) = self.next_timeout(timeout) {
                return match result {
                    Ok(value) => Some(Ok(value)),
                    Err(RecvTimeoutError::Disconnected) => Some(Err(RecvError)),
                    Err(RecvTimeoutError::Timeout) => None,
                };
            } else {
                // Reduce the timeout on each iteration, but if
                // the checked_sub return None (because start is
                // larger than timeout), return None as a timeout.
                timeout = timeout.checked_sub(start.elapsed())?;
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::FilterTimeoutIterator;
    use std::sync::mpsc::channel;
    use std::sync::mpsc::RecvError;
    use std::thread;
    use std::time::{Duration, Instant};

    fn assert_range(duration: Duration, target: Duration, wiggle: Duration) {
        let min = target.checked_sub(wiggle).unwrap_or(Duration::from_secs(0));
        let max = target
            .checked_add(wiggle)
            .expect("target + wiggle should be representable");

        if duration < min || duration > max {
            panic!(
                "Duration {:?} out of range ({:?} - {:?})",
                duration, min, max,
            );
        }
    }

    #[test]
    fn events_passed_properly() {
        let (sender, receiver) = channel();
        sender.send("hello!").unwrap();

        let mut iter = FilterTimeoutIterator::new(&receiver, Duration::from_secs(0), |_| true);

        assert_eq!(iter.next(), Some(Ok("hello!")));
    }

    #[test]
    fn it_does_time_out() {
        let (sender, receiver) = channel::<()>();

        let mut iter = FilterTimeoutIterator::new(&receiver, Duration::from_secs(0), |_| true);

        assert_eq!(iter.next(), None);
        drop(sender); // Important so we don't get a hangup
    }

    #[test]
    fn hangup_errs() {
        let (sender, receiver) = channel::<()>();
        drop(sender); // Force a hangup now

        let mut iter = FilterTimeoutIterator::new(&receiver, Duration::from_secs(0), |_| true);

        assert_eq!(iter.next(), Some(Err(RecvError)));
    }

    #[test]
    fn filter_takes_reasonable_time() {
        let (sender, receiver) = channel::<usize>();

        let start = Instant::now();

        let thread = thread::spawn(move || {
            sender.send(1).unwrap();
            thread::sleep(Duration::from_millis(150));
            sender.send(2).unwrap();
            thread::sleep(Duration::from_millis(150));
            sender.send(3).unwrap();
        });

        let mut iter = FilterTimeoutIterator::new(&receiver, Duration::from_secs(4), |v| {
            println!("{:#?}", v);
            *v > 2
        });

        assert_eq!(iter.next(), Some(Ok(3)));
        assert_range(
            start.elapsed(),
            Duration::from_millis(300),
            Duration::from_millis(75),
        );

        thread.join().unwrap();
    }
}
