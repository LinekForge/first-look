# Step 3W · Windows 装机

> **核心提醒（每一步都适用）**
> - 一次一个命令，等反馈再进下一步
> - 具体方案先回本文件查，不凭印象
> - 求稳 ≠ 求对 · 用户的朴素直觉值得被验证
> - 诊断看完整 transcript，不看末尾几行

---

**只在她用 Windows 时走这条。** 如果她用 Mac,应该上传的是 `step-3m-mac装机.md`。

Windows 的路径比 Mac 短一步——不需要装 Homebrew，用 Anthropic 官方 PowerShell installer 直接装 Claude Code。但在中国大陆，**代理仍然是必需的**（不然 install.ps1 下载 CC 会失败）。

**前置**：Step 0 已经要求她装 Git for Windows 了——如果还没装，先回去装完。

---

#### 3W.0 先确认 Claude Code 的当前状态

同 Mac,装机前先判断她是否已有 Claude Code,避免重复装或错过卸旧版的时机。但 Windows 下这个 check 需要先把 PowerShell 打开——所以先跟着 3W.1 打开 PowerShell,然后**在跑 3W.2 的代理之前**,做以下判断:

> 在 PowerShell 里粘这一行:
>
> ```powershell
> claude --version
> ```
>
> 两种结果:
> - **报错 / "not recognized"** → 没装过。继续走 3W.2 开始装机流程
> - **看到版本号（比如 `2.x.x`）** → 之前装过,继续下一步判断是什么方式装的

**已装 → 判断渠道**:

> 先 check winget:
>
> ```powershell
> winget list Anthropic.ClaudeCode 2>$null | Select-String ClaudeCode
> ```
>
> - **有命中** → winget 装的（官方推荐路径）,**保留**。跳过 3W.4(装 CC),**直接从 3W.2 做代理** → 3W.3 验证 → 步骤 4

> 没命中再 check 官方 PowerShell installer（装到 `~/.local/bin/`):
>
> ```powershell
> Test-Path $env:USERPROFILE\.local\bin\claude.exe
> ```
>
> - **True** → 官方 `irm claude.ai/install.ps1 | iex` 装的,**保留**。同 winget,跳到 3W.2 做代理 → 步骤 4

> 都不命中再 check 废弃的 npm 渠道:
>
> ```powershell
> npm list -g --depth=0 2>$null | Select-String "@anthropic-ai/claude-code"
> ```
>
> - **命中** → npm 废弃渠道。**建议卸掉后用官方 PowerShell installer 重装**:
>   > 你之前装的是旧版本,通过 npm 装的。这个渠道 Anthropic 不再维护,可能有 bug。我们先卸掉它,然后用官方 PowerShell installer 重装——整个过程我带着你走。
>
>   卸载 + 验证:
>   ```powershell
>   npm uninstall -g @anthropic-ai/claude-code
>   Get-Command claude -ErrorAction SilentlyContinue
>   ```
>   第二行应该**没有输出**(已卸干净)。然后走 3W.2 开始完整装机。
>
> - 都不命中 → 不常见,让她跑 `Get-Command claude | Select-Object -ExpandProperty Source` 把路径发给你,基于路径判断

如果任何 check 命令本身报错（比如 `winget` / `npm` 不在 PATH）,跳过那条 check——说明那个工具没装,对应不是她装 CC 的渠道。

#### 3W.1 打开 PowerShell（不是 CMD、不是 Git Bash）

她装 Git for Windows 后系统里多了几个终端。**我们全程只用 PowerShell**——你要让她开对那一个。

> 打开 PowerShell：
>
> 1. 按键盘上的 **Windows 键**（左下角 Ctrl 旁边那个带 Windows 图标的键）
> 2. 直接输入 "powershell"（不用打引号）
> 3. 在搜索结果里点**第一个**（通常是 "Windows PowerShell" 或 "PowerShell"）
>
> 打开后你会看到一个深色窗口，底部有一行 `PS C:\Users\你的用户名>`。**看到 `PS` 开头的提示符就对了**——那就是 PowerShell。
>
> 如果看到的是 `C:\Users\xxx>`（没 `PS`）——那是 CMD，关掉重开一次。
> 如果看到的是 `用户名@电脑名 MINGW64 ~` + 绿色——那是 Git Bash，关掉重开一次。
>
> 到 PowerShell 了告诉我。

