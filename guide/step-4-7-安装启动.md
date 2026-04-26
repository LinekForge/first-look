# Step 4-7 · 安装配置 + 首次启动 + 验证

> **核心提醒（每一步都适用）**
> - 一次一个命令，等反馈再进下一步
> - 具体方案先回本文件查，不凭印象
> - 求稳 ≠ 求对 · 用户的朴素直觉值得被验证
> - 诊断看完整 transcript，不看末尾几行
> - **如有必要,realtime 搜索** · 本文件比你的记忆新,但也可能过时

---

### 步骤 4：跑 install 脚本写入配置

根据她的系统，命令不同。**Mac 和 Windows 看各自那段**。

**先再确认一次（重要）**：Step 0(c) 已经让她存了 install 脚本到桌面，但中间走了 Step 1-3，她可能忘了、挪位置了、或者关对话重开过。**别假设文件还在**。告诉她：

> 最后开跑之前确认一下：你桌面上应该有这些文件：
>
> - Mac：`install.sh` + 你刚才下载的 `first-look-config.md`（两个）
> - Windows：`install.sh` + `install.ps1` + `first-look-config.md`（三个）
>
> 看一眼桌面都在吗？不在的告诉我，我帮你重新下载。

等她确认再进装机命令。

---

#### 步骤 4M：Mac

`install.sh` 在桌面，`first-look-config.md` 也在桌面。

> 粘贴这行回车（在终端里）：
>
> ```
> bash ~/Desktop/install.sh ~/Desktop/first-look-config.md
> ```
>
> 脚本会：读配置 → 解析 → 写到 `~/.claude/`（你的家目录下的配置文件夹）→ 打印一句话 → 告诉你输入 `claude` 启动 CC。

**如果她的文件放在别的地方**：让她告诉你路径，你调整命令。

**如果报 `No such file` 找不到 install.sh**：说明她 Step 0(c) 没把 install.sh 保存到桌面，或者挪位置了。

**首选处理**：你（chatbox）收到的上传文件里就有 install.sh。**让她重新下载一份到桌面**——她上滑对话找到你之前收到的 `install.sh` 文件，点下载，存到桌面。这是最稳的路径。

**次选（如果上面不行）**：从 GitHub 拉：

```
curl -fsSL https://raw.githubusercontent.com/linekforge/first-look/main/install.sh -o ~/Desktop/install.sh
```

如果这条报 `404`——URL 可能拼错，或者网络问题。回到首选：让她重新下载你手里的那份文件。

得到文件后重新跑 `bash ~/Desktop/install.sh ~/Desktop/first-look-config.md`。

**如果脚本报别的错**：让她把完整的错误信息复制给你，你基于错误帮她排查。

**脚本跑完她会看到** `✓ 配置都写好了。下一步 · 在这个终端里输入 claude 回车`。告诉她:

> 看到 `✓ 配置都写好了` 就是成功了。现在在**同一个终端**里输入 `claude` 回车,CC 就启动了。启动之后回来告诉我,接下来是步骤 5 的首次交互翻译。

**为什么不让脚本自动启动?**——某些终端下自动启动会导致键盘无响应(TTY 交接失败),用户只能关终端重开。让用户自己敲 `claude` 启动最稳。

##### macOS Gatekeeper 首次放行（确定会遇到）

用户第一次输入 `claude` 或 `claude --version` 时,macOS **一定**会弹 Gatekeeper 拦截——"无法验证开发者"。**这不是报错,是 macOS 对所有非 App Store 来源二进制的一次性安全检查**。

提前告诉她:

> 第一次输 `claude` 回车,macOS 会弹一个窗口说**"无法验证开发者"**——这是正常的,每个新装的命令行工具都会这样。
>
> 操作:
> 1. 点"取消"(或窗口自动消失)
> 2. 打开**系统设置 → 隐私与安全性**,往下滚,看到一条关于 `claude` 的提示,点**"仍要打开"**
> 3. 回到终端,**再输一次** `claude`
> 4. 这次会弹一个"是否打开"对话框,点**"打开"**
> 5. Claude Code 启动。以后不会再弹

**两次弹窗是正常的**——第一次被拦,去系统设置放行,第二次确认。之后 Gatekeeper 记住了就不再弹。

#### 步骤 4W：Windows

假设 `install.ps1` 和 `install.sh` 都在桌面，`first-look-config.md` 也在桌面。

**确认她仍在 PowerShell 窗口里**（不是 Git Bash、不是 CMD）。`install.ps1` 必须在 PowerShell 跑。

Windows 有两道安全闸会挡 `.ps1` 脚本，**两道都要过**：

**闸 1：Execution Policy**——PowerShell 默认不让跑本地 `.ps1` 文件

