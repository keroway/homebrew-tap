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

`tdsl` の bash / zsh / fish 補完はインストール時に自動生成されます。ただし Homebrew は既定では
外部 tap の補完を自動リンクしないため、有効化するには一度だけ以下を実行してください:

```sh
brew completions link
```

そのうえで、各シェルが Homebrew の補完を読み込むようにします:

- **zsh**: `.zshrc` の `compinit` より前に `FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"` を追加
- **bash**: `brew install bash-completion` を入れ、[Homebrew のドキュメント](https://docs.brew.sh/Shell-Completion)に従って読み込む
- **fish**: 追加設定不要 — fish は `$(brew --prefix)/share/fish/vendor_completions.d` を自動的に読み込みます

補完スクリプトを手動生成したい場合（Homebrew が自動配線しないシェル向けなど）は
`tdsl completions <shell>` を実行してください。

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
- **インストールはできたがバイナリが古く見える** — `brew update && brew upgrade tdsl` で
  最新を取得してください。この tap は bottle ではなくビルド済みバイナリの tarball を配布するため、
  formula の `url` がバージョンの唯一の出所です。
- **formula 変更後に何かおかしい** — `brew untap keroway/tap` でリセットし、
  `brew tap keroway/tap && brew install tdsl` でやり直してください。

## Issue の報告先

- **Formula 関連の問題** (インストール失敗 / ビルドエラー / formula 構文): 本リポジトリの Issues へ — <https://github.com/keroway/homebrew-tap/issues>
- **ツール本体の不具合や機能要望** (バイナリの挙動): 各 upstream リポジトリへ。`tdsl` の場合は <https://github.com/keroway/timeline-dsl/issues>
- **脆弱性の報告**: [SECURITY.md](SECURITY.md) を参照してください — 公開 Issue は使わないでください

## コントリビュート

Pull Request を歓迎します。`just --list` でローカルタスク一覧（`build` / `test` / `lint` /
`format` / `check`）が確認できます。PR を出す前に以下を実行してください:

```sh
just check
# = brew test-bot --only-tap-syntax + brew style Formula/*.rb
```

lefthook が `pre-commit` で `brew style`、`pre-push` で `brew test-bot --only-tap-syntax` を
自動実行するため、push する前にほとんどのスタイル/構文上の問題が検出されます
（`brew audit --strict Formula/*.rb` は現行 Homebrew では使えません: path 形式の
`brew audit` は無効化されており、name 形式は `/opt/homebrew/Library/Taps/` 配下の
タップ済みクローンを検査するため、作業ツリーの未コミット変更は検証できません）。
formula の build/test の正しさは CI（`tests.yml` の `brew test-bot --only-formulae`、
PR 時のみ）が検証します。

formula の build/test 自体はローカルではなく Pull Request の CI が実行します。
バージョンアップの典型的なフロー:

1. 新リリースの SHA256 を取得: `curl -fsSL <アセット URL> -o <アセットファイル> && shasum -a 256 <アセットファイル>`
2. formula の `url` / `sha256` を更新（対象アセット一覧は `CLAUDE.md` を参照）
3. PR を作成 — `brew test-bot` が通ったらマージします（bottle の手順はありません。下の注記を参照）

### CI ワークフロー

> **bottle は使いません。** この tap が配るのはビルド済みバイナリの tarball で、
> `install` は実質 `bin.install "tdsl"` だけです。bottle が節約するのは
> 「すでにビルド済みのアーカイブを展開する手間」だけなので利得が小さく、
> `brew tap-new` の雛形由来の `brew pr-pull` 公開ワークフローは #37 で削除しました
> （発火条件の `pr-pull` ラベルがこのリポジトリに存在せず、一度も動いていなかった）。
> `brew test-bot --only-formulae` は残しています — formula を実際に install して
> `test do` を走らせる唯一のステップだからです。


| ワークフロー | トリガー | 内容 |
|--------------|----------|------|
| [`tests.yml`](.github/workflows/tests.yml) (`brew test-bot`) | `main` への push / Pull Request | macOS (Apple Silicon / Intel) と Linux (x86_64) での tap 構文チェック、および Pull Request 時の formula ビルドテスト |
| [`gitleaks.yml`](.github/workflows/gitleaks.yml) (`secret-scan`) | `main` への push / Pull Request / 週次スケジュール / 手動実行 | [`keroway/.github`](https://github.com/keroway/.github) の共通 reusable workflow によるシークレットスキャン |
| [`osv-scan.yml`](.github/workflows/osv-scan.yml) (`osv-scan`) | `main` への push / 週次スケジュール / 手動実行 | [`keroway/.github`](https://github.com/keroway/.github) の共通 reusable workflow による OSV 脆弱性スキャン |
| [`workflow-lint.yml`](.github/workflows/workflow-lint.yml) (`workflow-lint`) | `main` への push / `.github/workflows/**`・`**/*.sh` を変更する Pull Request / 手動実行 | [`keroway/.github`](https://github.com/keroway/.github) の共通 reusable workflow によるワークフロー/スクリプト lint |

## ドキュメント

`brew help` / `man brew` / [Homebrew 公式ドキュメント](https://docs.brew.sh) を参照してください。

## ライセンス

この tap (リポジトリ内の Formula ソース) は Homebrew の慣習に従い [BSD 2-Clause License](LICENSE) で公開しています。

各 formula がインストールするツールは、それぞれ独自のライセンスに従います (例: `tdsl` は upstream で MIT License として配布されています)。
