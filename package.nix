# Generate a source archive for lorri.
#
# Usage:
#   $ package=$(nix-build package.nix)
#   $ cd $(mktemp -d)
#   $ tar -xvzf $package
#   $ chmod -R u+w src/ # required for generated code
#   $ nix-shell -p cargo rustfmt --run 'cargo build'
#
# The sources are taken from the current directory by default. Only files under
# version control are included in the archive.
#
# In addition to source files under version control, the archive contains:
# - VERSION: a file containing the number of commits ("revcount") of the
#   current state of the repository.
# - RUNTIME_CLOSURE: a file containing the path of the nix file with lorri's
#   runtime closure.

{ pkgs ? import ./nix/nixpkgs.nix

  # Use the current directory as the source directory by default. The filter is
  # strictly an optimisation: we don't want to copy the "target" directory in the
  # nix store. This directory will not be included in the archive either way
  # since we only include files listed by `git ls-files` in the archive.
, src ? builtins.filterSource (path: type: type != "directory" || baseNameOf path != "target") ./.
, closure ? pkgs.callPackage ./nix/runtime.nix {}
}:
let
  # Drop first n characters from string s
  drop = n: s: builtins.substring n (builtins.stringLength s) s;

  # Contains the current version of lorri (the "revcount").
  version = pkgs.runCommandLocal "lorri-version" {
    inherit src;
    passAsFile = [ "src" ];
    buildInputs = with pkgs; [ git ];
  }
    ''
      git -C $(cat $srcPath) log --pretty=%h | wc -l > $out
    '';

  # Contains the runtime closure.
  runtimeClosure = pkgs.runCommandLocal "lorri-runtime-closure" {
    inherit closure;
    passAsFile = [ "closure" ];
    buildInputs = with pkgs; [ git ];
  }
    ''
      echo $(cat $closurePath) > $out
    '';
in
pkgs.runCommandLocal "lorri-src.tar.gz" {
  inherit src closure;
  passAsFile = [ "src" "closure" ];
  buildInputs = with pkgs; [ git gnutar gzip ];
}
  ''
    srcPath=$(cat $srcPath)
    closurePath=$(cat $closurePath)

    tarfile=$(mktemp)

    # Include all files under version control.
    tar -C $srcPath -cvf $tarfile $(git -C $srcPath ls-files)

    # Include the version, call it "VERSION".
    tar --transform="s:${drop 1 version}:VERSION:" -rvf $tarfile ${version}

    # Include the runtime closure, call it "RUNTIME_CLOSURE".
    tar --transform="s:''${closurePath#?}:RUNTIME_CLOSURE:" -rvf $tarfile $closurePath

    gzip -c $tarfile > $out
  ''
