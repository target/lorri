# How to start the lorri daemon as a service

This guide shows you how to run `lorri daemon` as a service.

If you are using NixOS or `home-manager` on Linux with a Nixpkgs channel at
least as recent as `nixos-19.09`, you have it easy: see [Setup on NixOS or with
`home-manager` on Linux][setup-nixos-or-home-manager]. Otherwise, read on.

The exact steps depend on your operating system and general setup. Currently,
we have instructions for these setups:

- [Run `lorri daemon` on Linux with just
  systemd](#run-lorri-daemon-on-linux-with-just-systemd)
- [Run `lorri daemon` on macOS with
  Nix](#run-lorri-daemon-on-macOS-with-nix)

## Run `lorri daemon` on Linux with just systemd

Here we'll set up a [systemd] socket and service file manually.

<details>
<summary>What's the purpose of the systemd socket? How does systemd know when
to start the daemon "on demand"?</summary>
<p>lorri clients, like the `direnv` integration, talk to the daemon via a Unix
socket at a well-known location. [`lorri.socket`] tells systemd to start the
systemd service defined in [`lorri.service`] the first time a client attempts
to connect to this socket.</p>
</details>

If your `lorri` binary is not in `~/.nix-profile/bin/lorri`, please change the
`ExecStart=` setting in `lorri.service` to the correct location.

Install [`lorri.socket`] and [`lorri.service`] and make systemd listen on the
daemon socket:

```shell
wget -P "${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user" \
    https://raw.githubusercontent.com/target/lorri/master/contrib/lorri.service \
    https://raw.githubusercontent.com/target/lorri/master/contrib/lorri.socket && \
    systemctl --user daemon-reload && \
    systemctl --user enable --now lorri.socket
```

The lorri daemon will now be started on demand by systemd. See [Verify the
setup](#verify-the-setup) to check that everything works as expected.

## Run `lorri daemon` on macOS with Nix (using [nix-darwin](https://github.com/LnL7/nix-darwin))

The following user contributions should help you get started:
- [@jkachmar]'s [suggested `darwin-configuration.nix`](https://github.com/target/lorri/issues/96#issuecomment-579931485)
- [@pawlowskialex]'s [suggested `darwin-configuration.nix`](https://github.com/target/lorri/issues/96#issuecomment-545152525)

## Verify the setup

In this section, we'll see how to check that the `lorri daemon` setup actually
works as intended.

### systemd

On a systemd-based system, you should get the following:

```console
$ systemctl --user is-enabled lorri.socket
enabled
$ systemctl --user is-active lorri.socket
active
```

### launchd

On macOS, use this command to check the status of the lorri daemon:

```console
$ launchctl list | grep lorri
```

[`lorri.socket`]: ./lorri.socket
[`lorri.service`]: ./lorri.service
[@jkachmar]: https://github.com/jkachmar
[@pawlowskialex]: https://github.com/pawlowskialex
[setup-nixos-or-home-manager]: ../README.md#setup-on-nixos-or-with-home-manager-on-linux
[systemd]: https://www.freedesktop.org/wiki/Software/systemd/
