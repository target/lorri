use std::str::FromStr;

#[derive(PartialEq, Eq, Debug)]
pub struct DirenvVersion(usize, usize, usize);

pub const MIN_DIRENV_VERSION: DirenvVersion = DirenvVersion(2, 19, 2);

/// `"a.b.c"`, e.g. `"2.19.2"`.
impl FromStr for DirenvVersion {
    type Err = ();
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let ss = s.split('.').collect::<Vec<&str>>();
        let parse = |s: &str| s.parse::<usize>().or_else(|_| Err(()));
        match *ss {
            [major, minor, patch] => Ok(DirenvVersion(parse(major)?, parse(minor)?, parse(patch)?)),
            _ => Err(()),
        }
    }
}

impl std::fmt::Display for DirenvVersion {
    fn fmt(&self, fmt: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(fmt, "{}.{}.{}", self.0, self.1, self.2)
    }
}

/// Essentially just semver, first field, then second, then third.
impl Ord for DirenvVersion {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        self.0
            .cmp(&other.0)
            .then(self.1.cmp(&other.1))
            .then(self.2.cmp(&other.2))
    }
}

impl PartialOrd for DirenvVersion {
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
        Some(self.cmp(other))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use proptest::prelude::{prop_assert_eq, proptest};
    use std::cmp::Ordering;

    /// A few trivial orderings
    #[test]
    fn version_ord() {
        fn eq(t1: (usize, usize, usize), t2: (usize, usize, usize), ord: Ordering) {
            assert_eq!(
                DirenvVersion(t1.0, t1.1, t1.2).cmp(&DirenvVersion(t2.0, t2.1, t2.2)),
                ord
            )
        }
        eq((0, 0, 0), (0, 0, 0), Ordering::Equal);
        eq((0, 0, 1), (0, 0, 2), Ordering::Less);
        eq((1, 1, 0), (0, 0, 1), Ordering::Greater);
        eq((0, 0, 1), (1, 0, 0), Ordering::Less);
        eq((5, 0, 1), (1, 0, 0), Ordering::Greater);
    }

    proptest! {
        /// Parsing roundtrip
        #[test]
        fn random_number_parse(maj in 1usize..100, min in 1usize..100, patch in 1usize..100) {
            prop_assert_eq!(
                DirenvVersion::from_str(format!("{}.{}.{}", maj, min, patch).as_str()),
                Ok(DirenvVersion(maj, min, patch))
            )
        }

    }
}
