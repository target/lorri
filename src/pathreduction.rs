//! Given a list of paths, reduce them to a minimum set of paths
//! which should be watched for changes.

use std::collections::HashSet;
use std::path::{Path, PathBuf};

#[derive(PartialEq, Debug)]
enum PathReduction {
    Reduced(PathBuf),
    Remove,
}

#[derive(Debug)]
enum ReductionOp {
    Reduction(PathReduction),
    NoOpinion,
}

impl PathReduction {
    fn unwrap(self, msg: &'static str) -> PathBuf {
        match self {
            PathReduction::Reduced(p) => p,
            _ => panic!(msg),
        }
    }
}

/// Reduce one list of paths to another list of paths.
pub fn reduce_paths(paths: &[PathBuf]) -> HashSet<PathBuf> {
    let mut reduced = paths
        .iter()
        .map::<_, _>(|path| {
            let reducers = &[reduce_channel_path, reduce_nix_store_path];

            for reducer in reducers {
                match reducer(path) {
                    ReductionOp::Reduction(r) => {
                        return r;
                    }
                    ReductionOp::NoOpinion => {
                        // next
                    }
                }
            }

            // Default: return a noop reduction
            PathReduction::Reduced(path.clone())
        })
        .filter(|reduction| reduction != &PathReduction::Remove)
        .map(|reduction| reduction.unwrap("previous filter got them"))
        .collect::<HashSet<PathBuf>>()
        .into_iter()
        .collect::<Vec<PathBuf>>();

    // Sort by length so we automatically select project roots when
    // possible, in the next fold.
    reduced.sort();
    reduced
        .into_iter()
        .fold::<HashSet<PathBuf>, _>(HashSet::new(), |mut set, new_path| {
            if set.iter().any(|path| new_path.starts_with(path)) {
                set
            } else {
                set.insert(new_path);
                set
            }
        })
}

/// Reduce a path coming from a user's channel to the location where
/// the channel becomes switchable.
///
/// In other words, given the following path we want to return parts
/// A and B.
///
/// ```text
///
///                                       B               D
///                                    ___|___          __|__
///     /nix/var/nix/profiles/per-user/theuser/channels/nixos/default.nix
///     ^------------- A ------------^         -- C --       ----- E ----
///
/// (A) is the per-user profile prefix, where each user can define
///     their user's nix-env profiles and channel versions within a
///     user-owned subdirectory.
///
/// (B) the user's dedicated directory, they control the contents.
///
///    Among other things, this directory will contain `channels`
///    symlinks:
///
///          channels -> channels-4-link
///          channels-2-link -> /nix/store/...-user-environment
///          channels-3-link -> /nix/store/...-user-environment
///          channels-4-link -> /nix/store/...-user-environment
///
///    each `channels-*` link points to a different set of channel
///    versions, and the `channels` link is atomically updated when
///    the versions change.
///
/// (C) `channels` is a symlink to the currently selected set of
///      channel versions. The target of `channels` is always a Nix
///      store path and thus its contents never change.
///
/// (D) This is the name of the imported channel.
///
///    Ideally, we could just watch on this segment, but as noted in
///    (C) it never changes.
///
/// (E) Sub-path to exactly what file was looked at.
fn reduce_channel_path(path: &PathBuf) -> ReductionOp {
    let nix_profile = Path::new("/nix/var/nix/profiles/per-user");

    // example path: /nix/var/nix/profiles/per-user/root/channels/nixos/....
    //     segments: 1 2   3   4     5         6     7       8      9    10
    let channel_version_root_segments = 9;

    if !path.starts_with(nix_profile) {
        return ReductionOp::NoOpinion;
    }

    // channel_root_path will contain:
    //     /nix/var/nix/profiles/per-user/root/channels/nixos
    let channel_root_path = path
        .iter()
        .take(channel_version_root_segments)
        .map(Path::new)
        .collect::<PathBuf>();

    // Check to see that the channel's root canonicalizes to the same
    // root the full path resolves to. If so, simplify to
    // the directory containing the swapped channel symlink.
    let canonical_channel_location = channel_root_path.canonicalize().unwrap();
    let canonical_path_location = path.canonicalize().unwrap();
    if canonical_path_location.starts_with(&canonical_channel_location) {
        let reduce_to = channel_root_path
            .parent()
            .expect("expected /nix/var/nix/profiles/per-user/root/channels")
            .parent()
            .expect("expected /nix/var/nix/profiles/per-user/root");
        ReductionOp::Reduction(PathReduction::Reduced(reduce_to.to_path_buf()))
    } else {
        ReductionOp::NoOpinion
    }
}

/// Reduce a nix store path to its /nix/store/hash-name root
/// accounting for the fact that a store path can have impure
/// symlinks inside of it.
///
/// Note that because store paths are immutable, these paths can
/// be discarded.
fn reduce_nix_store_path(path: &PathBuf) -> ReductionOp {
    let nix_store = Path::new("/nix/store");

    // This is only a valid reduction if the Nix store path
    // does not contain a symlink to a location out of the Nix store.
    // Because of that, we check that it starts with /nix/store before
    // and after making it canonical.
    if !path.starts_with(nix_store) {
        return ReductionOp::NoOpinion;
    }

    if let Ok(path) = path.canonicalize() {
        // Verify the path still starts with /nix/store
        // (see the prior comment block)
        if path.starts_with(nix_store) {
            return ReductionOp::Reduction(PathReduction::Remove);
        }
    }

    ReductionOp::NoOpinion
}
