# ShipIt

ShipIt automates Hex package publishing to avoid common mistakes.

It automates these steps:

* ensure there are no uncommited changes in the working tree
* ensure current branch matches the given branch
* ensure local branch is in sync with remote branch
* ensure project version in mix.exs matches the given version
* ensure CHANGELOG.md contains an entry for the version
* ensure LICENSE.md file is present
* create a git tag and push it
* publish to Hex.pm and HexDocs.pm

## Usage

    $ mix shipit master 1.0.0

For more information, see:

    $ mix help shipit

## Installation

On Elixir v1.4+:

    $ mix archive.install hex shipit

On Elixir v1.3:

    $ curl -L -O https://github.com/wojtekmach/shipit/releases/download/v0.2.3/shipit-0.2.3.ez
    $ mix archive.install shipit-0.2.3.ez

## License

ShipIt is released under the MIT license, see [LICENSE.md](LICENSE.md).
