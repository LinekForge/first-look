#!/usr/bin/env bash
#
# pack.sh · 打精简发行包给用户
#
# 从 repo 里提取用户需要的文件,flat 打到一个干净目录。
# 不含 dev 文件(README/SECURITY/CONTRIBUTING/LICENSE/.gitignore/blueprint/guide/prompt.md)。
#
# 用法:
#   bash pack.sh                           # 默认打到 ~/Desktop/first-look-发行包/
#   bash pack.sh ~/Desktop/给贞老师/       # 指定目录
#   bash pack.sh --zip                     # 打完再压成 zip

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZIP_MODE=0
OUT=""

for arg in "$@"; do
    case "$arg" in
        --zip) ZIP_MODE=1 ;;
        *) OUT="$arg" ;;
    esac
done

OUT="${OUT:-$HOME/Desktop/first-look-发行包}"

# 目标目录如果已存在,先清空(避免旧文件残留污染发行包)
if [[ -d "$OUT" ]]; then
    echo "  ⚠ 目标目录已存在,清空后重新打包: $OUT"
    rm -rf "$OUT"
fi
mkdir -p "$OUT"

# guide/ 下的 step 文件提到根——flat 结构让用户不用进目录找
cp "$REPO_DIR/guide/地图.md" "$OUT/"
cp "$REPO_DIR/guide/step-0-1-了解你.md" "$OUT/"
cp "$REPO_DIR/guide/step-2-生成配置.md" "$OUT/"
cp "$REPO_DIR/guide/step-3m-mac装机.md" "$OUT/"
cp "$REPO_DIR/guide/step-3w-windows装机.md" "$OUT/"
cp "$REPO_DIR/guide/step-4-7-安装启动.md" "$OUT/"

# 根目录文件
cp "$REPO_DIR/给你自己看.md" "$OUT/"
cp "$REPO_DIR/install.sh" "$OUT/"
cp "$REPO_DIR/install.ps1" "$OUT/"
cp "$REPO_DIR/SECURITY.md" "$OUT/"

echo ""
echo "✓ 发行包已打到: $OUT"
echo "  $(ls -1 "$OUT" | wc -l | tr -d ' ') 个文件:"
ls -1 "$OUT"

if (( ZIP_MODE )); then
    ZIP_PATH="${OUT}.zip"
    cd "$(dirname "$OUT")"
    zip -r "$(basename "$ZIP_PATH")" "$(basename "$OUT")" -x "*.DS_Store" "*__MACOSX*"
    echo ""
    echo "✓ zip: $ZIP_PATH"
    ls -la "$ZIP_PATH"
fi
