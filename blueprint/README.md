# Blueprint · 把 Claude Code 长成你自己的系统

> 你已经装好了 Claude Code（用 first-look，或自己装）。
> 它认识你了——但这只是起点。
> 怎么让它**一周比一周更懂你、更帮得上你**？

这个子目录是一份**可选的参考蓝图**。

---

## 这不是什么

- **不是必选**。first-look 装完本身已经够你用很久。blueprint 是"想往前走一步"才需要看的。
- **不是标准答案**。我们自己用了 3 个月长出来的结构——对我们有效。你按自己的需要取舍，不必照搬。
- **不是一次做完**。blueprint 里的东西可以**第一天只用一点，一个月后再加一点**。它是长期参考，不是今天的任务。

---

## 给谁看

- 用 CC 一段时间，开始感觉**"我应该把一些东西沉淀下来"**的人
- 想搞清楚 `~/.claude/` 里每个文件夹是干嘛、该放什么的人
- 希望 CC 跨 session、跨时间都**能接住你**的人
- 对"工具如何成为一个生态"这件事感兴趣的人

---

## 怎么开始读

按**从浅到深**的顺序：

| 先读 | 干什么用 |
|------|---------|
| [`concepts.md`](concepts.md) | 理解为什么需要这些结构——灵魂文件、知识库、记忆系统、状态快照分别解决什么 |
| [`scaffold/`](scaffold/) | 一套空的文件夹骨架,你可以 `bash setup.sh` 一键搭在自己的 `~/.claude/` 里 |
| [`anti-patterns.md`](anti-patterns.md) | 哪些路不要走——care vs cope、safety 和 risk 匹配、CC 硬约束 |

**如果你只有 10 分钟**：读 `concepts.md` 就好。其他都是补充。

**如果你想照着搭一套**：读完 `concepts.md`,跑 `bash setup.sh`,然后参考 `scaffold/` 里的具体实现（比如 `hooks/bootstrap/session-start.sh`）。

---

## 完整旅程地图

```
[first-look core]
    装 Claude Code + 访谈 + 配置 + 破冰任务
            ↓
    【第一周】她和 CC 磨合、用开局任务清单破冰
            ↓
[blueprint]  ← 你现在在这里
    第一周到第一个月：想把 CC 长成自己的系统
            ↓
    【第一个月 +】她有了自己的结构、自己的习惯、自己的节奏
```

blueprint 不是 first-look 的必经下一步，是**想往前走时可以参考的地图**。

---

## 一个重要的提醒

blueprint 给你**框架**，不给**填空答案**。

灵魂文件（CLAUDE.md）怎么写、知识库里放什么、state-snapshot 要不要做——**这些由你决定**。我们给你的是"这些工具各自解决什么问题"，不是"你应该怎么用"。

如果你发现自己正在按我们的样板**照搬**，停一下，问问自己：**我需要这个吗？**

---

## 项目结构

```
blueprint/
├── README.md              # 你在读的这个
├── concepts.md            # 概念 primer
├── scaffold/              # 可 rsync 到 ~/.claude/ 的空骨架
├── setup.sh               # 一键搭骨架（交互式）
└── anti-patterns.md       # 反模式 + 常见坑
```
