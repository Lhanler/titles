#!/bin/bash
# update-viral-titles.sh - 一键更新本地 viral-titles skill 数据
#
# 用法:
#   ./update-viral-titles.sh
#
# 原理:
#   1. 自动找本地安装目录
#   2. cd 进去 git pull origin main
#   3. 显示更新条数 + 最新 commit
#
# 兼容:bash 3.2+(Mac/Linux/WSL/Git Bash)
#   Windows 原生命令行请用 update-viral-titles.bat
#
# 查找顺序:
#   ~/.qclaw/skills/viral-titles
#   ~/.qclaw/skills/viral-title-generator
#   ~/.openclaw/skills/viral-titles
#   ~/.claude/skills/viral-titles
#   ~/.cursor/skills/viral-titles
#   当前目录

set -e

echo "▶ 查找 viral-titles 安装位置 ..."

# 候选目录
CANDIDATES=(
    "$HOME/.qclaw/skills/viral-titles"
    "$HOME/.qclaw/skills/viral-title-generator"
    "$HOME/.openclaw/skills/viral-titles"
    "$HOME/.claude/skills/viral-titles"
    "$HOME/.cursor/skills/viral-titles"
    "$HOME/.q/skills/viral-titles"
    "$(pwd)"
)

SKILL_DIR=""
for dir in "${CANDIDATES[@]}"; do
    if [ -d "$dir/.git" ]; then
        SKILL_DIR="$dir"
        break
    fi
done

if [ -z "$SKILL_DIR" ]; then
    echo ""
    echo "✗ 未找到 viral-titles 安装位置(没有 .git 目录)"
    echo ""
    echo "请先用 git clone 完整安装:"
    echo "  git clone https://github.com/Lhanler/titles.git ~/.qclaw/skills/viral-titles"
    exit 1
fi

echo "✓ 找到: $SKILL_DIR"
cd "$SKILL_DIR"

# 记录更新前 commit
OLD_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "none")
echo "  本地版本: $OLD_SHA"

echo ""
echo "▶ git pull origin main ..."

if ! git pull origin main 2>&1; then
    echo ""
    echo "✗ git pull 失败(可能网络问题)"
    exit 1
fi

NEW_SHA=$(git rev-parse --short HEAD)
echo ""
echo "✓ 已更新到: $NEW_SHA"

# 显示 corpus 行数变化
if [ -f "data/title-corpus.jsonl" ]; then
    CORPUS_LINES=$(wc -l < "data/title-corpus.jsonl")
    echo "  corpus: $CORPUS_LINES 条标题"
fi

if [ "$OLD_SHA" = "$NEW_SHA" ]; then
    echo "  已是最新,无需更新"
fi

echo ""
echo "✓ 完成。下次加载 skill 时会用最新数据。"