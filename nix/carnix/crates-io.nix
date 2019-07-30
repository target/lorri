{ lib, buildRustCrate, buildRustCrateHelpers }:
with buildRustCrateHelpers;
let inherit (lib.lists) fold;
    inherit (lib.attrsets) recursiveUpdate;
in
rec {

# aho-corasick-0.6.10

  crates.aho_corasick."0.6.10" = deps: { features?(features_.aho_corasick."0.6.10" deps {}) }: buildRustCrate {
    crateName = "aho-corasick";
    version = "0.6.10";
    description = "Fast multiple substring searching with finite state machines.";
    authors = [ "Andrew Gallant <jamslam@gmail.com>" ];
    sha256 = "0bhasxfpmfmz1460chwsx59vdld05axvmk1nbp3sd48xav3d108p";
    libName = "aho_corasick";
    crateBin =
      [{  name = "aho-corasick-dot";  path = "src/main.rs"; }];
    dependencies = mapFeatures features ([
      (crates."memchr"."${deps."aho_corasick"."0.6.10"."memchr"}" deps)
    ]);
  };
  features_.aho_corasick."0.6.10" = deps: f: updateFeatures f (rec {
    aho_corasick."0.6.10".default = (f.aho_corasick."0.6.10".default or true);
    memchr."${deps.aho_corasick."0.6.10".memchr}".default = true;
  }) [
    (features_.memchr."${deps."aho_corasick"."0.6.10"."memchr"}" deps)
  ];


# end
# ansi_term-0.11.0

  crates.ansi_term."0.11.0" = deps: { features?(features_.ansi_term."0.11.0" deps {}) }: buildRustCrate {
    crateName = "ansi_term";
    version = "0.11.0";
    description = "Library for ANSI terminal colours and styles (bold, underline)";
    authors = [ "ogham@bsago.me" "Ryan Scheel (Havvy) <ryan.havvy@gmail.com>" "Josh Triplett <josh@joshtriplett.org>" ];
    sha256 = "08fk0p2xvkqpmz3zlrwnf6l8sj2vngw464rvzspzp31sbgxbwm4v";
    dependencies = (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."ansi_term"."0.11.0"."winapi"}" deps)
    ]) else []);
  };
  features_.ansi_term."0.11.0" = deps: f: updateFeatures f (rec {
    ansi_term."0.11.0".default = (f.ansi_term."0.11.0".default or true);
    winapi = fold recursiveUpdate {} [
      { "${deps.ansi_term."0.11.0".winapi}"."consoleapi" = true; }
      { "${deps.ansi_term."0.11.0".winapi}"."errhandlingapi" = true; }
      { "${deps.ansi_term."0.11.0".winapi}"."processenv" = true; }
      { "${deps.ansi_term."0.11.0".winapi}".default = true; }
    ];
  }) [
    (features_.winapi."${deps."ansi_term"."0.11.0"."winapi"}" deps)
  ];


# end
# atty-0.2.11

  crates.atty."0.2.11" = deps: { features?(features_.atty."0.2.11" deps {}) }: buildRustCrate {
    crateName = "atty";
    version = "0.2.11";
    description = "A simple interface for querying atty";
    authors = [ "softprops <d.tangren@gmail.com>" ];
    sha256 = "0by1bj2km9jxi4i4g76zzi76fc2rcm9934jpnyrqd95zw344pb20";
    dependencies = (if kernel == "redox" then mapFeatures features ([
      (crates."termion"."${deps."atty"."0.2.11"."termion"}" deps)
    ]) else [])
      ++ (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
      (crates."libc"."${deps."atty"."0.2.11"."libc"}" deps)
    ]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."atty"."0.2.11"."winapi"}" deps)
    ]) else []);
  };
  features_.atty."0.2.11" = deps: f: updateFeatures f (rec {
    atty."0.2.11".default = (f.atty."0.2.11".default or true);
    libc."${deps.atty."0.2.11".libc}".default = (f.libc."${deps.atty."0.2.11".libc}".default or false);
    termion."${deps.atty."0.2.11".termion}".default = true;
    winapi = fold recursiveUpdate {} [
      { "${deps.atty."0.2.11".winapi}"."consoleapi" = true; }
      { "${deps.atty."0.2.11".winapi}"."minwinbase" = true; }
      { "${deps.atty."0.2.11".winapi}"."minwindef" = true; }
      { "${deps.atty."0.2.11".winapi}"."processenv" = true; }
      { "${deps.atty."0.2.11".winapi}"."winbase" = true; }
      { "${deps.atty."0.2.11".winapi}".default = true; }
    ];
  }) [
    (features_.termion."${deps."atty"."0.2.11"."termion"}" deps)
    (features_.libc."${deps."atty"."0.2.11"."libc"}" deps)
    (features_.winapi."${deps."atty"."0.2.11"."winapi"}" deps)
  ];


# end
# autocfg-0.1.2

  crates.autocfg."0.1.2" = deps: { features?(features_.autocfg."0.1.2" deps {}) }: buildRustCrate {
    crateName = "autocfg";
    version = "0.1.2";
    description = "Automatic cfg for Rust compiler features";
    authors = [ "Josh Stone <cuviper@gmail.com>" ];
    sha256 = "0dv81dwnp1al3j4ffz007yrjv4w1c7hw09gnf0xs3icxiw6qqfs3";
  };
  features_.autocfg."0.1.2" = deps: f: updateFeatures f (rec {
    autocfg."0.1.2".default = (f.autocfg."0.1.2".default or true);
  }) [];


# end
# bincode-1.1.3

  crates.bincode."1.1.3" = deps: { features?(features_.bincode."1.1.3" deps {}) }: buildRustCrate {
    crateName = "bincode";
    version = "1.1.3";
    description = "A binary serialization / deserialization strategy that uses Serde for transforming structs into bytes and vice versa!";
    authors = [ "Ty Overby <ty@pre-alpha.com>" "Francesco Mazzoli <f@mazzo.li>" "David Tolnay <dtolnay@gmail.com>" "Daniel Griffen" ];
    sha256 = "1wx2iz648r6byl523sb2rqizk1qvwrzpf7apjgr8lsnb67p26y1a";
    build = "build.rs";
    dependencies = mapFeatures features ([
      (crates."byteorder"."${deps."bincode"."1.1.3"."byteorder"}" deps)
      (crates."serde"."${deps."bincode"."1.1.3"."serde"}" deps)
    ]);

    buildDependencies = mapFeatures features ([
      (crates."autocfg"."${deps."bincode"."1.1.3"."autocfg"}" deps)
    ]);
    features = mkFeatures (features."bincode"."1.1.3" or {});
  };
  features_.bincode."1.1.3" = deps: f: updateFeatures f (rec {
    autocfg."${deps.bincode."1.1.3".autocfg}".default = true;
    bincode."1.1.3".default = (f.bincode."1.1.3".default or true);
    byteorder."${deps.bincode."1.1.3".byteorder}".default = true;
    serde."${deps.bincode."1.1.3".serde}".default = true;
  }) [
    (features_.byteorder."${deps."bincode"."1.1.3"."byteorder"}" deps)
    (features_.serde."${deps."bincode"."1.1.3"."serde"}" deps)
    (features_.autocfg."${deps."bincode"."1.1.3"."autocfg"}" deps)
  ];


# end
# bit-set-0.5.0

  crates.bit_set."0.5.0" = deps: { features?(features_.bit_set."0.5.0" deps {}) }: buildRustCrate {
    crateName = "bit-set";
    version = "0.5.0";
    description = "A set of bits";
    authors = [ "Alexis Beingessner <a.beingessner@gmail.com>" ];
    sha256 = "1hwar0maz5pb1ggifrqi79hm14ffc75qiac0xy5lvf3vp6y8din1";
    dependencies = mapFeatures features ([
      (crates."bit_vec"."${deps."bit_set"."0.5.0"."bit_vec"}" deps)
    ]);
    features = mkFeatures (features."bit_set"."0.5.0" or {});
  };
  features_.bit_set."0.5.0" = deps: f: updateFeatures f (rec {
    bit_set = fold recursiveUpdate {} [
      { "0.5.0"."std" =
        (f.bit_set."0.5.0"."std" or false) ||
        (f.bit_set."0.5.0".default or false) ||
        (bit_set."0.5.0"."default" or false); }
      { "0.5.0".default = (f.bit_set."0.5.0".default or true); }
    ];
    bit_vec = fold recursiveUpdate {} [
      { "${deps.bit_set."0.5.0".bit_vec}"."nightly" =
        (f.bit_vec."${deps.bit_set."0.5.0".bit_vec}"."nightly" or false) ||
        (bit_set."0.5.0"."nightly" or false) ||
        (f."bit_set"."0.5.0"."nightly" or false); }
      { "${deps.bit_set."0.5.0".bit_vec}"."std" =
        (f.bit_vec."${deps.bit_set."0.5.0".bit_vec}"."std" or false) ||
        (bit_set."0.5.0"."std" or false) ||
        (f."bit_set"."0.5.0"."std" or false); }
      { "${deps.bit_set."0.5.0".bit_vec}".default = (f.bit_vec."${deps.bit_set."0.5.0".bit_vec}".default or false); }
    ];
  }) [
    (features_.bit_vec."${deps."bit_set"."0.5.0"."bit_vec"}" deps)
  ];


# end
# bit-vec-0.5.0

  crates.bit_vec."0.5.0" = deps: { features?(features_.bit_vec."0.5.0" deps {}) }: buildRustCrate {
    crateName = "bit-vec";
    version = "0.5.0";
    description = "A vector of bits";
    authors = [ "Alexis Beingessner <a.beingessner@gmail.com>" ];
    sha256 = "05q0cdrw5b7mjnac3a76f896wr1vm0g041zm9q3fx3n92nr8xvh6";
    features = mkFeatures (features."bit_vec"."0.5.0" or {});
  };
  features_.bit_vec."0.5.0" = deps: f: updateFeatures f (rec {
    bit_vec = fold recursiveUpdate {} [
      { "0.5.0"."std" =
        (f.bit_vec."0.5.0"."std" or false) ||
        (f.bit_vec."0.5.0".default or false) ||
        (bit_vec."0.5.0"."default" or false); }
      { "0.5.0".default = (f.bit_vec."0.5.0".default or true); }
    ];
  }) [];


# end
# bitflags-0.7.0

  crates.bitflags."0.7.0" = deps: { features?(features_.bitflags."0.7.0" deps {}) }: buildRustCrate {
    crateName = "bitflags";
    version = "0.7.0";
    description = "A macro to generate structures which behave like bitflags.\n";
    authors = [ "The Rust Project Developers" ];
    sha256 = "1hr72xg5slm0z4pxs2hiy4wcyx3jva70h58b7mid8l0a4c8f7gn5";
  };
  features_.bitflags."0.7.0" = deps: f: updateFeatures f (rec {
    bitflags."0.7.0".default = (f.bitflags."0.7.0".default or true);
  }) [];


# end
# bitflags-1.0.4

  crates.bitflags."1.0.4" = deps: { features?(features_.bitflags."1.0.4" deps {}) }: buildRustCrate {
    crateName = "bitflags";
    version = "1.0.4";
    description = "A macro to generate structures which behave like bitflags.\n";
    authors = [ "The Rust Project Developers" ];
    sha256 = "1g1wmz2001qmfrd37dnd5qiss5njrw26aywmg6yhkmkbyrhjxb08";
    features = mkFeatures (features."bitflags"."1.0.4" or {});
  };
  features_.bitflags."1.0.4" = deps: f: updateFeatures f (rec {
    bitflags."1.0.4".default = (f.bitflags."1.0.4".default or true);
  }) [];


# end
# byteorder-1.3.1

  crates.byteorder."1.3.1" = deps: { features?(features_.byteorder."1.3.1" deps {}) }: buildRustCrate {
    crateName = "byteorder";
    version = "1.3.1";
    description = "Library for reading/writing numbers in big-endian and little-endian.";
    authors = [ "Andrew Gallant <jamslam@gmail.com>" ];
    sha256 = "1dd46l7fvmxfq90kh6ip1ghsxzzcdybac8f0mh2jivsdv9vy8k4w";
    build = "build.rs";
    features = mkFeatures (features."byteorder"."1.3.1" or {});
  };
  features_.byteorder."1.3.1" = deps: f: updateFeatures f (rec {
    byteorder = fold recursiveUpdate {} [
      { "1.3.1"."std" =
        (f.byteorder."1.3.1"."std" or false) ||
        (f.byteorder."1.3.1".default or false) ||
        (byteorder."1.3.1"."default" or false); }
      { "1.3.1".default = (f.byteorder."1.3.1".default or true); }
    ];
  }) [];


# end
# cc-1.0.37

  crates.cc."1.0.37" = deps: { features?(features_.cc."1.0.37" deps {}) }: buildRustCrate {
    crateName = "cc";
    version = "1.0.37";
    description = "A build-time dependency for Cargo build scripts to assist in invoking the native\nC compiler to compile native C code into a static archive to be linked into Rust\ncode.\n";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    sha256 = "1m5s357yi2amgd0kd8chxdcbnscyxwxifmf5hgv92x5xj56b3shj";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."cc"."1.0.37" or {});
  };
  features_.cc."1.0.37" = deps: f: updateFeatures f (rec {
    cc = fold recursiveUpdate {} [
      { "1.0.37"."rayon" =
        (f.cc."1.0.37"."rayon" or false) ||
        (f.cc."1.0.37".parallel or false) ||
        (cc."1.0.37"."parallel" or false); }
      { "1.0.37".default = (f.cc."1.0.37".default or true); }
    ];
  }) [];


# end
# cfg-if-0.1.6

  crates.cfg_if."0.1.6" = deps: { features?(features_.cfg_if."0.1.6" deps {}) }: buildRustCrate {
    crateName = "cfg-if";
    version = "0.1.6";
    description = "A macro to ergonomically define an item depending on a large number of #[cfg]\nparameters. Structured like an if-else chain, the first matching branch is the\nitem that gets emitted.\n";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    sha256 = "11qrix06wagkplyk908i3423ps9m9np6c4vbcq81s9fyl244xv3n";
  };
  features_.cfg_if."0.1.6" = deps: f: updateFeatures f (rec {
    cfg_if."0.1.6".default = (f.cfg_if."0.1.6".default or true);
  }) [];


# end
# clap-2.32.0

  crates.clap."2.32.0" = deps: { features?(features_.clap."2.32.0" deps {}) }: buildRustCrate {
    crateName = "clap";
    version = "2.32.0";
    description = "A simple to use, efficient, and full featured  Command Line Argument Parser\n";
    authors = [ "Kevin K. <kbknapp@gmail.com>" ];
    sha256 = "1hdjf0janvpjkwrjdjx1mm2aayzr54k72w6mriyr0n5anjkcj1lx";
    dependencies = mapFeatures features ([
      (crates."bitflags"."${deps."clap"."2.32.0"."bitflags"}" deps)
      (crates."textwrap"."${deps."clap"."2.32.0"."textwrap"}" deps)
      (crates."unicode_width"."${deps."clap"."2.32.0"."unicode_width"}" deps)
    ]
      ++ (if features.clap."2.32.0".atty or false then [ (crates.atty."${deps."clap"."2.32.0".atty}" deps) ] else [])
      ++ (if features.clap."2.32.0".strsim or false then [ (crates.strsim."${deps."clap"."2.32.0".strsim}" deps) ] else [])
      ++ (if features.clap."2.32.0".vec_map or false then [ (crates.vec_map."${deps."clap"."2.32.0".vec_map}" deps) ] else []))
      ++ (if !(kernel == "windows") then mapFeatures features ([
    ]
      ++ (if features.clap."2.32.0".ansi_term or false then [ (crates.ansi_term."${deps."clap"."2.32.0".ansi_term}" deps) ] else [])) else []);
    features = mkFeatures (features."clap"."2.32.0" or {});
  };
  features_.clap."2.32.0" = deps: f: updateFeatures f (rec {
    ansi_term."${deps.clap."2.32.0".ansi_term}".default = true;
    atty."${deps.clap."2.32.0".atty}".default = true;
    bitflags."${deps.clap."2.32.0".bitflags}".default = true;
    clap = fold recursiveUpdate {} [
      { "2.32.0"."ansi_term" =
        (f.clap."2.32.0"."ansi_term" or false) ||
        (f.clap."2.32.0".color or false) ||
        (clap."2.32.0"."color" or false); }
      { "2.32.0"."atty" =
        (f.clap."2.32.0"."atty" or false) ||
        (f.clap."2.32.0".color or false) ||
        (clap."2.32.0"."color" or false); }
      { "2.32.0"."clippy" =
        (f.clap."2.32.0"."clippy" or false) ||
        (f.clap."2.32.0".lints or false) ||
        (clap."2.32.0"."lints" or false); }
      { "2.32.0"."color" =
        (f.clap."2.32.0"."color" or false) ||
        (f.clap."2.32.0".default or false) ||
        (clap."2.32.0"."default" or false); }
      { "2.32.0"."strsim" =
        (f.clap."2.32.0"."strsim" or false) ||
        (f.clap."2.32.0".suggestions or false) ||
        (clap."2.32.0"."suggestions" or false); }
      { "2.32.0"."suggestions" =
        (f.clap."2.32.0"."suggestions" or false) ||
        (f.clap."2.32.0".default or false) ||
        (clap."2.32.0"."default" or false); }
      { "2.32.0"."term_size" =
        (f.clap."2.32.0"."term_size" or false) ||
        (f.clap."2.32.0".wrap_help or false) ||
        (clap."2.32.0"."wrap_help" or false); }
      { "2.32.0"."vec_map" =
        (f.clap."2.32.0"."vec_map" or false) ||
        (f.clap."2.32.0".default or false) ||
        (clap."2.32.0"."default" or false); }
      { "2.32.0"."yaml" =
        (f.clap."2.32.0"."yaml" or false) ||
        (f.clap."2.32.0".doc or false) ||
        (clap."2.32.0"."doc" or false); }
      { "2.32.0"."yaml-rust" =
        (f.clap."2.32.0"."yaml-rust" or false) ||
        (f.clap."2.32.0".yaml or false) ||
        (clap."2.32.0"."yaml" or false); }
      { "2.32.0".default = (f.clap."2.32.0".default or true); }
    ];
    strsim."${deps.clap."2.32.0".strsim}".default = true;
    textwrap = fold recursiveUpdate {} [
      { "${deps.clap."2.32.0".textwrap}"."term_size" =
        (f.textwrap."${deps.clap."2.32.0".textwrap}"."term_size" or false) ||
        (clap."2.32.0"."wrap_help" or false) ||
        (f."clap"."2.32.0"."wrap_help" or false); }
      { "${deps.clap."2.32.0".textwrap}".default = true; }
    ];
    unicode_width."${deps.clap."2.32.0".unicode_width}".default = true;
    vec_map."${deps.clap."2.32.0".vec_map}".default = true;
  }) [
    (features_.atty."${deps."clap"."2.32.0"."atty"}" deps)
    (features_.bitflags."${deps."clap"."2.32.0"."bitflags"}" deps)
    (features_.strsim."${deps."clap"."2.32.0"."strsim"}" deps)
    (features_.textwrap."${deps."clap"."2.32.0"."textwrap"}" deps)
    (features_.unicode_width."${deps."clap"."2.32.0"."unicode_width"}" deps)
    (features_.vec_map."${deps."clap"."2.32.0"."vec_map"}" deps)
    (features_.ansi_term."${deps."clap"."2.32.0"."ansi_term"}" deps)
  ];


# end
# cloudabi-0.0.3

  crates.cloudabi."0.0.3" = deps: { features?(features_.cloudabi."0.0.3" deps {}) }: buildRustCrate {
    crateName = "cloudabi";
    version = "0.0.3";
    description = "Low level interface to CloudABI. Contains all syscalls and related types.";
    authors = [ "Nuxi (https://nuxi.nl/) and contributors" ];
    sha256 = "1z9lby5sr6vslfd14d6igk03s7awf91mxpsfmsp3prxbxlk0x7h5";
    libPath = "cloudabi.rs";
    dependencies = mapFeatures features ([
    ]
      ++ (if features.cloudabi."0.0.3".bitflags or false then [ (crates.bitflags."${deps."cloudabi"."0.0.3".bitflags}" deps) ] else []));
    features = mkFeatures (features."cloudabi"."0.0.3" or {});
  };
  features_.cloudabi."0.0.3" = deps: f: updateFeatures f (rec {
    bitflags."${deps.cloudabi."0.0.3".bitflags}".default = true;
    cloudabi = fold recursiveUpdate {} [
      { "0.0.3"."bitflags" =
        (f.cloudabi."0.0.3"."bitflags" or false) ||
        (f.cloudabi."0.0.3".default or false) ||
        (cloudabi."0.0.3"."default" or false); }
      { "0.0.3".default = (f.cloudabi."0.0.3".default or true); }
    ];
  }) [
    (features_.bitflags."${deps."cloudabi"."0.0.3"."bitflags"}" deps)
  ];


