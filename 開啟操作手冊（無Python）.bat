@echo off
chcp 65001 >nul 2>&1
setlocal EnableExtensions
set "PROJECT_ROOT=%~dp0"
if "%PROJECT_ROOT:~-1%"=="\" set "PROJECT_ROOT=%PROJECT_ROOT:~0,-1%"

echo ========================================
echo   SQA Inspection App - 操作手冊
echo   (無需 Python 版本)
echo ========================================
echo.

set "INDEX_FILE=%PROJECT_ROOT%\docs\index.html"

REM 檢查檔案是否存在
if not exist "%INDEX_FILE%" (
    echo ❌ 錯誤: 找不到 docs\index.html
    echo.
    echo 請確認專案檔案完整
    pause
    exit /b 1
)

echo ✅ 找到操作手冊檔案
echo.
echo 📖 正在開啟操作手冊...
echo.
echo ⚠️  注意事項:
echo    • 這是離線版本，直接開啟 HTML 檔案
echo    • 部分互動功能（如一鍵執行 .bat）無法使用
echo    • 所有文件內容都可以正常閱讀
echo.

REM 嘗試用現代瀏覽器開啟
set "BROWSER="
if exist "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe" set "BROWSER=%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"
if not defined BROWSER if exist "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" set "BROWSER=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
if not defined BROWSER if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" set "BROWSER=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if not defined BROWSER if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" set "BROWSER=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
if not defined BROWSER if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" set "BROWSER=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"

if defined BROWSER (
    echo 使用瀏覽器: %BROWSER%
    start "" "%BROWSER%" "%INDEX_FILE%"
) else (
    echo 使用預設程式開啟
    start "" "%INDEX_FILE%"
)

echo.
echo ✅ 操作手冊已開啟
echo.
echo 💡 其他可用的文件（無需 Python）:
echo    • 新手入門指南: 新手入門指南.md
echo    • Windows 快速開始: WINDOWS_快速開始.md
echo    • 疑難排解指南: WINDOWS_疑難排解.md
echo.
echo 📂 操作手冊位置:
echo    %INDEX_FILE%
echo.
pause
