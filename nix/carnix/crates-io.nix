{ lib, buildRustCrate, buildRustCrateHelpers }:
with buildRustCrateHelpers;
let inherit (lib.lists) fold;
    inherit (lib.attrsets) recursiveUpdate;
in
rec {

# aho-corasick-0.7.6

  crates.aho_corasick."0.7.6" = deps: { features?(features_.aho_corasick."0.7.6" deps {}) }: buildRustCrate {
    crateName = "aho-corasick";
    version = "0.7.6";
    description = "Fast multiple substring searching.";
    authors = [ "Andrew Gallant <jamslam@gmail.com>" ];
    sha256 = "1srdggg7iawz7rfyb79qfnz6vmzkgl6g6gabyd9ad6pbx7zzj8gz";
    libName = "aho_corasick";
    dependencies = mapFeatures features ([
      (crates."memchr"."${deps."aho_corasick"."0.7.6"."memchr"}" deps)
    ]);
    features = mkFeatures (features."aho_corasick"."0.7.6" or {});
  };
  features_.aho_corasick."0.7.6" = deps: f: updateFeatures f (rec {
    aho_corasick = fold recursiveUpdate {} [
      { "0.7.6"."std" =
        (f.aho_corasick."0.7.6"."std" or false) ||
        (f.aho_corasick."0.7.6".default or false) ||
        (aho_corasick."0.7.6"."default" or false); }
      { "0.7.6".default = (f.aho_corasick."0.7.6".default or true); }
    ];
    memchr = fold recursiveUpdate {} [
      { "${deps.aho_corasick."0.7.6".memchr}"."use_std" =
        (f.memchr."${deps.aho_corasick."0.7.6".memchr}"."use_std" or false) ||
        (aho_corasick."0.7.6"."std" or false) ||
        (f."aho_corasick"."0.7.6"."std" or false); }
      { "${deps.aho_corasick."0.7.6".memchr}".default = (f.memchr."${deps.aho_corasick."0.7.6".memchr}".default or false); }
    ];
  }) [
    (features_.memchr."${deps."aho_corasick"."0.7.6"."memchr"}" deps)
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
# ansi_term-0.12.1

  crates.ansi_term."0.12.1" = deps: { features?(features_.ansi_term."0.12.1" deps {}) }: buildRustCrate {
    crateName = "ansi_term";
    version = "0.12.1";
    description = "Library for ANSI terminal colours and styles (bold, underline)";
    authors = [ "ogham@bsago.me" "Ryan Scheel (Havvy) <ryan.havvy@gmail.com>" "Josh Triplett <josh@joshtriplett.org>" ];
    sha256 = "1ggb7gsm8qgav5mqsmwrx64rfk2548v32id92qsag48xwhh34m9i";
    dependencies = mapFeatures features ([
])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."ansi_term"."0.12.1"."winapi"}" deps)
    ]) else []);
    features = mkFeatures (features."ansi_term"."0.12.1" or {});
  };
  features_.ansi_term."0.12.1" = deps: f: updateFeatures f (rec {
    ansi_term = fold recursiveUpdate {} [
      { "0.12.1"."serde" =
        (f.ansi_term."0.12.1"."serde" or false) ||
        (f.ansi_term."0.12.1".derive_serde_style or false) ||
        (ansi_term."0.12.1"."derive_serde_style" or false); }
      { "0.12.1".default = (f.ansi_term."0.12.1".default or true); }
    ];
    winapi = fold recursiveUpdate {} [
      { "${deps.ansi_term."0.12.1".winapi}"."consoleapi" = true; }
      { "${deps.ansi_term."0.12.1".winapi}"."errhandlingapi" = true; }
      { "${deps.ansi_term."0.12.1".winapi}"."fileapi" = true; }
      { "${deps.ansi_term."0.12.1".winapi}"."handleapi" = true; }
      { "${deps.ansi_term."0.12.1".winapi}"."processenv" = true; }
      { "${deps.ansi_term."0.12.1".winapi}".default = true; }
    ];
  }) [
    (features_.winapi."${deps."ansi_term"."0.12.1"."winapi"}" deps)
  ];


# end
# anymap-0.12.1

  crates.anymap."0.12.1" = deps: { features?(features_.anymap."0.12.1" deps {}) }: buildRustCrate {
    crateName = "anymap";
    version = "0.12.1";
    description = "A safe and convenient store for one value of each type";
    authors = [ "Chris Morgan <me@chrismorgan.info>" ];
    sha256 = "08l2xa6ini8nbd4y997cayr0ibh23209il5zn6j516q1pcb1wiwi";
    features = mkFeatures (features."anymap"."0.12.1" or {});
  };
  features_.anymap."0.12.1" = deps: f: updateFeatures f (rec {
    anymap."0.12.1".default = (f.anymap."0.12.1".default or true);
  }) [];


# end
# arc-swap-0.4.4

  crates.arc_swap."0.4.4" = deps: { features?(features_.arc_swap."0.4.4" deps {}) }: buildRustCrate {
    crateName = "arc-swap";
    version = "0.4.4";
    description = "Atomically swappable Arc";
    authors = [ "Michal 'vorner' Vaner <vorner@vorner.cz>" ];
    sha256 = "1hkqmz1f5y28ir5bxgv75sa3i1q5kgdvrd8fyhhp7ip9mbx9gb90";
    features = mkFeatures (features."arc_swap"."0.4.4" or {});
  };
  features_.arc_swap."0.4.4" = deps: f: updateFeatures f (rec {
    arc_swap."0.4.4".default = (f.arc_swap."0.4.4".default or true);
  }) [];


# end
# arrayref-0.3.5

  crates.arrayref."0.3.5" = deps: { features?(features_.arrayref."0.3.5" deps {}) }: buildRustCrate {
    crateName = "arrayref";
    version = "0.3.5";
    description = "Macros to take array references of slices";
    authors = [ "David Roundy <roundyd@physics.oregonstate.edu>" ];
    sha256 = "00dfn9lbr4pc524imc25v3rbmswiqk3jldsgmx4rdngcpxb8ssjf";
  };
  features_.arrayref."0.3.5" = deps: f: updateFeatures f (rec {
    arrayref."0.3.5".default = (f.arrayref."0.3.5".default or true);
  }) [];


# end
# arrayvec-0.5.1

  crates.arrayvec."0.5.1" = deps: { features?(features_.arrayvec."0.5.1" deps {}) }: buildRustCrate {
    crateName = "arrayvec";
    version = "0.5.1";
    description = "A vector with fixed capacity, backed by an array (it can be stored on the stack too). Implements fixed capacity ArrayVec and ArrayString.";
    authors = [ "bluss" ];
    edition = "2018";
    sha256 = "01fc06ab7zh75z26m2l4a0fc7zy4zpr962qazdcp9hl4fgdwbj6v";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."arrayvec"."0.5.1" or {});
  };
  features_.arrayvec."0.5.1" = deps: f: updateFeatures f (rec {
    arrayvec = fold recursiveUpdate {} [
      { "0.5.1"."std" =
        (f.arrayvec."0.5.1"."std" or false) ||
        (f.arrayvec."0.5.1".default or false) ||
        (arrayvec."0.5.1"."default" or false); }
      { "0.5.1".default = (f.arrayvec."0.5.1".default or true); }
    ];
  }) [];


# end
# atomicwrites-0.2.5

  crates.atomicwrites."0.2.5" = deps: { features?(features_.atomicwrites."0.2.5" deps {}) }: buildRustCrate {
    crateName = "atomicwrites";
    version = "0.2.5";
    description = "Atomic file-writes.";
    authors = [ "Markus Unterwaditzer <markus@unterwaditzer.net>" ];
    sha256 = "117276ag68iyfs5c90vfhb10klmwzs7rqx6clvh124wh4717fgvd";
    dependencies = mapFeatures features ([
      (crates."tempdir"."${deps."atomicwrites"."0.2.5"."tempdir"}" deps)
    ])
      ++ (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
      (crates."nix"."${deps."atomicwrites"."0.2.5"."nix"}" deps)
    ]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."atomicwrites"."0.2.5"."winapi"}" deps)
    ]) else []);
  };
  features_.atomicwrites."0.2.5" = deps: f: updateFeatures f (rec {
    atomicwrites."0.2.5".default = (f.atomicwrites."0.2.5".default or true);
    nix."${deps.atomicwrites."0.2.5".nix}".default = true;
    tempdir."${deps.atomicwrites."0.2.5".tempdir}".default = true;
    winapi = fold recursiveUpdate {} [
      { "${deps.atomicwrites."0.2.5".winapi}"."winbase" = true; }
      { "${deps.atomicwrites."0.2.5".winapi}".default = true; }
    ];
  }) [
    (features_.tempdir."${deps."atomicwrites"."0.2.5"."tempdir"}" deps)
    (features_.nix."${deps."atomicwrites"."0.2.5"."nix"}" deps)
    (features_.winapi."${deps."atomicwrites"."0.2.5"."winapi"}" deps)
  ];


# end
# atty-0.2.13

  crates.atty."0.2.13" = deps: { features?(features_.atty."0.2.13" deps {}) }: buildRustCrate {
    crateName = "atty";
    version = "0.2.13";
    description = "A simple interface for querying atty";
    authors = [ "softprops <d.tangren@gmail.com>" ];
    sha256 = "0a1ii8h9fvvrq05bz7j135zjjz1sjz6n2invn2ngxqri0jxgmip2";
    dependencies = (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
      (crates."libc"."${deps."atty"."0.2.13"."libc"}" deps)
    ]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."atty"."0.2.13"."winapi"}" deps)
    ]) else []);
  };
  features_.atty."0.2.13" = deps: f: updateFeatures f (rec {
    atty."0.2.13".default = (f.atty."0.2.13".default or true);
    libc."${deps.atty."0.2.13".libc}".default = (f.libc."${deps.atty."0.2.13".libc}".default or false);
    winapi = fold recursiveUpdate {} [
      { "${deps.atty."0.2.13".winapi}"."consoleapi" = true; }
      { "${deps.atty."0.2.13".winapi}"."minwinbase" = true; }
      { "${deps.atty."0.2.13".winapi}"."minwindef" = true; }
      { "${deps.atty."0.2.13".winapi}"."processenv" = true; }
      { "${deps.atty."0.2.13".winapi}"."winbase" = true; }
      { "${deps.atty."0.2.13".winapi}".default = true; }
    ];
  }) [
    (features_.libc."${deps."atty"."0.2.13"."libc"}" deps)
    (features_.winapi."${deps."atty"."0.2.13"."winapi"}" deps)
  ];


# end
# autocfg-0.1.7

  crates.autocfg."0.1.7" = deps: { features?(features_.autocfg."0.1.7" deps {}) }: buildRustCrate {
    crateName = "autocfg";
    version = "0.1.7";
    description = "Automatic cfg for Rust compiler features";
    authors = [ "Josh Stone <cuviper@gmail.com>" ];
    sha256 = "01iq4rs9kanj88pbwjxzqp5k4bgdsvz3y398nljz441rfws11mi4";
  };
  features_.autocfg."0.1.7" = deps: f: updateFeatures f (rec {
    autocfg."0.1.7".default = (f.autocfg."0.1.7".default or true);
  }) [];


# end
# backtrace-0.3.40

  crates.backtrace."0.3.40" = deps: { features?(features_.backtrace."0.3.40" deps {}) }: buildRustCrate {
    crateName = "backtrace";
    version = "0.3.40";
    description = "A library to acquire a stack trace (backtrace) at runtime in a Rust program.\n";
    authors = [ "The Rust Project Developers" ];
    edition = "2018";
    sha256 = "0xzgw3vldpfcfhsxs17jx3l6vacfxm93g3l363k5vk0nc7avgzar";
    dependencies = mapFeatures features ([
      (crates."cfg_if"."${deps."backtrace"."0.3.40"."cfg_if"}" deps)
      (crates."libc"."${deps."backtrace"."0.3.40"."libc"}" deps)
      (crates."rustc_demangle"."${deps."backtrace"."0.3.40"."rustc_demangle"}" deps)
    ]
      ++ (if features.backtrace."0.3.40".backtrace-sys or false then [ (crates.backtrace_sys."${deps."backtrace"."0.3.40".backtrace_sys}" deps) ] else []))
      ++ (if kernel == "windows" then mapFeatures features ([
]) else []);
    features = mkFeatures (features."backtrace"."0.3.40" or {});
  };
  features_.backtrace."0.3.40" = deps: f: updateFeatures f (rec {
    backtrace = fold recursiveUpdate {} [
      { "0.3.40"."addr2line" =
        (f.backtrace."0.3.40"."addr2line" or false) ||
        (f.backtrace."0.3.40".gimli-symbolize or false) ||
        (backtrace."0.3.40"."gimli-symbolize" or false); }
      { "0.3.40"."backtrace-sys" =
        (f.backtrace."0.3.40"."backtrace-sys" or false) ||
        (f.backtrace."0.3.40".libbacktrace or false) ||
        (backtrace."0.3.40"."libbacktrace" or false); }
      { "0.3.40"."compiler_builtins" =
        (f.backtrace."0.3.40"."compiler_builtins" or false) ||
        (f.backtrace."0.3.40".rustc-dep-of-std or false) ||
        (backtrace."0.3.40"."rustc-dep-of-std" or false); }
      { "0.3.40"."core" =
        (f.backtrace."0.3.40"."core" or false) ||
        (f.backtrace."0.3.40".rustc-dep-of-std or false) ||
        (backtrace."0.3.40"."rustc-dep-of-std" or false); }
      { "0.3.40"."dbghelp" =
        (f.backtrace."0.3.40"."dbghelp" or false) ||
        (f.backtrace."0.3.40".default or false) ||
        (backtrace."0.3.40"."default" or false); }
      { "0.3.40"."dladdr" =
        (f.backtrace."0.3.40"."dladdr" or false) ||
        (f.backtrace."0.3.40".default or false) ||
        (backtrace."0.3.40"."default" or false); }
      { "0.3.40"."findshlibs" =
        (f.backtrace."0.3.40"."findshlibs" or false) ||
        (f.backtrace."0.3.40".gimli-symbolize or false) ||
        (backtrace."0.3.40"."gimli-symbolize" or false); }
      { "0.3.40"."goblin" =
        (f.backtrace."0.3.40"."goblin" or false) ||
        (f.backtrace."0.3.40".gimli-symbolize or false) ||
        (backtrace."0.3.40"."gimli-symbolize" or false); }
      { "0.3.40"."libbacktrace" =
        (f.backtrace."0.3.40"."libbacktrace" or false) ||
        (f.backtrace."0.3.40".default or false) ||
        (backtrace."0.3.40"."default" or false); }
      { "0.3.40"."libunwind" =
        (f.backtrace."0.3.40"."libunwind" or false) ||
        (f.backtrace."0.3.40".default or false) ||
        (backtrace."0.3.40"."default" or false); }
      { "0.3.40"."memmap" =
        (f.backtrace."0.3.40"."memmap" or false) ||
        (f.backtrace."0.3.40".gimli-symbolize or false) ||
        (backtrace."0.3.40"."gimli-symbolize" or false); }
      { "0.3.40"."rustc-serialize" =
        (f.backtrace."0.3.40"."rustc-serialize" or false) ||
        (f.backtrace."0.3.40".serialize-rustc or false) ||
        (backtrace."0.3.40"."serialize-rustc" or false); }
      { "0.3.40"."serde" =
        (f.backtrace."0.3.40"."serde" or false) ||
        (f.backtrace."0.3.40".serialize-serde or false) ||
        (backtrace."0.3.40"."serialize-serde" or false); }
      { "0.3.40"."std" =
        (f.backtrace."0.3.40"."std" or false) ||
        (f.backtrace."0.3.40".default or false) ||
        (backtrace."0.3.40"."default" or false); }
      { "0.3.40".default = (f.backtrace."0.3.40".default or true); }
    ];
    backtrace_sys = fold recursiveUpdate {} [
      { "${deps.backtrace."0.3.40".backtrace_sys}"."rustc-dep-of-std" =
        (f.backtrace_sys."${deps.backtrace."0.3.40".backtrace_sys}"."rustc-dep-of-std" or false) ||
        (backtrace."0.3.40"."rustc-dep-of-std" or false) ||
        (f."backtrace"."0.3.40"."rustc-dep-of-std" or false); }
      { "${deps.backtrace."0.3.40".backtrace_sys}".default = true; }
    ];
    cfg_if = fold recursiveUpdate {} [
      { "${deps.backtrace."0.3.40".cfg_if}"."rustc-dep-of-std" =
        (f.cfg_if."${deps.backtrace."0.3.40".cfg_if}"."rustc-dep-of-std" or false) ||
        (backtrace."0.3.40"."rustc-dep-of-std" or false) ||
        (f."backtrace"."0.3.40"."rustc-dep-of-std" or false); }
      { "${deps.backtrace."0.3.40".cfg_if}".default = true; }
    ];
    libc = fold recursiveUpdate {} [
      { "${deps.backtrace."0.3.40".libc}"."rustc-dep-of-std" =
        (f.libc."${deps.backtrace."0.3.40".libc}"."rustc-dep-of-std" or false) ||
        (backtrace."0.3.40"."rustc-dep-of-std" or false) ||
        (f."backtrace"."0.3.40"."rustc-dep-of-std" or false); }
      { "${deps.backtrace."0.3.40".libc}".default = (f.libc."${deps.backtrace."0.3.40".libc}".default or false); }
    ];
    rustc_demangle = fold recursiveUpdate {} [
      { "${deps.backtrace."0.3.40".rustc_demangle}"."rustc-dep-of-std" =
        (f.rustc_demangle."${deps.backtrace."0.3.40".rustc_demangle}"."rustc-dep-of-std" or false) ||
        (backtrace."0.3.40"."rustc-dep-of-std" or false) ||
        (f."backtrace"."0.3.40"."rustc-dep-of-std" or false); }
      { "${deps.backtrace."0.3.40".rustc_demangle}".default = true; }
    ];
  }) [
    (features_.backtrace_sys."${deps."backtrace"."0.3.40"."backtrace_sys"}" deps)
    (features_.cfg_if."${deps."backtrace"."0.3.40"."cfg_if"}" deps)
    (features_.libc."${deps."backtrace"."0.3.40"."libc"}" deps)
    (features_.rustc_demangle."${deps."backtrace"."0.3.40"."rustc_demangle"}" deps)
  ];


# end
# backtrace-sys-0.1.32

  crates.backtrace_sys."0.1.32" = deps: { features?(features_.backtrace_sys."0.1.32" deps {}) }: buildRustCrate {
    crateName = "backtrace-sys";
    version = "0.1.32";
    description = "Bindings to the libbacktrace gcc library\n";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    sha256 = "1jrb7450v9kyqrjc97vzckbpwj9jakvc1jkq95i46g6mn9kvqkgr";
    build = "build.rs";
    dependencies = mapFeatures features ([
      (crates."libc"."${deps."backtrace_sys"."0.1.32"."libc"}" deps)
    ]);

    buildDependencies = mapFeatures features ([
      (crates."cc"."${deps."backtrace_sys"."0.1.32"."cc"}" deps)
    ]);
    features = mkFeatures (features."backtrace_sys"."0.1.32" or {});
  };
  features_.backtrace_sys."0.1.32" = deps: f: updateFeatures f (rec {
    backtrace_sys = fold recursiveUpdate {} [
      { "0.1.32"."compiler_builtins" =
        (f.backtrace_sys."0.1.32"."compiler_builtins" or false) ||
        (f.backtrace_sys."0.1.32".rustc-dep-of-std or false) ||
        (backtrace_sys."0.1.32"."rustc-dep-of-std" or false); }
      { "0.1.32"."core" =
        (f.backtrace_sys."0.1.32"."core" or false) ||
        (f.backtrace_sys."0.1.32".rustc-dep-of-std or false) ||
        (backtrace_sys."0.1.32"."rustc-dep-of-std" or false); }
      { "0.1.32".default = (f.backtrace_sys."0.1.32".default or true); }
    ];
    cc."${deps.backtrace_sys."0.1.32".cc}".default = true;
    libc."${deps.backtrace_sys."0.1.32".libc}".default = (f.libc."${deps.backtrace_sys."0.1.32".libc}".default or false);
  }) [
    (features_.libc."${deps."backtrace_sys"."0.1.32"."libc"}" deps)
    (features_.cc."${deps."backtrace_sys"."0.1.32"."cc"}" deps)
  ];


# end
# base64-0.10.1

  crates.base64."0.10.1" = deps: { features?(features_.base64."0.10.1" deps {}) }: buildRustCrate {
    crateName = "base64";
    version = "0.10.1";
    description = "encodes and decodes base64 as bytes or utf8";
    authors = [ "Alice Maz <alice@alicemaz.com>" "Marshall Pierce <marshall@mpierce.org>" ];
    sha256 = "1zz3jq619hahla1f70ra38818b5n8cp4iilij81i90jq6z7hlfhg";
    dependencies = mapFeatures features ([
      (crates."byteorder"."${deps."base64"."0.10.1"."byteorder"}" deps)
    ]);
  };
  features_.base64."0.10.1" = deps: f: updateFeatures f (rec {
    base64."0.10.1".default = (f.base64."0.10.1".default or true);
    byteorder."${deps.base64."0.10.1".byteorder}".default = true;
  }) [
    (features_.byteorder."${deps."base64"."0.10.1"."byteorder"}" deps)
  ];


# end
# bincode-1.2.0

  crates.bincode."1.2.0" = deps: { features?(features_.bincode."1.2.0" deps {}) }: buildRustCrate {
    crateName = "bincode";
    version = "1.2.0";
    description = "A binary serialization / deserialization strategy that uses Serde for transforming structs into bytes and vice versa!";
    authors = [ "Ty Overby <ty@pre-alpha.com>" "Francesco Mazzoli <f@mazzo.li>" "David Tolnay <dtolnay@gmail.com>" "Daniel Griffen" ];
    sha256 = "0sfk6drrivn6xij8w6krskhn7fa5bq2jjvlvl7ipnsvjz3l1l949";
    build = "build.rs";
    dependencies = mapFeatures features ([
      (crates."byteorder"."${deps."bincode"."1.2.0"."byteorder"}" deps)
      (crates."serde"."${deps."bincode"."1.2.0"."serde"}" deps)
    ]);

    buildDependencies = mapFeatures features ([
      (crates."autocfg"."${deps."bincode"."1.2.0"."autocfg"}" deps)
    ]);
    features = mkFeatures (features."bincode"."1.2.0" or {});
  };
  features_.bincode."1.2.0" = deps: f: updateFeatures f (rec {
    autocfg."${deps.bincode."1.2.0".autocfg}".default = true;
    bincode."1.2.0".default = (f.bincode."1.2.0".default or true);
    byteorder."${deps.bincode."1.2.0".byteorder}".default = true;
    serde."${deps.bincode."1.2.0".serde}".default = true;
  }) [
    (features_.byteorder."${deps."bincode"."1.2.0"."byteorder"}" deps)
    (features_.serde."${deps."bincode"."1.2.0"."serde"}" deps)
    (features_.autocfg."${deps."bincode"."1.2.0"."autocfg"}" deps)
  ];


# end
# bit-set-0.5.1

  crates.bit_set."0.5.1" = deps: { features?(features_.bit_set."0.5.1" deps {}) }: buildRustCrate {
    crateName = "bit-set";
    version = "0.5.1";
    description = "A set of bits";
    authors = [ "Alexis Beingessner <a.beingessner@gmail.com>" ];
    sha256 = "1f6x1kv5bw1kkq3ms0vj6wf5jazq9390i23ywnjszm6h2x4qani1";
    dependencies = mapFeatures features ([
      (crates."bit_vec"."${deps."bit_set"."0.5.1"."bit_vec"}" deps)
    ]);
    features = mkFeatures (features."bit_set"."0.5.1" or {});
  };
  features_.bit_set."0.5.1" = deps: f: updateFeatures f (rec {
    bit_set = fold recursiveUpdate {} [
      { "0.5.1"."std" =
        (f.bit_set."0.5.1"."std" or false) ||
        (f.bit_set."0.5.1".default or false) ||
        (bit_set."0.5.1"."default" or false); }
      { "0.5.1".default = (f.bit_set."0.5.1".default or true); }
    ];
    bit_vec = fold recursiveUpdate {} [
      { "${deps.bit_set."0.5.1".bit_vec}"."nightly" =
        (f.bit_vec."${deps.bit_set."0.5.1".bit_vec}"."nightly" or false) ||
        (bit_set."0.5.1"."nightly" or false) ||
        (f."bit_set"."0.5.1"."nightly" or false); }
      { "${deps.bit_set."0.5.1".bit_vec}"."std" =
        (f.bit_vec."${deps.bit_set."0.5.1".bit_vec}"."std" or false) ||
        (bit_set."0.5.1"."std" or false) ||
        (f."bit_set"."0.5.1"."std" or false); }
      { "${deps.bit_set."0.5.1".bit_vec}".default = (f.bit_vec."${deps.bit_set."0.5.1".bit_vec}".default or false); }
    ];
  }) [
    (features_.bit_vec."${deps."bit_set"."0.5.1"."bit_vec"}" deps)
  ];


# end
# bit-vec-0.5.1

  crates.bit_vec."0.5.1" = deps: { features?(features_.bit_vec."0.5.1" deps {}) }: buildRustCrate {
    crateName = "bit-vec";
    version = "0.5.1";
    description = "A vector of bits";
    authors = [ "Alexis Beingessner <a.beingessner@gmail.com>" ];
    sha256 = "1irsn05qn4c7rd903ph69xvsa69b36mj76fl5n2nvjd847cw7ypa";
    features = mkFeatures (features."bit_vec"."0.5.1" or {});
  };
  features_.bit_vec."0.5.1" = deps: f: updateFeatures f (rec {
    bit_vec = fold recursiveUpdate {} [
      { "0.5.1"."std" =
        (f.bit_vec."0.5.1"."std" or false) ||
        (f.bit_vec."0.5.1".default or false) ||
        (bit_vec."0.5.1"."default" or false); }
      { "0.5.1".default = (f.bit_vec."0.5.1".default or true); }
    ];
  }) [];


# end
# bitflags-1.2.1

  crates.bitflags."1.2.1" = deps: { features?(features_.bitflags."1.2.1" deps {}) }: buildRustCrate {
    crateName = "bitflags";
    version = "1.2.1";
    description = "A macro to generate structures which behave like bitflags.\n";
    authors = [ "The Rust Project Developers" ];
    sha256 = "0b77awhpn7yaqjjibm69ginfn996azx5vkzfjj39g3wbsqs7mkxg";
    build = "build.rs";
    features = mkFeatures (features."bitflags"."1.2.1" or {});
  };
  features_.bitflags."1.2.1" = deps: f: updateFeatures f (rec {
    bitflags."1.2.1".default = (f.bitflags."1.2.1".default or true);
  }) [];


# end
# blake2b_simd-0.5.9

  crates.blake2b_simd."0.5.9" = deps: { features?(features_.blake2b_simd."0.5.9" deps {}) }: buildRustCrate {
    crateName = "blake2b_simd";
    version = "0.5.9";
    description = "a pure Rust BLAKE2b implementation with dynamic SIMD";
    authors = [ "Jack O'Connor" ];
    edition = "2018";
    sha256 = "02yzvnjmw8mvv4mdd7azpzqjlcf1z7jn7bp20l2qhkvy735ffpyg";
    dependencies = mapFeatures features ([
      (crates."arrayref"."${deps."blake2b_simd"."0.5.9"."arrayref"}" deps)
      (crates."arrayvec"."${deps."blake2b_simd"."0.5.9"."arrayvec"}" deps)
      (crates."constant_time_eq"."${deps."blake2b_simd"."0.5.9"."constant_time_eq"}" deps)
    ]);
    features = mkFeatures (features."blake2b_simd"."0.5.9" or {});
  };
  features_.blake2b_simd."0.5.9" = deps: f: updateFeatures f (rec {
    arrayref."${deps.blake2b_simd."0.5.9".arrayref}".default = true;
    arrayvec."${deps.blake2b_simd."0.5.9".arrayvec}".default = (f.arrayvec."${deps.blake2b_simd."0.5.9".arrayvec}".default or false);
    blake2b_simd = fold recursiveUpdate {} [
      { "0.5.9"."std" =
        (f.blake2b_simd."0.5.9"."std" or false) ||
        (f.blake2b_simd."0.5.9".default or false) ||
        (blake2b_simd."0.5.9"."default" or false); }
      { "0.5.9".default = (f.blake2b_simd."0.5.9".default or true); }
    ];
    constant_time_eq."${deps.blake2b_simd."0.5.9".constant_time_eq}".default = true;
  }) [
    (features_.arrayref."${deps."blake2b_simd"."0.5.9"."arrayref"}" deps)
    (features_.arrayvec."${deps."blake2b_simd"."0.5.9"."arrayvec"}" deps)
    (features_.constant_time_eq."${deps."blake2b_simd"."0.5.9"."constant_time_eq"}" deps)
  ];


# end
# byteorder-1.3.2

  crates.byteorder."1.3.2" = deps: { features?(features_.byteorder."1.3.2" deps {}) }: buildRustCrate {
    crateName = "byteorder";
    version = "1.3.2";
    description = "Library for reading/writing numbers in big-endian and little-endian.";
    authors = [ "Andrew Gallant <jamslam@gmail.com>" ];
    sha256 = "099fxwc79ncpcl8dgg9hql8gznz11a3sjs7pai0mg6w8r05khvdx";
    build = "build.rs";
    features = mkFeatures (features."byteorder"."1.3.2" or {});
  };
  features_.byteorder."1.3.2" = deps: f: updateFeatures f (rec {
    byteorder = fold recursiveUpdate {} [
      { "1.3.2"."std" =
        (f.byteorder."1.3.2"."std" or false) ||
        (f.byteorder."1.3.2".default or false) ||
        (byteorder."1.3.2"."default" or false); }
      { "1.3.2".default = (f.byteorder."1.3.2".default or true); }
    ];
  }) [];


# end
# bytes-0.5.2

  crates.bytes."0.5.2" = deps: { features?(features_.bytes."0.5.2" deps {}) }: buildRustCrate {
    crateName = "bytes";
    version = "0.5.2";
    description = "Types and traits for working with bytes";
    authors = [ "Carl Lerche <me@carllerche.com>" ];
    edition = "2018";
    sha256 = "1fkz2cj2s3jcmds88fsdgi56lb17rj890gb840x4mi1l1wfshh90";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."bytes"."0.5.2" or {});
  };
  features_.bytes."0.5.2" = deps: f: updateFeatures f (rec {
    bytes = fold recursiveUpdate {} [
      { "0.5.2"."std" =
        (f.bytes."0.5.2"."std" or false) ||
        (f.bytes."0.5.2".default or false) ||
        (bytes."0.5.2"."default" or false); }
      { "0.5.2".default = (f.bytes."0.5.2".default or true); }
    ];
  }) [];


# end
# c2-chacha-0.2.3

  crates.c2_chacha."0.2.3" = deps: { features?(features_.c2_chacha."0.2.3" deps {}) }: buildRustCrate {
    crateName = "c2-chacha";
    version = "0.2.3";
    description = "The ChaCha family of stream ciphers";
    authors = [ "The CryptoCorrosion Contributors" ];
    edition = "2018";
    sha256 = "04vh0cc9g94cj6cq96sfv3lks7rx486jdn43rmqcvb2syh4y9dqj";
    dependencies = mapFeatures features ([
      (crates."ppv_lite86"."${deps."c2_chacha"."0.2.3"."ppv_lite86"}" deps)
    ]);
    features = mkFeatures (features."c2_chacha"."0.2.3" or {});
  };
  features_.c2_chacha."0.2.3" = deps: f: updateFeatures f (rec {
    c2_chacha = fold recursiveUpdate {} [
      { "0.2.3"."byteorder" =
        (f.c2_chacha."0.2.3"."byteorder" or false) ||
        (f.c2_chacha."0.2.3".rustcrypto_api or false) ||
        (c2_chacha."0.2.3"."rustcrypto_api" or false); }
      { "0.2.3"."rustcrypto_api" =
        (f.c2_chacha."0.2.3"."rustcrypto_api" or false) ||
        (f.c2_chacha."0.2.3".default or false) ||
        (c2_chacha."0.2.3"."default" or false); }
      { "0.2.3"."simd" =
        (f.c2_chacha."0.2.3"."simd" or false) ||
        (f.c2_chacha."0.2.3".default or false) ||
        (c2_chacha."0.2.3"."default" or false); }
      { "0.2.3"."std" =
        (f.c2_chacha."0.2.3"."std" or false) ||
        (f.c2_chacha."0.2.3".default or false) ||
        (c2_chacha."0.2.3"."default" or false); }
      { "0.2.3"."stream-cipher" =
        (f.c2_chacha."0.2.3"."stream-cipher" or false) ||
        (f.c2_chacha."0.2.3".rustcrypto_api or false) ||
        (c2_chacha."0.2.3"."rustcrypto_api" or false); }
      { "0.2.3".default = (f.c2_chacha."0.2.3".default or true); }
    ];
    ppv_lite86 = fold recursiveUpdate {} [
      { "${deps.c2_chacha."0.2.3".ppv_lite86}"."simd" =
        (f.ppv_lite86."${deps.c2_chacha."0.2.3".ppv_lite86}"."simd" or false) ||
        (c2_chacha."0.2.3"."simd" or false) ||
        (f."c2_chacha"."0.2.3"."simd" or false); }
      { "${deps.c2_chacha."0.2.3".ppv_lite86}"."std" =
        (f.ppv_lite86."${deps.c2_chacha."0.2.3".ppv_lite86}"."std" or false) ||
        (c2_chacha."0.2.3"."std" or false) ||
        (f."c2_chacha"."0.2.3"."std" or false); }
      { "${deps.c2_chacha."0.2.3".ppv_lite86}".default = (f.ppv_lite86."${deps.c2_chacha."0.2.3".ppv_lite86}".default or false); }
    ];
  }) [
    (features_.ppv_lite86."${deps."c2_chacha"."0.2.3"."ppv_lite86"}" deps)
  ];


# end
# cc-1.0.47

  crates.cc."1.0.47" = deps: { features?(features_.cc."1.0.47" deps {}) }: buildRustCrate {
    crateName = "cc";
    version = "1.0.47";
    description = "A build-time dependency for Cargo build scripts to assist in invoking the native\nC compiler to compile native C code into a static archive to be linked into Rust\ncode.\n";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    edition = "2018";
    sha256 = "0s29s8nazjzk6s5dk5i0r5wdrs78fa7maai9y1wfy335wgg4whkf";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."cc"."1.0.47" or {});
  };
  features_.cc."1.0.47" = deps: f: updateFeatures f (rec {
    cc = fold recursiveUpdate {} [
      { "1.0.47"."jobserver" =
        (f.cc."1.0.47"."jobserver" or false) ||
        (f.cc."1.0.47".parallel or false) ||
        (cc."1.0.47"."parallel" or false); }
      { "1.0.47"."num_cpus" =
        (f.cc."1.0.47"."num_cpus" or false) ||
        (f.cc."1.0.47".parallel or false) ||
        (cc."1.0.47"."parallel" or false); }
      { "1.0.47".default = (f.cc."1.0.47".default or true); }
    ];
  }) [];


