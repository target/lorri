{ stdenv, pkgs, fetchFromGitHub, makeWrapper, substituteAll, rustNightly }:

let
  rustPlatform = pkgs.rust.makeRustPlatform {
    rustc = rustNightly.rust;
    cargo = rustNightly.cargo;
  };

in rustPlatform.buildRustPackage rec {
  name = "racer-${version}";
  version = "2.1.22";

  src = fetchFromGitHub {
    owner = "racer-rust";
    repo = "racer";
    rev = "v${version}";
    sha256 = "1n808h4jqxkvpjwmj8jgi4y5is5zvr8vn42mwb3yi13mix32cysa";
  };

  cargoSha256 = "0njaa9vk2i9g1c6sq20b7ls97nl532rfv3is7d8dwz51nrwk6jxs";

  preBuild = ''
    export HOME=$(mktemp -d)
  '';

  preCheck = let
    # add #[ignore] before the given function name
    ignoreTest = name: ''
      sed -e's|\(fn ${name}\)|#[ignore]\n\1|' -i "$(grep -rl '${name}')"
    '';
    # ignore all tests by removing all #[test] lines from a file
    ignoreAllTests = file: ''
      sed -e's|#\[test\]||' -i "${file}"
    '';

  in ''
    cat tests/external.rs
    export RUST_SRC_PATH="${rustNightly.rust-src}/lib/rustlib/src/rust/src/"
    ${# we don’t have rustup in the build environment
    ignoreTest "test_get_rust_src_path_rustup_ok"}
    ${# need an external crate of sorts
    ignoreAllTests "tests/external.rs"}
    ${# same
    ignoreTest "get_completion_in_example_dir"}

    cat tests/external.rs
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    description = "A utility intended to provide Rust code completion for editors and IDEs";
    homepage = https://github.com/racer-rust/racer;
    license = licenses.mit;
    maintainers = with maintainers; [ jagajaga globin ];
    platforms = platforms.all;
  };
}
