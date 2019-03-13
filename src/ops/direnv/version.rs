use std::str::FromStr;

#[derive(PartialEq, Eq)]
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
