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

# ========== 修复 GCM 弹窗(根因:Git for Windows 自带 GCM,即使 user 设了 store helper,system 级的 helper-selector 仍会触发 GUI 弹窗) ==========
echo ""
echo "▶ [1/3] 修复 GCM 弹窗(写入 ~/.gitconfig + ~/.bashrc) ..."
GITCONFIG="$HOME/.gitconfig"
BASHRC="$HOME/.bashrc"
HELPER_SCRIPT="$HOME/git-credential-helper.py"

# 备份
cp "$GITCONFIG" "$GITCONFIG.pre-viral-titles.bak" 2>/dev/null || true

# 写 helper script(读 ~/.git-credentials 并 echo 给 git,完全替代 GCM)
cat > "$HELPER_SCRIPT" <<'PYEOF'
#!/usr/bin/env python3
"""git-credential-helper: 读 ~/.git-credentials 并 echo 凭据,完全替代 GCM"""
import sys, os
from pathlib import Path
from urllib.parse import urlparse

url = sys.stdin.read().strip()
if not url:
    sys.exit(1)

creds_paths = [
    Path.home() / '.git-credentials',
    Path(os.environ.get('USERPROFILE', str(Path.home()))) / '.git-credentials',
]
host = urlparse(url).netloc

for creds in creds_paths:
    if not creds.exists():
        continue
    try:
        with open(creds, 'r', encoding='utf-8') as f:
            for line in f:
                if '://' not in line or '@' not in line:
                    continue
                scheme, rest = line.strip().split('://', 1)
                auth, line_host = rest.rsplit('@', 1)
                if line_host.startswith(host):
                    if ':' in auth:
                        user, _, password = auth.partition(':')
                        print(f"username={user}")
                        print(f"password={password}")
                        sys.exit(0)
    except Exception:
        continue
sys.exit(1)
PYEOF
chmod +x "$HELPER_SCRIPT" 2>/dev/null || true
echo "  ✓ helper script: $HELPER_SCRIPT"

# 找 python 路径
PYTHON_PATH="$(command -v python 2>/dev/null || command -v python3 2>/dev/null || echo python)"
echo "  ✓ python: $PYTHON_PATH"

# 删旧 override(用 Python helper 替代 store helper)
git config --global --unset-all credential.https://github.com.helper 2>/dev/null || true
git config --global --unset-all credential.https://gist.github.com.helper 2>/dev/null || true
# 加新 override(用 ! python ... 形式,完全替代 GCM)
git config --global --add credential.https://github.com.helper "!\"$PYTHON_PATH\" \"$HELPER_SCRIPT\""
git config --global --add credential.https://gist.github.com.helper "!\"$PYTHON_PATH\" \"$HELPER_SCRIPT\""
echo "  ✓ ~/.gitconfig: [credential \"https://github.com\"] helper = python helper"

# 写 bashrc
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
echo "下一步:"
echo "  cd $TARGET_DIR && git pull origin main"
echo ""
echo "或一键更新脚本(需先 curl 下载):"
echo "  curl -O https://raw.githubusercontent.com/Lhanler/titles/main/update-viral-titles.sh"
echo "  bash update-viral-titles.sh"
echo ""
echo "重启你的 Agent(Cursor / OpenClaw / Claude Desktop)即可加载"