#!/usr/bin/env bash
#
# first-look install.sh
#
# 把 chatbox 生成的 md 配置文件解析，放到 Claude Code 能读到的位置，
# 打印开场白，启动 Claude Code。
#
# 用法：
#   bash install.sh <配置文件路径>
#   bash install.sh                （自动在桌面/下载文件夹找 first-look-config.md）
#
# 前置：Claude Code 已经装好（`claude --version` 能返回版本）。
# 如果还没装，回到你的 chatbox，让它带你装 Homebrew + Claude Code。
#
# 详细安全说明见 SECURITY.md 或 chatbox。

set -euo pipefail

# ————————————————————————
# 终端色彩 & 打印
# ————————————————————————

if [[ -t 1 ]]; then
    BOLD=$'\033[1m'
    DIM=$'\033[2m'
    GREEN=$'\033[32m'
    YELLOW=$'\033[33m'
    RED=$'\033[31m'
    CYAN=$'\033[36m'
    RESET=$'\033[0m'
else
    BOLD=''; DIM=''; GREEN=''; YELLOW=''; RED=''; CYAN=''; RESET=''
fi

ok()    { printf '  %s✓%s %s\n' "$GREEN" "$RESET" "$1"; }
info()  { printf '  %s%s%s\n' "$DIM" "$1" "$RESET"; }
warn()  { printf '  %s⚠%s  %s\n' "$YELLOW" "$RESET" "$1"; }
err()   { printf '  %s✗%s %s\n' "$RED" "$RESET" "$1" >&2; }

# 遇到用户不知道怎么处理的错误时用这个——除了报错外，指一条求助路径
die_with_chatbox_hint() {
    for msg in "$@"; do
        err "$msg"
    done
    info ""
    info "如果不知道怎么处理，把上面这段错误复制回你的 chatbox，让它帮你看。"
    exit 1
}

# 首次开场白（从 first_greeting.txt 读到）
GREETING=""

# 解析时被跳过的文件名（最后汇总告诉用户，避免静默失败）
declare -a SKIPPED_FILES=()

# 让 read 能读键盘
if [[ -r /dev/tty ]]; then
    TTY=/dev/tty
else
    TTY=/dev/stdin
fi

prompt_continue() {
    printf '  %s ' "$1"
    read -r _ < "$TTY" || true
}

# ————————————————————————
# 配置文件合并文本块格式
# ————————————————————————
#
# 起止分隔符允许 `=` 数量浮动（3+ 个），兼容 chatbox 可能的轻微格式偏差。

BUNDLE_START_RE='=+[[:space:]]*FIRST-LOOK START[[:space:]]*=+'
BUNDLE_END_RE='=+[[:space:]]*FIRST-LOOK END[[:space:]]*=+'
BUNDLE_FILE_RE='^=+[[:space:]]*FILE:[[:space:]]*(.+[^[:space:]=])[[:space:]]*=+$'

validate_bundle() {
    local content="$1"
    [[ -z "$content" ]]                                        && return 1
    # 用 printf 不用 echo——echo 对前导 `-e` `-n` 会当 flag 吞掉
    printf '%s\n' "$content" | grep -qE "$BUNDLE_START_RE"     || return 2
    printf '%s\n' "$content" | grep -qE "$BUNDLE_END_RE"       || return 3
    return 0
}

# ————————————————————————
# 安全的文件名校验
# ————————————————————————
#
# 接受 UTF-8 文件名（含中文）、数字开头、连字符。
# 拒绝路径穿越（`..`、`/`、`.` 前缀）和非 .md 文件。

