## 概要

<!-- この PR で何を・なぜ変えるのかを簡潔に。 -->

## 変更内容

-

## 関連 Issue

<!-- Closes #123 / Refs #123 -->

## バージョン / SHA256 確認（formula bump 時）

<!--
formula のバージョンを上げた場合のみ記入。それ以外の PR はこのセクションを削除してください。
-->

- [ ] `version` を更新した
- [ ] `tdsl-macos-aarch64.tar.gz` の SHA256 を更新した（`on_macos` / arm64）
- [ ] `tdsl-macos-x86_64.tar.gz` の SHA256 を更新した（`on_macos` / x86_64）
- [ ] `tdsl-linux-aarch64.tar.gz` の SHA256 を更新した（`on_linux` / arm64）
- [ ] `tdsl-linux-x86_64.tar.gz` の SHA256 を更新した（`on_linux` / x86_64）

## 検証

- [ ] `brew install --build-from-source Formula/tdsl.rb`
- [ ] `brew test Formula/tdsl.rb`
<!-- brew audit --strict Formula/tdsl.rb は現行 Homebrew では path 形式が無効化されており実行できない。
     formula の audit/build/test の正しさは `brew test-bot` CI (tests.yml) に委ねる。 -->
- [ ] `brew test-bot` CI 通過
