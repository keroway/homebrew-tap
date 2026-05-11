# Homebrew Tap — keroway/tap

このリポジトリは [keroway](https://github.com/keroway) 製ツールの Homebrew tap です。

## リポジトリ構造

```
Formula/        # formula ファイル (.rb)
.github/
  workflows/
    brew-pr-pull.yml   # ボトルのマージ用ワークフロー
    brew-test-bot.yml  # CI (syntax check + build test)
  dependabot.yml       # GitHub Actions の自動バージョン更新
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
- `tdsl-linux-x86_64.tar.gz`

### 2. formula の編集

`Formula/tdsl.rb` の以下を更新:

- `version` — 新バージョン番号
- トップレベル `url` / `sha256` — Linux x86_64 用
- `on_macos` ブロック内の各 `sha256` — macOS arm64 / x86_64 用

### 3. 動作確認

```sh
brew install --build-from-source Formula/tdsl.rb
brew test Formula/tdsl.rb
brew audit --strict Formula/tdsl.rb
```

### 4. PR 作成 → マージ

CI (`brew test-bot`) が通れば `pr-pull` ラベルを付けてマージ。

## 注意事項

- `on_linux > on_arm` ブロックで ARM64 Linux を `disable!` している（バイナリ未提供のため）
- `brew readall --os=all --arch=all` を通すため、トップレベルにも Linux x86_64 の `url`/`sha256` が必要
- このリポジトリは **public 必須**（`brew tap` はパブリックリポジトリのみ対応）
