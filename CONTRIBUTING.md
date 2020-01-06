# Contributing to lorri

Contributions to this project are welcome.  If you'd like to
contribute, raise an issue, or propose a new feature, please follow
the procedures outlined below.

## Raising issues

If you would like to fix a bug or request a bug fix, please [raise an
issue](https://github.com/target/lorri/issues) so the issue can be documented
and discussed.

## How to contribute

1. [Fork][gh-about-forks] the project and make your changes in a branch.
2. Open and submit a [pull request][gh-create-pr].

Whether you're fixing a bug or adding a feature, we recommend you use the
development environment defined in `shell.nix`. You can do this using
`nix-shell` or by using lorri itself (yes, we use lorri to develop lorri!).

Amongst other things, the environment gives you the `ci` command which runs the
continuous integration build and test suite locally. If this passes, you can be
pretty confident that your pull request will pass Travis too.

## Making a contribution

Open up a request as early as you want. Consider opening it as a ["draft" pull
request][gh-draft-pr] to indicate that it is work in progress. We can work
together to make your pull request complete.

A complete pull request will:

 - Have new or updated documentation
 - Have tests
 - Pass the `ci` script available in the project's `nix-shell` environment
   This script runs `cargo test`, `cargo fmt --check` and `cargo clippy`,
   amongst other checks.
 - Have nice commit messages

Instead of writing a beautiful Pull Request message, write the
important parts in the commit messages themselves. This makes it much
easier to open up a request: just copy and paste the nice commit
messages into the pull request.

## Guidelines

1. Be respectful.  All contributions to lorri are appreciated and we
   ask that you respect one another.
2. Be responsible. You are responsible for your pull request
   submission.
3. Give credit.  Any submissions or contributions built on other work
   (including and not limited to research papers, open source
   projects, and public code) must be cited or attached with
   information about the original source or work.  People should be
   credited for the work they have done.

Please see our [Code of Conduct](./.github/CODE_OF_CONDUCT.md).

[gh-about-forks]: https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/about-forks
[gh-create-pr]: https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork
[gh-draft-pr]: https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-requests#draft-pull-requests
