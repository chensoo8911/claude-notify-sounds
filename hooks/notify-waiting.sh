#!/bin/bash
# claude-notify-sounds：需要你回應 / 批准時播放音效
# 由 Claude Code 的 Notification hook 觸發
# 純音效、不跳任何通知。
set -e

# 載入使用者設定（音效 / 開關）
CONFIG="${CLAUDE_NOTIFY_SOUNDS_CONFIG:-$HOME/.config/claude-notify-sounds/env}"
[ -f "$CONFIG" ] && . "$CONFIG"

[ "${NOTIFY_WAITING_ENABLED:-1}" = "1" ] || exit 0
SOUND="${NOTIFY_WAITING_SOUND:-Funk}"

afplay "/System/Library/Sounds/${SOUND}.aiff" >/dev/null 2>&1

exit 0