**chatbox 注意**：三个终端对纯小白来说外观很像但不能混用：
- **PowerShell**（我们要的）：深色窗口、`PS >` 提示符
- **CMD / Command Prompt**：深色窗口、`C:\xx>` 提示符、**不要用**（语法不一样）
- **Git Bash**：深色窗口、绿色 `$` 提示符、**不要用**（Claude Code 内部自己调用，她不要手动开）

如果她开错了只是认错终端的问题，关掉重开就好——不是装错了东西。

#### 3W.2 一次性搞定代理

**(a) 让她亲自查端口号**

和 Mac 用户一样，**不要凭默认值猜**。

> 打开你的代理工具面板（Clash for Windows / ClashX / Surge / 其他），看一眼端口号是多少。一般在「常规」或「General」标签页，找「HTTP Proxy Port」或「混合代理端口」。
>
> 告诉我这个数字。

**(b) 代理工具开机自启**

> 把代理工具设成**开机自启**。Clash for Windows 一般在 "General → Start with Windows" 打开。其他工具找 "Start at login" / "Run at startup" 之类的选项。
>
> 不然重启电脑后代理没开，Claude Code 连不上 Anthropic。

**(c) 一次性持久化四个代理环境变量（系统级）**

Windows 下最稳的办法是设**系统用户级环境变量**——所有程序都能读到，重启也不丢。

**重要概念（告诉她）**：

> Windows 上的代理其实有两套：
>
> 1. **「系统代理」**（Internet Options → Proxy）——浏览器（Chrome、Edge）走这套
> 2. **「环境变量代理」**（HTTPS_PROXY / HTTP_PROXY）——**终端程序和命令行工具走这套**
>
> 你的 Clash / Surge 一般自动设了**第 1 种**（所以你的浏览器能上 Google）。但我们接下来要用的 curl、Claude Code **读的是第 2 种**——系统里必须同时有第 2 种设置，它们才能通。
>
> 这就是下面这一步要干的事——把你 Clash 的端口号，"告诉"Windows 的环境变量系统。


给她**一整块 PowerShell 命令**（把 `{PORT}` 换成她的端口号）：

```powershell
# 系统用户级环境变量（持久化，重启不丢）
[Environment]::SetEnvironmentVariable("HTTPS_PROXY", "http://127.0.0.1:{PORT}", "User")
[Environment]::SetEnvironmentVariable("HTTP_PROXY", "http://127.0.0.1:{PORT}", "User")
[Environment]::SetEnvironmentVariable("https_proxy", "http://127.0.0.1:{PORT}", "User")
[Environment]::SetEnvironmentVariable("http_proxy", "http://127.0.0.1:{PORT}", "User")

# 当前 PowerShell 会话立即生效（上面那 4 行要重开终端才对新进程生效）
$env:HTTPS_PROXY = "http://127.0.0.1:{PORT}"
$env:HTTP_PROXY = "http://127.0.0.1:{PORT}"
$env:https_proxy = "http://127.0.0.1:{PORT}"
$env:http_proxy = "http://127.0.0.1:{PORT}"
```

**为什么大小写都要**：curl / 部分程序读小写；Claude Code 底层（Node.js）读大写。都写了才保险。

**为什么分两段**：`SetEnvironmentVariable` 写到系统——重启不丢，但**新开的 PowerShell 才能读到**。`$env:` 设置当前会话——立刻生效，但退出就没了。**两段一起上**，才能"当前立即能用 + 以后也不用重设"。

**快速验证 4 个变量都进当前 PowerShell 了**：

> 粘这一行：
>
> ```powershell
> Get-ChildItem Env: | Where-Object { $_.Name -match '^(HTTPS?_PROXY|https?_proxy)$' }
> ```
>
> 应该看到 4 行——HTTPS_PROXY、HTTP_PROXY、https_proxy、http_proxy，都是同一个端口。少任何一行就回上一步，把 `$env:` 那 4 行再粘一次。

#### 3W.3 验证代理真通了

