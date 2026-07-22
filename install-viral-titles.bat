@echo off
REM install-viral-titles.bat - Windows 一键安装 viral-titles skill
REM
REM 用法:
REM   install-viral-titles.bat [target-dir]
REM
REM 例:
REM   install-viral-titles.bat                                    REM 默认装到 %USERPROFILE%\.qclaw\skills\viral-titles
REM   install-viral-titles.bat %USERPROFILE%\.claude\skills      REM 装到 Claude Desktop
REM   install-viral-titles.bat %USERPROFILE%\.cursor\skills      REM 装到 Cursor
REM
REM 关键:完整 git clone(不是 shallow),这样以后可以 git pull 更新数据

setlocal

if "%~1"=="" (
    set TARGET_DIR=%USERPROFILE%\.qclaw\skills\viral-titles
) else (
    set TARGET_DIR=%~1
)

set REPO_URL=https://github.com/Lhanler/titles.git

echo ▶ 从 %REPO_URL% 安装 viral-titles
echo   目标: %TARGET_DIR%

REM ========== 修复 GCM 弹窗 ==========
echo.
echo ▶ [1/3] 修复 GCM 弹窗(写入 %%USERPROFILE%%\.gitconfig + PowerShell profile) ...

REM 备份 gitconfig
if exist "%USERPROFILE%\.gitconfig" (
    copy /Y "%USERPROFILE%\.gitconfig" "%USERPROFILE%\.gitconfig.pre-viral-titles.bak" >nul 2>&1
)

REM 写 helper script(读 %USERPROFILE%\.git-credentials 并 echo 凭据给 git,完全替代 GCM)
set HELPER_SCRIPT=%USERPROFILE%\git-credential-helper.py
(
    echo #!/usr/bin/env python3
    echo """git-credential-helper: 读 ~/.git-credentials 并 echo 凭据,完全替代 GCM"""
    echo import sys, os
    echo from pathlib import Path
    echo from urllib.parse import urlparse
    echo.
    echo url = sys.stdin.read^(^).strip^(^)
    echo if not url: sys.exit^(1^)
    echo.
    echo creds_paths = [
    echo     Path.home^(^) / '.git-credentials',
    echo     Path^(os.environ.get^('USERPROFILE', str^(Path.home^(^)^)^)^) / '.git-credentials',
    echo ]
    echo host = urlparse^(url^).netloc
    echo.
    echo for creds in creds_paths:
    echo     if not creds.exists^(^): continue
    echo     try:
    echo         with open^(creds, 'r', encoding='utf-8'^) as f:
    echo             for line in f:
    echo                 if '://' not in line or '@' not in line: continue
    echo                 scheme, rest = line.strip^(^).split^('://', 1^)
    echo                 auth, line_host = rest.rsplit^('@', 1^)
    echo                 if line_host.startswith^(host^):
    echo                     if ':' in auth:
    echo                         user, _, password = auth.partition^(':'^)
    echo                         print^(f"username={user}"^)
    echo                         print^(f"password={password}"^)
    echo                         sys.exit^(0^)
    echo     except Exception: continue
    echo sys.exit^(1^)
) > "%HELPER_SCRIPT%"
echo   ✓ helper script: %HELPER_SCRIPT%

REM 找 python 路径
where python >nul 2>&1
if errorlevel 1 (
    echo   ✗ 未找到 python,请先安装 Python 3.8+
    exit /b 1
)
for /f "delims=" %%P in ('where python') do (
    set PYTHON_PATH=%%P
    goto :got_python
)
:got_python
echo   ✓ python: %PYTHON_PATH%

REM 删旧 override
git config --global --unset-all credential.https://github.com.helper >nul 2>&1
git config --global --unset-all credential.https://gist.github.com.helper >nul 2>&1

REM 加新 override(用 ! python ... 形式,完全替代 GCM)
git config --global --add credential.https://github.com.helper !"%PYTHON_PATH%" "%HELPER_SCRIPT%"
git config --global --add credential.https://gist.github.com.helper !"%PYTHON_PATH%" "%HELPER_SCRIPT%"
echo   ✓ %%USERPROFILE%%\.gitconfig: [credential "https://github.com"] helper = python helper

REM 写 PowerShell profile
set PS_PROFILE_DIR=%USERPROFILE%\Documents\WindowsPowerShell
set PS_PROFILE=%PS_PROFILE_DIR%\Microsoft.PowerShell_profile.ps1
if not exist "%PS_PROFILE_DIR%" mkdir "%PS_PROFILE_DIR%"
if not exist "%PS_PROFILE%" (
    (
        echo # === viral-titles: disable GCM popup ===
        echo $env:GIT_TERMINAL_PROMPT = '0'
    ) > "%PS_PROFILE%"
    echo   ✓ 创建 PowerShell profile + GIT_TERMINAL_PROMPT=0
) else (
    findstr /c:"GIT_TERMINAL_PROMPT" "%PS_PROFILE%" >nul 2>&1
    if errorlevel 1 (
        echo.>> "%PS_PROFILE%"
        echo # === viral-titles: disable GCM popup ===>> "%PS_PROFILE%"
        echo $env:GIT_TERMINAL_PROMPT = '0'>> "%PS_PROFILE%"
        echo   ✓ PowerShell profile: 追加 GIT_TERMINAL_PROMPT=0
    ) else (
        echo   ✓ PowerShell profile: GIT_TERMINAL_PROMPT=0 已存在
    )
)

REM ========== 创建父目录 ==========
echo.
echo ▶ [2/3] 安装到 %TARGET_DIR% ...
for %%D in ("%TARGET_DIR%") do set PARENT_DIR=%%~dpD
if not exist "%PARENT_DIR%" mkdir "%PARENT_DIR%"

REM 如果已经存在,做更新
if exist "%TARGET_DIR%\.git" (
    echo ✓ 已存在 %TARGET_DIR%
    echo ▶ 自动 pull 最新数据 ...
    cd /d %TARGET_DIR%
    git pull origin main
    echo ✓ 更新完成
    exit /b 0
)

REM 如果存在但不是 git 仓,删除重装
if exist "%TARGET_DIR%" (
    echo ⚠ %TARGET_DIR% 已存在但不是 git 仓库
    set /p REPLY="  是否删除后重装? [y/N] "
    if /i not "%REPLY%"=="y" (
        echo ✗ 取消安装
        exit /b 1
    )
    rmdir /s /q "%TARGET_DIR%"
)

REM 完整 git clone(非 shallow)
echo ▶ git clone(完整历史,支持后续 update) ...
git clone "%REPO_URL%" "%TARGET_DIR%"

echo.
echo ✓ 安装完成: %TARGET_DIR%
echo.
echo 下次更新数据:
echo   cd /d %TARGET_DIR%
echo   git pull origin main
echo.
echo 重启你的 Agent(Cursor / OpenClaw / Claude Desktop)即可加载

endlocal