#!/usr/bin/env bash
#
# session-start.sh · 通用版
#
# CC 启动时自动调用——stdout 会被注入到 CC 的 system context。
# 用来让她"醒来"时就有你准备好的上下文：时间、导航、最近的便条等。
#
# 挂载方式：在 ~/.claude/settings.json 加：
#   "hooks": {
#     "SessionStart": [{
#       "hooks": [{
#         "type": "command",
#         "command": "bash ~/.claude/hooks/bootstrap/session-start.sh"
#       }]
#     }]
#   }
#
# 这是通用骨架——可直接用，也可以按你自己的需要扩展。
# 每一段都有注释标出是什么、可以改什么。

set -uo pipefail  # 注意：没开 errexit——hook 一段失败不要让整个启动挂掉

CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"

# ——————————————————————
# 1. 时间（基准）
# ——————————————————————

echo "[时间] $(date '+%Y-%m-%d %H:%M:%S %Z')"

# ——————————————————————
# 2. 导航注入（从 ~/.claude/README.md 的 wake-inject 区提取）
# ——————————————————————
# 约定：README.md 里用 HTML 注释标出"醒来该看什么"：
#   <!-- wake-inject-start -->
#   1. CLAUDE.md
#   2. mine/self-narrative.md
#   <!-- wake-inject-end -->

if [[ -f "$CLAUDE_HOME/README.md" ]]; then
    nav=$(sed -n '/<!-- wake-inject-start -->/,/<!-- wake-inject-end -->/p' "$CLAUDE_HOME/README.md" \
          | sed '1d;$d')  # 去掉首尾标记行
    if [[ -n "$nav" ]]; then
        echo ""
        echo "[导航]"
        echo "$nav"
    fi
fi

# ——————————————————————
# 3. 自我叙事（如果你写了 mine/self-narrative.md）
# ——————————————————————

if [[ -f "$CLAUDE_HOME/mine/self-narrative.md" ]]; then
    echo ""
    echo "[自我叙事]"
    cat "$CLAUDE_HOME/mine/self-narrative.md"
fi

# ——————————————————————
# 4. 最近的 state-snapshots（最近 2-3 个）
# ——————————————————————

SNAPSHOTS_DIR="$CLAUDE_HOME/state/state-snapshots"
if [[ -d "$SNAPSHOTS_DIR" ]]; then
    # 找最近 3 个 .md，按文件名倒序（时间戳命名天然排序）
    recent=$(ls -1 "$SNAPSHOTS_DIR"/*.md 2>/dev/null | sort -r | head -3)
    if [[ -n "$recent" ]]; then
        echo ""
        echo "[最近的便条]"
        while IFS= read -r f; do
            echo ""
            echo "--- $(basename "$f") ---"
            cat "$f"
        done <<< "$recent"
    fi
fi

# ——————————————————————
# 5. 你自己的扩展点（删掉这些注释，加你要的）
# ——————————————————————

# 例子：周期性提醒
#
# SESSION_COUNT_FILE="$CLAUDE_HOME/state/session-count"
# if [[ -f "$SESSION_COUNT_FILE" ]]; then
#     count=$(cat "$SESSION_COUNT_FILE")
#     count=$((count + 1))
#     echo "$count" > "$SESSION_COUNT_FILE"
#     if (( count % 10 == 0 )); then
#         echo ""
#         echo "[提醒] 已经 $count 次 session 了，考虑做一次记忆整理"
#     fi
# fi

# 例子：条件性提醒（文件 N 天没更新）
#
# capability_doc="$CLAUDE_HOME/mine/knowledge/tech/能力清单.md"
# if [[ -f "$capability_doc" ]]; then
#     age_days=$(( ($(date +%s) - $(stat -f %m "$capability_doc")) / 86400 ))
#     if (( age_days > 14 )); then
#         echo ""
#         echo "[提醒] 能力清单 $age_days 天没更新了，建议刷一刷"
#     fi
# fi

# ——————————————————————
# 完
# ——————————————————————
#
# 测试方法：直接运行 `bash ~/.claude/hooks/bootstrap/session-start.sh` 看输出是什么样。
# CC 启动时会把这段 stdout 注入 context。
