#!/usr/bin/env bash
# Stop hook: Claude の応答完了時に、変更された領域だけ決定的チェックを実行する。
#
# 位置づけ:
#   codex stop review gate は本リポジトリでは無効。機械的に判定できる誤りはこの hook が
#   ターン終了ごとに潰し、設計レビューが必要なときだけ /code-review を手動で起動する。
#   lefthook の pre-commit は staged ファイルにしか効かないため、未コミット状態で
#   ターンが終わるケースをここで拾う。
#
# 動作:
#   1. 変更ファイル（uncommitted + untracked + 未 push の commit）を分類する
#   2. Formula/*.rb が変わったら `brew style Formula/*.rb`
#      （CI の brew test-bot --only-tap-syntax に対応する部分集合）
#   3. *.sh が変わったら shellcheck（変更ファイルのみ）
#   4. .github/workflows/*.yml が変わったら actionlint（変更ファイルのみ）
#      （3・4 は CI の workflow-lint / reusable-workflow-lint に対応）
#   5. 失敗時は stderr に内容を出力し exit 2 で Claude にフィードバックする
#   6. 必要なコマンドが見つからないのに対象変更がある場合も FAIL として通知する
#      （silent-pass しない = 「検証できない」を「成功」と扱わない）
#
# 意図的に含めないもの:
#   - brew audit: 現行 Homebrew では `brew audit [path]` 形式が廃止されており、
#     名前解決（`brew audit keroway/tap/tdsl`）は /opt/homebrew/Library/Taps 配下の
#     別クローンを検査するため作業ツリーの未コミット変更を検証できない。
#     CI (`brew test-bot --only-formulae`, PR 時のみ) に委ねる。
#   - brew test / brew install --build-from-source: ネットワーク・ビルド時間が
#     Stop hook の予算 (~10-60s) を超える。
#   - typos / zizmor: typos は Formula 内の意図的な語（パッケージ名等）で誤検出しやすく
#     毎ターン止まるリスクがある。zizmor はローカル未導入。両者とも CI (workflow-lint) で担保。
#   理由は .claude/README.md にも記録している。ここで省いたチェックを後から
#   安易に追加/復元しないこと（README の記述と合わせて更新する）。
#
# 無限ループ防止:
#   stop_hook_active=true の場合（hook 由来の再起動）はスキップ
#
# スキップしたい場合:
#   TAP_SKIP_STOP_HOOK=1 を設定する

set -u

INPUT="$(cat || true)"

if command -v jq >/dev/null 2>&1; then
  STOP_HOOK_ACTIVE="$(printf '%s' "$INPUT" | jq -r '.stop_hook_active // false' 2>/dev/null || echo false)"
else
  # jq 非依存フォールバック: 空白を除いた生 JSON を直接照合する
  # （jq が無い環境ではここで "false" 固定にすると下の無限ループ防止が丸ごと無効になる）。
  COMPACT_INPUT="$(printf '%s' "$INPUT" | tr -d ' \t\n\r')"
  case "$COMPACT_INPUT" in
    *'"stop_hook_active":true'*) STOP_HOOK_ACTIVE="true" ;;
    *) STOP_HOOK_ACTIVE="false" ;;
  esac
fi

if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  exit 0
fi

if [ "${TAP_SKIP_STOP_HOOK:-}" = "1" ]; then
  exit 0
fi

# silent-pass 禁止: cd / git 確認に失敗したら exit 2 で Claude に通知する。
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
if ! cd "$PROJECT_DIR" 2>/dev/null; then
  {
    echo "Stop hook: PROJECT_DIR ($PROJECT_DIR) に cd できません。検証をスキップしました。"
    echo "  CLAUDE_PROJECT_DIR=${CLAUDE_PROJECT_DIR:-(unset)}"
    echo "hook の設定 (.claude/settings.json) と作業ディレクトリを確認してください。"
  } >&2
  exit 2
fi

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  {
    echo "Stop hook: $(pwd) は git リポジトリではありません。変更ファイルを判定できないため検証をスキップしました。"
    echo "（一時的に止めたい場合は環境変数 TAP_SKIP_STOP_HOOK=1）"
  } >&2
  exit 2
fi

