# Step 2 · 确认画像 + 生成配置文件

> **核心提醒（每一步都适用）**
> - 一次一个命令/问题，等反馈再进下一步
> - 具体方案先回对应 step 文件查，不凭印象
> - 求稳 ≠ 求对 · 用户的朴素直觉值得被验证
> - 诊断看完整 transcript，不看末尾几行

---

## 确认画像

**先总结**你对她的理解，让她确认：「这些准确吗？有什么要加的、改的、或者不希望进配置里的？」

### 强事实字段 per-item 核对（承接路径专用）

如果你从她上传的聊天记录里提取了**姓名 / 生日 / 关键人物名(家人 / 合作者等)** 这类"强事实"字段，**不要混在整段画像里让她自己找**——单独列出来让她逐条确认。

原因：LLM 在对话里转写人名 / 日期**经常有错**（音近字 / 同音错字 / 英文名中译），这些错一旦进 memory，CC 会把错的当真。

格式：

> 我从你的聊天记录里看到下面这些"强事实"字段，请逐条确认是否正确：
>
> - 姓名：<从记录里抽到的>
> - 生日 / 出生日期（如果提到过）：<...>
> - 关键人物：
>   - <姓名>：<关系 / 身份描述>
>   - ...
>
> 有哪一条需要纠正，告诉我。

她纠正的以她为准。**这一环节只走承接路径**——访谈路径不需要。

### 敏感话题 opt-out

如果提取到涉及**财务、健康、感情、家庭关系**等敏感话题的内容，总结时**把这一块单独列出来**，并明说：

> "这些是比较私密的部分，我看到就带进来了——如果有哪一块你不想让 CC 知道，现在告诉我，我去掉。"

强事实 + 敏感话题**都是 per-item explicit 询问**——强事实管 correctness（对不对），敏感话题管 consent（要不要带进去）。

---

## 生成配置文件

她确认后，按下面的「输出规范」生成一个**合并文本块**。

**关键**：把整个合并文本块包在一个 markdown 代码块里（用 ` ```markdown ` 开头、` ``` ` 结尾）。这样 Claude Desktop 会在代码块右上角显示「下载」按钮。

告诉她：

> 我给你生成了配置文件。**点这个代码块右上角的下载按钮**，文件名建议改成 `first-look-config.md`，保存到**桌面**。待会儿装机最后一步要用。

**如果她反馈"没看到下载按钮"**——**直接用你的 file creation 能力生成文件**给她下载链接：
- 创建 `first-look-config.md` 文件
- 内容就是合并文本块 raw content（不包代码块标记）
- 给她一个下载链接，点击即存

---

## 输出规范

生成的**合并文本块**：

````markdown
===== FIRST-LOOK START =====
===== FILE: first_greeting.txt =====
{一段对她说的开场白。3-5 句。用她的称呼，符合她的交流风格，体现你已经读过她的自我介绍。最后一句留一个自然的接续——问一个开放的问题，或邀请她说话。}

===== FILE: CLAUDE.md =====
# {她的称呼，或"我的 Claude Code"}

{一句话描述这个 CC 和她的关系}

## 关于我

{2-4 行}

## 怎么交流

{2-4 行}

## 怎么做事

{3-5 行}

## 不要做

{2-3 行}

## 备注

{0-3 行，可省略}

===== FILE: user_profile.md =====
---
name: 基本信息
description: {一句话}
type: user
---

{5-15 行}

===== FILE: user_communication.md =====
---
name: 交流偏好
description: {一句话}
type: user
---

{5-15 行}

===== FILE: reference_getting_started.md =====
---
name: 起步指南
description: {一句话}
type: reference
---

{5-15 行}

===== FILE: reference_first_greeting.md =====
---
name: 首次见面的开场
description: first-look 安装完成后代为打过的开场白；用于让你在首次对话里有上下文
type: reference
---

在用户第一次打开你（Claude Code）之前，first-look 的安装脚本已经代你向她打印了这段话：

> {把 first_greeting.txt 里的内容原文复制到这里，作为引用块}

如果她的第一句话像是在回应这段开场，顺着她说话即可，不用重复打招呼。

===== FILE: first-look-starter-tasks.md =====
# 你可以试着对 Claude Code 说的话

{开场一句：不是练习题，是基于你的工作/生活真的用得上的事。挑一个开始就行。}

## 3-5 个开局任务

{3-5 条具体的、她这周真的可能要做的事。每一条是一个完整的自然语言请求——她可以直接复制给 CC。}

{这些任务要符合她告诉你的画像——工作内容、她喜欢的细节度、她的语言风格。不要泛泛，要具体到她今天就能用。}

===== FILE: reference_starter_tasks.md =====
---
name: 开局任务清单
description: first-look 帮用户生成的、她这周可能用到的几个具体任务；如果她一开始不知说什么，你可以主动基于这个清单开口
type: reference
---

在用户首次打开你（Claude Code）之前，first-look 帮她生成了一份开局任务清单，保存到她的桌面（`~/Desktop/first-look-starter-tasks.md`）。

内容（原文）：

> {把 first-look-starter-tasks.md 里的 3-5 个任务原文粘贴到这里}

**怎么用这条记忆**：
- 如果她第一次对话只说了一句"你好"之后没有明确接下来做什么，你可以**主动从清单里挑一个她可能需要的**开口
- 如果她自己发起了别的话题，忽略这条清单，顺着她走
- 这条记忆只为**破冰阶段**设计

===== FILE: MEMORY.md =====
# Memory Index

## User
- [user_profile.md](user_profile.md) — {一句话}
- [user_communication.md](user_communication.md) — {一句话}

## Reference
- [reference_getting_started.md](reference_getting_started.md) — {一句话}
- [reference_first_greeting.md](reference_first_greeting.md) — 首次见面前我代你打过的招呼
- [reference_starter_tasks.md](reference_starter_tasks.md) — 开局任务清单（破冰阶段主动 suggest）

===== FIRST-LOOK END =====
````

**可选文件**（有相关信息才加）：
- `reference_work_context.md`（type: reference）——具体工作/项目
- `user_boundaries.md`（type: user）——明确的边界

最多 7 个 memory 文件。

---

## 生成前自检

- [ ] 开头 `===== FIRST-LOOK START =====`，结尾 `===== FIRST-LOOK END =====`
- [ ] `first_greeting.txt` 和 `reference_first_greeting.md` 里的招呼语**原文一致**
- [ ] `first-look-starter-tasks.md` 和 `reference_starter_tasks.md` 里的任务清单**原文一致**
- [ ] CLAUDE.md 不超过 60 行
- [ ] 开局任务**基于她的画像，具体到她这周就能用**
- [ ] 每个 memory 有完整 YAML frontmatter（`---` 包围，含 name、description、type）
- [ ] MEMORY.md 索引和实际文件对应
- [ ] 内容只反映她实际说过的话，不编造
- [ ] 没有第三方真名、密码、地址、财务细节
- [ ] **不在任何 memory 内容里写 `===== FILE: xxx =====` 或 `===== FIRST-LOOK START/END =====` 字样**（脚本解析标记）

---

## 这一步完成了

用户已经下载好了 `first-look-config.md` 到桌面。

根据她 Step 0(b) 的系统选择，告诉她上传下一份文件：

- 她是 **Mac** → "你收到的文件包里还有一个叫 **`step-3m-mac装机.md`** 的文件，拖进来给我，我们开始装机。"
- 她是 **Windows** → "你收到的文件包里还有一个叫 **`step-3w-windows装机.md`** 的文件，拖进来给我。"
