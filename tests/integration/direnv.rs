use std::collections::hash_map::Keys;
use std::collections::HashMap;

/// The resulting environment Direnv after running Direnv. Note:
/// Direnv returns `{ "varname": null, "varname": "something" }`
/// so the value type is `Option<String>`. This makes `.get()`
/// operations clunky, so be prepared to check for `Some(None)` and
/// `Some(Some("val"))`.
#[derive(Deserialize, Debug)]
pub struct DirenvEnv(HashMap<String, Option<String>>);

impl DirenvEnv {
    /// Get an environment value with a borrowed str in the deepest Option.
    /// Makes asserts nicer, like:
    ///
    ///    assert!(env.get_env("foo"), Value("bar"));
    pub fn get_env<'a, 'b>(&'a self, key: &'b str) -> DirenvValue {
        match self.0.get(key) {
            Some(Some(val)) => DirenvValue::Value(&val),
            Some(None) => DirenvValue::Unset,
            None => DirenvValue::NotSet,
        }
    }

    /// Get the environment variable names defined by direnv
    pub fn keys<'a>(&'a self) -> Keys<'a, String, Option<String>> {
        self.0.keys()
    }
}

/// Environemnt Values from Direnv
#[derive(Debug, PartialEq)]
pub enum DirenvValue<'a> {
    /// This variable will not be modified.
    NotSet,

    /// This variable will be unset when entering direnv.
    Unset,

    /// This variable will be set to exactly.
    Value(&'a str),
}