# end
# directories-1.0.2

  crates.directories."1.0.2" = deps: { features?(features_.directories."1.0.2" deps {}) }: buildRustCrate {
    crateName = "directories";
    version = "1.0.2";
    description = "A tiny mid-level library that provides platform-specific standard locations of directories for config, cache and other data on Linux, Windows and macOS by leveraging the mechanisms defined by the XDG base/user directory specifications on Linux, the Known Folder API on Windows, and the Standard Directory guidelines on macOS.";
    authors = [ "Simon Ochsenreither <simon@ochsenreither.de>" ];
    sha256 = "07gr8bcs77i8sjr24c9frj9gsbs4csp91s895s5y253qaacqzz0m";
    dependencies = (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
      (crates."libc"."${deps."directories"."1.0.2"."libc"}" deps)
    ]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."directories"."1.0.2"."winapi"}" deps)
    ]) else []);
  };
  features_.directories."1.0.2" = deps: f: updateFeatures f (rec {
    directories."1.0.2".default = (f.directories."1.0.2".default or true);
    libc."${deps.directories."1.0.2".libc}".default = true;
    winapi = fold recursiveUpdate {} [
      { "${deps.directories."1.0.2".winapi}"."knownfolders" = true; }
      { "${deps.directories."1.0.2".winapi}"."objbase" = true; }
      { "${deps.directories."1.0.2".winapi}"."shlobj" = true; }
      { "${deps.directories."1.0.2".winapi}"."winbase" = true; }
      { "${deps.directories."1.0.2".winapi}"."winerror" = true; }
      { "${deps.directories."1.0.2".winapi}".default = true; }
    ];
  }) [
    (features_.libc."${deps."directories"."1.0.2"."libc"}" deps)
    (features_.winapi."${deps."directories"."1.0.2"."winapi"}" deps)
  ];


# end
# env_logger-0.6.0

  crates.env_logger."0.6.0" = deps: { features?(features_.env_logger."0.6.0" deps {}) }: buildRustCrate {
    crateName = "env_logger";
    version = "0.6.0";
    description = "A logging implementation for `log` which is configured via an environment\nvariable.\n";
    authors = [ "The Rust Project Developers" ];
    sha256 = "1k2v2wz2725c7rrxzc05x2jifw3frp0fnsr0p8r4n4jj9j12bkp9";
    dependencies = mapFeatures features ([
      (crates."log"."${deps."env_logger"."0.6.0"."log"}" deps)
    ]
      ++ (if features.env_logger."0.6.0".atty or false then [ (crates.atty."${deps."env_logger"."0.6.0".atty}" deps) ] else [])
      ++ (if features.env_logger."0.6.0".humantime or false then [ (crates.humantime."${deps."env_logger"."0.6.0".humantime}" deps) ] else [])
      ++ (if features.env_logger."0.6.0".regex or false then [ (crates.regex."${deps."env_logger"."0.6.0".regex}" deps) ] else [])
      ++ (if features.env_logger."0.6.0".termcolor or false then [ (crates.termcolor."${deps."env_logger"."0.6.0".termcolor}" deps) ] else []));
    features = mkFeatures (features."env_logger"."0.6.0" or {});
  };
  features_.env_logger."0.6.0" = deps: f: updateFeatures f (rec {
    atty."${deps.env_logger."0.6.0".atty}".default = true;
    env_logger = fold recursiveUpdate {} [
      { "0.6.0"."atty" =
        (f.env_logger."0.6.0"."atty" or false) ||
        (f.env_logger."0.6.0".default or false) ||
        (env_logger."0.6.0"."default" or false); }
      { "0.6.0"."humantime" =
        (f.env_logger."0.6.0"."humantime" or false) ||
        (f.env_logger."0.6.0".default or false) ||
        (env_logger."0.6.0"."default" or false); }
      { "0.6.0"."regex" =
        (f.env_logger."0.6.0"."regex" or false) ||
        (f.env_logger."0.6.0".default or false) ||
        (env_logger."0.6.0"."default" or false); }
      { "0.6.0"."termcolor" =
        (f.env_logger."0.6.0"."termcolor" or false) ||
        (f.env_logger."0.6.0".default or false) ||
        (env_logger."0.6.0"."default" or false); }
      { "0.6.0".default = (f.env_logger."0.6.0".default or true); }
    ];
    humantime."${deps.env_logger."0.6.0".humantime}".default = true;
    log = fold recursiveUpdate {} [
      { "${deps.env_logger."0.6.0".log}"."std" = true; }
      { "${deps.env_logger."0.6.0".log}".default = true; }
    ];
    regex."${deps.env_logger."0.6.0".regex}".default = true;
    termcolor."${deps.env_logger."0.6.0".termcolor}".default = true;
  }) [
    (features_.atty."${deps."env_logger"."0.6.0"."atty"}" deps)
    (features_.humantime."${deps."env_logger"."0.6.0"."humantime"}" deps)
    (features_.log."${deps."env_logger"."0.6.0"."log"}" deps)
    (features_.regex."${deps."env_logger"."0.6.0"."regex"}" deps)
    (features_.termcolor."${deps."env_logger"."0.6.0"."termcolor"}" deps)
  ];


# end
# filetime-0.2.4

  crates.filetime."0.2.4" = deps: { features?(features_.filetime."0.2.4" deps {}) }: buildRustCrate {
    crateName = "filetime";
    version = "0.2.4";
    description = "Platform-agnostic accessors of timestamps in File metadata\n";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    sha256 = "1lsc0qjihr8y56rlzdcldzr0nbljm8qqi691msgwhy6wrkawwx5d";
    dependencies = mapFeatures features ([
      (crates."cfg_if"."${deps."filetime"."0.2.4"."cfg_if"}" deps)
    ])
      ++ (if kernel == "redox" then mapFeatures features ([
      (crates."redox_syscall"."${deps."filetime"."0.2.4"."redox_syscall"}" deps)
    ]) else [])
      ++ (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
      (crates."libc"."${deps."filetime"."0.2.4"."libc"}" deps)
    ]) else []);
  };
  features_.filetime."0.2.4" = deps: f: updateFeatures f (rec {
    cfg_if."${deps.filetime."0.2.4".cfg_if}".default = true;
    filetime."0.2.4".default = (f.filetime."0.2.4".default or true);
    libc."${deps.filetime."0.2.4".libc}".default = true;
    redox_syscall."${deps.filetime."0.2.4".redox_syscall}".default = true;
  }) [
    (features_.cfg_if."${deps."filetime"."0.2.4"."cfg_if"}" deps)
    (features_.redox_syscall."${deps."filetime"."0.2.4"."redox_syscall"}" deps)
    (features_.libc."${deps."filetime"."0.2.4"."libc"}" deps)
  ];


# end
# fnv-1.0.6

  crates.fnv."1.0.6" = deps: { features?(features_.fnv."1.0.6" deps {}) }: buildRustCrate {
    crateName = "fnv";
    version = "1.0.6";
    description = "Fowler–Noll–Vo hash function";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    sha256 = "128mlh23y3gg6ag5h8iiqlcbl59smisdzraqy88ldrf75kbw27ip";
    libPath = "lib.rs";
  };
  features_.fnv."1.0.6" = deps: f: updateFeatures f (rec {
    fnv."1.0.6".default = (f.fnv."1.0.6".default or true);
  }) [];


# end
# fsevent-0.2.17

  crates.fsevent."0.2.17" = deps: { features?(features_.fsevent."0.2.17" deps {}) }: buildRustCrate {
    crateName = "fsevent";
    version = "0.2.17";
    description = "Rust bindings to the fsevent-sys OSX API for file changes notifications";
    authors = [ "Pierre Baillet <pierre@baillet.name>" ];
    sha256 = "0wgn3qyyl7dacxpg3ddbc2hliyjk79pjpck968y03x8mf90hqcyw";
    dependencies = mapFeatures features ([
      (crates."bitflags"."${deps."fsevent"."0.2.17"."bitflags"}" deps)
      (crates."fsevent_sys"."${deps."fsevent"."0.2.17"."fsevent_sys"}" deps)
      (crates."libc"."${deps."fsevent"."0.2.17"."libc"}" deps)
    ]);
  };
  features_.fsevent."0.2.17" = deps: f: updateFeatures f (rec {
    bitflags."${deps.fsevent."0.2.17".bitflags}".default = true;
    fsevent."0.2.17".default = (f.fsevent."0.2.17".default or true);
    fsevent_sys."${deps.fsevent."0.2.17".fsevent_sys}".default = true;
    libc."${deps.fsevent."0.2.17".libc}".default = true;
  }) [
    (features_.bitflags."${deps."fsevent"."0.2.17"."bitflags"}" deps)
    (features_.fsevent_sys."${deps."fsevent"."0.2.17"."fsevent_sys"}" deps)
    (features_.libc."${deps."fsevent"."0.2.17"."libc"}" deps)
  ];


# end
# fsevent-sys-0.1.6

  crates.fsevent_sys."0.1.6" = deps: { features?(features_.fsevent_sys."0.1.6" deps {}) }: buildRustCrate {
    crateName = "fsevent-sys";
    version = "0.1.6";
    description = "Rust bindings to the fsevent OSX API for file changes notifications";
    authors = [ "Pierre Baillet <pierre@baillet.name>" ];
    sha256 = "0zydr8qppn25qlgxgdblwx6qgdvj6f12xp7jjhz72z8wlsgqkm08";
    libPath = "lib.rs";
    libName = "fsevent_sys";
    dependencies = mapFeatures features ([
      (crates."libc"."${deps."fsevent_sys"."0.1.6"."libc"}" deps)
    ]);
  };
  features_.fsevent_sys."0.1.6" = deps: f: updateFeatures f (rec {
    fsevent_sys."0.1.6".default = (f.fsevent_sys."0.1.6".default or true);
    libc."${deps.fsevent_sys."0.1.6".libc}".default = true;
  }) [
    (features_.libc."${deps."fsevent_sys"."0.1.6"."libc"}" deps)
  ];


# end
# fuchsia-cprng-0.1.1

  crates.fuchsia_cprng."0.1.1" = deps: { features?(features_.fuchsia_cprng."0.1.1" deps {}) }: buildRustCrate {
    crateName = "fuchsia-cprng";
    version = "0.1.1";
    description = "Rust crate for the Fuchsia cryptographically secure pseudorandom number generator";
    authors = [ "Erick Tryzelaar <etryzelaar@google.com>" ];
    edition = "2018";
    sha256 = "07apwv9dj716yjlcj29p94vkqn5zmfh7hlrqvrjx3wzshphc95h9";
  };
  features_.fuchsia_cprng."0.1.1" = deps: f: updateFeatures f (rec {
    fuchsia_cprng."0.1.1".default = (f.fuchsia_cprng."0.1.1".default or true);
  }) [];


# end
# fuchsia-zircon-0.3.3

  crates.fuchsia_zircon."0.3.3" = deps: { features?(features_.fuchsia_zircon."0.3.3" deps {}) }: buildRustCrate {
    crateName = "fuchsia-zircon";
    version = "0.3.3";
    description = "Rust bindings for the Zircon kernel";
    authors = [ "Raph Levien <raph@google.com>" ];
    sha256 = "0jrf4shb1699r4la8z358vri8318w4mdi6qzfqy30p2ymjlca4gk";
    dependencies = mapFeatures features ([
      (crates."bitflags"."${deps."fuchsia_zircon"."0.3.3"."bitflags"}" deps)
      (crates."fuchsia_zircon_sys"."${deps."fuchsia_zircon"."0.3.3"."fuchsia_zircon_sys"}" deps)
    ]);
  };
  features_.fuchsia_zircon."0.3.3" = deps: f: updateFeatures f (rec {
    bitflags."${deps.fuchsia_zircon."0.3.3".bitflags}".default = true;
    fuchsia_zircon."0.3.3".default = (f.fuchsia_zircon."0.3.3".default or true);
    fuchsia_zircon_sys."${deps.fuchsia_zircon."0.3.3".fuchsia_zircon_sys}".default = true;
  }) [
    (features_.bitflags."${deps."fuchsia_zircon"."0.3.3"."bitflags"}" deps)
    (features_.fuchsia_zircon_sys."${deps."fuchsia_zircon"."0.3.3"."fuchsia_zircon_sys"}" deps)
  ];


# end
# fuchsia-zircon-sys-0.3.3

  crates.fuchsia_zircon_sys."0.3.3" = deps: { features?(features_.fuchsia_zircon_sys."0.3.3" deps {}) }: buildRustCrate {
    crateName = "fuchsia-zircon-sys";
    version = "0.3.3";
    description = "Low-level Rust bindings for the Zircon kernel";
    authors = [ "Raph Levien <raph@google.com>" ];
    sha256 = "08jp1zxrm9jbrr6l26bjal4dbm8bxfy57ickdgibsqxr1n9j3hf5";
  };
  features_.fuchsia_zircon_sys."0.3.3" = deps: f: updateFeatures f (rec {
    fuchsia_zircon_sys."0.3.3".default = (f.fuchsia_zircon_sys."0.3.3".default or true);
  }) [];


# end
# futures-0.1.25

  crates.futures."0.1.25" = deps: { features?(features_.futures."0.1.25" deps {}) }: buildRustCrate {
    crateName = "futures";
    version = "0.1.25";
    description = "An implementation of futures and streams featuring zero allocations,\ncomposability, and iterator-like interfaces.\n";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    sha256 = "1gdn9z3mi3jjzbxgvawqh90895130c3ydks55rshja0ncpn985q3";
    features = mkFeatures (features."futures"."0.1.25" or {});
  };
  features_.futures."0.1.25" = deps: f: updateFeatures f (rec {
    futures = fold recursiveUpdate {} [
      { "0.1.25"."use_std" =
        (f.futures."0.1.25"."use_std" or false) ||
        (f.futures."0.1.25".default or false) ||
        (futures."0.1.25"."default" or false); }
      { "0.1.25"."with-deprecated" =
        (f.futures."0.1.25"."with-deprecated" or false) ||
        (f.futures."0.1.25".default or false) ||
        (futures."0.1.25"."default" or false); }
      { "0.1.25".default = (f.futures."0.1.25".default or true); }
    ];
  }) [];


# end
# heck-0.3.1

  crates.heck."0.3.1" = deps: { features?(features_.heck."0.3.1" deps {}) }: buildRustCrate {
    crateName = "heck";
    version = "0.3.1";
    description = "heck is a case conversion library.";
    authors = [ "Without Boats <woboats@gmail.com>" ];
    sha256 = "1q7vmnlh62kls6cvkfhbcacxkawaznaqa5wwm9dg1xkcza846c3d";
    dependencies = mapFeatures features ([
      (crates."unicode_segmentation"."${deps."heck"."0.3.1"."unicode_segmentation"}" deps)
    ]);
  };
  features_.heck."0.3.1" = deps: f: updateFeatures f (rec {
    heck."0.3.1".default = (f.heck."0.3.1".default or true);
    unicode_segmentation."${deps.heck."0.3.1".unicode_segmentation}".default = true;
  }) [
    (features_.unicode_segmentation."${deps."heck"."0.3.1"."unicode_segmentation"}" deps)
  ];


# end
# humantime-1.2.0

  crates.humantime."1.2.0" = deps: { features?(features_.humantime."1.2.0" deps {}) }: buildRustCrate {
    crateName = "humantime";
    version = "1.2.0";
    description = "    A parser and formatter for std::time::{Duration, SystemTime}\n";
    authors = [ "Paul Colomiets <paul@colomiets.name>" ];
    sha256 = "0wlcxzz2mhq0brkfbjb12hc6jm17bgm8m6pdgblw4qjwmf26aw28";
    libPath = "src/lib.rs";
    dependencies = mapFeatures features ([
      (crates."quick_error"."${deps."humantime"."1.2.0"."quick_error"}" deps)
    ]);
  };
  features_.humantime."1.2.0" = deps: f: updateFeatures f (rec {
    humantime."1.2.0".default = (f.humantime."1.2.0".default or true);
    quick_error."${deps.humantime."1.2.0".quick_error}".default = true;
  }) [
    (features_.quick_error."${deps."humantime"."1.2.0"."quick_error"}" deps)
  ];


# end
# inotify-0.6.1

  crates.inotify."0.6.1" = deps: { features?(features_.inotify."0.6.1" deps {}) }: buildRustCrate {
    crateName = "inotify";
    version = "0.6.1";
    description = "Idiomatic wrapper for inotify";
    authors = [ "Hanno Braun <mail@hannobraun.de>" "Félix Saparelli <me@passcod.name>" "Cristian Kubis <cristian.kubis@tsunix.de>" "Frank Denis <github@pureftpd.org>" ];
    sha256 = "11p9dkxbrkv95dj13rza066ly36i51hn1li229wy69gxvprsqs23";
    dependencies = mapFeatures features ([
      (crates."bitflags"."${deps."inotify"."0.6.1"."bitflags"}" deps)
      (crates."inotify_sys"."${deps."inotify"."0.6.1"."inotify_sys"}" deps)
      (crates."libc"."${deps."inotify"."0.6.1"."libc"}" deps)
    ]);
    features = mkFeatures (features."inotify"."0.6.1" or {});
  };
  features_.inotify."0.6.1" = deps: f: updateFeatures f (rec {
    bitflags."${deps.inotify."0.6.1".bitflags}".default = true;
    inotify = fold recursiveUpdate {} [
      { "0.6.1"."futures" =
        (f.inotify."0.6.1"."futures" or false) ||
        (f.inotify."0.6.1".stream or false) ||
        (inotify."0.6.1"."stream" or false); }
      { "0.6.1"."mio" =
        (f.inotify."0.6.1"."mio" or false) ||
        (f.inotify."0.6.1".stream or false) ||
        (inotify."0.6.1"."stream" or false); }
      { "0.6.1"."stream" =
        (f.inotify."0.6.1"."stream" or false) ||
        (f.inotify."0.6.1".default or false) ||
        (inotify."0.6.1"."default" or false); }
      { "0.6.1"."tokio-io" =
        (f.inotify."0.6.1"."tokio-io" or false) ||
        (f.inotify."0.6.1".stream or false) ||
        (inotify."0.6.1"."stream" or false); }
      { "0.6.1"."tokio-reactor" =
        (f.inotify."0.6.1"."tokio-reactor" or false) ||
        (f.inotify."0.6.1".stream or false) ||
        (inotify."0.6.1"."stream" or false); }
      { "0.6.1".default = (f.inotify."0.6.1".default or true); }
    ];
    inotify_sys."${deps.inotify."0.6.1".inotify_sys}".default = true;
    libc."${deps.inotify."0.6.1".libc}".default = true;
  }) [
    (features_.bitflags."${deps."inotify"."0.6.1"."bitflags"}" deps)
    (features_.inotify_sys."${deps."inotify"."0.6.1"."inotify_sys"}" deps)
    (features_.libc."${deps."inotify"."0.6.1"."libc"}" deps)
  ];


# end
# inotify-sys-0.1.3

  crates.inotify_sys."0.1.3" = deps: { features?(features_.inotify_sys."0.1.3" deps {}) }: buildRustCrate {
    crateName = "inotify-sys";
    version = "0.1.3";
    description = "inotify bindings for the Rust programming language";
    authors = [ "Hanno Braun <hb@hannobraun.de>" ];
    sha256 = "110bbc9vprrj3cmp5g5v1adfh3wlnlbxqllwfksrlcdv1k3dnv8n";
    dependencies = mapFeatures features ([
      (crates."libc"."${deps."inotify_sys"."0.1.3"."libc"}" deps)
    ]);
  };
  features_.inotify_sys."0.1.3" = deps: f: updateFeatures f (rec {
    inotify_sys."0.1.3".default = (f.inotify_sys."0.1.3".default or true);
    libc."${deps.inotify_sys."0.1.3".libc}".default = true;
  }) [
    (features_.libc."${deps."inotify_sys"."0.1.3"."libc"}" deps)
  ];


# end
# iovec-0.1.2

  crates.iovec."0.1.2" = deps: { features?(features_.iovec."0.1.2" deps {}) }: buildRustCrate {
    crateName = "iovec";
    version = "0.1.2";
    description = "Portable buffer type for scatter/gather I/O operations\n";
    authors = [ "Carl Lerche <me@carllerche.com>" ];
    sha256 = "0vjymmb7wj4v4kza5jjn48fcdb85j3k37y7msjl3ifz0p9yiyp2r";
    dependencies = (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
      (crates."libc"."${deps."iovec"."0.1.2"."libc"}" deps)
    ]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."iovec"."0.1.2"."winapi"}" deps)
    ]) else []);
  };
  features_.iovec."0.1.2" = deps: f: updateFeatures f (rec {
    iovec."0.1.2".default = (f.iovec."0.1.2".default or true);
    libc."${deps.iovec."0.1.2".libc}".default = true;
    winapi."${deps.iovec."0.1.2".winapi}".default = true;
  }) [
    (features_.libc."${deps."iovec"."0.1.2"."libc"}" deps)
    (features_.winapi."${deps."iovec"."0.1.2"."winapi"}" deps)
  ];


