#!/bin/bash
# install-viral-titles.sh - 一键安装 viral-titles skill
#
# 用法:
#   ./install-viral-titles.sh [target-dir]
#
# 例:
#   ./install-viral-titles.sh                              # 默认装到 ~/.qclaw/skills/viral-titles
#   ./install-viral-titles.sh ~/.claude/skills             # 装到 Claude Desktop
#   ./install-viral-titles.sh ~/.cursor/skills             # 装到 Cursor
#
# 关键:完整 git clone(非 shallow),以后可 git pull 更新数据
# 兼容:bash 3.2+(Mac/Linux/WSL/Git Bash)
#   Windows 原生命令行请用 install-viral-titles.bat

set -e

TARGET_DIR="${1:-$HOME/.qclaw/skills/viral-titles}"
REPO_URL="https://github.com/Lhanler/titles.git"

if ! command -v git >/dev/null 2>&1; then
    echo "✗ 需要 git 命令"
    exit 1
fi

echo "▶ 从 $REPO_URL 安装 viral-titles"

PARENT_DIR=$(dirname "$TARGET_DIR")
mkdir -p "$PARENT_DIR"

# 已存在则 pull
if [ -d "$TARGET_DIR/.git" ]; then
    echo "✓ 已存在 $TARGET_DIR,自动 pull 更新"
    cd "$TARGET_DIR" && git pull origin main
    echo "✓ 更新完成"
    exit 0
fi

# 存在但不是 git 仓
if [ -d "$TARGET_DIR" ]; then
    echo "⚠ $TARGET_DIR 已存在但不是 git 仓库"
    read -p "  是否删除后重装? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "✗ 取消安装"
        exit 1
    fi
    rm -rf "$TARGET_DIR"
fi

echo "▶ git clone(完整历史) ..."
git clone "$REPO_URL" "$TARGET_DIR"

echo ""
echo "✓ 安装完成: $TARGET_DIR"
echo ""
echo "更新数据:"
echo "  cd $TARGET_DIR && git pull origin main"
echo "  或:bash update-viral-titles.sh"
echo ""
echo "重启你的 Agent(Cursor / OpenClaw / Claude Desktop)即可加载"