# end
# cfg-if-0.1.10

  crates.cfg_if."0.1.10" = deps: { features?(features_.cfg_if."0.1.10" deps {}) }: buildRustCrate {
    crateName = "cfg-if";
    version = "0.1.10";
    description = "A macro to ergonomically define an item depending on a large number of #[cfg]\nparameters. Structured like an if-else chain, the first matching branch is the\nitem that gets emitted.\n";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    edition = "2018";
    sha256 = "0x52qzpbyl2f2jqs7kkqzgfki2cpq99gpfjjigdp8pwwfqk01007";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."cfg_if"."0.1.10" or {});
  };
  features_.cfg_if."0.1.10" = deps: f: updateFeatures f (rec {
    cfg_if = fold recursiveUpdate {} [
      { "0.1.10"."compiler_builtins" =
        (f.cfg_if."0.1.10"."compiler_builtins" or false) ||
        (f.cfg_if."0.1.10".rustc-dep-of-std or false) ||
        (cfg_if."0.1.10"."rustc-dep-of-std" or false); }
      { "0.1.10"."core" =
        (f.cfg_if."0.1.10"."core" or false) ||
        (f.cfg_if."0.1.10".rustc-dep-of-std or false) ||
        (cfg_if."0.1.10"."rustc-dep-of-std" or false); }
      { "0.1.10".default = (f.cfg_if."0.1.10".default or true); }
    ];
  }) [];


# end
# chainerror-0.4.3

  crates.chainerror."0.4.3" = deps: { features?(features_.chainerror."0.4.3" deps {}) }: buildRustCrate {
    crateName = "chainerror";
    version = "0.4.3";
    description = "Make chaining errors easy.";
    authors = [ "Harald Hoyer <harald@redhat.com>" ];
    edition = "2018";
    sha256 = "1pysaqv4ll8kfrmj5q9nkd3f4fbxhczp5lgqf175qy7yyhrw741c";
    features = mkFeatures (features."chainerror"."0.4.3" or {});
  };
  features_.chainerror."0.4.3" = deps: f: updateFeatures f (rec {
    chainerror."0.4.3".default = (f.chainerror."0.4.3".default or true);
  }) [];


# end
# chashmap-2.2.2

  crates.chashmap."2.2.2" = deps: { features?(features_.chashmap."2.2.2" deps {}) }: buildRustCrate {
    crateName = "chashmap";
    version = "2.2.2";
    description = "Fast, concurrent hash maps with extensive API.";
    authors = [ "ticki <Ticki@users.noreply.github.com>" ];
    sha256 = "1kf09hv0i8nmqg36fmv255fv7l8grfk8xxk15h7gd5djg4kxjp0x";
    dependencies = mapFeatures features ([
      (crates."owning_ref"."${deps."chashmap"."2.2.2"."owning_ref"}" deps)
      (crates."parking_lot"."${deps."chashmap"."2.2.2"."parking_lot"}" deps)
    ]);
  };
  features_.chashmap."2.2.2" = deps: f: updateFeatures f (rec {
    chashmap."2.2.2".default = (f.chashmap."2.2.2".default or true);
    owning_ref."${deps.chashmap."2.2.2".owning_ref}".default = true;
    parking_lot."${deps.chashmap."2.2.2".parking_lot}".default = true;
  }) [
    (features_.owning_ref."${deps."chashmap"."2.2.2"."owning_ref"}" deps)
    (features_.parking_lot."${deps."chashmap"."2.2.2"."parking_lot"}" deps)
  ];


# end
# chrono-0.4.10

  crates.chrono."0.4.10" = deps: { features?(features_.chrono."0.4.10" deps {}) }: buildRustCrate {
    crateName = "chrono";
    version = "0.4.10";
    description = "Date and time library for Rust";
    authors = [ "Kang Seonghoon <public+rust@mearie.org>" "Brandon W Maister <quodlibetor@gmail.com>" ];
    sha256 = "13yj8csdvzzcrw8g4946rip5wgvviafg6cg01m1r32vgnssb2kr5";
    dependencies = mapFeatures features ([
      (crates."num_integer"."${deps."chrono"."0.4.10"."num_integer"}" deps)
      (crates."num_traits"."${deps."chrono"."0.4.10"."num_traits"}" deps)
    ]
      ++ (if features.chrono."0.4.10".time or false then [ (crates.time."${deps."chrono"."0.4.10".time}" deps) ] else []))
      ++ (if cpu == "wasm32" && !(kernel == "emscripten") then mapFeatures features ([
]) else []);
    features = mkFeatures (features."chrono"."0.4.10" or {});
  };
  features_.chrono."0.4.10" = deps: f: updateFeatures f (rec {
    chrono = fold recursiveUpdate {} [
      { "0.4.10"."clock" =
        (f.chrono."0.4.10"."clock" or false) ||
        (f.chrono."0.4.10".default or false) ||
        (chrono."0.4.10"."default" or false); }
      { "0.4.10"."js-sys" =
        (f.chrono."0.4.10"."js-sys" or false) ||
        (f.chrono."0.4.10".wasmbind or false) ||
        (chrono."0.4.10"."wasmbind" or false); }
      { "0.4.10"."std" =
        (f.chrono."0.4.10"."std" or false) ||
        (f.chrono."0.4.10".bench or false) ||
        (chrono."0.4.10"."bench" or false) ||
        (f.chrono."0.4.10".clock or false) ||
        (chrono."0.4.10"."clock" or false) ||
        (f.chrono."0.4.10".default or false) ||
        (chrono."0.4.10"."default" or false); }
      { "0.4.10"."time" =
        (f.chrono."0.4.10"."time" or false) ||
        (f.chrono."0.4.10".clock or false) ||
        (chrono."0.4.10"."clock" or false); }
      { "0.4.10"."wasm-bindgen" =
        (f.chrono."0.4.10"."wasm-bindgen" or false) ||
        (f.chrono."0.4.10".wasmbind or false) ||
        (chrono."0.4.10"."wasmbind" or false); }
      { "0.4.10".default = (f.chrono."0.4.10".default or true); }
    ];
    num_integer."${deps.chrono."0.4.10".num_integer}".default = (f.num_integer."${deps.chrono."0.4.10".num_integer}".default or false);
    num_traits."${deps.chrono."0.4.10".num_traits}".default = (f.num_traits."${deps.chrono."0.4.10".num_traits}".default or false);
    time."${deps.chrono."0.4.10".time}".default = true;
  }) [
    (features_.num_integer."${deps."chrono"."0.4.10"."num_integer"}" deps)
    (features_.num_traits."${deps."chrono"."0.4.10"."num_traits"}" deps)
    (features_.time."${deps."chrono"."0.4.10"."time"}" deps)
  ];


# end
# clap-2.33.0

  crates.clap."2.33.0" = deps: { features?(features_.clap."2.33.0" deps {}) }: buildRustCrate {
    crateName = "clap";
    version = "2.33.0";
    description = "A simple to use, efficient, and full-featured Command Line Argument Parser\n";
    authors = [ "Kevin K. <kbknapp@gmail.com>" ];
    sha256 = "054n9ngh6pkknpmd4acgdsp40iw6f5jzq8a4h2b76gnbvk6p5xjh";
    dependencies = mapFeatures features ([
      (crates."bitflags"."${deps."clap"."2.33.0"."bitflags"}" deps)
      (crates."textwrap"."${deps."clap"."2.33.0"."textwrap"}" deps)
      (crates."unicode_width"."${deps."clap"."2.33.0"."unicode_width"}" deps)
    ]
      ++ (if features.clap."2.33.0".atty or false then [ (crates.atty."${deps."clap"."2.33.0".atty}" deps) ] else [])
      ++ (if features.clap."2.33.0".strsim or false then [ (crates.strsim."${deps."clap"."2.33.0".strsim}" deps) ] else [])
      ++ (if features.clap."2.33.0".vec_map or false then [ (crates.vec_map."${deps."clap"."2.33.0".vec_map}" deps) ] else []))
      ++ (if !(kernel == "windows") then mapFeatures features ([
    ]
      ++ (if features.clap."2.33.0".ansi_term or false then [ (crates.ansi_term."${deps."clap"."2.33.0".ansi_term}" deps) ] else [])) else []);
    features = mkFeatures (features."clap"."2.33.0" or {});
  };
  features_.clap."2.33.0" = deps: f: updateFeatures f (rec {
    ansi_term."${deps.clap."2.33.0".ansi_term}".default = true;
    atty."${deps.clap."2.33.0".atty}".default = true;
    bitflags."${deps.clap."2.33.0".bitflags}".default = true;
    clap = fold recursiveUpdate {} [
      { "2.33.0"."ansi_term" =
        (f.clap."2.33.0"."ansi_term" or false) ||
        (f.clap."2.33.0".color or false) ||
        (clap."2.33.0"."color" or false); }
      { "2.33.0"."atty" =
        (f.clap."2.33.0"."atty" or false) ||
        (f.clap."2.33.0".color or false) ||
        (clap."2.33.0"."color" or false); }
      { "2.33.0"."clippy" =
        (f.clap."2.33.0"."clippy" or false) ||
        (f.clap."2.33.0".lints or false) ||
        (clap."2.33.0"."lints" or false); }
      { "2.33.0"."color" =
        (f.clap."2.33.0"."color" or false) ||
        (f.clap."2.33.0".default or false) ||
        (clap."2.33.0"."default" or false); }
      { "2.33.0"."strsim" =
        (f.clap."2.33.0"."strsim" or false) ||
        (f.clap."2.33.0".suggestions or false) ||
        (clap."2.33.0"."suggestions" or false); }
      { "2.33.0"."suggestions" =
        (f.clap."2.33.0"."suggestions" or false) ||
        (f.clap."2.33.0".default or false) ||
        (clap."2.33.0"."default" or false); }
      { "2.33.0"."term_size" =
        (f.clap."2.33.0"."term_size" or false) ||
        (f.clap."2.33.0".wrap_help or false) ||
        (clap."2.33.0"."wrap_help" or false); }
      { "2.33.0"."vec_map" =
        (f.clap."2.33.0"."vec_map" or false) ||
        (f.clap."2.33.0".default or false) ||
        (clap."2.33.0"."default" or false); }
      { "2.33.0"."yaml" =
        (f.clap."2.33.0"."yaml" or false) ||
        (f.clap."2.33.0".doc or false) ||
        (clap."2.33.0"."doc" or false); }
      { "2.33.0"."yaml-rust" =
        (f.clap."2.33.0"."yaml-rust" or false) ||
        (f.clap."2.33.0".yaml or false) ||
        (clap."2.33.0"."yaml" or false); }
      { "2.33.0".default = (f.clap."2.33.0".default or true); }
    ];
    strsim."${deps.clap."2.33.0".strsim}".default = true;
    textwrap = fold recursiveUpdate {} [
      { "${deps.clap."2.33.0".textwrap}"."term_size" =
        (f.textwrap."${deps.clap."2.33.0".textwrap}"."term_size" or false) ||
        (clap."2.33.0"."wrap_help" or false) ||
        (f."clap"."2.33.0"."wrap_help" or false); }
      { "${deps.clap."2.33.0".textwrap}".default = true; }
    ];
    unicode_width."${deps.clap."2.33.0".unicode_width}".default = true;
    vec_map."${deps.clap."2.33.0".vec_map}".default = true;
  }) [
    (features_.atty."${deps."clap"."2.33.0"."atty"}" deps)
    (features_.bitflags."${deps."clap"."2.33.0"."bitflags"}" deps)
    (features_.strsim."${deps."clap"."2.33.0"."strsim"}" deps)
    (features_.textwrap."${deps."clap"."2.33.0"."textwrap"}" deps)
    (features_.unicode_width."${deps."clap"."2.33.0"."unicode_width"}" deps)
    (features_.vec_map."${deps."clap"."2.33.0"."vec_map"}" deps)
    (features_.ansi_term."${deps."clap"."2.33.0"."ansi_term"}" deps)
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
# constant_time_eq-0.1.4

  crates.constant_time_eq."0.1.4" = deps: { features?(features_.constant_time_eq."0.1.4" deps {}) }: buildRustCrate {
    crateName = "constant_time_eq";
    version = "0.1.4";
    description = "Compares two equal-sized byte strings in constant time.";
    authors = [ "Cesar Eduardo Barros <cesarb@cesarb.eti.br>" ];
    sha256 = "0k3b5yavx7si8cy030py6bhgmg24sghzs8chbs4d4r13wjp5c5ih";
  };
  features_.constant_time_eq."0.1.4" = deps: f: updateFeatures f (rec {
    constant_time_eq."0.1.4".default = (f.constant_time_eq."0.1.4".default or true);
  }) [];


# end
# crossbeam-channel-0.3.9

  crates.crossbeam_channel."0.3.9" = deps: { features?(features_.crossbeam_channel."0.3.9" deps {}) }: buildRustCrate {
    crateName = "crossbeam-channel";
    version = "0.3.9";
    description = "Multi-producer multi-consumer channels for message passing";
    authors = [ "The Crossbeam Project Developers" ];
    sha256 = "0si8kg061qgadx56dfyil2jq0ffckg6sk3mf2vl8ha8fwi9kd34h";
    dependencies = mapFeatures features ([
      (crates."crossbeam_utils"."${deps."crossbeam_channel"."0.3.9"."crossbeam_utils"}" deps)
    ]);
  };
  features_.crossbeam_channel."0.3.9" = deps: f: updateFeatures f (rec {
    crossbeam_channel."0.3.9".default = (f.crossbeam_channel."0.3.9".default or true);
    crossbeam_utils."${deps.crossbeam_channel."0.3.9".crossbeam_utils}".default = true;
  }) [
    (features_.crossbeam_utils."${deps."crossbeam_channel"."0.3.9"."crossbeam_utils"}" deps)
  ];


# end
# crossbeam-utils-0.6.6

  crates.crossbeam_utils."0.6.6" = deps: { features?(features_.crossbeam_utils."0.6.6" deps {}) }: buildRustCrate {
    crateName = "crossbeam-utils";
    version = "0.6.6";
    description = "Utilities for concurrent programming";
    authors = [ "The Crossbeam Project Developers" ];
    sha256 = "01gxccmrjkkcavdh8fc01kj3b5fmk10f0lkx66jmnv69kcssry72";
    dependencies = mapFeatures features ([
      (crates."cfg_if"."${deps."crossbeam_utils"."0.6.6"."cfg_if"}" deps)
    ]
      ++ (if features.crossbeam_utils."0.6.6".lazy_static or false then [ (crates.lazy_static."${deps."crossbeam_utils"."0.6.6".lazy_static}" deps) ] else []));
    features = mkFeatures (features."crossbeam_utils"."0.6.6" or {});
  };
  features_.crossbeam_utils."0.6.6" = deps: f: updateFeatures f (rec {
    cfg_if."${deps.crossbeam_utils."0.6.6".cfg_if}".default = true;
    crossbeam_utils = fold recursiveUpdate {} [
      { "0.6.6"."lazy_static" =
        (f.crossbeam_utils."0.6.6"."lazy_static" or false) ||
        (f.crossbeam_utils."0.6.6".std or false) ||
        (crossbeam_utils."0.6.6"."std" or false); }
      { "0.6.6"."std" =
        (f.crossbeam_utils."0.6.6"."std" or false) ||
        (f.crossbeam_utils."0.6.6".default or false) ||
        (crossbeam_utils."0.6.6"."default" or false); }
      { "0.6.6".default = (f.crossbeam_utils."0.6.6".default or true); }
    ];
    lazy_static."${deps.crossbeam_utils."0.6.6".lazy_static}".default = true;
  }) [
    (features_.cfg_if."${deps."crossbeam_utils"."0.6.6"."cfg_if"}" deps)
    (features_.lazy_static."${deps."crossbeam_utils"."0.6.6"."lazy_static"}" deps)
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
# dirs-2.0.2

  crates.dirs."2.0.2" = deps: { features?(features_.dirs."2.0.2" deps {}) }: buildRustCrate {
    crateName = "dirs";
    version = "2.0.2";
    description = "A tiny low-level library that provides platform-specific standard locations of directories for config, cache and other data on Linux, Windows, macOS and Redox by leveraging the mechanisms defined by the XDG base/user directory specifications on Linux, the Known Folder API on Windows, and the Standard Directory guidelines on macOS.";
    authors = [ "Simon Ochsenreither <simon@ochsenreither.de>" ];
    sha256 = "0zk0kdnl2hd3qk76yq6yk7hc7s73gpnnzi1p208ygrh270y96fpx";
    dependencies = mapFeatures features ([
      (crates."cfg_if"."${deps."dirs"."2.0.2"."cfg_if"}" deps)
      (crates."dirs_sys"."${deps."dirs"."2.0.2"."dirs_sys"}" deps)
    ]);
  };
  features_.dirs."2.0.2" = deps: f: updateFeatures f (rec {
    cfg_if."${deps.dirs."2.0.2".cfg_if}".default = true;
    dirs."2.0.2".default = (f.dirs."2.0.2".default or true);
    dirs_sys."${deps.dirs."2.0.2".dirs_sys}".default = true;
  }) [
    (features_.cfg_if."${deps."dirs"."2.0.2"."cfg_if"}" deps)
    (features_.dirs_sys."${deps."dirs"."2.0.2"."dirs_sys"}" deps)
  ];


# end
# dirs-sys-0.3.4

  crates.dirs_sys."0.3.4" = deps: { features?(features_.dirs_sys."0.3.4" deps {}) }: buildRustCrate {
    crateName = "dirs-sys";
    version = "0.3.4";
    description = "System-level helper functions for the dirs and directories crates.";
    authors = [ "Simon Ochsenreither <simon@ochsenreither.de>" ];
    sha256 = "1hb7h6g5xyhc26v8d8fksxfw1gv6kl427jzp9vhl7y8v6992d80d";
    dependencies = mapFeatures features ([
      (crates."cfg_if"."${deps."dirs_sys"."0.3.4"."cfg_if"}" deps)
    ])
      ++ (if kernel == "redox" then mapFeatures features ([
      (crates."redox_users"."${deps."dirs_sys"."0.3.4"."redox_users"}" deps)
    ]) else [])
      ++ (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
      (crates."libc"."${deps."dirs_sys"."0.3.4"."libc"}" deps)
    ]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."dirs_sys"."0.3.4"."winapi"}" deps)
    ]) else []);
  };
  features_.dirs_sys."0.3.4" = deps: f: updateFeatures f (rec {
    cfg_if."${deps.dirs_sys."0.3.4".cfg_if}".default = true;
    dirs_sys."0.3.4".default = (f.dirs_sys."0.3.4".default or true);
    libc."${deps.dirs_sys."0.3.4".libc}".default = true;
    redox_users."${deps.dirs_sys."0.3.4".redox_users}".default = true;
    winapi = fold recursiveUpdate {} [
      { "${deps.dirs_sys."0.3.4".winapi}"."knownfolders" = true; }
      { "${deps.dirs_sys."0.3.4".winapi}"."objbase" = true; }
      { "${deps.dirs_sys."0.3.4".winapi}"."shlobj" = true; }
      { "${deps.dirs_sys."0.3.4".winapi}"."winbase" = true; }
      { "${deps.dirs_sys."0.3.4".winapi}"."winerror" = true; }
      { "${deps.dirs_sys."0.3.4".winapi}".default = true; }
    ];
  }) [
    (features_.cfg_if."${deps."dirs_sys"."0.3.4"."cfg_if"}" deps)
    (features_.redox_users."${deps."dirs_sys"."0.3.4"."redox_users"}" deps)
    (features_.libc."${deps."dirs_sys"."0.3.4"."libc"}" deps)
    (features_.winapi."${deps."dirs_sys"."0.3.4"."winapi"}" deps)
  ];


# end
# failure-0.1.6

  crates.failure."0.1.6" = deps: { features?(features_.failure."0.1.6" deps {}) }: buildRustCrate {
    crateName = "failure";
    version = "0.1.6";
    description = "Experimental error handling abstraction.";
    authors = [ "Without Boats <boats@mozilla.com>" ];
    sha256 = "09qsxzrxzqz7h76sd5klfk6nq407way77j898519ll7pr5yk3j65";
    dependencies = mapFeatures features ([
    ]
      ++ (if features.failure."0.1.6".backtrace or false then [ (crates.backtrace."${deps."failure"."0.1.6".backtrace}" deps) ] else [])
      ++ (if features.failure."0.1.6".failure_derive or false then [ (crates.failure_derive."${deps."failure"."0.1.6".failure_derive}" deps) ] else []));
    features = mkFeatures (features."failure"."0.1.6" or {});
  };
  features_.failure."0.1.6" = deps: f: updateFeatures f (rec {
    backtrace."${deps.failure."0.1.6".backtrace}".default = true;
    failure = fold recursiveUpdate {} [
      { "0.1.6"."backtrace" =
        (f.failure."0.1.6"."backtrace" or false) ||
        (f.failure."0.1.6".std or false) ||
        (failure."0.1.6"."std" or false); }
      { "0.1.6"."derive" =
        (f.failure."0.1.6"."derive" or false) ||
        (f.failure."0.1.6".default or false) ||
        (failure."0.1.6"."default" or false); }
      { "0.1.6"."failure_derive" =
        (f.failure."0.1.6"."failure_derive" or false) ||
        (f.failure."0.1.6".derive or false) ||
        (failure."0.1.6"."derive" or false); }
      { "0.1.6"."std" =
        (f.failure."0.1.6"."std" or false) ||
        (f.failure."0.1.6".default or false) ||
        (failure."0.1.6"."default" or false); }
      { "0.1.6".default = (f.failure."0.1.6".default or true); }
    ];
    failure_derive."${deps.failure."0.1.6".failure_derive}".default = true;
  }) [
    (features_.backtrace."${deps."failure"."0.1.6"."backtrace"}" deps)
    (features_.failure_derive."${deps."failure"."0.1.6"."failure_derive"}" deps)
  ];


# end
# failure_derive-0.1.6

  crates.failure_derive."0.1.6" = deps: { features?(features_.failure_derive."0.1.6" deps {}) }: buildRustCrate {
    crateName = "failure_derive";
    version = "0.1.6";
    description = "derives for the failure crate";
    authors = [ "Without Boats <woboats@gmail.com>" ];
    sha256 = "00ps2s591hh2sicdv3ix6gv3qf39n5qf67q0mjff90ha8hvsykpj";
    procMacro = true;
    build = "build.rs";
    dependencies = mapFeatures features ([
      (crates."proc_macro2"."${deps."failure_derive"."0.1.6"."proc_macro2"}" deps)
      (crates."quote"."${deps."failure_derive"."0.1.6"."quote"}" deps)
      (crates."syn"."${deps."failure_derive"."0.1.6"."syn"}" deps)
      (crates."synstructure"."${deps."failure_derive"."0.1.6"."synstructure"}" deps)
    ]);
    features = mkFeatures (features."failure_derive"."0.1.6" or {});
  };
  features_.failure_derive."0.1.6" = deps: f: updateFeatures f (rec {
    failure_derive."0.1.6".default = (f.failure_derive."0.1.6".default or true);
    proc_macro2."${deps.failure_derive."0.1.6".proc_macro2}".default = true;
    quote."${deps.failure_derive."0.1.6".quote}".default = true;
    syn."${deps.failure_derive."0.1.6".syn}".default = true;
    synstructure."${deps.failure_derive."0.1.6".synstructure}".default = true;
  }) [
    (features_.proc_macro2."${deps."failure_derive"."0.1.6"."proc_macro2"}" deps)
    (features_.quote."${deps."failure_derive"."0.1.6"."quote"}" deps)
    (features_.syn."${deps."failure_derive"."0.1.6"."syn"}" deps)
    (features_.synstructure."${deps."failure_derive"."0.1.6"."synstructure"}" deps)
  ];


