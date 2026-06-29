#!/bin/bash
#
# claude-notify-sounds 安裝腳本（macOS）
#
# 行為（全部 idempotent，可重複執行）：
#   1. 檢查依賴（macOS / afplay / jq）
#   2. symlink SKILL.md + hooks 到 ~/.claude/skills/claude-notify-sounds/
#   3. 建立 ~/.config/claude-notify-sounds/env（若不存在，從 config.example.env 複製）
#   4. 用 jq「安全合併」兩個 hook 進 ~/.claude/settings.json（保留既有設定，不覆蓋）
#
# 兩個 hook 都「同步」播放（不掛 async）：async 會在 afplay 播完前
# 把行程收掉 → 聽不到聲音。
#
# 用法：bash install.sh
#
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$HOME/.claude/skills/claude-notify-sounds"
SETTINGS="$HOME/.claude/settings.json"
CONFIG_DIR="$HOME/.config/claude-notify-sounds"
CONFIG_FILE="$CONFIG_DIR/env"

HOOK_DONE="$SKILL_DIR/hooks/notify-done.sh"
HOOK_WAITING="$SKILL_DIR/hooks/notify-waiting.sh"

echo "🔊 claude-notify-sounds 安裝開始（repo: $REPO_DIR）"
echo

# ─── 1. 依賴檢查 ───────────────────────────────────────────────
echo "📋 檢查依賴..."
if [ "$(uname)" != "Darwin" ]; then
  echo "  ❌ 本工具僅支援 macOS（偵測到 $(uname)）" >&2
  exit 1
fi
echo "  ✅ macOS"

if ! command -v afplay >/dev/null 2>&1; then
  echo "  ❌ 找不到 afplay（macOS 內建，環境異常）" >&2
  exit 1
fi
echo "  ✅ afplay"

if ! command -v jq >/dev/null 2>&1; then
  echo "  ❌ 需要 jq（用於安全合併 settings.json）。請先安裝：" >&2
  echo "       brew install jq" >&2
  exit 1
fi
echo "  ✅ jq: $(jq --version)"
echo

# ─── 2. symlink 到 skill 目錄 ─────────────────────────────────
echo "🔗 設定 skill 目錄 $SKILL_DIR ..."
mkdir -p "$SKILL_DIR"
link_into() {
  local target="$1" linkname="$2" linkpath="$SKILL_DIR/$2"
  if [ -L "$linkpath" ]; then
    if [ "$(readlink "$linkpath")" = "$target" ]; then
      echo "  ✅ $linkname (已正確 symlink)"; return
    fi
    rm "$linkpath"
  elif [ -e "$linkpath" ]; then
    echo "  ⚠️  $linkpath 已存在且非 symlink，跳過（請手動處理）" >&2; return
  fi
  ln -s "$target" "$linkpath"
  echo "  ✅ $linkname → $target"
}
link_into "$REPO_DIR/skill/SKILL.md" "SKILL.md"
link_into "$REPO_DIR/hooks"          "hooks"
echo

# ─── 3. 建立使用者設定檔 ───────────────────────────────────────
echo "⚙️  設定檔 $CONFIG_FILE ..."
mkdir -p "$CONFIG_DIR"
if [ -f "$CONFIG_FILE" ]; then
  echo "  ✅ 已存在（保留你的設定，不覆蓋）"
else
  cp "$REPO_DIR/config.example.env" "$CONFIG_FILE"
  echo "  ✅ 已建立（預設值；之後可編輯）"
fi
echo

# ─── 4. 安全合併 hooks 進 settings.json ───────────────────────
echo "🪝 寫入 settings.json hooks（安全合併，保留既有設定）..."
mkdir -p "$(dirname "$SETTINGS")"
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"

if ! jq empty "$SETTINGS" 2>/dev/null; then
  echo "  ❌ 現有 $SETTINGS 不是合法 JSON，為安全起見中止。請先修復後再裝。" >&2
  exit 1
fi

TMP="$(mktemp)"
jq --arg done "$HOOK_DONE" --arg waiting "$HOOK_WAITING" '
  def has_cmd($e; $c): ((.hooks[$e] // []) | map(.hooks[]?.command) | any(. == $c));
  .hooks = (.hooks // {})
  | (if has_cmd("Stop"; $done) then .
     else .hooks.Stop = ((.hooks.Stop // []) + [{"hooks":[{"type":"command","command":$done}]}]) end)
  | (if has_cmd("Notification"; $waiting) then .
     else .hooks.Notification = ((.hooks.Notification // []) + [{"hooks":[{"type":"command","command":$waiting}]}]) end)
' "$SETTINGS" > "$TMP"

if jq empty "$TMP" 2>/dev/null; then
  mv "$TMP" "$SETTINGS"
  echo "  ✅ Stop → notify-done.sh（換你了／這輪結束音效）"
  echo "  ✅ Notification → notify-waiting.sh（需要你回應音效）"
else
  rm -f "$TMP"
  echo "  ❌ 合併後產生非法 JSON，已中止（原檔未更動）" >&2
  exit 1
fi
echo

echo "🎉 安裝完成！"
echo
echo "下一步："
echo "  1. 重啟 Claude Code（或開一次 /hooks）讓設定重載"
echo "  2. 想改音效 / 開關 → 編輯 $CONFIG_FILE"
echo "  3. 想移除 → bash $REPO_DIR/uninstall.sh"
echo
echo "⚠️  若你同時裝了 claude-notify-hooks（含通知版），兩者會在相同"
echo "    時機播音效 → 會聽到兩聲。請擇一安裝。"
