@echo off
REM install-viral-titles.bat - Windows 一键安装 viral-titles skill(SSH 模式,0 弹窗)
REM
REM 用法:
REM   install-viral-titles.bat [target-dir]
REM
REM 例:
REM   install-viral-titles.bat                                    REM 默认装到 %USERPROFILE%\.qclaw\skills\viral-titles
REM   install-viral-titles.bat %USERPROFILE%\.claude\skills      REM 装到 Claude Desktop
REM   install-viral-titles.bat %USERPROFILE%\.cursor\skills      REM 装到 Cursor
REM
REM 关键:
REM   - 用 SSH 而非 HTTPS,完全绕开 GCM 弹窗(根因)
REM   - 完整 git clone(非 shallow),以后可以 git pull 更新
REM   - 自动配 core.sshCommand + ~/.ssh/config 绝对路径(修中文用户名 bug)

setlocal

if "%~1"=="" (
    set TARGET_DIR=%USERPROFILE%\.qclaw\skills\viral-titles
) else (
    set TARGET_DIR=%~1
)

set REPO_URL=git@github.com:Lhanler/titles.git

echo ▶ 从 %REPO_URL% 安装 viral-titles(SSH 模式,0 弹窗)
echo   目标: %TARGET_DIR%

REM ========== [1/3] 配 SSH ==========
echo.
echo ▶ [1/3] 配 SSH 认证(完全绕开 GCM 弹窗) ...

if not exist "%USERPROFILE%\.ssh" (
    mkdir "%USERPROFILE%\.ssh"
)

REM 写 SSH config(绝对路径,修中文用户名 bug)
(
    echo Host github.com
    echo     HostName github.com
    echo     User git
    echo     IdentityFile "%USERPROFILE%\.ssh\id_ed25519"
    echo     IdentitiesOnly yes
    echo     UserKnownHostsFile "%USERPROFILE%\.ssh\known_hosts"
    echo     StrictHostKeyChecking accept-new
    echo     PreferredAuthentications publickey
    echo     PasswordAuthentication no
) > "%USERPROFILE%\.ssh\config"
echo   ✓ %USERPROFILE%\.ssh\config

REM 提示如果没 SSH key
if not exist "%USERPROFILE%\.ssh\id_ed25519" (
    echo   ⚠ 没找到 SSH key ^(id_ed25519^),需要先生成:
    echo     ssh-keygen -t ed25519 -C "your@email.com"
    echo     然后把 id_ed25519.pub 加到 https://github.com/settings/keys
)

REM 找 ssh 路径
where ssh >nul 2>&1
if errorlevel 1 (
    echo   ✗ 未找到 ssh 命令
    exit /b 1
)
for /f "delims=" %%S in ('where ssh') do (
    set SSH_PATH=%%S
    goto :got_ssh
)
:got_ssh
echo   ✓ ssh: %SSH_PATH%

REM 配 core.sshCommand(显式指定 SSH 绝对路径,完全绕开 HOME 路径问题)
git config --global core.sshCommand "\"%SSH_PATH%\" -F \"%USERPROFILE%\.ssh\config\" -i \"%USERPROFILE%\.ssh\id_ed25519\" -o UserKnownHostsFile=\"%USERPROFILE%\.ssh\known_hosts\" -o IdentitiesOnly=yes -o BatchMode=yes"
echo   ✓ core.sshCommand

REM 删 GCM helper(避免触发)
git config --global --unset-all credential.helper >nul 2>&1
git config --global --unset-all credential.https://github.com.helper >nul 2>&1
git config --global --unset-all credential.https://gist.github.com.helper >nul 2>&1
echo   ✓ 移除 GCM credential helper(完全绕开 GCM)

REM 添加 github.com 到 known_hosts
findstr /c:"github.com" "%USERPROFILE%\.ssh\known_hosts" >nul 2>&1
if errorlevel 1 (
    echo   ▶ 添加 github.com 到 known_hosts ...
    ssh-keyscan -t ed25519,rsa,ecdsa github.com >> "%USERPROFILE%\.ssh\known_hosts" 2>nul
)

REM ========== [2/3] 安装 ==========
echo.
echo ▶ [2/3] 安装到 %TARGET_DIR% ...
for %%D in ("%TARGET_DIR%") do set PARENT_DIR=%%~dpD
if not exist "%PARENT_DIR%" mkdir "%PARENT_DIR%"

if exist "%TARGET_DIR%\.git" (
    echo ✓ 已存在 %TARGET_DIR%
    echo ▶ 自动 pull 最新数据 ...
    cd /d %TARGET_DIR%
    git pull origin main
    echo ✓ 更新完成
    exit /b 0
)

if exist "%TARGET_DIR%" (
    echo ⚠ %TARGET_DIR% 已存在但不是 git 仓库
    set /p REPLY="  是否删除后重装? [y/N] "
    if /i not "%REPLY%"=="y" (
        echo ✗ 取消安装
        exit /b 1
    )
    rmdir /s /q "%TARGET_DIR%"
)

echo ▶ git clone^(SSH,完整历史^) ...
git clone "%REPO_URL%" "%TARGET_DIR%"

REM ========== [3/3] 验证 ==========
echo.
echo ▶ [3/3] 验证 ...
cd /d %TARGET_DIR%
git ls-remote origin main >nul 2>&1
if errorlevel 1 (
    echo   ⚠ SSH 认证失败,可能需要:
    echo     1. 上传 %USERPROFILE%\.ssh\id_ed25519.pub 到 https://github.com/settings/keys
    echo     2. 重新跑此脚本
) else (
    echo   ✓ SSH 认证 OK,无 GCM 弹窗
)

echo.
echo ✓ 安装完成: %TARGET_DIR%
echo.
echo 更新数据:
echo   cd /d %TARGET_DIR%
echo   git pull origin main
echo.
echo 重启你的 Agent(Cursor / OpenClaw / Claude Desktop)即可加载

endlocal