@echo off
chcp 65001 >nul 2>&1
set "PROJECT_ROOT=%~dp0"
if "%PROJECT_ROOT:~-1%"=="\" set "PROJECT_ROOT=%PROJECT_ROOT:~0,-1%"

echo ========================================
echo   公司電腦無 Python 使用指南
echo ========================================
echo.
echo 正在開啟使用指南...
echo.

start "" "%PROJECT_ROOT%\無Python使用指南.md"

echo ✅ 已開啟使用指南
echo.
echo 💡 快速提示:
echo    • 操作手冊: 開啟操作手冊（無Python）.bat
echo    • 執行測試: run_tests.bat
echo    • 查看報告: 開啟測試報告.bat
echo.
timeout /t 3 /nobreak >nul