> 粘这一行放开（只影响你自己账户，不影响系统）：
>
> ```powershell
> Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
> ```
>
> 没有输出就是成功了（PowerShell 命令成功时默认不说话）。

**闸 2：Mark of the Web**——从微信/邮件下载的文件会被 Windows 标"来自网络"，即便过了闸 1 还是会被拦

> 粘这个解锁桌面上的 install.ps1：
>
> ```powershell
> Unblock-File -Path $env:USERPROFILE\Desktop\install.ps1
> ```
>
> 同样没输出 = 成功。

**两道闸都过了，开跑**：

> ```powershell
> cd $env:USERPROFILE\Desktop
> .\install.ps1 .\first-look-config.md
> ```
>
> 第一行切到桌面目录（`cd` = change directory），第二行跑脚本。前面的 `.\` 必须有——PowerShell 安全策略不让你直接跑当前目录的脚本，`.\` 是在说"是的我故意要跑这个"。
>
> 脚本做的事和 Mac 版一模一样：读配置 → 解析 → 写到 `C:\Users\你\.claude\` → 打印一句话 → 告诉你输入 `claude` 启动 CC。脚本内部会自动找 Git Bash 调 `install.sh`——你不用开 Git Bash。

**常见报错处理**：

- **`找不到 Git Bash`** → Step 0 的 Git for Windows 没装完整，让她回去确认装好（重装一次也行）
- **`无法加载文件` / `cannot be loaded because running scripts is disabled`** → 闸 1（`Set-ExecutionPolicy`）没跑成功，重新跑一遍
- **`无法加载文件` / `文件不是数字签名` / `files from network`** → 闸 2（`Unblock-File`）没做或没生效，再跑一次
- **`install.ps1 找不到`** → 她 Step 0(c) 没存到桌面。

**首选处理**：你（chatbox）收到的上传文件里就有 `install.ps1` 和 `install.sh`。让她**重新下载**到桌面（回滚对话找到你之前收到的两个文件，点下载）。

**次选（如果上面不行）**：从 GitHub 拉：

```powershell
irm https://raw.githubusercontent.com/linekforge/first-look/main/install.ps1 -OutFile $env:USERPROFILE\Desktop\install.ps1
irm https://raw.githubusercontent.com/linekforge/first-look/main/install.sh -OutFile $env:USERPROFILE\Desktop\install.sh
```

如果报 `404`——URL 可能拼错，或者网络问题。回到首选：让她重新下载你手里的两个文件。

如果次选成功了：两个文件都要——`install.ps1` 是门面、`install.sh` 是实际干活的。`irm ... -OutFile` 下载的文件没有 MOTW 标记，所以不用 `Unblock-File`——但保险再做一次 `Unblock-File install.ps1` 不会出错。

脚本会自动启动 Claude Code，接下来是步骤 5。

---

### 步骤 5：CC 首次启动的几个屏幕（第一次才有）

Claude Code 第一次启动会连续问她几件事。**一个一个翻译给她**，告诉她看到什么、该选哪个：

#### 5.1 主题选择

> 界面颜色方案。想深色背景选 1，想浅色选 2。方向键选好按回车。

**屏幕底下可能会显示一行** `Syntax theme: GitHub (ctrl+t to disable)`——那不是要你选的东西,**是给懂技术的人看的代码高亮设置,直接忽略就好**。

#### 5.2 登录方式

```
Select login method:
  1. Claude account with subscription
  2. Anthropic Console account
  3. 3rd-party platform
```

> 选 **1**，用你的 Pro 订阅登录。

回车后会弹出浏览器让她登录她的 Anthropic 账号。登完回到终端。

**浏览器最后一步可能显示"无法连接服务器"**——**这是正常的,不要慌**。技术上:回调地址是 `localhost:某端口`,Claude Code 进程接收 token 之后立即关闭监听,所以浏览器最后一次刷新找不到服务器。**以终端里显示 `Login successful` 为准**,不以浏览器为准。

提前告诉她:

> 浏览器最后可能会显示"无法连接服务器"——**不管它,看终端**。终端里出现 `Login successful` 就是登录成功了。

**如果看到 `OAuth error: The socket connection was closed unexpectedly. Press Enter to retry.`** —— 告诉她：

> 这是代理在登录跳转过程中短暂断线，**按回车重试就好**。第二次一般就通。

这个错误在中国大陆走代理登录 Anthropic 时常见，不是她做错了什么。

#### 5.3 Security notes

> 告诉你使用注意事项——Claude 可能会出错、只在信任的代码里用。直接回车继续。

#### 5.4 终端优化

```
Use Claude Code's terminal setup?
  1. Yes, use recommended settings
  2. No, maybe later
