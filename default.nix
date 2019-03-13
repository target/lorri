{
  pkgs ? import ./nix/nixpkgs.nix { enableMozillaOverlay = false; },
  src ? builtins.fetchGit {
    url = ./.;
    ref = "HEAD";
  }
}:
pkgs.rustPlatform.buildRustPackage rec {
  name = "lorri";

  inherit src;

  BUILD_REV_COUNT = src.revCount or 1;

  cargoSha256 = "04v9k81rvnv3n3n5s1jwqxgq1sw83iim322ki28q1qp5m5z7canv";

  NIX_PATH = "nixpkgs=${./nix/bogus-nixpkgs}";

  nativeBuildInputs = [ ];
  buildInputs = [ pkgs.nix ] ++ pkgs.stdenv.lib.optionals pkgs.stdenv.isDarwin [
    pkgs.darwin.cf-private
    pkgs.darwin.Security
    pkgs.darwin.apple_sdk.frameworks.CoreServices
  ];

  preCheck = ''
    . ${./nix/pre-check.sh}
  '';

  # Darwin fails to build doctests with:
  # dyld: Symbol not found __ZTIN4llvm2cl18GenericOptionValueE
  # see: https://github.com/NixOS/nixpkgs/pull/49839
  doCheck = !pkgs.stdenv.isDarwin;
}