# end
# filetime-0.2.8

  crates.filetime."0.2.8" = deps: { features?(features_.filetime."0.2.8" deps {}) }: buildRustCrate {
    crateName = "filetime";
    version = "0.2.8";
    description = "Platform-agnostic accessors of timestamps in File metadata\n";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    edition = "2018";
    sha256 = "1vg9ppg51sn1mhc8jbvn2wwg1crishsg4gy48civrp3qy7fl2z75";
    dependencies = mapFeatures features ([
      (crates."cfg_if"."${deps."filetime"."0.2.8"."cfg_if"}" deps)
    ])
      ++ (if kernel == "redox" then mapFeatures features ([
      (crates."redox_syscall"."${deps."filetime"."0.2.8"."redox_syscall"}" deps)
    ]) else [])
      ++ (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
      (crates."libc"."${deps."filetime"."0.2.8"."libc"}" deps)
    ]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."filetime"."0.2.8"."winapi"}" deps)
    ]) else []);
  };
  features_.filetime."0.2.8" = deps: f: updateFeatures f (rec {
    cfg_if."${deps.filetime."0.2.8".cfg_if}".default = true;
    filetime."0.2.8".default = (f.filetime."0.2.8".default or true);
    libc."${deps.filetime."0.2.8".libc}".default = true;
    redox_syscall."${deps.filetime."0.2.8".redox_syscall}".default = true;
    winapi = fold recursiveUpdate {} [
      { "${deps.filetime."0.2.8".winapi}"."fileapi" = true; }
      { "${deps.filetime."0.2.8".winapi}"."minwindef" = true; }
      { "${deps.filetime."0.2.8".winapi}"."winbase" = true; }
      { "${deps.filetime."0.2.8".winapi}".default = true; }
    ];
  }) [
    (features_.cfg_if."${deps."filetime"."0.2.8"."cfg_if"}" deps)
    (features_.redox_syscall."${deps."filetime"."0.2.8"."redox_syscall"}" deps)
    (features_.libc."${deps."filetime"."0.2.8"."libc"}" deps)
    (features_.winapi."${deps."filetime"."0.2.8"."winapi"}" deps)
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
# fsevent-0.4.0

  crates.fsevent."0.4.0" = deps: { features?(features_.fsevent."0.4.0" deps {}) }: buildRustCrate {
    crateName = "fsevent";
    version = "0.4.0";
    description = "Rust bindings to the fsevent-sys macOS API for file changes notifications";
    authors = [ "Pierre Baillet <pierre@baillet.name>" ];
    sha256 = "19wynmx2k8gmsxv6fa9kpjzb9v5k6qc2ykziw25bray645spg77v";
    dependencies = mapFeatures features ([
      (crates."bitflags"."${deps."fsevent"."0.4.0"."bitflags"}" deps)
      (crates."fsevent_sys"."${deps."fsevent"."0.4.0"."fsevent_sys"}" deps)
    ]);
  };
  features_.fsevent."0.4.0" = deps: f: updateFeatures f (rec {
    bitflags."${deps.fsevent."0.4.0".bitflags}".default = true;
    fsevent."0.4.0".default = (f.fsevent."0.4.0".default or true);
    fsevent_sys."${deps.fsevent."0.4.0".fsevent_sys}".default = true;
  }) [
    (features_.bitflags."${deps."fsevent"."0.4.0"."bitflags"}" deps)
    (features_.fsevent_sys."${deps."fsevent"."0.4.0"."fsevent_sys"}" deps)
  ];


# end
# fsevent-sys-2.0.1

  crates.fsevent_sys."2.0.1" = deps: { features?(features_.fsevent_sys."2.0.1" deps {}) }: buildRustCrate {
    crateName = "fsevent-sys";
    version = "2.0.1";
    description = "Rust bindings to the fsevent macOS API for file changes notifications";
    authors = [ "Pierre Baillet <pierre@baillet.name>" ];
    sha256 = "1jlnqp6iw4mmwd2f973j33k00mbfc1cv9wpdvxq1jk3bry558gbr";
    dependencies = mapFeatures features ([
      (crates."libc"."${deps."fsevent_sys"."2.0.1"."libc"}" deps)
    ]);
  };
  features_.fsevent_sys."2.0.1" = deps: f: updateFeatures f (rec {
    fsevent_sys."2.0.1".default = (f.fsevent_sys."2.0.1".default or true);
    libc."${deps.fsevent_sys."2.0.1".libc}".default = true;
  }) [
    (features_.libc."${deps."fsevent_sys"."2.0.1"."libc"}" deps)
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
# futures-channel-0.3.1

  crates.futures_channel."0.3.1" = deps: { features?(features_.futures_channel."0.3.1" deps {}) }: buildRustCrate {
    crateName = "futures-channel";
    version = "0.3.1";
    description = "Channels for asynchronous communication using futures-rs.\n";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    edition = "2018";
    sha256 = "1qrqhzkb09ci138w1cpr0mzrrcq12v0b941xli8i1sk6cmikh35m";
    libName = "futures_channel";
    dependencies = mapFeatures features ([
      (crates."futures_core"."${deps."futures_channel"."0.3.1"."futures_core"}" deps)
    ]);
    features = mkFeatures (features."futures_channel"."0.3.1" or {});
  };
  features_.futures_channel."0.3.1" = deps: f: updateFeatures f (rec {
    futures_channel = fold recursiveUpdate {} [
      { "0.3.1"."alloc" =
        (f.futures_channel."0.3.1"."alloc" or false) ||
        (f.futures_channel."0.3.1".std or false) ||
        (futures_channel."0.3.1"."std" or false); }
      { "0.3.1"."futures-sink" =
        (f.futures_channel."0.3.1"."futures-sink" or false) ||
        (f.futures_channel."0.3.1".sink or false) ||
        (futures_channel."0.3.1"."sink" or false); }
      { "0.3.1"."std" =
        (f.futures_channel."0.3.1"."std" or false) ||
        (f.futures_channel."0.3.1".default or false) ||
        (futures_channel."0.3.1"."default" or false); }
      { "0.3.1".default = (f.futures_channel."0.3.1".default or true); }
    ];
    futures_core = fold recursiveUpdate {} [
      { "${deps.futures_channel."0.3.1".futures_core}"."alloc" =
        (f.futures_core."${deps.futures_channel."0.3.1".futures_core}"."alloc" or false) ||
        (futures_channel."0.3.1"."alloc" or false) ||
        (f."futures_channel"."0.3.1"."alloc" or false); }
      { "${deps.futures_channel."0.3.1".futures_core}"."cfg-target-has-atomic" =
        (f.futures_core."${deps.futures_channel."0.3.1".futures_core}"."cfg-target-has-atomic" or false) ||
        (futures_channel."0.3.1"."cfg-target-has-atomic" or false) ||
        (f."futures_channel"."0.3.1"."cfg-target-has-atomic" or false); }
      { "${deps.futures_channel."0.3.1".futures_core}"."std" =
        (f.futures_core."${deps.futures_channel."0.3.1".futures_core}"."std" or false) ||
        (futures_channel."0.3.1"."std" or false) ||
        (f."futures_channel"."0.3.1"."std" or false); }
      { "${deps.futures_channel."0.3.1".futures_core}"."unstable" =
        (f.futures_core."${deps.futures_channel."0.3.1".futures_core}"."unstable" or false) ||
        (futures_channel."0.3.1"."unstable" or false) ||
        (f."futures_channel"."0.3.1"."unstable" or false); }
      { "${deps.futures_channel."0.3.1".futures_core}".default = (f.futures_core."${deps.futures_channel."0.3.1".futures_core}".default or false); }
    ];
  }) [
    (features_.futures_core."${deps."futures_channel"."0.3.1"."futures_core"}" deps)
  ];


# end
# futures-core-0.3.1

  crates.futures_core."0.3.1" = deps: { features?(features_.futures_core."0.3.1" deps {}) }: buildRustCrate {
    crateName = "futures-core";
    version = "0.3.1";
    description = "The core traits and types in for the `futures` library.\n";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    edition = "2018";
    sha256 = "1bl5lwri88ck9hhdgxvqx0nhylpnzmml3vg4kgpcjqgm8vf0vqcl";
    libName = "futures_core";
    features = mkFeatures (features."futures_core"."0.3.1" or {});
  };
  features_.futures_core."0.3.1" = deps: f: updateFeatures f (rec {
    futures_core = fold recursiveUpdate {} [
      { "0.3.1"."alloc" =
        (f.futures_core."0.3.1"."alloc" or false) ||
        (f.futures_core."0.3.1".std or false) ||
        (futures_core."0.3.1"."std" or false); }
      { "0.3.1"."std" =
        (f.futures_core."0.3.1"."std" or false) ||
        (f.futures_core."0.3.1".default or false) ||
        (futures_core."0.3.1"."default" or false); }
      { "0.3.1".default = (f.futures_core."0.3.1".default or true); }
    ];
  }) [];


# end
# futures-macro-0.3.1

  crates.futures_macro."0.3.1" = deps: { features?(features_.futures_macro."0.3.1" deps {}) }: buildRustCrate {
    crateName = "futures-macro";
    version = "0.3.1";
    description = "The futures-rs procedural macro implementations.\n";
    authors = [ "Taylor Cramer <cramertj@google.com>" "Taiki Endo <te316e89@gmail.com>" ];
    edition = "2018";
    sha256 = "0jk0zg4vldb7x4pilqaiis6403w1l5iv8r7y2xzqbndx14g1gf47";
    libName = "futures_macro";
    procMacro = true;
    dependencies = mapFeatures features ([
      (crates."proc_macro_hack"."${deps."futures_macro"."0.3.1"."proc_macro_hack"}" deps)
      (crates."proc_macro2"."${deps."futures_macro"."0.3.1"."proc_macro2"}" deps)
      (crates."quote"."${deps."futures_macro"."0.3.1"."quote"}" deps)
      (crates."syn"."${deps."futures_macro"."0.3.1"."syn"}" deps)
    ]);
  };
  features_.futures_macro."0.3.1" = deps: f: updateFeatures f (rec {
    futures_macro."0.3.1".default = (f.futures_macro."0.3.1".default or true);
    proc_macro2."${deps.futures_macro."0.3.1".proc_macro2}".default = true;
    proc_macro_hack."${deps.futures_macro."0.3.1".proc_macro_hack}".default = true;
    quote."${deps.futures_macro."0.3.1".quote}".default = true;
    syn = fold recursiveUpdate {} [
      { "${deps.futures_macro."0.3.1".syn}"."full" = true; }
      { "${deps.futures_macro."0.3.1".syn}".default = true; }
    ];
  }) [
    (features_.proc_macro_hack."${deps."futures_macro"."0.3.1"."proc_macro_hack"}" deps)
    (features_.proc_macro2."${deps."futures_macro"."0.3.1"."proc_macro2"}" deps)
    (features_.quote."${deps."futures_macro"."0.3.1"."quote"}" deps)
    (features_.syn."${deps."futures_macro"."0.3.1"."syn"}" deps)
  ];


# end
# futures-task-0.3.1

  crates.futures_task."0.3.1" = deps: { features?(features_.futures_task."0.3.1" deps {}) }: buildRustCrate {
    crateName = "futures-task";
    version = "0.3.1";
    description = "Tools for working with tasks.\n";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    edition = "2018";
    sha256 = "1j6cq3nkmx8c4jw8021jah7r9ksxdx4r4ddxqr5x0a9gfvz05pyv";
    libName = "futures_task";
    features = mkFeatures (features."futures_task"."0.3.1" or {});
  };
  features_.futures_task."0.3.1" = deps: f: updateFeatures f (rec {
    futures_task = fold recursiveUpdate {} [
      { "0.3.1"."alloc" =
        (f.futures_task."0.3.1"."alloc" or false) ||
        (f.futures_task."0.3.1".std or false) ||
        (futures_task."0.3.1"."std" or false); }
      { "0.3.1"."std" =
        (f.futures_task."0.3.1"."std" or false) ||
        (f.futures_task."0.3.1".default or false) ||
        (futures_task."0.3.1"."default" or false); }
      { "0.3.1".default = (f.futures_task."0.3.1".default or true); }
    ];
  }) [];


# end
# futures-util-0.3.1

  crates.futures_util."0.3.1" = deps: { features?(features_.futures_util."0.3.1" deps {}) }: buildRustCrate {
    crateName = "futures-util";
    version = "0.3.1";
    description = "Common utilities and extension traits for the futures-rs library.\n";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    edition = "2018";
    sha256 = "133pqb8r8581qvzlp0mhzpk638v486k9zwp8cgd0sm6knyzj7s0b";
    libName = "futures_util";
    dependencies = mapFeatures features ([
      (crates."futures_core"."${deps."futures_util"."0.3.1"."futures_core"}" deps)
      (crates."futures_task"."${deps."futures_util"."0.3.1"."futures_task"}" deps)
      (crates."pin_utils"."${deps."futures_util"."0.3.1"."pin_utils"}" deps)
    ]
      ++ (if features.futures_util."0.3.1".futures-macro or false then [ (crates.futures_macro."${deps."futures_util"."0.3.1".futures_macro}" deps) ] else [])
      ++ (if features.futures_util."0.3.1".proc-macro-hack or false then [ (crates.proc_macro_hack."${deps."futures_util"."0.3.1".proc_macro_hack}" deps) ] else [])
      ++ (if features.futures_util."0.3.1".proc-macro-nested or false then [ (crates.proc_macro_nested."${deps."futures_util"."0.3.1".proc_macro_nested}" deps) ] else [])
      ++ (if features.futures_util."0.3.1".slab or false then [ (crates.slab."${deps."futures_util"."0.3.1".slab}" deps) ] else []));
    features = mkFeatures (features."futures_util"."0.3.1" or {});
  };
  features_.futures_util."0.3.1" = deps: f: updateFeatures f (rec {
    futures_core = fold recursiveUpdate {} [
      { "${deps.futures_util."0.3.1".futures_core}"."alloc" =
        (f.futures_core."${deps.futures_util."0.3.1".futures_core}"."alloc" or false) ||
        (futures_util."0.3.1"."alloc" or false) ||
        (f."futures_util"."0.3.1"."alloc" or false); }
      { "${deps.futures_util."0.3.1".futures_core}"."cfg-target-has-atomic" =
        (f.futures_core."${deps.futures_util."0.3.1".futures_core}"."cfg-target-has-atomic" or false) ||
        (futures_util."0.3.1"."cfg-target-has-atomic" or false) ||
        (f."futures_util"."0.3.1"."cfg-target-has-atomic" or false); }
      { "${deps.futures_util."0.3.1".futures_core}"."std" =
        (f.futures_core."${deps.futures_util."0.3.1".futures_core}"."std" or false) ||
        (futures_util."0.3.1"."std" or false) ||
        (f."futures_util"."0.3.1"."std" or false); }
      { "${deps.futures_util."0.3.1".futures_core}"."unstable" =
        (f.futures_core."${deps.futures_util."0.3.1".futures_core}"."unstable" or false) ||
        (futures_util."0.3.1"."unstable" or false) ||
        (f."futures_util"."0.3.1"."unstable" or false); }
      { "${deps.futures_util."0.3.1".futures_core}".default = (f.futures_core."${deps.futures_util."0.3.1".futures_core}".default or false); }
    ];
    futures_macro."${deps.futures_util."0.3.1".futures_macro}".default = (f.futures_macro."${deps.futures_util."0.3.1".futures_macro}".default or false);
    futures_task = fold recursiveUpdate {} [
      { "${deps.futures_util."0.3.1".futures_task}"."alloc" =
        (f.futures_task."${deps.futures_util."0.3.1".futures_task}"."alloc" or false) ||
        (futures_util."0.3.1"."alloc" or false) ||
        (f."futures_util"."0.3.1"."alloc" or false); }
      { "${deps.futures_util."0.3.1".futures_task}"."cfg-target-has-atomic" =
        (f.futures_task."${deps.futures_util."0.3.1".futures_task}"."cfg-target-has-atomic" or false) ||
        (futures_util."0.3.1"."cfg-target-has-atomic" or false) ||
        (f."futures_util"."0.3.1"."cfg-target-has-atomic" or false); }
      { "${deps.futures_util."0.3.1".futures_task}"."std" =
        (f.futures_task."${deps.futures_util."0.3.1".futures_task}"."std" or false) ||
        (futures_util."0.3.1"."std" or false) ||
        (f."futures_util"."0.3.1"."std" or false); }
      { "${deps.futures_util."0.3.1".futures_task}"."unstable" =
        (f.futures_task."${deps.futures_util."0.3.1".futures_task}"."unstable" or false) ||
        (futures_util."0.3.1"."unstable" or false) ||
        (f."futures_util"."0.3.1"."unstable" or false); }
      { "${deps.futures_util."0.3.1".futures_task}".default = (f.futures_task."${deps.futures_util."0.3.1".futures_task}".default or false); }
    ];
    futures_util = fold recursiveUpdate {} [
      { "0.3.1"."alloc" =
        (f.futures_util."0.3.1"."alloc" or false) ||
        (f.futures_util."0.3.1".std or false) ||
        (futures_util."0.3.1"."std" or false); }
      { "0.3.1"."async-await" =
        (f.futures_util."0.3.1"."async-await" or false) ||
        (f.futures_util."0.3.1".async-await-macro or false) ||
        (futures_util."0.3.1"."async-await-macro" or false) ||
        (f.futures_util."0.3.1".default or false) ||
        (futures_util."0.3.1"."default" or false); }
      { "0.3.1"."async-await-macro" =
        (f.futures_util."0.3.1"."async-await-macro" or false) ||
        (f.futures_util."0.3.1".default or false) ||
        (futures_util."0.3.1"."default" or false); }
      { "0.3.1"."compat" =
        (f.futures_util."0.3.1"."compat" or false) ||
        (f.futures_util."0.3.1".io-compat or false) ||
        (futures_util."0.3.1"."io-compat" or false); }
      { "0.3.1"."futures-channel" =
        (f.futures_util."0.3.1"."futures-channel" or false) ||
        (f.futures_util."0.3.1".channel or false) ||
        (futures_util."0.3.1"."channel" or false); }
      { "0.3.1"."futures-io" =
        (f.futures_util."0.3.1"."futures-io" or false) ||
        (f.futures_util."0.3.1".io or false) ||
        (futures_util."0.3.1"."io" or false); }
      { "0.3.1"."futures-macro" =
        (f.futures_util."0.3.1"."futures-macro" or false) ||
        (f.futures_util."0.3.1".async-await-macro or false) ||
        (futures_util."0.3.1"."async-await-macro" or false); }
      { "0.3.1"."futures-sink" =
        (f.futures_util."0.3.1"."futures-sink" or false) ||
        (f.futures_util."0.3.1".sink or false) ||
        (futures_util."0.3.1"."sink" or false); }
      { "0.3.1"."futures_01" =
        (f.futures_util."0.3.1"."futures_01" or false) ||
        (f.futures_util."0.3.1".compat or false) ||
        (futures_util."0.3.1"."compat" or false); }
      { "0.3.1"."io" =
        (f.futures_util."0.3.1"."io" or false) ||
        (f.futures_util."0.3.1".io-compat or false) ||
        (futures_util."0.3.1"."io-compat" or false) ||
        (f.futures_util."0.3.1".read-initializer or false) ||
        (futures_util."0.3.1"."read-initializer" or false); }
      { "0.3.1"."memchr" =
        (f.futures_util."0.3.1"."memchr" or false) ||
        (f.futures_util."0.3.1".io or false) ||
        (futures_util."0.3.1"."io" or false); }
      { "0.3.1"."proc-macro-hack" =
        (f.futures_util."0.3.1"."proc-macro-hack" or false) ||
        (f.futures_util."0.3.1".async-await-macro or false) ||
        (futures_util."0.3.1"."async-await-macro" or false); }
      { "0.3.1"."proc-macro-nested" =
        (f.futures_util."0.3.1"."proc-macro-nested" or false) ||
        (f.futures_util."0.3.1".async-await-macro or false) ||
        (futures_util."0.3.1"."async-await-macro" or false); }
      { "0.3.1"."slab" =
        (f.futures_util."0.3.1"."slab" or false) ||
        (f.futures_util."0.3.1".std or false) ||
        (futures_util."0.3.1"."std" or false); }
      { "0.3.1"."std" =
        (f.futures_util."0.3.1"."std" or false) ||
        (f.futures_util."0.3.1".channel or false) ||
        (futures_util."0.3.1"."channel" or false) ||
        (f.futures_util."0.3.1".compat or false) ||
        (futures_util."0.3.1"."compat" or false) ||
        (f.futures_util."0.3.1".default or false) ||
        (futures_util."0.3.1"."default" or false) ||
        (f.futures_util."0.3.1".io or false) ||
        (futures_util."0.3.1"."io" or false); }
      { "0.3.1"."tokio-io" =
        (f.futures_util."0.3.1"."tokio-io" or false) ||
        (f.futures_util."0.3.1".io-compat or false) ||
        (futures_util."0.3.1"."io-compat" or false); }
      { "0.3.1".default = (f.futures_util."0.3.1".default or true); }
    ];
    pin_utils."${deps.futures_util."0.3.1".pin_utils}".default = true;
    proc_macro_hack."${deps.futures_util."0.3.1".proc_macro_hack}".default = true;
    proc_macro_nested."${deps.futures_util."0.3.1".proc_macro_nested}".default = true;
    slab."${deps.futures_util."0.3.1".slab}".default = true;
  }) [
    (features_.futures_core."${deps."futures_util"."0.3.1"."futures_core"}" deps)
    (features_.futures_macro."${deps."futures_util"."0.3.1"."futures_macro"}" deps)
    (features_.futures_task."${deps."futures_util"."0.3.1"."futures_task"}" deps)
    (features_.pin_utils."${deps."futures_util"."0.3.1"."pin_utils"}" deps)
    (features_.proc_macro_hack."${deps."futures_util"."0.3.1"."proc_macro_hack"}" deps)
    (features_.proc_macro_nested."${deps."futures_util"."0.3.1"."proc_macro_nested"}" deps)
    (features_.slab."${deps."futures_util"."0.3.1"."slab"}" deps)
  ];


# end
# getopts-0.2.21

  crates.getopts."0.2.21" = deps: { features?(features_.getopts."0.2.21" deps {}) }: buildRustCrate {
    crateName = "getopts";
    version = "0.2.21";
    description = "getopts-like option parsing.\n";
    authors = [ "The Rust Project Developers" ];
    sha256 = "1sqp35br180qhc1kzqg7pcv1nkbs05fgjfg53n4swcx2q2ql4763";
    dependencies = mapFeatures features ([
      (crates."unicode_width"."${deps."getopts"."0.2.21"."unicode_width"}" deps)
    ]);
    features = mkFeatures (features."getopts"."0.2.21" or {});
  };
  features_.getopts."0.2.21" = deps: f: updateFeatures f (rec {
    getopts = fold recursiveUpdate {} [
      { "0.2.21"."core" =
        (f.getopts."0.2.21"."core" or false) ||
        (f.getopts."0.2.21".rustc-dep-of-std or false) ||
        (getopts."0.2.21"."rustc-dep-of-std" or false); }
      { "0.2.21"."std" =
        (f.getopts."0.2.21"."std" or false) ||
        (f.getopts."0.2.21".rustc-dep-of-std or false) ||
        (getopts."0.2.21"."rustc-dep-of-std" or false); }
      { "0.2.21".default = (f.getopts."0.2.21".default or true); }
    ];
    unicode_width = fold recursiveUpdate {} [
      { "${deps.getopts."0.2.21".unicode_width}"."rustc-dep-of-std" =
        (f.unicode_width."${deps.getopts."0.2.21".unicode_width}"."rustc-dep-of-std" or false) ||
        (getopts."0.2.21"."rustc-dep-of-std" or false) ||
        (f."getopts"."0.2.21"."rustc-dep-of-std" or false); }
      { "${deps.getopts."0.2.21".unicode_width}".default = true; }
    ];
  }) [
    (features_.unicode_width."${deps."getopts"."0.2.21"."unicode_width"}" deps)
  ];


# end
# getrandom-0.1.13

  crates.getrandom."0.1.13" = deps: { features?(features_.getrandom."0.1.13" deps {}) }: buildRustCrate {
    crateName = "getrandom";
    version = "0.1.13";
    description = "A small cross-platform library for retrieving random data from system source";
    authors = [ "The Rand Project Developers" ];
    edition = "2018";
    sha256 = "0js1vkdrqy94vfn39p8i93zcr1r4mjbvy78dbrbx7s8rd6xl33md";
    dependencies = mapFeatures features ([
      (crates."cfg_if"."${deps."getrandom"."0.1.13"."cfg_if"}" deps)
    ])
      ++ (if kernel == "wasi" then mapFeatures features ([
      (crates."wasi"."${deps."getrandom"."0.1.13"."wasi"}" deps)
    ]) else [])
      ++ (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
      (crates."libc"."${deps."getrandom"."0.1.13"."libc"}" deps)
    ]) else [])
      ++ (if kernel == "wasm32-unknown-unknown" then mapFeatures features ([
]) else []);
    features = mkFeatures (features."getrandom"."0.1.13" or {});
  };
  features_.getrandom."0.1.13" = deps: f: updateFeatures f (rec {
    cfg_if."${deps.getrandom."0.1.13".cfg_if}".default = true;
    getrandom = fold recursiveUpdate {} [
      { "0.1.13"."compiler_builtins" =
        (f.getrandom."0.1.13"."compiler_builtins" or false) ||
        (f.getrandom."0.1.13".rustc-dep-of-std or false) ||
        (getrandom."0.1.13"."rustc-dep-of-std" or false); }
      { "0.1.13"."core" =
        (f.getrandom."0.1.13"."core" or false) ||
        (f.getrandom."0.1.13".rustc-dep-of-std or false) ||
        (getrandom."0.1.13"."rustc-dep-of-std" or false); }
      { "0.1.13"."wasm-bindgen" =
        (f.getrandom."0.1.13"."wasm-bindgen" or false) ||
        (f.getrandom."0.1.13".test-in-browser or false) ||
        (getrandom."0.1.13"."test-in-browser" or false); }
      { "0.1.13".default = (f.getrandom."0.1.13".default or true); }
    ];
    libc."${deps.getrandom."0.1.13".libc}".default = (f.libc."${deps.getrandom."0.1.13".libc}".default or false);
    wasi."${deps.getrandom."0.1.13".wasi}".default = true;
  }) [
    (features_.cfg_if."${deps."getrandom"."0.1.13"."cfg_if"}" deps)
    (features_.wasi."${deps."getrandom"."0.1.13"."wasi"}" deps)
    (features_.libc."${deps."getrandom"."0.1.13"."libc"}" deps)
  ];


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
# hermit-abi-0.1.3

  crates.hermit_abi."0.1.3" = deps: { features?(features_.hermit_abi."0.1.3" deps {}) }: buildRustCrate {
    crateName = "hermit-abi";
    version = "0.1.3";
    description = "hermit-abi is small interface to call functions from the unikernel RustyHermit.\nIt is used to build the target `x86_64-unknown-hermit`.\n";
    authors = [ "Stefan Lankes" ];
    sha256 = "13lvclqpdpa2jk8kblja8jmbq0gj80rlmc5x8kiqk91h278j2r2s";
    dependencies = mapFeatures features ([
      (crates."libc"."${deps."hermit_abi"."0.1.3"."libc"}" deps)
    ]);
    features = mkFeatures (features."hermit_abi"."0.1.3" or {});
  };
  features_.hermit_abi."0.1.3" = deps: f: updateFeatures f (rec {
    hermit_abi = fold recursiveUpdate {} [
      { "0.1.3"."core" =
        (f.hermit_abi."0.1.3"."core" or false) ||
        (f.hermit_abi."0.1.3".rustc-dep-of-std or false) ||
        (hermit_abi."0.1.3"."rustc-dep-of-std" or false); }
      { "0.1.3".default = (f.hermit_abi."0.1.3".default or true); }
    ];
    libc = fold recursiveUpdate {} [
      { "${deps.hermit_abi."0.1.3".libc}"."rustc-dep-of-std" =
        (f.libc."${deps.hermit_abi."0.1.3".libc}"."rustc-dep-of-std" or false) ||
        (hermit_abi."0.1.3"."rustc-dep-of-std" or false) ||
        (f."hermit_abi"."0.1.3"."rustc-dep-of-std" or false); }
      { "${deps.hermit_abi."0.1.3".libc}".default = (f.libc."${deps.hermit_abi."0.1.3".libc}".default or false); }
    ];
  }) [
    (features_.libc."${deps."hermit_abi"."0.1.3"."libc"}" deps)
  ];


# end
# inotify-0.7.0

  crates.inotify."0.7.0" = deps: { features?(features_.inotify."0.7.0" deps {}) }: buildRustCrate {
    crateName = "inotify";
    version = "0.7.0";
    description = "Idiomatic wrapper for inotify";
    authors = [ "Hanno Braun <mail@hannobraun.de>" "Félix Saparelli <me@passcod.name>" "Cristian Kubis <cristian.kubis@tsunix.de>" "Frank Denis <github@pureftpd.org>" ];
    sha256 = "1djx64kq3mgzh2yw4iilq9rigvkk4q07xrysw7m2szpd8395y3yb";
    dependencies = mapFeatures features ([
      (crates."bitflags"."${deps."inotify"."0.7.0"."bitflags"}" deps)
      (crates."inotify_sys"."${deps."inotify"."0.7.0"."inotify_sys"}" deps)
      (crates."libc"."${deps."inotify"."0.7.0"."libc"}" deps)
    ]);
    features = mkFeatures (features."inotify"."0.7.0" or {});
  };
  features_.inotify."0.7.0" = deps: f: updateFeatures f (rec {
    bitflags."${deps.inotify."0.7.0".bitflags}".default = true;
    inotify = fold recursiveUpdate {} [
      { "0.7.0"."futures" =
        (f.inotify."0.7.0"."futures" or false) ||
        (f.inotify."0.7.0".stream or false) ||
        (inotify."0.7.0"."stream" or false); }
      { "0.7.0"."mio" =
        (f.inotify."0.7.0"."mio" or false) ||
        (f.inotify."0.7.0".stream or false) ||
        (inotify."0.7.0"."stream" or false); }
      { "0.7.0"."stream" =
        (f.inotify."0.7.0"."stream" or false) ||
        (f.inotify."0.7.0".default or false) ||
        (inotify."0.7.0"."default" or false); }
      { "0.7.0"."tokio" =
        (f.inotify."0.7.0"."tokio" or false) ||
        (f.inotify."0.7.0".stream or false) ||
        (inotify."0.7.0"."stream" or false); }
      { "0.7.0"."tokio-io" =
        (f.inotify."0.7.0"."tokio-io" or false) ||
        (f.inotify."0.7.0".stream or false) ||
        (inotify."0.7.0"."stream" or false); }
      { "0.7.0"."tokio-reactor" =
        (f.inotify."0.7.0"."tokio-reactor" or false) ||
        (f.inotify."0.7.0".stream or false) ||
        (inotify."0.7.0"."stream" or false); }
      { "0.7.0".default = (f.inotify."0.7.0".default or true); }
    ];
    inotify_sys."${deps.inotify."0.7.0".inotify_sys}".default = true;
    libc."${deps.inotify."0.7.0".libc}".default = true;
  }) [
    (features_.bitflags."${deps."inotify"."0.7.0"."bitflags"}" deps)
    (features_.inotify_sys."${deps."inotify"."0.7.0"."inotify_sys"}" deps)
    (features_.libc."${deps."inotify"."0.7.0"."libc"}" deps)
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
# iovec-0.1.4

  crates.iovec."0.1.4" = deps: { features?(features_.iovec."0.1.4" deps {}) }: buildRustCrate {
    crateName = "iovec";
    version = "0.1.4";
    description = "Portable buffer type for scatter/gather I/O operations\n";
    authors = [ "Carl Lerche <me@carllerche.com>" ];
    sha256 = "1wy7rsm8rx6y4rjy98jws1aqxdy0v5wbz9whz73p45cwpsg4prfa";
    dependencies = (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
      (crates."libc"."${deps."iovec"."0.1.4"."libc"}" deps)
    ]) else []);
  };
  features_.iovec."0.1.4" = deps: f: updateFeatures f (rec {
    iovec."0.1.4".default = (f.iovec."0.1.4".default or true);
    libc."${deps.iovec."0.1.4".libc}".default = true;
  }) [
    (features_.libc."${deps."iovec"."0.1.4"."libc"}" deps)
  ];


# end
# itoa-0.4.4

  crates.itoa."0.4.4" = deps: { features?(features_.itoa."0.4.4" deps {}) }: buildRustCrate {
    crateName = "itoa";
    version = "0.4.4";
    description = "Fast functions for printing integer primitives to an io::Write";
    authors = [ "David Tolnay <dtolnay@gmail.com>" ];
    sha256 = "1fqc34xzzl2spfdawxd9awhzl0fwf1y6y4i94l8bq8rfrzd90awl";
    features = mkFeatures (features."itoa"."0.4.4" or {});
  };
  features_.itoa."0.4.4" = deps: f: updateFeatures f (rec {
    itoa = fold recursiveUpdate {} [
      { "0.4.4"."std" =
        (f.itoa."0.4.4"."std" or false) ||
        (f.itoa."0.4.4".default or false) ||
        (itoa."0.4.4"."default" or false); }
      { "0.4.4".default = (f.itoa."0.4.4".default or true); }
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
# lazy_static-1.4.0

  crates.lazy_static."1.4.0" = deps: { features?(features_.lazy_static."1.4.0" deps {}) }: buildRustCrate {
    crateName = "lazy_static";
    version = "1.4.0";
    description = "A macro for declaring lazily evaluated statics in Rust.";
    authors = [ "Marvin Löbel <loebel.marvin@gmail.com>" ];
    sha256 = "13h6sdghdcy7vcqsm2gasfw3qg7ssa0fl3sw7lq6pdkbk52wbyfr";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."lazy_static"."1.4.0" or {});
  };
  features_.lazy_static."1.4.0" = deps: f: updateFeatures f (rec {
    lazy_static = fold recursiveUpdate {} [
      { "1.4.0"."spin" =
        (f.lazy_static."1.4.0"."spin" or false) ||
        (f.lazy_static."1.4.0".spin_no_std or false) ||
        (lazy_static."1.4.0"."spin_no_std" or false); }
      { "1.4.0".default = (f.lazy_static."1.4.0".default or true); }
    ];
  }) [];


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
# libc-0.2.65

  crates.libc."0.2.65" = deps: { features?(features_.libc."0.2.65" deps {}) }: buildRustCrate {
    crateName = "libc";
    version = "0.2.65";
    description = "Raw FFI bindings to platform libraries like libc.\n";
    authors = [ "The Rust Project Developers" ];
    sha256 = "0nx1n3xvwj2ikw1d6v17154jx2sb9sgrv6fwbnq79c614a3mhmad";
    build = "build.rs";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."libc"."0.2.65" or {});
  };
  features_.libc."0.2.65" = deps: f: updateFeatures f (rec {
    libc = fold recursiveUpdate {} [
      { "0.2.65"."align" =
        (f.libc."0.2.65"."align" or false) ||
        (f.libc."0.2.65".rustc-dep-of-std or false) ||
        (libc."0.2.65"."rustc-dep-of-std" or false); }
      { "0.2.65"."rustc-std-workspace-core" =
        (f.libc."0.2.65"."rustc-std-workspace-core" or false) ||
        (f.libc."0.2.65".rustc-dep-of-std or false) ||
        (libc."0.2.65"."rustc-dep-of-std" or false); }
      { "0.2.65"."std" =
        (f.libc."0.2.65"."std" or false) ||
        (f.libc."0.2.65".default or false) ||
        (libc."0.2.65"."default" or false) ||
        (f.libc."0.2.65".use_std or false) ||
        (libc."0.2.65"."use_std" or false); }
      { "0.2.65".default = (f.libc."0.2.65".default or true); }
    ];
  }) [];


# end
# log-0.4.8

  crates.log."0.4.8" = deps: { features?(features_.log."0.4.8" deps {}) }: buildRustCrate {
    crateName = "log";
    version = "0.4.8";
    description = "A lightweight logging facade for Rust\n";
    authors = [ "The Rust Project Developers" ];
    sha256 = "0wvzzzcn89dai172rrqcyz06pzldyyy0lf0w71csmn206rdpnb15";
    build = "build.rs";
    dependencies = mapFeatures features ([
      (crates."cfg_if"."${deps."log"."0.4.8"."cfg_if"}" deps)
    ]);
    features = mkFeatures (features."log"."0.4.8" or {});
  };
  features_.log."0.4.8" = deps: f: updateFeatures f (rec {
    cfg_if."${deps.log."0.4.8".cfg_if}".default = true;
    log = fold recursiveUpdate {} [
      { "0.4.8"."kv_unstable" =
        (f.log."0.4.8"."kv_unstable" or false) ||
        (f.log."0.4.8".kv_unstable_sval or false) ||
        (log."0.4.8"."kv_unstable_sval" or false); }
      { "0.4.8".default = (f.log."0.4.8".default or true); }
    ];
  }) [
    (features_.cfg_if."${deps."log"."0.4.8"."cfg_if"}" deps)
  ];


# end
# maybe-uninit-2.0.0

  crates.maybe_uninit."2.0.0" = deps: { features?(features_.maybe_uninit."2.0.0" deps {}) }: buildRustCrate {
    crateName = "maybe-uninit";
    version = "2.0.0";
    description = "MaybeUninit for friends of backwards compatibility";
    authors = [ "est31 <MTest31@outlook.com>" "The Rust Project Developers" ];
    sha256 = "0crrwlngxjswhcnw8dvsccx8qnm2cbp4fvq6xhz3akmznvnv77gk";
  };
  features_.maybe_uninit."2.0.0" = deps: f: updateFeatures f (rec {
    maybe_uninit."2.0.0".default = (f.maybe_uninit."2.0.0".default or true);
  }) [];


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
# memchr-2.2.1

  crates.memchr."2.2.1" = deps: { features?(features_.memchr."2.2.1" deps {}) }: buildRustCrate {
    crateName = "memchr";
    version = "2.2.1";
    description = "Safe interface to memchr.";
    authors = [ "Andrew Gallant <jamslam@gmail.com>" "bluss" ];
    sha256 = "1mj5z8lhz6jbapslpq8a39pwcsl1p0jmgp7wgcj7nv4pcqhya7a0";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."memchr"."2.2.1" or {});
  };
  features_.memchr."2.2.1" = deps: f: updateFeatures f (rec {
    memchr = fold recursiveUpdate {} [
      { "2.2.1"."use_std" =
        (f.memchr."2.2.1"."use_std" or false) ||
        (f.memchr."2.2.1".default or false) ||
        (memchr."2.2.1"."default" or false); }
      { "2.2.1".default = (f.memchr."2.2.1".default or true); }
    ];
  }) [];


