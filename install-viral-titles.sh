#!/bin/bash
# install-viral-titles.sh - 一键安装 viral-titles skill(完整 git clone + SSH,支持后续 update)
#
# 用法:
#   ./install-viral-titles.sh [target-dir]
#
# 例:
#   ./install-viral-titles.sh                         # 默认装到 ~/.qclaw/skills/viral-titles
#   ./install-viral-titles.sh ~/.claude/skills        # 装到 Claude Desktop
#   ./install-viral-titles.sh ~/.cursor/skills        # 装到 Cursor
#
# 关键:**完整 git clone + SSH remote URL**(完全跳过 GCM / helper-selector)
#
# 兼容:bash 3.2+(Mac/Linux/WSL/Git Bash)
#   Windows 原生命令行请用 install-viral-titles.bat

set -e

TARGET_DIR="${1:-$HOME/.qclaw/skills/viral-titles}"
REPO_URL="git@github.com:Lhanler/titles.git"   # SSH 完全跳过 GCM 弹窗

echo "▶ 从 $REPO_URL 安装 viral-titles"

# 检查 git
if ! command -v git >/dev/null 2>&1; then
    echo "✗ 需要 git 命令"
    exit 1
fi

# 检查 SSH(自动生成 key 如果没有)
if [ ! -f "$HOME/.ssh/id_ed25519" ] && [ ! -f "$HOME/.ssh/id_rsa" ]; then
    echo "▶ 没找到 SSH key,自动生成 id_ed25519 ..."
    mkdir -p "$HOME/.ssh"
    ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N "" -C "$(git config --global user.email 2>/dev/null || echo 'viral-titles@local')"
    echo ""
    echo "⚠ 你需要把公钥加到 GitHub:"
    echo "  1. 复制: cat ~/.ssh/id_ed25519.pub"
    echo "  2. GitHub → Settings → SSH and GPG keys → New SSH key"
    echo ""
    read -p "  加好公钥后按 Enter 继续..."
fi

# 设置 GIT_SSH_COMMAND(走显式 key)
export GIT_SSH_COMMAND='ssh -i '"$HOME"'/.ssh/id_ed25519 -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile='"$HOME"'/.ssh/known_hosts -o ConnectTimeout=15'
echo "  ✓ GIT_SSH_COMMAND:用 ~/.ssh/id_ed25519"

# ========== 修复 GCM 弹窗(为 HTTPS 用户保留) ==========
echo ""
echo "▶ [1/3] 修复 GCM 弹窗(写入 ~/.gitconfig + ~/.bashrc) ..."
GITCONFIG="$HOME/.gitconfig"
BASHRC="$HOME/.bashrc"
# 备份
cp "$GITCONFIG" "$GITCONFIG.pre-viral-titles.bak" 2>/dev/null || true
# 删旧 override
git config --global --unset-all credential.https://github.com.helper 2>/dev/null || true
git config --global --unset-all credential.https://gist.github.com.helper 2>/dev/null || true
# 加新 override(URL-match 跳过系统级 helper-selector)
git config --global --add credential.https://github.com.helper store
git config --global --add credential.https://gist.github.com.helper store
echo "  ✓ ~/.gitconfig: [credential \"https://github.com\"] helper = store"
# 写 bashrc(禁用 terminal prompt,防止任何 helper 弹窗)
touch "$BASHRC"
if ! grep -q "GIT_TERMINAL_PROMPT=0" "$BASHRC" 2>/dev/null; then
    printf "\n# === viral-titles: disable GCM popup ===\nexport GIT_TERMINAL_PROMPT=0\n" >> "$BASHRC"
    echo "  ✓ ~/.bashrc: export GIT_TERMINAL_PROMPT=0"
else
    echo "  ✓ ~/.bashrc: GIT_TERMINAL_PROMPT=0 已存在"
fi

# ========== 创建父目录 ==========
echo ""
echo "▶ [2/3] 安装到 $TARGET_DIR ..."
PARENT_DIR=$(dirname "$TARGET_DIR")
mkdir -p "$PARENT_DIR"

# 如果已经存在,做更新
if [ -d "$TARGET_DIR/.git" ]; then
    echo "✓ 已存在 $TARGET_DIR"
    echo "▶ 自动 pull 最新数据 ..."
    cd "$TARGET_DIR"
    # 强制 SSH remote(覆盖之前可能的 HTTPS)
    git remote set-url origin "$REPO_URL"
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
echo "▶ git clone(完整历史,SSH 走) ..."
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