[English](README.md) | 日本語

# Keroway Tap

[![brew test-bot](https://github.com/keroway/homebrew-tap/actions/workflows/tests.yml/badge.svg)](https://github.com/keroway/homebrew-tap/actions/workflows/tests.yml)
[![tdsl release](https://img.shields.io/github/v/release/keroway/timeline-dsl?label=tdsl)](https://github.com/keroway/timeline-dsl/releases)
[![License: BSD-2-Clause](https://img.shields.io/badge/License-BSD--2--Clause-blue.svg)](LICENSE)

[keroway](https://github.com/keroway) 製ツールを配布する [Homebrew](https://brew.sh) tap です。

## 概要

keroway のツールのバイナリ配布を Homebrew 経由で行います。

| プラットフォーム | 対応 |
|----------|---------|
| macOS | Apple Silicon (arm64) / Intel (x86_64) |
| Linux | ARM64 / x86_64 |

> [!NOTE]
> CI (`tests.yml`) は現状、Linux 用 formula のビルド/テストを `ubuntu-latest` (x86_64) でのみ実行しています。
> Linux ARM64 の bottle は公開していますが CI では検証していません。

## Formulae

| Formula | Upstream | 説明 |
|---------|----------|------|
| [tdsl](Formula/tdsl.rb) | [keroway/timeline-dsl](https://github.com/keroway/timeline-dsl) | Timeline DSL コンパイラ — テキストでタイムラインを記述、Wikidata からのインポートに対応 |

## インストール

直接インストール:

```sh
brew install keroway/tap/tdsl
```

または tap してからインストール:

```sh
brew tap keroway/tap
brew install tdsl
```

`brew bundle` を使う場合は `Brewfile` に以下を記述:

```ruby
tap "keroway/tap"
brew "tdsl"
```

## クイックスタート: tdsl

`tdsl` はテキストで書いた `.tdsl` ソースをインタラクティブな HTML/SVG タイムラインへコンパイルします。
Wikidata 連携によるインポートにも対応しています。インストール後すぐに試せます:

```sh
tdsl init -o my-timeline.tdsl               # 最小テンプレートを生成
tdsl render my-timeline.tdsl -o out.html    # スタンドアロン HTML タイムラインへレンダリング
```

最小の `.tdsl` ソース例:

```tdsl
timeline "test" {
  unit year;
  range 1..100;
}
lane "main" as main { kind dynasty; order 1; }
span main 10..50 "test span" {};
```

主要なサブコマンド（全 20 個弱の一覧は `tdsl help` を参照）:

| コマンド | 用途 |
|---------|------|
| `build` / `check` | IR JSON へのコンパイル / 構文・意味の検証 |
| `render` | `.tdsl` ファイルをスタンドアロン HTML タイムラインへレンダリング |
| `fmt` / `lint` | 正規フォーマット / 安全な自動修正付きの lint |
| `scaffold` | Wikidata エンティティから `.tdsl` テンプレートを生成 |
| `import-csv` / `export-csv` | CSV とのラウンドトリップ |
| `lsp` | stdio 上で Language Server Protocol サーバを起動 |
| `completions` | シェル補完スクリプトを生成 |

コマンド全体のリファレンスと DSL 文法: <https://keroway.github.io/timeline-dsl/>

## シェル補完

`tdsl` の bash / zsh / fish 補完はインストール時に自動生成され、Homebrew の補完セットアップに
組み込まれます — zsh/fish は追加設定不要です。手動生成したい場合（Homebrew が自動配線しない
シェル向けなど）は `tdsl completions <shell>` を実行してください。

## アップデート

```sh
brew update
brew upgrade tdsl
```

## アンインストール

```sh
brew uninstall tdsl
brew untap keroway/tap
```

## トラブルシューティング

- **`brew tap keroway/tap` が失敗する / "repository not found"** — 本 tap は public を維持しています。
  もしアクセスできない状態を見かけたら、権限の問題ではなく GitHub 側の一時的な障害である可能性が高いです。
- **インストールはできたがバイナリが古く見える** — bottle は PR が `pr-pull` でマージされたときにのみ
  添付されます。`brew update && brew upgrade tdsl` で最新を取得してください。
- **formula 変更後に何かおかしい** — `brew untap keroway/tap` でリセットし、
  `brew tap keroway/tap && brew install tdsl` でやり直してください。

## Issue の報告先

- **Formula 関連の問題** (インストール失敗 / ビルドエラー / bottle 不整合 / formula 構文): 本リポジトリの Issues へ — <https://github.com/keroway/homebrew-tap/issues>
- **ツール本体の不具合や機能要望** (バイナリの挙動): 各 upstream リポジトリへ。`tdsl` の場合は <https://github.com/keroway/timeline-dsl/issues>
- **脆弱性の報告**: [SECURITY.md](SECURITY.md) を参照してください — 公開 Issue は使わないでください

## コントリビュート

Pull Request を歓迎します。`just --list` でローカルタスク一覧（`build` / `test` / `lint` /
`format` / `check`）が確認できます。PR を出す前に以下を実行してください:

```sh
just check
# = brew test-bot --only-tap-syntax + brew style Formula/*.rb
```

lefthook が `pre-commit` で `brew style`、`pre-push` で `brew audit --strict` を自動実行するため、
push する前にほとんどのスタイル/audit 上の問題が検出されます。

formula の build/test 自体はローカルではなく Pull Request の CI が実行します。
バージョンアップの典型的なフロー:

1. 新リリースの SHA256 を取得: `curl -sL <アセット URL> | shasum -a 256`
2. formula の `url` / `sha256` を更新（対象アセット一覧は `CLAUDE.md` を参照）
3. PR を作成 — `brew test-bot` が通ったら、メンテナが `pr-pull` ラベルを付与し bottle 添付とマージが行われます

### CI ワークフロー

| ワークフロー | トリガー | 内容 |
|--------------|----------|------|
| [`tests.yml`](.github/workflows/tests.yml) (`brew test-bot`) | `main` への push / Pull Request | macOS (Apple Silicon / Intel) と Linux (x86_64) での tap 構文チェック、および Pull Request 時の formula ビルドテスト |
| [`publish.yml`](.github/workflows/publish.yml) (`brew pr-pull`) | Pull Request への `pr-pull` ラベル付与 | `brew test-bot` がビルドした bottle を取り込んで `main` に push し、ブランチを削除 |
| [`gitleaks.yml`](.github/workflows/gitleaks.yml) (`secret-scan`) | `main` への push / Pull Request / 週次スケジュール / 手動実行 | [`keroway/.github`](https://github.com/keroway/.github) の共通 reusable workflow によるシークレットスキャン |
| [`osv-scan.yml`](.github/workflows/osv-scan.yml) (`osv-scan`) | `main` への push / 週次スケジュール / 手動実行 | [`keroway/.github`](https://github.com/keroway/.github) の共通 reusable workflow による OSV 脆弱性スキャン |
| [`workflow-lint.yml`](.github/workflows/workflow-lint.yml) (`workflow-lint`) | `main` への push / `.github/workflows/**`・`**/*.sh` を変更する Pull Request / 手動実行 | [`keroway/.github`](https://github.com/keroway/.github) の共通 reusable workflow によるワークフロー/スクリプト lint |

## ドキュメント

`brew help` / `man brew` / [Homebrew 公式ドキュメント](https://docs.brew.sh) を参照してください。

## ライセンス

この tap (リポジトリ内の Formula ソース) は Homebrew の慣習に従い [BSD 2-Clause License](LICENSE) で公開しています。

各 formula がインストールするツールは、それぞれ独自のライセンスに従います (例: `tdsl` は upstream で MIT License として配布されています)。