# end
# itoa-0.4.3

  crates.itoa."0.4.3" = deps: { features?(features_.itoa."0.4.3" deps {}) }: buildRustCrate {
    crateName = "itoa";
    version = "0.4.3";
    description = "Fast functions for printing integer primitives to an io::Write";
    authors = [ "David Tolnay <dtolnay@gmail.com>" ];
    sha256 = "0zadimmdgvili3gdwxqg7ljv3r4wcdg1kkdfp9nl15vnm23vrhy1";
    features = mkFeatures (features."itoa"."0.4.3" or {});
  };
  features_.itoa."0.4.3" = deps: f: updateFeatures f (rec {
    itoa = fold recursiveUpdate {} [
      { "0.4.3"."std" =
        (f.itoa."0.4.3"."std" or false) ||
        (f.itoa."0.4.3".default or false) ||
        (itoa."0.4.3"."default" or false); }
      { "0.4.3".default = (f.itoa."0.4.3".default or true); }
    ];
  }) [];


# end
# kernel32-sys-0.2.2

  crates.kernel32_sys."0.2.2" = deps: { features?(features_.kernel32_sys."0.2.2" deps {}) }: buildRustCrate {
    crateName = "kernel32-sys";
    version = "0.2.2";
    description = "Contains function definitions for the Windows API library kernel32. See winapi for types and constants.";
    authors = [ "Peter Atashian <retep998@gmail.com>" ];
    sha256 = "1lrw1hbinyvr6cp28g60z97w32w8vsk6pahk64pmrv2fmby8srfj";
    libName = "kernel32";
    build = "build.rs";
    dependencies = mapFeatures features ([
      (crates."winapi"."${deps."kernel32_sys"."0.2.2"."winapi"}" deps)
    ]);

    buildDependencies = mapFeatures features ([
      (crates."winapi_build"."${deps."kernel32_sys"."0.2.2"."winapi_build"}" deps)
    ]);
  };
  features_.kernel32_sys."0.2.2" = deps: f: updateFeatures f (rec {
    kernel32_sys."0.2.2".default = (f.kernel32_sys."0.2.2".default or true);
    winapi."${deps.kernel32_sys."0.2.2".winapi}".default = true;
    winapi_build."${deps.kernel32_sys."0.2.2".winapi_build}".default = true;
  }) [
    (features_.winapi."${deps."kernel32_sys"."0.2.2"."winapi"}" deps)
    (features_.winapi_build."${deps."kernel32_sys"."0.2.2"."winapi_build"}" deps)
  ];


# end
# lazy_static-1.2.0

  crates.lazy_static."1.2.0" = deps: { features?(features_.lazy_static."1.2.0" deps {}) }: buildRustCrate {
    crateName = "lazy_static";
    version = "1.2.0";
    description = "A macro for declaring lazily evaluated statics in Rust.";
    authors = [ "Marvin Löbel <loebel.marvin@gmail.com>" ];
    sha256 = "07p3b30k2akyr6xw08ggd5qiz5nw3vd3agggj360fcc1njz7d0ss";
    dependencies = mapFeatures features ([
    ]
      ++ (if features.lazy_static."1.2.0".spin or false then [ (crates.spin."${deps."lazy_static"."1.2.0".spin}" deps) ] else []));
    features = mkFeatures (features."lazy_static"."1.2.0" or {});
  };
  features_.lazy_static."1.2.0" = deps: f: updateFeatures f (rec {
    lazy_static = fold recursiveUpdate {} [
      { "1.2.0"."spin" =
        (f.lazy_static."1.2.0"."spin" or false) ||
        (f.lazy_static."1.2.0".spin_no_std or false) ||
        (lazy_static."1.2.0"."spin_no_std" or false); }
      { "1.2.0".default = (f.lazy_static."1.2.0".default or true); }
    ];
    spin = fold recursiveUpdate {} [
      { "${deps.lazy_static."1.2.0".spin}"."once" = true; }
      { "${deps.lazy_static."1.2.0".spin}".default = (f.spin."${deps.lazy_static."1.2.0".spin}".default or false); }
    ];
  }) [
    (features_.spin."${deps."lazy_static"."1.2.0"."spin"}" deps)
  ];


# end
# lazycell-1.2.1

  crates.lazycell."1.2.1" = deps: { features?(features_.lazycell."1.2.1" deps {}) }: buildRustCrate {
    crateName = "lazycell";
    version = "1.2.1";
    description = "A library providing a lazily filled Cell struct";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" "Nikita Pekin <contact@nikitapek.in>" ];
    sha256 = "1m4h2q9rgxrgc7xjnws1x81lrb68jll8w3pykx1a9bhr29q2mcwm";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."lazycell"."1.2.1" or {});
  };
  features_.lazycell."1.2.1" = deps: f: updateFeatures f (rec {
    lazycell = fold recursiveUpdate {} [
      { "1.2.1"."clippy" =
        (f.lazycell."1.2.1"."clippy" or false) ||
        (f.lazycell."1.2.1".nightly-testing or false) ||
        (lazycell."1.2.1"."nightly-testing" or false); }
      { "1.2.1"."nightly" =
        (f.lazycell."1.2.1"."nightly" or false) ||
        (f.lazycell."1.2.1".nightly-testing or false) ||
        (lazycell."1.2.1"."nightly-testing" or false); }
      { "1.2.1".default = (f.lazycell."1.2.1".default or true); }
    ];
  }) [];


# end
# libc-0.2.55

  crates.libc."0.2.55" = deps: { features?(features_.libc."0.2.55" deps {}) }: buildRustCrate {
    crateName = "libc";
    version = "0.2.55";
    description = "Raw FFI bindings to platform libraries like libc.\n";
    authors = [ "The Rust Project Developers" ];
    sha256 = "1i3a7q8xpqlxfsyb421warvjwi8lvsxdcx2hzvd12qaxfpkbj3p5";
    build = "build.rs";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."libc"."0.2.55" or {});
  };
  features_.libc."0.2.55" = deps: f: updateFeatures f (rec {
    libc = fold recursiveUpdate {} [
      { "0.2.55"."align" =
        (f.libc."0.2.55"."align" or false) ||
        (f.libc."0.2.55".rustc-dep-of-std or false) ||
        (libc."0.2.55"."rustc-dep-of-std" or false); }
      { "0.2.55"."rustc-std-workspace-core" =
        (f.libc."0.2.55"."rustc-std-workspace-core" or false) ||
        (f.libc."0.2.55".rustc-dep-of-std or false) ||
        (libc."0.2.55"."rustc-dep-of-std" or false); }
      { "0.2.55"."use_std" =
        (f.libc."0.2.55"."use_std" or false) ||
        (f.libc."0.2.55".default or false) ||
        (libc."0.2.55"."default" or false); }
      { "0.2.55".default = (f.libc."0.2.55".default or true); }
    ];
  }) [];


# end
# log-0.4.6

  crates.log."0.4.6" = deps: { features?(features_.log."0.4.6" deps {}) }: buildRustCrate {
    crateName = "log";
    version = "0.4.6";
    description = "A lightweight logging facade for Rust\n";
    authors = [ "The Rust Project Developers" ];
    sha256 = "1nd8dl9mvc9vd6fks5d4gsxaz990xi6rzlb8ymllshmwi153vngr";
    dependencies = mapFeatures features ([
      (crates."cfg_if"."${deps."log"."0.4.6"."cfg_if"}" deps)
    ]);
    features = mkFeatures (features."log"."0.4.6" or {});
  };
  features_.log."0.4.6" = deps: f: updateFeatures f (rec {
    cfg_if."${deps.log."0.4.6".cfg_if}".default = true;
    log."0.4.6".default = (f.log."0.4.6".default or true);
  }) [
    (features_.cfg_if."${deps."log"."0.4.6"."cfg_if"}" deps)
  ];


# end
# md5-0.6.1

  crates.md5."0.6.1" = deps: { features?(features_.md5."0.6.1" deps {}) }: buildRustCrate {
    crateName = "md5";
    version = "0.6.1";
    description = "The package provides the MD5 hash function.";
    authors = [ "Ivan Ukhov <ivan.ukhov@gmail.com>" "Kamal Ahmad <shibe@openmailbox.org>" "Konstantin Stepanov <milezv@gmail.com>" "Lukas Kalbertodt <lukas.kalbertodt@gmail.com>" "Nathan Musoke <nathan.musoke@gmail.com>" "Tony Arcieri <bascule@gmail.com>" "Wim de With <register@dewith.io>" "Yosef Dinerstein <yosefdi@gmail.com>" ];
    sha256 = "0kkg05igb50l4v9c3dxd2mll548gkxqnj97sd2bnq3r433wa82d4";
  };
  features_.md5."0.6.1" = deps: f: updateFeatures f (rec {
    md5."0.6.1".default = (f.md5."0.6.1".default or true);
  }) [];


# end
# memchr-2.2.0

  crates.memchr."2.2.0" = deps: { features?(features_.memchr."2.2.0" deps {}) }: buildRustCrate {
    crateName = "memchr";
    version = "2.2.0";
    description = "Safe interface to memchr.";
    authors = [ "Andrew Gallant <jamslam@gmail.com>" "bluss" ];
    sha256 = "11vwg8iig9jyjxq3n1cq15g29ikzw5l7ar87md54k1aisjs0997p";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."memchr"."2.2.0" or {});
  };
  features_.memchr."2.2.0" = deps: f: updateFeatures f (rec {
    memchr = fold recursiveUpdate {} [
      { "2.2.0"."use_std" =
        (f.memchr."2.2.0"."use_std" or false) ||
        (f.memchr."2.2.0".default or false) ||
        (memchr."2.2.0"."default" or false); }
      { "2.2.0".default = (f.memchr."2.2.0".default or true); }
    ];
  }) [];


# end
# mio-0.6.16

  crates.mio."0.6.16" = deps: { features?(features_.mio."0.6.16" deps {}) }: buildRustCrate {
    crateName = "mio";
    version = "0.6.16";
    description = "Lightweight non-blocking IO";
    authors = [ "Carl Lerche <me@carllerche.com>" ];
    sha256 = "14vyrlmf0w984pi7ad9qvmlfj6vrb0wn6i8ik9j87w5za2r3rban";
    dependencies = mapFeatures features ([
      (crates."iovec"."${deps."mio"."0.6.16"."iovec"}" deps)
      (crates."lazycell"."${deps."mio"."0.6.16"."lazycell"}" deps)
      (crates."log"."${deps."mio"."0.6.16"."log"}" deps)
      (crates."net2"."${deps."mio"."0.6.16"."net2"}" deps)
      (crates."slab"."${deps."mio"."0.6.16"."slab"}" deps)
    ])
      ++ (if kernel == "fuchsia" then mapFeatures features ([
      (crates."fuchsia_zircon"."${deps."mio"."0.6.16"."fuchsia_zircon"}" deps)
      (crates."fuchsia_zircon_sys"."${deps."mio"."0.6.16"."fuchsia_zircon_sys"}" deps)
    ]) else [])
      ++ (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
      (crates."libc"."${deps."mio"."0.6.16"."libc"}" deps)
    ]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."kernel32_sys"."${deps."mio"."0.6.16"."kernel32_sys"}" deps)
      (crates."miow"."${deps."mio"."0.6.16"."miow"}" deps)
      (crates."winapi"."${deps."mio"."0.6.16"."winapi"}" deps)
    ]) else []);
    features = mkFeatures (features."mio"."0.6.16" or {});
  };
  features_.mio."0.6.16" = deps: f: updateFeatures f (rec {
    fuchsia_zircon."${deps.mio."0.6.16".fuchsia_zircon}".default = true;
    fuchsia_zircon_sys."${deps.mio."0.6.16".fuchsia_zircon_sys}".default = true;
    iovec."${deps.mio."0.6.16".iovec}".default = true;
    kernel32_sys."${deps.mio."0.6.16".kernel32_sys}".default = true;
    lazycell."${deps.mio."0.6.16".lazycell}".default = true;
    libc."${deps.mio."0.6.16".libc}".default = true;
    log."${deps.mio."0.6.16".log}".default = true;
    mio = fold recursiveUpdate {} [
      { "0.6.16"."with-deprecated" =
        (f.mio."0.6.16"."with-deprecated" or false) ||
        (f.mio."0.6.16".default or false) ||
        (mio."0.6.16"."default" or false); }
      { "0.6.16".default = (f.mio."0.6.16".default or true); }
    ];
    miow."${deps.mio."0.6.16".miow}".default = true;
    net2."${deps.mio."0.6.16".net2}".default = true;
    slab."${deps.mio."0.6.16".slab}".default = true;
    winapi."${deps.mio."0.6.16".winapi}".default = true;
  }) [
    (features_.iovec."${deps."mio"."0.6.16"."iovec"}" deps)
    (features_.lazycell."${deps."mio"."0.6.16"."lazycell"}" deps)
    (features_.log."${deps."mio"."0.6.16"."log"}" deps)
    (features_.net2."${deps."mio"."0.6.16"."net2"}" deps)
    (features_.slab."${deps."mio"."0.6.16"."slab"}" deps)
    (features_.fuchsia_zircon."${deps."mio"."0.6.16"."fuchsia_zircon"}" deps)
    (features_.fuchsia_zircon_sys."${deps."mio"."0.6.16"."fuchsia_zircon_sys"}" deps)
    (features_.libc."${deps."mio"."0.6.16"."libc"}" deps)
    (features_.kernel32_sys."${deps."mio"."0.6.16"."kernel32_sys"}" deps)
    (features_.miow."${deps."mio"."0.6.16"."miow"}" deps)
    (features_.winapi."${deps."mio"."0.6.16"."winapi"}" deps)
  ];


# end
# mio-extras-2.0.5

  crates.mio_extras."2.0.5" = deps: { features?(features_.mio_extras."2.0.5" deps {}) }: buildRustCrate {
    crateName = "mio-extras";
    version = "2.0.5";
    description = "Extra components for use with Mio";
    authors = [ "Carl Lerche <me@carllerche.com>" "David Hotham" ];
    sha256 = "0h3f488fbqgiigs4zhff75db6afj8hndf7dfw7gw22fg286hfhwq";
    dependencies = mapFeatures features ([
      (crates."lazycell"."${deps."mio_extras"."2.0.5"."lazycell"}" deps)
      (crates."log"."${deps."mio_extras"."2.0.5"."log"}" deps)
      (crates."mio"."${deps."mio_extras"."2.0.5"."mio"}" deps)
      (crates."slab"."${deps."mio_extras"."2.0.5"."slab"}" deps)
    ]);
  };
  features_.mio_extras."2.0.5" = deps: f: updateFeatures f (rec {
    lazycell."${deps.mio_extras."2.0.5".lazycell}".default = true;
    log."${deps.mio_extras."2.0.5".log}".default = true;
    mio."${deps.mio_extras."2.0.5".mio}".default = true;
    mio_extras."2.0.5".default = (f.mio_extras."2.0.5".default or true);
    slab."${deps.mio_extras."2.0.5".slab}".default = true;
  }) [
    (features_.lazycell."${deps."mio_extras"."2.0.5"."lazycell"}" deps)
    (features_.log."${deps."mio_extras"."2.0.5"."log"}" deps)
    (features_.mio."${deps."mio_extras"."2.0.5"."mio"}" deps)
    (features_.slab."${deps."mio_extras"."2.0.5"."slab"}" deps)
  ];


# end
# miow-0.2.1

  crates.miow."0.2.1" = deps: { features?(features_.miow."0.2.1" deps {}) }: buildRustCrate {
    crateName = "miow";
    version = "0.2.1";
    description = "A zero overhead I/O library for Windows, focusing on IOCP and Async I/O\nabstractions.\n";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    sha256 = "14f8zkc6ix7mkyis1vsqnim8m29b6l55abkba3p2yz7j1ibcvrl0";
    dependencies = mapFeatures features ([
      (crates."kernel32_sys"."${deps."miow"."0.2.1"."kernel32_sys"}" deps)
      (crates."net2"."${deps."miow"."0.2.1"."net2"}" deps)
      (crates."winapi"."${deps."miow"."0.2.1"."winapi"}" deps)
      (crates."ws2_32_sys"."${deps."miow"."0.2.1"."ws2_32_sys"}" deps)
    ]);
  };
  features_.miow."0.2.1" = deps: f: updateFeatures f (rec {
    kernel32_sys."${deps.miow."0.2.1".kernel32_sys}".default = true;
    miow."0.2.1".default = (f.miow."0.2.1".default or true);
    net2."${deps.miow."0.2.1".net2}".default = (f.net2."${deps.miow."0.2.1".net2}".default or false);
    winapi."${deps.miow."0.2.1".winapi}".default = true;
    ws2_32_sys."${deps.miow."0.2.1".ws2_32_sys}".default = true;
  }) [
    (features_.kernel32_sys."${deps."miow"."0.2.1"."kernel32_sys"}" deps)
    (features_.net2."${deps."miow"."0.2.1"."net2"}" deps)
    (features_.winapi."${deps."miow"."0.2.1"."winapi"}" deps)
    (features_.ws2_32_sys."${deps."miow"."0.2.1"."ws2_32_sys"}" deps)
  ];


# end
# net2-0.2.33

  crates.net2."0.2.33" = deps: { features?(features_.net2."0.2.33" deps {}) }: buildRustCrate {
    crateName = "net2";
    version = "0.2.33";
    description = "Extensions to the standard library's networking types as proposed in RFC 1158.\n";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    sha256 = "1qnmajafgybj5wyxz9iffa8x5wgbwd2znfklmhqj7vl6lw1m65mq";
    dependencies = mapFeatures features ([
      (crates."cfg_if"."${deps."net2"."0.2.33"."cfg_if"}" deps)
    ])
      ++ (if kernel == "redox" || (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
      (crates."libc"."${deps."net2"."0.2.33"."libc"}" deps)
    ]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."net2"."0.2.33"."winapi"}" deps)
    ]) else []);
    features = mkFeatures (features."net2"."0.2.33" or {});
  };
  features_.net2."0.2.33" = deps: f: updateFeatures f (rec {
    cfg_if."${deps.net2."0.2.33".cfg_if}".default = true;
    libc."${deps.net2."0.2.33".libc}".default = true;
    net2 = fold recursiveUpdate {} [
      { "0.2.33"."duration" =
        (f.net2."0.2.33"."duration" or false) ||
        (f.net2."0.2.33".default or false) ||
        (net2."0.2.33"."default" or false); }
      { "0.2.33".default = (f.net2."0.2.33".default or true); }
    ];
    winapi = fold recursiveUpdate {} [
      { "${deps.net2."0.2.33".winapi}"."handleapi" = true; }
      { "${deps.net2."0.2.33".winapi}"."winsock2" = true; }
      { "${deps.net2."0.2.33".winapi}"."ws2def" = true; }
      { "${deps.net2."0.2.33".winapi}"."ws2ipdef" = true; }
      { "${deps.net2."0.2.33".winapi}"."ws2tcpip" = true; }
      { "${deps.net2."0.2.33".winapi}".default = true; }
    ];
  }) [
    (features_.cfg_if."${deps."net2"."0.2.33"."cfg_if"}" deps)
    (features_.libc."${deps."net2"."0.2.33"."libc"}" deps)
    (features_.winapi."${deps."net2"."0.2.33"."winapi"}" deps)
  ];


# end
# nix-0.14.0

  crates.nix."0.14.0" = deps: { features?(features_.nix."0.14.0" deps {}) }: buildRustCrate {
    crateName = "nix";
    version = "0.14.0";
    description = "Rust friendly bindings to *nix APIs";
    authors = [ "The nix-rust Project Developers" ];
    sha256 = "0rxhq4xjw91jv63w609jjb0h7v7iynsgz3r7mndk1dp9m93yl8cj";
    dependencies = mapFeatures features ([
      (crates."bitflags"."${deps."nix"."0.14.0"."bitflags"}" deps)
      (crates."cfg_if"."${deps."nix"."0.14.0"."cfg_if"}" deps)
      (crates."libc"."${deps."nix"."0.14.0"."libc"}" deps)
      (crates."void"."${deps."nix"."0.14.0"."void"}" deps)
    ])
      ++ (if kernel == "dragonfly" then mapFeatures features ([
]) else [])
      ++ (if kernel == "freebsd" then mapFeatures features ([
]) else []);
  };
  features_.nix."0.14.0" = deps: f: updateFeatures f (rec {
    bitflags."${deps.nix."0.14.0".bitflags}".default = true;
    cfg_if."${deps.nix."0.14.0".cfg_if}".default = true;
    libc."${deps.nix."0.14.0".libc}".default = true;
    nix."0.14.0".default = (f.nix."0.14.0".default or true);
    void."${deps.nix."0.14.0".void}".default = true;
  }) [
    (features_.bitflags."${deps."nix"."0.14.0"."bitflags"}" deps)
    (features_.cfg_if."${deps."nix"."0.14.0"."cfg_if"}" deps)
    (features_.libc."${deps."nix"."0.14.0"."libc"}" deps)
    (features_.void."${deps."nix"."0.14.0"."void"}" deps)
  ];


