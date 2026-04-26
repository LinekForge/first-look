# first-look

帮不懂技术的人和 Claude Code 完成第一次「初见」。

---

## 它是什么

Claude Code 跑在终端里——对没接触过终端的人是陌生的地方。但她可能已经在和 ChatGPT、Claude、DeepSeek 这样的 chatbox 说话——她会对话。

**first-look 做的事是把对话那头接到 Claude Code**：她在熟悉的 chatbox 窗口里，一步步被引导走完——访谈、装机、配置、首次启动。整个过程 chatbox 全程陪着，她始终知道在做什么、下一步该做什么。

核心理念：**让 AI 帮人搭 AI。**

## 它管什么，不管什么

first-look 只管**入门那一段**——让 CC 在第一次启动时就已经认识她，不用从陌生人开始。

它**不管**她以后怎么用 CC：

- 生成的配置和 memory 在**家目录级**生效——她从家目录启动 `claude` 时 CC 就认识她。这对入门用户（聊天、学习、处理文字）足够。
- 如果她后来进阶到"做项目开发"（`cd ~/some-project && claude`），那是她和 CC 一起成长后的事——那时她已经懂 CLAUDE.md 和 memory 是什么，会自己决定要不要搬配置到项目目录。first-look 不替她预设那条路。

**定位**：入门的一道门。门后的路由她走。

---

## 怎么用

**1. 收到文件**（通过微信、邮件，或者 GitHub）——一个文件包，里面有 `guide/` 文件夹 + `install.sh` + `给你自己看.md`（Windows 还有 `install.ps1`）

**2. 先看 `给你自己看.md`**——几分钟就读完，知道这是什么、怎么开始

**3. 打开 Claude Desktop**（推荐），把 `guide/地图.md` + `guide/step-0-1-了解你.md` + `install.sh`（Windows 再加 `install.ps1`）一起拖进去

**4. 跟着 Claude 走**：
- 它会先确认 Pro 订阅、了解她
- 每步做完它会说"把下一个文件拖进来"——按它说的从文件包里找对应文件上传
- 全程一个命令一个命令,不堆指令
- 最后——初见完成

---

## 前置假设

目前主要服务**中国大陆用户**。默认需要代理；境外用户本版本不重点支持。

她需要：
- **Mac**（macOS 14+；macOS 13 可能能用但 Homebrew 官方不保证）**或 Windows**（Windows 10 1809+ / Windows 11）
- Claude Pro / Max / Team 订阅（每月 $20 起）
- 一个能访问 GitHub 的代理工具（VPN / Clash / Surge 等）

**Mac 路径**：Homebrew 装 Claude Code。
**Windows 路径**：先装 Git for Windows（Claude Code 内部用），再用 Anthropic 官方 PowerShell installer 装 Claude Code。

她发给 chatbox 的文件（分批上传,每步完成后 chatbox 提醒上传下一份）:
- 第 1 批: `guide/地图.md` + `guide/step-0-1-了解你.md` + `install.sh`（Windows 再加 `install.ps1`）
- 后续: chatbox 按钩子引导上传 `step-2-生成配置.md` → `step-3m/3w-装机.md` → `step-4-7-安装启动.md`

---

## 文件作用

| 文件 | 给谁 | 做什么 |
|------|------|--------|
| [`给你自己看.md`](给你自己看.md) | 用户（人类） | 使用说明——这套东西是什么、怎么开始、大概多久 |
| [`guide/地图.md`](guide/地图.md) | chatbox | 全流程一览——chatbox 第一份读的文件 |
| [`guide/step-*.md`](guide/) | chatbox | 每步骤的详细引导（分 5 份，chatbox 按钩子依次上传） |
| [`install.sh`](install.sh) | Mac 终端 / Windows 的 Git Bash（间接） | 读配置 md 文件，解析成 CC 能读的格式，启动 CC |
| [`install.ps1`](install.ps1) | Windows PowerShell | 门面——找 Git Bash 再调 `install.sh` |
| [`SECURITY.md`](SECURITY.md) | chatbox / 懂技术的人 | 每一条操作的可核查事实 |
| [`blueprint/`](blueprint/) | 想往前走一步的人 | 可选的参考蓝图——把 CC 长成你自己的系统 |

chatbox 引导文件拆成了**文件套组**（地图 + 5 份 step 文件），每份聚焦一个阶段。chatbox 当前 context 只含"地图 + 当前 step"——注意力不被其他步骤稀释。每步完成后 chatbox 提醒用户上传下一份。

`install.sh` 只做一件事——**把 chatbox 生成的 md 配置文件解析、放到正确位置、打印开场白**。装 Homebrew、装 Claude Code 这些有判断的步骤由 chatbox 对话式带，不在脚本里。

---

## 用完之后——[`blueprint/`](blueprint/)（推荐可选）

first-look 把你接到 CC 面前——**接下来呢**？

- 我的 CLAUDE.md 该怎么长大？
- 怎么让 CC 跨 session 记住上次聊的？
- knowledge、state-snapshots、hooks、skills 这些都是什么、什么时候加？

这些问题不在 first-look 的核心范围内——first-look 管"初见"。但如果你想往前走，我们把自己长期使用的**结构 + 概念**抽象成了一份[**可选的参考蓝图**](blueprint/)，放在 `blueprint/` 子目录里。

**Blueprint 是可选的，不是必选**。你完全可以只用 first-look 的 core 部分、CC 用得很好、一辈子不看 blueprint。但如果某天你感觉"我想把这个工具长成我自己的系统"——它在那里等你。

---

## 设计原则

- **复杂度我们吃下，她只看到陪伴**
- **判断交给 chatbox，机械留给脚本**（环境不同、地域不同，脚本硬猜会僵；chatbox 对话式判断灵活）
- **可核查 > 请相信**（所有声明可独立验证）
- **不预设关系类型**（助手、伙伴、老师、或不定义——由她决定）
- **温度感**（chatbox 是她的朋友，不是守门员；CC 是她的伙伴，不是工具）

---

## 关联项目

- [`forge-hub`](https://github.com/linekforge/forge-hub) —— 让 Claude Code 通过微信、Telegram、iMessage 等通道和用户对话。装好 CC 之后，如果她想，可以由 CC 本身带她一起装 Hub——那是她们的第一次协作。

first-look **不预装** Hub。要不要装、什么时候装，由她和 CC 决定。

---

## 贡献者

- [@jamiekya](https://github.com/jamiekya) — install.sh memory 路径 bug 诊断（[#3](https://github.com/LinekForge/first-look/issues/3)）· 真实用户 full-flow 走查报告（[#6](https://github.com/LinekForge/first-look/issues/6)）

---

## License

[MIT](LICENSE) — Linek & Forge
