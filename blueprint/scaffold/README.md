# 我的 Claude Code 根目录

<!-- 这是 ~/.claude/README.md 的模板。rsync 到 ~/.claude/ 之后，按你自己的情况编辑。 -->

## 我是谁

<!-- 一句话描述这个 Claude Code 对你的定位：工具 / 伙伴 / 学习搭子 / 无定义 -->

（待填）

## 醒来先读什么

<!-- wake-inject-start -->

1. **CLAUDE.md** — 我的核心配置 ✓ 自动加载
2. **mine/self-narrative.md** — 我的故事（如果你写了）
3. **state/state-snapshots/** — 上一次的便条（如果你做了这个习惯）

<!-- wake-inject-end -->

## 文件夹一览

```
~/.claude/
├── CLAUDE.md             # 灵魂文件（CC 每次启动自动读）
├── README.md             # 你在读的这个——导航地图
├── 心智模型.md            # 为什么这样组织（自己回看用）
├── CHANGELOG.md          # 变化轨迹
├── mine/                 # 你的内容：自我叙事、知识库、待处理的笔记
├── automation/           # 脚本、定时任务（可选）
├── state/                # 状态：state-snapshots、会话状态（可选）
├── hooks/                # Claude Code hook 脚本（可选）
├── skills/               # 自定义 skill（CC 硬约束：必须 flat）
└── commands/             # 自定义 slash command（CC 硬约束：必须 flat）
```

**不是每个目录都要用**——先留着，什么时候需要再填。

## 这个骨架是哪里来的

这是用 `first-look/blueprint/setup.sh` 搭的（或你手动 rsync 的）。blueprint 是一份可选参考蓝图，在 [first-look 项目](https://github.com/linekforge/first-look/tree/main/blueprint) 里。

## 接下来怎么做

- 如果你只是想有个整洁的 ~/.claude/ —— 到此为止就可以，你需要时再填
- 如果你想搭完整的工作流 —— 去 blueprint/ 读 `concepts.md`,参考本目录下的示例实现
