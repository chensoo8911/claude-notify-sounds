#!/bin/bash
# claude-notify-sounds：回答完畢時播放音效
# 由 Claude Code 的 Stop hook 觸發
# 純音效、不跳任何通知。
set -e

# 載入使用者設定（音效 / 開關）
CONFIG="${CLAUDE_NOTIFY_SOUNDS_CONFIG:-$HOME/.config/claude-notify-sounds/env}"
[ -f "$CONFIG" ] && . "$CONFIG"

[ "${NOTIFY_DONE_ENABLED:-1}" = "1" ] || exit 0
SOUND="${NOTIFY_DONE_SOUND:-Glass}"

# 防止 Stop hook 連續觸發造成重複播放（不需 jq，純文字比對）
INPUT=$(cat)
echo "$INPUT" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0

afplay "/System/Library/Sounds/${SOUND}.aiff" >/dev/null 2>&1

exit 0