is_safe_filename() {
    local name="$1"
    [[ -n "$name" ]]              || return 1
    [[ "$name" != */* ]]          || return 1
    [[ "$name" != .* ]]           || return 1
    [[ "$name" != *..* ]]         || return 1
    [[ "$name" == *.md ]]         || return 1
    # 禁止空格和 shell 元字符，避免下游工具忘记 quote 时出问题
    case "$name" in
        *[[:space:]]* | *[\`\$\;\&\<\>\(\)\|\*\?\"\']* ) return 1 ;;
    esac
    return 0
}

# ————————————————————————
# 写文件到正确位置
# ————————————————————————

write_bundle_file() {
    local filename="$1"
    local content="$2"

    # 去掉首尾所有空行
    while [[ "$content" == $'\n'* ]]; do content="${content#$'\n'}"; done
    while [[ "$content" == *$'\n' ]]; do content="${content%$'\n'}"; done

    # 特殊文件：first_greeting.txt（开场白，不写入 memory，启动前打印到终端）
    if [[ "$filename" == "first_greeting.txt" ]]; then
        # 安全：strip 控制字符（ANSI 转义、OSC 等），防 chatbox 输出的内容控制终端
        # 只删 0x00-0x08、0x0B、0x0C、0x0E-0x1F；保留 \n(0x0A)、\r(0x0D)、\t(0x09) 和所有 UTF-8 中文
        GREETING=$(printf '%s' "$content" | LC_ALL=C tr -d '\000-\010\013\014\016-\037')
        ok "收到首次开场白（${#GREETING} 字节）"
        return
    fi

    # 特殊文件：first-look-starter-tasks.md（开局任务清单，保存到桌面，不写入 memory）
    # 她可以随时打开翻看，破冰阶段挑一个开始
    if [[ "$filename" == "first-look-starter-tasks.md" ]]; then
        local tasks_dir="$HOME/Desktop"
        # Desktop 目录可能不存在(某些 Linux / 精简 macOS 环境)
        if [[ ! -d "$tasks_dir" ]]; then
            tasks_dir="$HOME"
        fi
        local tasks_path="$tasks_dir/first-look-starter-tasks.md"
        local clean_tasks
        clean_tasks=$(printf '%s' "$content" | LC_ALL=C tr -d '\000-\010\013\014\016-\037')
        if ! printf '%s\n' "$clean_tasks" > "$tasks_path" 2>/dev/null; then
            warn "开局任务清单写入失败：$tasks_path"
            SKIPPED_FILES+=("$filename")
            return 1
        fi
        ok "开局任务清单已存到：$tasks_path"
        return
    fi

    if ! is_safe_filename "$filename"; then
        err "文件名无法接受：$filename"
        err "（只允许 .md 结尾、不含 / 和 ..、不以 . 开头的文件名）"
        SKIPPED_FILES+=("$filename")
        return 1
    fi

    local target
    if [[ "$filename" == "CLAUDE.md" ]]; then
        mkdir -p "$HOME/.claude"
        target="$HOME/.claude/CLAUDE.md"
    else
        mkdir -p "$MEMORY_DIR"
        target="$MEMORY_DIR/$filename"
    fi

    if ! printf '%s\n' "$content" > "$target" 2>/dev/null; then
        err "写入失败：$target"
        SKIPPED_FILES+=("$filename")
        return 1
    fi
    ok "写入 $target"
}

parse_and_write() {
    local content="$1"
    local current=""
    local buffer=""
    local in_bundle=0
    local line
    local count=0

    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ $BUNDLE_START_RE ]]; then
            in_bundle=1
            continue
        fi
        if [[ "$line" =~ $BUNDLE_END_RE ]]; then
            if [[ -n "$current" ]]; then
                write_bundle_file "$current" "$buffer" && count=$((count + 1)) || true
            fi
            break
        fi
        (( in_bundle )) || continue

        if [[ "$line" =~ $BUNDLE_FILE_RE ]]; then
            local next_file="${BASH_REMATCH[1]}"
            if [[ -n "$current" ]]; then
                write_bundle_file "$current" "$buffer" && count=$((count + 1)) || true
            fi
            next_file="${next_file## }"
            next_file="${next_file%% }"
            current="$next_file"
            buffer=""
            continue
        fi

        buffer="${buffer}${line}"$'\n'
    done <<< "$content"

    if (( count == 0 )); then
        return 1
    fi
    return 0
}

# ========================
# 正式开始
# ========================

printf '\n'
printf '%s—————————————————————————————%s\n' "$BOLD" "$RESET"
printf '%s  first-look · Claude Code 初见%s\n' "$BOLD" "$RESET"
printf '%s—————————————————————————————%s\n' "$BOLD" "$RESET"
printf '\n'

# ————————————————————————
# 找配置文件
# ————————————————————————

CONFIG_FILE="${1:-}"

if [[ -z "$CONFIG_FILE" ]]; then
    # 自动在常见位置找 first-look-config.md
    for loc in "$HOME/Desktop" "$HOME/Downloads"; do
        if [[ -f "$loc/first-look-config.md" ]]; then
            CONFIG_FILE="$loc/first-look-config.md"
            break
        fi
    done
fi

if [[ -z "$CONFIG_FILE" ]]; then
    die_with_chatbox_hint \
        "没有找到配置文件。" \
        "请把 chatbox 给你的 md 文件下载到桌面，文件名 first-look-config.md；或者运行时在命令后加文件路径：bash install.sh <路径>"
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
    die_with_chatbox_hint \
        "配置文件不存在：$CONFIG_FILE" \
        "请检查文件路径对不对。"
fi

ok "读配置：$CONFIG_FILE"

CONTENT=$(cat "$CONFIG_FILE")

if ! validate_bundle "$CONTENT"; then
    die_with_chatbox_hint \
        "配置文件格式不对——里面没找到 first-look 的分隔符。" \
        "请让 chatbox 重新生成一份完整的配置文件，从 ===== FIRST-LOOK START ===== 到 ===== FIRST-LOOK END ====="
fi

# ————————————————————————
# 幂等：已有配置询问
# ————————————————————————

# memory 目录：~/.claude/projects/-Users-{whoami}/memory
HOME_ENCODED=${HOME//\//-}
MEMORY_DIR="$HOME/.claude/projects/$HOME_ENCODED/memory"

# 检测已有配置（CLAUDE.md 或 memory 目录里有 .md 文件——任一存在都要询问）
# 只看 .md，避免 .DS_Store 等隐藏元文件触发假警告
existing_claude=0
existing_memory=0
existing_md_files=()
[[ -f "$HOME/.claude/CLAUDE.md" ]] && existing_claude=1
if [[ -d "$MEMORY_DIR" ]]; then
    shopt -s nullglob
    existing_md_files=("$MEMORY_DIR"/*.md)
    shopt -u nullglob
    (( ${#existing_md_files[@]} > 0 )) && existing_memory=1
fi

if (( existing_claude || existing_memory )); then
    warn "检测到你之前已经有配置了："
    if (( existing_claude )); then
        existing_title=$(head -1 "$HOME/.claude/CLAUDE.md" | sed 's/^# *//')
        info "  ~/.claude/CLAUDE.md  —— 「${existing_title}」"
    fi
    if (( existing_memory )); then
        info "  $MEMORY_DIR/  —— ${#existing_md_files[@]} 个文件"
        for f in "${existing_md_files[@]}"; do
            info "    · $(basename "$f")"
        done
    fi
    info ""
    if (( existing_memory )); then
        warn "注意：新配置中不存在的旧 memory 文件会留在原位。"
        info "  如果你想完全干净地重来，建议选 [B] 备份，再手动清理旧文件。"
        info ""
    fi
    info "  [B] 备份后继续（推荐 · 旧文件备份到 .backup.{时间}，新文件写入）"
    info "  [O] 直接覆盖（同名文件替换，不同名的旧文件保留）"
    info "  [Q] 退出（不做任何改动）"
    printf '  %s选择 [B/O/Q]（直接回车 = 退出）:%s ' "$BOLD" "$RESET"
    if ! read -r existing_choice < "$TTY"; then
        err "无法读取你的选择。为安全起见，退出，不改动原配置。"
        exit 1
    fi

    # 秒级时间戳 + PID 后缀，避免同秒内两个进程互相覆盖备份
    ts=$(date +%Y%m%d_%H%M%S)_$$

    case "${existing_choice}" in
        [Bb])
            if (( existing_claude )); then
                cp "$HOME/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md.backup.$ts"
                ok "旧 CLAUDE.md 已备份到 ~/.claude/CLAUDE.md.backup.$ts"
            fi
            if (( existing_memory )); then
                backup_dir="${MEMORY_DIR}.backup.$ts"
                cp -RP "$MEMORY_DIR" "$backup_dir"
                ok "旧 memory 目录已备份到 ${backup_dir}"
            fi
            ;;
        [Oo])
            info "继续，同名文件覆盖，不同名旧文件保留。"
            ;;
        *)
            # 空输入、Q、未知输入 → 默认退出（保护已有配置）
            info "好，不改。现在退出。"
            exit 0
            ;;
    esac
    printf '\n'
