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

REM 检查 git
where git >nul 2>&1
if errorlevel 1 (
    echo ✗ 需要 git 命令(请先安装 Git for Windows)
    exit /b 1
)

REM 创建父目录
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