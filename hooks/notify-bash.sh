#!/bin/bash
# claude-notify-sounds：每次執行 bash 指令時播放短促音效
# 由 Claude Code 的 PreToolUse(Bash) hook 觸發
# 純音效、不跳任何通知。
#
# 重要：這個 hook 必須「同步」播放，不可掛 async。async 會在 afplay
# 播完前就把行程收掉，結果聽不到聲音（背景 / nohup 也會被 hook runner 殺掉）。
set -e

# 載入使用者設定（音效 / 開關）
CONFIG="${CLAUDE_NOTIFY_SOUNDS_CONFIG:-$HOME/.config/claude-notify-sounds/env}"
[ -f "$CONFIG" ] && . "$CONFIG"

[ "${NOTIFY_BASH_ENABLED:-1}" = "1" ] || exit 0
SOUND="${NOTIFY_BASH_SOUND:-Frog}"

afplay "/System/Library/Sounds/${SOUND}.aiff" >/dev/null 2>&1

exit 0
