/// These options correspond to the nix options in `man nix.conf`
/// with the same names, though we only support a subset.
///
/// You can use `.append(other)` to merge another `NixOptions`.
#[derive(Clone)]
pub struct NixOptions {
    /// List of nix `builder` specifications
    ///
    /// * `None` use the ones configured in the nix config
    /// * `Some([])`: use no builders
    /// * `Some(list)`: use exactly `list`
    pub builders: Option<Vec<String>>,
    /// `substituter` hostnames
    ///
    /// * `None`: use the ones configured in the nix config
    /// * `Some([])`: use no substituters
    /// *`Some(list)`: use exactly `list`
    pub substituters: Option<Vec<String>>,
}

impl NixOptions {
    /// No extra options. Empty element.
    pub fn empty() -> Self {
        NixOptions {
            builders: None,
            substituters: None,
        }
    }

    /// Combine the two optional lists, so that they are concatenated
    /// if both are `Some` and otherwise the one that exists is used.
    fn extend_option_vec(v1: &mut Option<Vec<String>>, v2: Option<Vec<String>>) {
        match v1.as_mut() {
            Some(v1) => {
                if let Some(v2) = v2 {
                    v1.extend(v2)
                }
            }
            None => {
                if let Some(v2) = v2 {
                    drop(v1.replace(v2))
                }
            }
        }
    }

    /// Append nix options semantically.
    ///
    /// This means for the extra options:
    /// - The `builders` list is appended to on the right (if both exist),
    ///   otherwise the existing one is used (or `None` if both are `None`).
    /// - Same for `substituters`.
    ///
    /// `empty()` and `append()` form a monoid.
    pub fn append(&mut self, other: Self) {
        Self::extend_option_vec(&mut self.builders, other.builders);
        Self::extend_option_vec(&mut self.substituters, other.substituters);
    }

    /// At the moment there is no distinction between
    /// `nix-instantiate` and `nix-store`)
    pub fn to_nix_arglist(&self) -> Vec<String> {
        let Self {
            ref builders,
            ref substituters,
        } = self;

        let mut builders_vec = match builders {
            Some(bs) => vec![
                "--builders".to_owned(),
                // The --builders argument takes the same format as /etc/nix/machines,
                // which means one line per builder specification.
                bs.join("\n"),
            ],
            None => vec![],
        };

        let substituters_vec = match substituters {
            Some(ss) => vec![
                // --substituters are joined “by whitespace” according to `man nix.conf`.
                "--substituters".to_owned(),
                ss.join(" "),
            ],
            None => vec![],
        };

        builders_vec.extend(substituters_vec);
        builders_vec
    }
}