# end
# notify-4.0.9

  crates.notify."4.0.9" = deps: { features?(features_.notify."4.0.9" deps {}) }: buildRustCrate {
    crateName = "notify";
    version = "4.0.9";
    description = "Cross-platform filesystem notification library";
    authors = [ "Félix Saparelli <me@passcod.name>" "Jorge Israel Peña <jorge.israel.p@gmail.com>" "Michael Maurizi <michael.maurizi@gmail.com>" "Pierre Baillet <oct@zoy.org>" "Joe Wilm <joe@jwilm.com>" "Daniel Faust <hessijames@gmail.com>" ];
    sha256 = "0rfh99piyc11h6snajx8fh4ny781x87mc59sgcg6rkxn1d4mwpqs";
    dependencies = mapFeatures features ([
      (crates."bitflags"."${deps."notify"."4.0.9"."bitflags"}" deps)
      (crates."filetime"."${deps."notify"."4.0.9"."filetime"}" deps)
      (crates."libc"."${deps."notify"."4.0.9"."libc"}" deps)
      (crates."walkdir"."${deps."notify"."4.0.9"."walkdir"}" deps)
    ])
      ++ (if kernel == "linux" then mapFeatures features ([
      (crates."inotify"."${deps."notify"."4.0.9"."inotify"}" deps)
      (crates."mio"."${deps."notify"."4.0.9"."mio"}" deps)
      (crates."mio_extras"."${deps."notify"."4.0.9"."mio_extras"}" deps)
    ]) else [])
      ++ (if kernel == "darwin" then mapFeatures features ([
      (crates."fsevent"."${deps."notify"."4.0.9"."fsevent"}" deps)
      (crates."fsevent_sys"."${deps."notify"."4.0.9"."fsevent_sys"}" deps)
    ]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."kernel32_sys"."${deps."notify"."4.0.9"."kernel32_sys"}" deps)
      (crates."winapi"."${deps."notify"."4.0.9"."winapi"}" deps)
    ]) else []);
    features = mkFeatures (features."notify"."4.0.9" or {});
  };
  features_.notify."4.0.9" = deps: f: updateFeatures f (rec {
    bitflags."${deps.notify."4.0.9".bitflags}".default = true;
    filetime."${deps.notify."4.0.9".filetime}".default = true;
    fsevent."${deps.notify."4.0.9".fsevent}".default = true;
    fsevent_sys."${deps.notify."4.0.9".fsevent_sys}".default = true;
    inotify."${deps.notify."4.0.9".inotify}".default = (f.inotify."${deps.notify."4.0.9".inotify}".default or false);
    kernel32_sys."${deps.notify."4.0.9".kernel32_sys}".default = true;
    libc."${deps.notify."4.0.9".libc}".default = true;
    mio."${deps.notify."4.0.9".mio}".default = true;
    mio_extras."${deps.notify."4.0.9".mio_extras}".default = true;
    notify."4.0.9".default = (f.notify."4.0.9".default or true);
    walkdir."${deps.notify."4.0.9".walkdir}".default = true;
    winapi."${deps.notify."4.0.9".winapi}".default = true;
  }) [
    (features_.bitflags."${deps."notify"."4.0.9"."bitflags"}" deps)
    (features_.filetime."${deps."notify"."4.0.9"."filetime"}" deps)
    (features_.libc."${deps."notify"."4.0.9"."libc"}" deps)
    (features_.walkdir."${deps."notify"."4.0.9"."walkdir"}" deps)
    (features_.inotify."${deps."notify"."4.0.9"."inotify"}" deps)
    (features_.mio."${deps."notify"."4.0.9"."mio"}" deps)
    (features_.mio_extras."${deps."notify"."4.0.9"."mio_extras"}" deps)
    (features_.fsevent."${deps."notify"."4.0.9"."fsevent"}" deps)
    (features_.fsevent_sys."${deps."notify"."4.0.9"."fsevent_sys"}" deps)
    (features_.kernel32_sys."${deps."notify"."4.0.9"."kernel32_sys"}" deps)
    (features_.winapi."${deps."notify"."4.0.9"."winapi"}" deps)
  ];


# end
# num-traits-0.2.6

  crates.num_traits."0.2.6" = deps: { features?(features_.num_traits."0.2.6" deps {}) }: buildRustCrate {
    crateName = "num-traits";
    version = "0.2.6";
    description = "Numeric traits for generic mathematics";
    authors = [ "The Rust Project Developers" ];
    sha256 = "1d20sil9n0wgznd1nycm3yjfj1mzyl41ambb7by1apxlyiil1azk";
    build = "build.rs";
    features = mkFeatures (features."num_traits"."0.2.6" or {});
  };
  features_.num_traits."0.2.6" = deps: f: updateFeatures f (rec {
    num_traits = fold recursiveUpdate {} [
      { "0.2.6"."std" =
        (f.num_traits."0.2.6"."std" or false) ||
        (f.num_traits."0.2.6".default or false) ||
        (num_traits."0.2.6"."default" or false); }
      { "0.2.6".default = (f.num_traits."0.2.6".default or true); }
    ];
  }) [];


# end
# proc-macro2-0.4.27

  crates.proc_macro2."0.4.27" = deps: { features?(features_.proc_macro2."0.4.27" deps {}) }: buildRustCrate {
    crateName = "proc-macro2";
    version = "0.4.27";
    description = "A stable implementation of the upcoming new `proc_macro` API. Comes with an\noption, off by default, to also reimplement itself in terms of the upstream\nunstable API.\n";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    sha256 = "1cp4c40p3hwn2sz72ssqa62gp5n8w4gbamdqvvadzp5l7gxnq95i";
    build = "build.rs";
    dependencies = mapFeatures features ([
      (crates."unicode_xid"."${deps."proc_macro2"."0.4.27"."unicode_xid"}" deps)
    ]);
    features = mkFeatures (features."proc_macro2"."0.4.27" or {});
  };
  features_.proc_macro2."0.4.27" = deps: f: updateFeatures f (rec {
    proc_macro2 = fold recursiveUpdate {} [
      { "0.4.27"."proc-macro" =
        (f.proc_macro2."0.4.27"."proc-macro" or false) ||
        (f.proc_macro2."0.4.27".default or false) ||
        (proc_macro2."0.4.27"."default" or false); }
      { "0.4.27".default = (f.proc_macro2."0.4.27".default or true); }
    ];
    unicode_xid."${deps.proc_macro2."0.4.27".unicode_xid}".default = true;
  }) [
    (features_.unicode_xid."${deps."proc_macro2"."0.4.27"."unicode_xid"}" deps)
  ];


# end
# proptest-0.9.1

  crates.proptest."0.9.1" = deps: { features?(features_.proptest."0.9.1" deps {}) }: buildRustCrate {
    crateName = "proptest";
    version = "0.9.1";
    description = "Hypothesis-like property-based testing and shrinking.\n";
    authors = [ "Jason Lingle" ];
    edition = "2018";
    sha256 = "1bfa14zi87i5v260x7j35ssvwhskxssly11iii0z1mgbca8836wn";
    dependencies = mapFeatures features ([
      (crates."bitflags"."${deps."proptest"."0.9.1"."bitflags"}" deps)
      (crates."byteorder"."${deps."proptest"."0.9.1"."byteorder"}" deps)
      (crates."lazy_static"."${deps."proptest"."0.9.1"."lazy_static"}" deps)
      (crates."num_traits"."${deps."proptest"."0.9.1"."num_traits"}" deps)
      (crates."rand"."${deps."proptest"."0.9.1"."rand"}" deps)
      (crates."rand_chacha"."${deps."proptest"."0.9.1"."rand_chacha"}" deps)
      (crates."rand_xorshift"."${deps."proptest"."0.9.1"."rand_xorshift"}" deps)
    ]
      ++ (if features.proptest."0.9.1".bit-set or false then [ (crates.bit_set."${deps."proptest"."0.9.1".bit_set}" deps) ] else [])
      ++ (if features.proptest."0.9.1".quick-error or false then [ (crates.quick_error."${deps."proptest"."0.9.1".quick_error}" deps) ] else [])
      ++ (if features.proptest."0.9.1".regex-syntax or false then [ (crates.regex_syntax."${deps."proptest"."0.9.1".regex_syntax}" deps) ] else [])
      ++ (if features.proptest."0.9.1".rusty-fork or false then [ (crates.rusty_fork."${deps."proptest"."0.9.1".rusty_fork}" deps) ] else [])
      ++ (if features.proptest."0.9.1".tempfile or false then [ (crates.tempfile."${deps."proptest"."0.9.1".tempfile}" deps) ] else []));
    features = mkFeatures (features."proptest"."0.9.1" or {});
  };
  features_.proptest."0.9.1" = deps: f: updateFeatures f (rec {
    bit_set."${deps.proptest."0.9.1".bit_set}".default = true;
    bitflags."${deps.proptest."0.9.1".bitflags}".default = true;
    byteorder = fold recursiveUpdate {} [
      { "${deps.proptest."0.9.1".byteorder}"."std" =
        (f.byteorder."${deps.proptest."0.9.1".byteorder}"."std" or false) ||
        (proptest."0.9.1"."std" or false) ||
        (f."proptest"."0.9.1"."std" or false); }
      { "${deps.proptest."0.9.1".byteorder}".default = (f.byteorder."${deps.proptest."0.9.1".byteorder}".default or false); }
    ];
    lazy_static = fold recursiveUpdate {} [
      { "${deps.proptest."0.9.1".lazy_static}"."spin_no_std" = true; }
      { "${deps.proptest."0.9.1".lazy_static}".default = (f.lazy_static."${deps.proptest."0.9.1".lazy_static}".default or false); }
    ];
    num_traits = fold recursiveUpdate {} [
      { "${deps.proptest."0.9.1".num_traits}"."std" =
        (f.num_traits."${deps.proptest."0.9.1".num_traits}"."std" or false) ||
        (proptest."0.9.1"."std" or false) ||
        (f."proptest"."0.9.1"."std" or false); }
      { "${deps.proptest."0.9.1".num_traits}".default = (f.num_traits."${deps.proptest."0.9.1".num_traits}".default or false); }
    ];
    proptest = fold recursiveUpdate {} [
      { "0.9.1"."bit-set" =
        (f.proptest."0.9.1"."bit-set" or false) ||
        (f.proptest."0.9.1".default or false) ||
        (proptest."0.9.1"."default" or false) ||
        (f.proptest."0.9.1".default-code-coverage or false) ||
        (proptest."0.9.1"."default-code-coverage" or false); }
      { "0.9.1"."break-dead-code" =
        (f.proptest."0.9.1"."break-dead-code" or false) ||
        (f.proptest."0.9.1".default or false) ||
        (proptest."0.9.1"."default" or false); }
      { "0.9.1"."fork" =
        (f.proptest."0.9.1"."fork" or false) ||
        (f.proptest."0.9.1".default or false) ||
        (proptest."0.9.1"."default" or false) ||
        (f.proptest."0.9.1".default-code-coverage or false) ||
        (proptest."0.9.1"."default-code-coverage" or false) ||
        (f.proptest."0.9.1".timeout or false) ||
        (proptest."0.9.1"."timeout" or false); }
      { "0.9.1"."quick-error" =
        (f.proptest."0.9.1"."quick-error" or false) ||
        (f.proptest."0.9.1".std or false) ||
        (proptest."0.9.1"."std" or false); }
      { "0.9.1"."regex-syntax" =
        (f.proptest."0.9.1"."regex-syntax" or false) ||
        (f.proptest."0.9.1".std or false) ||
        (proptest."0.9.1"."std" or false); }
      { "0.9.1"."rusty-fork" =
        (f.proptest."0.9.1"."rusty-fork" or false) ||
        (f.proptest."0.9.1".fork or false) ||
        (proptest."0.9.1"."fork" or false); }
      { "0.9.1"."std" =
        (f.proptest."0.9.1"."std" or false) ||
        (f.proptest."0.9.1".default or false) ||
        (proptest."0.9.1"."default" or false) ||
        (f.proptest."0.9.1".default-code-coverage or false) ||
        (proptest."0.9.1"."default-code-coverage" or false) ||
        (f.proptest."0.9.1".fork or false) ||
        (proptest."0.9.1"."fork" or false); }
      { "0.9.1"."tempfile" =
        (f.proptest."0.9.1"."tempfile" or false) ||
        (f.proptest."0.9.1".fork or false) ||
        (proptest."0.9.1"."fork" or false); }
      { "0.9.1"."timeout" =
        (f.proptest."0.9.1"."timeout" or false) ||
        (f.proptest."0.9.1".default or false) ||
        (proptest."0.9.1"."default" or false) ||
        (f.proptest."0.9.1".default-code-coverage or false) ||
        (proptest."0.9.1"."default-code-coverage" or false); }
      { "0.9.1".default = (f.proptest."0.9.1".default or true); }
    ];
    quick_error."${deps.proptest."0.9.1".quick_error}".default = true;
    rand = fold recursiveUpdate {} [
      { "${deps.proptest."0.9.1".rand}"."alloc" = true; }
      { "${deps.proptest."0.9.1".rand}"."i128_support" = true; }
      { "${deps.proptest."0.9.1".rand}"."std" =
        (f.rand."${deps.proptest."0.9.1".rand}"."std" or false) ||
        (proptest."0.9.1"."std" or false) ||
        (f."proptest"."0.9.1"."std" or false); }
      { "${deps.proptest."0.9.1".rand}".default = (f.rand."${deps.proptest."0.9.1".rand}".default or false); }
    ];
    rand_chacha."${deps.proptest."0.9.1".rand_chacha}".default = true;
    rand_xorshift."${deps.proptest."0.9.1".rand_xorshift}".default = true;
    regex_syntax."${deps.proptest."0.9.1".regex_syntax}".default = true;
    rusty_fork = fold recursiveUpdate {} [
      { "${deps.proptest."0.9.1".rusty_fork}"."timeout" =
        (f.rusty_fork."${deps.proptest."0.9.1".rusty_fork}"."timeout" or false) ||
        (proptest."0.9.1"."timeout" or false) ||
        (f."proptest"."0.9.1"."timeout" or false); }
      { "${deps.proptest."0.9.1".rusty_fork}".default = (f.rusty_fork."${deps.proptest."0.9.1".rusty_fork}".default or false); }
    ];
    tempfile."${deps.proptest."0.9.1".tempfile}".default = true;
  }) [
    (features_.bit_set."${deps."proptest"."0.9.1"."bit_set"}" deps)
    (features_.bitflags."${deps."proptest"."0.9.1"."bitflags"}" deps)
    (features_.byteorder."${deps."proptest"."0.9.1"."byteorder"}" deps)
    (features_.lazy_static."${deps."proptest"."0.9.1"."lazy_static"}" deps)
    (features_.num_traits."${deps."proptest"."0.9.1"."num_traits"}" deps)
    (features_.quick_error."${deps."proptest"."0.9.1"."quick_error"}" deps)
    (features_.rand."${deps."proptest"."0.9.1"."rand"}" deps)
    (features_.rand_chacha."${deps."proptest"."0.9.1"."rand_chacha"}" deps)
    (features_.rand_xorshift."${deps."proptest"."0.9.1"."rand_xorshift"}" deps)
    (features_.regex_syntax."${deps."proptest"."0.9.1"."regex_syntax"}" deps)
    (features_.rusty_fork."${deps."proptest"."0.9.1"."rusty_fork"}" deps)
    (features_.tempfile."${deps."proptest"."0.9.1"."tempfile"}" deps)
  ];


# end
# quick-error-1.2.2

  crates.quick_error."1.2.2" = deps: { features?(features_.quick_error."1.2.2" deps {}) }: buildRustCrate {
    crateName = "quick-error";
    version = "1.2.2";
    description = "    A macro which makes error types pleasant to write.\n";
    authors = [ "Paul Colomiets <paul@colomiets.name>" "Colin Kiegel <kiegel@gmx.de>" ];
    sha256 = "192a3adc5phgpibgqblsdx1b421l5yg9bjbmv552qqq9f37h60k5";
  };
  features_.quick_error."1.2.2" = deps: f: updateFeatures f (rec {
    quick_error."1.2.2".default = (f.quick_error."1.2.2".default or true);
  }) [];


# end
# quote-0.6.11

  crates.quote."0.6.11" = deps: { features?(features_.quote."0.6.11" deps {}) }: buildRustCrate {
    crateName = "quote";
    version = "0.6.11";
    description = "Quasi-quoting macro quote!(...)";
    authors = [ "David Tolnay <dtolnay@gmail.com>" ];
    sha256 = "0agska77z58cypcq4knayzwx7r7n6m756z1cz9cp2z4sv0b846ga";
    dependencies = mapFeatures features ([
      (crates."proc_macro2"."${deps."quote"."0.6.11"."proc_macro2"}" deps)
    ]);
    features = mkFeatures (features."quote"."0.6.11" or {});
  };
  features_.quote."0.6.11" = deps: f: updateFeatures f (rec {
    proc_macro2 = fold recursiveUpdate {} [
      { "${deps.quote."0.6.11".proc_macro2}"."proc-macro" =
        (f.proc_macro2."${deps.quote."0.6.11".proc_macro2}"."proc-macro" or false) ||
        (quote."0.6.11"."proc-macro" or false) ||
        (f."quote"."0.6.11"."proc-macro" or false); }
      { "${deps.quote."0.6.11".proc_macro2}".default = (f.proc_macro2."${deps.quote."0.6.11".proc_macro2}".default or false); }
    ];
    quote = fold recursiveUpdate {} [
      { "0.6.11"."proc-macro" =
        (f.quote."0.6.11"."proc-macro" or false) ||
        (f.quote."0.6.11".default or false) ||
        (quote."0.6.11"."default" or false); }
      { "0.6.11".default = (f.quote."0.6.11".default or true); }
    ];
  }) [
    (features_.proc_macro2."${deps."quote"."0.6.11"."proc_macro2"}" deps)
  ];