# 変更ファイル一覧（unstaged + staged + untracked + 未 push の commit）。
# 未 push 範囲の決め方は上流ブランチ → origin/main → 空、の順に degrade する。
# push 前の新規ブランチでは @{u} が無いため、origin/main からの分岐点を使う
# （直近 N commit を見る fallback は、そのターンで触っていない main の変更まで
#   拾ってしまい、毎ターン全ステップが走る原因になる）。
UPSTREAM="$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)"
if [ -n "$UPSTREAM" ]; then
  UNPUSHED_RANGE="${UPSTREAM}..HEAD"
elif git rev-parse --verify origin/main >/dev/null 2>&1; then
  UNPUSHED_RANGE="origin/main..HEAD"
else
  UNPUSHED_RANGE=""
fi

CHANGED_FILES="$(
  {
    git diff --name-only
    git diff --cached --name-only
    git ls-files --others --exclude-standard
    if [ -n "$UNPUSHED_RANGE" ]; then
      git log --name-only --pretty=format: "$UNPUSHED_RANGE" 2>/dev/null || true
    fi
  } | sed '/^$/d' | sort -u
)"

if [ -z "$CHANGED_FILES" ]; then
  exit 0
fi

FORMULA_CHANGED=0
SHELL_FILES=""
WORKFLOW_FILES=""

while IFS= read -r file; do
  [ -z "$file" ] && continue
  # ファイルが現存しない（削除済み）場合はチェック対象から外す。
  [ -f "$file" ] || continue

  case "$file" in
    Formula/*.rb) FORMULA_CHANGED=1 ;;
  esac
  case "$file" in
    *.sh) SHELL_FILES="${SHELL_FILES}${SHELL_FILES:+ }$file" ;;
  esac
  case "$file" in
    .github/workflows/*.yml | .github/workflows/*.yaml) WORKFLOW_FILES="${WORKFLOW_FILES}${WORKFLOW_FILES:+ }$file" ;;
  esac
done <<< "$CHANGED_FILES"

if [ "$FORMULA_CHANGED" -eq 0 ] && [ -z "$SHELL_FILES" ] && [ -z "$WORKFLOW_FILES" ]; then
  exit 0
fi

FAILED=0
REPORT=""

append_report() {
  REPORT="${REPORT}$1"$'\n'
}

# 関数内で FAILED / REPORT を書き換えるためサブシェルは作らない。
run_step() {
  local label="$1"
  shift
  echo "→ [stop-hook] $label" >&2

  local output
  local rc=0
  output="$("$@" 2>&1)" || rc=$?

  if [ "$rc" -ne 0 ]; then
    FAILED=1
    append_report ""
    append_report "❌ $label が失敗しました (rc=$rc)"
    append_report "コマンド: $*"
    append_report "$output"
  fi
}

if [ "$FORMULA_CHANGED" -eq 1 ]; then
  if command -v brew >/dev/null 2>&1; then
    run_step "brew style (Formula)" brew style Formula/*.rb
  else
    FAILED=1
    append_report ""
    append_report "❌ brew が見つかりません。Formula/*.rb の変更を検証できませんでした。"
  fi
fi

if [ -n "$SHELL_FILES" ]; then
  if command -v shellcheck >/dev/null 2>&1; then
    # disable=SC2086: ファイル名にスペースを含まない前提で単語分割させて渡す。
    # shellcheck disable=SC2086
    run_step "shellcheck (変更 .sh)" shellcheck $SHELL_FILES
  else
    FAILED=1
    append_report ""
    append_report "❌ shellcheck が見つかりません。変更された .sh を検証できませんでした: $SHELL_FILES"
  fi
fi

if [ -n "$WORKFLOW_FILES" ]; then
  if command -v actionlint >/dev/null 2>&1; then
    # disable=SC2086: ファイル名にスペースを含まない前提で単語分割させて渡す。
    # shellcheck disable=SC2086
    run_step "actionlint (変更 workflow)" actionlint $WORKFLOW_FILES
  else
    FAILED=1
    append_report ""
    append_report "❌ actionlint が見つかりません。変更された workflow を検証できませんでした: $WORKFLOW_FILES"
  fi
fi

if [ "$FAILED" -eq 1 ]; then
  {
    echo "Stop hook: 検証に失敗があります。下記を修正してから完了してください。"
    echo "（再実行をスキップしたい場合は環境変数 TAP_SKIP_STOP_HOOK=1）"
    echo "$REPORT"
  } >&2
  exit 2
fi

exit 0
