@echo off
chcp 65001 >nul 2>&1
set "PROJECT_ROOT=%~dp0"
if "%PROJECT_ROOT:~-1%"=="\" set "PROJECT_ROOT=%PROJECT_ROOT:~0,-1%"

echo 正在開啟 Windows 疑難排解指南...
start "" "%PROJECT_ROOT%\WINDOWS_疑難排解.md"

REM 如果 Markdown 無法開啟，嘗試用瀏覽器開啟（如果有 HTML 版本）
timeout /t 2 /nobreak >nul
