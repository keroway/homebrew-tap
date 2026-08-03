English | [日本語](README.ja.md)

# Keroway Tap

A [Homebrew](https://brew.sh) tap for tools published by [keroway](https://github.com/keroway).

## Overview

This tap distributes binaries built from keroway's tools. Supported platforms:

- macOS (Apple Silicon / Intel)
- Linux (ARM64 / x86_64)

## Formulae

| Formula | Upstream | Description |
|---------|----------|-------------|
| [tdsl](Formula/tdsl.rb) | [keroway/timeline-dsl](https://github.com/keroway/timeline-dsl) | Timeline DSL compiler — text-based timelines with Wikidata import |

## Installation

Install directly:

```sh
brew install keroway/tap/tdsl
```

Or tap first, then install:

```sh
brew tap keroway/tap
brew install tdsl
```

Or, in a `brew bundle` `Brewfile`:

```ruby
tap "keroway/tap"
brew "tdsl"
```

## Updating

```sh
brew update
brew upgrade tdsl
```

## Uninstalling

```sh
brew uninstall tdsl
brew untap keroway/tap
```

## Reporting issues

- **Formula problems** (install / build / bottle / formula syntax): open an issue in this repository — <https://github.com/keroway/homebrew-tap/issues>
- **Tool bugs or feature requests** (the actual binary behavior): file them in the upstream repository, e.g. <https://github.com/keroway/timeline-dsl/issues> for `tdsl`

## Contributing

Pull requests are welcome — typical flow for bumping a formula:

```sh
brew test-bot --only-tap-syntax
# Formula build/test runs in pull request CI.
```

Once CI (`brew test-bot`) is green, a maintainer applies the `pr-pull` label to attach bottles and merge.

### CI workflows

| Workflow | Trigger | What it does |
|----------|---------|--------------|
| [`tests.yml`](.github/workflows/tests.yml) (`brew test-bot`) | push to `main`, pull request | Tap syntax check on macOS (Apple Silicon / Intel) and Linux, plus a formula build test on pull requests |
| [`publish.yml`](.github/workflows/publish.yml) (`brew pr-pull`) | `pr-pull` label applied to a pull request | Pulls the bottles built by `brew test-bot`, pushes them to `main`, and deletes the branch |
| [`gitleaks.yml`](.github/workflows/gitleaks.yml) (`secret-scan`) | push to `main`, pull request, weekly schedule, manual dispatch | Secret scan via the shared reusable workflow in [`keroway/.github`](https://github.com/keroway/.github) |

## Documentation

`brew help`, `man brew`, or the [Homebrew documentation](https://docs.brew.sh).

## License

The tap itself (Formula sources in this repository) is released under the [BSD 2-Clause License](LICENSE), following Homebrew's convention.

Each formula installs an upstream tool with its own license — for example, `tdsl` is distributed under the MIT License by its upstream project.
