@echo off
chcp 65001 >nul 2>&1

echo ════════════════════════════════════════
echo   🏢 公司電腦快速參考卡
echo ════════════════════════════════════════
echo.
echo ✅ 以下功能全部不需要 Python！
echo.
echo ────────────────────────────────────────
echo   📋 常用操作
echo ────────────────────────────────────────
echo.
echo   [1] 查看操作手冊（離線版）
echo       → 開啟操作手冊（無Python）.bat
echo.
echo   [2] 執行全部測試
echo       → run_tests.bat
echo.
echo   [3] 執行單一測試
echo       → 執行單一測試.bat
echo.
echo   [4] 查看測試報告
echo       → 開啟測試報告.bat
echo.
echo   [5] 啟動被測程式
echo       → 啟動InspectionApp.bat
echo.
echo ────────────────────────────────────────
echo   📚 文件與指南
echo ────────────────────────────────────────
echo.
echo   [6] 無 Python 完整使用指南
echo       → 開啟無Python使用指南.bat
echo.
echo   [7] 快速參考卡（本文件）
echo       → 公司電腦快速參考.md
echo.
echo   [8] 疑難排解指南
echo       → 開啟疑難排解指南.bat
echo.
echo ────────────────────────────────────────
echo   💡 提示
echo ────────────────────────────────────────
echo.
echo   • 核心功能完全不需要 Python
echo   • 只有 Web 控制台需要 Python
echo   • 可以用命令列替代 Web 控制台
echo.
echo ════════════════════════════════════════
echo.
echo 請選擇要執行的操作 (1-8)，或按 0 退出
echo.

set /p choice="請輸入數字: "

if "%choice%"=="1" (
    echo.
    echo 正在開啟操作手冊...
    start "" "%~dp0開啟操作手冊（無Python）.bat"
) else if "%choice%"=="2" (
    echo.
    echo 正在執行全部測試...
    call "%~dp0run_tests.bat"
) else if "%choice%"=="3" (
    echo.
    echo 正在啟動單一測試工具...
    call "%~dp0執行單一測試.bat"
) else if "%choice%"=="4" (
    echo.
    echo 正在開啟測試報告...
    start "" "%~dp0開啟測試報告.bat"
) else if "%choice%"=="5" (
    echo.
    echo 正在啟動被測程式...
    start "" "%~dp0啟動InspectionApp.bat"
) else if "%choice%"=="6" (
    echo.
    echo 正在開啟無 Python 使用指南...
    start "" "%~dp0開啟無Python使用指南.bat"
) else if "%choice%"=="7" (
    echo.
    echo 正在開啟快速參考卡...
    start "" "%~dp0公司電腦快速參考.md"
) else if "%choice%"=="8" (
    echo.
    echo 正在開啟疑難排解指南...
    start "" "%~dp0開啟疑難排解指南.bat"
) else if "%choice%"=="0" (
    echo.
    echo 再見！
    timeout /t 1 /nobreak >nul
    exit /b 0
) else (
    echo.
    echo ❌ 無效的選擇，請輸入 0-8
    echo.
    pause
)

echo.
pause
