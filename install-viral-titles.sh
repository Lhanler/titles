#!/bin/bash
# install-viral-titles.sh - 一键安装 viral-titles skill(SSH 模式,0 弹窗)
#
# 用法:
#   ./install-viral-titles.sh [target-dir]
#
# 例:
#   ./install-viral-titles.sh                              # 默认装到 ~/.qclaw/skills/viral-titles
#   ./install-viral-titles.sh ~/.claude/skills             # 装到 Claude Desktop
#   ./install-viral-titles.sh ~/.cursor/skills             # 装到 Cursor
#
# 关键:
#   - 用 SSH 而非 HTTPS,完全绕开 GCM 弹窗
#   - 完整 git clone(非 shallow),以后可以 git pull 更新
#   - 自动配 ~/.gitconfig[core] sshCommand + ~/.ssh/config
#
# 兼容:bash 3.2+(Mac/Linux/WSL/Git Bash)
#   Windows 原生命令行请用 install-viral-titles.bat

set -e

TARGET_DIR="${1:-$HOME/.qclaw/skills/viral-titles}"
REPO_URL="git@github.com:Lhanler/titles.git"  # SSH,避免 GCM 弹窗

echo "▶ 从 $REPO_URL 安装 viral-titles(SSH 模式,0 弹窗)"

# 检查 git
if ! command -v git >/dev/null 2>&1; then
    echo "✗ 需要 git 命令"
    exit 1
fi

# ========== [1/3] 配 SSH(完全绕开 GCM 弹窗) ==========
echo ""
echo "▶ [1/3] 配 SSH 认证(完全绕开 GCM 弹窗) ..."

SSH_DIR="$HOME/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# 1. 写 SSH config(显式 IdentityFile + UserKnownHostsFile 绝对路径,修中文用户名 bug)
cat > "$SSH_DIR/config" <<SSHEOF
Host github.com
    HostName github.com
    User git
    IdentityFile "$HOME/.ssh/id_ed25519"
    IdentitiesOnly yes
    UserKnownHostsFile "$HOME/.ssh/known_hosts"
    StrictHostKeyChecking accept-new
    PreferredAuthentications publickey
    PasswordAuthentication no
SSHEOF
chmod 600 "$SSH_DIR/config"
echo "  ✓ ~/.ssh/config"

# 2. 如果没 SSH key,生成(可选,大多数用户已有)
if [ ! -f "$SSH_DIR/id_ed25519" ]; then
    echo "  ⚠ 没找到 SSH key(id_ed25519),需要先生成:"
    echo "    ssh-keygen -t ed25519 -C 'your@email.com'"
    echo "    然后把 id_ed25519.pub 加到 https://github.com/settings/keys"
    # 仍然继续,git clone 会失败时再提示
fi

# 3. 写 ~/.gitconfig[core] sshCommand(显式指定 SSH 绝对路径,完全绕开 HOME 路径问题)
# 找到 ssh 路径
SSH_PATH="$(command -v ssh 2>/dev/null || echo ssh)"
echo "  ✓ ssh: $SSH_PATH"

git config --global core.sshCommand "\"$SSH_PATH\" -F \"$HOME/.ssh/config\" -i \"$HOME/.ssh/id_ed25519\" -o UserKnownHostsFile=\"$HOME/.ssh/known_hosts\" -o IdentitiesOnly=yes -o BatchMode=yes"
echo "  ✓ ~/.gitconfig core.sshCommand"

# 4. 删 GCM helper 引用(避免触发)
git config --global --unset-all credential.helper 2>/dev/null || true
git config --global --unset-all credential.https://github.com.helper 2>/dev/null || true
git config --global --unset-all credential.https://gist.github.com.helper 2>/dev/null || true
echo "  ✓ 移除 GCM credential helper(完全绕开 GCM)"

# 5. 加 GitHub 到 known_hosts(首次)
if ! grep -q "github.com" "$SSH_DIR/known_hosts" 2>/dev/null; then
    echo "  ▶ 添加 github.com 到 known_hosts ..."
    ssh-keyscan -t ed25519,rsa,ecdsa github.com >> "$SSH_DIR/known_hosts" 2>/dev/null || true
    chmod 644 "$SSH_DIR/known_hosts"
fi

# ========== [2/3] 安装 ==========
echo ""
echo "▶ [2/3] 安装到 $TARGET_DIR ..."
PARENT_DIR=$(dirname "$TARGET_DIR")
mkdir -p "$PARENT_DIR"

# 已存在则 pull
if [ -d "$TARGET_DIR/.git" ]; then
    echo "✓ 已存在 $TARGET_DIR"
    echo "▶ 自动 pull 最新数据 ..."
    cd "$TARGET_DIR"
    git pull origin main
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

echo "▶ git clone(SSH,完整历史) ..."
git clone "$REPO_URL" "$TARGET_DIR"

# ========== [3/3] 验证 ==========
echo ""
echo "▶ [3/3] 验证 ..."
cd "$TARGET_DIR"
if git ls-remote origin main >/dev/null 2>&1; then
    echo "  ✓ SSH 认证 OK,无 GCM 弹窗"
else
    echo "  ⚠ SSH 认证失败,可能需要:"
    echo "    1. 上传 ~/.ssh/id_ed25519.pub 到 https://github.com/settings/keys"
    echo "    2. 重新跑此脚本"
fi

echo ""
echo "✓ 安装完成: $TARGET_DIR"
echo ""
echo "更新数据:"
echo "  cd $TARGET_DIR && git pull origin main"
echo ""
echo "重启你的 Agent(Cursor / OpenClaw / Claude Desktop)即可加载"