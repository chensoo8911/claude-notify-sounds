# claude-notify-sounds

讓 **Claude Code** 在 macOS 用**音效**提示你 —— 換你了（這輪結束）、需要你回應（權限等待）時各播一個系統音效。**純音效，不跳任何桌面通知**。

> 僅支援 **macOS**（用系統內建 `afplay`）。安裝時需要 [`jq`](https://jqlang.github.io/jq/) 來安全合併 settings.json。
> 想要「會跳桌面通知」的完整版，看 👉 [claude-notify-hooks](https://github.com/chensoo8911/claude-notify-hooks)。

## 它做什麼

| 事件 | 觸發 | 預設音效 |
|---|---|---|
| 換你了（這輪結束）| Claude Code `Stop` hook | Glass 🔔 |
| 需要你回應 / 批准 | Claude Code `Notification` hook | Funk |

兩個音色刻意分開，閉著眼睛也能分辨：Glass = 換你了、Funk = 需要你批准 / 在等你。

## 安裝

```bash
git clone https://github.com/chensoo8911/claude-notify-sounds.git
cd claude-notify-sounds
bash install.sh
```

沒裝 `jq` 的話先：`brew install jq`

安裝後**重啟 Claude Code 或開一次 `/hooks`** 讓設定重載。

安裝會做的事（全部 idempotent、可重複跑）：
1. 檢查依賴（macOS / afplay / jq）
2. 把 `hooks/`、`skill/SKILL.md` symlink 到 `~/.claude/skills/claude-notify-sounds/`
3. 建立設定檔 `~/.config/claude-notify-sounds/env`
4. 用 `jq` **安全合併** 兩個 hook 進 `~/.claude/settings.json`（**保留你既有的所有設定**，不覆蓋）

## 客製

編輯 `~/.config/claude-notify-sounds/env`，改完即時生效、不需重裝：

```bash
NOTIFY_DONE_ENABLED=1            # 換你了（這輪結束），1=開 0=關
NOTIFY_DONE_SOUND=Glass

NOTIFY_WAITING_ENABLED=1         # 需要你回應 / 批准
NOTIFY_WAITING_SOUND=Funk
```

可用音效：`Basso Blow Bottle Frog Funk Glass Hero Morse Ping Pop Purr Sosumi Submarine Tink`

## 移除

```bash
bash uninstall.sh
```

只移除本工具自己的 hook（保留你其餘 settings），並刪除 skill symlink 目錄。設定檔預設保留。

## 設計筆記

- 兩個 hook 都**同步**播放，**不掛 async**：async 會在 `afplay` 播完前把行程收掉 → 聽不到聲音。
- v1.1.0 起移除了「每次跑 bash」時機（太吵），只留 Stop / Notification 兩個。

## 授權

MIT
