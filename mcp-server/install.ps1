# install.ps1 - PowerShell 一键安装
# 用法:powershell -ExecutionPolicy Bypass -File install.ps1

Write-Host "====================================" -ForegroundColor Cyan
Write-Host " viral-titles-mcp installer (PS1)"
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# 装 mcp
Write-Host "[1/2] Installing mcp package..." -ForegroundColor Yellow
& python -m pip install mcp>=1.0.0
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] pip install failed" -ForegroundColor Red
    exit 1
}

# 装本包
Write-Host ""
Write-Host "[2/2] Installing viral-titles-mcp (editable)..." -ForegroundColor Yellow
& python -m pip install -e .
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] package install failed" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host " [OK] Installation complete!"
Write-Host "====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next: run start-mcp.ps1 to test" -ForegroundColor Cyan