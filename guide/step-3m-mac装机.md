# Step 3M · Mac 装机

> **核心提醒（每一步都适用）**
> - 一次一个命令，等反馈再进下一步
> - 具体方案先回本文件查，不凭印象
> - 求稳 ≠ 求对 · 用户的朴素直觉值得被验证
> - 看到 `SSL_ERROR_SYSCALL` → 默认假设代理 MITM，先看 `no_proxy`
> - 诊断看完整 transcript，不看末尾几行

---

**只在她用 Mac 时走这条。** Windows 用户跳到"步骤 3W"。

---

#### 3M.0 先确认 Claude Code 的当前状态

装机前先判断她是否已有 Claude Code——避免把已装的盖掉或错过卸载旧版的时机。

> 打开终端（`Cmd + 空格`,输入"终端",回车）。

**如果这是她第一次打开终端**,她会看到类似 `用户名@电脑名 ~ %` 的一行文字。**主动解释一下**:

> 屏幕上 `用户名@电脑名 ~ %` 这行不是要你输入的内容——那是终端在等你输命令。`%` 后面闪烁的光标就是输入的地方,直接粘我给你的命令就好。

这个 5 秒的解释能避免用户以为提示符是需要操作的东西。

粘这一行:
>
> ```
> claude --version
> ```
>
> 两种结果:
> - **`command not found`** → 没装过。**跳到 3M.1**,走完整装机流程
> - **看到版本号（比如 `2.x.x`）** → 之前装过,继续下一步判断是什么方式装的

**已装 → 判断渠道**:

> 粘这几行(用 if/fi 结构比 `&& || ` chain 更稳,避免某些 shell 下静默完成):
>
> ```
> if brew list --cask 2>/dev/null | grep -q claude-code; then
>     echo "brew 装的"
> else
>     echo "不是 brew 装的"
> fi
> ```

- **"brew 装的"** → 官方推荐渠道,**保留**。告诉她:
  > 你之前装过 Claude Code（而且是官方最推荐的 Homebrew 方式）。我们就不重装了,直接把代理配好、把配置写进去、启动它就行。

  跳过 3M.1(Xcode CLT) 和 3M.4-3M.5(Homebrew + 装 CC),**直接从 3M.2 做代理** → 3M.3 验证 → 步骤 4。
  
- **"不是 brew 装的"** → 很可能是废弃渠道(npm 或 bun),继续 verify:
  > ```
  > npm list -g --depth=0 2>/dev/null | grep "@anthropic-ai/claude-code" && echo "npm 装的"
  > ls ~/.bun/bin/claude 2>/dev/null && echo "bun 装的"
  > ```
  
  - **命中 npm 或 bun** → 废弃渠道。**建议卸掉后用 Homebrew 重装**。告诉她:
    > 你之前装的是一个旧版本,是通过 [npm / bun] 装的。这个渠道 Anthropic 官方已经不再维护,可能有 bug(比如 `claude` 命令能跑但功能不全)。我们先卸掉它,然后用官方现在推荐的 Homebrew 重装——整个过程我带着你走,不用担心。
    
    卸载命令(按她实际的渠道选):
    - **npm 装的**: `npm uninstall -g @anthropic-ai/claude-code`
    - **bun 装的**: `bun uninstall -g @anthropic-ai/claude-code`
    
    **如果报 `EACCES` 权限错误**——说明当初是 `sudo npm install -g` 装的(package 所有权是 root),卸载也要加 sudo:
    - `sudo npm uninstall -g @anthropic-ai/claude-code`
    - (bun 不存在这个问题,因为 bun 全局包默认装到用户目录 `~/.bun/`,不需要 sudo)
    
    卸完验证:
    ```
    command -v claude || echo "已卸干净"
    ```
    看到"已卸干净"就好。然后**走 3M.1 开始完整装机**。
  
  - **都不命中** → 不常见的装法。让她跑 `which claude` 把完整路径发给你,基于路径判断(可能是官方 installer 装到 `~/.local/bin/claude`——那就保留,跳过装机)

如果任何命令跑不过(比如 `brew` 或 `npm` 本身不在 PATH),不用慌——说明那个工具本身没装,对应渠道就不是她装 CC 的渠道,跳过那条 check 即可。