fi

# ————————————————————————
# 解析 & 写入
# ————————————————————————

info "正在解析并写入配置…"
if ! parse_and_write "$CONTENT"; then
    die_with_chatbox_hint "解析失败——配置文件里没有发现任何合法的文件块。"
fi

if [[ ! -f "$HOME/.claude/CLAUDE.md" ]]; then
    die_with_chatbox_hint "CLAUDE.md 没有写入成功。配置内容可能不完整。"
fi

# 汇总跳过的文件（如果有）
if (( ${#SKIPPED_FILES[@]} > 0 )); then
    warn "有 ${#SKIPPED_FILES[@]} 个文件被跳过（名字不合规）："
    for f in "${SKIPPED_FILES[@]}"; do
        info "  - $f"
    done
    info "这些文件没写入。其他文件已正常处理。"
fi

ok "配置写好了"

# ————————————————————————
# 收尾 · 告诉用户下一步
# ————————————————————————
#
# 设计决定：不在这里 `exec claude` 自动启动 Claude Code。
# 理由：某些终端下 TTY 交接（exec claude < "$TTY"）会失效,
# 表现为 CC 界面已渲染但键盘无响应,用户只能 Cmd+Q 关终端重开。
# 与其修 fragile 的 TTY 交接,不如把启动控制权完全交给用户——
# 打印清晰的下一步,让她主动敲 `claude` 回车。TTY 问题根除,
# 流程可预测性提升,和 first-look 的"复杂度我们吃,她看到的
# 是陪伴"原则一致。

printf '\n'

# 检查 claude 命令
if ! command -v claude >/dev/null 2>&1; then
    warn "还没找到 claude 命令——Claude Code 可能没装，或者 PATH 没刷新。"
    info ""
    info "配置文件已经放好了，放心。你只差一步——启动 Claude Code。"
    info "回到你的 chatbox，告诉它「claude 命令没找到」，它会帮你装或者修 PATH。"
    info ""
    info "装好之后，在终端里跑 claude 就能见面了。"
    # 用 exit 2 表示"部分完成"——配置写了但 claude 命令没找到。
    exit 2
fi

# 打印开场白(如果有)
if [[ -n "$GREETING" ]]; then
    printf '%s─────────────────────────────────────%s\n' "$CYAN" "$RESET"
    printf '%s\n' "$GREETING"
    printf '%s─────────────────────────────────────%s\n' "$CYAN" "$RESET"
    printf '\n'
fi

# 清晰的下一步指引 —— 用户自己敲 claude 启动
printf '%s  ✓ 配置都写好了。%s\n\n' "$BOLD$GREEN" "$RESET"
printf '  下一步 · 在这个终端里输入这一行,打开 Claude Code:\n\n'
printf '%s      claude%s\n\n' "$BOLD" "$RESET"
printf '%s  (敲完回车,CC 就启动了,然后回到 chatbox 继续。)%s\n\n' "$DIM" "$RESET"
