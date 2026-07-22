@echo off
REM update-viral-titles.bat - Windows 一键更新本地 viral-titles skill 数据
REM
REM 用法:
REM   update-viral-titles.bat
REM
REM 原理:
REM   1. 自动找本地安装目录(常见 OpenClaw / Claude Desktop 路径)
REM   2. cd 进去 git pull origin main
REM   3. 显示更新条数 + 最新 commit

setlocal enabledelayedexpansion

echo ▶ 查找 viral-titles 安装位置 ...

set SKILL_DIR=
set CANDIDATES=^
    "%USERPROFILE%\.qclaw\skills\viral-titles";^
    "%USERPROFILE%\.qclaw\skills\viral-title-generator";^
    "%USERPROFILE%\.openclaw\skills\viral-titles";^
    "%USERPROFILE%\.claude\skills\viral-titles";^
    "%USERPROFILE%\.cursor\skills\viral-titles";^
    "%USERPROFILE%\.q\skills\viral-titles";^
    "%CD%"

for %%D in (%CANDIDATES%) do (
    if exist "%%D\.git" (
        set SKILL_DIR=%%D
        goto :found
    )
)

echo.
echo ✗ 未找到 viral-titles 安装位置(没有 .git 目录)
echo.
echo 请先用 git clone 完整安装:
echo   git clone https://github.com/Lhanler/titles.git %USERPROFILE%\.qclaw\skills\viral-titles
exit /b 1

:found
echo ✓ 找到: %SKILL_DIR%
cd /d %SKILL_DIR%

REM 记录更新前 commit
for /f "delims=" %%S in ('git rev-parse --short HEAD 2^>nul') do set OLD_SHA=%%S
if "%OLD_SHA%"=="" set OLD_SHA=none
echo   本地版本: %OLD_SHA%

echo.
echo ▶ git pull origin main ...

git pull origin main
if errorlevel 1 (
    echo.
    echo ✗ git pull 失败(可能网络问题)
    exit /b 1
)

for /f "delims=" %%S in ('git rev-parse --short HEAD') do set NEW_SHA=%%S
echo.
echo ✓ 已更新到: %NEW_SHA%

REM 显示 corpus 行数
if exist "data\title-corpus.jsonl" (
    for /f %%L in ('type "data\title-corpus.jsonl"^|find /c /v ""') do echo   corpus: %%L 条标题
)

if "%OLD_SHA%"=="%NEW_SHA%" echo   已是最新,无需更新

echo.
echo ✓ 完成。下次加载 skill 时会用最新数据。
endlocal