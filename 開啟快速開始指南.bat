@echo off
chcp 65001 >nul 2>&1
set "PROJECT_ROOT=%~dp0"
if "%PROJECT_ROOT:~-1%"=="\" set "PROJECT_ROOT=%PROJECT_ROOT:~0,-1%"

echo ========================================
echo   Windows 11 快速開始指南
echo ========================================
echo.
echo 正在開啟快速開始指南...
echo.

REM 嘗試用預設程式開啟 Markdown
start "" "%PROJECT_ROOT%\WINDOWS_快速開始.md"

echo ✅ 已開啟快速開始指南
echo.
echo 💡 提示:
echo    如果檔案無法開啟，請手動開啟:
echo    %PROJECT_ROOT%\WINDOWS_快速開始.md
echo.
timeout /t 3 /nobreak >nul