#### 3M.1 先装 Xcode Command Line Tools（走苹果，不经代理）

> 打开「终端」（`Cmd + 空格`，输入"终端"，回车）。粘贴这一行，回车：
>
> ```
> xcode-select --install
> ```
>
> 屏幕会弹出一个小窗口问「是否安装」，点「安装」。等它装完（5-10 分钟）。装完告诉我。

**要点**：
- 如果她说"已经装过了"或报错 `already installed`——跳过，进 3.2
- 这步**不要代理**，走苹果官方服务器，大陆直连就通
- **不要用 `softwareupdate` 方式**装 CLT——常触发 PKDownloadError

#### 3M.2 一次性搞定代理（本项目所有卡点的根源都在这里）

本项目只服务于中国大陆用户。代理是必需的，不是可选。这一步把**她以后永远不用再想代理**这件事一次做完。

**(a) 确认端口号**

**你（chatbox）不要凭默认值猜**——Clash 默认 7890、Surge 默认 6152 这些很多人改过。实际可能是 7897、7899 之类的非默认。让她去代理工具面板看一眼告诉你：

> 打开你的代理工具面板，看一眼端口号是多少——告诉我那个数字。
>
> - Clash 系（ClashX / Clash Verge / Clash for Windows）：「常规 / General」里的「HTTP Proxy Port」或「混合代理端口」
> - Surge：首页或状态栏
> - 其他：找「HTTP/HTTPS Proxy Port」

**(b) 开机自启**

> 顺便把代理工具设成**开机自启**。工具设置里找「启动项」或「Launch at Login」打开。不然明天重启电脑后代理没开，Claude Code 会连不上——你会以为昨天装好的东西坏了。

**(c) 一次性持久化代理 + 直连配置**

先让她运行 `echo $SHELL` 看她的 shell：
- `/bin/zsh` → profile 文件是 `~/.zshrc`
- `/bin/bash` → profile 文件是 `~/.bash_profile`

然后给她**一整块命令**（`{PORT}` 换成她的端口、`{PROFILE}` 换成 `~/.zshrc` 或 `~/.bash_profile`）：

```
cat >> {PROFILE} << 'EOF'
export https_proxy=http://127.0.0.1:{PORT}
export http_proxy=http://127.0.0.1:{PORT}
export HTTPS_PROXY=http://127.0.0.1:{PORT}
export HTTP_PROXY=http://127.0.0.1:{PORT}
export no_proxy="mirrors.ustc.edu.cn,.edu.cn,.cn,localhost,127.0.0.1"
export NO_PROXY="mirrors.ustc.edu.cn,.edu.cn,.cn,localhost,127.0.0.1"
EOF
source {PROFILE}
```

**为什么大小写都要**：curl / brew 等工具读小写；Claude Code 底层（Node.js undici）读大写。都写了才能保证装机时代理通、运行时也通。`no_proxy` 同理——有些工具读小写有些读大写。

**为什么要 `no_proxy`**（**很重要**）：前 4 行告诉终端"走代理",`no_proxy` 告诉终端"**这些域名不走代理,直连**"。

为什么直连？后面装 Homebrew 时我们要用 USTC（中国科学技术大学）镜像。USTC 服务器在中国大陆——**她在中国大陆 → USTC 在中国大陆 → 直连最快最稳**。如果不设 `no_proxy`,USTC 的流量也会绕到代理的海外节点再回来——绕路、慢、而且**代理会 MITM SSL 连接导致 USTC 的 https 握手失败**（表现为 `SSL_ERROR_SYSCALL`,这是中国大陆 Homebrew 装机最常见的卡死原因之一）。

告诉她："**国内的服务直连快,国外的服务走代理——我们一开始就把两件事都设上,后面少踩坑。**"

**快速验证 6 个变量都进当前 shell 了**（`source` 有时会静默吃掉某行）：

> 粘这一行看看：
>
> ```
> env | grep -i proxy
> ```
>
> 应该看到 6 行——4 个 proxy + 2 个 no_proxy,都是刚才设的值。少任何一行就回上一步重新 `source` 或检查 profile 文件。

#### 3M.3 验证代理真通了（装任何东西前的最后一闸）