# end
# rand-0.6.5

  crates.rand."0.6.5" = deps: { features?(features_.rand."0.6.5" deps {}) }: buildRustCrate {
    crateName = "rand";
    version = "0.6.5";
    description = "Random number generators and other randomness functionality.\n";
    authors = [ "The Rand Project Developers" "The Rust Project Developers" ];
    sha256 = "0zbck48159aj8zrwzf80sd9xxh96w4f4968nshwjpysjvflimvgb";
    build = "build.rs";
    dependencies = mapFeatures features ([
      (crates."rand_chacha"."${deps."rand"."0.6.5"."rand_chacha"}" deps)
      (crates."rand_core"."${deps."rand"."0.6.5"."rand_core"}" deps)
      (crates."rand_hc"."${deps."rand"."0.6.5"."rand_hc"}" deps)
      (crates."rand_isaac"."${deps."rand"."0.6.5"."rand_isaac"}" deps)
      (crates."rand_jitter"."${deps."rand"."0.6.5"."rand_jitter"}" deps)
      (crates."rand_pcg"."${deps."rand"."0.6.5"."rand_pcg"}" deps)
      (crates."rand_xorshift"."${deps."rand"."0.6.5"."rand_xorshift"}" deps)
    ]
      ++ (if features.rand."0.6.5".rand_os or false then [ (crates.rand_os."${deps."rand"."0.6.5".rand_os}" deps) ] else []))
      ++ (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
      (crates."libc"."${deps."rand"."0.6.5"."libc"}" deps)
    ]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."rand"."0.6.5"."winapi"}" deps)
    ]) else []);

    buildDependencies = mapFeatures features ([
      (crates."autocfg"."${deps."rand"."0.6.5"."autocfg"}" deps)
    ]);
    features = mkFeatures (features."rand"."0.6.5" or {});
  };
  features_.rand."0.6.5" = deps: f: updateFeatures f (rec {
    autocfg."${deps.rand."0.6.5".autocfg}".default = true;
    libc."${deps.rand."0.6.5".libc}".default = (f.libc."${deps.rand."0.6.5".libc}".default or false);
    rand = fold recursiveUpdate {} [
      { "0.6.5"."alloc" =
        (f.rand."0.6.5"."alloc" or false) ||
        (f.rand."0.6.5".std or false) ||
        (rand."0.6.5"."std" or false); }
      { "0.6.5"."packed_simd" =
        (f.rand."0.6.5"."packed_simd" or false) ||
        (f.rand."0.6.5".simd_support or false) ||
        (rand."0.6.5"."simd_support" or false); }
      { "0.6.5"."rand_os" =
        (f.rand."0.6.5"."rand_os" or false) ||
        (f.rand."0.6.5".std or false) ||
        (rand."0.6.5"."std" or false); }
      { "0.6.5"."simd_support" =
        (f.rand."0.6.5"."simd_support" or false) ||
        (f.rand."0.6.5".nightly or false) ||
        (rand."0.6.5"."nightly" or false); }
      { "0.6.5"."std" =
        (f.rand."0.6.5"."std" or false) ||
        (f.rand."0.6.5".default or false) ||
        (rand."0.6.5"."default" or false); }
      { "0.6.5".default = (f.rand."0.6.5".default or true); }
    ];
    rand_chacha."${deps.rand."0.6.5".rand_chacha}".default = true;
    rand_core = fold recursiveUpdate {} [
      { "${deps.rand."0.6.5".rand_core}"."alloc" =
        (f.rand_core."${deps.rand."0.6.5".rand_core}"."alloc" or false) ||
        (rand."0.6.5"."alloc" or false) ||
        (f."rand"."0.6.5"."alloc" or false); }
      { "${deps.rand."0.6.5".rand_core}"."serde1" =
        (f.rand_core."${deps.rand."0.6.5".rand_core}"."serde1" or false) ||
        (rand."0.6.5"."serde1" or false) ||
        (f."rand"."0.6.5"."serde1" or false); }
      { "${deps.rand."0.6.5".rand_core}"."std" =
        (f.rand_core."${deps.rand."0.6.5".rand_core}"."std" or false) ||
        (rand."0.6.5"."std" or false) ||
        (f."rand"."0.6.5"."std" or false); }
      { "${deps.rand."0.6.5".rand_core}".default = true; }
    ];
    rand_hc."${deps.rand."0.6.5".rand_hc}".default = true;
    rand_isaac = fold recursiveUpdate {} [
      { "${deps.rand."0.6.5".rand_isaac}"."serde1" =
        (f.rand_isaac."${deps.rand."0.6.5".rand_isaac}"."serde1" or false) ||
        (rand."0.6.5"."serde1" or false) ||
        (f."rand"."0.6.5"."serde1" or false); }
      { "${deps.rand."0.6.5".rand_isaac}".default = true; }
    ];
    rand_jitter = fold recursiveUpdate {} [
      { "${deps.rand."0.6.5".rand_jitter}"."std" =
        (f.rand_jitter."${deps.rand."0.6.5".rand_jitter}"."std" or false) ||
        (rand."0.6.5"."std" or false) ||
        (f."rand"."0.6.5"."std" or false); }
      { "${deps.rand."0.6.5".rand_jitter}".default = true; }
    ];
    rand_os = fold recursiveUpdate {} [
      { "${deps.rand."0.6.5".rand_os}"."stdweb" =
        (f.rand_os."${deps.rand."0.6.5".rand_os}"."stdweb" or false) ||
        (rand."0.6.5"."stdweb" or false) ||
        (f."rand"."0.6.5"."stdweb" or false); }
      { "${deps.rand."0.6.5".rand_os}"."wasm-bindgen" =
        (f.rand_os."${deps.rand."0.6.5".rand_os}"."wasm-bindgen" or false) ||
        (rand."0.6.5"."wasm-bindgen" or false) ||
        (f."rand"."0.6.5"."wasm-bindgen" or false); }
      { "${deps.rand."0.6.5".rand_os}".default = true; }
    ];
    rand_pcg."${deps.rand."0.6.5".rand_pcg}".default = true;
    rand_xorshift = fold recursiveUpdate {} [
      { "${deps.rand."0.6.5".rand_xorshift}"."serde1" =
        (f.rand_xorshift."${deps.rand."0.6.5".rand_xorshift}"."serde1" or false) ||
        (rand."0.6.5"."serde1" or false) ||
        (f."rand"."0.6.5"."serde1" or false); }
      { "${deps.rand."0.6.5".rand_xorshift}".default = true; }
    ];
    winapi = fold recursiveUpdate {} [
      { "${deps.rand."0.6.5".winapi}"."minwindef" = true; }
      { "${deps.rand."0.6.5".winapi}"."ntsecapi" = true; }
      { "${deps.rand."0.6.5".winapi}"."profileapi" = true; }
      { "${deps.rand."0.6.5".winapi}"."winnt" = true; }
      { "${deps.rand."0.6.5".winapi}".default = true; }
    ];
  }) [
    (features_.rand_chacha."${deps."rand"."0.6.5"."rand_chacha"}" deps)
    (features_.rand_core."${deps."rand"."0.6.5"."rand_core"}" deps)
    (features_.rand_hc."${deps."rand"."0.6.5"."rand_hc"}" deps)
    (features_.rand_isaac."${deps."rand"."0.6.5"."rand_isaac"}" deps)
    (features_.rand_jitter."${deps."rand"."0.6.5"."rand_jitter"}" deps)
    (features_.rand_os."${deps."rand"."0.6.5"."rand_os"}" deps)
    (features_.rand_pcg."${deps."rand"."0.6.5"."rand_pcg"}" deps)
    (features_.rand_xorshift."${deps."rand"."0.6.5"."rand_xorshift"}" deps)
    (features_.autocfg."${deps."rand"."0.6.5"."autocfg"}" deps)
    (features_.libc."${deps."rand"."0.6.5"."libc"}" deps)
    (features_.winapi."${deps."rand"."0.6.5"."winapi"}" deps)
  ];


# end
# rand_chacha-0.1.1

  crates.rand_chacha."0.1.1" = deps: { features?(features_.rand_chacha."0.1.1" deps {}) }: buildRustCrate {
    crateName = "rand_chacha";
    version = "0.1.1";
    description = "ChaCha random number generator\n";
    authors = [ "The Rand Project Developers" "The Rust Project Developers" ];
    sha256 = "0xnxm4mjd7wjnh18zxc1yickw58axbycp35ciraplqdfwn1gffwi";
    build = "build.rs";
    dependencies = mapFeatures features ([
      (crates."rand_core"."${deps."rand_chacha"."0.1.1"."rand_core"}" deps)
    ]);

    buildDependencies = mapFeatures features ([
      (crates."autocfg"."${deps."rand_chacha"."0.1.1"."autocfg"}" deps)
    ]);
  };
  features_.rand_chacha."0.1.1" = deps: f: updateFeatures f (rec {
    autocfg."${deps.rand_chacha."0.1.1".autocfg}".default = true;
    rand_chacha."0.1.1".default = (f.rand_chacha."0.1.1".default or true);
    rand_core."${deps.rand_chacha."0.1.1".rand_core}".default = (f.rand_core."${deps.rand_chacha."0.1.1".rand_core}".default or false);
  }) [
    (features_.rand_core."${deps."rand_chacha"."0.1.1"."rand_core"}" deps)
    (features_.autocfg."${deps."rand_chacha"."0.1.1"."autocfg"}" deps)
  ];


# end
# rand_core-0.3.1

  crates.rand_core."0.3.1" = deps: { features?(features_.rand_core."0.3.1" deps {}) }: buildRustCrate {
    crateName = "rand_core";
    version = "0.3.1";
    description = "Core random number generator traits and tools for implementation.\n";
    authors = [ "The Rand Project Developers" "The Rust Project Developers" ];
    sha256 = "0q0ssgpj9x5a6fda83nhmfydy7a6c0wvxm0jhncsmjx8qp8gw91m";
    dependencies = mapFeatures features ([
      (crates."rand_core"."${deps."rand_core"."0.3.1"."rand_core"}" deps)
    ]);
    features = mkFeatures (features."rand_core"."0.3.1" or {});
  };
  features_.rand_core."0.3.1" = deps: f: updateFeatures f (rec {
    rand_core = fold recursiveUpdate {} [
      { "${deps.rand_core."0.3.1".rand_core}"."alloc" =
        (f.rand_core."${deps.rand_core."0.3.1".rand_core}"."alloc" or false) ||
        (rand_core."0.3.1"."alloc" or false) ||
        (f."rand_core"."0.3.1"."alloc" or false); }
      { "${deps.rand_core."0.3.1".rand_core}"."serde1" =
        (f.rand_core."${deps.rand_core."0.3.1".rand_core}"."serde1" or false) ||
        (rand_core."0.3.1"."serde1" or false) ||
        (f."rand_core"."0.3.1"."serde1" or false); }
      { "${deps.rand_core."0.3.1".rand_core}"."std" =
        (f.rand_core."${deps.rand_core."0.3.1".rand_core}"."std" or false) ||
        (rand_core."0.3.1"."std" or false) ||
        (f."rand_core"."0.3.1"."std" or false); }
      { "${deps.rand_core."0.3.1".rand_core}".default = true; }
      { "0.3.1"."std" =
        (f.rand_core."0.3.1"."std" or false) ||
        (f.rand_core."0.3.1".default or false) ||
        (rand_core."0.3.1"."default" or false); }
      { "0.3.1".default = (f.rand_core."0.3.1".default or true); }
    ];
  }) [
    (features_.rand_core."${deps."rand_core"."0.3.1"."rand_core"}" deps)
  ];


# end
# rand_core-0.4.0

  crates.rand_core."0.4.0" = deps: { features?(features_.rand_core."0.4.0" deps {}) }: buildRustCrate {
    crateName = "rand_core";
    version = "0.4.0";
    description = "Core random number generator traits and tools for implementation.\n";
    authors = [ "The Rand Project Developers" "The Rust Project Developers" ];
    sha256 = "0wb5iwhffibj0pnpznhv1g3i7h1fnhz64s3nz74fz6vsm3q6q3br";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."rand_core"."0.4.0" or {});
  };
  features_.rand_core."0.4.0" = deps: f: updateFeatures f (rec {
    rand_core = fold recursiveUpdate {} [
      { "0.4.0"."alloc" =
        (f.rand_core."0.4.0"."alloc" or false) ||
        (f.rand_core."0.4.0".std or false) ||
        (rand_core."0.4.0"."std" or false); }
      { "0.4.0"."serde" =
        (f.rand_core."0.4.0"."serde" or false) ||
        (f.rand_core."0.4.0".serde1 or false) ||
        (rand_core."0.4.0"."serde1" or false); }
      { "0.4.0"."serde_derive" =
        (f.rand_core."0.4.0"."serde_derive" or false) ||
        (f.rand_core."0.4.0".serde1 or false) ||
        (rand_core."0.4.0"."serde1" or false); }
      { "0.4.0".default = (f.rand_core."0.4.0".default or true); }
    ];
  }) [];


# end
# rand_hc-0.1.0

  crates.rand_hc."0.1.0" = deps: { features?(features_.rand_hc."0.1.0" deps {}) }: buildRustCrate {
    crateName = "rand_hc";
    version = "0.1.0";
    description = "HC128 random number generator\n";
    authors = [ "The Rand Project Developers" ];
    sha256 = "05agb75j87yp7y1zk8yf7bpm66hc0673r3dlypn0kazynr6fdgkz";
    dependencies = mapFeatures features ([
      (crates."rand_core"."${deps."rand_hc"."0.1.0"."rand_core"}" deps)
    ]);
  };
  features_.rand_hc."0.1.0" = deps: f: updateFeatures f (rec {
    rand_core."${deps.rand_hc."0.1.0".rand_core}".default = (f.rand_core."${deps.rand_hc."0.1.0".rand_core}".default or false);
    rand_hc."0.1.0".default = (f.rand_hc."0.1.0".default or true);
  }) [
    (features_.rand_core."${deps."rand_hc"."0.1.0"."rand_core"}" deps)
  ];


# end
# rand_isaac-0.1.1

  crates.rand_isaac."0.1.1" = deps: { features?(features_.rand_isaac."0.1.1" deps {}) }: buildRustCrate {
    crateName = "rand_isaac";
    version = "0.1.1";
    description = "ISAAC random number generator\n";
    authors = [ "The Rand Project Developers" "The Rust Project Developers" ];
    sha256 = "10hhdh5b5sa03s6b63y9bafm956jwilx41s71jbrzl63ccx8lxdq";
    dependencies = mapFeatures features ([
      (crates."rand_core"."${deps."rand_isaac"."0.1.1"."rand_core"}" deps)
    ]);
    features = mkFeatures (features."rand_isaac"."0.1.1" or {});
  };
  features_.rand_isaac."0.1.1" = deps: f: updateFeatures f (rec {
    rand_core = fold recursiveUpdate {} [
      { "${deps.rand_isaac."0.1.1".rand_core}"."serde1" =
        (f.rand_core."${deps.rand_isaac."0.1.1".rand_core}"."serde1" or false) ||
        (rand_isaac."0.1.1"."serde1" or false) ||
        (f."rand_isaac"."0.1.1"."serde1" or false); }
      { "${deps.rand_isaac."0.1.1".rand_core}".default = (f.rand_core."${deps.rand_isaac."0.1.1".rand_core}".default or false); }
    ];
    rand_isaac = fold recursiveUpdate {} [
      { "0.1.1"."serde" =
        (f.rand_isaac."0.1.1"."serde" or false) ||
        (f.rand_isaac."0.1.1".serde1 or false) ||
        (rand_isaac."0.1.1"."serde1" or false); }
      { "0.1.1"."serde_derive" =
        (f.rand_isaac."0.1.1"."serde_derive" or false) ||
        (f.rand_isaac."0.1.1".serde1 or false) ||
        (rand_isaac."0.1.1"."serde1" or false); }
      { "0.1.1".default = (f.rand_isaac."0.1.1".default or true); }
    ];
  }) [
    (features_.rand_core."${deps."rand_isaac"."0.1.1"."rand_core"}" deps)
  ];


# end
# rand_jitter-0.1.3

  crates.rand_jitter."0.1.3" = deps: { features?(features_.rand_jitter."0.1.3" deps {}) }: buildRustCrate {
    crateName = "rand_jitter";
    version = "0.1.3";
    description = "Random number generator based on timing jitter";
    authors = [ "The Rand Project Developers" ];
    sha256 = "1cb4q73rmh1inlx3liy6rabapcqh6p6c1plsd2lxw6dmi67d1qc3";
    dependencies = mapFeatures features ([
      (crates."rand_core"."${deps."rand_jitter"."0.1.3"."rand_core"}" deps)
    ])
      ++ (if kernel == "darwin" || kernel == "ios" then mapFeatures features ([
      (crates."libc"."${deps."rand_jitter"."0.1.3"."libc"}" deps)
    ]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."rand_jitter"."0.1.3"."winapi"}" deps)
    ]) else []);
    features = mkFeatures (features."rand_jitter"."0.1.3" or {});
  };
  features_.rand_jitter."0.1.3" = deps: f: updateFeatures f (rec {
    libc."${deps.rand_jitter."0.1.3".libc}".default = true;
    rand_core = fold recursiveUpdate {} [
      { "${deps.rand_jitter."0.1.3".rand_core}"."std" =
        (f.rand_core."${deps.rand_jitter."0.1.3".rand_core}"."std" or false) ||
        (rand_jitter."0.1.3"."std" or false) ||
        (f."rand_jitter"."0.1.3"."std" or false); }
      { "${deps.rand_jitter."0.1.3".rand_core}".default = true; }
    ];
    rand_jitter."0.1.3".default = (f.rand_jitter."0.1.3".default or true);
    winapi = fold recursiveUpdate {} [
      { "${deps.rand_jitter."0.1.3".winapi}"."profileapi" = true; }
      { "${deps.rand_jitter."0.1.3".winapi}".default = true; }
    ];
  }) [
    (features_.rand_core."${deps."rand_jitter"."0.1.3"."rand_core"}" deps)
    (features_.libc."${deps."rand_jitter"."0.1.3"."libc"}" deps)
    (features_.winapi."${deps."rand_jitter"."0.1.3"."winapi"}" deps)
  ];


# end
# rand_os-0.1.2

  crates.rand_os."0.1.2" = deps: { features?(features_.rand_os."0.1.2" deps {}) }: buildRustCrate {
    crateName = "rand_os";
    version = "0.1.2";
    description = "OS backed Random Number Generator";
    authors = [ "The Rand Project Developers" ];
    sha256 = "07wzs8zn24gc6kg7sv75dszxswm6kd47zd4c1fg9h1d7bkwd4337";
    dependencies = mapFeatures features ([
      (crates."rand_core"."${deps."rand_os"."0.1.2"."rand_core"}" deps)
    ])
      ++ (if abi == "sgx" then mapFeatures features ([
      (crates."rdrand"."${deps."rand_os"."0.1.2"."rdrand"}" deps)
    ]) else [])
      ++ (if kernel == "cloudabi" then mapFeatures features ([
      (crates."cloudabi"."${deps."rand_os"."0.1.2"."cloudabi"}" deps)
    ]) else [])
      ++ (if kernel == "fuchsia" then mapFeatures features ([
      (crates."fuchsia_cprng"."${deps."rand_os"."0.1.2"."fuchsia_cprng"}" deps)
    ]) else [])
      ++ (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
      (crates."libc"."${deps."rand_os"."0.1.2"."libc"}" deps)
    ]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."rand_os"."0.1.2"."winapi"}" deps)
    ]) else [])
      ++ (if kernel == "wasm32-unknown-unknown" then mapFeatures features ([
]) else []);
  };
  features_.rand_os."0.1.2" = deps: f: updateFeatures f (rec {
    cloudabi."${deps.rand_os."0.1.2".cloudabi}".default = true;
    fuchsia_cprng."${deps.rand_os."0.1.2".fuchsia_cprng}".default = true;
    libc."${deps.rand_os."0.1.2".libc}".default = true;
    rand_core = fold recursiveUpdate {} [
      { "${deps.rand_os."0.1.2".rand_core}"."std" = true; }
      { "${deps.rand_os."0.1.2".rand_core}".default = true; }
    ];
    rand_os."0.1.2".default = (f.rand_os."0.1.2".default or true);
    rdrand."${deps.rand_os."0.1.2".rdrand}".default = true;
    winapi = fold recursiveUpdate {} [
      { "${deps.rand_os."0.1.2".winapi}"."minwindef" = true; }
      { "${deps.rand_os."0.1.2".winapi}"."ntsecapi" = true; }
      { "${deps.rand_os."0.1.2".winapi}"."winnt" = true; }
      { "${deps.rand_os."0.1.2".winapi}".default = true; }
    ];
  }) [
    (features_.rand_core."${deps."rand_os"."0.1.2"."rand_core"}" deps)
    (features_.rdrand."${deps."rand_os"."0.1.2"."rdrand"}" deps)
    (features_.cloudabi."${deps."rand_os"."0.1.2"."cloudabi"}" deps)
    (features_.fuchsia_cprng."${deps."rand_os"."0.1.2"."fuchsia_cprng"}" deps)
    (features_.libc."${deps."rand_os"."0.1.2"."libc"}" deps)
    (features_.winapi."${deps."rand_os"."0.1.2"."winapi"}" deps)
  ];


# end
# rand_pcg-0.1.1

  crates.rand_pcg."0.1.1" = deps: { features?(features_.rand_pcg."0.1.1" deps {}) }: buildRustCrate {
    crateName = "rand_pcg";
    version = "0.1.1";
    description = "Selected PCG random number generators\n";
    authors = [ "The Rand Project Developers" ];
    sha256 = "0x6pzldj0c8c7gmr67ni5i7w2f7n7idvs3ckx0fc3wkhwl7wrbza";
    build = "build.rs";
    dependencies = mapFeatures features ([
      (crates."rand_core"."${deps."rand_pcg"."0.1.1"."rand_core"}" deps)
    ]);

    buildDependencies = mapFeatures features ([
      (crates."rustc_version"."${deps."rand_pcg"."0.1.1"."rustc_version"}" deps)
    ]);
    features = mkFeatures (features."rand_pcg"."0.1.1" or {});
  };
  features_.rand_pcg."0.1.1" = deps: f: updateFeatures f (rec {
    rand_core."${deps.rand_pcg."0.1.1".rand_core}".default = (f.rand_core."${deps.rand_pcg."0.1.1".rand_core}".default or false);
    rand_pcg = fold recursiveUpdate {} [
      { "0.1.1"."serde" =
        (f.rand_pcg."0.1.1"."serde" or false) ||
        (f.rand_pcg."0.1.1".serde1 or false) ||
        (rand_pcg."0.1.1"."serde1" or false); }
      { "0.1.1"."serde_derive" =
        (f.rand_pcg."0.1.1"."serde_derive" or false) ||
        (f.rand_pcg."0.1.1".serde1 or false) ||
        (rand_pcg."0.1.1"."serde1" or false); }
      { "0.1.1".default = (f.rand_pcg."0.1.1".default or true); }
    ];
    rustc_version."${deps.rand_pcg."0.1.1".rustc_version}".default = true;
  }) [
    (features_.rand_core."${deps."rand_pcg"."0.1.1"."rand_core"}" deps)
    (features_.rustc_version."${deps."rand_pcg"."0.1.1"."rustc_version"}" deps)
  ];