# end
# mio-0.6.21

  crates.mio."0.6.21" = deps: { features?(features_.mio."0.6.21" deps {}) }: buildRustCrate {
    crateName = "mio";
    version = "0.6.21";
    description = "Lightweight non-blocking IO";
    authors = [ "Carl Lerche <me@carllerche.com>" ];
    sha256 = "08z31q5fx4irmp3hsvlzqy541swda8ixhs69adm95j97xz5ikmys";
    dependencies = mapFeatures features ([
      (crates."cfg_if"."${deps."mio"."0.6.21"."cfg_if"}" deps)
      (crates."iovec"."${deps."mio"."0.6.21"."iovec"}" deps)
      (crates."log"."${deps."mio"."0.6.21"."log"}" deps)
      (crates."net2"."${deps."mio"."0.6.21"."net2"}" deps)
      (crates."slab"."${deps."mio"."0.6.21"."slab"}" deps)
    ])
      ++ (if kernel == "fuchsia" then mapFeatures features ([
      (crates."fuchsia_zircon"."${deps."mio"."0.6.21"."fuchsia_zircon"}" deps)
      (crates."fuchsia_zircon_sys"."${deps."mio"."0.6.21"."fuchsia_zircon_sys"}" deps)
    ]) else [])
      ++ (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
      (crates."libc"."${deps."mio"."0.6.21"."libc"}" deps)
    ]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."kernel32_sys"."${deps."mio"."0.6.21"."kernel32_sys"}" deps)
      (crates."miow"."${deps."mio"."0.6.21"."miow"}" deps)
      (crates."winapi"."${deps."mio"."0.6.21"."winapi"}" deps)
    ]) else []);
    features = mkFeatures (features."mio"."0.6.21" or {});
  };
  features_.mio."0.6.21" = deps: f: updateFeatures f (rec {
    cfg_if."${deps.mio."0.6.21".cfg_if}".default = true;
    fuchsia_zircon."${deps.mio."0.6.21".fuchsia_zircon}".default = true;
    fuchsia_zircon_sys."${deps.mio."0.6.21".fuchsia_zircon_sys}".default = true;
    iovec."${deps.mio."0.6.21".iovec}".default = true;
    kernel32_sys."${deps.mio."0.6.21".kernel32_sys}".default = true;
    libc."${deps.mio."0.6.21".libc}".default = true;
    log."${deps.mio."0.6.21".log}".default = true;
    mio = fold recursiveUpdate {} [
      { "0.6.21"."with-deprecated" =
        (f.mio."0.6.21"."with-deprecated" or false) ||
        (f.mio."0.6.21".default or false) ||
        (mio."0.6.21"."default" or false); }
      { "0.6.21".default = (f.mio."0.6.21".default or true); }
    ];
    miow."${deps.mio."0.6.21".miow}".default = true;
    net2."${deps.mio."0.6.21".net2}".default = true;
    slab."${deps.mio."0.6.21".slab}".default = true;
    winapi."${deps.mio."0.6.21".winapi}".default = true;
  }) [
    (features_.cfg_if."${deps."mio"."0.6.21"."cfg_if"}" deps)
    (features_.iovec."${deps."mio"."0.6.21"."iovec"}" deps)
    (features_.log."${deps."mio"."0.6.21"."log"}" deps)
    (features_.net2."${deps."mio"."0.6.21"."net2"}" deps)
    (features_.slab."${deps."mio"."0.6.21"."slab"}" deps)
    (features_.fuchsia_zircon."${deps."mio"."0.6.21"."fuchsia_zircon"}" deps)
    (features_.fuchsia_zircon_sys."${deps."mio"."0.6.21"."fuchsia_zircon_sys"}" deps)
    (features_.libc."${deps."mio"."0.6.21"."libc"}" deps)
    (features_.kernel32_sys."${deps."mio"."0.6.21"."kernel32_sys"}" deps)
    (features_.miow."${deps."mio"."0.6.21"."miow"}" deps)
    (features_.winapi."${deps."mio"."0.6.21"."winapi"}" deps)
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
# mio-named-pipes-0.1.6

  crates.mio_named_pipes."0.1.6" = deps: { features?(features_.mio_named_pipes."0.1.6" deps {}) }: buildRustCrate {
    crateName = "mio-named-pipes";
    version = "0.1.6";
    description = "Windows named pipe bindings for mio.\n";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    sha256 = "016r9rjh8yq94rs8vn7z4jasx08z1q06jfwcvg39bihfyar4gsfx";
    dependencies = (if kernel == "windows" then mapFeatures features ([
      (crates."log"."${deps."mio_named_pipes"."0.1.6"."log"}" deps)
      (crates."mio"."${deps."mio_named_pipes"."0.1.6"."mio"}" deps)
      (crates."miow"."${deps."mio_named_pipes"."0.1.6"."miow"}" deps)
      (crates."winapi"."${deps."mio_named_pipes"."0.1.6"."winapi"}" deps)
    ]) else []);
  };
  features_.mio_named_pipes."0.1.6" = deps: f: updateFeatures f (rec {
    log."${deps.mio_named_pipes."0.1.6".log}".default = true;
    mio."${deps.mio_named_pipes."0.1.6".mio}".default = true;
    mio_named_pipes."0.1.6".default = (f.mio_named_pipes."0.1.6".default or true);
    miow."${deps.mio_named_pipes."0.1.6".miow}".default = true;
    winapi = fold recursiveUpdate {} [
      { "${deps.mio_named_pipes."0.1.6".winapi}"."ioapiset" = true; }
      { "${deps.mio_named_pipes."0.1.6".winapi}"."minwinbase" = true; }
      { "${deps.mio_named_pipes."0.1.6".winapi}"."winbase" = true; }
      { "${deps.mio_named_pipes."0.1.6".winapi}"."winerror" = true; }
      { "${deps.mio_named_pipes."0.1.6".winapi}".default = true; }
    ];
  }) [
    (features_.log."${deps."mio_named_pipes"."0.1.6"."log"}" deps)
    (features_.mio."${deps."mio_named_pipes"."0.1.6"."mio"}" deps)
    (features_.miow."${deps."mio_named_pipes"."0.1.6"."miow"}" deps)
    (features_.winapi."${deps."mio_named_pipes"."0.1.6"."winapi"}" deps)
  ];


# end
# mio-uds-0.6.7

  crates.mio_uds."0.6.7" = deps: { features?(features_.mio_uds."0.6.7" deps {}) }: buildRustCrate {
    crateName = "mio-uds";
    version = "0.6.7";
    description = "Unix domain socket bindings for mio\n";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    sha256 = "1gff9908pvvysv7zgxvyxy7x34fnhs088cr0j8mgwj8j24mswrhm";
    dependencies = (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
      (crates."iovec"."${deps."mio_uds"."0.6.7"."iovec"}" deps)
      (crates."libc"."${deps."mio_uds"."0.6.7"."libc"}" deps)
      (crates."mio"."${deps."mio_uds"."0.6.7"."mio"}" deps)
    ]) else []);
  };
  features_.mio_uds."0.6.7" = deps: f: updateFeatures f (rec {
    iovec."${deps.mio_uds."0.6.7".iovec}".default = true;
    libc."${deps.mio_uds."0.6.7".libc}".default = true;
    mio."${deps.mio_uds."0.6.7".mio}".default = true;
    mio_uds."0.6.7".default = (f.mio_uds."0.6.7".default or true);
  }) [
    (features_.iovec."${deps."mio_uds"."0.6.7"."iovec"}" deps)
    (features_.libc."${deps."mio_uds"."0.6.7"."libc"}" deps)
    (features_.mio."${deps."mio_uds"."0.6.7"."mio"}" deps)
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
# miow-0.3.3

  crates.miow."0.3.3" = deps: { features?(features_.miow."0.3.3" deps {}) }: buildRustCrate {
    crateName = "miow";
    version = "0.3.3";
    description = "A zero overhead I/O library for Windows, focusing on IOCP and Async I/O\nabstractions.\n";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    sha256 = "1mlk5mn00cl6bmf8qlpc6r85dxf4l45vbkbzshsr1mrkb3hn1j57";
    dependencies = mapFeatures features ([
      (crates."socket2"."${deps."miow"."0.3.3"."socket2"}" deps)
      (crates."winapi"."${deps."miow"."0.3.3"."winapi"}" deps)
    ]);
  };
  features_.miow."0.3.3" = deps: f: updateFeatures f (rec {
    miow."0.3.3".default = (f.miow."0.3.3".default or true);
    socket2."${deps.miow."0.3.3".socket2}".default = true;
    winapi = fold recursiveUpdate {} [
      { "${deps.miow."0.3.3".winapi}"."fileapi" = true; }
      { "${deps.miow."0.3.3".winapi}"."handleapi" = true; }
      { "${deps.miow."0.3.3".winapi}"."ioapiset" = true; }
      { "${deps.miow."0.3.3".winapi}"."minwindef" = true; }
      { "${deps.miow."0.3.3".winapi}"."namedpipeapi" = true; }
      { "${deps.miow."0.3.3".winapi}"."ntdef" = true; }
      { "${deps.miow."0.3.3".winapi}"."std" = true; }
      { "${deps.miow."0.3.3".winapi}"."synchapi" = true; }
      { "${deps.miow."0.3.3".winapi}"."winerror" = true; }
      { "${deps.miow."0.3.3".winapi}"."winsock2" = true; }
      { "${deps.miow."0.3.3".winapi}"."ws2def" = true; }
      { "${deps.miow."0.3.3".winapi}"."ws2ipdef" = true; }
      { "${deps.miow."0.3.3".winapi}".default = true; }
    ];
  }) [
    (features_.socket2."${deps."miow"."0.3.3"."socket2"}" deps)
    (features_.winapi."${deps."miow"."0.3.3"."winapi"}" deps)
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
# nix-0.14.1

  crates.nix."0.14.1" = deps: { features?(features_.nix."0.14.1" deps {}) }: buildRustCrate {
    crateName = "nix";
    version = "0.14.1";
    description = "Rust friendly bindings to *nix APIs";
    authors = [ "The nix-rust Project Developers" ];
    sha256 = "1hikdrihw975fcf3m2nmqjd7a00gxdzsbwjzlnjf6bgamr7ygipz";
    dependencies = mapFeatures features ([
      (crates."bitflags"."${deps."nix"."0.14.1"."bitflags"}" deps)
      (crates."cfg_if"."${deps."nix"."0.14.1"."cfg_if"}" deps)
      (crates."libc"."${deps."nix"."0.14.1"."libc"}" deps)
      (crates."void"."${deps."nix"."0.14.1"."void"}" deps)
    ])
      ++ (if kernel == "android" || kernel == "linux" then mapFeatures features ([
]) else [])
      ++ (if kernel == "dragonfly" then mapFeatures features ([
]) else [])
      ++ (if kernel == "freebsd" then mapFeatures features ([
]) else []);
  };
  features_.nix."0.14.1" = deps: f: updateFeatures f (rec {
    bitflags."${deps.nix."0.14.1".bitflags}".default = true;
    cfg_if."${deps.nix."0.14.1".cfg_if}".default = true;
    libc."${deps.nix."0.14.1".libc}".default = true;
    nix."0.14.1".default = (f.nix."0.14.1".default or true);
    void."${deps.nix."0.14.1".void}".default = true;
  }) [
    (features_.bitflags."${deps."nix"."0.14.1"."bitflags"}" deps)
    (features_.cfg_if."${deps."nix"."0.14.1"."cfg_if"}" deps)
    (features_.libc."${deps."nix"."0.14.1"."libc"}" deps)
    (features_.void."${deps."nix"."0.14.1"."void"}" deps)
  ];


# end
# notify-5.0.0-pre.1

  crates.notify."5.0.0-pre.1" = deps: { features?(features_.notify."5.0.0-pre.1" deps {}) }: buildRustCrate {
    crateName = "notify";
    version = "5.0.0-pre.1";
    description = "Cross-platform filesystem notification library";
    authors = [ "Félix Saparelli <me@passcod.name>" "Daniel Faust <hessijames@gmail.com>" ];
    edition = "2018";
    sha256 = "0hpawy8igcb1ga6p5xbwdk2c638hyg0148yfhdmqv6j42j0z4n9b";
    dependencies = mapFeatures features ([
      (crates."anymap"."${deps."notify"."5.0.0-pre.1"."anymap"}" deps)
      (crates."bitflags"."${deps."notify"."5.0.0-pre.1"."bitflags"}" deps)
      (crates."chashmap"."${deps."notify"."5.0.0-pre.1"."chashmap"}" deps)
      (crates."crossbeam_channel"."${deps."notify"."5.0.0-pre.1"."crossbeam_channel"}" deps)
      (crates."filetime"."${deps."notify"."5.0.0-pre.1"."filetime"}" deps)
      (crates."libc"."${deps."notify"."5.0.0-pre.1"."libc"}" deps)
      (crates."walkdir"."${deps."notify"."5.0.0-pre.1"."walkdir"}" deps)
    ])
      ++ (if kernel == "linux" then mapFeatures features ([
      (crates."inotify"."${deps."notify"."5.0.0-pre.1"."inotify"}" deps)
      (crates."mio"."${deps."notify"."5.0.0-pre.1"."mio"}" deps)
      (crates."mio_extras"."${deps."notify"."5.0.0-pre.1"."mio_extras"}" deps)
    ]) else [])
      ++ (if kernel == "darwin" then mapFeatures features ([
      (crates."fsevent"."${deps."notify"."5.0.0-pre.1"."fsevent"}" deps)
      (crates."fsevent_sys"."${deps."notify"."5.0.0-pre.1"."fsevent_sys"}" deps)
    ]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."kernel32_sys"."${deps."notify"."5.0.0-pre.1"."kernel32_sys"}" deps)
      (crates."winapi"."${deps."notify"."5.0.0-pre.1"."winapi"}" deps)
    ]) else []);
    features = mkFeatures (features."notify"."5.0.0-pre.1" or {});
  };
  features_.notify."5.0.0-pre.1" = deps: f: updateFeatures f (rec {
    anymap."${deps.notify."5.0.0-pre.1".anymap}".default = true;
    bitflags."${deps.notify."5.0.0-pre.1".bitflags}".default = true;
    chashmap."${deps.notify."5.0.0-pre.1".chashmap}".default = true;
    crossbeam_channel."${deps.notify."5.0.0-pre.1".crossbeam_channel}".default = true;
    filetime."${deps.notify."5.0.0-pre.1".filetime}".default = true;
    fsevent."${deps.notify."5.0.0-pre.1".fsevent}".default = true;
    fsevent_sys."${deps.notify."5.0.0-pre.1".fsevent_sys}".default = true;
    inotify."${deps.notify."5.0.0-pre.1".inotify}".default = (f.inotify."${deps.notify."5.0.0-pre.1".inotify}".default or false);
    kernel32_sys."${deps.notify."5.0.0-pre.1".kernel32_sys}".default = true;
    libc."${deps.notify."5.0.0-pre.1".libc}".default = true;
    mio."${deps.notify."5.0.0-pre.1".mio}".default = true;
    mio_extras."${deps.notify."5.0.0-pre.1".mio_extras}".default = true;
    notify."5.0.0-pre.1".default = (f.notify."5.0.0-pre.1".default or true);
    walkdir."${deps.notify."5.0.0-pre.1".walkdir}".default = true;
    winapi."${deps.notify."5.0.0-pre.1".winapi}".default = true;
  }) [
    (features_.anymap."${deps."notify"."5.0.0-pre.1"."anymap"}" deps)
    (features_.bitflags."${deps."notify"."5.0.0-pre.1"."bitflags"}" deps)
    (features_.chashmap."${deps."notify"."5.0.0-pre.1"."chashmap"}" deps)
    (features_.crossbeam_channel."${deps."notify"."5.0.0-pre.1"."crossbeam_channel"}" deps)
    (features_.filetime."${deps."notify"."5.0.0-pre.1"."filetime"}" deps)
    (features_.libc."${deps."notify"."5.0.0-pre.1"."libc"}" deps)
    (features_.walkdir."${deps."notify"."5.0.0-pre.1"."walkdir"}" deps)
    (features_.inotify."${deps."notify"."5.0.0-pre.1"."inotify"}" deps)
    (features_.mio."${deps."notify"."5.0.0-pre.1"."mio"}" deps)
    (features_.mio_extras."${deps."notify"."5.0.0-pre.1"."mio_extras"}" deps)
    (features_.fsevent."${deps."notify"."5.0.0-pre.1"."fsevent"}" deps)
    (features_.fsevent_sys."${deps."notify"."5.0.0-pre.1"."fsevent_sys"}" deps)
    (features_.kernel32_sys."${deps."notify"."5.0.0-pre.1"."kernel32_sys"}" deps)
    (features_.winapi."${deps."notify"."5.0.0-pre.1"."winapi"}" deps)
  ];


# end
# num-integer-0.1.41

  crates.num_integer."0.1.41" = deps: { features?(features_.num_integer."0.1.41" deps {}) }: buildRustCrate {
    crateName = "num-integer";
    version = "0.1.41";
    description = "Integer traits and functions";
    authors = [ "The Rust Project Developers" ];
    sha256 = "1y45nh9xlp2dra9svb1wfsy65fysm3k1w4m8jynywccq645yixid";
    build = "build.rs";
    dependencies = mapFeatures features ([
      (crates."num_traits"."${deps."num_integer"."0.1.41"."num_traits"}" deps)
    ]);

    buildDependencies = mapFeatures features ([
      (crates."autocfg"."${deps."num_integer"."0.1.41"."autocfg"}" deps)
    ]);
    features = mkFeatures (features."num_integer"."0.1.41" or {});
  };
  features_.num_integer."0.1.41" = deps: f: updateFeatures f (rec {
    autocfg."${deps.num_integer."0.1.41".autocfg}".default = true;
    num_integer = fold recursiveUpdate {} [
      { "0.1.41"."std" =
        (f.num_integer."0.1.41"."std" or false) ||
        (f.num_integer."0.1.41".default or false) ||
        (num_integer."0.1.41"."default" or false); }
      { "0.1.41".default = (f.num_integer."0.1.41".default or true); }
    ];
    num_traits = fold recursiveUpdate {} [
      { "${deps.num_integer."0.1.41".num_traits}"."i128" =
        (f.num_traits."${deps.num_integer."0.1.41".num_traits}"."i128" or false) ||
        (num_integer."0.1.41"."i128" or false) ||
        (f."num_integer"."0.1.41"."i128" or false); }
      { "${deps.num_integer."0.1.41".num_traits}"."std" =
        (f.num_traits."${deps.num_integer."0.1.41".num_traits}"."std" or false) ||
        (num_integer."0.1.41"."std" or false) ||
        (f."num_integer"."0.1.41"."std" or false); }
      { "${deps.num_integer."0.1.41".num_traits}".default = (f.num_traits."${deps.num_integer."0.1.41".num_traits}".default or false); }
    ];
  }) [
    (features_.num_traits."${deps."num_integer"."0.1.41"."num_traits"}" deps)
    (features_.autocfg."${deps."num_integer"."0.1.41"."autocfg"}" deps)
  ];


# end
# num-traits-0.2.10

  crates.num_traits."0.2.10" = deps: { features?(features_.num_traits."0.2.10" deps {}) }: buildRustCrate {
    crateName = "num-traits";
    version = "0.2.10";
    description = "Numeric traits for generic mathematics";
    authors = [ "The Rust Project Developers" ];
    sha256 = "0f2974brqrfqinws35249ac1g0slr9viqkyf2fkgxckcllssmzfi";
    build = "build.rs";
    dependencies = mapFeatures features ([
]);

    buildDependencies = mapFeatures features ([
      (crates."autocfg"."${deps."num_traits"."0.2.10"."autocfg"}" deps)
    ]);
    features = mkFeatures (features."num_traits"."0.2.10" or {});
  };
  features_.num_traits."0.2.10" = deps: f: updateFeatures f (rec {
    autocfg."${deps.num_traits."0.2.10".autocfg}".default = true;
    num_traits = fold recursiveUpdate {} [
      { "0.2.10"."std" =
        (f.num_traits."0.2.10"."std" or false) ||
        (f.num_traits."0.2.10".default or false) ||
        (num_traits."0.2.10"."default" or false); }
      { "0.2.10".default = (f.num_traits."0.2.10".default or true); }
    ];
  }) [
    (features_.autocfg."${deps."num_traits"."0.2.10"."autocfg"}" deps)
  ];


# end
# num_cpus-1.11.1

  crates.num_cpus."1.11.1" = deps: { features?(features_.num_cpus."1.11.1" deps {}) }: buildRustCrate {
    crateName = "num_cpus";
    version = "1.11.1";
    description = "Get the number of CPUs on a machine.";
    authors = [ "Sean McArthur <sean@seanmonstar.com>" ];
    sha256 = "0f53q5g6ky6zl4r5qp65yh2rdf0bdpypp8xzpikc75r8py3j91nx";
    dependencies = mapFeatures features ([
      (crates."libc"."${deps."num_cpus"."1.11.1"."libc"}" deps)
    ])
      ++ (if cpu == "x86_64" || cpu == "aarch64" && kernel == "hermit" then mapFeatures features ([
      (crates."hermit_abi"."${deps."num_cpus"."1.11.1"."hermit_abi"}" deps)
    ]) else []);
  };
  features_.num_cpus."1.11.1" = deps: f: updateFeatures f (rec {
    hermit_abi."${deps.num_cpus."1.11.1".hermit_abi}".default = true;
    libc."${deps.num_cpus."1.11.1".libc}".default = true;
    num_cpus."1.11.1".default = (f.num_cpus."1.11.1".default or true);
  }) [
    (features_.libc."${deps."num_cpus"."1.11.1"."libc"}" deps)
    (features_.hermit_abi."${deps."num_cpus"."1.11.1"."hermit_abi"}" deps)
  ];


# end
# os_type-2.2.0

  crates.os_type."2.2.0" = deps: { features?(features_.os_type."2.2.0" deps {}) }: buildRustCrate {
    crateName = "os_type";
    version = "2.2.0";
    description = "Detect the operating system type";
    authors = [ "Jan Schulte <hello@unexpected-co.de>" ];
    sha256 = "100ldg1vv0pxrb9s83vb4awvczbg8iy1by6vx6zl8vpdnr8n2ghg";
    dependencies = mapFeatures features ([
      (crates."regex"."${deps."os_type"."2.2.0"."regex"}" deps)
    ]);
  };
  features_.os_type."2.2.0" = deps: f: updateFeatures f (rec {
    os_type."2.2.0".default = (f.os_type."2.2.0".default or true);
    regex."${deps.os_type."2.2.0".regex}".default = true;
  }) [
    (features_.regex."${deps."os_type"."2.2.0"."regex"}" deps)
  ];


# end
# owning_ref-0.3.3

  crates.owning_ref."0.3.3" = deps: { features?(features_.owning_ref."0.3.3" deps {}) }: buildRustCrate {
    crateName = "owning_ref";
    version = "0.3.3";
    description = "A library for creating references that carry their owner with them.";
    authors = [ "Marvin Löbel <loebel.marvin@gmail.com>" ];
    sha256 = "13ivn0ydc0hf957ix0f5si9nnplzzykbr70hni1qz9m19i9kvmrh";
    dependencies = mapFeatures features ([
      (crates."stable_deref_trait"."${deps."owning_ref"."0.3.3"."stable_deref_trait"}" deps)
    ]);
  };
  features_.owning_ref."0.3.3" = deps: f: updateFeatures f (rec {
    owning_ref."0.3.3".default = (f.owning_ref."0.3.3".default or true);
    stable_deref_trait."${deps.owning_ref."0.3.3".stable_deref_trait}".default = true;
  }) [
    (features_.stable_deref_trait."${deps."owning_ref"."0.3.3"."stable_deref_trait"}" deps)
  ];


# end
# parking_lot-0.4.8

  crates.parking_lot."0.4.8" = deps: { features?(features_.parking_lot."0.4.8" deps {}) }: buildRustCrate {
    crateName = "parking_lot";
    version = "0.4.8";
    description = "More compact and efficient implementations of the standard synchronization primitives.";
    authors = [ "Amanieu d'Antras <amanieu@gmail.com>" ];
    sha256 = "0qrb2f0azglbsx7k3skgnc7mmv9z9spnqgk1m450g91r94nlklqi";
    dependencies = mapFeatures features ([
      (crates."parking_lot_core"."${deps."parking_lot"."0.4.8"."parking_lot_core"}" deps)
    ]
      ++ (if features.parking_lot."0.4.8".owning_ref or false then [ (crates.owning_ref."${deps."parking_lot"."0.4.8".owning_ref}" deps) ] else []));
    features = mkFeatures (features."parking_lot"."0.4.8" or {});
  };
  features_.parking_lot."0.4.8" = deps: f: updateFeatures f (rec {
    owning_ref."${deps.parking_lot."0.4.8".owning_ref}".default = true;
    parking_lot = fold recursiveUpdate {} [
      { "0.4.8"."owning_ref" =
        (f.parking_lot."0.4.8"."owning_ref" or false) ||
        (f.parking_lot."0.4.8".default or false) ||
        (parking_lot."0.4.8"."default" or false); }
      { "0.4.8".default = (f.parking_lot."0.4.8".default or true); }
    ];
    parking_lot_core = fold recursiveUpdate {} [
      { "${deps.parking_lot."0.4.8".parking_lot_core}"."deadlock_detection" =
        (f.parking_lot_core."${deps.parking_lot."0.4.8".parking_lot_core}"."deadlock_detection" or false) ||
        (parking_lot."0.4.8"."deadlock_detection" or false) ||
        (f."parking_lot"."0.4.8"."deadlock_detection" or false); }
      { "${deps.parking_lot."0.4.8".parking_lot_core}"."nightly" =
        (f.parking_lot_core."${deps.parking_lot."0.4.8".parking_lot_core}"."nightly" or false) ||
        (parking_lot."0.4.8"."nightly" or false) ||
        (f."parking_lot"."0.4.8"."nightly" or false); }
      { "${deps.parking_lot."0.4.8".parking_lot_core}".default = true; }
    ];
  }) [
    (features_.owning_ref."${deps."parking_lot"."0.4.8"."owning_ref"}" deps)
    (features_.parking_lot_core."${deps."parking_lot"."0.4.8"."parking_lot_core"}" deps)
  ];


# end
# parking_lot_core-0.2.14

  crates.parking_lot_core."0.2.14" = deps: { features?(features_.parking_lot_core."0.2.14" deps {}) }: buildRustCrate {
    crateName = "parking_lot_core";
    version = "0.2.14";
    description = "An advanced API for creating custom synchronization primitives.";
    authors = [ "Amanieu d'Antras <amanieu@gmail.com>" ];
    sha256 = "0giypb8ckkpi34p14nfk4b19c7przj4jxs95gs7x2v5ncmi0y286";
    dependencies = mapFeatures features ([
      (crates."rand"."${deps."parking_lot_core"."0.2.14"."rand"}" deps)
      (crates."smallvec"."${deps."parking_lot_core"."0.2.14"."smallvec"}" deps)
    ])
      ++ (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
      (crates."libc"."${deps."parking_lot_core"."0.2.14"."libc"}" deps)
    ]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."parking_lot_core"."0.2.14"."winapi"}" deps)
    ]) else []);
    features = mkFeatures (features."parking_lot_core"."0.2.14" or {});
  };
  features_.parking_lot_core."0.2.14" = deps: f: updateFeatures f (rec {
    libc."${deps.parking_lot_core."0.2.14".libc}".default = true;
    parking_lot_core = fold recursiveUpdate {} [
      { "0.2.14"."backtrace" =
        (f.parking_lot_core."0.2.14"."backtrace" or false) ||
        (f.parking_lot_core."0.2.14".deadlock_detection or false) ||
        (parking_lot_core."0.2.14"."deadlock_detection" or false); }
      { "0.2.14"."petgraph" =
        (f.parking_lot_core."0.2.14"."petgraph" or false) ||
        (f.parking_lot_core."0.2.14".deadlock_detection or false) ||
        (parking_lot_core."0.2.14"."deadlock_detection" or false); }
      { "0.2.14"."thread-id" =
        (f.parking_lot_core."0.2.14"."thread-id" or false) ||
        (f.parking_lot_core."0.2.14".deadlock_detection or false) ||
        (parking_lot_core."0.2.14"."deadlock_detection" or false); }
      { "0.2.14".default = (f.parking_lot_core."0.2.14".default or true); }
    ];
    rand."${deps.parking_lot_core."0.2.14".rand}".default = true;
    smallvec."${deps.parking_lot_core."0.2.14".smallvec}".default = true;
    winapi = fold recursiveUpdate {} [
      { "${deps.parking_lot_core."0.2.14".winapi}"."errhandlingapi" = true; }
      { "${deps.parking_lot_core."0.2.14".winapi}"."handleapi" = true; }
      { "${deps.parking_lot_core."0.2.14".winapi}"."minwindef" = true; }
      { "${deps.parking_lot_core."0.2.14".winapi}"."ntstatus" = true; }
      { "${deps.parking_lot_core."0.2.14".winapi}"."winbase" = true; }
      { "${deps.parking_lot_core."0.2.14".winapi}"."winerror" = true; }
      { "${deps.parking_lot_core."0.2.14".winapi}"."winnt" = true; }
      { "${deps.parking_lot_core."0.2.14".winapi}".default = true; }
    ];
  }) [
    (features_.rand."${deps."parking_lot_core"."0.2.14"."rand"}" deps)
    (features_.smallvec."${deps."parking_lot_core"."0.2.14"."smallvec"}" deps)
    (features_.libc."${deps."parking_lot_core"."0.2.14"."libc"}" deps)
    (features_.winapi."${deps."parking_lot_core"."0.2.14"."winapi"}" deps)
  ];


# end
# pin-project-lite-0.1.1

  crates.pin_project_lite."0.1.1" = deps: { features?(features_.pin_project_lite."0.1.1" deps {}) }: buildRustCrate {
    crateName = "pin-project-lite";
    version = "0.1.1";
    description = "A lightweight version of pin-project written with declarative macros.\n";
    authors = [ "Taiki Endo <te316e89@gmail.com>" ];
    edition = "2018";
    sha256 = "08w3an8962j2rdk8gv3213izgw79a1qfwb0vfxa3nmlp6aidq5gr";
  };
  features_.pin_project_lite."0.1.1" = deps: f: updateFeatures f (rec {
    pin_project_lite."0.1.1".default = (f.pin_project_lite."0.1.1".default or true);
  }) [];


# end
# pin-utils-0.1.0-alpha.4

  crates.pin_utils."0.1.0-alpha.4" = deps: { features?(features_.pin_utils."0.1.0-alpha.4" deps {}) }: buildRustCrate {
    crateName = "pin-utils";
    version = "0.1.0-alpha.4";
    description = "Utilities for pinning\n";
    authors = [ "Josef Brandl <mail@josefbrandl.de>" ];
    edition = "2018";
    sha256 = "1fl7h1f6gr7qj903k3ir2vw993gbj4dd775s0idq4pzsbjqjj3x1";
  };
  features_.pin_utils."0.1.0-alpha.4" = deps: f: updateFeatures f (rec {
    pin_utils."0.1.0-alpha.4".default = (f.pin_utils."0.1.0-alpha.4".default or true);
  }) [];


# end
# ppv-lite86-0.2.6

  crates.ppv_lite86."0.2.6" = deps: { features?(features_.ppv_lite86."0.2.6" deps {}) }: buildRustCrate {
    crateName = "ppv-lite86";
    version = "0.2.6";
    description = "Implementation of the crypto-simd API for x86";
    authors = [ "The CryptoCorrosion Contributors" ];
    edition = "2018";
    sha256 = "1mlbp0713frbyvcbjmc5vl062b0vr58agkv3ar2qqi5plgy9b7ib";
    features = mkFeatures (features."ppv_lite86"."0.2.6" or {});
  };
  features_.ppv_lite86."0.2.6" = deps: f: updateFeatures f (rec {
    ppv_lite86 = fold recursiveUpdate {} [
      { "0.2.6"."simd" =
        (f.ppv_lite86."0.2.6"."simd" or false) ||
        (f.ppv_lite86."0.2.6".default or false) ||
        (ppv_lite86."0.2.6"."default" or false); }
      { "0.2.6"."std" =
        (f.ppv_lite86."0.2.6"."std" or false) ||
        (f.ppv_lite86."0.2.6".default or false) ||
        (ppv_lite86."0.2.6"."default" or false); }
      { "0.2.6".default = (f.ppv_lite86."0.2.6".default or true); }
    ];
  }) [];


# end
# proc-macro-hack-0.5.11

  crates.proc_macro_hack."0.5.11" = deps: { features?(features_.proc_macro_hack."0.5.11" deps {}) }: buildRustCrate {
    crateName = "proc-macro-hack";
    version = "0.5.11";
    description = "Procedural macros in expression position";
    authors = [ "David Tolnay <dtolnay@gmail.com>" ];
    edition = "2018";
    sha256 = "0cnpfl5x7cac9d94in5r93b29frski33jhvgp7n6qih9gpsxqn80";
    procMacro = true;
    dependencies = mapFeatures features ([
      (crates."proc_macro2"."${deps."proc_macro_hack"."0.5.11"."proc_macro2"}" deps)
      (crates."quote"."${deps."proc_macro_hack"."0.5.11"."quote"}" deps)
      (crates."syn"."${deps."proc_macro_hack"."0.5.11"."syn"}" deps)
    ]);
  };
  features_.proc_macro_hack."0.5.11" = deps: f: updateFeatures f (rec {
    proc_macro2."${deps.proc_macro_hack."0.5.11".proc_macro2}".default = true;
    proc_macro_hack."0.5.11".default = (f.proc_macro_hack."0.5.11".default or true);
    quote."${deps.proc_macro_hack."0.5.11".quote}".default = true;
    syn."${deps.proc_macro_hack."0.5.11".syn}".default = true;
  }) [
    (features_.proc_macro2."${deps."proc_macro_hack"."0.5.11"."proc_macro2"}" deps)
    (features_.quote."${deps."proc_macro_hack"."0.5.11"."quote"}" deps)
    (features_.syn."${deps."proc_macro_hack"."0.5.11"."syn"}" deps)
  ];


# end
# proc-macro-nested-0.1.3

  crates.proc_macro_nested."0.1.3" = deps: { features?(features_.proc_macro_nested."0.1.3" deps {}) }: buildRustCrate {
    crateName = "proc-macro-nested";
    version = "0.1.3";
    description = "Support for nested proc-macro-hack invocations";
    authors = [ "David Tolnay <dtolnay@gmail.com>" ];
    sha256 = "1xbai316ygv2gxc9vjb8b2nr6xia3ahc19nh66vkwnvz1nc90gya";
  };
  features_.proc_macro_nested."0.1.3" = deps: f: updateFeatures f (rec {
    proc_macro_nested."0.1.3".default = (f.proc_macro_nested."0.1.3".default or true);
  }) [];


# end
# proc-macro2-0.4.30

  crates.proc_macro2."0.4.30" = deps: { features?(features_.proc_macro2."0.4.30" deps {}) }: buildRustCrate {
    crateName = "proc-macro2";
    version = "0.4.30";
    description = "A stable implementation of the upcoming new `proc_macro` API. Comes with an\noption, off by default, to also reimplement itself in terms of the upstream\nunstable API.\n";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    sha256 = "0iifv51wrm6r4r2gghw6rray3nv53zcap355bbz1nsmbhj5s09b9";
    build = "build.rs";
    dependencies = mapFeatures features ([
      (crates."unicode_xid"."${deps."proc_macro2"."0.4.30"."unicode_xid"}" deps)
    ]);
    features = mkFeatures (features."proc_macro2"."0.4.30" or {});
  };
  features_.proc_macro2."0.4.30" = deps: f: updateFeatures f (rec {
    proc_macro2 = fold recursiveUpdate {} [
      { "0.4.30"."proc-macro" =
        (f.proc_macro2."0.4.30"."proc-macro" or false) ||
        (f.proc_macro2."0.4.30".default or false) ||
        (proc_macro2."0.4.30"."default" or false); }
      { "0.4.30".default = (f.proc_macro2."0.4.30".default or true); }
    ];
    unicode_xid."${deps.proc_macro2."0.4.30".unicode_xid}".default = true;
  }) [
    (features_.unicode_xid."${deps."proc_macro2"."0.4.30"."unicode_xid"}" deps)
  ];


# end
# proc-macro2-1.0.6

  crates.proc_macro2."1.0.6" = deps: { features?(features_.proc_macro2."1.0.6" deps {}) }: buildRustCrate {
    crateName = "proc-macro2";
    version = "1.0.6";
    description = "A stable implementation of the upcoming new `proc_macro` API. Comes with an\noption, off by default, to also reimplement itself in terms of the upstream\nunstable API.\n";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    edition = "2018";
    sha256 = "1l56ss9ip8cg6764cpi9y8dv7nsyqf2i4hb7sn29zx61n03jr81z";
    dependencies = mapFeatures features ([
      (crates."unicode_xid"."${deps."proc_macro2"."1.0.6"."unicode_xid"}" deps)
    ]);
    features = mkFeatures (features."proc_macro2"."1.0.6" or {});
  };
  features_.proc_macro2."1.0.6" = deps: f: updateFeatures f (rec {
    proc_macro2 = fold recursiveUpdate {} [
      { "1.0.6"."proc-macro" =
        (f.proc_macro2."1.0.6"."proc-macro" or false) ||
        (f.proc_macro2."1.0.6".default or false) ||
        (proc_macro2."1.0.6"."default" or false); }
      { "1.0.6".default = (f.proc_macro2."1.0.6".default or true); }
    ];
    unicode_xid."${deps.proc_macro2."1.0.6".unicode_xid}".default = true;
  }) [
    (features_.unicode_xid."${deps."proc_macro2"."1.0.6"."unicode_xid"}" deps)
  ];


