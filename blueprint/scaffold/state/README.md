# state/ · 运行状态

这里放**当下状态**类的数据——state-snapshots、会话操作日志、计数器。

和 `mine/` 的区别：
- `mine/` 是**你是谁**（spec，长期不变）
- `state/` 是**此刻发生了什么**（state，不断更新）

**主要内容**：
- `state-snapshots/` — 你跨 session 的便条
- 其他运行状态文件（看你需要什么）
