# keroway 標準 justfile（Homebrew tap 向け。中身は brew CLI への薄い委譲）。

default:
    @just --list

# build/test はここでは提供しない: `brew install`/`brew test` は path 形式の
# formula (`Formula/*.rb`) を「tap 未登録」として拒否するため、作業ツリーの
# 未コミット変更を検証できない。formula の build/test 検証は CI
# (`tests.yml` の `brew test-bot --only-formulae`, PR 時のみ) に委ねる。

lint:
    brew style Formula/*.rb

format:
    brew style --fix Formula/*.rb

# tap syntax / style をまとめて実行（PR 前の全通し確認）
check:
    brew test-bot --only-tap-syntax
    brew style Formula/*.rb
