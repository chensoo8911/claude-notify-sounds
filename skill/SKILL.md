---
name: claude-notify-sounds
description: 在 macOS 安裝 / 設定 / 移除 Claude Code 的「純音效」hook。讓 Claude 在「換你了（這輪結束）」「需要你回應（權限等待）」兩個時機播放系統音效，不跳任何桌面通知。觸發詞：「裝 Claude 音效」「設定 Claude 音效」「claude sounds」「移除 Claude 音效」。僅支援 macOS，需要 jq。
---

# claude-notify-sounds

幫使用者在 **macOS** 安裝 / 管理 Claude Code 的**純音效**提示。只播系統音效、**不跳任何桌面通知**。

## 兩個音效時機

| 事件 | 觸發 hook | 預設音效 |
|---|---|---|
| 換你了（這輪結束）| Stop | Glass |
| 需要你回應 / 批准 | Notification | Funk |

## 何時用這個 skill

使用者說「裝 Claude 音效」「設定 Claude 音效」「我只要音效不要通知」「移除 Claude 音效」等。

## 安裝

在 repo 根目錄執行：

```bash
bash install.sh
```

它會（idempotent，可重複跑）：
1. 檢查依賴（macOS / afplay / jq）
2. 把 `SKILL.md`、`hooks/` symlink 到 `~/.claude/skills/claude-notify-sounds/`
3. 建立設定檔 `~/.config/claude-notify-sounds/env`（已存在則保留）
4. 用 `jq` **安全合併** 兩個 hook 進 `~/.claude/settings.json`（保留既有設定，不覆蓋）

安裝後請使用者**重啟 Claude Code 或開一次 `/hooks`** 讓設定重載。

## 客製（音效 / 開關）

編輯 `~/.config/claude-notify-sounds/env`，改完即時生效、不需重裝：
- `NOTIFY_DONE_*` / `NOTIFY_WAITING_*`：各自的 `ENABLED`（開關）、`SOUND`
- 可用音效：Basso Blow Bottle Frog Funk Glass Hero Morse Ping Pop Purr Sosumi Submarine Tink

## 移除

```bash
bash uninstall.sh
```

只移除本工具自己的 hook（保留其餘 settings），並刪除 skill symlink 目錄。設定檔預設保留。

## 注意事項

- **僅 macOS**（用系統內建 `afplay` 播 `/System/Library/Sounds`）。
- 兩個 hook 都「**同步**」播放，**不可掛 async**：async 會在 `afplay` 播完前把行程收掉 → 聽不到聲音。
- v1.1.0 起移除了「每次跑 bash」時機（太吵），只留 Stop / Notification。
- 這是 [claude-notify-hooks](https://github.com/chensoo8911/claude-notify-hooks) 的純音效精簡版；兩者都裝會在同樣時機重複播放，請擇一。
