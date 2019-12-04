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

Note: If you are developing rust in emacs and would like to use
emacs-racer, you can do so in a lorri direnv by setting
```elisp
    (setq racer-rust-src-path nil) ;; read from shell-nix
    (setq racer-cmd "racer")
```
