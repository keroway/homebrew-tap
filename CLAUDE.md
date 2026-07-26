# Homebrew Tap — keroway/tap

このリポジトリは [keroway](https://github.com/keroway) 製ツールの Homebrew tap です。

## リポジトリ構造

```
Formula/                     # formula ファイル (.rb)
.github/
  workflows/
    tests.yml                # CI (brew test-bot — tap syntax check + build test)
    publish.yml              # brew pr-pull (pr-pull ラベルで bottle 添付 → main へ push)
    gitleaks.yml             # シークレットスキャン (keroway/.github の reusable workflow を呼び出す)
  dependabot.yml             # GitHub Actions の自動バージョン更新
  pull_request_template.md   # PR テンプレート
README.md                    # README (英語版)
README.ja.md                 # README (日本語版)
SECURITY.md                  # 脆弱性の報告手順
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

- `version` — 新バージョン番号
- `on_macos` ブロック内の各 `url` / `sha256` — macOS arm64 / x86_64 用
- `on_linux` ブロック内の各 `url` / `sha256` — Linux arm64 / x86_64 用

### 3. 動作確認

```sh
brew install --build-from-source Formula/tdsl.rb
brew test Formula/tdsl.rb
brew audit --strict Formula/tdsl.rb
```

### 4. PR 作成 → マージ

CI (`brew test-bot`) が通れば `pr-pull` ラベルを付けてマージ。

## 注意事項

- `on_macos` / `on_linux` それぞれの block 内で arm64 / x86_64 両方に実バイナリの `url`/`sha256` を
  用意しており、`brew readall --os=all --arch=all` の対象マトリクスを全てカバーしているため、
  トップレベルの `url`/`sha256` は不要
- このリポジトリは **public 必須**（`brew tap` はパブリックリポジトリのみ対応）