> 粘这两行测试：
>
> ```
> curl -I -m 10 https://github.com
> curl -I -m 10 https://www.anthropic.com
> ```
>
> 两个都要看到 `HTTP/2 200` 或 `HTTP/1.1 200`。
>
> - **两个都失败**：代理工具开着吗？端口对吗？3.2(c) 的 `cat >> ... EOF` 和 `source` 跑成功了吗？
> - **GitHub 通但 Anthropic 不通**：你的代理没覆盖 Anthropic 域名。告诉她有两条路可以选，让她挑：
>   - **加规则**（推荐，精准）：在代理工具里给 `anthropic.com` 和 `api.anthropic.com` 加一条走代理的规则。Clash 系的「代理」页能加
>   - **临时切全局**（粗暴，但最快）：代理工具切到全局模式。只建议装机 + 测试这段时间切，之后她愿意再切回原来的模式
>
> **⚠️ 不要建议她换节点**。Claude Pro 账号换不同国家 IP 登录会被 Anthropic 风控识别为异常，**封号概率极高**。她一旦登录用的是某个节点，就保持那个节点，别乱换。
> - **两个都通**：过闸，进下一步

**这一步不通就不要往下**。装了也是白装——她发第一句话会 403，之前的所有努力浪费。

#### 3M.4 装 Homebrew（装完立即持久化 PATH）

**在中国大陆代理环境下**,直接走 GitHub 主仓库的 git clone 经常会被代理节点 CANCEL 掉(Homebrew 主仓库几百 MB,大流量长连接不稳,装机失败率高)。因此**推荐走国内镜像源 + API 分发**。

##### 关于镜像源 · 摆明事实

