# How does lorri protect project environments from Nix garbage collection?

Most Nix operations never delete packages from the system, they only create new
user environments. [Garbage collection][nix-gc] (GC) is the process by which
Nix explicitly removes all packages for which there is no generation, profile,
or [garbage collector root][nix-gc-roots] referencing it.

From [the blog post that introduced lorri][blog-post]:
> Nix shells are not protected from garbage collection. [...] lorri captures
> development dependencies and creates garbage collection roots automatically.

What does this mean precisely, and how does it work?

## Garbage collection by example: Nix shell and lorri

Let's see GC in action when using Nix shell and lorri.

### Example setup

Assume that we have a project directory with the following minimal setup:

```console
$ cat .envrc 
eval "$(lorri direnv)"
$ cat shell.nix 
with import <nixpkgs> {};
mkShell { buildInputs = [ hello ]; }
```

### Nix shell: output dependencies are garbage collected by default

From the [Nix manual][nix-gc]:

> The behaviour of the garbage collector is affected by the `keep-derivations`
> (default: true) and `keep-outputs` (default: false) options in the Nix
> configuration file. The defaults will ensure that all derivations that are
> build-time dependencies of garbage collector roots will be kept and that all
> output paths that are runtime dependencies will be kept as well. All other
> derivations or paths will be collected. (This is usually what you want, but
> while you are developing it may make sense to keep outputs to ensure that
> rebuild times are quick.)

You can check the values of these settings as follows (default values shown
here):

```
$ nix show-config | grep 'keep-\(outputs\|derivations\)'
keep-derivations = true
keep-outputs = false
```

Nix GC deletes the `hello` package previously installed via `nix-shell` if
`keep-outputs` is false (the default):

```console
$ hello
The program ‘hello’ is currently not installed. [...]
$ nix-shell
[...]
copying path '/nix/store/4w99qz14nsahk0s798a5rw5l7qk1zwwf-hello-2.10' from 'https://cache.nixos.org'...
$ hello
Hello, world!
$ exit
$ nix-store --gc
[...]
deleting '/nix/store/4w99qz14nsahk0s798a5rw5l7qk1zwwf-hello-2.10'
deleting '/nix/store/dhmin7wq99aw9f59jm41varj0753va9b-hello-2.10.drv'
deleting '/nix/store/q0282y7l6f59z71hg1pi2v04dfb1jqbl-hello-2.10.tar.gz.drv'
[...]
```

### lorri: output dependencies are protected from garbage collection

With lorri, the `hello` package is _not_ deleted in a subsequent GC even when
`keep-outputs` is false:

```console
$ hello
The program ‘hello’ is currently not installed. [...]
$ direnv allow # lorri installs `hello` in the background
[...]
$ hello
Hello, world!
$ cd
direnv: unloading
$ nix-store --gc
[...]
0 store paths deleted, 0.00 MiB freed
```

## How does lorri protect dependencies from Nix garbage collection?

In the previous section, we have seen that lorri protects project dependencies
from Nix GC. In this section, we will take a closer look at
_how_ this is done.

### Garbage collection roots

The easy part of protecting a project environment from [Nix GC][nix-gc] is to
create a [GC root][nix-gc-roots] for it. A GC root is simply a symlink
somewhere in `/nix/var/nix/gcroots/` that points (directly or indirectly) to a
Nix store path. That store path is then protected from GC.

After each successful build, lorri creates an indirect GC root:
- a symlink in `$CACHE_DIR/lorri/gc_roots/` (see
  [ProjectDirs::cache_dir][cache-dir] for how `$CACHE_DIR` is determined) which
  points to the store path of the environment, and
- an indirect Nix GC root in `/nix/var/nix/gcroots/per-user/$USER/` which
  points to the symlink

Here is an example:

```console
$ tree ~/.cache/lorri/gc_roots/
├── [...]
├── 8562d49821e3218f74e0e37413973802
│   └── gc_root
│       └── shell_gc_root -> /nix/store/8pxs717wgd15i8g18v5aqm34icy756ii-lorri-wrapped-project-nix-shell
└── [...]
$ tree /nix/var/nix/gcroots/per-user/leo/
/nix/var/nix/gcroots/per-user/leo/
├── [...]
├── 8562d49821e3218f74e0e37413973802-shell_gc_root -> /home/leo/.cache/lorri/gc_roots/8562d49821e3218f74e0e37413973802/gc_root/shell_gc_root
└── [...]
```

<details>
<summary>Why make the GC root indirect?</summary><p>

It makes it easy to garbage collect _all_ lorri-created environments at once:
by removing `$CACHE_DIR/lorri/gc_roots/`. As a result, the garbage
collections roots lorri created inside `/nix/var/nix/gcroots/` will point
nowhere.

The next time Nix GC is triggered, it will fail to follow those GC roots. Roots
that can't be followed are deleted. Since the store paths of the environments
lorri has created will no longer have any GC roots pointing to them, they will
be GC'd.
</details>

There are two things to note here:
1. The exact layout and naming of the directories and symlinks can change at
   any point. They are considered implementation details.
2. The name of the GC root is derived from the file path of the Nix shell file
   that defines the project environment. As a result, the _last successful
   build_ of each project environment is protected from Nix GC.

### Environment closures

The tricky part of protecting a project environment from Nix GC is to capture
all the environment's dependencies in a _closure_.

The goal of lorri's GC protection mechanism is to keep outputs paths of
build-time dependencies for your development environments without forcing you
to set `keep-outputs = true` globally.

[blog-post]: https://www.tweag.io/posts/2019-03-28-introducing-lorri.html
[cache-dir]: https://docs.rs/directories/1.0.2/directories/struct.ProjectDirs.html#method.cache_dir
[nix-conf-man]: https://www.mankier.com/5/nix.conf
[nix-gc-roots]: https://nixos.org/nix/manual/#ssec-gc-roots
[nix-gc]: https://nixos.org/nix/manual/#sec-garbage-collection
