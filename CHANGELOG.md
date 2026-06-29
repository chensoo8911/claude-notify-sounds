# Changelog

本專案的所有重大變更記錄於此（格式參考 [Keep a Changelog](https://keepachangelog.com/zh-TW/1.0.0/)）。

## [1.0.1] - 2026-06-30

### Changed
- 文件用詞：Stop hook 的時機從「回答完畢」正名為「**換你了（這輪結束）**」，更貼近 Stop 的真實語意（主對話這輪做完、把控制權交還給你，含我用文字反問你的情況），避免被誤解成字面「答完一段話」。
- 純文件 / 註解調整，**行為與設定變數（`NOTIFY_DONE_*`）皆未變**，不影響既有安裝。

## [1.0.0] - 2026-06-29

### Added
- 初版發布。[claude-notify-hooks](https://github.com/chensoo8911/claude-notify-hooks) 的「純音效」精簡分支。
- `PreToolUse(Bash)` hook：每次跑 bash 播音效（預設 Frog）。
- `Stop` hook：回答完畢播音效（預設 Glass），含 `stop_hook_active` 連續觸發防護。
- `Notification` hook：需要你回應 / 批准時播音效（預設 Funk）。
- 三個 hook 一律**同步**播放、不掛 async（async 會在 afplay 播完前被收掉 → 聽不到）。
- `install.sh` / `uninstall.sh`：依賴檢查、symlink 到 `~/.claude/skills/`、用 `jq` 安全合併 / 移除 settings.json hook、idempotent。
- `config.example.env`：三個時機各自的開關 / 音效，改完即時生效。
- `SKILL.md`：可讓 Claude 使用者一句話觸發安裝。
- 僅支援 macOS。
