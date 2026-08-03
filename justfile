# keroway 標準 justfile（Homebrew tap 向け。中身は brew CLI への薄い委譲）。

default:
    @just --list

build:
    for f in Formula/*.rb; do brew install --build-from-source "$f"; done

test:
    for f in Formula/*.rb; do brew test "$f"; done

lint:
    brew style Formula/*.rb

format:
    brew style --fix Formula/*.rb

# tap syntax / style をまとめて実行（PR 前の全通し確認）
check:
    brew test-bot --only-tap-syntax
    brew style Formula/*.rb
