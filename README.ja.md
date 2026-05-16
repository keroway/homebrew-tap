[English](README.md) | 日本語

# Keroway Tap

[keroway](https://github.com/keroway) 製ツールを配布する [Homebrew](https://brew.sh) tap です。

## 概要

keroway のツールのバイナリ配布を Homebrew 経由で行います。対応プラットフォーム:

- macOS (Apple Silicon / Intel)
- Linux x86_64

> ARM64 Linux は **未対応** です (upstream でバイナリが提供されていないため)。

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

## Issue の報告先

- **Formula 関連の問題** (インストール失敗 / ビルドエラー / bottle 不整合 / formula 構文): 本リポジトリの Issues へ — <https://github.com/keroway/homebrew-tap/issues>
- **ツール本体の不具合や機能要望** (バイナリの挙動): 各 upstream リポジトリへ。`tdsl` の場合は <https://github.com/keroway/timeline-dsl/issues>

## コントリビュート

Pull Request を歓迎します。formula のバージョンアップ時の典型的なフロー:

```sh
brew install --build-from-source Formula/<name>.rb
brew test                       Formula/<name>.rb
brew audit --strict             Formula/<name>.rb
```

CI (`brew test-bot`) が通ったあと、メンテナが `pr-pull` ラベルを付与し、bottle 添付とマージが自動実行されます。

## ドキュメント

`brew help` / `man brew` / [Homebrew 公式ドキュメント](https://docs.brew.sh) を参照してください。

## ライセンス

この tap (リポジトリ内の Formula ソース) は Homebrew の慣習に従い [BSD 2-Clause License](LICENSE) で公開しています。

各 formula がインストールするツールは、それぞれ独自のライセンスに従います (例: `tdsl` は upstream で MIT License として配布されています)。
