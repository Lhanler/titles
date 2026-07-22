#!/bin/bash
# install-viral-titles.sh - 一键安装 viral-titles skill(完整 git clone,支持后续 update)
#
# 用法:
#   ./install-viral-titles.sh [target-dir]
#
# 例:
#   ./install-viral-titles.sh                         # 默认装到 ~/.qclaw/skills/viral-titles
#   ./install-viral-titles.sh ~/.claude/skills        # 装到 Claude Desktop
#   ./install-viral-titles.sh ~/.cursor/skills        # 装到 Cursor
#
# 关键:**完整 git clone**(不是 --depth 1),这样以后可以 git pull 更新数据
#
# 兼容:bash 3.2+(Mac/Linux/WSL/Git Bash)
#   Windows 原生命令行请用 install-viral-titles.bat

set -e

TARGET_DIR="${1:-$HOME/.qclaw/skills/viral-titles}"
REPO_URL="https://github.com/Lhanler/titles.git"

echo "▶ 从 $REPO_URL 安装 viral-titles"

# 检查 git
if ! command -v git >/dev/null 2>&1; then
    echo "✗ 需要 git 命令"
    exit 1
fi

# 创建父目录
PARENT_DIR=$(dirname "$TARGET_DIR")
mkdir -p "$PARENT_DIR"

# 如果已经存在,做更新
if [ -d "$TARGET_DIR/.git" ]; then
    echo "✓ 已存在 $TARGET_DIR"
    echo "▶ 自动 pull 最新数据 ..."
    cd "$TARGET_DIR"
    git pull origin main
    echo "✓ 更新完成"
    exit 0
fi

# 如果存在但不是 git 仓,警告
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

# 完整 git clone(非 shallow,可以 pull)
echo "▶ git clone(完整历史,支持后续 update) ..."
git clone "$REPO_URL" "$TARGET_DIR"

echo ""
echo "✓ 安装完成: $TARGET_DIR"
echo ""
echo "下次更新数据:"
echo "  cd $TARGET_DIR && git pull origin main"
echo ""
echo "或一键更新脚本(需先 curl 下载):"
echo "  curl -O https://raw.githubusercontent.com/Lhanler/titles/main/update-viral-titles.sh"
echo "  bash update-viral-titles.sh"
echo ""
echo "重启你的 Agent(Cursor / OpenClaw / Claude Desktop)即可加载"