@echo off
chcp 65001 >nul 2>&1
setlocal EnableExtensions
cd /d "%~dp0"

echo ========================================
echo   Semi Inspection Desktop
echo ========================================
echo.

call "%~dp0run_semi.bat"
set "EXIT_CODE=%ERRORLEVEL%"

if %EXIT_CODE% neq 0 (
    echo.
    echo [ERROR] 無法啟動 Inspection App
    pause
    exit /b %EXIT_CODE%
)

echo.
echo Inspection App 已啟動。
echo 執行檔: %~dp0SemiInspectionDesktop\bin\Debug\SemiInspectionDesktop.exe
echo.
exit /b 0
