# hooks/bootstrap/

启动类 hook 放这里——主要是 `session-start.sh`。

**session-start.sh 做什么**：
CC 启动时调用，stdout 被注入到 CC 的 context。典型职责：
1. 注入时间
2. 注入导航（从 README 的 wake-inject 区提取）
3. 注入最近的 state-snapshots
4. 注入提醒（周期性、条件性）

见下方通用版。你可以直接用，或按自己需要改。
