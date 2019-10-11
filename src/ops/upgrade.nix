# support selecting either a given branch, or a local checkout.
#
# Calling this with `--argstr type local --argstr path $(pwd)` will install the version
# of lorri present in $(pwd).
# Calling this with `--argstr type branch --argstr branch rolling-release` will install the
# `rolling-release` branch from the upstream git repository.
{
  # either "branch" or "local"
  type
, # branch of upstream repo, null if type == "local"
  branch ? null
, # path to local repo, null if "type == "branch"
  path ? null
}:

# enum Source { Branch(String), Local(String) }
# for poor people
assert type == "branch" || type == "local";
assert type == "branch" -> path == null && branch != null;
assert type == "local" -> branch == null && path != null;

let
  inherit (builtins) fetchGit hasAttr getAttr trace;

  fetchBranch = branch: fetchGit {
    url = "https://github.com/target/lorri.git";
    ref = branch;
  };

  fetchedSource =
    if type == "branch" then fetchBranch branch
    else if type == "local" then path
    else abort "impossibru";

# TODO: we should use the ${fetchedSource}/default.nix as source in release.nix
in (import "${fetchedSource}/release.nix" { src = fetchedSource; } )
