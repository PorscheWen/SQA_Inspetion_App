@echo off
chcp 65001 >nul 2>&1
setlocal EnableExtensions
cd /d "%~dp0"

echo ========================================
echo   SQA Inspection App - 操作手冊
echo ========================================
echo.

set "PORT=6688"
set "URL=http://localhost:%PORT%/docs/index.html"
set "MANUAL_SERVER_PORT=%PORT%"

python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:%PORT%/api/health', timeout=2)" >nul 2>&1
if not errorlevel 1 (
    echo 操作手冊伺服器已在執行，開啟瀏覽器...
    start "" "%URL%"
    echo %URL%
    pause
    exit /b 0
)

echo 啟動操作手冊伺服器 (port %PORT%) ...
start "" "%URL%"
python "%~dp0docs\server.py"
exit /b %ERRORLEVEL%
