# Claude Code 初见引导 · 已拆分为文件套组

> **这份文件是旧的单体 prompt**。内容已拆分为以下文件套组，chatbox 的注意力更集中，用户体验更好。

## 新的文件套组

| 文件 | 用途 |
|------|------|
| [`地图.md`](地图.md) | chatbox 的全流程一览（第一份读的） |
| [`step-0-1-了解你.md`](step-0-1-了解你.md) | 前置确认 + 了解她（承接/访谈） |
| [`step-2-生成配置.md`](step-2-生成配置.md) | 画像确认 + 生成配置文件 + 输出规范 |
| [`step-3m-mac装机.md`](step-3m-mac装机.md) | Mac 装机（代理 + Homebrew + CC） |
| [`step-3w-windows装机.md`](step-3w-windows装机.md) | Windows 装机（代理 + Git + CC） |
| [`step-4-7-安装启动.md`](step-4-7-安装启动.md) | 跑 install.sh + 首次启动 + 验证 |
| [`../给你自己看.md`](../给你自己看.md) | 给人类用户自己读的使用说明 |

## 怎么用

用户把 `地图.md` + `step-0-1-了解你.md` + `install.sh`（Windows 再加 `install.ps1`）一起上传给 chatbox。每步完成后 chatbox 会提醒用户上传下一份文件。

## 为什么拆

单体 prompt (~1200 行) 导致 chatbox 注意力被大幅稀释——chatbox 靠训练数据 prior 而非读 prompt 内容给方案（实测踩过：凭印象推荐清华源而非 prompt 指定的 USTC）。拆成文件套组后，chatbox 当前 context 只含"地图(短) + 当前 step 文件(聚焦)"，依从性显著提升。
