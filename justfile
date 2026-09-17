# keroway 標準 justfile（Homebrew tap 向け。中身は brew CLI への薄い委譲）。

default:
    @just --list

# build/test はここでは提供しない: `brew install`/`brew test` は path 形式の
# formula (`Formula/*.rb`) を「tap 未登録」として拒否するため、作業ツリーの
# 未コミット変更を検証できない。formula の build/test 検証は CI
# (`tests.yml` の `brew test-bot --only-formulae`, pull request・main への push・
# 週次 schedule で実行) に委ねる。作業ツリーでは実行しない。

lint:
    brew style Formula/*.rb

format:
    brew style --fix Formula/*.rb

# tap syntax / style をまとめて実行（PR 前の全通し確認）
# brew test-bot は cwd に steps_output.txt を書き出す (#108)。CI は
# actions/checkout が無く cwd が空の runner workspace のため無害だが、
# ここでは cwd がリポジトリ直下になるため作業ツリーへ残留する。
# 一時ディレクトリに退避して実行する。
check:
    tmp_dir=$(mktemp -d); (cd "$tmp_dir" && brew test-bot --only-tap-syntax); status=$?; rm -rf "$tmp_dir"; exit $status
    brew style Formula/*.rb
