#!/bin/bash
#
# claude-notify-sounds 移除腳本（macOS）
#
# 只移除本工具掛過的 hook（Stop / Notification，含舊版的 PreToolUse bash；
# 用 command 路徑比對），保留你其餘的 settings 設定；並刪除 skill symlink
# 目錄。設定檔預設保留。
#
# 用法：bash uninstall.sh
#
set -e

SKILL_DIR="$HOME/.claude/skills/claude-notify-sounds"
SETTINGS="$HOME/.claude/settings.json"
CONFIG_DIR="$HOME/.config/claude-notify-sounds"

HOOK_BASH="$SKILL_DIR/hooks/notify-bash.sh"
HOOK_DONE="$SKILL_DIR/hooks/notify-done.sh"
HOOK_WAITING="$SKILL_DIR/hooks/notify-waiting.sh"

echo "🧹 claude-notify-sounds 移除開始..."
echo

# ─── 1. 從 settings.json 移除自己的 hook ──────────────────────
if [ -f "$SETTINGS" ] && command -v jq >/dev/null 2>&1 && jq empty "$SETTINGS" 2>/dev/null; then
  TMP="$(mktemp)"
  jq --arg bash "$HOOK_BASH" --arg done "$HOOK_DONE" --arg waiting "$HOOK_WAITING" '
    def strip($e; $c):
      if (.hooks[$e]) then
        .hooks[$e] = ((.hooks[$e]) | map(.hooks |= map(select(.command != $c))) | map(select((.hooks | length) > 0)))
        | (if (.hooks[$e] | length) == 0 then del(.hooks[$e]) else . end)
      else . end;
    strip("PreToolUse"; $bash) | strip("Stop"; $done) | strip("Notification"; $waiting)
  ' "$SETTINGS" > "$TMP"
  if jq empty "$TMP" 2>/dev/null; then
    mv "$TMP" "$SETTINGS"
    echo "  ✅ 已從 settings.json 移除本工具的 hook（保留其餘設定）"
  else
    rm -f "$TMP"
    echo "  ⚠️  移除後 JSON 異常，已略過（原檔未更動）" >&2
  fi
else
  echo "  ⚠️  找不到合法 settings.json 或 jq，略過 hook 移除" >&2
fi

# ─── 2. 刪除 skill symlink 目錄 ───────────────────────────────
if [ -d "$SKILL_DIR" ]; then
  rm -rf "$SKILL_DIR"
  echo "  ✅ 已刪除 $SKILL_DIR"
fi

echo
echo "🎉 移除完成（設定檔 $CONFIG_DIR 預設保留，要清就手動刪）。"
echo "   記得重啟 Claude Code 或開一次 /hooks 讓設定重載。"
