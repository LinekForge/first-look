# Contributing to first-look

谢谢你愿意 contribute。这个项目帮助非技术用户第一次上手 Claude Code——每一个改进都直接影响她们的第一印象。

## 项目定位

- **受众**：中国大陆 + 非技术用户（没用过终端、没写过代码）
- **哲学**：复杂度我们吃下,她只看到陪伴;判断交给 chatbox,机械留给脚本
- **Scope 边界**：当前只服务中国大陆环境。扩到境外 / 其他平台请先在 issue 里讨论再开工——避免把 repo 的 assumption 冲散

## 本地测试

first-look 不需要装依赖——全是 bash + PowerShell + markdown。测试分三层：

### install.sh（Mac + Windows Git Bash）

造一个 mock config 跑一遍：

```bash
# 1. 写一个最小合法的 merged bundle
cat > /tmp/test-config.md <<'EOF'
===== FIRST-LOOK START =====
===== FILE: first_greeting.txt =====
测试开场白。

===== FILE: CLAUDE.md =====
# 测试用户
## 关于我
测试中
===== FIRST-LOOK END =====
EOF

# 2. 在一个 fake HOME 里跑,不污染真 ~/.claude/
TEST_HOME=$(mktemp -d)
HOME="$TEST_HOME" bash install.sh /tmp/test-config.md

# 3. verify
ls "$TEST_HOME/.claude/"
cat "$TEST_HOME/.claude/CLAUDE.md"
```

改动 install.sh 之后至少过这三个用例：
- 正常 bundle → 正确解析写入
- 已存在 CLAUDE.md → 弹 [O/B/Q] 幂等交互
- bundle 格式错误（缺分隔符 / 非 .md 文件名） → 友好报错不崩

### install.ps1（Windows PowerShell）

本地 mac 不能完整测——至少静态检查：

```bash
# 语法检查(需要 PowerShell Core)
pwsh -c "Get-Command -Syntax install.ps1" 2>/dev/null || echo "跳过,本地没装 pwsh"
```

真实的 Windows 回归需要真机——在 PR 描述里说明你在哪个 Windows 版本 + PowerShell 版本跑过。

### guide/ 文件套组（Claude Desktop 对话）

chatbox 引导文件已拆成文件套组（`地图.md` + 5 份 `step-*.md`）。改动难以自动化测试。建议：

1. 开一个新的 Claude Desktop 对话
2. 上传 `guide/地图.md` + 你改的那份 `step-*.md` + `install.sh`（Windows 再加 `install.ps1`）
3. 从对应 step 开始走一遍,看 chatbox 表现
4. 特别关注你改动涉及的 step——边界情况是否被覆盖
5. 如果改了跨 step 的内容（如地图里的"绝对不要做"），拉通走完整流程

真机测试比自审高 10 倍价值。有条件找一个非技术朋友跑一遍最好。

## 贡献类型

欢迎：

- **Bug 报告**：install 脚本在特定环境下失败、prompt 某一步让用户卡住、文档错误
- **措辞改进**：让 chatbox 对用户的话更准确 / 更温和 / 更清晰
- **Edge case 覆盖**：prompt 里没预见到的安装环境 / 终端 / 代理行为
- **非中国大陆 adapter**：境外用户的路径(如果你想做,先开 issue 讨论 scope)
- **新的 blueprint scaffold 示例**：如果你用 first-look 搭出了有价值的 `~/.claude/` 结构,欢迎 back-port

不太合适：

- 把项目扩展成通用 onboarding 工具——first-look 有意 opinionated
- 加运行时依赖（当前零依赖是 feature）
- 加 telemetry / 分析 / 任何回传维护者的机制（SECURITY.md 承诺过不做）

## PR 流程

1. Fork → branch（`fix/xxx` 或 `feat/xxx`）
2. 改动 + 按上面跑相应层的测试
3. PR 描述带：
   - 动机（解决什么问题 / 改进什么体验）
   - 影响范围（只动了 install.sh? 还是 prompt + install 联动?）
   - 测试结果（哪些用例过了 / 哪些场景你没测到）

## 安全问题

**不要发 public issue**。通过 GitHub Security Advisory 提交 private report,详见 [SECURITY.md](SECURITY.md)。

涉及用户隐私的问题（install 脚本可能泄漏数据 / prompt 引导用户做不安全操作）一律按安全问题处理。

## License

MIT。提交 PR 即同意你的代码以 MIT 开源。
