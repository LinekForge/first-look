#!/usr/bin/env bash
#
# blueprint · setup.sh
#
# 把 blueprint/scaffold/ 的内容搭到你的 ~/.claude/（或指定目录）。
# 不覆盖已有内容——如果你已经有某个文件，跳过它，不会吃掉你写的东西。
#
# 用法：
#   bash setup.sh                    # 默认搭到 ~/.claude/
#   bash setup.sh -n                 # 干跑，只预览要做什么
#   bash setup.sh /path/to/target    # 搭到别的位置（测试用）

set -euo pipefail

# ————————————————————————
# 颜色 / 打印
# ————————————————————————

if [[ -t 1 ]]; then
    BOLD=$'\033[1m'; DIM=$'\033[2m'; GREEN=$'\033[32m'
    YELLOW=$'\033[33m'; CYAN=$'\033[36m'; RESET=$'\033[0m'
else
    BOLD=''; DIM=''; GREEN=''; YELLOW=''; CYAN=''; RESET=''
fi

ok()   { printf '  %s✓%s %s\n' "$GREEN" "$RESET" "$1"; }
info() { printf '  %s%s%s\n' "$DIM" "$1" "$RESET"; }
warn() { printf '  %s⚠%s  %s\n' "$YELLOW" "$RESET" "$1"; }
head() { printf '\n%s%s%s\n' "$BOLD" "$1" "$RESET"; }

# ————————————————————————
# 参数
# ————————————————————————

DRY_RUN=0
TARGET=""

for arg in "$@"; do
    case "$arg" in
        -n|--dry-run) DRY_RUN=1 ;;
        -h|--help)
            cat <<EOF
用法: bash setup.sh [目标目录] [-n|--dry-run]

目标目录默认 ~/.claude/。
-n / --dry-run：不实际写入，只预览。
EOF
            exit 0 ;;
        -*)
            echo "未知选项：$arg"; exit 1 ;;
        *)
            TARGET="$arg" ;;
    esac
done

TARGET="${TARGET:-$HOME/.claude}"

# ————————————————————————
# 找 scaffold 目录（脚本同级）
# ————————————————————————

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCAFFOLD_DIR="$SCRIPT_DIR/scaffold"

if [[ ! -d "$SCAFFOLD_DIR" ]]; then
    echo "错误：找不到 $SCAFFOLD_DIR"
    echo "这个脚本必须和 scaffold/ 放在同一个 blueprint/ 目录里。"
    exit 1
fi

# ————————————————————————
# 欢迎
# ————————————————————————

printf '\n'
printf '%s━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%s\n' "$BOLD" "$RESET"
printf '%s  blueprint · ~/.claude/ 结构搭建%s\n' "$BOLD" "$RESET"
printf '%s━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%s\n' "$BOLD" "$RESET"

head "要做什么"
info "从 $SCAFFOLD_DIR"
info "搭到 $TARGET"
info "冲突策略：不覆盖已有文件（你写过的东西安全）"
if (( DRY_RUN )); then
    warn "干跑模式 · 只预览，不实际写入"
fi

# ————————————————————————
# 命名偏好（顶层目录中英文）
# ————————————————————————

head "命名偏好"
info "scaffold 里顶层目录是 mine/ automation/ state/——英文。"
info "你可以选改成中文：我的/ 自动化/ 状态/"
info "（深层目录不改——CC 硬约束 skills/commands/hooks 必须英文）"
printf '\n  你想用 [E] 英文（默认）还是 [C] 中文？ '

RENAME_CN=0
if (( DRY_RUN )); then
    info ""; info "[干跑] 假设选英文"
else
    read -r naming_choice || true
    case "${naming_choice:-}" in
        [Cc]|[Cc][Hh]|中文) RENAME_CN=1; ok "选了中文" ;;
        *) ok "选了英文（默认）" ;;
    esac
fi

# ————————————————————————
# 预览即将做什么
# ————————————————————————

head "即将创建/跳过的内容"

# 用 find 列出 scaffold 里所有相对路径，映射到目标
cd "$SCAFFOLD_DIR"

created=0
skipped=0
declare -a create_list=()
declare -a skip_list=()

while IFS= read -r rel; do
    rel="${rel#./}"
    [[ -z "$rel" ]] && continue
    # rename 顶层目录（如果选了中文）
    target_rel="$rel"
    if (( RENAME_CN )); then
        case "$target_rel" in
            mine|mine/*)             target_rel="我的${target_rel#mine}" ;;
            automation|automation/*) target_rel="自动化${target_rel#automation}" ;;
            state|state/*)           target_rel="状态${target_rel#state}" ;;
        esac
    fi
    abs_target="$TARGET/$target_rel"
    if [[ -e "$abs_target" ]]; then
        skip_list+=("$target_rel")
        skipped=$((skipped + 1))
    else
        create_list+=("$target_rel|$rel")
        created=$((created + 1))
    fi
done < <(find . -type f 2>/dev/null)

if (( created > 0 )); then
    info ""
    info "将创建 ${created} 个文件："
    for item in "${create_list[@]}"; do
        rel="${item%%|*}"
        printf '  %s+%s %s\n' "$GREEN" "$RESET" "$rel"
    done
fi

if (( skipped > 0 )); then
    info ""
    info "将跳过 ${skipped} 个已存在的（不覆盖）："
    for rel in "${skip_list[@]}"; do
        printf '  %s·%s %s（已存在）\n' "$DIM" "$RESET" "$rel"
    done
fi

if (( created == 0 )); then
    info ""
    warn "目标目录已经有全部内容，无事可做。"
    exit 0
fi

# ————————————————————————
# 确认
# ————————————————————————

if (( DRY_RUN )); then
    info ""
    info "[干跑] 没有写入任何文件。去掉 -n 就实际执行。"
    exit 0
fi

head "确认"
printf '  看一眼上面——执行吗？ [Y/n] '
read -r confirm || true
case "${confirm:-Y}" in
    [Nn]|[Nn][Oo])
        info "好，取消了。没有改动任何东西。"
        exit 0 ;;
esac

# ————————————————————————
# 执行
# ————————————————————————

head "搭起来"

for item in "${create_list[@]}"; do
    rel="${item%%|*}"
    src_rel="${item##*|}"
    abs_target="$TARGET/$rel"
    mkdir -p "$(dirname "$abs_target")"
    cp "$SCAFFOLD_DIR/$src_rel" "$abs_target"
    ok "创建 $rel"
done

# ————————————————————————
# 下一步建议
# ————————————————————————

head "下一步"
info "1. 读一遍 $TARGET/README.md"
info "   了解你新搭好的骨架是什么"
info ""
info "2. 改 $TARGET/CLAUDE.md"
info "   把占位填成你自己的情况——姓名、在忙什么、沟通偏好"
info ""
info "3. 可选：挂 session-start hook"
info "   编辑 ~/.claude/settings.json，加："
info "   \"hooks\": {\"SessionStart\": [{\"hooks\": [{\"type\": \"command\", \"command\": \"bash ~/.claude/hooks/bootstrap/session-start.sh\"}]}]}"
info "   （你也可以先跑 bash $TARGET/hooks/bootstrap/session-start.sh 看它输出什么）"
info ""
info "4. 读 blueprint/concepts.md 理解每个目录的职责"
info "   blueprint/scaffold/ 里有每个目录的示例实现"
info ""
info "5. 不要一口气全填完"
info '   先把 CLAUDE.md 改好用一周，再决定加什么——'
info '   不是「blueprint 说什么都要做」。blueprint 是参考，不是任务清单。'

printf '\n'
