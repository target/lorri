//! An implementation of BufRead's lines(), but for producing OsString
//!
//! See https://doc.rust-lang.org/src/std/io/mod.rs.html#2241 for
//! the reference implementation.

use std::ffi::OsString;
use std::io::{BufRead, Result};
use std::os::unix::ffi::OsStringExt;

/// An iterator over the OsString lines of an instance of `BufRead`.
#[derive(Debug)]
pub struct Lines<B> {
    buf: B,
}

impl<B: BufRead> Lines<B> {
    /// Returns an iterator over the lines of this reader.
    ///
    /// The iterator returned from this function will yield instances of
    /// `io::Result<OsString>`. Each string returned will
    /// *not* have a newline byte (the 0xA byte) or CRLF (0xD, 0xA bytes)
    /// at the end.
    ///
    /// # Examples
    ///
    /// `std::io::Cursor` is a type that implements `BufRead`. In
    /// this example, we use `Cursor` to iterate over all the lines in a byte
    /// slice.
    ///
    /// ```
    /// use std::io::{self, BufRead};
    /// use std::ffi::{OsStr, OsString};
    /// use std::os::unix::ffi::OsStrExt;
    /// use lorri::osstrlines::Lines;
    ///
    /// let cursor = io::Cursor::new(b"lorem\nipsum\r\ndolor\n\xab\xbc\xcd\xde\xde\xef");
    ///
    /// let mut lines_iter = Lines::from(cursor).map(|l| l.unwrap());
    /// assert_eq!(lines_iter.next(), Some(OsString::from("lorem")));
    /// assert_eq!(lines_iter.next(), Some(OsString::from("ipsum")));
    /// assert_eq!(lines_iter.next(), Some(OsString::from("dolor")));
    /// assert_eq!(lines_iter.next(), Some(OsStr::from_bytes(b"\xab\xbc\xcd\xde\xde\xef").to_owned()));
    /// assert_eq!(lines_iter.next(), None);
    /// ```
    ///
    /// # Errors
    ///
    /// Each line of the iterator has the same error semantics as BufRead::read_until.
    pub fn from(reader: B) -> Lines<B> {
        Lines { buf: reader }
    }
}

impl<B: BufRead> Iterator for Lines<B> {
    type Item = Result<OsString>;

    fn next(&mut self) -> Option<Result<OsString>> {
        let mut buf = vec![];
        match self.buf.read_until(b'\n', &mut buf) {
            Ok(0) => None,
            Ok(_n) => {
                if buf.ends_with(&[b'\n']) {
                    buf.pop();
                    if buf.ends_with(&[b'\r']) {
                        buf.pop();
                    }
                }
                Some(Ok(std::ffi::OsString::from_vec(buf)))
            }
            Err(e) => Some(Err(e)),
        }
    }
}