# end
# proptest-0.9.4

  crates.proptest."0.9.4" = deps: { features?(features_.proptest."0.9.4" deps {}) }: buildRustCrate {
    crateName = "proptest";
    version = "0.9.4";
    description = "Hypothesis-like property-based testing and shrinking.\n";
    authors = [ "Jason Lingle" ];
    edition = "2018";
    sha256 = "0m2dsfwgqgbqg4gbc27db3md4gdkbgambn3kkivypwiibfrqdkrh";
    dependencies = mapFeatures features ([
      (crates."bitflags"."${deps."proptest"."0.9.4"."bitflags"}" deps)
      (crates."byteorder"."${deps."proptest"."0.9.4"."byteorder"}" deps)
      (crates."num_traits"."${deps."proptest"."0.9.4"."num_traits"}" deps)
      (crates."rand"."${deps."proptest"."0.9.4"."rand"}" deps)
      (crates."rand_chacha"."${deps."proptest"."0.9.4"."rand_chacha"}" deps)
      (crates."rand_xorshift"."${deps."proptest"."0.9.4"."rand_xorshift"}" deps)
    ]
      ++ (if features.proptest."0.9.4".bit-set or false then [ (crates.bit_set."${deps."proptest"."0.9.4".bit_set}" deps) ] else [])
      ++ (if features.proptest."0.9.4".lazy_static or false then [ (crates.lazy_static."${deps."proptest"."0.9.4".lazy_static}" deps) ] else [])
      ++ (if features.proptest."0.9.4".quick-error or false then [ (crates.quick_error."${deps."proptest"."0.9.4".quick_error}" deps) ] else [])
      ++ (if features.proptest."0.9.4".regex-syntax or false then [ (crates.regex_syntax."${deps."proptest"."0.9.4".regex_syntax}" deps) ] else [])
      ++ (if features.proptest."0.9.4".rusty-fork or false then [ (crates.rusty_fork."${deps."proptest"."0.9.4".rusty_fork}" deps) ] else [])
      ++ (if features.proptest."0.9.4".tempfile or false then [ (crates.tempfile."${deps."proptest"."0.9.4".tempfile}" deps) ] else []));
    features = mkFeatures (features."proptest"."0.9.4" or {});
  };
  features_.proptest."0.9.4" = deps: f: updateFeatures f (rec {
    bit_set."${deps.proptest."0.9.4".bit_set}".default = true;
    bitflags."${deps.proptest."0.9.4".bitflags}".default = true;
    byteorder = fold recursiveUpdate {} [
      { "${deps.proptest."0.9.4".byteorder}"."std" =
        (f.byteorder."${deps.proptest."0.9.4".byteorder}"."std" or false) ||
        (proptest."0.9.4"."std" or false) ||
        (f."proptest"."0.9.4"."std" or false); }
      { "${deps.proptest."0.9.4".byteorder}".default = (f.byteorder."${deps.proptest."0.9.4".byteorder}".default or false); }
    ];
    lazy_static."${deps.proptest."0.9.4".lazy_static}".default = true;
    num_traits = fold recursiveUpdate {} [
      { "${deps.proptest."0.9.4".num_traits}"."std" =
        (f.num_traits."${deps.proptest."0.9.4".num_traits}"."std" or false) ||
        (proptest."0.9.4"."std" or false) ||
        (f."proptest"."0.9.4"."std" or false); }
      { "${deps.proptest."0.9.4".num_traits}".default = (f.num_traits."${deps.proptest."0.9.4".num_traits}".default or false); }
    ];
    proptest = fold recursiveUpdate {} [
      { "0.9.4"."bit-set" =
        (f.proptest."0.9.4"."bit-set" or false) ||
        (f.proptest."0.9.4".default or false) ||
        (proptest."0.9.4"."default" or false) ||
        (f.proptest."0.9.4".default-code-coverage or false) ||
        (proptest."0.9.4"."default-code-coverage" or false); }
      { "0.9.4"."break-dead-code" =
        (f.proptest."0.9.4"."break-dead-code" or false) ||
        (f.proptest."0.9.4".default or false) ||
        (proptest."0.9.4"."default" or false); }
      { "0.9.4"."fork" =
        (f.proptest."0.9.4"."fork" or false) ||
        (f.proptest."0.9.4".default or false) ||
        (proptest."0.9.4"."default" or false) ||
        (f.proptest."0.9.4".default-code-coverage or false) ||
        (proptest."0.9.4"."default-code-coverage" or false) ||
        (f.proptest."0.9.4".timeout or false) ||
        (proptest."0.9.4"."timeout" or false); }
      { "0.9.4"."lazy_static" =
        (f.proptest."0.9.4"."lazy_static" or false) ||
        (f.proptest."0.9.4".std or false) ||
        (proptest."0.9.4"."std" or false); }
      { "0.9.4"."quick-error" =
        (f.proptest."0.9.4"."quick-error" or false) ||
        (f.proptest."0.9.4".std or false) ||
        (proptest."0.9.4"."std" or false); }
      { "0.9.4"."regex-syntax" =
        (f.proptest."0.9.4"."regex-syntax" or false) ||
        (f.proptest."0.9.4".std or false) ||
        (proptest."0.9.4"."std" or false); }
      { "0.9.4"."rusty-fork" =
        (f.proptest."0.9.4"."rusty-fork" or false) ||
        (f.proptest."0.9.4".fork or false) ||
        (proptest."0.9.4"."fork" or false); }
      { "0.9.4"."std" =
        (f.proptest."0.9.4"."std" or false) ||
        (f.proptest."0.9.4".default or false) ||
        (proptest."0.9.4"."default" or false) ||
        (f.proptest."0.9.4".default-code-coverage or false) ||
        (proptest."0.9.4"."default-code-coverage" or false) ||
        (f.proptest."0.9.4".fork or false) ||
        (proptest."0.9.4"."fork" or false); }
      { "0.9.4"."tempfile" =
        (f.proptest."0.9.4"."tempfile" or false) ||
        (f.proptest."0.9.4".fork or false) ||
        (proptest."0.9.4"."fork" or false); }
      { "0.9.4"."timeout" =
        (f.proptest."0.9.4"."timeout" or false) ||
        (f.proptest."0.9.4".default or false) ||
        (proptest."0.9.4"."default" or false) ||
        (f.proptest."0.9.4".default-code-coverage or false) ||
        (proptest."0.9.4"."default-code-coverage" or false); }
      { "0.9.4".default = (f.proptest."0.9.4".default or true); }
    ];
    quick_error."${deps.proptest."0.9.4".quick_error}".default = true;
    rand = fold recursiveUpdate {} [
      { "${deps.proptest."0.9.4".rand}"."alloc" = true; }
      { "${deps.proptest."0.9.4".rand}"."i128_support" = true; }
      { "${deps.proptest."0.9.4".rand}"."std" =
        (f.rand."${deps.proptest."0.9.4".rand}"."std" or false) ||
        (proptest."0.9.4"."std" or false) ||
        (f."proptest"."0.9.4"."std" or false); }
      { "${deps.proptest."0.9.4".rand}".default = (f.rand."${deps.proptest."0.9.4".rand}".default or false); }
    ];
    rand_chacha."${deps.proptest."0.9.4".rand_chacha}".default = true;
    rand_xorshift."${deps.proptest."0.9.4".rand_xorshift}".default = true;
    regex_syntax."${deps.proptest."0.9.4".regex_syntax}".default = true;
    rusty_fork = fold recursiveUpdate {} [
      { "${deps.proptest."0.9.4".rusty_fork}"."timeout" =
        (f.rusty_fork."${deps.proptest."0.9.4".rusty_fork}"."timeout" or false) ||
        (proptest."0.9.4"."timeout" or false) ||
        (f."proptest"."0.9.4"."timeout" or false); }
      { "${deps.proptest."0.9.4".rusty_fork}".default = (f.rusty_fork."${deps.proptest."0.9.4".rusty_fork}".default or false); }
    ];
    tempfile."${deps.proptest."0.9.4".tempfile}".default = true;
  }) [
    (features_.bit_set."${deps."proptest"."0.9.4"."bit_set"}" deps)
    (features_.bitflags."${deps."proptest"."0.9.4"."bitflags"}" deps)
    (features_.byteorder."${deps."proptest"."0.9.4"."byteorder"}" deps)
    (features_.lazy_static."${deps."proptest"."0.9.4"."lazy_static"}" deps)
    (features_.num_traits."${deps."proptest"."0.9.4"."num_traits"}" deps)
    (features_.quick_error."${deps."proptest"."0.9.4"."quick_error"}" deps)
    (features_.rand."${deps."proptest"."0.9.4"."rand"}" deps)
    (features_.rand_chacha."${deps."proptest"."0.9.4"."rand_chacha"}" deps)
    (features_.rand_xorshift."${deps."proptest"."0.9.4"."rand_xorshift"}" deps)
    (features_.regex_syntax."${deps."proptest"."0.9.4"."regex_syntax"}" deps)
    (features_.rusty_fork."${deps."proptest"."0.9.4"."rusty_fork"}" deps)
    (features_.tempfile."${deps."proptest"."0.9.4"."tempfile"}" deps)
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
# quote-0.6.13

  crates.quote."0.6.13" = deps: { features?(features_.quote."0.6.13" deps {}) }: buildRustCrate {
    crateName = "quote";
    version = "0.6.13";
    description = "Quasi-quoting macro quote!(...)";
    authors = [ "David Tolnay <dtolnay@gmail.com>" ];
    sha256 = "1hrvsin40i4q8swrhlj9057g7nsp0lg02h8zbzmgz14av9mzv8g8";
    dependencies = mapFeatures features ([
      (crates."proc_macro2"."${deps."quote"."0.6.13"."proc_macro2"}" deps)
    ]);
    features = mkFeatures (features."quote"."0.6.13" or {});
  };
  features_.quote."0.6.13" = deps: f: updateFeatures f (rec {
    proc_macro2 = fold recursiveUpdate {} [
      { "${deps.quote."0.6.13".proc_macro2}"."proc-macro" =
        (f.proc_macro2."${deps.quote."0.6.13".proc_macro2}"."proc-macro" or false) ||
        (quote."0.6.13"."proc-macro" or false) ||
        (f."quote"."0.6.13"."proc-macro" or false); }
      { "${deps.quote."0.6.13".proc_macro2}".default = (f.proc_macro2."${deps.quote."0.6.13".proc_macro2}".default or false); }
    ];
    quote = fold recursiveUpdate {} [
      { "0.6.13"."proc-macro" =
        (f.quote."0.6.13"."proc-macro" or false) ||
        (f.quote."0.6.13".default or false) ||
        (quote."0.6.13"."default" or false); }
      { "0.6.13".default = (f.quote."0.6.13".default or true); }
    ];
  }) [
    (features_.proc_macro2."${deps."quote"."0.6.13"."proc_macro2"}" deps)
  ];


# end
# quote-1.0.2

  crates.quote."1.0.2" = deps: { features?(features_.quote."1.0.2" deps {}) }: buildRustCrate {
    crateName = "quote";
    version = "1.0.2";
    description = "Quasi-quoting macro quote!(...)";
    authors = [ "David Tolnay <dtolnay@gmail.com>" ];
    edition = "2018";
    sha256 = "0r7030w7dymarn92gjgm02hsm04fwsfs6f1l20wdqiyrm9z8rs5q";
    dependencies = mapFeatures features ([
      (crates."proc_macro2"."${deps."quote"."1.0.2"."proc_macro2"}" deps)
    ]);
    features = mkFeatures (features."quote"."1.0.2" or {});
  };
  features_.quote."1.0.2" = deps: f: updateFeatures f (rec {
    proc_macro2 = fold recursiveUpdate {} [
      { "${deps.quote."1.0.2".proc_macro2}"."proc-macro" =
        (f.proc_macro2."${deps.quote."1.0.2".proc_macro2}"."proc-macro" or false) ||
        (quote."1.0.2"."proc-macro" or false) ||
        (f."quote"."1.0.2"."proc-macro" or false); }
      { "${deps.quote."1.0.2".proc_macro2}".default = (f.proc_macro2."${deps.quote."1.0.2".proc_macro2}".default or false); }
    ];
    quote = fold recursiveUpdate {} [
      { "1.0.2"."proc-macro" =
        (f.quote."1.0.2"."proc-macro" or false) ||
        (f.quote."1.0.2".default or false) ||
        (quote."1.0.2"."default" or false); }
      { "1.0.2".default = (f.quote."1.0.2".default or true); }
    ];
  }) [
    (features_.proc_macro2."${deps."quote"."1.0.2"."proc_macro2"}" deps)
  ];


# end
# rand-0.4.6

  crates.rand."0.4.6" = deps: { features?(features_.rand."0.4.6" deps {}) }: buildRustCrate {
    crateName = "rand";
    version = "0.4.6";
    description = "Random number generators and other randomness functionality.\n";
    authors = [ "The Rust Project Developers" ];
    sha256 = "0c3rmg5q7d6qdi7cbmg5py9alm70wd3xsg0mmcawrnl35qv37zfs";
    dependencies = (if abi == "sgx" then mapFeatures features ([
      (crates."rand_core"."${deps."rand"."0.4.6"."rand_core"}" deps)
      (crates."rdrand"."${deps."rand"."0.4.6"."rdrand"}" deps)
    ]) else [])
      ++ (if kernel == "fuchsia" then mapFeatures features ([
      (crates."fuchsia_cprng"."${deps."rand"."0.4.6"."fuchsia_cprng"}" deps)
    ]) else [])
      ++ (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
    ]
      ++ (if features.rand."0.4.6".libc or false then [ (crates.libc."${deps."rand"."0.4.6".libc}" deps) ] else [])) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."rand"."0.4.6"."winapi"}" deps)
    ]) else []);
    features = mkFeatures (features."rand"."0.4.6" or {});
  };
  features_.rand."0.4.6" = deps: f: updateFeatures f (rec {
    fuchsia_cprng."${deps.rand."0.4.6".fuchsia_cprng}".default = true;
    libc."${deps.rand."0.4.6".libc}".default = true;
    rand = fold recursiveUpdate {} [
      { "0.4.6"."i128_support" =
        (f.rand."0.4.6"."i128_support" or false) ||
        (f.rand."0.4.6".nightly or false) ||
        (rand."0.4.6"."nightly" or false); }
      { "0.4.6"."libc" =
        (f.rand."0.4.6"."libc" or false) ||
        (f.rand."0.4.6".std or false) ||
        (rand."0.4.6"."std" or false); }
      { "0.4.6"."std" =
        (f.rand."0.4.6"."std" or false) ||
        (f.rand."0.4.6".default or false) ||
        (rand."0.4.6"."default" or false); }
      { "0.4.6".default = (f.rand."0.4.6".default or true); }
    ];
    rand_core."${deps.rand."0.4.6".rand_core}".default = (f.rand_core."${deps.rand."0.4.6".rand_core}".default or false);
    rdrand."${deps.rand."0.4.6".rdrand}".default = true;
    winapi = fold recursiveUpdate {} [
      { "${deps.rand."0.4.6".winapi}"."minwindef" = true; }
      { "${deps.rand."0.4.6".winapi}"."ntsecapi" = true; }
      { "${deps.rand."0.4.6".winapi}"."profileapi" = true; }
      { "${deps.rand."0.4.6".winapi}"."winnt" = true; }
      { "${deps.rand."0.4.6".winapi}".default = true; }
    ];
  }) [
    (features_.rand_core."${deps."rand"."0.4.6"."rand_core"}" deps)
    (features_.rdrand."${deps."rand"."0.4.6"."rdrand"}" deps)
    (features_.fuchsia_cprng."${deps."rand"."0.4.6"."fuchsia_cprng"}" deps)
    (features_.libc."${deps."rand"."0.4.6"."libc"}" deps)
    (features_.winapi."${deps."rand"."0.4.6"."winapi"}" deps)
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
# rand-0.7.2

  crates.rand."0.7.2" = deps: { features?(features_.rand."0.7.2" deps {}) }: buildRustCrate {
    crateName = "rand";
    version = "0.7.2";
    description = "Random number generators and other randomness functionality.\n";
    authors = [ "The Rand Project Developers" "The Rust Project Developers" ];
    edition = "2018";
    sha256 = "1f53047g63b9kyyx1k8wgwzspk4n96w2n2h1a9848ggl9y9h0ik6";
    dependencies = mapFeatures features ([
      (crates."rand_core"."${deps."rand"."0.7.2"."rand_core"}" deps)
    ])
      ++ (if !(kernel == "emscripten") then mapFeatures features ([
      (crates."rand_chacha"."${deps."rand"."0.7.2"."rand_chacha"}" deps)
    ]) else [])
      ++ (if kernel == "emscripten" then mapFeatures features ([
      (crates."rand_hc"."${deps."rand"."0.7.2"."rand_hc"}" deps)
    ]) else [])
      ++ (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
      (crates."libc"."${deps."rand"."0.7.2"."libc"}" deps)
    ]) else []);
    features = mkFeatures (features."rand"."0.7.2" or {});
  };
  features_.rand."0.7.2" = deps: f: updateFeatures f (rec {
    libc."${deps.rand."0.7.2".libc}".default = (f.libc."${deps.rand."0.7.2".libc}".default or false);
    rand = fold recursiveUpdate {} [
      { "0.7.2"."alloc" =
        (f.rand."0.7.2"."alloc" or false) ||
        (f.rand."0.7.2".std or false) ||
        (rand."0.7.2"."std" or false); }
      { "0.7.2"."getrandom" =
        (f.rand."0.7.2"."getrandom" or false) ||
        (f.rand."0.7.2".std or false) ||
        (rand."0.7.2"."std" or false); }
      { "0.7.2"."getrandom_package" =
        (f.rand."0.7.2"."getrandom_package" or false) ||
        (f.rand."0.7.2".getrandom or false) ||
        (rand."0.7.2"."getrandom" or false); }
      { "0.7.2"."packed_simd" =
        (f.rand."0.7.2"."packed_simd" or false) ||
        (f.rand."0.7.2".simd_support or false) ||
        (rand."0.7.2"."simd_support" or false); }
      { "0.7.2"."rand_pcg" =
        (f.rand."0.7.2"."rand_pcg" or false) ||
        (f.rand."0.7.2".small_rng or false) ||
        (rand."0.7.2"."small_rng" or false); }
      { "0.7.2"."simd_support" =
        (f.rand."0.7.2"."simd_support" or false) ||
        (f.rand."0.7.2".nightly or false) ||
        (rand."0.7.2"."nightly" or false); }
      { "0.7.2"."std" =
        (f.rand."0.7.2"."std" or false) ||
        (f.rand."0.7.2".default or false) ||
        (rand."0.7.2"."default" or false); }
      { "0.7.2".default = (f.rand."0.7.2".default or true); }
    ];
    rand_chacha."${deps.rand."0.7.2".rand_chacha}".default = (f.rand_chacha."${deps.rand."0.7.2".rand_chacha}".default or false);
    rand_core = fold recursiveUpdate {} [
      { "${deps.rand."0.7.2".rand_core}"."alloc" =
        (f.rand_core."${deps.rand."0.7.2".rand_core}"."alloc" or false) ||
        (rand."0.7.2"."alloc" or false) ||
        (f."rand"."0.7.2"."alloc" or false); }
      { "${deps.rand."0.7.2".rand_core}"."getrandom" =
        (f.rand_core."${deps.rand."0.7.2".rand_core}"."getrandom" or false) ||
        (rand."0.7.2"."getrandom" or false) ||
        (f."rand"."0.7.2"."getrandom" or false); }
      { "${deps.rand."0.7.2".rand_core}"."std" =
        (f.rand_core."${deps.rand."0.7.2".rand_core}"."std" or false) ||
        (rand."0.7.2"."std" or false) ||
        (f."rand"."0.7.2"."std" or false); }
      { "${deps.rand."0.7.2".rand_core}".default = true; }
    ];
    rand_hc."${deps.rand."0.7.2".rand_hc}".default = true;
  }) [
    (features_.rand_core."${deps."rand"."0.7.2"."rand_core"}" deps)
    (features_.rand_chacha."${deps."rand"."0.7.2"."rand_chacha"}" deps)
    (features_.rand_hc."${deps."rand"."0.7.2"."rand_hc"}" deps)
    (features_.libc."${deps."rand"."0.7.2"."libc"}" deps)
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
# rand_chacha-0.2.1

  crates.rand_chacha."0.2.1" = deps: { features?(features_.rand_chacha."0.2.1" deps {}) }: buildRustCrate {
    crateName = "rand_chacha";
    version = "0.2.1";
    description = "ChaCha random number generator\n";
    authors = [ "The Rand Project Developers" "The Rust Project Developers" "The CryptoCorrosion Contributors" ];
    edition = "2018";
    sha256 = "0zpp3wmxhhmripb6bywhzhx5rfwl4dfbny85hpalwdj0sncv0p0k";
    dependencies = mapFeatures features ([
      (crates."c2_chacha"."${deps."rand_chacha"."0.2.1"."c2_chacha"}" deps)
      (crates."rand_core"."${deps."rand_chacha"."0.2.1"."rand_core"}" deps)
    ]);
    features = mkFeatures (features."rand_chacha"."0.2.1" or {});
  };
  features_.rand_chacha."0.2.1" = deps: f: updateFeatures f (rec {
    c2_chacha = fold recursiveUpdate {} [
      { "${deps.rand_chacha."0.2.1".c2_chacha}"."simd" = true; }
      { "${deps.rand_chacha."0.2.1".c2_chacha}"."std" =
        (f.c2_chacha."${deps.rand_chacha."0.2.1".c2_chacha}"."std" or false) ||
        (rand_chacha."0.2.1"."std" or false) ||
        (f."rand_chacha"."0.2.1"."std" or false); }
      { "${deps.rand_chacha."0.2.1".c2_chacha}".default = (f.c2_chacha."${deps.rand_chacha."0.2.1".c2_chacha}".default or false); }
    ];
    rand_chacha = fold recursiveUpdate {} [
      { "0.2.1"."simd" =
        (f.rand_chacha."0.2.1"."simd" or false) ||
        (f.rand_chacha."0.2.1".default or false) ||
        (rand_chacha."0.2.1"."default" or false); }
      { "0.2.1"."std" =
        (f.rand_chacha."0.2.1"."std" or false) ||
        (f.rand_chacha."0.2.1".default or false) ||
        (rand_chacha."0.2.1"."default" or false); }
      { "0.2.1".default = (f.rand_chacha."0.2.1".default or true); }
    ];
    rand_core."${deps.rand_chacha."0.2.1".rand_core}".default = true;
  }) [
    (features_.c2_chacha."${deps."rand_chacha"."0.2.1"."c2_chacha"}" deps)
    (features_.rand_core."${deps."rand_chacha"."0.2.1"."rand_core"}" deps)
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
# rand_core-0.4.2

  crates.rand_core."0.4.2" = deps: { features?(features_.rand_core."0.4.2" deps {}) }: buildRustCrate {
    crateName = "rand_core";
    version = "0.4.2";
    description = "Core random number generator traits and tools for implementation.\n";
    authors = [ "The Rand Project Developers" "The Rust Project Developers" ];
    sha256 = "18zpzwn4bl7lp9f36iacy8mvdnfrhfmzsl35gmln98dcindff2ly";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."rand_core"."0.4.2" or {});
  };
  features_.rand_core."0.4.2" = deps: f: updateFeatures f (rec {
    rand_core = fold recursiveUpdate {} [
      { "0.4.2"."alloc" =
        (f.rand_core."0.4.2"."alloc" or false) ||
        (f.rand_core."0.4.2".std or false) ||
        (rand_core."0.4.2"."std" or false); }
      { "0.4.2"."serde" =
        (f.rand_core."0.4.2"."serde" or false) ||
        (f.rand_core."0.4.2".serde1 or false) ||
        (rand_core."0.4.2"."serde1" or false); }
      { "0.4.2"."serde_derive" =
        (f.rand_core."0.4.2"."serde_derive" or false) ||
        (f.rand_core."0.4.2".serde1 or false) ||
        (rand_core."0.4.2"."serde1" or false); }
      { "0.4.2".default = (f.rand_core."0.4.2".default or true); }
    ];
  }) [];


# end
# rand_core-0.5.1

  crates.rand_core."0.5.1" = deps: { features?(features_.rand_core."0.5.1" deps {}) }: buildRustCrate {
    crateName = "rand_core";
    version = "0.5.1";
    description = "Core random number generator traits and tools for implementation.\n";
    authors = [ "The Rand Project Developers" "The Rust Project Developers" ];
    edition = "2018";
    sha256 = "19qfnh77bzz0x2gfsk91h0gygy0z1s5l3yyc2j91gmprq60d6s3r";
    dependencies = mapFeatures features ([
    ]
      ++ (if features.rand_core."0.5.1".getrandom or false then [ (crates.getrandom."${deps."rand_core"."0.5.1".getrandom}" deps) ] else []));
    features = mkFeatures (features."rand_core"."0.5.1" or {});
  };
  features_.rand_core."0.5.1" = deps: f: updateFeatures f (rec {
    getrandom = fold recursiveUpdate {} [
      { "${deps.rand_core."0.5.1".getrandom}"."std" =
        (f.getrandom."${deps.rand_core."0.5.1".getrandom}"."std" or false) ||
        (rand_core."0.5.1"."std" or false) ||
        (f."rand_core"."0.5.1"."std" or false); }
      { "${deps.rand_core."0.5.1".getrandom}".default = true; }
    ];
    rand_core = fold recursiveUpdate {} [
      { "0.5.1"."alloc" =
        (f.rand_core."0.5.1"."alloc" or false) ||
        (f.rand_core."0.5.1".std or false) ||
        (rand_core."0.5.1"."std" or false); }
      { "0.5.1"."getrandom" =
        (f.rand_core."0.5.1"."getrandom" or false) ||
        (f.rand_core."0.5.1".std or false) ||
        (rand_core."0.5.1"."std" or false); }
      { "0.5.1"."serde" =
        (f.rand_core."0.5.1"."serde" or false) ||
        (f.rand_core."0.5.1".serde1 or false) ||
        (rand_core."0.5.1"."serde1" or false); }
      { "0.5.1".default = (f.rand_core."0.5.1".default or true); }
    ];
  }) [
    (features_.getrandom."${deps."rand_core"."0.5.1"."getrandom"}" deps)
  ];


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
# rand_hc-0.2.0

  crates.rand_hc."0.2.0" = deps: { features?(features_.rand_hc."0.2.0" deps {}) }: buildRustCrate {
    crateName = "rand_hc";
    version = "0.2.0";
    description = "HC128 random number generator\n";
    authors = [ "The Rand Project Developers" ];
    edition = "2018";
    sha256 = "0592q9kqcna9aiyzy6vp3fadxkkbpfkmi2cnkv48zhybr0v2yf01";
    dependencies = mapFeatures features ([
      (crates."rand_core"."${deps."rand_hc"."0.2.0"."rand_core"}" deps)
    ]);
  };
  features_.rand_hc."0.2.0" = deps: f: updateFeatures f (rec {
    rand_core."${deps.rand_hc."0.2.0".rand_core}".default = true;
    rand_hc."0.2.0".default = (f.rand_hc."0.2.0".default or true);
  }) [
    (features_.rand_core."${deps."rand_hc"."0.2.0"."rand_core"}" deps)
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
# rand_jitter-0.1.4

  crates.rand_jitter."0.1.4" = deps: { features?(features_.rand_jitter."0.1.4" deps {}) }: buildRustCrate {
    crateName = "rand_jitter";
    version = "0.1.4";
    description = "Random number generator based on timing jitter";
    authors = [ "The Rand Project Developers" ];
    sha256 = "13nr4h042ab9l7qcv47bxrxw3gkf2pc3cni6c9pyi4nxla0mm7b6";
    dependencies = mapFeatures features ([
      (crates."rand_core"."${deps."rand_jitter"."0.1.4"."rand_core"}" deps)
    ])
      ++ (if kernel == "darwin" || kernel == "ios" then mapFeatures features ([
      (crates."libc"."${deps."rand_jitter"."0.1.4"."libc"}" deps)
    ]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."rand_jitter"."0.1.4"."winapi"}" deps)
    ]) else []);
    features = mkFeatures (features."rand_jitter"."0.1.4" or {});
  };
  features_.rand_jitter."0.1.4" = deps: f: updateFeatures f (rec {
    libc."${deps.rand_jitter."0.1.4".libc}".default = true;
    rand_core = fold recursiveUpdate {} [
      { "${deps.rand_jitter."0.1.4".rand_core}"."std" =
        (f.rand_core."${deps.rand_jitter."0.1.4".rand_core}"."std" or false) ||
        (rand_jitter."0.1.4"."std" or false) ||
        (f."rand_jitter"."0.1.4"."std" or false); }
      { "${deps.rand_jitter."0.1.4".rand_core}".default = true; }
    ];
    rand_jitter."0.1.4".default = (f.rand_jitter."0.1.4".default or true);
    winapi = fold recursiveUpdate {} [
      { "${deps.rand_jitter."0.1.4".winapi}"."profileapi" = true; }
      { "${deps.rand_jitter."0.1.4".winapi}".default = true; }
    ];
  }) [
    (features_.rand_core."${deps."rand_jitter"."0.1.4"."rand_core"}" deps)
    (features_.libc."${deps."rand_jitter"."0.1.4"."libc"}" deps)
    (features_.winapi."${deps."rand_jitter"."0.1.4"."winapi"}" deps)
  ];


# end
# rand_os-0.1.3

  crates.rand_os."0.1.3" = deps: { features?(features_.rand_os."0.1.3" deps {}) }: buildRustCrate {
    crateName = "rand_os";
    version = "0.1.3";
    description = "OS backed Random Number Generator";
    authors = [ "The Rand Project Developers" ];
    sha256 = "0ywwspizgs9g8vzn6m5ix9yg36n15119d6n792h7mk4r5vs0ww4j";
    dependencies = mapFeatures features ([
      (crates."rand_core"."${deps."rand_os"."0.1.3"."rand_core"}" deps)
    ])
      ++ (if abi == "sgx" then mapFeatures features ([
      (crates."rdrand"."${deps."rand_os"."0.1.3"."rdrand"}" deps)
    ]) else [])
      ++ (if kernel == "cloudabi" then mapFeatures features ([
      (crates."cloudabi"."${deps."rand_os"."0.1.3"."cloudabi"}" deps)
    ]) else [])
      ++ (if kernel == "fuchsia" then mapFeatures features ([
      (crates."fuchsia_cprng"."${deps."rand_os"."0.1.3"."fuchsia_cprng"}" deps)
    ]) else [])
      ++ (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
      (crates."libc"."${deps."rand_os"."0.1.3"."libc"}" deps)
    ]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."rand_os"."0.1.3"."winapi"}" deps)
    ]) else [])
      ++ (if kernel == "wasm32-unknown-unknown" then mapFeatures features ([
]) else []);
  };
  features_.rand_os."0.1.3" = deps: f: updateFeatures f (rec {
    cloudabi."${deps.rand_os."0.1.3".cloudabi}".default = true;
    fuchsia_cprng."${deps.rand_os."0.1.3".fuchsia_cprng}".default = true;
    libc."${deps.rand_os."0.1.3".libc}".default = true;
    rand_core = fold recursiveUpdate {} [
      { "${deps.rand_os."0.1.3".rand_core}"."std" = true; }
      { "${deps.rand_os."0.1.3".rand_core}".default = true; }
    ];
    rand_os."0.1.3".default = (f.rand_os."0.1.3".default or true);
    rdrand."${deps.rand_os."0.1.3".rdrand}".default = true;
    winapi = fold recursiveUpdate {} [
      { "${deps.rand_os."0.1.3".winapi}"."minwindef" = true; }
      { "${deps.rand_os."0.1.3".winapi}"."ntsecapi" = true; }
      { "${deps.rand_os."0.1.3".winapi}"."winnt" = true; }
      { "${deps.rand_os."0.1.3".winapi}".default = true; }
    ];
  }) [
    (features_.rand_core."${deps."rand_os"."0.1.3"."rand_core"}" deps)
    (features_.rdrand."${deps."rand_os"."0.1.3"."rdrand"}" deps)
    (features_.cloudabi."${deps."rand_os"."0.1.3"."cloudabi"}" deps)
    (features_.fuchsia_cprng."${deps."rand_os"."0.1.3"."fuchsia_cprng"}" deps)
    (features_.libc."${deps."rand_os"."0.1.3"."libc"}" deps)
    (features_.winapi."${deps."rand_os"."0.1.3"."winapi"}" deps)
  ];