# end
# rand_xorshift-0.1.1

  crates.rand_xorshift."0.1.1" = deps: { features?(features_.rand_xorshift."0.1.1" deps {}) }: buildRustCrate {
    crateName = "rand_xorshift";
    version = "0.1.1";
    description = "Xorshift random number generator\n";
    authors = [ "The Rand Project Developers" "The Rust Project Developers" ];
    sha256 = "0v365c4h4lzxwz5k5kp9m0661s0sss7ylv74if0xb4svis9sswnn";
    dependencies = mapFeatures features ([
      (crates."rand_core"."${deps."rand_xorshift"."0.1.1"."rand_core"}" deps)
    ]);
    features = mkFeatures (features."rand_xorshift"."0.1.1" or {});
  };
  features_.rand_xorshift."0.1.1" = deps: f: updateFeatures f (rec {
    rand_core."${deps.rand_xorshift."0.1.1".rand_core}".default = (f.rand_core."${deps.rand_xorshift."0.1.1".rand_core}".default or false);
    rand_xorshift = fold recursiveUpdate {} [
      { "0.1.1"."serde" =
        (f.rand_xorshift."0.1.1"."serde" or false) ||
        (f.rand_xorshift."0.1.1".serde1 or false) ||
        (rand_xorshift."0.1.1"."serde1" or false); }
      { "0.1.1"."serde_derive" =
        (f.rand_xorshift."0.1.1"."serde_derive" or false) ||
        (f.rand_xorshift."0.1.1".serde1 or false) ||
        (rand_xorshift."0.1.1"."serde1" or false); }
      { "0.1.1".default = (f.rand_xorshift."0.1.1".default or true); }
    ];
  }) [
    (features_.rand_core."${deps."rand_xorshift"."0.1.1"."rand_core"}" deps)
  ];


# end
# rdrand-0.4.0

  crates.rdrand."0.4.0" = deps: { features?(features_.rdrand."0.4.0" deps {}) }: buildRustCrate {
    crateName = "rdrand";
    version = "0.4.0";
    description = "An implementation of random number generator based on rdrand and rdseed instructions";
    authors = [ "Simonas Kazlauskas <rdrand@kazlauskas.me>" ];
    sha256 = "15hrcasn0v876wpkwab1dwbk9kvqwrb3iv4y4dibb6yxnfvzwajk";
    dependencies = mapFeatures features ([
      (crates."rand_core"."${deps."rdrand"."0.4.0"."rand_core"}" deps)
    ]);
    features = mkFeatures (features."rdrand"."0.4.0" or {});
  };
  features_.rdrand."0.4.0" = deps: f: updateFeatures f (rec {
    rand_core."${deps.rdrand."0.4.0".rand_core}".default = (f.rand_core."${deps.rdrand."0.4.0".rand_core}".default or false);
    rdrand = fold recursiveUpdate {} [
      { "0.4.0"."std" =
        (f.rdrand."0.4.0"."std" or false) ||
        (f.rdrand."0.4.0".default or false) ||
        (rdrand."0.4.0"."default" or false); }
      { "0.4.0".default = (f.rdrand."0.4.0".default or true); }
    ];
  }) [
    (features_.rand_core."${deps."rdrand"."0.4.0"."rand_core"}" deps)
  ];


# end
# redox_syscall-0.1.51

  crates.redox_syscall."0.1.51" = deps: { features?(features_.redox_syscall."0.1.51" deps {}) }: buildRustCrate {
    crateName = "redox_syscall";
    version = "0.1.51";
    description = "A Rust library to access raw Redox system calls";
    authors = [ "Jeremy Soller <jackpot51@gmail.com>" ];
    sha256 = "1a61cv7yydx64vpyvzr0z0hwzdvy4gcvcnfc6k70zpkngj5sz3ip";
    libName = "syscall";
  };
  features_.redox_syscall."0.1.51" = deps: f: updateFeatures f (rec {
    redox_syscall."0.1.51".default = (f.redox_syscall."0.1.51".default or true);
  }) [];


# end
# redox_termios-0.1.1

  crates.redox_termios."0.1.1" = deps: { features?(features_.redox_termios."0.1.1" deps {}) }: buildRustCrate {
    crateName = "redox_termios";
    version = "0.1.1";
    description = "A Rust library to access Redox termios functions";
    authors = [ "Jeremy Soller <jackpot51@gmail.com>" ];
    sha256 = "04s6yyzjca552hdaqlvqhp3vw0zqbc304md5czyd3axh56iry8wh";
    libPath = "src/lib.rs";
    dependencies = mapFeatures features ([
      (crates."redox_syscall"."${deps."redox_termios"."0.1.1"."redox_syscall"}" deps)
    ]);
  };
  features_.redox_termios."0.1.1" = deps: f: updateFeatures f (rec {
    redox_syscall."${deps.redox_termios."0.1.1".redox_syscall}".default = true;
    redox_termios."0.1.1".default = (f.redox_termios."0.1.1".default or true);
  }) [
    (features_.redox_syscall."${deps."redox_termios"."0.1.1"."redox_syscall"}" deps)
  ];


# end
# regex-1.1.0

  crates.regex."1.1.0" = deps: { features?(features_.regex."1.1.0" deps {}) }: buildRustCrate {
    crateName = "regex";
    version = "1.1.0";
    description = "An implementation of regular expressions for Rust. This implementation uses\nfinite automata and guarantees linear time matching on all inputs.\n";
    authors = [ "The Rust Project Developers" ];
    sha256 = "1myzfgs1yp6vs2rxyg6arn6ab05j6c2m922w3b4iv6zix1rl7z0n";
    dependencies = mapFeatures features ([
      (crates."aho_corasick"."${deps."regex"."1.1.0"."aho_corasick"}" deps)
      (crates."memchr"."${deps."regex"."1.1.0"."memchr"}" deps)
      (crates."regex_syntax"."${deps."regex"."1.1.0"."regex_syntax"}" deps)
      (crates."thread_local"."${deps."regex"."1.1.0"."thread_local"}" deps)
      (crates."utf8_ranges"."${deps."regex"."1.1.0"."utf8_ranges"}" deps)
    ]);
    features = mkFeatures (features."regex"."1.1.0" or {});
  };
  features_.regex."1.1.0" = deps: f: updateFeatures f (rec {
    aho_corasick."${deps.regex."1.1.0".aho_corasick}".default = true;
    memchr."${deps.regex."1.1.0".memchr}".default = true;
    regex = fold recursiveUpdate {} [
      { "1.1.0"."pattern" =
        (f.regex."1.1.0"."pattern" or false) ||
        (f.regex."1.1.0".unstable or false) ||
        (regex."1.1.0"."unstable" or false); }
      { "1.1.0"."use_std" =
        (f.regex."1.1.0"."use_std" or false) ||
        (f.regex."1.1.0".default or false) ||
        (regex."1.1.0"."default" or false); }
      { "1.1.0".default = (f.regex."1.1.0".default or true); }
    ];
    regex_syntax."${deps.regex."1.1.0".regex_syntax}".default = true;
    thread_local."${deps.regex."1.1.0".thread_local}".default = true;
    utf8_ranges."${deps.regex."1.1.0".utf8_ranges}".default = true;
  }) [
    (features_.aho_corasick."${deps."regex"."1.1.0"."aho_corasick"}" deps)
    (features_.memchr."${deps."regex"."1.1.0"."memchr"}" deps)
    (features_.regex_syntax."${deps."regex"."1.1.0"."regex_syntax"}" deps)
    (features_.thread_local."${deps."regex"."1.1.0"."thread_local"}" deps)
    (features_.utf8_ranges."${deps."regex"."1.1.0"."utf8_ranges"}" deps)
  ];


# end
# regex-syntax-0.6.5

  crates.regex_syntax."0.6.5" = deps: { features?(features_.regex_syntax."0.6.5" deps {}) }: buildRustCrate {
    crateName = "regex-syntax";
    version = "0.6.5";
    description = "A regular expression parser.";
    authors = [ "The Rust Project Developers" ];
    sha256 = "0aaaba1fan2qfyc31wzdmgmbmyirc27zgcbz41ba5wm1lb2d8kli";
    dependencies = mapFeatures features ([
      (crates."ucd_util"."${deps."regex_syntax"."0.6.5"."ucd_util"}" deps)
    ]);
  };
  features_.regex_syntax."0.6.5" = deps: f: updateFeatures f (rec {
    regex_syntax."0.6.5".default = (f.regex_syntax."0.6.5".default or true);
    ucd_util."${deps.regex_syntax."0.6.5".ucd_util}".default = true;
  }) [
    (features_.ucd_util."${deps."regex_syntax"."0.6.5"."ucd_util"}" deps)
  ];


# end
# remove_dir_all-0.5.1

  crates.remove_dir_all."0.5.1" = deps: { features?(features_.remove_dir_all."0.5.1" deps {}) }: buildRustCrate {
    crateName = "remove_dir_all";
    version = "0.5.1";
    description = "A safe, reliable implementation of remove_dir_all for Windows";
    authors = [ "Aaronepower <theaaronepower@gmail.com>" ];
    sha256 = "1chx3yvfbj46xjz4bzsvps208l46hfbcy0sm98gpiya454n4rrl7";
    dependencies = (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."remove_dir_all"."0.5.1"."winapi"}" deps)
    ]) else []);
  };
  features_.remove_dir_all."0.5.1" = deps: f: updateFeatures f (rec {
    remove_dir_all."0.5.1".default = (f.remove_dir_all."0.5.1".default or true);
    winapi = fold recursiveUpdate {} [
      { "${deps.remove_dir_all."0.5.1".winapi}"."errhandlingapi" = true; }
      { "${deps.remove_dir_all."0.5.1".winapi}"."fileapi" = true; }
      { "${deps.remove_dir_all."0.5.1".winapi}"."std" = true; }
      { "${deps.remove_dir_all."0.5.1".winapi}"."winbase" = true; }
      { "${deps.remove_dir_all."0.5.1".winapi}"."winerror" = true; }
      { "${deps.remove_dir_all."0.5.1".winapi}".default = true; }
    ];
  }) [
    (features_.winapi."${deps."remove_dir_all"."0.5.1"."winapi"}" deps)
  ];


# end
# rustc_version-0.2.3

  crates.rustc_version."0.2.3" = deps: { features?(features_.rustc_version."0.2.3" deps {}) }: buildRustCrate {
    crateName = "rustc_version";
    version = "0.2.3";
    description = "A library for querying the version of a installed rustc compiler";
    authors = [ "Marvin Löbel <loebel.marvin@gmail.com>" ];
    sha256 = "0rgwzbgs3i9fqjm1p4ra3n7frafmpwl29c8lw85kv1rxn7n2zaa7";
    dependencies = mapFeatures features ([
      (crates."semver"."${deps."rustc_version"."0.2.3"."semver"}" deps)
    ]);
  };
  features_.rustc_version."0.2.3" = deps: f: updateFeatures f (rec {
    rustc_version."0.2.3".default = (f.rustc_version."0.2.3".default or true);
    semver."${deps.rustc_version."0.2.3".semver}".default = true;
  }) [
    (features_.semver."${deps."rustc_version"."0.2.3"."semver"}" deps)
  ];


# end
# rusty-fork-0.2.1

  crates.rusty_fork."0.2.1" = deps: { features?(features_.rusty_fork."0.2.1" deps {}) }: buildRustCrate {
    crateName = "rusty-fork";
    version = "0.2.1";
    description = "Cross-platform library for running Rust tests in sub-processes using a\nfork-like interface.\n";
    authors = [ "Jason Lingle" ];
    sha256 = "1gzyvcvlwpq332qb95v650mrxp1mpx1dzwr9rvlvqbq871pmw519";
    dependencies = mapFeatures features ([
      (crates."fnv"."${deps."rusty_fork"."0.2.1"."fnv"}" deps)
      (crates."quick_error"."${deps."rusty_fork"."0.2.1"."quick_error"}" deps)
      (crates."tempfile"."${deps."rusty_fork"."0.2.1"."tempfile"}" deps)
    ]
      ++ (if features.rusty_fork."0.2.1".wait-timeout or false then [ (crates.wait_timeout."${deps."rusty_fork"."0.2.1".wait_timeout}" deps) ] else []));
    features = mkFeatures (features."rusty_fork"."0.2.1" or {});
  };
  features_.rusty_fork."0.2.1" = deps: f: updateFeatures f (rec {
    fnv."${deps.rusty_fork."0.2.1".fnv}".default = true;
    quick_error."${deps.rusty_fork."0.2.1".quick_error}".default = true;
    rusty_fork = fold recursiveUpdate {} [
      { "0.2.1"."timeout" =
        (f.rusty_fork."0.2.1"."timeout" or false) ||
        (f.rusty_fork."0.2.1".default or false) ||
        (rusty_fork."0.2.1"."default" or false); }
      { "0.2.1"."wait-timeout" =
        (f.rusty_fork."0.2.1"."wait-timeout" or false) ||
        (f.rusty_fork."0.2.1".timeout or false) ||
        (rusty_fork."0.2.1"."timeout" or false); }
      { "0.2.1".default = (f.rusty_fork."0.2.1".default or true); }
    ];
    tempfile."${deps.rusty_fork."0.2.1".tempfile}".default = true;
    wait_timeout."${deps.rusty_fork."0.2.1".wait_timeout}".default = true;
  }) [
    (features_.fnv."${deps."rusty_fork"."0.2.1"."fnv"}" deps)
    (features_.quick_error."${deps."rusty_fork"."0.2.1"."quick_error"}" deps)
    (features_.tempfile."${deps."rusty_fork"."0.2.1"."tempfile"}" deps)
    (features_.wait_timeout."${deps."rusty_fork"."0.2.1"."wait_timeout"}" deps)
  ];


# end
# ryu-0.2.7

  crates.ryu."0.2.7" = deps: { features?(features_.ryu."0.2.7" deps {}) }: buildRustCrate {
    crateName = "ryu";
    version = "0.2.7";
    description = "Fast floating point to string conversion";
    authors = [ "David Tolnay <dtolnay@gmail.com>" ];
    sha256 = "0m8szf1m87wfqkwh1f9zp9bn2mb0m9nav028xxnd0hlig90b44bd";
    build = "build.rs";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."ryu"."0.2.7" or {});
  };
  features_.ryu."0.2.7" = deps: f: updateFeatures f (rec {
    ryu."0.2.7".default = (f.ryu."0.2.7".default or true);
  }) [];


# end
# same-file-1.0.4

  crates.same_file."1.0.4" = deps: { features?(features_.same_file."1.0.4" deps {}) }: buildRustCrate {
    crateName = "same-file";
    version = "1.0.4";
    description = "A simple crate for determining whether two file paths point to the same file.\n";
    authors = [ "Andrew Gallant <jamslam@gmail.com>" ];
    sha256 = "1zs244ssl381cqlnh2g42g3i60qip4z72i26z44d6kas3y3gy77q";
    dependencies = (if kernel == "windows" then mapFeatures features ([
      (crates."winapi_util"."${deps."same_file"."1.0.4"."winapi_util"}" deps)
    ]) else []);
  };
  features_.same_file."1.0.4" = deps: f: updateFeatures f (rec {
    same_file."1.0.4".default = (f.same_file."1.0.4".default or true);
    winapi_util."${deps.same_file."1.0.4".winapi_util}".default = true;
  }) [
    (features_.winapi_util."${deps."same_file"."1.0.4"."winapi_util"}" deps)
  ];


# end
# semver-0.9.0

  crates.semver."0.9.0" = deps: { features?(features_.semver."0.9.0" deps {}) }: buildRustCrate {
    crateName = "semver";
    version = "0.9.0";
    description = "Semantic version parsing and comparison.\n";
    authors = [ "Steve Klabnik <steve@steveklabnik.com>" "The Rust Project Developers" ];
    sha256 = "0azak2lb2wc36s3x15az886kck7rpnksrw14lalm157rg9sc9z63";
    dependencies = mapFeatures features ([
      (crates."semver_parser"."${deps."semver"."0.9.0"."semver_parser"}" deps)
    ]);
    features = mkFeatures (features."semver"."0.9.0" or {});
  };
  features_.semver."0.9.0" = deps: f: updateFeatures f (rec {
    semver = fold recursiveUpdate {} [
      { "0.9.0"."serde" =
        (f.semver."0.9.0"."serde" or false) ||
        (f.semver."0.9.0".ci or false) ||
        (semver."0.9.0"."ci" or false); }
      { "0.9.0".default = (f.semver."0.9.0".default or true); }
    ];
    semver_parser."${deps.semver."0.9.0".semver_parser}".default = true;
  }) [
    (features_.semver_parser."${deps."semver"."0.9.0"."semver_parser"}" deps)
  ];


# end
# semver-parser-0.7.0

  crates.semver_parser."0.7.0" = deps: { features?(features_.semver_parser."0.7.0" deps {}) }: buildRustCrate {
    crateName = "semver-parser";
    version = "0.7.0";
    description = "Parsing of the semver spec.\n";
    authors = [ "Steve Klabnik <steve@steveklabnik.com>" ];
    sha256 = "1da66c8413yakx0y15k8c055yna5lyb6fr0fw9318kdwkrk5k12h";
  };
  features_.semver_parser."0.7.0" = deps: f: updateFeatures f (rec {
    semver_parser."0.7.0".default = (f.semver_parser."0.7.0".default or true);
  }) [];


# end
# serde-1.0.88

  crates.serde."1.0.88" = deps: { features?(features_.serde."1.0.88" deps {}) }: buildRustCrate {
    crateName = "serde";
    version = "1.0.88";
    description = "A generic serialization/deserialization framework";
    authors = [ "Erick Tryzelaar <erick.tryzelaar@gmail.com>" "David Tolnay <dtolnay@gmail.com>" ];
    sha256 = "0d51jvnznxrb1xq6a44vc2gg0rvgqs25hbca3h38y8982vy6xj1r";
    build = "build.rs";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."serde"."1.0.88" or {});
  };
  features_.serde."1.0.88" = deps: f: updateFeatures f (rec {
    serde = fold recursiveUpdate {} [
      { "1.0.88"."serde_derive" =
        (f.serde."1.0.88"."serde_derive" or false) ||
        (f.serde."1.0.88".derive or false) ||
        (serde."1.0.88"."derive" or false); }
      { "1.0.88"."std" =
        (f.serde."1.0.88"."std" or false) ||
        (f.serde."1.0.88".default or false) ||
        (serde."1.0.88"."default" or false); }
      { "1.0.88"."unstable" =
        (f.serde."1.0.88"."unstable" or false) ||
        (f.serde."1.0.88".alloc or false) ||
        (serde."1.0.88"."alloc" or false); }
      { "1.0.88".default = (f.serde."1.0.88".default or true); }
    ];
  }) [];


# end
# serde_derive-1.0.88

  crates.serde_derive."1.0.88" = deps: { features?(features_.serde_derive."1.0.88" deps {}) }: buildRustCrate {
    crateName = "serde_derive";
    version = "1.0.88";
    description = "Macros 1.1 implementation of #[derive(Serialize, Deserialize)]";
    authors = [ "Erick Tryzelaar <erick.tryzelaar@gmail.com>" "David Tolnay <dtolnay@gmail.com>" ];
    sha256 = "0022sjlj7q4d3l23bdz7d2y17cvw9jn0jzn6sjrdd2jzg83iw2h0";
    procMacro = true;
    dependencies = mapFeatures features ([
      (crates."proc_macro2"."${deps."serde_derive"."1.0.88"."proc_macro2"}" deps)
      (crates."quote"."${deps."serde_derive"."1.0.88"."quote"}" deps)
      (crates."syn"."${deps."serde_derive"."1.0.88"."syn"}" deps)
    ]);
    features = mkFeatures (features."serde_derive"."1.0.88" or {});
  };
  features_.serde_derive."1.0.88" = deps: f: updateFeatures f (rec {
    proc_macro2."${deps.serde_derive."1.0.88".proc_macro2}".default = true;
    quote."${deps.serde_derive."1.0.88".quote}".default = true;
    serde_derive."1.0.88".default = (f.serde_derive."1.0.88".default or true);
    syn = fold recursiveUpdate {} [
      { "${deps.serde_derive."1.0.88".syn}"."visit" = true; }
      { "${deps.serde_derive."1.0.88".syn}".default = true; }
    ];
  }) [
    (features_.proc_macro2."${deps."serde_derive"."1.0.88"."proc_macro2"}" deps)
    (features_.quote."${deps."serde_derive"."1.0.88"."quote"}" deps)
    (features_.syn."${deps."serde_derive"."1.0.88"."syn"}" deps)
  ];


# end
# serde_json-1.0.38

  crates.serde_json."1.0.38" = deps: { features?(features_.serde_json."1.0.38" deps {}) }: buildRustCrate {
    crateName = "serde_json";
    version = "1.0.38";
    description = "A JSON serialization file format";
    authors = [ "Erick Tryzelaar <erick.tryzelaar@gmail.com>" "David Tolnay <dtolnay@gmail.com>" ];
    sha256 = "10zhcsk1qh92320fjmgrdd23jf99rr504gp3d5nv9fddy5viq6a1";
    dependencies = mapFeatures features ([
      (crates."itoa"."${deps."serde_json"."1.0.38"."itoa"}" deps)
      (crates."ryu"."${deps."serde_json"."1.0.38"."ryu"}" deps)
      (crates."serde"."${deps."serde_json"."1.0.38"."serde"}" deps)
    ]);
    features = mkFeatures (features."serde_json"."1.0.38" or {});
  };
  features_.serde_json."1.0.38" = deps: f: updateFeatures f (rec {
    itoa."${deps.serde_json."1.0.38".itoa}".default = true;
    ryu."${deps.serde_json."1.0.38".ryu}".default = true;
    serde."${deps.serde_json."1.0.38".serde}".default = true;
    serde_json = fold recursiveUpdate {} [
      { "1.0.38"."indexmap" =
        (f.serde_json."1.0.38"."indexmap" or false) ||
        (f.serde_json."1.0.38".preserve_order or false) ||
        (serde_json."1.0.38"."preserve_order" or false); }
      { "1.0.38".default = (f.serde_json."1.0.38".default or true); }
    ];
  }) [
    (features_.itoa."${deps."serde_json"."1.0.38"."itoa"}" deps)
    (features_.ryu."${deps."serde_json"."1.0.38"."ryu"}" deps)
    (features_.serde."${deps."serde_json"."1.0.38"."serde"}" deps)
  ];


