@echo off
chcp 65001 >nul 2>&1
setlocal EnableExtensions
cd /d "%~dp0"

echo ========================================
echo   Inspection App FlaUI BDD - Operation Guide
echo ========================================
echo.

set "GUIDE=%~dp0操作說明.html"
if not exist "%GUIDE%" (
    echo [ERROR] Not found: %GUIDE%
    pause
    exit /b 1
)

start "" "%GUIDE%"
echo Opened in default browser: %GUIDE%
echo.
pause