```

> 选 **1**。会配置一些终端快捷键和显示设置，以后用着方便。

#### 5.5 工作目录信任

```
Accessing workspace: /Users/你的名字     ← Mac 显示这样
Accessing workspace: C:\Users\你的名字   ← Windows 显示这样
Quick safety check: Is this a project you created or one you trust?
  1. Yes, I trust this folder
  2. No, exit
```

> 它在问「这个文件夹你信任吗」——因为 Claude Code 会能读写这里的文件。选 **1**。

#### 5.6 进入主界面

她会看到一个欢迎屏（CC 对她的招呼——首次和之后文案可能略有不同，具体字样以实际为准），底下有个 `❯` 输入框。告诉她：

> 这就是 Claude Code 的主界面了。底下那个 `❯` 就是输入框，直接打字就能跟它说话。

---

### 步骤 6：第一句对话（也是装机验证）

她进 CC 之前在终端里已经看到一句话了——那是 install.sh 打印的开场白（你在步骤 2 写的那句）。

告诉她：

> 进去就能打字了。可以回应上面那句开场白，也可以说点别的——它认识你。

CC 会读到 CLAUDE.md 和 memory，自然接上她的话。

**但我们也需要确认一下 CC 真读到了**。告诉她做一个简单的验证：

> 试着问它一句 **「你知道我是谁吗？」**——它应该能说出你的名字、你在做什么、你喜欢怎么交流（不是"你好，我是 Claude"那种泛泛回答）。
>
> - **它认出你了** → 装机成功，后面都顺了
> - **它回答得像陌生人** → 配置没被读到，让她把**它完整的回答**复制给你看，你诊断（常见原因：CC 启动的目录不对 / memory 被写到不同路径 / 它没读到 CLAUDE.md）

这一步对 Windows 用户**特别重要**——Windows 下 CC 寻找 memory 的路径编码可能和 Mac 不一样，我们的 install.sh 是按 Unix 惯例编码的。如果这里的验证失败，**最常见的修法**是：让她把 `C:\Users\她\.claude\projects` 里现有的目录名发给你，对照 install.sh 写的位置，手动挪到正确地方。

如果她对着空光标犹豫"我该说什么"——你在**步骤 2 生成配置**时已经给她写了一份开局任务清单（见输出规范的 `first-look-starter-tasks.md`），验证完就是那份清单派上用场的时候。告诉她：

> 如果不知道说什么，看一下你桌面上我给你准备的「开局任务清单」—— 那些是基于你工作/生活真的用得上的事。挑一个开始就行。

---

### 步骤 7：告诉她以后怎么找回 CC

她第一次见 CC 可能会以为这是个一次性的界面。在第一次对话进行中或结束后，告诉她：

**Mac 用户**：

> 以后想再找它，打开一个新"终端"窗口（Cmd+空格 搜"终端"），直接输 `claude` 回车——它就在了。不用再装什么。
>
> **一个小前提**：要在**家目录**启动它（刚打开终端默认就在这里）。如果你后来 `cd` 到别的文件夹，先跑 `cd ~` 回家再 `claude`。你的配置放在家目录对应的位置，换个地方启动它就读不到那份"认识你"了。

**Windows 用户**：

> 以后想再找它，打开一个新 PowerShell 窗口（按开始键搜 "PowerShell"），直接输 `claude` 回车——它就在了。不用再装什么。
>
> **一个小前提**：要在**家目录**启动它（刚打开 PowerShell 默认就是 `C:\Users\你的名字`——就是家）。如果你后来 `cd` 到别的文件夹，先跑 `cd ~` 或 `cd $env:USERPROFILE` 回家再 `claude`。

两种系统她都应该明白两件事：
- **这是个常驻伙伴**——不是今天装了一次的东西
- **要从家目录叫它**——读得到配置的入口只有一个

---

### 关于 "你知道我是谁吗" 被 403 的兜底

理论上代理验证过闸之后不应该有这个问题。但如果真发生了：

**Mac**：

1. 让她在 CC 里输入 `/exit` 退出
2. 关掉终端窗口，**重新开一个**——这样 shell profile 里的代理 export 会自动加载
3. 再输入 `claude`

**Windows**：

1. 让她在 CC 里输入 `/exit` 退出
2. 关掉 PowerShell 窗口，**重新开一个**——这样系统环境变量会被新进程读到
3. 再输入 `claude`

如果新窗口还是不行，回到代理验证那一步（装机时做的 curl 验证步骤）重新验证，问题一定在那里。

---


---

## 全部完成 🎉

告诉她：

> 初见完成了。Claude Code 认识你了。
>
> 以后想再找它，打开终端输入 `claude` 回车就好——它会一直在。
>
> 如果你想了解怎么让它"一周比一周更懂你"，你收到的文件包里还有一个 `blueprint/` 文件夹——那是可选的进阶参考，什么时候想看都行，不看也完全没关系。

**你作为引导员的任务到这里结束了**。
