{
  # support selecting either a given branch, or a local checkout.
  #
  # Calling this with `--argstr src $(pwd)` will install the version
  # of lorri present in $(pwd).
  src ? "rolling-release",
}:
let
  inherit (builtins) fetchGit hasAttr getAttr trace;

  sources = {
    master = fetchGit {
      url = "https://github.com/target/lorri.git";
      ref = "master";
    };

    rolling-release = fetchGit {
      url = "https://github.com/target/lorri.git";
      ref = "rolling-release";
    };

    local = fetchGit src;
  };

  path = if hasAttr src sources
    then getAttr src sources
    else sources.local;
in (import "${path}/release.nix" { src = path; } )