# end
# rand_pcg-0.1.2

  crates.rand_pcg."0.1.2" = deps: { features?(features_.rand_pcg."0.1.2" deps {}) }: buildRustCrate {
    crateName = "rand_pcg";
    version = "0.1.2";
    description = "Selected PCG random number generators\n";
    authors = [ "The Rand Project Developers" ];
    sha256 = "04qgi2ai2z42li5h4aawvxbpnlqyjfnipz9d6k73mdnl6p1xq938";
    build = "build.rs";
    dependencies = mapFeatures features ([
      (crates."rand_core"."${deps."rand_pcg"."0.1.2"."rand_core"}" deps)
    ]);

    buildDependencies = mapFeatures features ([
      (crates."autocfg"."${deps."rand_pcg"."0.1.2"."autocfg"}" deps)
    ]);
    features = mkFeatures (features."rand_pcg"."0.1.2" or {});
  };
  features_.rand_pcg."0.1.2" = deps: f: updateFeatures f (rec {
    autocfg."${deps.rand_pcg."0.1.2".autocfg}".default = true;
    rand_core."${deps.rand_pcg."0.1.2".rand_core}".default = true;
    rand_pcg = fold recursiveUpdate {} [
      { "0.1.2"."serde" =
        (f.rand_pcg."0.1.2"."serde" or false) ||
        (f.rand_pcg."0.1.2".serde1 or false) ||
        (rand_pcg."0.1.2"."serde1" or false); }
      { "0.1.2"."serde_derive" =
        (f.rand_pcg."0.1.2"."serde_derive" or false) ||
        (f.rand_pcg."0.1.2".serde1 or false) ||
        (rand_pcg."0.1.2"."serde1" or false); }
      { "0.1.2".default = (f.rand_pcg."0.1.2".default or true); }
    ];
  }) [
    (features_.rand_core."${deps."rand_pcg"."0.1.2"."rand_core"}" deps)
    (features_.autocfg."${deps."rand_pcg"."0.1.2"."autocfg"}" deps)
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
# redox_syscall-0.1.56

  crates.redox_syscall."0.1.56" = deps: { features?(features_.redox_syscall."0.1.56" deps {}) }: buildRustCrate {
    crateName = "redox_syscall";
    version = "0.1.56";
    description = "A Rust library to access raw Redox system calls";
    authors = [ "Jeremy Soller <jackpot51@gmail.com>" ];
    sha256 = "0jcp8nd947zcy938bz09pzlmi3vyxfdzg92pjxdvvk0699vwcc26";
    libName = "syscall";
  };
  features_.redox_syscall."0.1.56" = deps: f: updateFeatures f (rec {
    redox_syscall."0.1.56".default = (f.redox_syscall."0.1.56".default or true);
  }) [];


# end
# redox_users-0.3.1

  crates.redox_users."0.3.1" = deps: { features?(features_.redox_users."0.3.1" deps {}) }: buildRustCrate {
    crateName = "redox_users";
    version = "0.3.1";
    description = "A Rust library to access Redox users and groups functionality";
    authors = [ "Jose Narvaez <goyox86@gmail.com>" "Wesley Hershberger <mggmugginsmc@gmail.com>" ];
    sha256 = "0kqc1vjmkcvgkxjpqva3nyqd9dixivsh4qswxclyqf7ql8a2g17s";
    dependencies = mapFeatures features ([
      (crates."failure"."${deps."redox_users"."0.3.1"."failure"}" deps)
      (crates."rand_os"."${deps."redox_users"."0.3.1"."rand_os"}" deps)
      (crates."redox_syscall"."${deps."redox_users"."0.3.1"."redox_syscall"}" deps)
      (crates."rust_argon2"."${deps."redox_users"."0.3.1"."rust_argon2"}" deps)
    ]);
  };
  features_.redox_users."0.3.1" = deps: f: updateFeatures f (rec {
    failure."${deps.redox_users."0.3.1".failure}".default = true;
    rand_os."${deps.redox_users."0.3.1".rand_os}".default = true;
    redox_syscall."${deps.redox_users."0.3.1".redox_syscall}".default = true;
    redox_users."0.3.1".default = (f.redox_users."0.3.1".default or true);
    rust_argon2."${deps.redox_users."0.3.1".rust_argon2}".default = true;
  }) [
    (features_.failure."${deps."redox_users"."0.3.1"."failure"}" deps)
    (features_.rand_os."${deps."redox_users"."0.3.1"."rand_os"}" deps)
    (features_.redox_syscall."${deps."redox_users"."0.3.1"."redox_syscall"}" deps)
    (features_.rust_argon2."${deps."redox_users"."0.3.1"."rust_argon2"}" deps)
  ];


# end
# regex-1.3.1

  crates.regex."1.3.1" = deps: { features?(features_.regex."1.3.1" deps {}) }: buildRustCrate {
    crateName = "regex";
    version = "1.3.1";
    description = "An implementation of regular expressions for Rust. This implementation uses\nfinite automata and guarantees linear time matching on all inputs.\n";
    authors = [ "The Rust Project Developers" ];
    sha256 = "0508b01q7iwky5gzp1cc3lpz6al1qam8skgcvkfgxr67nikiz7jn";
    dependencies = mapFeatures features ([
      (crates."regex_syntax"."${deps."regex"."1.3.1"."regex_syntax"}" deps)
    ]
      ++ (if features.regex."1.3.1".aho-corasick or false then [ (crates.aho_corasick."${deps."regex"."1.3.1".aho_corasick}" deps) ] else [])
      ++ (if features.regex."1.3.1".memchr or false then [ (crates.memchr."${deps."regex"."1.3.1".memchr}" deps) ] else [])
      ++ (if features.regex."1.3.1".thread_local or false then [ (crates.thread_local."${deps."regex"."1.3.1".thread_local}" deps) ] else []));
    features = mkFeatures (features."regex"."1.3.1" or {});
  };
  features_.regex."1.3.1" = deps: f: updateFeatures f (rec {
    aho_corasick."${deps.regex."1.3.1".aho_corasick}".default = true;
    memchr."${deps.regex."1.3.1".memchr}".default = true;
    regex = fold recursiveUpdate {} [
      { "1.3.1"."aho-corasick" =
        (f.regex."1.3.1"."aho-corasick" or false) ||
        (f.regex."1.3.1".perf-literal or false) ||
        (regex."1.3.1"."perf-literal" or false); }
      { "1.3.1"."memchr" =
        (f.regex."1.3.1"."memchr" or false) ||
        (f.regex."1.3.1".perf-literal or false) ||
        (regex."1.3.1"."perf-literal" or false); }
      { "1.3.1"."pattern" =
        (f.regex."1.3.1"."pattern" or false) ||
        (f.regex."1.3.1".unstable or false) ||
        (regex."1.3.1"."unstable" or false); }
      { "1.3.1"."perf" =
        (f.regex."1.3.1"."perf" or false) ||
        (f.regex."1.3.1".default or false) ||
        (regex."1.3.1"."default" or false); }
      { "1.3.1"."perf-cache" =
        (f.regex."1.3.1"."perf-cache" or false) ||
        (f.regex."1.3.1".perf or false) ||
        (regex."1.3.1"."perf" or false); }
      { "1.3.1"."perf-dfa" =
        (f.regex."1.3.1"."perf-dfa" or false) ||
        (f.regex."1.3.1".perf or false) ||
        (regex."1.3.1"."perf" or false); }
      { "1.3.1"."perf-inline" =
        (f.regex."1.3.1"."perf-inline" or false) ||
        (f.regex."1.3.1".perf or false) ||
        (regex."1.3.1"."perf" or false); }
      { "1.3.1"."perf-literal" =
        (f.regex."1.3.1"."perf-literal" or false) ||
        (f.regex."1.3.1".perf or false) ||
        (regex."1.3.1"."perf" or false); }
      { "1.3.1"."std" =
        (f.regex."1.3.1"."std" or false) ||
        (f.regex."1.3.1".default or false) ||
        (regex."1.3.1"."default" or false) ||
        (f.regex."1.3.1".use_std or false) ||
        (regex."1.3.1"."use_std" or false); }
      { "1.3.1"."thread_local" =
        (f.regex."1.3.1"."thread_local" or false) ||
        (f.regex."1.3.1".perf-cache or false) ||
        (regex."1.3.1"."perf-cache" or false); }
      { "1.3.1"."unicode" =
        (f.regex."1.3.1"."unicode" or false) ||
        (f.regex."1.3.1".default or false) ||
        (regex."1.3.1"."default" or false); }
      { "1.3.1"."unicode-age" =
        (f.regex."1.3.1"."unicode-age" or false) ||
        (f.regex."1.3.1".unicode or false) ||
        (regex."1.3.1"."unicode" or false); }
      { "1.3.1"."unicode-bool" =
        (f.regex."1.3.1"."unicode-bool" or false) ||
        (f.regex."1.3.1".unicode or false) ||
        (regex."1.3.1"."unicode" or false); }
      { "1.3.1"."unicode-case" =
        (f.regex."1.3.1"."unicode-case" or false) ||
        (f.regex."1.3.1".unicode or false) ||
        (regex."1.3.1"."unicode" or false); }
      { "1.3.1"."unicode-gencat" =
        (f.regex."1.3.1"."unicode-gencat" or false) ||
        (f.regex."1.3.1".unicode or false) ||
        (regex."1.3.1"."unicode" or false); }
      { "1.3.1"."unicode-perl" =
        (f.regex."1.3.1"."unicode-perl" or false) ||
        (f.regex."1.3.1".unicode or false) ||
        (regex."1.3.1"."unicode" or false); }
      { "1.3.1"."unicode-script" =
        (f.regex."1.3.1"."unicode-script" or false) ||
        (f.regex."1.3.1".unicode or false) ||
        (regex."1.3.1"."unicode" or false); }
      { "1.3.1"."unicode-segment" =
        (f.regex."1.3.1"."unicode-segment" or false) ||
        (f.regex."1.3.1".unicode or false) ||
        (regex."1.3.1"."unicode" or false); }
      { "1.3.1".default = (f.regex."1.3.1".default or true); }
    ];
    regex_syntax = fold recursiveUpdate {} [
      { "${deps.regex."1.3.1".regex_syntax}"."unicode-age" =
        (f.regex_syntax."${deps.regex."1.3.1".regex_syntax}"."unicode-age" or false) ||
        (regex."1.3.1"."unicode-age" or false) ||
        (f."regex"."1.3.1"."unicode-age" or false); }
      { "${deps.regex."1.3.1".regex_syntax}"."unicode-bool" =
        (f.regex_syntax."${deps.regex."1.3.1".regex_syntax}"."unicode-bool" or false) ||
        (regex."1.3.1"."unicode-bool" or false) ||
        (f."regex"."1.3.1"."unicode-bool" or false); }
      { "${deps.regex."1.3.1".regex_syntax}"."unicode-case" =
        (f.regex_syntax."${deps.regex."1.3.1".regex_syntax}"."unicode-case" or false) ||
        (regex."1.3.1"."unicode-case" or false) ||
        (f."regex"."1.3.1"."unicode-case" or false); }
      { "${deps.regex."1.3.1".regex_syntax}"."unicode-gencat" =
        (f.regex_syntax."${deps.regex."1.3.1".regex_syntax}"."unicode-gencat" or false) ||
        (regex."1.3.1"."unicode-gencat" or false) ||
        (f."regex"."1.3.1"."unicode-gencat" or false); }
      { "${deps.regex."1.3.1".regex_syntax}"."unicode-perl" =
        (f.regex_syntax."${deps.regex."1.3.1".regex_syntax}"."unicode-perl" or false) ||
        (regex."1.3.1"."unicode-perl" or false) ||
        (f."regex"."1.3.1"."unicode-perl" or false); }
      { "${deps.regex."1.3.1".regex_syntax}"."unicode-script" =
        (f.regex_syntax."${deps.regex."1.3.1".regex_syntax}"."unicode-script" or false) ||
        (regex."1.3.1"."unicode-script" or false) ||
        (f."regex"."1.3.1"."unicode-script" or false); }
      { "${deps.regex."1.3.1".regex_syntax}"."unicode-segment" =
        (f.regex_syntax."${deps.regex."1.3.1".regex_syntax}"."unicode-segment" or false) ||
        (regex."1.3.1"."unicode-segment" or false) ||
        (f."regex"."1.3.1"."unicode-segment" or false); }
      { "${deps.regex."1.3.1".regex_syntax}".default = (f.regex_syntax."${deps.regex."1.3.1".regex_syntax}".default or false); }
    ];
    thread_local."${deps.regex."1.3.1".thread_local}".default = true;
  }) [
    (features_.aho_corasick."${deps."regex"."1.3.1"."aho_corasick"}" deps)
    (features_.memchr."${deps."regex"."1.3.1"."memchr"}" deps)
    (features_.regex_syntax."${deps."regex"."1.3.1"."regex_syntax"}" deps)
    (features_.thread_local."${deps."regex"."1.3.1"."thread_local"}" deps)
  ];


# end
# regex-syntax-0.6.12

  crates.regex_syntax."0.6.12" = deps: { features?(features_.regex_syntax."0.6.12" deps {}) }: buildRustCrate {
    crateName = "regex-syntax";
    version = "0.6.12";
    description = "A regular expression parser.";
    authors = [ "The Rust Project Developers" ];
    sha256 = "1lqhddhwzpgq8zfkxhm241n7g4m3yc11fb4098dkgawbxvybr53v";
    features = mkFeatures (features."regex_syntax"."0.6.12" or {});
  };
  features_.regex_syntax."0.6.12" = deps: f: updateFeatures f (rec {
    regex_syntax = fold recursiveUpdate {} [
      { "0.6.12"."unicode" =
        (f.regex_syntax."0.6.12"."unicode" or false) ||
        (f.regex_syntax."0.6.12".default or false) ||
        (regex_syntax."0.6.12"."default" or false); }
      { "0.6.12"."unicode-age" =
        (f.regex_syntax."0.6.12"."unicode-age" or false) ||
        (f.regex_syntax."0.6.12".unicode or false) ||
        (regex_syntax."0.6.12"."unicode" or false); }
      { "0.6.12"."unicode-bool" =
        (f.regex_syntax."0.6.12"."unicode-bool" or false) ||
        (f.regex_syntax."0.6.12".unicode or false) ||
        (regex_syntax."0.6.12"."unicode" or false); }
      { "0.6.12"."unicode-case" =
        (f.regex_syntax."0.6.12"."unicode-case" or false) ||
        (f.regex_syntax."0.6.12".unicode or false) ||
        (regex_syntax."0.6.12"."unicode" or false); }
      { "0.6.12"."unicode-gencat" =
        (f.regex_syntax."0.6.12"."unicode-gencat" or false) ||
        (f.regex_syntax."0.6.12".unicode or false) ||
        (regex_syntax."0.6.12"."unicode" or false); }
      { "0.6.12"."unicode-perl" =
        (f.regex_syntax."0.6.12"."unicode-perl" or false) ||
        (f.regex_syntax."0.6.12".unicode or false) ||
        (regex_syntax."0.6.12"."unicode" or false); }
      { "0.6.12"."unicode-script" =
        (f.regex_syntax."0.6.12"."unicode-script" or false) ||
        (f.regex_syntax."0.6.12".unicode or false) ||
        (regex_syntax."0.6.12"."unicode" or false); }
      { "0.6.12"."unicode-segment" =
        (f.regex_syntax."0.6.12"."unicode-segment" or false) ||
        (f.regex_syntax."0.6.12".unicode or false) ||
        (regex_syntax."0.6.12"."unicode" or false); }
      { "0.6.12".default = (f.regex_syntax."0.6.12".default or true); }
    ];
  }) [];


# end
# remove_dir_all-0.5.2

  crates.remove_dir_all."0.5.2" = deps: { features?(features_.remove_dir_all."0.5.2" deps {}) }: buildRustCrate {
    crateName = "remove_dir_all";
    version = "0.5.2";
    description = "A safe, reliable implementation of remove_dir_all for Windows";
    authors = [ "Aaronepower <theaaronepower@gmail.com>" ];
    sha256 = "04sxg2ppvxiljc2i13bwvpbi540rf9d2a89cq0wmqf9pjvr3a1wm";
    dependencies = (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."remove_dir_all"."0.5.2"."winapi"}" deps)
    ]) else []);
  };
  features_.remove_dir_all."0.5.2" = deps: f: updateFeatures f (rec {
    remove_dir_all."0.5.2".default = (f.remove_dir_all."0.5.2".default or true);
    winapi = fold recursiveUpdate {} [
      { "${deps.remove_dir_all."0.5.2".winapi}"."errhandlingapi" = true; }
      { "${deps.remove_dir_all."0.5.2".winapi}"."fileapi" = true; }
      { "${deps.remove_dir_all."0.5.2".winapi}"."std" = true; }
      { "${deps.remove_dir_all."0.5.2".winapi}"."winbase" = true; }
      { "${deps.remove_dir_all."0.5.2".winapi}"."winerror" = true; }
      { "${deps.remove_dir_all."0.5.2".winapi}".default = true; }
    ];
  }) [
    (features_.winapi."${deps."remove_dir_all"."0.5.2"."winapi"}" deps)
  ];


# end
# rust-argon2-0.5.1

  crates.rust_argon2."0.5.1" = deps: { features?(features_.rust_argon2."0.5.1" deps {}) }: buildRustCrate {
    crateName = "rust-argon2";
    version = "0.5.1";
    description = "Rust implementation of the Argon2 password hashing function.";
    authors = [ "Martijn Rijkeboer <mrr@sru-systems.com>" ];
    sha256 = "049dqwn63i6xix55cnh8n4iqm2d3yzpisfsc2568vfmaaa4866d2";
    libName = "argon2";
    dependencies = mapFeatures features ([
      (crates."base64"."${deps."rust_argon2"."0.5.1"."base64"}" deps)
      (crates."blake2b_simd"."${deps."rust_argon2"."0.5.1"."blake2b_simd"}" deps)
      (crates."crossbeam_utils"."${deps."rust_argon2"."0.5.1"."crossbeam_utils"}" deps)
    ]);
  };
  features_.rust_argon2."0.5.1" = deps: f: updateFeatures f (rec {
    base64."${deps.rust_argon2."0.5.1".base64}".default = true;
    blake2b_simd."${deps.rust_argon2."0.5.1".blake2b_simd}".default = true;
    crossbeam_utils."${deps.rust_argon2."0.5.1".crossbeam_utils}".default = true;
    rust_argon2."0.5.1".default = (f.rust_argon2."0.5.1".default or true);
  }) [
    (features_.base64."${deps."rust_argon2"."0.5.1"."base64"}" deps)
    (features_.blake2b_simd."${deps."rust_argon2"."0.5.1"."blake2b_simd"}" deps)
    (features_.crossbeam_utils."${deps."rust_argon2"."0.5.1"."crossbeam_utils"}" deps)
  ];


# end
# rustc-demangle-0.1.16

  crates.rustc_demangle."0.1.16" = deps: { features?(features_.rustc_demangle."0.1.16" deps {}) }: buildRustCrate {
    crateName = "rustc-demangle";
    version = "0.1.16";
    description = "Rust compiler symbol demangling.\n";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    sha256 = "0zmn448d0f898ahfkz7cir0fi0vk84dabjpw84mk6a1r6nf9vzmi";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."rustc_demangle"."0.1.16" or {});
  };
  features_.rustc_demangle."0.1.16" = deps: f: updateFeatures f (rec {
    rustc_demangle = fold recursiveUpdate {} [
      { "0.1.16"."compiler_builtins" =
        (f.rustc_demangle."0.1.16"."compiler_builtins" or false) ||
        (f.rustc_demangle."0.1.16".rustc-dep-of-std or false) ||
        (rustc_demangle."0.1.16"."rustc-dep-of-std" or false); }
      { "0.1.16"."core" =
        (f.rustc_demangle."0.1.16"."core" or false) ||
        (f.rustc_demangle."0.1.16".rustc-dep-of-std or false) ||
        (rustc_demangle."0.1.16"."rustc-dep-of-std" or false); }
      { "0.1.16".default = (f.rustc_demangle."0.1.16".default or true); }
    ];
  }) [];


# end
# rusty-fork-0.2.2

  crates.rusty_fork."0.2.2" = deps: { features?(features_.rusty_fork."0.2.2" deps {}) }: buildRustCrate {
    crateName = "rusty-fork";
    version = "0.2.2";
    description = "Cross-platform library for running Rust tests in sub-processes using a\nfork-like interface.\n";
    authors = [ "Jason Lingle" ];
    sha256 = "1qjnfbk0b267mib86p9rvj42xcxv1wady290iblpfnlsyn3achsa";
    dependencies = mapFeatures features ([
      (crates."fnv"."${deps."rusty_fork"."0.2.2"."fnv"}" deps)
      (crates."quick_error"."${deps."rusty_fork"."0.2.2"."quick_error"}" deps)
      (crates."tempfile"."${deps."rusty_fork"."0.2.2"."tempfile"}" deps)
    ]
      ++ (if features.rusty_fork."0.2.2".wait-timeout or false then [ (crates.wait_timeout."${deps."rusty_fork"."0.2.2".wait_timeout}" deps) ] else []));
    features = mkFeatures (features."rusty_fork"."0.2.2" or {});
  };
  features_.rusty_fork."0.2.2" = deps: f: updateFeatures f (rec {
    fnv."${deps.rusty_fork."0.2.2".fnv}".default = true;
    quick_error."${deps.rusty_fork."0.2.2".quick_error}".default = true;
    rusty_fork = fold recursiveUpdate {} [
      { "0.2.2"."timeout" =
        (f.rusty_fork."0.2.2"."timeout" or false) ||
        (f.rusty_fork."0.2.2".default or false) ||
        (rusty_fork."0.2.2"."default" or false); }
      { "0.2.2"."wait-timeout" =
        (f.rusty_fork."0.2.2"."wait-timeout" or false) ||
        (f.rusty_fork."0.2.2".timeout or false) ||
        (rusty_fork."0.2.2"."timeout" or false); }
      { "0.2.2".default = (f.rusty_fork."0.2.2".default or true); }
    ];
    tempfile."${deps.rusty_fork."0.2.2".tempfile}".default = true;
    wait_timeout."${deps.rusty_fork."0.2.2".wait_timeout}".default = true;
  }) [
    (features_.fnv."${deps."rusty_fork"."0.2.2"."fnv"}" deps)
    (features_.quick_error."${deps."rusty_fork"."0.2.2"."quick_error"}" deps)
    (features_.tempfile."${deps."rusty_fork"."0.2.2"."tempfile"}" deps)
    (features_.wait_timeout."${deps."rusty_fork"."0.2.2"."wait_timeout"}" deps)
  ];


# end
# ryu-1.0.2

  crates.ryu."1.0.2" = deps: { features?(features_.ryu."1.0.2" deps {}) }: buildRustCrate {
    crateName = "ryu";
    version = "1.0.2";
    description = "Fast floating point to string conversion";
    authors = [ "David Tolnay <dtolnay@gmail.com>" ];
    sha256 = "04pxfhps9ix078qyml7hifjdmy4bg1n047ki0wx6i1007z85wjp1";
    build = "build.rs";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."ryu"."1.0.2" or {});
  };
  features_.ryu."1.0.2" = deps: f: updateFeatures f (rec {
    ryu."1.0.2".default = (f.ryu."1.0.2".default or true);
  }) [];


# end
# same-file-1.0.5

  crates.same_file."1.0.5" = deps: { features?(features_.same_file."1.0.5" deps {}) }: buildRustCrate {
    crateName = "same-file";
    version = "1.0.5";
    description = "A simple crate for determining whether two file paths point to the same file.\n";
    authors = [ "Andrew Gallant <jamslam@gmail.com>" ];
    sha256 = "0vn7bc069wsdick0nk0n2j3wvgq2vzb5ix957c35nkhkwlszv4l5";
    dependencies = (if kernel == "windows" then mapFeatures features ([
      (crates."winapi_util"."${deps."same_file"."1.0.5"."winapi_util"}" deps)
    ]) else []);
  };
  features_.same_file."1.0.5" = deps: f: updateFeatures f (rec {
    same_file."1.0.5".default = (f.same_file."1.0.5".default or true);
    winapi_util."${deps.same_file."1.0.5".winapi_util}".default = true;
  }) [
    (features_.winapi_util."${deps."same_file"."1.0.5"."winapi_util"}" deps)
  ];


# end
# serde-1.0.103

  crates.serde."1.0.103" = deps: { features?(features_.serde."1.0.103" deps {}) }: buildRustCrate {
    crateName = "serde";
    version = "1.0.103";
    description = "A generic serialization/deserialization framework";
    authors = [ "Erick Tryzelaar <erick.tryzelaar@gmail.com>" "David Tolnay <dtolnay@gmail.com>" ];
    sha256 = "1z1r845r12h0kgp6f42ngz3nvxarmnif2l2vy2ln7m8nyx2yddw5";
    build = "build.rs";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."serde"."1.0.103" or {});
  };
  features_.serde."1.0.103" = deps: f: updateFeatures f (rec {
    serde = fold recursiveUpdate {} [
      { "1.0.103"."serde_derive" =
        (f.serde."1.0.103"."serde_derive" or false) ||
        (f.serde."1.0.103".derive or false) ||
        (serde."1.0.103"."derive" or false); }
      { "1.0.103"."std" =
        (f.serde."1.0.103"."std" or false) ||
        (f.serde."1.0.103".default or false) ||
        (serde."1.0.103"."default" or false); }
      { "1.0.103".default = (f.serde."1.0.103".default or true); }
    ];
  }) [];


# end
# serde_derive-1.0.103

  crates.serde_derive."1.0.103" = deps: { features?(features_.serde_derive."1.0.103" deps {}) }: buildRustCrate {
    crateName = "serde_derive";
    version = "1.0.103";
    description = "Macros 1.1 implementation of #[derive(Serialize, Deserialize)]";
    authors = [ "Erick Tryzelaar <erick.tryzelaar@gmail.com>" "David Tolnay <dtolnay@gmail.com>" ];
    sha256 = "1idz7r4b5zsjrx1gvmnmknbxxljwj6g9pd9pb37z298xi2sw97ia";
    procMacro = true;
    dependencies = mapFeatures features ([
      (crates."proc_macro2"."${deps."serde_derive"."1.0.103"."proc_macro2"}" deps)
      (crates."quote"."${deps."serde_derive"."1.0.103"."quote"}" deps)
      (crates."syn"."${deps."serde_derive"."1.0.103"."syn"}" deps)
    ]);
    features = mkFeatures (features."serde_derive"."1.0.103" or {});
  };
  features_.serde_derive."1.0.103" = deps: f: updateFeatures f (rec {
    proc_macro2."${deps.serde_derive."1.0.103".proc_macro2}".default = true;
    quote."${deps.serde_derive."1.0.103".quote}".default = true;
    serde_derive."1.0.103".default = (f.serde_derive."1.0.103".default or true);
    syn = fold recursiveUpdate {} [
      { "${deps.serde_derive."1.0.103".syn}"."visit" = true; }
      { "${deps.serde_derive."1.0.103".syn}".default = true; }
    ];
  }) [
    (features_.proc_macro2."${deps."serde_derive"."1.0.103"."proc_macro2"}" deps)
    (features_.quote."${deps."serde_derive"."1.0.103"."quote"}" deps)
    (features_.syn."${deps."serde_derive"."1.0.103"."syn"}" deps)
  ];


# end
# serde_json-1.0.42

  crates.serde_json."1.0.42" = deps: { features?(features_.serde_json."1.0.42" deps {}) }: buildRustCrate {
    crateName = "serde_json";
    version = "1.0.42";
    description = "A JSON serialization file format";
    authors = [ "Erick Tryzelaar <erick.tryzelaar@gmail.com>" "David Tolnay <dtolnay@gmail.com>" ];
    sha256 = "0vqczxlz40l64ssanj46wkgpkm5q1ilcj8jhmmlhx666kc0vm96m";
    dependencies = mapFeatures features ([
      (crates."itoa"."${deps."serde_json"."1.0.42"."itoa"}" deps)
      (crates."ryu"."${deps."serde_json"."1.0.42"."ryu"}" deps)
      (crates."serde"."${deps."serde_json"."1.0.42"."serde"}" deps)
    ]);
    features = mkFeatures (features."serde_json"."1.0.42" or {});
  };
  features_.serde_json."1.0.42" = deps: f: updateFeatures f (rec {
    itoa."${deps.serde_json."1.0.42".itoa}".default = true;
    ryu."${deps.serde_json."1.0.42".ryu}".default = true;
    serde."${deps.serde_json."1.0.42".serde}".default = true;
    serde_json = fold recursiveUpdate {} [
      { "1.0.42"."indexmap" =
        (f.serde_json."1.0.42"."indexmap" or false) ||
        (f.serde_json."1.0.42".preserve_order or false) ||
        (serde_json."1.0.42"."preserve_order" or false); }
      { "1.0.42".default = (f.serde_json."1.0.42".default or true); }
    ];
  }) [
    (features_.itoa."${deps."serde_json"."1.0.42"."itoa"}" deps)
    (features_.ryu."${deps."serde_json"."1.0.42"."ryu"}" deps)
    (features_.serde."${deps."serde_json"."1.0.42"."serde"}" deps)
  ];


# end
# signal-hook-registry-1.2.0

  crates.signal_hook_registry."1.2.0" = deps: { features?(features_.signal_hook_registry."1.2.0" deps {}) }: buildRustCrate {
    crateName = "signal-hook-registry";
    version = "1.2.0";
    description = "Backend crate for signal-hook";
    authors = [ "Michal 'vorner' Vaner <vorner@vorner.cz>" "Masaki Hara <ackie.h.gmai@gmail.com>" ];
    sha256 = "0sap7brbb8fp3641nrvfm4rk024hjcmxix0y0zn9sc8vgvnfivxb";
    dependencies = mapFeatures features ([
      (crates."arc_swap"."${deps."signal_hook_registry"."1.2.0"."arc_swap"}" deps)
      (crates."libc"."${deps."signal_hook_registry"."1.2.0"."libc"}" deps)
    ]);
  };
  features_.signal_hook_registry."1.2.0" = deps: f: updateFeatures f (rec {
    arc_swap."${deps.signal_hook_registry."1.2.0".arc_swap}".default = true;
    libc."${deps.signal_hook_registry."1.2.0".libc}".default = true;
    signal_hook_registry."1.2.0".default = (f.signal_hook_registry."1.2.0".default or true);
  }) [
    (features_.arc_swap."${deps."signal_hook_registry"."1.2.0"."arc_swap"}" deps)
    (features_.libc."${deps."signal_hook_registry"."1.2.0"."libc"}" deps)
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
# slog-2.5.2

  crates.slog."2.5.2" = deps: { features?(features_.slog."2.5.2" deps {}) }: buildRustCrate {
    crateName = "slog";
    version = "2.5.2";
    description = "Structured, extensible, composable logging for Rust";
    authors = [ "Dawid Ciężarkiewicz <dpc@dpc.pw>" ];
    sha256 = "1mckj3mjmhqhjrs6nkp0zh0jwgppkrq52a5sxh8svd9dqf6j7vl3";
    build = "build.rs";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."slog"."2.5.2" or {});
  };
  features_.slog."2.5.2" = deps: f: updateFeatures f (rec {
    slog = fold recursiveUpdate {} [
      { "2.5.2"."erased-serde" =
        (f.slog."2.5.2"."erased-serde" or false) ||
        (f.slog."2.5.2".nested-values or false) ||
        (slog."2.5.2"."nested-values" or false); }
      { "2.5.2"."std" =
        (f.slog."2.5.2"."std" or false) ||
        (f.slog."2.5.2".default or false) ||
        (slog."2.5.2"."default" or false); }
      { "2.5.2".default = (f.slog."2.5.2".default or true); }
    ];
  }) [];


# end
# slog-async-2.3.0

  crates.slog_async."2.3.0" = deps: { features?(features_.slog_async."2.3.0" deps {}) }: buildRustCrate {
    crateName = "slog-async";
    version = "2.3.0";
    description = "Asynchronous drain for slog-rs";
    authors = [ "Dawid Ciężarkiewicz <dpc@dpc.pw>" ];
    sha256 = "1mifm17723fp8vvv0a1d52g82sq2rpnz9f7xvv81h0rbwm2w01xl";
    libPath = "lib.rs";
    dependencies = mapFeatures features ([
      (crates."slog"."${deps."slog_async"."2.3.0"."slog"}" deps)
      (crates."take_mut"."${deps."slog_async"."2.3.0"."take_mut"}" deps)
      (crates."thread_local"."${deps."slog_async"."2.3.0"."thread_local"}" deps)
    ]);
    features = mkFeatures (features."slog_async"."2.3.0" or {});
  };
  features_.slog_async."2.3.0" = deps: f: updateFeatures f (rec {
    slog = fold recursiveUpdate {} [
      { "${deps.slog_async."2.3.0".slog}"."dynamic-keys" =
        (f.slog."${deps.slog_async."2.3.0".slog}"."dynamic-keys" or false) ||
        (slog_async."2.3.0"."dynamic-keys" or false) ||
        (f."slog_async"."2.3.0"."dynamic-keys" or false); }
      { "${deps.slog_async."2.3.0".slog}"."nested-values" =
        (f.slog."${deps.slog_async."2.3.0".slog}"."nested-values" or false) ||
        (slog_async."2.3.0"."nested-values" or false) ||
        (f."slog_async"."2.3.0"."nested-values" or false); }
      { "${deps.slog_async."2.3.0".slog}".default = true; }
    ];
    slog_async."2.3.0".default = (f.slog_async."2.3.0".default or true);
    take_mut."${deps.slog_async."2.3.0".take_mut}".default = true;
    thread_local."${deps.slog_async."2.3.0".thread_local}".default = true;
  }) [
    (features_.slog."${deps."slog_async"."2.3.0"."slog"}" deps)
    (features_.take_mut."${deps."slog_async"."2.3.0"."take_mut"}" deps)
    (features_.thread_local."${deps."slog_async"."2.3.0"."thread_local"}" deps)
  ];


# end
# slog-scope-4.3.0

  crates.slog_scope."4.3.0" = deps: { features?(features_.slog_scope."4.3.0" deps {}) }: buildRustCrate {
    crateName = "slog-scope";
    version = "4.3.0";
    description = "Logging scopes for slog-rs";
    authors = [ "Dawid Ciężarkiewicz <dpc@dpc.pw>" ];
    sha256 = "1hyy13j664r5cn3s2w79737mpv3p2i48lk78gmb4i9jsnzvzbk24";
    libPath = "lib.rs";
    dependencies = mapFeatures features ([
      (crates."arc_swap"."${deps."slog_scope"."4.3.0"."arc_swap"}" deps)
      (crates."lazy_static"."${deps."slog_scope"."4.3.0"."lazy_static"}" deps)
      (crates."slog"."${deps."slog_scope"."4.3.0"."slog"}" deps)
    ]);
  };
  features_.slog_scope."4.3.0" = deps: f: updateFeatures f (rec {
    arc_swap."${deps.slog_scope."4.3.0".arc_swap}".default = true;
    lazy_static."${deps.slog_scope."4.3.0".lazy_static}".default = true;
    slog."${deps.slog_scope."4.3.0".slog}".default = true;
    slog_scope."4.3.0".default = (f.slog_scope."4.3.0".default or true);
  }) [
    (features_.arc_swap."${deps."slog_scope"."4.3.0"."arc_swap"}" deps)
    (features_.lazy_static."${deps."slog_scope"."4.3.0"."lazy_static"}" deps)
    (features_.slog."${deps."slog_scope"."4.3.0"."slog"}" deps)
  ];


# end
# slog-term-2.4.2

  crates.slog_term."2.4.2" = deps: { features?(features_.slog_term."2.4.2" deps {}) }: buildRustCrate {
    crateName = "slog-term";
    version = "2.4.2";
    description = "Unix terminal drain and formatter for slog-rs";
    authors = [ "Dawid Ciężarkiewicz <dpc@dpc.pw>" ];
    sha256 = "0l1whpp84r56zd8vpy4wqcr82rbw7j9gq2pn4j390nk27yjh66n8";
    dependencies = mapFeatures features ([
      (crates."atty"."${deps."slog_term"."2.4.2"."atty"}" deps)
      (crates."chrono"."${deps."slog_term"."2.4.2"."chrono"}" deps)
      (crates."slog"."${deps."slog_term"."2.4.2"."slog"}" deps)
      (crates."term"."${deps."slog_term"."2.4.2"."term"}" deps)
      (crates."thread_local"."${deps."slog_term"."2.4.2"."thread_local"}" deps)
    ]);
  };
  features_.slog_term."2.4.2" = deps: f: updateFeatures f (rec {
    atty."${deps.slog_term."2.4.2".atty}".default = true;
    chrono."${deps.slog_term."2.4.2".chrono}".default = true;
    slog."${deps.slog_term."2.4.2".slog}".default = true;
    slog_term."2.4.2".default = (f.slog_term."2.4.2".default or true);
    term."${deps.slog_term."2.4.2".term}".default = true;
    thread_local."${deps.slog_term."2.4.2".thread_local}".default = true;
  }) [
    (features_.atty."${deps."slog_term"."2.4.2"."atty"}" deps)
    (features_.chrono."${deps."slog_term"."2.4.2"."chrono"}" deps)
    (features_.slog."${deps."slog_term"."2.4.2"."slog"}" deps)
    (features_.term."${deps."slog_term"."2.4.2"."term"}" deps)
    (features_.thread_local."${deps."slog_term"."2.4.2"."thread_local"}" deps)
  ];


# end
# smallvec-0.6.13

  crates.smallvec."0.6.13" = deps: { features?(features_.smallvec."0.6.13" deps {}) }: buildRustCrate {
    crateName = "smallvec";
    version = "0.6.13";
    description = "'Small vector' optimization: store up to a small number of items on the stack";
    authors = [ "Simon Sapin <simon.sapin@exyr.org>" ];
    sha256 = "15784fxgp1bvld5pbhb3171rv4kwvvy2p83jlyr0smp5hqg2b68w";
    libPath = "lib.rs";
    dependencies = mapFeatures features ([
      (crates."maybe_uninit"."${deps."smallvec"."0.6.13"."maybe_uninit"}" deps)
    ]);
    features = mkFeatures (features."smallvec"."0.6.13" or {});
  };
  features_.smallvec."0.6.13" = deps: f: updateFeatures f (rec {
    maybe_uninit."${deps.smallvec."0.6.13".maybe_uninit}".default = true;
    smallvec = fold recursiveUpdate {} [
      { "0.6.13"."std" =
        (f.smallvec."0.6.13"."std" or false) ||
        (f.smallvec."0.6.13".default or false) ||
        (smallvec."0.6.13"."default" or false); }
      { "0.6.13".default = (f.smallvec."0.6.13".default or true); }
    ];
  }) [
    (features_.maybe_uninit."${deps."smallvec"."0.6.13"."maybe_uninit"}" deps)
  ];


# end
# socket2-0.3.11

  crates.socket2."0.3.11" = deps: { features?(features_.socket2."0.3.11" deps {}) }: buildRustCrate {
    crateName = "socket2";
    version = "0.3.11";
    description = "Utilities for handling networking sockets with a maximal amount of configuration\npossible intended.\n";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    edition = "2018";
    sha256 = "06v07j2i8miv484vdgbj0k6npk6115x756yi0x3gvd3424nj3yjx";
    dependencies = (if (kernel == "linux" || kernel == "darwin") || kernel == "redox" then mapFeatures features ([
      (crates."cfg_if"."${deps."socket2"."0.3.11"."cfg_if"}" deps)
      (crates."libc"."${deps."socket2"."0.3.11"."libc"}" deps)
    ]) else [])
      ++ (if kernel == "redox" then mapFeatures features ([
      (crates."redox_syscall"."${deps."socket2"."0.3.11"."redox_syscall"}" deps)
    ]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."socket2"."0.3.11"."winapi"}" deps)
    ]) else []);
    features = mkFeatures (features."socket2"."0.3.11" or {});
  };
  features_.socket2."0.3.11" = deps: f: updateFeatures f (rec {
    cfg_if."${deps.socket2."0.3.11".cfg_if}".default = true;
    libc."${deps.socket2."0.3.11".libc}".default = true;
    redox_syscall."${deps.socket2."0.3.11".redox_syscall}".default = true;
    socket2."0.3.11".default = (f.socket2."0.3.11".default or true);
    winapi = fold recursiveUpdate {} [
      { "${deps.socket2."0.3.11".winapi}"."handleapi" = true; }
      { "${deps.socket2."0.3.11".winapi}"."minwindef" = true; }
      { "${deps.socket2."0.3.11".winapi}"."ws2def" = true; }
      { "${deps.socket2."0.3.11".winapi}"."ws2ipdef" = true; }
      { "${deps.socket2."0.3.11".winapi}"."ws2tcpip" = true; }
      { "${deps.socket2."0.3.11".winapi}".default = true; }
    ];
  }) [
    (features_.cfg_if."${deps."socket2"."0.3.11"."cfg_if"}" deps)
    (features_.libc."${deps."socket2"."0.3.11"."libc"}" deps)
    (features_.redox_syscall."${deps."socket2"."0.3.11"."redox_syscall"}" deps)
    (features_.winapi."${deps."socket2"."0.3.11"."winapi"}" deps)
  ];


# end
# stable_deref_trait-1.1.1

  crates.stable_deref_trait."1.1.1" = deps: { features?(features_.stable_deref_trait."1.1.1" deps {}) }: buildRustCrate {
    crateName = "stable_deref_trait";
    version = "1.1.1";
    description = "An unsafe marker trait for types like Box and Rc that dereference to a stable address even when moved, and hence can be used with libraries such as owning_ref and rental.\n";
    authors = [ "Robert Grosse <n210241048576@gmail.com>" ];
    sha256 = "1xy9slzslrzr31nlnw52sl1d820b09y61b7f13lqgsn8n7y0l4g8";
    features = mkFeatures (features."stable_deref_trait"."1.1.1" or {});
  };
  features_.stable_deref_trait."1.1.1" = deps: f: updateFeatures f (rec {
    stable_deref_trait = fold recursiveUpdate {} [
      { "1.1.1"."std" =
        (f.stable_deref_trait."1.1.1"."std" or false) ||
        (f.stable_deref_trait."1.1.1".default or false) ||
        (stable_deref_trait."1.1.1"."default" or false); }
      { "1.1.1".default = (f.stable_deref_trait."1.1.1".default or true); }
    ];
  }) [];


