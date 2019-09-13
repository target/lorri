<!-- This tutorial’s contents can be automatically checked with mdsh,
(https://github.com/zimbatm/mdsh). Lines that start with `$ <command>`
are executed and their output inserted into a code block.
We put “hidden” commands that are not relevant to the tutorial into
HTML comments like this one, they should be skipped while following
the tutorial.

In lorri’s toplevel `shell.nix`, we provide a tool to run mdsh
on this file in a sandboxed environment. Execute
```
$ env SUBDIR=./example lorri-mdsh-sandbox -i $(realpath ./example/README.md)
```
from the project root.
-->

# How to set up lorri with direnv

After following this tutorial, you will have a working setup of
`lorri`, `direnv`, and working basic editor integration into Emacs.

This gives you `nix` editor integration for free. Whenever you open
a file, as long as there is a `direnv`/`lorri` setup in the project,
your editor automatically loads all tools, environment variables,
library dependencies, etc. from your nix files. In short: Everything
you need to be productive on your project and everything to make sure
your codevelopers have the same, reproducible setup.
Even further, if you change something in your nix files, `lorri`
immediately picks it up, and your editor does as well.

These are the major setup steps described below:

1. Set up `direnv` >= 2.19.2.
1. Set up `lorri`.
1. Change the environment of a shell with lorri & direnv.
1. Add it to Emacs via `direnv-mode`.

First, clone the `lorri` repository and `cd` into the directory which
contains this tutorial:

<!-- mdsh: We assume this is already checked out. -->
```
$ git clone https://github.com/target/lorri
$ cd lorri/example
```

## Set up `direnv`

[`direnv`](https://direnv.net/) is a tool to automatically load an
environment. You need at least version 2.19.2 of direnv.

To install it into your local nix profile, use our provided pin of
`nixpkgs`:

`$ nix-env -f ../nix/nixpkgs.nix -i -A direnv`

`$ direnv --version`
```
2.20.0
```
Then hook `direnv` into your shell by evaluating the output of

```bash
$ direnv hook <myshell>
```

* For `bash`:
  ```bash
  $ eval "$(direnv hook bash)"
  ```

* For `zsh`:
  ```zsh
  $ eval "$(direnv hook zsh)"
  ```

* For `fish`:
  ```fish
  $ eval (direnv hook fish)
  ```
  
Add that command to your shell’s init file (`$HOME/.bashrc` for `bash`).

If you are still in the `lorri/example` directory, you should now see
a warning message:

```
direnv: error .envrc is blocked. Run `direnv allow` to approve its content.
```

<!-- mdsh
We check for the error, which is the next best thing to checking
the shell hook.
`$ direnv exec $PWD true 2>&1 | grep ".envrc is blocked"`
```
[31mdirenv: error .envrc is blocked. Run `direnv allow` to approve its content.[0m
```
-->

`direnv` has picked up the `.envrc` file which exists in the
`lorri/example` directory. `direnv` uses `.envrc` files to determine
how to load an environment for your project. Since arbitrary code can
be placed into `.envrc`, direnv does not execute it until you allow it
to. Be sure to never run untrusted code.

Do *not* run `direnv allow` for now, or if you already did so run
`direnv deny`. To make the example `.envrc` work, we need to set up
`lorri` first.

## Set up `lorri`

`lorri` can watch a `shell.nix` file, together with all its
dependencies. If any of these files change, `lorri` starts nix and
builds the new version.

Install `lorri` by following the instructions [in the
README](../README.md#install).

<!-- mdsh
`$ nix-env -if ../default.nix`

-->

Now that you have installed `lorri`, let’s take it for a spin.
Start up the `lorri` watcher:

```bash
$ lorri watch
```

<!-- mdsh
`$ lorri watch --once`

-->

As you can see, the watcher starts a build, which finishes after a
short while.
Open the `shell.nix` file in your editor and edit the package list to
include GNU hello:

```nix
with import ../nix/nixpkgs.nix;

mkShell {
  buildInputs = [
    hello
  ];
}
```

<!-- mdsh
`$ sed -ie "/buildInputs/a hello" shell.nix`

`$ lorri watch --once`

-->

As soon as you save, `lorri` starts building the changes.


## Change the environment of your shell with lorri & direnv

Keep `lorri watch` running and open up a second terminal. `cd` back
into `lorri/example`.

You should see the direnv warning message again (`error .envrc is
blocked …`). Type

`$ direnv allow`

You should see a bunch of environment variable names prefixed by
`+/-/~`, like `+shell +stdenv +system ~PATH`. This means `direnv` has
switched your environment to the one set up by `lorri`. Give it a
shot:

```bash
$ hello
Hello, world.
```

<!-- mdsh
`$ direnv exec $PWD hello`
```
Hello, world!
```
-->

Now, remove the `hello` package from your `shell.nix`:

```nix
with import ../nix/nixpkgs.nix;
mkShell {
  buildInputs = [
  ];
}
```

<!-- mdsh
`$ sed -ie "/hello/d" shell.nix`

`$ lorri watch --once`

-->

After saving, `lorri` re-builds the file, notifies `direnv`,
which reloads your environment after you hit enter to update
your prompt. Now you see:

```bash
$ hello
[127] Command not found.
```

<!-- mdsh
`$ direnv exec $PWD hello 2>&1 | grep 'executable file not found in $PATH'`
```
[31mdirenv: error executable file not found in $PATH[0m
```
-->

Wonderful!


## Set up `direnv` in Emacs with `direnv-mode`

`lorri` uses `direnv`, because `direnv` has dozens of integrations for
editors, shells and the like . Basically everywhere you want to change
an environment on the fly, you can use `direnv`.

In particular, there is integration for the Emacs editor,
[`emacs-direnv`](https://github.com/wbolster/emacs-direnv).

Follow [the `emacs-direnv` setup
guide](https://github.com/wbolster/emacs-direnv/blob/master/README.rst)
now.

Note: There are direnv plugins for _many_ editors. Just a few,
[vscode](https://github.com/direnv/direnv/wiki/VSCode),
[Sublime](https://github.com/zchee/sublime-direnv),
[vim](https://github.com/direnv/direnv.vim),
[Atom](https://atom.io/packages/000-project-shell-env).


Once you have it installed, hit `M-x` and enter `direnv-mode`.
This activates direnv integration for every buffer.

Use the the Emacs file browser to navigate to `lorri/example` and open
`shell.nix`. If everything went fine, you should see the same list
of environment variables in your Emacs status line that you previously
saw in your shell.
Congratulations, you have working `direnv` integration in your editor,
and therefore also working `lorri` integration.

`direnv-mode` updates your environment every time you enter a buffer
that is in a project with a different `.envrc` file. To manually
apply changes, hit `M-x` and enter `direnv-update-environment`.

Try playing around with the `shell.nix` file, removing and adding
things. For example, add an environment variable:

```nix
with import ../nix/nixpkgs.nix;
mkShell {
  buildInputs = [];

  MYVARIABLE = "hi";
}
```

Wait until the evaluation finishes and refresh your direnv environment
(`M-x direnv-update-environment`). Your status line shows that
`MYVARIABLE` was added to the environment.
Comment out `MYVARIABLE` and refresh, it is removed from the
environment again.