> 粘这两行测试（PowerShell 里 `curl` 是 `Invoke-WebRequest` 的别名，我们要用 `curl.exe` 这个真正的 curl 程序）：
>
> ```powershell
> curl.exe -I -m 10 https://github.com
> curl.exe -I -m 10 https://www.anthropic.com
> ```
>
> 两个都要看到 `HTTP/2 200` 或 `HTTP/1.1 200`。
>
> - **两个都失败**：代理工具开着吗？端口对吗？`SetEnvironmentVariable` 那几行和 `$env:` 那几行都跑了吗？
> - **GitHub 通但 Anthropic 不通**：你的代理没覆盖 Anthropic 域名。两条路选：
>   - **加规则**（推荐，精准）：在代理工具里给 `anthropic.com` 和 `api.anthropic.com` 加一条走代理的规则
>   - **临时切全局**（粗暴，但最快）：代理工具切到全局模式。装完之后你愿意再切回原模式
> - **两个都通**：过闸，进下一步

**⚠ 同 Mac：不要建议她换节点——Claude Pro 账号换 IP 被风控识别，封号概率极高。**

#### 3W.4 装 Claude Code

> Anthropic 官方的 PowerShell installer——粘这行：
>
> ```powershell
> irm https://claude.ai/install.ps1 | iex
> ```
>
> `irm` 是 `Invoke-RestMethod`、`iex` 是 `Invoke-Expression`——连起来的意思是"下载 install.ps1 的内容然后执行"，是 PowerShell 版的 `curl ... | bash`。
>
> 下载 + 装要 1-3 分钟。装完会提示类似 "Claude Code installed"。

**装完要重开 PowerShell**——这样新的 PATH 生效，`claude` 命令才能被找到：

> 装完**关掉这个 PowerShell 窗口**，重新开一个 PowerShell（按开始键搜 "PowerShell"，点开）。
>
> 在新窗口里输这一行验证：
>
> ```powershell
> claude --version
> ```
>
> 看到版本号就对了（比如 `2.1.112`）。

**如果 `claude --version` 报 "not recognized"**——可能是两个不同的 Windows installer 坑之一，先诊断再修：

**先看 claude.exe 到底在不在**：

> 粘这一行：
>
> ```powershell
> Test-Path $env:USERPROFILE\.local\bin\claude.exe
> ```
>
> 看输出：
> - **True**（文件在）→ **坑 1**：PATH 没加上（官方 issue #21365）
> - **False**（文件不在）→ **坑 2**：installer 报成功但文件没创建（官方 issue #14942），要换方法重装

**坑 1 修法（True 走这条）**：

> 粘这一行把 PATH 加上：
>
> ```powershell
> [Environment]::SetEnvironmentVariable("PATH", "$env:USERPROFILE\.local\bin;" + [Environment]::GetEnvironmentVariable("PATH", "User"), "User")
> ```
>
> 然后**关掉这个 PowerShell 窗口、再开一个新的**（PATH 设置只有新开的窗口才读得到）。在新窗口里再跑 `claude --version`。

**坑 2 修法（False 走这条）**：

> installer 那一版这次装不上。换 winget 这个 Windows 官方包管理器再装一次：
>
> ```powershell
> winget install Anthropic.ClaudeCode
> ```
>
> 期间可能会弹"允许此应用对你的设备进行更改？"——点"是"。
>
> 装完关掉 PowerShell 重开一个，跑 `claude --version`。
>
> （如果 winget 也报"找不到命令"——Windows 10 早期版本没 winget，让她先装 App Installer: https://apps.microsoft.com/detail/9NBLGGH4NNS1）

---

#### 3W 阶段收尾（Windows 走完这里进步骤 4）

到这里她已经：
- ✅ Git for Windows 装好（Claude Code 内部用）
- ✅ 代理设置在系统级环境变量里（重启不丢）
- ✅ 代理工具开机自启
- ✅ Claude Code 装好，`claude --version` 能返回版本
- ✅ curl 测通 Anthropic

**后面她再也不用手动设代理、不用担心 PATH、不用担心重启电脑坏掉。**

---


---

## 这一步完成了

到这里她已经：
- ✅ Git for Windows 装好
- ✅ 代理设置在系统级环境变量里
- ✅ 代理工具开机自启
- ✅ Claude Code 装好
- ✅ curl 测通 Anthropic

告诉她：

> 装机完成了。你收到的文件包里还有一个叫 **`step-4-7-安装启动.md`** 的文件，拖进来给我，我们进入最后一段——把配置写进去、启动 Claude Code。
