# hooks/ · CC 事件钩子

Claude Code 在关键时刻调用的脚本。每个 hook 做一件事、职责单一。

**常用 hooks**：
- `bootstrap/session-start.sh` — CC 启动时调用（做上下文恢复最常见）
- `destructive-guard.sh` — 工具调用前拦截危险操作（比如 rm）
- `pre-compact.sh` — 压缩前做备份
- `timestamp.sh` — 时间感知

**挂载方式**：在 `~/.claude/settings.json` 的 `hooks` 字段里指定。具体见 `bootstrap/session-start.sh` 顶部注释。

**建议顺序**：先挂一个 session-start 享受"跨 session 恢复"的好处。其他按需加。
