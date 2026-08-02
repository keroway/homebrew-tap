# homebrew-tap — Claude Code Setup

このディレクトリは Claude Code の共有設定です。リポジトリルートの
`CLAUDE.md` と一緒に読んでください。Codex / pi では、共通指示を `AGENTS.md` に置き、
各ハーネス固有の設定・hook は対応する公式ドキュメントに読み替えます。

## 構成

```
.claude/
├── hooks/
│   └── post-stop-check.sh     # Stop: 変更範囲に応じた決定的検証
├── settings.json              # 共有設定（コミット対象）
├── settings.local.json        # 個人設定（.gitignore で除外）
└── README.md                  # この設定の説明書
```

`PostToolUse`（保存直後の自動整形）は意図的に置いていない。本リポジトリの整形手段
`brew style --fix` は 1 ファイルあたり実測 ~4s あり、PostToolUse の予算（~1s）を
大きく超えるため。整形は Stop hook の `brew style`（差分検出のみ、`--fix` はしない）
と、手動の `just format` に任せる。

## 依存ツール

| ツール | 用途 | 必須？ |
|---|---|---|
| `brew` | `Formula/*.rb` 変更時の `brew style` | 必須（Stop hook は無ければ exit 2） |
| `shellcheck` | `*.sh` 変更時の静的解析 | 条件付き必須（該当変更があれば exit 2） |
| `actionlint` | `.github/workflows/*.yml` 変更時の静的解析 | 条件付き必須（該当変更があれば exit 2） |
| `jq` | hook payload の JSON 抽出 | 任意（フォールバックあり） |

## Hooks の挙動 `[Claude Code]`

### Stop: `post-stop-check.sh`

- 発火条件: Claude Code の応答完了時（変更がなければ即終了）
- 動作: uncommitted / untracked / unpushed の変更を分類し、変更領域に応じて
  以下だけを実行する:
  - `Formula/*.rb` → `brew style Formula/*.rb`
  - `*.sh`（変更ファイルのみ） → `shellcheck`
  - `.github/workflows/*.yml`（変更ファイルのみ） → `actionlint`
- 失敗時: exit 2。ツール不在など「検証できない」場合も silent-pass しない
- 一時的に止めたい場合: `TAP_SKIP_STOP_HOOK=1`

### exit code の意味論

- `0`: チェック対象なし、またはチェック通過
- `2`: チェック失敗（または前提コマンド不在など）。**ブロッキング** —
  stderr の内容が Claude にそのままフィードバックされ、修正を促す
- `1`（非ブロッキング）は本リポジトリでは使わない。すべての対象変更は
  エージェントが自力で直せる種類の誤り（style / shellcheck / actionlint）のため

## 意図的に hook に含めないもの

- **`brew audit` / `brew audit --strict`**: 現行 Homebrew では `brew audit [path]`
  形式が廃止されており（`Error: Calling brew audit [path ...] is disabled!`）、
  名前解決形式（`brew audit keroway/tap/tdsl`）は `/opt/homebrew/Library/Taps/`
  配下にタップされた**別クローン**を検査するため、作業ツリーの未コミット変更を
  検証できない。CI（`tests.yml` の `brew test-bot --only-formulae`、PR 時のみ）に委ねる。
  `justfile check` / `lefthook.yml` の pre-push はこの問題を抱えたままで、
  別 issue で追跡する。
- **`brew test` / `brew install --build-from-source`**: ネットワーク・ビルド時間が
  Stop hook の予算（~10-60s）を超える。CI に委ねる。
- **`typos`**: Formula 内のパッケージ名・URL 等で誤検出しやすく、blocking にすると
  毎ターン偽陽性で止まる。必要なときに手動で実行する。
- **`zizmor`**: ローカル未導入。CI（`workflow-lint.yml` → `reusable-workflow-lint`）
  で担保する。

この一覧は「後から統一されて劣化する」事故を防ぐための記録なので、
チェックを追加/削除する際はここも更新すること。

## タイムアウト

`settings.json` 側のタイムアウトは 60 秒。`brew style` は初回に Homebrew の
bundler gem 解決が走ると数十秒かかることがあるため、ワークスペース標準の
軽量リポジトリ目安（30秒）よりやや緩めている（warm 時は実測 ~4s）。

## 一時的に無効化したい場合

環境変数 `TAP_SKIP_STOP_HOOK=1` を設定すると、hook はチェックを行わず exit 0 で
終了する。恒常的な無効化ではなく、一時的なデバッグ用途に限定すること。

## 他環境への移植

- hook は `#!/usr/bin/env bash` を使う
- 絶対パスは `$CLAUDE_PROJECT_DIR` または `git rev-parse --show-toplevel` で解決する
- `settings.local.json`、作業メモ、worktree は `.gitignore` で除外する

新しい開発者がクローン後に必要な追加手順: なし。
