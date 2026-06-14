@echo off
chcp 65001 >nul 2>&1
setlocal EnableExtensions
cd /d "%~dp0"

echo ========================================
echo   SQA Inspection App - 操作手冊
echo ========================================
echo.

set "GUIDE=%~dp0docs\index.html"
if not exist "%GUIDE%" (
    echo [ERROR] 找不到: %GUIDE%
    pause
    exit /b 1
)

start "" "%GUIDE%"
echo 已在預設瀏覽器開啟: %GUIDE%
echo.
pause
