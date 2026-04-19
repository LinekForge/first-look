# first-look · install.ps1
#
# Windows 用户的入口：让你在 PowerShell 里直接跑这个脚本、不用开 Git Bash。
#
# 用法（在 PowerShell 里）：
#   .\install.ps1                           # 自动在桌面找 first-look-config.md
#   .\install.ps1 C:\path\to\config.md      # 指定配置文件路径
#
# 实际逻辑在 install.sh 里——这个脚本只是找 Git Bash 然后让它跑 install.sh。
#
# 前置：
#   - Claude Code 已经装好（irm https://claude.ai/install.ps1 | iex 装的）
#   - Git for Windows 已经装好（Claude Code 内部需要——非必须的话，这个脚本会告诉你）

$ErrorActionPreference = "Stop"

# 找 install.sh（脚本同目录）
$scriptDir = $PSScriptRoot
$installSh = Join-Path $scriptDir "install.sh"

if (-not (Test-Path $installSh)) {
    Write-Error "找不到 $installSh——请确认 install.sh 和 install.ps1 在同一个文件夹里。"
    exit 1
}

# 找 Git Bash（尝试几个常见位置）
$bashCandidates = @(
    "C:\Program Files\Git\bin\bash.exe",
    "C:\Program Files (x86)\Git\bin\bash.exe",
    "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe"
)

$bashExe = $null
foreach ($candidate in $bashCandidates) {
    if (Test-Path $candidate) {
        $bashExe = $candidate
        break
    }
}

# Fallback: 从 PATH 里找 bash.exe——但只接受路径里含 "Git" 的（排除 WSL 的 bash）
if (-not $bashExe) {
    $bashFromPath = Get-Command bash.exe -ErrorAction SilentlyContinue
    if ($bashFromPath -and $bashFromPath.Source -like "*Git*") {
        $bashExe = $bashFromPath.Source
    }
}

if (-not $bashExe) {
    Write-Host ""
    Write-Host "  ✗ 找不到 Git Bash。" -ForegroundColor Red
    Write-Host ""
    Write-Host "  first-look 需要 Git for Windows 的 Git Bash 来跑安装脚本。" -ForegroundColor Yellow
    Write-Host "  Claude Code 本身也需要它（它内部用 Git Bash 跑命令）。"
    Write-Host ""
    Write-Host "  请先去装 Git for Windows:" -ForegroundColor Cyan
    Write-Host "  https://git-scm.com/downloads/win"
    Write-Host ""
    Write-Host "  装完重新打开 PowerShell，再跑 .\install.ps1"
    Write-Host ""
    Write-Host "  如果你已经装过了但还是报这个错——"
    Write-Host "  把这段报错复制回你的 chatbox，告诉它你装到了哪里。"
    Write-Host "  可能你装到了非标准位置，需要手动指定路径。"
    Write-Host ""
    exit 1
}

# 把 Windows 路径转成 Git Bash 风格（C:\Users\x → /c/Users/x）
function Convert-ToBashPath {
    param([string]$winPath)
    if ([string]::IsNullOrEmpty($winPath)) { return "" }
    $bashPath = $winPath -replace '\\', '/'
    if ($bashPath -match '^([A-Za-z]):(.*)$') {
        $drive = $matches[1].ToLower()
        $rest = $matches[2]
        return "/$drive$rest"
    }
    return $bashPath
}

# 把传给 .ps1 的参数转成 Bash 路径，再传给 install.sh
$bashArgs = @()
foreach ($arg in $args) {
    # 如果看起来像文件路径（含盘符或反斜杠），转换；否则原样传
    if ($arg -match '^[A-Za-z]:\\' -or $arg -match '\\') {
        $bashArgs += (Convert-ToBashPath $arg)
    } else {
        $bashArgs += $arg
    }
}

# 调 Git Bash 跑 install.sh
$bashInstallPath = Convert-ToBashPath $installSh
& $bashExe $bashInstallPath @bashArgs
exit $LASTEXITCODE