- Homebrew 官方**支持** `HOMEBREW_BREW_GIT_REMOTE` / `HOMEBREW_CORE_GIT_REMOTE` / `HOMEBREW_BOTTLE_DOMAIN` / `HOMEBREW_API_DOMAIN` / `HOMEBREW_INSTALL_FROM_API` 等环境变量让用户自定 git remote + bottles 下载源 + API——**这是 official-documented 机制,不是 hack**。官方文档: [docs.brew.sh/Installation](https://docs.brew.sh/Installation)
- 我们默认推荐 **USTC(中国科学技术大学)镜像**,由 USTC 运维; 镜像说明页: [mirrors.ustc.edu.cn/help/brew.git.html](https://mirrors.ustc.edu.cn/help/brew.git.html) + [mirrors.ustc.edu.cn/help/homebrew-bottles.html](https://mirrors.ustc.edu.cn/help/homebrew-bottles.html)
- 如果你(chatbox)或她对镜像的合法性有疑虑,**你可以去 fetch 上面两个 URL 核实**——**不要靠记忆断言** `HOMEBREW_*_GIT_REMOTE` 是否有效。该机制 2021+ 的 Homebrew install.sh 都支持

##### 两条路,推荐镜像 · 用户可选

告诉她:

> 装 Homebrew 有两条路——我推荐走**国内镜像源**。GitHub 主仓库在代理下大流量 git clone 容易被中断(Homebrew 几百 MB)。

**推荐路径 · USTC 镜像**:

> 粘这一整段:
>
> ```
> export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
> export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
> export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
> export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"
> export HOMEBREW_INSTALL_FROM_API=1
> /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
> ```

**备选路径 · GitHub 原始**(如果她对镜像有顾虑 / 代理非常稳定):

> ```
> /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
> ```

会问 Mac 开机密码(输入时屏幕不显示字符,正常的,输完回车)。3-5 分钟装完。

**如果下载很慢（100KB/s 级别,持续 10 分钟以上）但在走**:

告诉她等。**不要鼓励她在下载过程中切换代理节点 / 切代理模式**——git clone 的长连接对网络中断异常脆弱,一断就要全部重传。在慢但在走的时候,**稳定性 > 速度**。

如果她焦虑,可以解释:"这个下载大概 200MB 左右,网速慢但只要没断就在进。切代理会断开当前连接,之前下的全部重来。我们等它走完。"

**如果她问"镜像可信吗?"**——不要凭记忆答,也不要含糊回避。你可以**去 fetch Homebrew 官方文档和 USTC 镜像页核实再回答**,URL 在上面"关于镜像源 · 摆明事实"那节。

##### 如果走镜像会踩一个已知错误(不致命,已知修法)

install.sh 最后一步可能报:

```
error: Not a valid ref: refs/remotes/origin/master
Failed during: /usr/bin/git remote set-head origin --auto
```

**原因**:镜像源的默认分支是 `main`,但 install.sh 硬编码期待 `master`(上游历史包袱)。**数据其实已经拉下来了,只是 working tree 没 checkout** —— brew 二进制暂时不存在。

告诉她:

> 看到 `Not a valid ref: master` 不用慌——文件已经下载完了,只是差一步切到 `main` 分支。粘这几行修好:
>
> ```
> cd /opt/homebrew    # 如果是 Intel Mac 改成 /usr/local/Homebrew
> git checkout main
> ls bin/             # 应该看到 brew 出现
> ```
>
> 看到 `brew` 文件就 OK。继续下面的 PATH 持久化。

##### Portable Ruby · 走 ghcr.io 不走 USTC（结构性事实）

**Portable Ruby 不在 USTC 镜像覆盖范围内**——已核实 USTC 的 `homebrew-bottles` 目录不包含 Portable Ruby 的 bottle 文件。Portable Ruby 是 Homebrew 内部 bootstrap 文件,USTC 只镜像普通 formula bottles。

所以即使设了 `HOMEBREW_BOTTLE_DOMAIN` 指向 USTC,Homebrew 5.x 仍然会去 **`ghcr.io`（GitHub Container Registry）** 拉 Portable Ruby——这一步**只能靠代理稳定**。

好消息是:**3M.2 已经设了 `no_proxy`**,USTC 的流量走直连,ghcr.io 的流量走代理——两者互不干扰。这是最稳的状态。

如果 Portable Ruby 下载报 SSL 错误(`SSL_ERROR_SYSCALL` 等)——走方案:
1. 先检查 `no_proxy` 是否设好了(回 3M.2 验证 `env | grep -i proxy` 看 6 行)
2. 如果 `no_proxy` 在但 ghcr.io 还是 SSL 失败 → 试 SOCKS5:`ALL_PROXY=socks5h://127.0.0.1:{PORT} brew update`
3. 如果还不行 → 用浏览器手动下载 ghcr.io 上的 Portable Ruby(浏览器走系统代理通常没 SSL 问题)

##### 装机报满屏 Error 不要慌——先验证 brew 存不存在

**通用诊断准则**:无论 Homebrew install.sh 或 `brew update` 报什么错,**第一件事是验证 `/opt/homebrew/bin/brew --version`（Intel Mac 用 `/usr/local/bin/brew --version`）能不能跑出版本号**。

- 跑出版本号 → **主体装好了,只是收尾步骤失败**(如 Portable Ruby 没拉到 / formula JSON 没更新)——可恢复,不用重来
- 跑不出 → 主体没装上,需要排查或重来

**不要根据屏幕上的 Error 数量来判断状态**。Homebrew install 收尾时 `brew update --force --quiet` 经常刷一大堆 `Failed to download formula.jws.json` + `Failed to install Homebrew Portable Ruby`——**看着吓人但 brew 主体已经在了**。

##### 遇到 `SSL_ERROR_SYSCALL` 的诊断顺序

如果装机过程中出现 `curl: (35) LibreSSL SSL_connect: SSL_ERROR_SYSCALL` 或类似 SSL 错误:

**默认假设是代理 MITM,不是节点不稳定**。诊断顺序:

1. **先看 `no_proxy`**——出错的 URL 是 `.edu.cn` / `.cn` 域名吗?如果是,说明它走了代理被 MITM,加到 `no_proxy` 即可
2. **看代理协议**——HTTP 代理的 MITM 是 SSL 错误最常见的根因。试 SOCKS5:`ALL_PROXY=socks5h://...`(SOCKS5 不 MITM,直接透传 SSL)
3. **最后才怀疑节点 / 镜像 / 网络**——这是 fallback 假设,不是第一反应

**不要反复让用户切镜像源 / 加 fallback 镜像 / 检查重试**——SSL_ERROR_SYSCALL 的根因几乎都在代理层,不在应用层。一个 `no_proxy` 或 `ALL_PROXY=socks5h://` 就能根治。反复折腾镜像是**浪费用户时间**。

##### PATH 持久化(不管走哪条都要做)

装完之后**立即把 brew 的 PATH 持久化**到她的 profile,不要等她下次开终端发现 `brew: command not found` 再补。

**Apple Silicon 和 Intel 的 brew 安装路径不同**（`/opt/homebrew/bin/brew` vs `/usr/local/bin/brew`），**不要凭记忆写**。Homebrew 装完最后会在屏幕上打印一段 `==> Next steps:`，里面有针对她这台机器的正确命令——长这样：

```
==> Next steps:
- Run these commands in your terminal to add Homebrew to your PATH:
    echo >> /Users/xxx/.zshrc
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/xxx/.zshrc
    eval "$(/opt/homebrew/bin/brew shellenv)"
```

告诉她：

> Homebrew 装完了。屏幕上应该能看到一段 `==> Next steps:`，下面有 2-3 行 `echo ...` 和 `eval ...` 的命令。**把那几行原样复制粘贴到终端运行**——这一步把 brew 加到你的环境里，以后新开终端都能用。运行完告诉我。

然后让她跑 `brew --version` 确认——看到版本号就成。

**为什么不让 chatbox 直接写死路径**：Intel Mac 上路径是 `/usr/local/bin/brew`，Apple Silicon 是 `/opt/homebrew/bin/brew`。你（chatbox）不知道她用的是哪台机，凭记忆写可能写错，她 Intel Mac 就炸。Homebrew 自己打印的 Next steps 是针对她这台机的正确命令——**永远以屏幕为准**。

#### 3M.5 装 Claude Code

> ```
> brew install --cask claude-code
> ```
>
> 会下载约 200MB。**1-2 分钟没有任何输出是正常的**,不要关终端。看到 `🍺 claude-code was successfully installed!` 就成功了。

##### 如果 `curl: (18) Transferred a partial file` · 切 SOCKS5 重试

这是代理节点在 HTTP 大文件长连接下被中断的典型症状,跟装 Homebrew 那种 CANCEL 是同一个病——**HTTP 代理对长连接不够稳,换 SOCKS5 通常通**。

Clash 系(Clash / ClashX / Clash Verge)的**混合端口(Mixed Port)**同时支持 HTTP 和 SOCKS5,就是你在 3M.2 填的那个端口号。

告诉她:

> 这种"Transferred a partial file"是代理对长连接不太稳,我们换 SOCKS5 协议试一下。粘这两行:
>
> ```
> brew cleanup --prune=all -s
> ALL_PROXY=socks5h://127.0.0.1:{PORT} brew install --cask claude-code
> ```
>
> ({PORT} 换成你 3M.2 用的那个端口号)

关键是 `ALL_PROXY=socks5h://127.0.0.1:{PORT}`——临时让 brew 走 SOCKS5。装完回来正常使用不受影响。

##### 如果 5 分钟以上都没动静

`Ctrl+C` 中断再跑一次(网络偶尔抽风)。连续 2 次抽风就按上面 SOCKS5 方案。

装完验证:

```
claude --version
```

看到版本号,进步骤 4。

---

#### 3M 阶段收尾（Mac 走完这里进步骤 4）

到这里她已经：
- ✅ 代理自动启动、全局覆盖、四个环境变量都永久生效
- ✅ Homebrew 在 PATH 永久
- ✅ Claude Code 装好
- ✅ curl 测通 Anthropic

**后面她再也不用手动 export 任何东西、不用 eval 任何 shellenv、不用担心代理。** 关终端重开照样用、明天重启电脑照样用。

---


---

## 这一步完成了

到这里她已经：
- ✅ 代理 + 直连 配好（proxy + no_proxy 永久生效）
- ✅ Homebrew 在 PATH
- ✅ Claude Code 装好
- ✅ curl 测通 Anthropic

告诉她：

> 装机完成了。你收到的文件包里还有一个叫 **`step-4-7-安装启动.md`** 的文件，拖进来给我，我们进入最后一段——把配置写进去、启动 Claude Code。
