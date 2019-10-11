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
  inherit (builtins) fetchGit isFunction;

  fetchBranch = branch: fetchGit {
    url = "https://github.com/target/lorri.git";
    ref = branch;
  };

  fetchedSource =
    if type == "branch" then fetchBranch branch
    else if type == "local" then path
    else abort "impossibru";

  releaseNix = import "${toString fetchedSource}/release.nix";

in
  # backwards-compatibility for older lorri repositories
  # where releaseNix still takes a src attribute.
  # Remove after a while.
if isFunction releaseNix
then releaseNix { src = fetchedSource; }
else releaseNix
