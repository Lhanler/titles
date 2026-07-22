@echo off
REM install.bat - 一键安装 viral-titles-mcp
REM 用法:双击 install.bat

echo ====================================
echo  viral-titles-mcp installer
echo ====================================
echo.

REM 1. 装 mcp 包(及依赖)
echo [1/2] Installing mcp package...
python -m pip install mcp>=1.0.0
if errorlevel 1 (
    echo [ERROR] pip install failed
    echo Try: python -m pip install --user mcp>=1.0.0
    exit /b 1
)

REM 2. 装本包(可编辑模式,便于修改)
echo.
echo [2/2] Installing viral-titles-mcp package (editable mode)...
python -m pip install -e .
if errorlevel 1 (
    echo [ERROR] package install failed
    exit /b 1
)

echo.
echo ====================================
echo  [OK] Installation complete!
echo ====================================
echo.
echo Next steps:
echo   1. Test the server:    start-mcp.bat
echo   2. Configure your MCP client (see mcp_config_examples\)
echo.
echo For Claude Desktop, add to %%APPDATA%%\Claude\claude_desktop_config.json:
echo {
echo   "mcpServers": {
echo     "viral-titles": {
echo       "command": "python",
echo       "args": ["-m", "viral_titles_mcp"]
echo     }
echo   }
echo }
echo.
echo Then restart Claude Desktop.
pause