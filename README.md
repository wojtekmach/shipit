# PublishPlus

PublishPlus is an opinionated package publisher for Elixir.

It assumes the following:

- as usual, packages are published to Hex.pm and docs to HexDocs.pm
- for each release, a tag is created and pushed to git
- CHANGELOG.md is present and updated with the release
- LICENSE.md is present

## Installation

On Elixir v1.4+:

    $ mix archive.install github wojtekmach/publish_plus

On Elixir v1.3:

    $ curl -L -O https://github.com/wojtekmach/publish_plus/releases/download/v0.1.0/publish_plus-0.1.0.ez
    $ mix archive.install publish_plus-0.1.0.ez
    $ mix help publish_plus

## License

PublishPlus is released under the MIT license, see [LICENSE.md](LICENSE.md).