# end
# slab-0.4.2

  crates.slab."0.4.2" = deps: { features?(features_.slab."0.4.2" deps {}) }: buildRustCrate {
    crateName = "slab";
    version = "0.4.2";
    description = "Pre-allocated storage for a uniform data type";
    authors = [ "Carl Lerche <me@carllerche.com>" ];
    sha256 = "0h1l2z7qy6207kv0v3iigdf2xfk9yrhbwj1svlxk6wxjmdxvgdl7";
  };
  features_.slab."0.4.2" = deps: f: updateFeatures f (rec {
    slab."0.4.2".default = (f.slab."0.4.2".default or true);
  }) [];


# end
# spin-0.4.10

  crates.spin."0.4.10" = deps: { features?(features_.spin."0.4.10" deps {}) }: buildRustCrate {
    crateName = "spin";
    version = "0.4.10";
    description = "Synchronization primitives based on spinning.\nThey may contain data,\nThey are usable without `std`\nand static initializers are available.\n";
    authors = [ "Mathijs van de Nes <git@mathijs.vd-nes.nl>" "John Ericson <John_Ericson@Yahoo.com>" ];
    sha256 = "0gaxd3pialj8pq6b2xm4sqhgmxmhblz9ki2bmjjrfmzr3qhpa1l5";
    features = mkFeatures (features."spin"."0.4.10" or {});
  };
  features_.spin."0.4.10" = deps: f: updateFeatures f (rec {
    spin = fold recursiveUpdate {} [
      { "0.4.10"."const_fn" =
        (f.spin."0.4.10"."const_fn" or false) ||
        (f.spin."0.4.10".unstable or false) ||
        (spin."0.4.10"."unstable" or false); }
      { "0.4.10"."once" =
        (f.spin."0.4.10"."once" or false) ||
        (f.spin."0.4.10".unstable or false) ||
        (spin."0.4.10"."unstable" or false); }
      { "0.4.10"."unstable" =
        (f.spin."0.4.10"."unstable" or false) ||
        (f.spin."0.4.10".default or false) ||
        (spin."0.4.10"."default" or false); }
      { "0.4.10".default = (f.spin."0.4.10".default or true); }
    ];
  }) [];


# end
# strsim-0.7.0

  crates.strsim."0.7.0" = deps: { features?(features_.strsim."0.7.0" deps {}) }: buildRustCrate {
    crateName = "strsim";
    version = "0.7.0";
    description = "Implementations of string similarity metrics.\nIncludes Hamming, Levenshtein, OSA, Damerau-Levenshtein, Jaro, and Jaro-Winkler.\n";
    authors = [ "Danny Guo <dannyguo91@gmail.com>" ];
    sha256 = "0fy0k5f2705z73mb3x9459bpcvrx4ky8jpr4zikcbiwan4bnm0iv";
  };
  features_.strsim."0.7.0" = deps: f: updateFeatures f (rec {
    strsim."0.7.0".default = (f.strsim."0.7.0".default or true);
  }) [];


# end
# structopt-0.2.14

  crates.structopt."0.2.14" = deps: { features?(features_.structopt."0.2.14" deps {}) }: buildRustCrate {
    crateName = "structopt";
    version = "0.2.14";
    description = "Parse command line argument by defining a struct.";
    authors = [ "Guillaume Pinot <texitoi@texitoi.eu>" "others" ];
    sha256 = "06cs2pxdi8rj4whcc9p0280fnr94dj4a9hfdm2i4wyd85wwsqcxm";
    dependencies = mapFeatures features ([
      (crates."clap"."${deps."structopt"."0.2.14"."clap"}" deps)
      (crates."structopt_derive"."${deps."structopt"."0.2.14"."structopt_derive"}" deps)
    ]);
    features = mkFeatures (features."structopt"."0.2.14" or {});
  };
  features_.structopt."0.2.14" = deps: f: updateFeatures f (rec {
    clap = fold recursiveUpdate {} [
      { "${deps.structopt."0.2.14".clap}"."color" =
        (f.clap."${deps.structopt."0.2.14".clap}"."color" or false) ||
        (structopt."0.2.14"."color" or false) ||
        (f."structopt"."0.2.14"."color" or false); }
      { "${deps.structopt."0.2.14".clap}"."debug" =
        (f.clap."${deps.structopt."0.2.14".clap}"."debug" or false) ||
        (structopt."0.2.14"."debug" or false) ||
        (f."structopt"."0.2.14"."debug" or false); }
      { "${deps.structopt."0.2.14".clap}"."default" =
        (f.clap."${deps.structopt."0.2.14".clap}"."default" or false) ||
        (structopt."0.2.14"."default" or false) ||
        (f."structopt"."0.2.14"."default" or false); }
      { "${deps.structopt."0.2.14".clap}"."doc" =
        (f.clap."${deps.structopt."0.2.14".clap}"."doc" or false) ||
        (structopt."0.2.14"."doc" or false) ||
        (f."structopt"."0.2.14"."doc" or false); }
      { "${deps.structopt."0.2.14".clap}"."lints" =
        (f.clap."${deps.structopt."0.2.14".clap}"."lints" or false) ||
        (structopt."0.2.14"."lints" or false) ||
        (f."structopt"."0.2.14"."lints" or false); }
      { "${deps.structopt."0.2.14".clap}"."no_cargo" =
        (f.clap."${deps.structopt."0.2.14".clap}"."no_cargo" or false) ||
        (structopt."0.2.14"."no_cargo" or false) ||
        (f."structopt"."0.2.14"."no_cargo" or false); }
      { "${deps.structopt."0.2.14".clap}"."suggestions" =
        (f.clap."${deps.structopt."0.2.14".clap}"."suggestions" or false) ||
        (structopt."0.2.14"."suggestions" or false) ||
        (f."structopt"."0.2.14"."suggestions" or false); }
      { "${deps.structopt."0.2.14".clap}"."wrap_help" =
        (f.clap."${deps.structopt."0.2.14".clap}"."wrap_help" or false) ||
        (structopt."0.2.14"."wrap_help" or false) ||
        (f."structopt"."0.2.14"."wrap_help" or false); }
      { "${deps.structopt."0.2.14".clap}"."yaml" =
        (f.clap."${deps.structopt."0.2.14".clap}"."yaml" or false) ||
        (structopt."0.2.14"."yaml" or false) ||
        (f."structopt"."0.2.14"."yaml" or false); }
      { "${deps.structopt."0.2.14".clap}".default = (f.clap."${deps.structopt."0.2.14".clap}".default or false); }
    ];
    structopt."0.2.14".default = (f.structopt."0.2.14".default or true);
    structopt_derive = fold recursiveUpdate {} [
      { "${deps.structopt."0.2.14".structopt_derive}"."nightly" =
        (f.structopt_derive."${deps.structopt."0.2.14".structopt_derive}"."nightly" or false) ||
        (structopt."0.2.14"."nightly" or false) ||
        (f."structopt"."0.2.14"."nightly" or false); }
      { "${deps.structopt."0.2.14".structopt_derive}".default = true; }
    ];
  }) [
    (features_.clap."${deps."structopt"."0.2.14"."clap"}" deps)
    (features_.structopt_derive."${deps."structopt"."0.2.14"."structopt_derive"}" deps)
  ];


# end
# structopt-derive-0.2.14

  crates.structopt_derive."0.2.14" = deps: { features?(features_.structopt_derive."0.2.14" deps {}) }: buildRustCrate {
    crateName = "structopt-derive";
    version = "0.2.14";
    description = "Parse command line argument by defining a struct, derive crate.";
    authors = [ "Guillaume Pinot <texitoi@texitoi.eu>" ];
    sha256 = "02pm3qc1364whshmsj8ra763wg5kfg7ap4dxnhjk960hkjbbqzd6";
    procMacro = true;
    dependencies = mapFeatures features ([
      (crates."heck"."${deps."structopt_derive"."0.2.14"."heck"}" deps)
      (crates."proc_macro2"."${deps."structopt_derive"."0.2.14"."proc_macro2"}" deps)
      (crates."quote"."${deps."structopt_derive"."0.2.14"."quote"}" deps)
      (crates."syn"."${deps."structopt_derive"."0.2.14"."syn"}" deps)
    ]);
    features = mkFeatures (features."structopt_derive"."0.2.14" or {});
  };
  features_.structopt_derive."0.2.14" = deps: f: updateFeatures f (rec {
    heck."${deps.structopt_derive."0.2.14".heck}".default = true;
    proc_macro2 = fold recursiveUpdate {} [
      { "${deps.structopt_derive."0.2.14".proc_macro2}"."nightly" =
        (f.proc_macro2."${deps.structopt_derive."0.2.14".proc_macro2}"."nightly" or false) ||
        (structopt_derive."0.2.14"."nightly" or false) ||
        (f."structopt_derive"."0.2.14"."nightly" or false); }
      { "${deps.structopt_derive."0.2.14".proc_macro2}".default = true; }
    ];
    quote."${deps.structopt_derive."0.2.14".quote}".default = true;
    structopt_derive."0.2.14".default = (f.structopt_derive."0.2.14".default or true);
    syn."${deps.structopt_derive."0.2.14".syn}".default = true;
  }) [
    (features_.heck."${deps."structopt_derive"."0.2.14"."heck"}" deps)
    (features_.proc_macro2."${deps."structopt_derive"."0.2.14"."proc_macro2"}" deps)
    (features_.quote."${deps."structopt_derive"."0.2.14"."quote"}" deps)
    (features_.syn."${deps."structopt_derive"."0.2.14"."syn"}" deps)
  ];


# end
# syn-0.15.26

  crates.syn."0.15.26" = deps: { features?(features_.syn."0.15.26" deps {}) }: buildRustCrate {
    crateName = "syn";
    version = "0.15.26";
    description = "Parser for Rust source code";
    authors = [ "David Tolnay <dtolnay@gmail.com>" ];
    sha256 = "12kf63vxbiirycv10zzxw3g8a3cxblmpi6kx4xxz4csd15wapxid";
    dependencies = mapFeatures features ([
      (crates."proc_macro2"."${deps."syn"."0.15.26"."proc_macro2"}" deps)
      (crates."unicode_xid"."${deps."syn"."0.15.26"."unicode_xid"}" deps)
    ]
      ++ (if features.syn."0.15.26".quote or false then [ (crates.quote."${deps."syn"."0.15.26".quote}" deps) ] else []));
    features = mkFeatures (features."syn"."0.15.26" or {});
  };
  features_.syn."0.15.26" = deps: f: updateFeatures f (rec {
    proc_macro2 = fold recursiveUpdate {} [
      { "${deps.syn."0.15.26".proc_macro2}"."proc-macro" =
        (f.proc_macro2."${deps.syn."0.15.26".proc_macro2}"."proc-macro" or false) ||
        (syn."0.15.26"."proc-macro" or false) ||
        (f."syn"."0.15.26"."proc-macro" or false); }
      { "${deps.syn."0.15.26".proc_macro2}".default = (f.proc_macro2."${deps.syn."0.15.26".proc_macro2}".default or false); }
    ];
    quote = fold recursiveUpdate {} [
      { "${deps.syn."0.15.26".quote}"."proc-macro" =
        (f.quote."${deps.syn."0.15.26".quote}"."proc-macro" or false) ||
        (syn."0.15.26"."proc-macro" or false) ||
        (f."syn"."0.15.26"."proc-macro" or false); }
      { "${deps.syn."0.15.26".quote}".default = (f.quote."${deps.syn."0.15.26".quote}".default or false); }
    ];
    syn = fold recursiveUpdate {} [
      { "0.15.26"."clone-impls" =
        (f.syn."0.15.26"."clone-impls" or false) ||
        (f.syn."0.15.26".default or false) ||
        (syn."0.15.26"."default" or false); }
      { "0.15.26"."derive" =
        (f.syn."0.15.26"."derive" or false) ||
        (f.syn."0.15.26".default or false) ||
        (syn."0.15.26"."default" or false); }
      { "0.15.26"."parsing" =
        (f.syn."0.15.26"."parsing" or false) ||
        (f.syn."0.15.26".default or false) ||
        (syn."0.15.26"."default" or false); }
      { "0.15.26"."printing" =
        (f.syn."0.15.26"."printing" or false) ||
        (f.syn."0.15.26".default or false) ||
        (syn."0.15.26"."default" or false); }
      { "0.15.26"."proc-macro" =
        (f.syn."0.15.26"."proc-macro" or false) ||
        (f.syn."0.15.26".default or false) ||
        (syn."0.15.26"."default" or false); }
      { "0.15.26"."quote" =
        (f.syn."0.15.26"."quote" or false) ||
        (f.syn."0.15.26".printing or false) ||
        (syn."0.15.26"."printing" or false); }
      { "0.15.26".default = (f.syn."0.15.26".default or true); }
    ];
    unicode_xid."${deps.syn."0.15.26".unicode_xid}".default = true;
  }) [
    (features_.proc_macro2."${deps."syn"."0.15.26"."proc_macro2"}" deps)
    (features_.quote."${deps."syn"."0.15.26"."quote"}" deps)
    (features_.unicode_xid."${deps."syn"."0.15.26"."unicode_xid"}" deps)
  ];


# end
# tempfile-3.0.7

  crates.tempfile."3.0.7" = deps: { features?(features_.tempfile."3.0.7" deps {}) }: buildRustCrate {
    crateName = "tempfile";
    version = "3.0.7";
    description = "A library for managing temporary files and directories.\n";
    authors = [ "Steven Allen <steven@stebalien.com>" "The Rust Project Developers" "Ashley Mannix <ashleymannix@live.com.au>" "Jason White <jasonaw0@gmail.com>" ];
    sha256 = "19h7ch8fvisxrrmabcnhlfj6b8vg34zaw8491x141p0n0727niaf";
    dependencies = mapFeatures features ([
      (crates."cfg_if"."${deps."tempfile"."3.0.7"."cfg_if"}" deps)
      (crates."rand"."${deps."tempfile"."3.0.7"."rand"}" deps)
      (crates."remove_dir_all"."${deps."tempfile"."3.0.7"."remove_dir_all"}" deps)
    ])
      ++ (if kernel == "redox" then mapFeatures features ([
      (crates."redox_syscall"."${deps."tempfile"."3.0.7"."redox_syscall"}" deps)
    ]) else [])
      ++ (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
      (crates."libc"."${deps."tempfile"."3.0.7"."libc"}" deps)
    ]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."tempfile"."3.0.7"."winapi"}" deps)
    ]) else []);
  };
  features_.tempfile."3.0.7" = deps: f: updateFeatures f (rec {
    cfg_if."${deps.tempfile."3.0.7".cfg_if}".default = true;
    libc."${deps.tempfile."3.0.7".libc}".default = true;
    rand."${deps.tempfile."3.0.7".rand}".default = true;
    redox_syscall."${deps.tempfile."3.0.7".redox_syscall}".default = true;
    remove_dir_all."${deps.tempfile."3.0.7".remove_dir_all}".default = true;
    tempfile."3.0.7".default = (f.tempfile."3.0.7".default or true);
    winapi = fold recursiveUpdate {} [
      { "${deps.tempfile."3.0.7".winapi}"."fileapi" = true; }
      { "${deps.tempfile."3.0.7".winapi}"."handleapi" = true; }
      { "${deps.tempfile."3.0.7".winapi}"."winbase" = true; }
      { "${deps.tempfile."3.0.7".winapi}".default = true; }
    ];
  }) [
    (features_.cfg_if."${deps."tempfile"."3.0.7"."cfg_if"}" deps)
    (features_.rand."${deps."tempfile"."3.0.7"."rand"}" deps)
    (features_.remove_dir_all."${deps."tempfile"."3.0.7"."remove_dir_all"}" deps)
    (features_.redox_syscall."${deps."tempfile"."3.0.7"."redox_syscall"}" deps)
    (features_.libc."${deps."tempfile"."3.0.7"."libc"}" deps)
    (features_.winapi."${deps."tempfile"."3.0.7"."winapi"}" deps)
  ];


# end
# termcolor-1.0.4

  crates.termcolor."1.0.4" = deps: { features?(features_.termcolor."1.0.4" deps {}) }: buildRustCrate {
    crateName = "termcolor";
    version = "1.0.4";
    description = "A simple cross platform library for writing colored text to a terminal.\n";
    authors = [ "Andrew Gallant <jamslam@gmail.com>" ];
    sha256 = "0xydrjc0bxg08llcbcmkka29szdrfklk4vh6l6mdd67ajifqw1mv";
    dependencies = (if kernel == "windows" then mapFeatures features ([
      (crates."wincolor"."${deps."termcolor"."1.0.4"."wincolor"}" deps)
    ]) else []);
  };
  features_.termcolor."1.0.4" = deps: f: updateFeatures f (rec {
    termcolor."1.0.4".default = (f.termcolor."1.0.4".default or true);
    wincolor."${deps.termcolor."1.0.4".wincolor}".default = true;
  }) [
    (features_.wincolor."${deps."termcolor"."1.0.4"."wincolor"}" deps)
  ];


# end
# termion-1.5.1

  crates.termion."1.5.1" = deps: { features?(features_.termion."1.5.1" deps {}) }: buildRustCrate {
    crateName = "termion";
    version = "1.5.1";
    description = "A bindless library for manipulating terminals.";
    authors = [ "ticki <Ticki@users.noreply.github.com>" "gycos <alexandre.bury@gmail.com>" "IGI-111 <igi-111@protonmail.com>" ];
    sha256 = "02gq4vd8iws1f3gjrgrgpajsk2bk43nds5acbbb4s8dvrdvr8nf1";
    dependencies = (if !(kernel == "redox") then mapFeatures features ([
      (crates."libc"."${deps."termion"."1.5.1"."libc"}" deps)
    ]) else [])
      ++ (if kernel == "redox" then mapFeatures features ([
      (crates."redox_syscall"."${deps."termion"."1.5.1"."redox_syscall"}" deps)
      (crates."redox_termios"."${deps."termion"."1.5.1"."redox_termios"}" deps)
    ]) else []);
  };
  features_.termion."1.5.1" = deps: f: updateFeatures f (rec {
    libc."${deps.termion."1.5.1".libc}".default = true;
    redox_syscall."${deps.termion."1.5.1".redox_syscall}".default = true;
    redox_termios."${deps.termion."1.5.1".redox_termios}".default = true;
    termion."1.5.1".default = (f.termion."1.5.1".default or true);
  }) [
    (features_.libc."${deps."termion"."1.5.1"."libc"}" deps)
    (features_.redox_syscall."${deps."termion"."1.5.1"."redox_syscall"}" deps)
    (features_.redox_termios."${deps."termion"."1.5.1"."redox_termios"}" deps)
  ];


# end
# textwrap-0.10.0

  crates.textwrap."0.10.0" = deps: { features?(features_.textwrap."0.10.0" deps {}) }: buildRustCrate {
    crateName = "textwrap";
    version = "0.10.0";
    description = "Textwrap is a small library for word wrapping, indenting, and\ndedenting strings.\n\nYou can use it to format strings (such as help and error messages) for\ndisplay in commandline applications. It is designed to be efficient\nand handle Unicode characters correctly.\n";
    authors = [ "Martin Geisler <martin@geisler.net>" ];
    sha256 = "1s8d5cna12smhgj0x2y1xphklyk2an1yzbadnj89p1vy5vnjpsas";
    dependencies = mapFeatures features ([
      (crates."unicode_width"."${deps."textwrap"."0.10.0"."unicode_width"}" deps)
    ]);
  };
  features_.textwrap."0.10.0" = deps: f: updateFeatures f (rec {
    textwrap."0.10.0".default = (f.textwrap."0.10.0".default or true);
    unicode_width."${deps.textwrap."0.10.0".unicode_width}".default = true;
  }) [
    (features_.unicode_width."${deps."textwrap"."0.10.0"."unicode_width"}" deps)
  ];


