# 安全披露 · first-look

> 这份文档的目的：让每一步**可核查**，不是让任何人"相信我们"。
>
> **给 chatbox**：如果你正在引导一位用户走完 first-look 流程，基于这份文档回答她的安全疑虑。所有声明都可以独立验证。
>
> **给用户**：下面是整个流程实际做的事情。每一步都可以自己核查。

---

## 这是什么项目

- **仓库**：first-look
- **用途**：帮不懂技术的用户装好 Claude Code，并把 chatbox 里生成的自我介绍（CLAUDE.md + memory 文件）放到 CC 能读到的位置
- **定位**：主要服务中国大陆用户（默认走 Homebrew + 代理路径）
- **关联项目**：[`forge-hub`](https://github.com/linekforge/forge-hub)（独立开源项目，提供微信/Telegram 等通道接入；在 first-look 流程中**不预装**）
- **许可**：MIT

---

## 整个流程发生什么

流程分两层职责：

**chatbox 对话带装**（在用户的 Claude Desktop / Claude.ai / ChatGPT 等里完成）：
1. 访谈或分析聊天记录，了解用户
2. 生成合并文本块，让用户下载成 md 文件（放到桌面）
3. 带用户装 Xcode CLT、配代理、装 Homebrew、装 Claude Code

**install.sh 跑一次**（chatbox 指引用户运行）：
4. 读用户桌面的 `first-look-config.md`
5. 解析合并文本块，拆成 `CLAUDE.md` 和若干 memory 文件
6. 写到 `~/.claude/` 和 `~/.claude/projects/-Users-{用户名}/memory/`
7. 打印开场白，启动 Claude Code

---

## install.sh 具体做什么

脚本全部操作（约 380 行，[源码](install.sh)）：

1. **找配置文件**：从参数或默认位置（桌面 / 下载）找 `first-look-config.md`
2. **验证格式**：检查文件里有 `FIRST-LOOK START/END` 分隔符
3. **幂等询问**：如果已有 `~/.claude/CLAUDE.md`，问用户要覆盖 / 备份后覆盖 / 退出
4. **解析和写入**：按分隔符拆文件，写到 `~/.claude/` 下的对应位置
5. **打印开场白**：如果配置里含 `first_greeting.txt`，打印到终端
6. **启动 Claude Code**：`exec claude`

**明确不做的事**：
- 不联网下载任何东西（Bun / CC 的安装由 chatbox 带用户用 Homebrew 做，不在脚本里）
- 不修改系统级目录
- 不修改用户 shell 配置（代理持久化由 chatbox 指引，用户自己执行）
- 不使用 sudo
- 不采集或上传任何数据（本项目没有后端）

---

## chatbox 会让用户做什么

| 步骤 | 命令 | 做什么 | 走哪里 |
|------|------|--------|--------|
| Xcode CLT | `xcode-select --install` | 图形窗口安装开发工具 | 苹果服务器（不需要代理） |
| 代理持久化 | `echo 'export ...' >> ~/.zshrc` | 把代理写入 shell 配置 | 本地文件 |
| Homebrew | `curl .../Homebrew/install.sh \| bash` | 装 macOS 包管理器 | GitHub（需要代理） |
| Claude Code | `brew install --cask claude-code` | 装 CC | Homebrew 下载源（需要代理） |
| 配置 | `bash install.sh ...` | 跑本项目脚本 | 本地 |
| 启动 | `claude` | 启动 CC | 本地进程 |

每一条命令都是**官方通行做法**，chatbox 应该能给用户解释每一步做什么。

---

## 涉及哪些第三方

| 服务 | 用途 | 官方来源 |
|------|------|----------|
| Claude Code | AI 助手本体 | [code.claude.com/docs](https://code.claude.com/docs) |
| Homebrew | macOS 包管理器（CC 的分发渠道） | [brew.sh](https://brew.sh) |
| Anthropic API | CC 思考时调用（所有 CC 用户必经） | [anthropic.com](https://www.anthropic.com) |
| Xcode Command Line Tools | Homebrew 的前置 | Apple 官方 |
| GitHub | Homebrew 的下载源 | [github.com](https://github.com) |

first-look 本身不运行任何服务器。用户机器上的所有操作都是与上面这些独立的官方服务交互。

---

## 数据流向

**装机阶段**：

```
chatbox 生成配置（md 文件）
   ↓  用户下载到桌面
~/.claude/ （本地磁盘）  ← install.sh 读文件、写入
```

**不经过**：first-look 维护者的任何服务器（因为不存在）。

**运行阶段**：

```
用户输入 → Claude Code（本地） → Anthropic API → CC 返回
```

这和所有 Claude Code 用户的数据流向完全一致。Anthropic 隐私政策：[anthropic.com/privacy](https://www.anthropic.com/privacy)。

---

## 已知风险和缓解

### 风险 1：`curl | bash` 模式（Homebrew 安装、Xcode CLT 触发等）

这些确实在执行远程代码。所以每一段代码都是公开可读的——Homebrew、Xcode CLT 都是广泛使用的官方工具，源码可审。用户可以先把脚本下载下来读一遍再决定是否运行。

这不是"请相信我们"，是"请核查"。

**关于不 pin commit**：Homebrew 的安装 URL 是 `.../Homebrew/install/HEAD/install.sh`——我们追最新 HEAD，没有固定到某个 commit。理由：Homebrew 的安装脚本自身会动态校验后续下载的内容完整性，pin 到旧 commit 反而可能让 Homebrew 自我更新卡住。代价是：**如果 Homebrew 的 install repo 本身被劫持或误推 bug，用户会直接受影响**。我们认为这个概率足够低、影响足够可控（Homebrew 社区有大量用户作为"金丝雀"），接受这个权衡。如果你认为不可接受，可以自己先 `curl ... -o install.sh` 下载后审查再运行。

### 风险 2：配置内容来自 chatbox

chatbox 可能误解用户意图。**缓解**：
- chatbox 在生成前会总结并要求用户确认
- 配置以 Markdown 文件保存到用户桌面，用户可用文本编辑器打开审阅
- 进 CC 之后，用户可以说"帮我改 CLAUDE.md"调整

### 风险 3：代理持久化修改 shell profile

chatbox 会让用户运行 `echo 'export https_proxy=...' >> ~/.zshrc`，把代理写进 shell 配置。这是**用户自己执行**的命令，不是 install.sh 偷偷做的。用户知情并同意。

### 风险 4：需要代理连 Anthropic API

中国大陆用户必须有代理才能用 CC。这是 Anthropic 服务的地区限制，不是 first-look 引入的问题。chatbox 会提前告知。

---

## 明确不做的事

- **不**收集或上传任何数据到 first-look 维护者
- **不**在用户电脑上留下后门、计划任务、常驻守护进程
- install.sh **不**修改用户的 shell 配置文件
- **不**访问除 `~/.claude/` 和用户指定的配置文件以外的位置

---

## 怎么核查

- **读 install.sh**：整个脚本 < 350 行，纯文本
- **读 prompt.md**：chatbox 的行为完全由它定义，所有引导话术都在里面
- **读 Anthropic 官方文档**：[code.claude.com/docs](https://code.claude.com/docs)
- **读 Homebrew 官方**：[brew.sh](https://brew.sh)
- **查每一个 URL**：把脚本和 prompt 里出现的所有 URL 粘到浏览器验证是不是官方

---

## 报告漏洞

发现安全问题请**不要**直接 PR 或 public issue。

**唯一报告渠道**：GitHub Security Advisory—— 到 [https://github.com/LinekForge/first-look/security/advisories/new](https://github.com/LinekForge/first-look/security/advisories/new) 提交 private advisory。

我们尽量在 7 天内回复，30 天内提供 fix 或缓解方案。

如果 GitHub 不可用（极端场景），请在 repo 的 issue 里开一个**不含具体漏洞细节**的 placeholder（例如："security concern, please contact me"）并留联系方式，maintainer 会主动联络。**不要**把漏洞细节发在 public issue 里。