# end
# strsim-0.8.0

  crates.strsim."0.8.0" = deps: { features?(features_.strsim."0.8.0" deps {}) }: buildRustCrate {
    crateName = "strsim";
    version = "0.8.0";
    description = "Implementations of string similarity metrics.\nIncludes Hamming, Levenshtein, OSA, Damerau-Levenshtein, Jaro, and Jaro-Winkler.\n";
    authors = [ "Danny Guo <dannyguo91@gmail.com>" ];
    sha256 = "0d3jsdz22wgjyxdakqnvdgmwjdvkximz50d9zfk4qlalw635qcvy";
  };
  features_.strsim."0.8.0" = deps: f: updateFeatures f (rec {
    strsim."0.8.0".default = (f.strsim."0.8.0".default or true);
  }) [];


# end
# structopt-0.2.18

  crates.structopt."0.2.18" = deps: { features?(features_.structopt."0.2.18" deps {}) }: buildRustCrate {
    crateName = "structopt";
    version = "0.2.18";
    description = "Parse command line argument by defining a struct.";
    authors = [ "Guillaume Pinot <texitoi@texitoi.eu>" "others" ];
    sha256 = "096mzwn2d5qsa0k5kxvd1ag38fm5rfrr262fnacfrq5k13ldl9j2";
    dependencies = mapFeatures features ([
      (crates."clap"."${deps."structopt"."0.2.18"."clap"}" deps)
      (crates."structopt_derive"."${deps."structopt"."0.2.18"."structopt_derive"}" deps)
    ]);
    features = mkFeatures (features."structopt"."0.2.18" or {});
  };
  features_.structopt."0.2.18" = deps: f: updateFeatures f (rec {
    clap = fold recursiveUpdate {} [
      { "${deps.structopt."0.2.18".clap}"."color" =
        (f.clap."${deps.structopt."0.2.18".clap}"."color" or false) ||
        (structopt."0.2.18"."color" or false) ||
        (f."structopt"."0.2.18"."color" or false); }
      { "${deps.structopt."0.2.18".clap}"."debug" =
        (f.clap."${deps.structopt."0.2.18".clap}"."debug" or false) ||
        (structopt."0.2.18"."debug" or false) ||
        (f."structopt"."0.2.18"."debug" or false); }
      { "${deps.structopt."0.2.18".clap}"."default" =
        (f.clap."${deps.structopt."0.2.18".clap}"."default" or false) ||
        (structopt."0.2.18"."default" or false) ||
        (f."structopt"."0.2.18"."default" or false); }
      { "${deps.structopt."0.2.18".clap}"."doc" =
        (f.clap."${deps.structopt."0.2.18".clap}"."doc" or false) ||
        (structopt."0.2.18"."doc" or false) ||
        (f."structopt"."0.2.18"."doc" or false); }
      { "${deps.structopt."0.2.18".clap}"."lints" =
        (f.clap."${deps.structopt."0.2.18".clap}"."lints" or false) ||
        (structopt."0.2.18"."lints" or false) ||
        (f."structopt"."0.2.18"."lints" or false); }
      { "${deps.structopt."0.2.18".clap}"."no_cargo" =
        (f.clap."${deps.structopt."0.2.18".clap}"."no_cargo" or false) ||
        (structopt."0.2.18"."no_cargo" or false) ||
        (f."structopt"."0.2.18"."no_cargo" or false); }
      { "${deps.structopt."0.2.18".clap}"."suggestions" =
        (f.clap."${deps.structopt."0.2.18".clap}"."suggestions" or false) ||
        (structopt."0.2.18"."suggestions" or false) ||
        (f."structopt"."0.2.18"."suggestions" or false); }
      { "${deps.structopt."0.2.18".clap}"."wrap_help" =
        (f.clap."${deps.structopt."0.2.18".clap}"."wrap_help" or false) ||
        (structopt."0.2.18"."wrap_help" or false) ||
        (f."structopt"."0.2.18"."wrap_help" or false); }
      { "${deps.structopt."0.2.18".clap}"."yaml" =
        (f.clap."${deps.structopt."0.2.18".clap}"."yaml" or false) ||
        (structopt."0.2.18"."yaml" or false) ||
        (f."structopt"."0.2.18"."yaml" or false); }
      { "${deps.structopt."0.2.18".clap}".default = (f.clap."${deps.structopt."0.2.18".clap}".default or false); }
    ];
    structopt."0.2.18".default = (f.structopt."0.2.18".default or true);
    structopt_derive = fold recursiveUpdate {} [
      { "${deps.structopt."0.2.18".structopt_derive}"."nightly" =
        (f.structopt_derive."${deps.structopt."0.2.18".structopt_derive}"."nightly" or false) ||
        (structopt."0.2.18"."nightly" or false) ||
        (f."structopt"."0.2.18"."nightly" or false); }
      { "${deps.structopt."0.2.18".structopt_derive}"."paw" =
        (f.structopt_derive."${deps.structopt."0.2.18".structopt_derive}"."paw" or false) ||
        (structopt."0.2.18"."paw" or false) ||
        (f."structopt"."0.2.18"."paw" or false); }
      { "${deps.structopt."0.2.18".structopt_derive}".default = true; }
    ];
  }) [
    (features_.clap."${deps."structopt"."0.2.18"."clap"}" deps)
    (features_.structopt_derive."${deps."structopt"."0.2.18"."structopt_derive"}" deps)
  ];


# end
# structopt-derive-0.2.18

  crates.structopt_derive."0.2.18" = deps: { features?(features_.structopt_derive."0.2.18" deps {}) }: buildRustCrate {
    crateName = "structopt-derive";
    version = "0.2.18";
    description = "Parse command line argument by defining a struct, derive crate.";
    authors = [ "Guillaume Pinot <texitoi@texitoi.eu>" ];
    sha256 = "0wrhvq92psxa62jx6ypyhld7d5l3l7va0s0qwy1mq7c863wnhp7p";
    procMacro = true;
    dependencies = mapFeatures features ([
      (crates."heck"."${deps."structopt_derive"."0.2.18"."heck"}" deps)
      (crates."proc_macro2"."${deps."structopt_derive"."0.2.18"."proc_macro2"}" deps)
      (crates."quote"."${deps."structopt_derive"."0.2.18"."quote"}" deps)
      (crates."syn"."${deps."structopt_derive"."0.2.18"."syn"}" deps)
    ]);
    features = mkFeatures (features."structopt_derive"."0.2.18" or {});
  };
  features_.structopt_derive."0.2.18" = deps: f: updateFeatures f (rec {
    heck."${deps.structopt_derive."0.2.18".heck}".default = true;
    proc_macro2 = fold recursiveUpdate {} [
      { "${deps.structopt_derive."0.2.18".proc_macro2}"."nightly" =
        (f.proc_macro2."${deps.structopt_derive."0.2.18".proc_macro2}"."nightly" or false) ||
        (structopt_derive."0.2.18"."nightly" or false) ||
        (f."structopt_derive"."0.2.18"."nightly" or false); }
      { "${deps.structopt_derive."0.2.18".proc_macro2}".default = true; }
    ];
    quote."${deps.structopt_derive."0.2.18".quote}".default = true;
    structopt_derive."0.2.18".default = (f.structopt_derive."0.2.18".default or true);
    syn."${deps.structopt_derive."0.2.18".syn}".default = true;
  }) [
    (features_.heck."${deps."structopt_derive"."0.2.18"."heck"}" deps)
    (features_.proc_macro2."${deps."structopt_derive"."0.2.18"."proc_macro2"}" deps)
    (features_.quote."${deps."structopt_derive"."0.2.18"."quote"}" deps)
    (features_.syn."${deps."structopt_derive"."0.2.18"."syn"}" deps)
  ];


# end
# syn-0.15.44

  crates.syn."0.15.44" = deps: { features?(features_.syn."0.15.44" deps {}) }: buildRustCrate {
    crateName = "syn";
    version = "0.15.44";
    description = "Parser for Rust source code";
    authors = [ "David Tolnay <dtolnay@gmail.com>" ];
    sha256 = "09v11h141grmsnamd5j14mn8vpnfng6p60kdmsm8akz9m0qn7s1n";
    dependencies = mapFeatures features ([
      (crates."proc_macro2"."${deps."syn"."0.15.44"."proc_macro2"}" deps)
      (crates."unicode_xid"."${deps."syn"."0.15.44"."unicode_xid"}" deps)
    ]
      ++ (if features.syn."0.15.44".quote or false then [ (crates.quote."${deps."syn"."0.15.44".quote}" deps) ] else []));
    features = mkFeatures (features."syn"."0.15.44" or {});
  };
  features_.syn."0.15.44" = deps: f: updateFeatures f (rec {
    proc_macro2 = fold recursiveUpdate {} [
      { "${deps.syn."0.15.44".proc_macro2}"."proc-macro" =
        (f.proc_macro2."${deps.syn."0.15.44".proc_macro2}"."proc-macro" or false) ||
        (syn."0.15.44"."proc-macro" or false) ||
        (f."syn"."0.15.44"."proc-macro" or false); }
      { "${deps.syn."0.15.44".proc_macro2}".default = (f.proc_macro2."${deps.syn."0.15.44".proc_macro2}".default or false); }
    ];
    quote = fold recursiveUpdate {} [
      { "${deps.syn."0.15.44".quote}"."proc-macro" =
        (f.quote."${deps.syn."0.15.44".quote}"."proc-macro" or false) ||
        (syn."0.15.44"."proc-macro" or false) ||
        (f."syn"."0.15.44"."proc-macro" or false); }
      { "${deps.syn."0.15.44".quote}".default = (f.quote."${deps.syn."0.15.44".quote}".default or false); }
    ];
    syn = fold recursiveUpdate {} [
      { "0.15.44"."clone-impls" =
        (f.syn."0.15.44"."clone-impls" or false) ||
        (f.syn."0.15.44".default or false) ||
        (syn."0.15.44"."default" or false); }
      { "0.15.44"."derive" =
        (f.syn."0.15.44"."derive" or false) ||
        (f.syn."0.15.44".default or false) ||
        (syn."0.15.44"."default" or false); }
      { "0.15.44"."parsing" =
        (f.syn."0.15.44"."parsing" or false) ||
        (f.syn."0.15.44".default or false) ||
        (syn."0.15.44"."default" or false); }
      { "0.15.44"."printing" =
        (f.syn."0.15.44"."printing" or false) ||
        (f.syn."0.15.44".default or false) ||
        (syn."0.15.44"."default" or false); }
      { "0.15.44"."proc-macro" =
        (f.syn."0.15.44"."proc-macro" or false) ||
        (f.syn."0.15.44".default or false) ||
        (syn."0.15.44"."default" or false); }
      { "0.15.44"."quote" =
        (f.syn."0.15.44"."quote" or false) ||
        (f.syn."0.15.44".printing or false) ||
        (syn."0.15.44"."printing" or false); }
      { "0.15.44".default = (f.syn."0.15.44".default or true); }
    ];
    unicode_xid."${deps.syn."0.15.44".unicode_xid}".default = true;
  }) [
    (features_.proc_macro2."${deps."syn"."0.15.44"."proc_macro2"}" deps)
    (features_.quote."${deps."syn"."0.15.44"."quote"}" deps)
    (features_.unicode_xid."${deps."syn"."0.15.44"."unicode_xid"}" deps)
  ];


# end
# syn-1.0.8

  crates.syn."1.0.8" = deps: { features?(features_.syn."1.0.8" deps {}) }: buildRustCrate {
    crateName = "syn";
    version = "1.0.8";
    description = "Parser for Rust source code";
    authors = [ "David Tolnay <dtolnay@gmail.com>" ];
    edition = "2018";
    sha256 = "0yjxxbh0n3xq73qjmhbb38jq1giz0k26bf8vawkv9xm703bbs06h";
    dependencies = mapFeatures features ([
      (crates."proc_macro2"."${deps."syn"."1.0.8"."proc_macro2"}" deps)
      (crates."unicode_xid"."${deps."syn"."1.0.8"."unicode_xid"}" deps)
    ]
      ++ (if features.syn."1.0.8".quote or false then [ (crates.quote."${deps."syn"."1.0.8".quote}" deps) ] else []));
    features = mkFeatures (features."syn"."1.0.8" or {});
  };
  features_.syn."1.0.8" = deps: f: updateFeatures f (rec {
    proc_macro2 = fold recursiveUpdate {} [
      { "${deps.syn."1.0.8".proc_macro2}"."proc-macro" =
        (f.proc_macro2."${deps.syn."1.0.8".proc_macro2}"."proc-macro" or false) ||
        (syn."1.0.8"."proc-macro" or false) ||
        (f."syn"."1.0.8"."proc-macro" or false); }
      { "${deps.syn."1.0.8".proc_macro2}".default = (f.proc_macro2."${deps.syn."1.0.8".proc_macro2}".default or false); }
    ];
    quote = fold recursiveUpdate {} [
      { "${deps.syn."1.0.8".quote}"."proc-macro" =
        (f.quote."${deps.syn."1.0.8".quote}"."proc-macro" or false) ||
        (syn."1.0.8"."proc-macro" or false) ||
        (f."syn"."1.0.8"."proc-macro" or false); }
      { "${deps.syn."1.0.8".quote}".default = (f.quote."${deps.syn."1.0.8".quote}".default or false); }
    ];
    syn = fold recursiveUpdate {} [
      { "1.0.8"."clone-impls" =
        (f.syn."1.0.8"."clone-impls" or false) ||
        (f.syn."1.0.8".default or false) ||
        (syn."1.0.8"."default" or false); }
      { "1.0.8"."derive" =
        (f.syn."1.0.8"."derive" or false) ||
        (f.syn."1.0.8".default or false) ||
        (syn."1.0.8"."default" or false); }
      { "1.0.8"."parsing" =
        (f.syn."1.0.8"."parsing" or false) ||
        (f.syn."1.0.8".default or false) ||
        (syn."1.0.8"."default" or false); }
      { "1.0.8"."printing" =
        (f.syn."1.0.8"."printing" or false) ||
        (f.syn."1.0.8".default or false) ||
        (syn."1.0.8"."default" or false); }
      { "1.0.8"."proc-macro" =
        (f.syn."1.0.8"."proc-macro" or false) ||
        (f.syn."1.0.8".default or false) ||
        (syn."1.0.8"."default" or false); }
      { "1.0.8"."quote" =
        (f.syn."1.0.8"."quote" or false) ||
        (f.syn."1.0.8".printing or false) ||
        (syn."1.0.8"."printing" or false); }
      { "1.0.8".default = (f.syn."1.0.8".default or true); }
    ];
    unicode_xid."${deps.syn."1.0.8".unicode_xid}".default = true;
  }) [
    (features_.proc_macro2."${deps."syn"."1.0.8"."proc_macro2"}" deps)
    (features_.quote."${deps."syn"."1.0.8"."quote"}" deps)
    (features_.unicode_xid."${deps."syn"."1.0.8"."unicode_xid"}" deps)
  ];


# end
# synstructure-0.12.3

  crates.synstructure."0.12.3" = deps: { features?(features_.synstructure."0.12.3" deps {}) }: buildRustCrate {
    crateName = "synstructure";
    version = "0.12.3";
    description = "Helper methods and macros for custom derives";
    authors = [ "Nika Layzell <nika@thelayzells.com>" ];
    edition = "2018";
    sha256 = "1mi3yl5h54wkarzbm4ma4b3dqfjiy8rlvags4qxqhsy3j850rmcy";
    dependencies = mapFeatures features ([
      (crates."proc_macro2"."${deps."synstructure"."0.12.3"."proc_macro2"}" deps)
      (crates."quote"."${deps."synstructure"."0.12.3"."quote"}" deps)
      (crates."syn"."${deps."synstructure"."0.12.3"."syn"}" deps)
      (crates."unicode_xid"."${deps."synstructure"."0.12.3"."unicode_xid"}" deps)
    ]);
    features = mkFeatures (features."synstructure"."0.12.3" or {});
  };
  features_.synstructure."0.12.3" = deps: f: updateFeatures f (rec {
    proc_macro2 = fold recursiveUpdate {} [
      { "${deps.synstructure."0.12.3".proc_macro2}"."proc-macro" =
        (f.proc_macro2."${deps.synstructure."0.12.3".proc_macro2}"."proc-macro" or false) ||
        (synstructure."0.12.3"."proc-macro" or false) ||
        (f."synstructure"."0.12.3"."proc-macro" or false); }
      { "${deps.synstructure."0.12.3".proc_macro2}".default = (f.proc_macro2."${deps.synstructure."0.12.3".proc_macro2}".default or false); }
    ];
    quote = fold recursiveUpdate {} [
      { "${deps.synstructure."0.12.3".quote}"."proc-macro" =
        (f.quote."${deps.synstructure."0.12.3".quote}"."proc-macro" or false) ||
        (synstructure."0.12.3"."proc-macro" or false) ||
        (f."synstructure"."0.12.3"."proc-macro" or false); }
      { "${deps.synstructure."0.12.3".quote}".default = (f.quote."${deps.synstructure."0.12.3".quote}".default or false); }
    ];
    syn = fold recursiveUpdate {} [
      { "${deps.synstructure."0.12.3".syn}"."clone-impls" = true; }
      { "${deps.synstructure."0.12.3".syn}"."derive" = true; }
      { "${deps.synstructure."0.12.3".syn}"."extra-traits" = true; }
      { "${deps.synstructure."0.12.3".syn}"."parsing" = true; }
      { "${deps.synstructure."0.12.3".syn}"."printing" = true; }
      { "${deps.synstructure."0.12.3".syn}"."proc-macro" =
        (f.syn."${deps.synstructure."0.12.3".syn}"."proc-macro" or false) ||
        (synstructure."0.12.3"."proc-macro" or false) ||
        (f."synstructure"."0.12.3"."proc-macro" or false); }
      { "${deps.synstructure."0.12.3".syn}"."visit" = true; }
      { "${deps.synstructure."0.12.3".syn}".default = (f.syn."${deps.synstructure."0.12.3".syn}".default or false); }
    ];
    synstructure = fold recursiveUpdate {} [
      { "0.12.3"."proc-macro" =
        (f.synstructure."0.12.3"."proc-macro" or false) ||
        (f.synstructure."0.12.3".default or false) ||
        (synstructure."0.12.3"."default" or false); }
      { "0.12.3".default = (f.synstructure."0.12.3".default or true); }
    ];
    unicode_xid."${deps.synstructure."0.12.3".unicode_xid}".default = true;
  }) [
    (features_.proc_macro2."${deps."synstructure"."0.12.3"."proc_macro2"}" deps)
    (features_.quote."${deps."synstructure"."0.12.3"."quote"}" deps)
    (features_.syn."${deps."synstructure"."0.12.3"."syn"}" deps)
    (features_.unicode_xid."${deps."synstructure"."0.12.3"."unicode_xid"}" deps)
  ];


# end
# take_mut-0.2.2

  crates.take_mut."0.2.2" = deps: { features?(features_.take_mut."0.2.2" deps {}) }: buildRustCrate {
    crateName = "take_mut";
    version = "0.2.2";
    description = "Take a T from a &mut T temporarily";
    authors = [ "Sgeo <sgeoster@gmail.com>" ];
    sha256 = "1jidav4jx1lkz69ixjh37k3m0w46adk798fv7qj6k0zhzkd1kshv";
  };
  features_.take_mut."0.2.2" = deps: f: updateFeatures f (rec {
    take_mut."0.2.2".default = (f.take_mut."0.2.2".default or true);
  }) [];


# end
# tempdir-0.3.7

  crates.tempdir."0.3.7" = deps: { features?(features_.tempdir."0.3.7" deps {}) }: buildRustCrate {
    crateName = "tempdir";
    version = "0.3.7";
    description = "A library for managing a temporary directory and deleting all contents when it's\ndropped.\n";
    authors = [ "The Rust Project Developers" ];
    sha256 = "0y53sxybyljrr7lh0x0ysrsa7p7cljmwv9v80acy3rc6n97g67vy";
    dependencies = mapFeatures features ([
      (crates."rand"."${deps."tempdir"."0.3.7"."rand"}" deps)
      (crates."remove_dir_all"."${deps."tempdir"."0.3.7"."remove_dir_all"}" deps)
    ]);
  };
  features_.tempdir."0.3.7" = deps: f: updateFeatures f (rec {
    rand."${deps.tempdir."0.3.7".rand}".default = true;
    remove_dir_all."${deps.tempdir."0.3.7".remove_dir_all}".default = true;
    tempdir."0.3.7".default = (f.tempdir."0.3.7".default or true);
  }) [
    (features_.rand."${deps."tempdir"."0.3.7"."rand"}" deps)
    (features_.remove_dir_all."${deps."tempdir"."0.3.7"."remove_dir_all"}" deps)
  ];


# end
# tempfile-3.1.0

  crates.tempfile."3.1.0" = deps: { features?(features_.tempfile."3.1.0" deps {}) }: buildRustCrate {
    crateName = "tempfile";
    version = "3.1.0";
    description = "A library for managing temporary files and directories.";
    authors = [ "Steven Allen <steven@stebalien.com>" "The Rust Project Developers" "Ashley Mannix <ashleymannix@live.com.au>" "Jason White <jasonaw0@gmail.com>" ];
    edition = "2018";
    sha256 = "1r7ykxw90p5hm1g46i8ia33j5iwl3q252kbb6b074qhdav3sqndk";
    dependencies = mapFeatures features ([
      (crates."cfg_if"."${deps."tempfile"."3.1.0"."cfg_if"}" deps)
      (crates."rand"."${deps."tempfile"."3.1.0"."rand"}" deps)
      (crates."remove_dir_all"."${deps."tempfile"."3.1.0"."remove_dir_all"}" deps)
    ])
      ++ (if kernel == "redox" then mapFeatures features ([
      (crates."redox_syscall"."${deps."tempfile"."3.1.0"."redox_syscall"}" deps)
    ]) else [])
      ++ (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
      (crates."libc"."${deps."tempfile"."3.1.0"."libc"}" deps)
    ]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."tempfile"."3.1.0"."winapi"}" deps)
    ]) else []);
  };
  features_.tempfile."3.1.0" = deps: f: updateFeatures f (rec {
    cfg_if."${deps.tempfile."3.1.0".cfg_if}".default = true;
    libc."${deps.tempfile."3.1.0".libc}".default = true;
    rand."${deps.tempfile."3.1.0".rand}".default = true;
    redox_syscall."${deps.tempfile."3.1.0".redox_syscall}".default = true;
    remove_dir_all."${deps.tempfile."3.1.0".remove_dir_all}".default = true;
    tempfile."3.1.0".default = (f.tempfile."3.1.0".default or true);
    winapi = fold recursiveUpdate {} [
      { "${deps.tempfile."3.1.0".winapi}"."fileapi" = true; }
      { "${deps.tempfile."3.1.0".winapi}"."handleapi" = true; }
      { "${deps.tempfile."3.1.0".winapi}"."winbase" = true; }
      { "${deps.tempfile."3.1.0".winapi}".default = true; }
    ];
  }) [
    (features_.cfg_if."${deps."tempfile"."3.1.0"."cfg_if"}" deps)
    (features_.rand."${deps."tempfile"."3.1.0"."rand"}" deps)
    (features_.remove_dir_all."${deps."tempfile"."3.1.0"."remove_dir_all"}" deps)
    (features_.redox_syscall."${deps."tempfile"."3.1.0"."redox_syscall"}" deps)
    (features_.libc."${deps."tempfile"."3.1.0"."libc"}" deps)
    (features_.winapi."${deps."tempfile"."3.1.0"."winapi"}" deps)
  ];


# end
# term-0.6.1

  crates.term."0.6.1" = deps: { features?(features_.term."0.6.1" deps {}) }: buildRustCrate {
    crateName = "term";
    version = "0.6.1";
    description = "A terminal formatting library\n";
    authors = [ "The Rust Project Developers" "Steven Allen" ];
    edition = "2018";
    sha256 = "1wdij7b4an6bdr3md7qfy2v70niphl638cw7p34ly5db5r8acl61";
    dependencies = mapFeatures features ([
      (crates."dirs"."${deps."term"."0.6.1"."dirs"}" deps)
    ])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."term"."0.6.1"."winapi"}" deps)
    ]) else []);
  };
  features_.term."0.6.1" = deps: f: updateFeatures f (rec {
    dirs."${deps.term."0.6.1".dirs}".default = true;
    term."0.6.1".default = (f.term."0.6.1".default or true);
    winapi = fold recursiveUpdate {} [
      { "${deps.term."0.6.1".winapi}"."consoleapi" = true; }
      { "${deps.term."0.6.1".winapi}"."fileapi" = true; }
      { "${deps.term."0.6.1".winapi}"."handleapi" = true; }
      { "${deps.term."0.6.1".winapi}"."wincon" = true; }
      { "${deps.term."0.6.1".winapi}".default = true; }
    ];
  }) [
    (features_.dirs."${deps."term"."0.6.1"."dirs"}" deps)
    (features_.winapi."${deps."term"."0.6.1"."winapi"}" deps)
  ];


# end
# termcolor-1.0.5

  crates.termcolor."1.0.5" = deps: { features?(features_.termcolor."1.0.5" deps {}) }: buildRustCrate {
    crateName = "termcolor";
    version = "1.0.5";
    description = "A simple cross platform library for writing colored text to a terminal.\n";
    authors = [ "Andrew Gallant <jamslam@gmail.com>" ];
    sha256 = "16266x431hbkmvyh0pv4yn7wm2kagicqaq6hy4fabn93c08sx0gp";
    dependencies = (if kernel == "windows" then mapFeatures features ([
      (crates."wincolor"."${deps."termcolor"."1.0.5"."wincolor"}" deps)
    ]) else []);
  };
  features_.termcolor."1.0.5" = deps: f: updateFeatures f (rec {
    termcolor."1.0.5".default = (f.termcolor."1.0.5".default or true);
    wincolor."${deps.termcolor."1.0.5".wincolor}".default = true;
  }) [
    (features_.wincolor."${deps."termcolor"."1.0.5"."wincolor"}" deps)
  ];


# end
# textwrap-0.11.0

  crates.textwrap."0.11.0" = deps: { features?(features_.textwrap."0.11.0" deps {}) }: buildRustCrate {
    crateName = "textwrap";
    version = "0.11.0";
    description = "Textwrap is a small library for word wrapping, indenting, and\ndedenting strings.\n\nYou can use it to format strings (such as help and error messages) for\ndisplay in commandline applications. It is designed to be efficient\nand handle Unicode characters correctly.\n";
    authors = [ "Martin Geisler <martin@geisler.net>" ];
    sha256 = "0s25qh49n7kjayrdj4q3v0jk0jc6vy88rdw0bvgfxqlscpqpxi7d";
    dependencies = mapFeatures features ([
      (crates."unicode_width"."${deps."textwrap"."0.11.0"."unicode_width"}" deps)
    ]);
  };
  features_.textwrap."0.11.0" = deps: f: updateFeatures f (rec {
    textwrap."0.11.0".default = (f.textwrap."0.11.0".default or true);
    unicode_width."${deps.textwrap."0.11.0".unicode_width}".default = true;
  }) [
    (features_.unicode_width."${deps."textwrap"."0.11.0"."unicode_width"}" deps)
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
# time-0.1.42

  crates.time."0.1.42" = deps: { features?(features_.time."0.1.42" deps {}) }: buildRustCrate {
    crateName = "time";
    version = "0.1.42";
    description = "Utilities for working with time-related functions in Rust.\n";
    authors = [ "The Rust Project Developers" ];
    sha256 = "1ny809kmdjwd4b478ipc33dz7q6nq7rxk766x8cnrg6zygcksmmx";
    dependencies = mapFeatures features ([
      (crates."libc"."${deps."time"."0.1.42"."libc"}" deps)
    ])
      ++ (if kernel == "redox" then mapFeatures features ([
      (crates."redox_syscall"."${deps."time"."0.1.42"."redox_syscall"}" deps)
    ]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."time"."0.1.42"."winapi"}" deps)
    ]) else []);
  };
  features_.time."0.1.42" = deps: f: updateFeatures f (rec {
    libc."${deps.time."0.1.42".libc}".default = true;
    redox_syscall."${deps.time."0.1.42".redox_syscall}".default = true;
    time."0.1.42".default = (f.time."0.1.42".default or true);
    winapi = fold recursiveUpdate {} [
      { "${deps.time."0.1.42".winapi}"."minwinbase" = true; }
      { "${deps.time."0.1.42".winapi}"."minwindef" = true; }
      { "${deps.time."0.1.42".winapi}"."ntdef" = true; }
      { "${deps.time."0.1.42".winapi}"."profileapi" = true; }
      { "${deps.time."0.1.42".winapi}"."std" = true; }
      { "${deps.time."0.1.42".winapi}"."sysinfoapi" = true; }
      { "${deps.time."0.1.42".winapi}"."timezoneapi" = true; }
      { "${deps.time."0.1.42".winapi}".default = true; }
    ];
  }) [
    (features_.libc."${deps."time"."0.1.42"."libc"}" deps)
    (features_.redox_syscall."${deps."time"."0.1.42"."redox_syscall"}" deps)
    (features_.winapi."${deps."time"."0.1.42"."winapi"}" deps)
  ];