# end
# thread_local-0.3.6

  crates.thread_local."0.3.6" = deps: { features?(features_.thread_local."0.3.6" deps {}) }: buildRustCrate {
    crateName = "thread_local";
    version = "0.3.6";
    description = "Per-object thread-local storage";
    authors = [ "Amanieu d'Antras <amanieu@gmail.com>" ];
    sha256 = "02rksdwjmz2pw9bmgbb4c0bgkbq5z6nvg510sq1s6y2j1gam0c7i";
    dependencies = mapFeatures features ([
      (crates."lazy_static"."${deps."thread_local"."0.3.6"."lazy_static"}" deps)
    ]);
  };
  features_.thread_local."0.3.6" = deps: f: updateFeatures f (rec {
    lazy_static."${deps.thread_local."0.3.6".lazy_static}".default = true;
    thread_local."0.3.6".default = (f.thread_local."0.3.6".default or true);
  }) [
    (features_.lazy_static."${deps."thread_local"."0.3.6"."lazy_static"}" deps)
  ];


# end
# ucd-util-0.1.3

  crates.ucd_util."0.1.3" = deps: { features?(features_.ucd_util."0.1.3" deps {}) }: buildRustCrate {
    crateName = "ucd-util";
    version = "0.1.3";
    description = "A small utility library for working with the Unicode character database.\n";
    authors = [ "Andrew Gallant <jamslam@gmail.com>" ];
    sha256 = "1n1qi3jywq5syq90z9qd8qzbn58pcjgv1sx4sdmipm4jf9zanz15";
  };
  features_.ucd_util."0.1.3" = deps: f: updateFeatures f (rec {
    ucd_util."0.1.3".default = (f.ucd_util."0.1.3".default or true);
  }) [];


# end
# unicode-segmentation-1.2.1

  crates.unicode_segmentation."1.2.1" = deps: { features?(features_.unicode_segmentation."1.2.1" deps {}) }: buildRustCrate {
    crateName = "unicode-segmentation";
    version = "1.2.1";
    description = "This crate provides Grapheme Cluster and Word boundaries\naccording to Unicode Standard Annex #29 rules.\n";
    authors = [ "kwantam <kwantam@gmail.com>" ];
    sha256 = "0pzydlrq019cdiqbbfq205cskxcspwi97zfdi02rma21br1kc59m";
    features = mkFeatures (features."unicode_segmentation"."1.2.1" or {});
  };
  features_.unicode_segmentation."1.2.1" = deps: f: updateFeatures f (rec {
    unicode_segmentation."1.2.1".default = (f.unicode_segmentation."1.2.1".default or true);
  }) [];


# end
# unicode-width-0.1.5

  crates.unicode_width."0.1.5" = deps: { features?(features_.unicode_width."0.1.5" deps {}) }: buildRustCrate {
    crateName = "unicode-width";
    version = "0.1.5";
    description = "Determine displayed width of `char` and `str` types\naccording to Unicode Standard Annex #11 rules.\n";
    authors = [ "kwantam <kwantam@gmail.com>" ];
    sha256 = "0886lc2aymwgy0lhavwn6s48ik3c61ykzzd3za6prgnw51j7bi4w";
    features = mkFeatures (features."unicode_width"."0.1.5" or {});
  };
  features_.unicode_width."0.1.5" = deps: f: updateFeatures f (rec {
    unicode_width."0.1.5".default = (f.unicode_width."0.1.5".default or true);
  }) [];


# end
# unicode-xid-0.1.0

  crates.unicode_xid."0.1.0" = deps: { features?(features_.unicode_xid."0.1.0" deps {}) }: buildRustCrate {
    crateName = "unicode-xid";
    version = "0.1.0";
    description = "Determine whether characters have the XID_Start\nor XID_Continue properties according to\nUnicode Standard Annex #31.\n";
    authors = [ "erick.tryzelaar <erick.tryzelaar@gmail.com>" "kwantam <kwantam@gmail.com>" ];
    sha256 = "05wdmwlfzxhq3nhsxn6wx4q8dhxzzfb9szsz6wiw092m1rjj01zj";
    features = mkFeatures (features."unicode_xid"."0.1.0" or {});
  };
  features_.unicode_xid."0.1.0" = deps: f: updateFeatures f (rec {
    unicode_xid."0.1.0".default = (f.unicode_xid."0.1.0".default or true);
  }) [];


# end
# utf8-ranges-1.0.2

  crates.utf8_ranges."1.0.2" = deps: { features?(features_.utf8_ranges."1.0.2" deps {}) }: buildRustCrate {
    crateName = "utf8-ranges";
    version = "1.0.2";
    description = "Convert ranges of Unicode codepoints to UTF-8 byte ranges.";
    authors = [ "Andrew Gallant <jamslam@gmail.com>" ];
    sha256 = "1my02laqsgnd8ib4dvjgd4rilprqjad6pb9jj9vi67csi5qs2281";
  };
  features_.utf8_ranges."1.0.2" = deps: f: updateFeatures f (rec {
    utf8_ranges."1.0.2".default = (f.utf8_ranges."1.0.2".default or true);
  }) [];


# end
# vec1-1.1.0

  crates.vec1."1.1.0" = deps: { features?(features_.vec1."1.1.0" deps {}) }: buildRustCrate {
    crateName = "vec1";
    version = "1.1.0";
    description = "a std Vec wrapper assuring that it has at least 1 element";
    authors = [ "Philipp Korber <p.korber@1aim.com>" ];
    sha256 = "0qglq8x5p3bprzh04d54wr3byqkz68izcirw443wwg7gw6hvppqw";
    dependencies = mapFeatures features ([
]);
  };
  features_.vec1."1.1.0" = deps: f: updateFeatures f (rec {
    vec1."1.1.0".default = (f.vec1."1.1.0".default or true);
  }) [];


# end
# vec_map-0.8.1

  crates.vec_map."0.8.1" = deps: { features?(features_.vec_map."0.8.1" deps {}) }: buildRustCrate {
    crateName = "vec_map";
    version = "0.8.1";
    description = "A simple map based on a vector for small integer keys";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" "Jorge Aparicio <japaricious@gmail.com>" "Alexis Beingessner <a.beingessner@gmail.com>" "Brian Anderson <>" "tbu- <>" "Manish Goregaokar <>" "Aaron Turon <aturon@mozilla.com>" "Adolfo Ochagavía <>" "Niko Matsakis <>" "Steven Fackler <>" "Chase Southwood <csouth3@illinois.edu>" "Eduard Burtescu <>" "Florian Wilkens <>" "Félix Raimundo <>" "Tibor Benke <>" "Markus Siemens <markus@m-siemens.de>" "Josh Branchaud <jbranchaud@gmail.com>" "Huon Wilson <dbau.pp@gmail.com>" "Corey Farwell <coref@rwell.org>" "Aaron Liblong <>" "Nick Cameron <nrc@ncameron.org>" "Patrick Walton <pcwalton@mimiga.net>" "Felix S Klock II <>" "Andrew Paseltiner <apaseltiner@gmail.com>" "Sean McArthur <sean.monstar@gmail.com>" "Vadim Petrochenkov <>" ];
    sha256 = "1jj2nrg8h3l53d43rwkpkikq5a5x15ms4rf1rw92hp5lrqhi8mpi";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."vec_map"."0.8.1" or {});
  };
  features_.vec_map."0.8.1" = deps: f: updateFeatures f (rec {
    vec_map = fold recursiveUpdate {} [
      { "0.8.1"."serde" =
        (f.vec_map."0.8.1"."serde" or false) ||
        (f.vec_map."0.8.1".eders or false) ||
        (vec_map."0.8.1"."eders" or false); }
      { "0.8.1".default = (f.vec_map."0.8.1".default or true); }
    ];
  }) [];


# end
# void-1.0.2

  crates.void."1.0.2" = deps: { features?(features_.void."1.0.2" deps {}) }: buildRustCrate {
    crateName = "void";
    version = "1.0.2";
    description = "The uninhabited void type for use in statically impossible cases.";
    authors = [ "Jonathan Reem <jonathan.reem@gmail.com>" ];
    sha256 = "0h1dm0dx8dhf56a83k68mijyxigqhizpskwxfdrs1drwv2cdclv3";
    features = mkFeatures (features."void"."1.0.2" or {});
  };
  features_.void."1.0.2" = deps: f: updateFeatures f (rec {
    void = fold recursiveUpdate {} [
      { "1.0.2"."std" =
        (f.void."1.0.2"."std" or false) ||
        (f.void."1.0.2".default or false) ||
        (void."1.0.2"."default" or false); }
      { "1.0.2".default = (f.void."1.0.2".default or true); }
    ];
  }) [];


# end
# wait-timeout-0.1.5

  crates.wait_timeout."0.1.5" = deps: { features?(features_.wait_timeout."0.1.5" deps {}) }: buildRustCrate {
    crateName = "wait-timeout";
    version = "0.1.5";
    description = "A crate to wait on a child process with a timeout specified across Unix and\nWindows platforms.\n";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    sha256 = "16vy805q2fg7phpfnmasp53jwjx14snxrdzks6iic56ml7dic14l";
    dependencies = mapFeatures features ([
      (crates."libc"."${deps."wait_timeout"."0.1.5"."libc"}" deps)
    ]);
  };
  features_.wait_timeout."0.1.5" = deps: f: updateFeatures f (rec {
    libc."${deps.wait_timeout."0.1.5".libc}".default = true;
    wait_timeout."0.1.5".default = (f.wait_timeout."0.1.5".default or true);
  }) [
    (features_.libc."${deps."wait_timeout"."0.1.5"."libc"}" deps)
  ];


# end
# walkdir-2.2.7

  crates.walkdir."2.2.7" = deps: { features?(features_.walkdir."2.2.7" deps {}) }: buildRustCrate {
    crateName = "walkdir";
    version = "2.2.7";
    description = "Recursively walk a directory.";
    authors = [ "Andrew Gallant <jamslam@gmail.com>" ];
    sha256 = "0wq3v28916kkla29yyi0g0xfc16apwx24py68049kriz3gjlig03";
    dependencies = mapFeatures features ([
      (crates."same_file"."${deps."walkdir"."2.2.7"."same_file"}" deps)
    ])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."walkdir"."2.2.7"."winapi"}" deps)
      (crates."winapi_util"."${deps."walkdir"."2.2.7"."winapi_util"}" deps)
    ]) else []);
  };
  features_.walkdir."2.2.7" = deps: f: updateFeatures f (rec {
    same_file."${deps.walkdir."2.2.7".same_file}".default = true;
    walkdir."2.2.7".default = (f.walkdir."2.2.7".default or true);
    winapi = fold recursiveUpdate {} [
      { "${deps.walkdir."2.2.7".winapi}"."std" = true; }
      { "${deps.walkdir."2.2.7".winapi}"."winnt" = true; }
      { "${deps.walkdir."2.2.7".winapi}".default = true; }
    ];
    winapi_util."${deps.walkdir."2.2.7".winapi_util}".default = true;
  }) [
    (features_.same_file."${deps."walkdir"."2.2.7"."same_file"}" deps)
    (features_.winapi."${deps."walkdir"."2.2.7"."winapi"}" deps)
    (features_.winapi_util."${deps."walkdir"."2.2.7"."winapi_util"}" deps)
  ];


# end
# winapi-0.2.8

  crates.winapi."0.2.8" = deps: { features?(features_.winapi."0.2.8" deps {}) }: buildRustCrate {
    crateName = "winapi";
    version = "0.2.8";
    description = "Types and constants for WinAPI bindings. See README for list of crates providing function bindings.";
    authors = [ "Peter Atashian <retep998@gmail.com>" ];
    sha256 = "0a45b58ywf12vb7gvj6h3j264nydynmzyqz8d8rqxsj6icqv82as";
  };
  features_.winapi."0.2.8" = deps: f: updateFeatures f (rec {
    winapi."0.2.8".default = (f.winapi."0.2.8".default or true);
  }) [];


# end
# winapi-0.3.6

  crates.winapi."0.3.6" = deps: { features?(features_.winapi."0.3.6" deps {}) }: buildRustCrate {
    crateName = "winapi";
    version = "0.3.6";
    description = "Raw FFI bindings for all of Windows API.";
    authors = [ "Peter Atashian <retep998@gmail.com>" ];
    sha256 = "1d9jfp4cjd82sr1q4dgdlrkvm33zhhav9d7ihr0nivqbncr059m4";
    build = "build.rs";
    dependencies = (if kernel == "i686-pc-windows-gnu" then mapFeatures features ([
      (crates."winapi_i686_pc_windows_gnu"."${deps."winapi"."0.3.6"."winapi_i686_pc_windows_gnu"}" deps)
    ]) else [])
      ++ (if kernel == "x86_64-pc-windows-gnu" then mapFeatures features ([
      (crates."winapi_x86_64_pc_windows_gnu"."${deps."winapi"."0.3.6"."winapi_x86_64_pc_windows_gnu"}" deps)
    ]) else []);
    features = mkFeatures (features."winapi"."0.3.6" or {});
  };
  features_.winapi."0.3.6" = deps: f: updateFeatures f (rec {
    winapi."0.3.6".default = (f.winapi."0.3.6".default or true);
    winapi_i686_pc_windows_gnu."${deps.winapi."0.3.6".winapi_i686_pc_windows_gnu}".default = true;
    winapi_x86_64_pc_windows_gnu."${deps.winapi."0.3.6".winapi_x86_64_pc_windows_gnu}".default = true;
  }) [
    (features_.winapi_i686_pc_windows_gnu."${deps."winapi"."0.3.6"."winapi_i686_pc_windows_gnu"}" deps)
    (features_.winapi_x86_64_pc_windows_gnu."${deps."winapi"."0.3.6"."winapi_x86_64_pc_windows_gnu"}" deps)
  ];


# end
# winapi-build-0.1.1

  crates.winapi_build."0.1.1" = deps: { features?(features_.winapi_build."0.1.1" deps {}) }: buildRustCrate {
    crateName = "winapi-build";
    version = "0.1.1";
    description = "Common code for build.rs in WinAPI -sys crates.";
    authors = [ "Peter Atashian <retep998@gmail.com>" ];
    sha256 = "1lxlpi87rkhxcwp2ykf1ldw3p108hwm24nywf3jfrvmff4rjhqga";
    libName = "build";
  };
  features_.winapi_build."0.1.1" = deps: f: updateFeatures f (rec {
    winapi_build."0.1.1".default = (f.winapi_build."0.1.1".default or true);
  }) [];


# end
# winapi-i686-pc-windows-gnu-0.4.0

  crates.winapi_i686_pc_windows_gnu."0.4.0" = deps: { features?(features_.winapi_i686_pc_windows_gnu."0.4.0" deps {}) }: buildRustCrate {
    crateName = "winapi-i686-pc-windows-gnu";
    version = "0.4.0";
    description = "Import libraries for the i686-pc-windows-gnu target. Please don't use this crate directly, depend on winapi instead.";
    authors = [ "Peter Atashian <retep998@gmail.com>" ];
    sha256 = "05ihkij18r4gamjpxj4gra24514can762imjzlmak5wlzidplzrp";
    build = "build.rs";
  };
  features_.winapi_i686_pc_windows_gnu."0.4.0" = deps: f: updateFeatures f (rec {
    winapi_i686_pc_windows_gnu."0.4.0".default = (f.winapi_i686_pc_windows_gnu."0.4.0".default or true);
  }) [];


# end
# winapi-util-0.1.2

  crates.winapi_util."0.1.2" = deps: { features?(features_.winapi_util."0.1.2" deps {}) }: buildRustCrate {
    crateName = "winapi-util";
    version = "0.1.2";
    description = "A dumping ground for high level safe wrappers over winapi.";
    authors = [ "Andrew Gallant <jamslam@gmail.com>" ];
    sha256 = "07jj7rg7nndd7bqhjin1xphbv8kb5clvhzpqpxkvm3wl84r3mj1h";
    dependencies = (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."winapi_util"."0.1.2"."winapi"}" deps)
    ]) else []);
  };
  features_.winapi_util."0.1.2" = deps: f: updateFeatures f (rec {
    winapi = fold recursiveUpdate {} [
      { "${deps.winapi_util."0.1.2".winapi}"."consoleapi" = true; }
      { "${deps.winapi_util."0.1.2".winapi}"."errhandlingapi" = true; }
      { "${deps.winapi_util."0.1.2".winapi}"."fileapi" = true; }
      { "${deps.winapi_util."0.1.2".winapi}"."minwindef" = true; }
      { "${deps.winapi_util."0.1.2".winapi}"."processenv" = true; }
      { "${deps.winapi_util."0.1.2".winapi}"."std" = true; }
      { "${deps.winapi_util."0.1.2".winapi}"."winbase" = true; }
      { "${deps.winapi_util."0.1.2".winapi}"."wincon" = true; }
      { "${deps.winapi_util."0.1.2".winapi}"."winerror" = true; }
      { "${deps.winapi_util."0.1.2".winapi}"."winnt" = true; }
      { "${deps.winapi_util."0.1.2".winapi}".default = true; }
    ];
    winapi_util."0.1.2".default = (f.winapi_util."0.1.2".default or true);
  }) [
    (features_.winapi."${deps."winapi_util"."0.1.2"."winapi"}" deps)
  ];


# end
# winapi-x86_64-pc-windows-gnu-0.4.0

  crates.winapi_x86_64_pc_windows_gnu."0.4.0" = deps: { features?(features_.winapi_x86_64_pc_windows_gnu."0.4.0" deps {}) }: buildRustCrate {
    crateName = "winapi-x86_64-pc-windows-gnu";
    version = "0.4.0";
    description = "Import libraries for the x86_64-pc-windows-gnu target. Please don't use this crate directly, depend on winapi instead.";
    authors = [ "Peter Atashian <retep998@gmail.com>" ];
    sha256 = "0n1ylmlsb8yg1v583i4xy0qmqg42275flvbc51hdqjjfjcl9vlbj";
    build = "build.rs";
  };
  features_.winapi_x86_64_pc_windows_gnu."0.4.0" = deps: f: updateFeatures f (rec {
    winapi_x86_64_pc_windows_gnu."0.4.0".default = (f.winapi_x86_64_pc_windows_gnu."0.4.0".default or true);
  }) [];


# end
# wincolor-1.0.1

  crates.wincolor."1.0.1" = deps: { features?(features_.wincolor."1.0.1" deps {}) }: buildRustCrate {
    crateName = "wincolor";
    version = "1.0.1";
    description = "A simple Windows specific API for controlling text color in a Windows console.\n";
    authors = [ "Andrew Gallant <jamslam@gmail.com>" ];
    sha256 = "0gr7v4krmjba7yq16071rfacz42qbapas7mxk5nphjwb042a8gvz";
    dependencies = mapFeatures features ([
      (crates."winapi"."${deps."wincolor"."1.0.1"."winapi"}" deps)
      (crates."winapi_util"."${deps."wincolor"."1.0.1"."winapi_util"}" deps)
    ]);
  };
  features_.wincolor."1.0.1" = deps: f: updateFeatures f (rec {
    winapi = fold recursiveUpdate {} [
      { "${deps.wincolor."1.0.1".winapi}"."minwindef" = true; }
      { "${deps.wincolor."1.0.1".winapi}"."wincon" = true; }
      { "${deps.wincolor."1.0.1".winapi}".default = true; }
    ];
    winapi_util."${deps.wincolor."1.0.1".winapi_util}".default = true;
    wincolor."1.0.1".default = (f.wincolor."1.0.1".default or true);
  }) [
    (features_.winapi."${deps."wincolor"."1.0.1"."winapi"}" deps)
    (features_.winapi_util."${deps."wincolor"."1.0.1"."winapi_util"}" deps)
  ];


# end
# ws2_32-sys-0.2.1

  crates.ws2_32_sys."0.2.1" = deps: { features?(features_.ws2_32_sys."0.2.1" deps {}) }: buildRustCrate {
    crateName = "ws2_32-sys";
    version = "0.2.1";
    description = "Contains function definitions for the Windows API library ws2_32. See winapi for types and constants.";
    authors = [ "Peter Atashian <retep998@gmail.com>" ];
    sha256 = "1zpy9d9wk11sj17fczfngcj28w4xxjs3b4n036yzpy38dxp4f7kc";
    libName = "ws2_32";
    build = "build.rs";
    dependencies = mapFeatures features ([
      (crates."winapi"."${deps."ws2_32_sys"."0.2.1"."winapi"}" deps)
    ]);

    buildDependencies = mapFeatures features ([
      (crates."winapi_build"."${deps."ws2_32_sys"."0.2.1"."winapi_build"}" deps)
    ]);
  };
  features_.ws2_32_sys."0.2.1" = deps: f: updateFeatures f (rec {
    winapi."${deps.ws2_32_sys."0.2.1".winapi}".default = true;
    winapi_build."${deps.ws2_32_sys."0.2.1".winapi_build}".default = true;
    ws2_32_sys."0.2.1".default = (f.ws2_32_sys."0.2.1".default or true);
  }) [
    (features_.winapi."${deps."ws2_32_sys"."0.2.1"."winapi"}" deps)
    (features_.winapi_build."${deps."ws2_32_sys"."0.2.1"."winapi_build"}" deps)
  ];


# end
}
