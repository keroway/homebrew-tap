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
- [ ] `tdsl-macos-aarch64.tar.gz` の SHA256 を更新した
- [ ] `tdsl-macos-x86_64.tar.gz` の SHA256 を更新した
- [ ] `tdsl-linux-x86_64.tar.gz` の SHA256 を更新した（トップレベル `url`/`sha256`）

## 検証

- [ ] `brew install --build-from-source Formula/tdsl.rb`
- [ ] `brew test Formula/tdsl.rb`
- [ ] `brew audit --strict Formula/tdsl.rb`
- [ ] `brew test-bot` CI 通過
