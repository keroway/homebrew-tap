English | [日本語](README.ja.md)

# Keroway Tap

[![brew test-bot](https://github.com/keroway/homebrew-tap/actions/workflows/tests.yml/badge.svg)](https://github.com/keroway/homebrew-tap/actions/workflows/tests.yml)
[![tdsl release](https://img.shields.io/github/v/release/keroway/timeline-dsl?label=tdsl)](https://github.com/keroway/timeline-dsl/releases)
[![License: BSD-2-Clause](https://img.shields.io/badge/License-BSD--2--Clause-blue.svg)](LICENSE)

A [Homebrew](https://brew.sh) tap for tools published by [keroway](https://github.com/keroway).

## Overview

This tap distributes binaries built from keroway's tools.

| Platform | Support |
|----------|---------|
| macOS | Apple Silicon (arm64) / Intel (x86_64) |
| Linux | ARM64 / x86_64 |

> [!NOTE]
> CI (`tests.yml`) currently builds and tests Linux formulae on `ubuntu-latest` (x86_64) only.
> The Linux ARM64 tarball is published in the formula but not exercised by CI.

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

## Quick start: tdsl

`tdsl` compiles a text-based `.tdsl` source into an interactive HTML/SVG timeline, with optional
Wikidata import. Try it right after installing:

```sh
tdsl init -o my-timeline.tdsl               # scaffold a minimal template
tdsl render my-timeline.tdsl -o out.html    # render a standalone HTML timeline
```

A minimal `.tdsl` source looks like this:

```tdsl
timeline "test" {
  unit year;
  range 1..100;
}
lane "main" as main { kind dynasty; order 1; }
span main 10..50 "test span" {};
```

Selected subcommands (run `tdsl help` for the full list of ~20):

| Command | Purpose |
|---------|---------|
| `build` / `check` | Compile to IR JSON / validate syntax and semantics |
| `render` | Render a `.tdsl` file to a standalone HTML timeline |
| `fmt` / `lint` | Canonical formatting / lint with optional safe fixes |
| `scaffold` | Generate a `.tdsl` template from Wikidata entities |
| `import-csv` / `export-csv` | Round-trip timeline items with CSV |
| `lsp` | Start a Language Server Protocol server over stdio |
| `completions` | Generate shell completion scripts |

Full command reference and DSL syntax: <https://keroway.github.io/timeline-dsl/>

## Shell completions

Bash, zsh, and fish completions for `tdsl` are generated automatically at install time. Homebrew
does not auto-link completions from external taps by default, so run this once to enable them:

```sh
brew completions link
```

Then make sure your shell loads Homebrew's completions:

- **zsh**: add `FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"` before `compinit` in your `.zshrc`
- **bash**: `brew install bash-completion` and source it per the [Homebrew docs](https://docs.brew.sh/Shell-Completion)
- **fish**: no extra setup — fish reads `$(brew --prefix)/share/fish/vendor_completions.d` automatically

To generate a completion script manually (e.g. for a shell Homebrew doesn't wire up automatically): `tdsl completions <shell>`.

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

## Troubleshooting

- **`brew tap keroway/tap` fails / "repository not found"** — this tap must stay public; if it
  ever shows as inaccessible, it likely means a transient GitHub outage rather than a permissions
  issue on your side.
- **Installed but the binary looks outdated** — run `brew update && brew upgrade tdsl` to pick up
  the latest. This tap ships prebuilt binary tarballs rather than bottles, so the formula's `url`
  is the only source of truth for the version.
- **Something looks broken after a formula change** — reset with `brew untap keroway/tap` followed
  by a fresh `brew tap keroway/tap && brew install tdsl`.

## Reporting issues

- **Formula problems** (install / build / bottle / formula syntax): open an issue in this repository — <https://github.com/keroway/homebrew-tap/issues>
- **Tool bugs or feature requests** (the actual binary behavior): file them in the upstream repository, e.g. <https://github.com/keroway/timeline-dsl/issues> for `tdsl`
- **Security vulnerabilities**: see [SECURITY.md](SECURITY.md) — do not open a public issue

## Contributing

Pull requests are welcome. `just --list` shows all local tasks (`build` / `test` / `lint` /
`format` / `check`); before opening a PR, run:

```sh
just check
# = brew test-bot --only-tap-syntax + brew style Formula/*.rb
```

lefthook runs `brew style` on `pre-commit` and `brew test-bot --only-tap-syntax` on `pre-push`
automatically, so most style/syntax issues surface before you even push. (`brew audit --strict
Formula/*.rb` is no longer usable here: current Homebrew disables the path form of `brew audit`,
and the name form only inspects the tapped clone under `/opt/homebrew/Library/Taps/`, not your
working tree's uncommitted changes.) Formula build/test correctness is verified by CI
(`brew test-bot --only-formulae` in `tests.yml`, on PRs only).

Formula build/test itself runs in pull request CI, not locally. Typical version-bump flow:

1. Fetch the new release's SHA256s: `curl -fsSL <asset URL> -o <asset file> && shasum -a 256 <asset file>`
2. Update the `url` / `sha256` pairs in the formula (see `CLAUDE.md` for the per-tool asset list)
3. Open a PR — once `brew test-bot` is green, merge it (no bottle step; see the note below)

### CI workflows

> **No bottles.** This tap distributes prebuilt binary tarballs, so `install` is just
> `bin.install "tdsl"` and a bottle would only save unpacking an already-built archive.
> The `brew pr-pull` publishing workflow inherited from the `brew tap-new` template was
> removed in #37 — it had never run (its `pr-pull` label did not exist in this repository)
> and no bottle host was configured. `brew test-bot --only-formulae` is kept because it is
> what actually installs the formula and runs its `test do` block.


| Workflow | Trigger | What it does |
|----------|---------|---------------|
| [`tests.yml`](.github/workflows/tests.yml) (`brew test-bot`) | push to `main`, pull request | Tap syntax check on macOS (Apple Silicon / Intel) and Linux (x86_64), plus a formula build test on pull requests |
| [`gitleaks.yml`](.github/workflows/gitleaks.yml) (`secret-scan`) | push to `main`, pull request, weekly schedule, manual dispatch | Secret scan via the shared reusable workflow in [`keroway/.github`](https://github.com/keroway/.github) |
| [`osv-scan.yml`](.github/workflows/osv-scan.yml) (`osv-scan`) | push to `main`, weekly schedule, manual dispatch | OSV vulnerability scan via the shared reusable workflow in [`keroway/.github`](https://github.com/keroway/.github) |
| [`workflow-lint.yml`](.github/workflows/workflow-lint.yml) (`workflow-lint`) | push to `main`, pull requests touching `.github/workflows/**` or `**/*.sh`, manual dispatch | Workflow/script lint via the shared reusable workflow in [`keroway/.github`](https://github.com/keroway/.github) |

## Documentation

`brew help`, `man brew`, or the [Homebrew documentation](https://docs.brew.sh).

## License

The tap itself (Formula sources in this repository) is released under the [BSD 2-Clause License](LICENSE), following Homebrew's convention.

Each formula installs an upstream tool with its own license — for example, `tdsl` is distributed under the MIT License by its upstream project.
