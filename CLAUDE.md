# Homebrew Tap — keroway/tap

このリポジトリは [keroway](https://github.com/keroway) 製ツールの Homebrew tap です。

## リポジトリ構造

```
Formula/                     # formula ファイル (.rb)
.claude/                     # Claude Code の共有設定 (settings.json, hooks/)
.github/
  workflows/
    tests.yml                # CI (brew test-bot — tap syntax check + build test)
    gitleaks.yml             # シークレットスキャン (keroway/.github の reusable workflow を呼び出す)
    osv-scan.yml             # OSV 脆弱性スキャン (keroway/.github の reusable workflow を呼び出す)
    workflow-lint.yml        # ワークフロー/スクリプト lint (keroway/.github の reusable workflow を呼び出す)
  renovate.json5             # Renovate による依存関係の自動更新設定
  pull_request_template.md   # PR テンプレート
justfile                     # ローカルタスク (lint/format/check) — brew CLI への薄い委譲。formula の build/test は CI が実行
lefthook.yml                 # pre-commit: brew style / pre-push: brew test-bot --only-tap-syntax
README.md                    # README (英語版)
README.ja.md                 # README (日本語版)
SECURITY.md                  # 脆弱性の報告手順 (英語/日本語併記)
CLAUDE.md                    # このファイル (AGENTS.md は CLAUDE.md へのシンボリックリンク)
LICENSE                      # tap 自体のライセンス (BSD 2-Clause)
```

## Formula の更新手順

新バージョンのバイナリをリリースしたあと、以下の手順で formula を更新する。

### 1. SHA256 の取得

```sh
curl -sL <URL> | shasum -a 256
```

対象アーカイブ（例: `tdsl` v1.x.x の場合）:

- `tdsl-macos-aarch64.tar.gz`
- `tdsl-macos-x86_64.tar.gz`
- `tdsl-linux-aarch64.tar.gz`
- `tdsl-linux-x86_64.tar.gz`

### 2. formula の編集

`Formula/tdsl.rb` の以下を更新:

- 各 `url` — 新バージョン番号を含むリリース URL
- `on_macos` ブロック内の各 `url` / `sha256` — macOS arm64 / x86_64 用
- `on_linux` ブロック内の各 `url` / `sha256` — Linux arm64 / x86_64 用

### 3. 動作確認

```sh
just check
# = brew test-bot --only-tap-syntax + brew style Formula/*.rb
# Formula の build / test は pull request・main への push・週次 schedule の CI が実行する。
```

### 4. PR 作成 → マージ

CI (`brew test-bot`) が通ればマージ。

**bottle の手順はない。** この tap はビルド済みバイナリの tarball を配るため bottle の
利得が小さく、雛形由来の `brew pr-pull` 公開ワークフローは #37 で削除した
(`pr-pull` ラベルが存在せず一度も動いていなかった)。

## 注意事項

- `on_macos` / `on_linux` それぞれの block 内で arm64 / x86_64 両方に実バイナリの `url`/`sha256` を
  用意しており、`brew readall --os=all --arch=all` の対象マトリクスを全てカバーしているため、
  トップレベルの `url`/`sha256` は不要
- このリポジトリは **public 必須**（`brew tap` はパブリックリポジトリのみ対応）

## Codex 向け運用ルール

Codex 向けの横断運用ルールは `keroway/CLAUDE.md` ではなく
[agent-assets `docs/codex-common-instructions.md`](https://github.com/keroway/agent-assets/blob/main/docs/codex-common-instructions.md)
を正典とする（Codex は git ルートより上の AGENTS.md を読まないため）。

## Multi-agent claim protocol (all agents, including cloud agents)

Before working on any GitHub issue in this repository:

1. Skip issues that have an assignee, or any of these labels:
   `in-progress` / `needs-refinement` / `blocked` / `needs-human` /
   `needs-triage` / `needs-info`, or an `agent:<other-agent>` label
   (one not matching your own name). Do not comment on or relabel them.
2. To claim an issue: assign yourself, add `in-progress` plus your
   attribution label — `agent:claude`, `agent:codex`, `agent:pi`,
   `agent:goose`, or `agent:dots` for OpenAI cloud agents — and leave a
   comment with your branch name.
3. On finish or abort: remove `in-progress` and your `agent:*` label.
4. Re-check labels, assignee, and open PRs right before opening a PR;
   if another agent claimed the issue meanwhile, withdraw your work.
5. Never touch issues labeled `needs-human`. Never force-push.

Canonical: agent-assets/docs/agents/claim-protocol.md