# end
# tokio-0.2.8

  crates.tokio."0.2.8" = deps: { features?(features_.tokio."0.2.8" deps {}) }: buildRustCrate {
    crateName = "tokio";
    version = "0.2.8";
    description = "An event-driven, non-blocking I/O platform for writing asynchronous I/O\nbacked applications.\n";
    authors = [ "Tokio Contributors <team@tokio.rs>" ];
    edition = "2018";
    sha256 = "09jc0lal2dm5w6cxh02ad7kaz4a66g2v0cxldqn1asffwm321vl2";
    dependencies = mapFeatures features ([
      (crates."bytes"."${deps."tokio"."0.2.8"."bytes"}" deps)
      (crates."pin_project_lite"."${deps."tokio"."0.2.8"."pin_project_lite"}" deps)
    ]
      ++ (if features.tokio."0.2.8".fnv or false then [ (crates.fnv."${deps."tokio"."0.2.8".fnv}" deps) ] else [])
      ++ (if features.tokio."0.2.8".futures-core or false then [ (crates.futures_core."${deps."tokio"."0.2.8".futures_core}" deps) ] else [])
      ++ (if features.tokio."0.2.8".lazy_static or false then [ (crates.lazy_static."${deps."tokio"."0.2.8".lazy_static}" deps) ] else [])
      ++ (if features.tokio."0.2.8".memchr or false then [ (crates.memchr."${deps."tokio"."0.2.8".memchr}" deps) ] else [])
      ++ (if features.tokio."0.2.8".mio or false then [ (crates.mio."${deps."tokio"."0.2.8".mio}" deps) ] else [])
      ++ (if features.tokio."0.2.8".num_cpus or false then [ (crates.num_cpus."${deps."tokio"."0.2.8".num_cpus}" deps) ] else []))
      ++ (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
    ]
      ++ (if features.tokio."0.2.8".libc or false then [ (crates.libc."${deps."tokio"."0.2.8".libc}" deps) ] else [])
      ++ (if features.tokio."0.2.8".mio-uds or false then [ (crates.mio_uds."${deps."tokio"."0.2.8".mio_uds}" deps) ] else [])
      ++ (if features.tokio."0.2.8".signal-hook-registry or false then [ (crates.signal_hook_registry."${deps."tokio"."0.2.8".signal_hook_registry}" deps) ] else [])) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
    ]
      ++ (if features.tokio."0.2.8".mio-named-pipes or false then [ (crates.mio_named_pipes."${deps."tokio"."0.2.8".mio_named_pipes}" deps) ] else [])
      ++ (if features.tokio."0.2.8".winapi or false then [ (crates.winapi."${deps."tokio"."0.2.8".winapi}" deps) ] else [])) else []);
    features = mkFeatures (features."tokio"."0.2.8" or {});
  };
  features_.tokio."0.2.8" = deps: f: updateFeatures f (rec {
    bytes."${deps.tokio."0.2.8".bytes}".default = true;
    fnv."${deps.tokio."0.2.8".fnv}".default = true;
    futures_core."${deps.tokio."0.2.8".futures_core}".default = true;
    lazy_static."${deps.tokio."0.2.8".lazy_static}".default = true;
    libc."${deps.tokio."0.2.8".libc}".default = true;
    memchr."${deps.tokio."0.2.8".memchr}".default = true;
    mio."${deps.tokio."0.2.8".mio}".default = true;
    mio_named_pipes."${deps.tokio."0.2.8".mio_named_pipes}".default = true;
    mio_uds."${deps.tokio."0.2.8".mio_uds}".default = true;
    num_cpus."${deps.tokio."0.2.8".num_cpus}".default = true;
    pin_project_lite."${deps.tokio."0.2.8".pin_project_lite}".default = true;
    signal_hook_registry."${deps.tokio."0.2.8".signal_hook_registry}".default = true;
    tokio = fold recursiveUpdate {} [
      { "0.2.8"."blocking" =
        (f.tokio."0.2.8"."blocking" or false) ||
        (f.tokio."0.2.8".full or false) ||
        (tokio."0.2.8"."full" or false); }
      { "0.2.8"."dns" =
        (f.tokio."0.2.8"."dns" or false) ||
        (f.tokio."0.2.8".full or false) ||
        (tokio."0.2.8"."full" or false) ||
        (f.tokio."0.2.8".net or false) ||
        (tokio."0.2.8"."net" or false); }
      { "0.2.8"."fnv" =
        (f.tokio."0.2.8"."fnv" or false) ||
        (f.tokio."0.2.8".sync or false) ||
        (tokio."0.2.8"."sync" or false); }
      { "0.2.8"."fs" =
        (f.tokio."0.2.8"."fs" or false) ||
        (f.tokio."0.2.8".full or false) ||
        (tokio."0.2.8"."full" or false); }
      { "0.2.8"."futures-core" =
        (f.tokio."0.2.8"."futures-core" or false) ||
        (f.tokio."0.2.8".stream or false) ||
        (tokio."0.2.8"."stream" or false); }
      { "0.2.8"."io-driver" =
        (f.tokio."0.2.8"."io-driver" or false) ||
        (f.tokio."0.2.8".full or false) ||
        (tokio."0.2.8"."full" or false) ||
        (f.tokio."0.2.8".process or false) ||
        (tokio."0.2.8"."process" or false) ||
        (f.tokio."0.2.8".signal or false) ||
        (tokio."0.2.8"."signal" or false) ||
        (f.tokio."0.2.8".tcp or false) ||
        (tokio."0.2.8"."tcp" or false) ||
        (f.tokio."0.2.8".udp or false) ||
        (tokio."0.2.8"."udp" or false) ||
        (f.tokio."0.2.8".uds or false) ||
        (tokio."0.2.8"."uds" or false); }
      { "0.2.8"."io-std" =
        (f.tokio."0.2.8"."io-std" or false) ||
        (f.tokio."0.2.8".full or false) ||
        (tokio."0.2.8"."full" or false); }
      { "0.2.8"."io-util" =
        (f.tokio."0.2.8"."io-util" or false) ||
        (f.tokio."0.2.8".full or false) ||
        (tokio."0.2.8"."full" or false); }
      { "0.2.8"."iovec" =
        (f.tokio."0.2.8"."iovec" or false) ||
        (f.tokio."0.2.8".tcp or false) ||
        (tokio."0.2.8"."tcp" or false); }
      { "0.2.8"."lazy_static" =
        (f.tokio."0.2.8"."lazy_static" or false) ||
        (f.tokio."0.2.8".io-driver or false) ||
        (tokio."0.2.8"."io-driver" or false) ||
        (f.tokio."0.2.8".signal or false) ||
        (tokio."0.2.8"."signal" or false); }
      { "0.2.8"."libc" =
        (f.tokio."0.2.8"."libc" or false) ||
        (f.tokio."0.2.8".process or false) ||
        (tokio."0.2.8"."process" or false) ||
        (f.tokio."0.2.8".signal or false) ||
        (tokio."0.2.8"."signal" or false) ||
        (f.tokio."0.2.8".uds or false) ||
        (tokio."0.2.8"."uds" or false); }
      { "0.2.8"."macros" =
        (f.tokio."0.2.8"."macros" or false) ||
        (f.tokio."0.2.8".full or false) ||
        (tokio."0.2.8"."full" or false); }
      { "0.2.8"."memchr" =
        (f.tokio."0.2.8"."memchr" or false) ||
        (f.tokio."0.2.8".io-util or false) ||
        (tokio."0.2.8"."io-util" or false); }
      { "0.2.8"."mio" =
        (f.tokio."0.2.8"."mio" or false) ||
        (f.tokio."0.2.8".io-driver or false) ||
        (tokio."0.2.8"."io-driver" or false); }
      { "0.2.8"."mio-named-pipes" =
        (f.tokio."0.2.8"."mio-named-pipes" or false) ||
        (f.tokio."0.2.8".process or false) ||
        (tokio."0.2.8"."process" or false); }
      { "0.2.8"."mio-uds" =
        (f.tokio."0.2.8"."mio-uds" or false) ||
        (f.tokio."0.2.8".signal or false) ||
        (tokio."0.2.8"."signal" or false) ||
        (f.tokio."0.2.8".uds or false) ||
        (tokio."0.2.8"."uds" or false); }
      { "0.2.8"."net" =
        (f.tokio."0.2.8"."net" or false) ||
        (f.tokio."0.2.8".full or false) ||
        (tokio."0.2.8"."full" or false); }
      { "0.2.8"."num_cpus" =
        (f.tokio."0.2.8"."num_cpus" or false) ||
        (f.tokio."0.2.8".rt-threaded or false) ||
        (tokio."0.2.8"."rt-threaded" or false); }
      { "0.2.8"."process" =
        (f.tokio."0.2.8"."process" or false) ||
        (f.tokio."0.2.8".full or false) ||
        (tokio."0.2.8"."full" or false); }
      { "0.2.8"."rt-core" =
        (f.tokio."0.2.8"."rt-core" or false) ||
        (f.tokio."0.2.8".blocking or false) ||
        (tokio."0.2.8"."blocking" or false) ||
        (f.tokio."0.2.8".dns or false) ||
        (tokio."0.2.8"."dns" or false) ||
        (f.tokio."0.2.8".fs or false) ||
        (tokio."0.2.8"."fs" or false) ||
        (f.tokio."0.2.8".full or false) ||
        (tokio."0.2.8"."full" or false) ||
        (f.tokio."0.2.8".io-std or false) ||
        (tokio."0.2.8"."io-std" or false) ||
        (f.tokio."0.2.8".rt-threaded or false) ||
        (tokio."0.2.8"."rt-threaded" or false); }
      { "0.2.8"."rt-threaded" =
        (f.tokio."0.2.8"."rt-threaded" or false) ||
        (f.tokio."0.2.8".full or false) ||
        (tokio."0.2.8"."full" or false); }
      { "0.2.8"."rt-util" =
        (f.tokio."0.2.8"."rt-util" or false) ||
        (f.tokio."0.2.8".full or false) ||
        (tokio."0.2.8"."full" or false); }
      { "0.2.8"."signal" =
        (f.tokio."0.2.8"."signal" or false) ||
        (f.tokio."0.2.8".full or false) ||
        (tokio."0.2.8"."full" or false) ||
        (f.tokio."0.2.8".process or false) ||
        (tokio."0.2.8"."process" or false); }
      { "0.2.8"."signal-hook-registry" =
        (f.tokio."0.2.8"."signal-hook-registry" or false) ||
        (f.tokio."0.2.8".signal or false) ||
        (tokio."0.2.8"."signal" or false); }
      { "0.2.8"."slab" =
        (f.tokio."0.2.8"."slab" or false) ||
        (f.tokio."0.2.8".time or false) ||
        (tokio."0.2.8"."time" or false); }
      { "0.2.8"."stream" =
        (f.tokio."0.2.8"."stream" or false) ||
        (f.tokio."0.2.8".full or false) ||
        (tokio."0.2.8"."full" or false); }
      { "0.2.8"."sync" =
        (f.tokio."0.2.8"."sync" or false) ||
        (f.tokio."0.2.8".full or false) ||
        (tokio."0.2.8"."full" or false); }
      { "0.2.8"."tcp" =
        (f.tokio."0.2.8"."tcp" or false) ||
        (f.tokio."0.2.8".net or false) ||
        (tokio."0.2.8"."net" or false); }
      { "0.2.8"."time" =
        (f.tokio."0.2.8"."time" or false) ||
        (f.tokio."0.2.8".full or false) ||
        (tokio."0.2.8"."full" or false); }
      { "0.2.8"."tokio-macros" =
        (f.tokio."0.2.8"."tokio-macros" or false) ||
        (f.tokio."0.2.8".macros or false) ||
        (tokio."0.2.8"."macros" or false); }
      { "0.2.8"."udp" =
        (f.tokio."0.2.8"."udp" or false) ||
        (f.tokio."0.2.8".net or false) ||
        (tokio."0.2.8"."net" or false); }
      { "0.2.8"."uds" =
        (f.tokio."0.2.8"."uds" or false) ||
        (f.tokio."0.2.8".net or false) ||
        (tokio."0.2.8"."net" or false); }
      { "0.2.8".default = (f.tokio."0.2.8".default or true); }
    ];
    winapi."${deps.tokio."0.2.8".winapi}".default = (f.winapi."${deps.tokio."0.2.8".winapi}".default or false);
  }) [
    (features_.bytes."${deps."tokio"."0.2.8"."bytes"}" deps)
    (features_.fnv."${deps."tokio"."0.2.8"."fnv"}" deps)
    (features_.futures_core."${deps."tokio"."0.2.8"."futures_core"}" deps)
    (features_.lazy_static."${deps."tokio"."0.2.8"."lazy_static"}" deps)
    (features_.memchr."${deps."tokio"."0.2.8"."memchr"}" deps)
    (features_.mio."${deps."tokio"."0.2.8"."mio"}" deps)
    (features_.num_cpus."${deps."tokio"."0.2.8"."num_cpus"}" deps)
    (features_.pin_project_lite."${deps."tokio"."0.2.8"."pin_project_lite"}" deps)
    (features_.libc."${deps."tokio"."0.2.8"."libc"}" deps)
    (features_.mio_uds."${deps."tokio"."0.2.8"."mio_uds"}" deps)
    (features_.signal_hook_registry."${deps."tokio"."0.2.8"."signal_hook_registry"}" deps)
    (features_.mio_named_pipes."${deps."tokio"."0.2.8"."mio_named_pipes"}" deps)
    (features_.winapi."${deps."tokio"."0.2.8"."winapi"}" deps)
  ];


# end
# toml-0.4.10

  crates.toml."0.4.10" = deps: { features?(features_.toml."0.4.10" deps {}) }: buildRustCrate {
    crateName = "toml";
    version = "0.4.10";
    description = "A native Rust encoder and decoder of TOML-formatted files and streams. Provides\nimplementations of the standard Serialize/Deserialize traits for TOML data to\nfacilitate deserializing and serializing Rust structures.\n";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    sha256 = "0fs4kxl86w3kmgwcgcv23nk79zagayz1spg281r83w0ywf88d6f1";
    dependencies = mapFeatures features ([
      (crates."serde"."${deps."toml"."0.4.10"."serde"}" deps)
    ]);
  };
  features_.toml."0.4.10" = deps: f: updateFeatures f (rec {
    serde."${deps.toml."0.4.10".serde}".default = true;
    toml."0.4.10".default = (f.toml."0.4.10".default or true);
  }) [
    (features_.serde."${deps."toml"."0.4.10"."serde"}" deps)
  ];


# end
# uds_windows-0.1.4

  crates.uds_windows."0.1.4" = deps: { features?(features_.uds_windows."0.1.4" deps {}) }: buildRustCrate {
    crateName = "uds_windows";
    version = "0.1.4";
    description = "Unix Domain Sockets for Windows!";
    authors = [ "Azure IoT Edge Devs" "Harald Hoyer <harald@redhat.com>" ];
    sha256 = "04vyb09xnqc61yh0iyqhjjiv4d5qny4fib8nn6phadk82lrfcy06";
    dependencies = (if kernel == "windows" then mapFeatures features ([
      (crates."kernel32_sys"."${deps."uds_windows"."0.1.4"."kernel32_sys"}" deps)
      (crates."tempdir"."${deps."uds_windows"."0.1.4"."tempdir"}" deps)
      (crates."winapi"."${deps."uds_windows"."0.1.4"."winapi"}" deps)
      (crates."ws2_32_sys"."${deps."uds_windows"."0.1.4"."ws2_32_sys"}" deps)
    ]) else []);
  };
  features_.uds_windows."0.1.4" = deps: f: updateFeatures f (rec {
    kernel32_sys."${deps.uds_windows."0.1.4".kernel32_sys}".default = true;
    tempdir."${deps.uds_windows."0.1.4".tempdir}".default = true;
    uds_windows."0.1.4".default = (f.uds_windows."0.1.4".default or true);
    winapi."${deps.uds_windows."0.1.4".winapi}".default = true;
    ws2_32_sys."${deps.uds_windows."0.1.4".ws2_32_sys}".default = true;
  }) [
    (features_.kernel32_sys."${deps."uds_windows"."0.1.4"."kernel32_sys"}" deps)
    (features_.tempdir."${deps."uds_windows"."0.1.4"."tempdir"}" deps)
    (features_.winapi."${deps."uds_windows"."0.1.4"."winapi"}" deps)
    (features_.ws2_32_sys."${deps."uds_windows"."0.1.4"."ws2_32_sys"}" deps)
  ];


# end
# unicode-segmentation-1.6.0

  crates.unicode_segmentation."1.6.0" = deps: { features?(features_.unicode_segmentation."1.6.0" deps {}) }: buildRustCrate {
    crateName = "unicode-segmentation";
    version = "1.6.0";
    description = "This crate provides Grapheme Cluster, Word and Sentence boundaries\naccording to Unicode Standard Annex #29 rules.\n";
    authors = [ "kwantam <kwantam@gmail.com>" "Manish Goregaokar <manishsmail@gmail.com>" ];
    sha256 = "1i9a9gzj4i7iqwrgfs3dagf3h2b9qxdy7bviykhnsjrxm3azgsyc";
    features = mkFeatures (features."unicode_segmentation"."1.6.0" or {});
  };
  features_.unicode_segmentation."1.6.0" = deps: f: updateFeatures f (rec {
    unicode_segmentation."1.6.0".default = (f.unicode_segmentation."1.6.0".default or true);
  }) [];


# end
# unicode-width-0.1.6

  crates.unicode_width."0.1.6" = deps: { features?(features_.unicode_width."0.1.6" deps {}) }: buildRustCrate {
    crateName = "unicode-width";
    version = "0.1.6";
    description = "Determine displayed width of `char` and `str` types\naccording to Unicode Standard Annex #11 rules.\n";
    authors = [ "kwantam <kwantam@gmail.com>" ];
    sha256 = "1mss965j7d8pv7z7zg6qfkcb7lyhxkxvbh8akzr4xxxx3vzazwsi";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."unicode_width"."0.1.6" or {});
  };
  features_.unicode_width."0.1.6" = deps: f: updateFeatures f (rec {
    unicode_width = fold recursiveUpdate {} [
      { "0.1.6"."compiler_builtins" =
        (f.unicode_width."0.1.6"."compiler_builtins" or false) ||
        (f.unicode_width."0.1.6".rustc-dep-of-std or false) ||
        (unicode_width."0.1.6"."rustc-dep-of-std" or false); }
      { "0.1.6"."core" =
        (f.unicode_width."0.1.6"."core" or false) ||
        (f.unicode_width."0.1.6".rustc-dep-of-std or false) ||
        (unicode_width."0.1.6"."rustc-dep-of-std" or false); }
      { "0.1.6"."std" =
        (f.unicode_width."0.1.6"."std" or false) ||
        (f.unicode_width."0.1.6".rustc-dep-of-std or false) ||
        (unicode_width."0.1.6"."rustc-dep-of-std" or false); }
      { "0.1.6".default = (f.unicode_width."0.1.6".default or true); }
    ];
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
# unicode-xid-0.2.0

  crates.unicode_xid."0.2.0" = deps: { features?(features_.unicode_xid."0.2.0" deps {}) }: buildRustCrate {
    crateName = "unicode-xid";
    version = "0.2.0";
    description = "Determine whether characters have the XID_Start\nor XID_Continue properties according to\nUnicode Standard Annex #31.\n";
    authors = [ "erick.tryzelaar <erick.tryzelaar@gmail.com>" "kwantam <kwantam@gmail.com>" ];
    sha256 = "1c85gb3p3qhbjvfyjb31m06la4f024jx319k10ig7n47dz2fk8v7";
    features = mkFeatures (features."unicode_xid"."0.2.0" or {});
  };
  features_.unicode_xid."0.2.0" = deps: f: updateFeatures f (rec {
    unicode_xid."0.2.0".default = (f.unicode_xid."0.2.0".default or true);
  }) [];


# end
# unix_socket-0.5.0

  crates.unix_socket."0.5.0" = deps: { features?(features_.unix_socket."0.5.0" deps {}) }: buildRustCrate {
    crateName = "unix_socket";
    version = "0.5.0";
    description = "Unix domain socket bindings";
    authors = [ "Steven Fackler <sfackler@gmail.com>" ];
    sha256 = "0gc4g7lybvq31cr6a1jfmn5lgg328lwjr9278j9dq4py5dq3n70f";
    dependencies = mapFeatures features ([
      (crates."cfg_if"."${deps."unix_socket"."0.5.0"."cfg_if"}" deps)
      (crates."libc"."${deps."unix_socket"."0.5.0"."libc"}" deps)
    ]);
  };
  features_.unix_socket."0.5.0" = deps: f: updateFeatures f (rec {
    cfg_if."${deps.unix_socket."0.5.0".cfg_if}".default = true;
    libc."${deps.unix_socket."0.5.0".libc}".default = true;
    unix_socket."0.5.0".default = (f.unix_socket."0.5.0".default or true);
  }) [
    (features_.cfg_if."${deps."unix_socket"."0.5.0"."cfg_if"}" deps)
    (features_.libc."${deps."unix_socket"."0.5.0"."libc"}" deps)
  ];


# end
# uuid-0.7.4

  crates.uuid."0.7.4" = deps: { features?(features_.uuid."0.7.4" deps {}) }: buildRustCrate {
    crateName = "uuid";
    version = "0.7.4";
    description = "A library to generate and parse UUIDs.";
    authors = [ "Ashley Mannix<ashleymannix@live.com.au>" "Christopher Armstrong" "Dylan DPC<dylan.dpc@gmail.com>" "Hunar Roop Kahlon<hunar.roop@gmail.com>" ];
    sha256 = "1kzjah6i8vf51hrla6qnplymaqx2fadhhlnbvgivgld311lqyz9m";
    dependencies = mapFeatures features ([
    ]
      ++ (if features.uuid."0.7.4".rand or false then [ (crates.rand."${deps."uuid"."0.7.4".rand}" deps) ] else []))
      ++ (if kernel == "windows" then mapFeatures features ([
]) else []);
    features = mkFeatures (features."uuid"."0.7.4" or {});
  };
  features_.uuid."0.7.4" = deps: f: updateFeatures f (rec {
    rand = fold recursiveUpdate {} [
      { "${deps.uuid."0.7.4".rand}"."stdweb" =
        (f.rand."${deps.uuid."0.7.4".rand}"."stdweb" or false) ||
        (uuid."0.7.4"."stdweb" or false) ||
        (f."uuid"."0.7.4"."stdweb" or false); }
      { "${deps.uuid."0.7.4".rand}"."wasm-bindgen" =
        (f.rand."${deps.uuid."0.7.4".rand}"."wasm-bindgen" or false) ||
        (uuid."0.7.4"."wasm-bindgen" or false) ||
        (f."uuid"."0.7.4"."wasm-bindgen" or false); }
      { "${deps.uuid."0.7.4".rand}".default = true; }
    ];
    uuid = fold recursiveUpdate {} [
      { "0.7.4"."byteorder" =
        (f.uuid."0.7.4"."byteorder" or false) ||
        (f.uuid."0.7.4".u128 or false) ||
        (uuid."0.7.4"."u128" or false); }
      { "0.7.4"."md5" =
        (f.uuid."0.7.4"."md5" or false) ||
        (f.uuid."0.7.4".v3 or false) ||
        (uuid."0.7.4"."v3" or false); }
      { "0.7.4"."nightly" =
        (f.uuid."0.7.4"."nightly" or false) ||
        (f.uuid."0.7.4".const_fn or false) ||
        (uuid."0.7.4"."const_fn" or false); }
      { "0.7.4"."rand" =
        (f.uuid."0.7.4"."rand" or false) ||
        (f.uuid."0.7.4".v4 or false) ||
        (uuid."0.7.4"."v4" or false); }
      { "0.7.4"."sha1" =
        (f.uuid."0.7.4"."sha1" or false) ||
        (f.uuid."0.7.4".v5 or false) ||
        (uuid."0.7.4"."v5" or false); }
      { "0.7.4"."std" =
        (f.uuid."0.7.4"."std" or false) ||
        (f.uuid."0.7.4".default or false) ||
        (uuid."0.7.4"."default" or false); }
      { "0.7.4"."winapi" =
        (f.uuid."0.7.4"."winapi" or false) ||
        (f.uuid."0.7.4".guid or false) ||
        (uuid."0.7.4"."guid" or false); }
      { "0.7.4".default = (f.uuid."0.7.4".default or true); }
    ];
  }) [
    (features_.rand."${deps."uuid"."0.7.4"."rand"}" deps)
  ];


# end
# varlink-10.0.0

  crates.varlink."10.0.0" = deps: { features?(features_.varlink."10.0.0" deps {}) }: buildRustCrate {
    crateName = "varlink";
    version = "10.0.0";
    description = "Client and server support for the varlink protocol.";
    authors = [ "Harald Hoyer <harald@redhat.com>" ];
    edition = "2018";
    sha256 = "1wgqghrjszrbsmplviqzaa5gi8yp8ki59gsjqaiqb4py91jxhca4";
    libPath = "src/lib.rs";
    dependencies = mapFeatures features ([
      (crates."serde"."${deps."varlink"."10.0.0"."serde"}" deps)
      (crates."serde_derive"."${deps."varlink"."10.0.0"."serde_derive"}" deps)
      (crates."serde_json"."${deps."varlink"."10.0.0"."serde_json"}" deps)
      (crates."tempfile"."${deps."varlink"."10.0.0"."tempfile"}" deps)
    ])
      ++ (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
      (crates."libc"."${deps."varlink"."10.0.0"."libc"}" deps)
      (crates."unix_socket"."${deps."varlink"."10.0.0"."unix_socket"}" deps)
    ]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."uds_windows"."${deps."varlink"."10.0.0"."uds_windows"}" deps)
      (crates."winapi"."${deps."varlink"."10.0.0"."winapi"}" deps)
    ]) else []);
  };
  features_.varlink."10.0.0" = deps: f: updateFeatures f (rec {
    libc."${deps.varlink."10.0.0".libc}".default = (f.libc."${deps.varlink."10.0.0".libc}".default or false);
    serde."${deps.varlink."10.0.0".serde}".default = true;
    serde_derive."${deps.varlink."10.0.0".serde_derive}".default = true;
    serde_json."${deps.varlink."10.0.0".serde_json}".default = true;
    tempfile."${deps.varlink."10.0.0".tempfile}".default = true;
    uds_windows."${deps.varlink."10.0.0".uds_windows}".default = true;
    unix_socket."${deps.varlink."10.0.0".unix_socket}".default = true;
    varlink."10.0.0".default = (f.varlink."10.0.0".default or true);
    winapi = fold recursiveUpdate {} [
      { "${deps.varlink."10.0.0".winapi}"."winsock2" = true; }
      { "${deps.varlink."10.0.0".winapi}"."winuser" = true; }
      { "${deps.varlink."10.0.0".winapi}".default = true; }
    ];
  }) [
    (features_.serde."${deps."varlink"."10.0.0"."serde"}" deps)
    (features_.serde_derive."${deps."varlink"."10.0.0"."serde_derive"}" deps)
    (features_.serde_json."${deps."varlink"."10.0.0"."serde_json"}" deps)
    (features_.tempfile."${deps."varlink"."10.0.0"."tempfile"}" deps)
    (features_.libc."${deps."varlink"."10.0.0"."libc"}" deps)
    (features_.unix_socket."${deps."varlink"."10.0.0"."unix_socket"}" deps)
    (features_.uds_windows."${deps."varlink"."10.0.0"."uds_windows"}" deps)
    (features_.winapi."${deps."varlink"."10.0.0"."winapi"}" deps)
  ];


# end
# varlink_generator-9.0.0

  crates.varlink_generator."9.0.0" = deps: { features?(features_.varlink_generator."9.0.0" deps {}) }: buildRustCrate {
    crateName = "varlink_generator";
    version = "9.0.0";
    description = "Rust code generator for the varlink protocol.";
    authors = [ "Harald Hoyer <harald@redhat.com>" ];
    edition = "2018";
    sha256 = "1p9fbsd6g43mvr10mpp56amiq027bks59chkc51kqajrzhv6m5mr";
    libPath = "src/lib.rs";
    crateBin =
      [{  name = "varlink-rust-generator";  path = "src/bin/varlink-rust-generator.rs"; }];
    dependencies = mapFeatures features ([
      (crates."chainerror"."${deps."varlink_generator"."9.0.0"."chainerror"}" deps)
      (crates."getopts"."${deps."varlink_generator"."9.0.0"."getopts"}" deps)
      (crates."proc_macro2"."${deps."varlink_generator"."9.0.0"."proc_macro2"}" deps)
      (crates."quote"."${deps."varlink_generator"."9.0.0"."quote"}" deps)
      (crates."syn"."${deps."varlink_generator"."9.0.0"."syn"}" deps)
      (crates."varlink_parser"."${deps."varlink_generator"."9.0.0"."varlink_parser"}" deps)
    ]);
  };
  features_.varlink_generator."9.0.0" = deps: f: updateFeatures f (rec {
    chainerror."${deps.varlink_generator."9.0.0".chainerror}".default = true;
    getopts."${deps.varlink_generator."9.0.0".getopts}".default = true;
    proc_macro2."${deps.varlink_generator."9.0.0".proc_macro2}".default = true;
    quote."${deps.varlink_generator."9.0.0".quote}".default = true;
    syn."${deps.varlink_generator."9.0.0".syn}".default = true;
    varlink_generator."9.0.0".default = (f.varlink_generator."9.0.0".default or true);
    varlink_parser."${deps.varlink_generator."9.0.0".varlink_parser}".default = true;
  }) [
    (features_.chainerror."${deps."varlink_generator"."9.0.0"."chainerror"}" deps)
    (features_.getopts."${deps."varlink_generator"."9.0.0"."getopts"}" deps)
    (features_.proc_macro2."${deps."varlink_generator"."9.0.0"."proc_macro2"}" deps)
    (features_.quote."${deps."varlink_generator"."9.0.0"."quote"}" deps)
    (features_.syn."${deps."varlink_generator"."9.0.0"."syn"}" deps)
    (features_.varlink_parser."${deps."varlink_generator"."9.0.0"."varlink_parser"}" deps)
  ];


# end
# varlink_parser-4.0.3

  crates.varlink_parser."4.0.3" = deps: { features?(features_.varlink_parser."4.0.3" deps {}) }: buildRustCrate {
    crateName = "varlink_parser";
    version = "4.0.3";
    description = "A crate for parsing varlink interface definition files.";
    authors = [ "Harald Hoyer <harald@redhat.com>" ];
    edition = "2018";
    sha256 = "0akc615x0k3z5irclr9ci5psyxhdkfq56fxqsg8z4bjfjsyxdxf1";
    build = "build.rs";
    dependencies = mapFeatures features ([
      (crates."ansi_term"."${deps."varlink_parser"."4.0.3"."ansi_term"}" deps)
      (crates."chainerror"."${deps."varlink_parser"."4.0.3"."chainerror"}" deps)
    ]);

    buildDependencies = mapFeatures features ([
]);
    features = mkFeatures (features."varlink_parser"."4.0.3" or {});
  };
  features_.varlink_parser."4.0.3" = deps: f: updateFeatures f (rec {
    ansi_term."${deps.varlink_parser."4.0.3".ansi_term}".default = true;
    chainerror."${deps.varlink_parser."4.0.3".chainerror}".default = true;
    varlink_parser = fold recursiveUpdate {} [
      { "4.0.3"."peg" =
        (f.varlink_parser."4.0.3"."peg" or false) ||
        (f.varlink_parser."4.0.3".dynamic_peg or false) ||
        (varlink_parser."4.0.3"."dynamic_peg" or false); }
      { "4.0.3".default = (f.varlink_parser."4.0.3".default or true); }
    ];
  }) [
    (features_.ansi_term."${deps."varlink_parser"."4.0.3"."ansi_term"}" deps)
    (features_.chainerror."${deps."varlink_parser"."4.0.3"."chainerror"}" deps)
  ];


# end
# vec1-1.4.0

  crates.vec1."1.4.0" = deps: { features?(features_.vec1."1.4.0" deps {}) }: buildRustCrate {
    crateName = "vec1";
    version = "1.4.0";
    description = "a std Vec wrapper assuring that it has at least 1 element";
    authors = [ "Philipp Korber <p.korber@1aim.com>" ];
    sha256 = "0xrprf4fbnlsa7gg4x07p7pzp4jlr86nysk18f4w3hss8gh66y58";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."vec1"."1.4.0" or {});
  };
  features_.vec1."1.4.0" = deps: f: updateFeatures f (rec {
    vec1."1.4.0".default = (f.vec1."1.4.0".default or true);
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
# wait-timeout-0.2.0

  crates.wait_timeout."0.2.0" = deps: { features?(features_.wait_timeout."0.2.0" deps {}) }: buildRustCrate {
    crateName = "wait-timeout";
    version = "0.2.0";
    description = "A crate to wait on a child process with a timeout specified across Unix and\nWindows platforms.\n";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    sha256 = "0l1lsw049536a01gqjb1amr1fddx7656j4qs8m1hjm6nj06qpkry";
    dependencies = (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
      (crates."libc"."${deps."wait_timeout"."0.2.0"."libc"}" deps)
    ]) else []);
  };
  features_.wait_timeout."0.2.0" = deps: f: updateFeatures f (rec {
    libc."${deps.wait_timeout."0.2.0".libc}".default = true;
    wait_timeout."0.2.0".default = (f.wait_timeout."0.2.0".default or true);
  }) [
    (features_.libc."${deps."wait_timeout"."0.2.0"."libc"}" deps)
  ];


# end
# walkdir-2.2.9

  crates.walkdir."2.2.9" = deps: { features?(features_.walkdir."2.2.9" deps {}) }: buildRustCrate {
    crateName = "walkdir";
    version = "2.2.9";
    description = "Recursively walk a directory.";
    authors = [ "Andrew Gallant <jamslam@gmail.com>" ];
    sha256 = "04k0pqbd8p36wxr8003r644ymka5jr5kn1p8xaz9r3nylgwlwjmq";
    dependencies = mapFeatures features ([
      (crates."same_file"."${deps."walkdir"."2.2.9"."same_file"}" deps)
    ])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."walkdir"."2.2.9"."winapi"}" deps)
      (crates."winapi_util"."${deps."walkdir"."2.2.9"."winapi_util"}" deps)
    ]) else []);
  };
  features_.walkdir."2.2.9" = deps: f: updateFeatures f (rec {
    same_file."${deps.walkdir."2.2.9".same_file}".default = true;
    walkdir."2.2.9".default = (f.walkdir."2.2.9".default or true);
    winapi = fold recursiveUpdate {} [
      { "${deps.walkdir."2.2.9".winapi}"."std" = true; }
      { "${deps.walkdir."2.2.9".winapi}"."winnt" = true; }
      { "${deps.walkdir."2.2.9".winapi}".default = true; }
    ];
    winapi_util."${deps.walkdir."2.2.9".winapi_util}".default = true;
  }) [
    (features_.same_file."${deps."walkdir"."2.2.9"."same_file"}" deps)
    (features_.winapi."${deps."walkdir"."2.2.9"."winapi"}" deps)
    (features_.winapi_util."${deps."walkdir"."2.2.9"."winapi_util"}" deps)
  ];


# end
# wasi-0.7.0

  crates.wasi."0.7.0" = deps: { features?(features_.wasi."0.7.0" deps {}) }: buildRustCrate {
    crateName = "wasi";
    version = "0.7.0";
    description = "Experimental WASI API bindings for Rust";
    authors = [ "The Cranelift Project Developers" ];
    edition = "2018";
    sha256 = "1lqknxy8x9mrsy0pna6xlwzypbhli73nbai9gmin5f4z1ghlng25";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."wasi"."0.7.0" or {});
  };
  features_.wasi."0.7.0" = deps: f: updateFeatures f (rec {
    wasi = fold recursiveUpdate {} [
      { "0.7.0"."alloc" =
        (f.wasi."0.7.0"."alloc" or false) ||
        (f.wasi."0.7.0".default or false) ||
        (wasi."0.7.0"."default" or false); }
      { "0.7.0"."compiler_builtins" =
        (f.wasi."0.7.0"."compiler_builtins" or false) ||
        (f.wasi."0.7.0".rustc-dep-of-std or false) ||
        (wasi."0.7.0"."rustc-dep-of-std" or false); }
      { "0.7.0"."core" =
        (f.wasi."0.7.0"."core" or false) ||
        (f.wasi."0.7.0".rustc-dep-of-std or false) ||
        (wasi."0.7.0"."rustc-dep-of-std" or false); }
      { "0.7.0"."rustc-std-workspace-alloc" =
        (f.wasi."0.7.0"."rustc-std-workspace-alloc" or false) ||
        (f.wasi."0.7.0".rustc-dep-of-std or false) ||
        (wasi."0.7.0"."rustc-dep-of-std" or false); }
      { "0.7.0".default = (f.wasi."0.7.0".default or true); }
    ];
  }) [];


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
# winapi-0.3.8

  crates.winapi."0.3.8" = deps: { features?(features_.winapi."0.3.8" deps {}) }: buildRustCrate {
    crateName = "winapi";
    version = "0.3.8";
    description = "Raw FFI bindings for all of Windows API.";
    authors = [ "Peter Atashian <retep998@gmail.com>" ];
    sha256 = "084ialbgww1vxry341fmkg5crgpvab3w52ahx1wa54yqjgym0vxs";
    build = "build.rs";
    dependencies = (if kernel == "i686-pc-windows-gnu" then mapFeatures features ([
      (crates."winapi_i686_pc_windows_gnu"."${deps."winapi"."0.3.8"."winapi_i686_pc_windows_gnu"}" deps)
    ]) else [])
      ++ (if kernel == "x86_64-pc-windows-gnu" then mapFeatures features ([
      (crates."winapi_x86_64_pc_windows_gnu"."${deps."winapi"."0.3.8"."winapi_x86_64_pc_windows_gnu"}" deps)
    ]) else []);
    features = mkFeatures (features."winapi"."0.3.8" or {});
  };
  features_.winapi."0.3.8" = deps: f: updateFeatures f (rec {
    winapi = fold recursiveUpdate {} [
      { "0.3.8"."impl-debug" =
        (f.winapi."0.3.8"."impl-debug" or false) ||
        (f.winapi."0.3.8".debug or false) ||
        (winapi."0.3.8"."debug" or false); }
      { "0.3.8".default = (f.winapi."0.3.8".default or true); }
    ];
    winapi_i686_pc_windows_gnu."${deps.winapi."0.3.8".winapi_i686_pc_windows_gnu}".default = true;
    winapi_x86_64_pc_windows_gnu."${deps.winapi."0.3.8".winapi_x86_64_pc_windows_gnu}".default = true;
  }) [
    (features_.winapi_i686_pc_windows_gnu."${deps."winapi"."0.3.8"."winapi_i686_pc_windows_gnu"}" deps)
    (features_.winapi_x86_64_pc_windows_gnu."${deps."winapi"."0.3.8"."winapi_x86_64_pc_windows_gnu"}" deps)
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
# wincolor-1.0.2

  crates.wincolor."1.0.2" = deps: { features?(features_.wincolor."1.0.2" deps {}) }: buildRustCrate {
    crateName = "wincolor";
    version = "1.0.2";
    description = "A simple Windows specific API for controlling text color in a Windows console.\n";
    authors = [ "Andrew Gallant <jamslam@gmail.com>" ];
    sha256 = "0bxgy5pf0pzykb21xipb41yfxs60inrs5kyavllphbrka5aqps89";
    dependencies = mapFeatures features ([
      (crates."winapi"."${deps."wincolor"."1.0.2"."winapi"}" deps)
      (crates."winapi_util"."${deps."wincolor"."1.0.2"."winapi_util"}" deps)
    ]);
  };
  features_.wincolor."1.0.2" = deps: f: updateFeatures f (rec {
    winapi = fold recursiveUpdate {} [
      { "${deps.wincolor."1.0.2".winapi}"."minwindef" = true; }
      { "${deps.wincolor."1.0.2".winapi}"."wincon" = true; }
      { "${deps.wincolor."1.0.2".winapi}".default = true; }
    ];
    winapi_util."${deps.wincolor."1.0.2".winapi_util}".default = true;
    wincolor."1.0.2".default = (f.wincolor."1.0.2".default or true);
  }) [
    (features_.winapi."${deps."wincolor"."1.0.2"."winapi"}" deps)
    (features_.winapi_util."${deps."wincolor"."1.0.2"."winapi_util"}" deps)
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
