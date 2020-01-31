# https://github.com/NixOS/nixpkgs/blob/85142b9ad27b5caf614cb99e728e7b67a7bfe481/pkgs/tools/nix/nixpkgs-fmt/default.nix
{ lib, rustPlatform, fetchFromGitHub }:
rustPlatform.buildRustPackage rec {
  pname = "nixpkgs-fmt";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = pname;
    rev = "v${version}";
    sha256 = "1iylldgyvrcarfigpbhicg6j6qyipfiqn7gybza7qajfzyprjqfa";
  };

  cargoSha256 = "04my7dlp76dxs1ydy2sbbca8sp3n62wzdxyc4afcmrg8anb0ghaf";

  meta = with lib; {
    description = "Nix code formatter for nixpkgs";
    homepage = "https://nix-community.github.io/nixpkgs-fmt";
    license = licenses.asl20;
    maintainers = with maintainers; [ zimbatm ];
  };
}
