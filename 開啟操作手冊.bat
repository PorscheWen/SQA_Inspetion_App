@echo off
chcp 65001 >nul 2>&1
setlocal EnableExtensions
set "PROJECT_ROOT=%~dp0"
if defined APP_ROOT set "PROJECT_ROOT=%APP_ROOT%"
if defined SQA_APP_ROOT set "PROJECT_ROOT=%SQA_APP_ROOT%"
if "%PROJECT_ROOT:~-1%"=="\" set "PROJECT_ROOT=%PROJECT_ROOT:~0,-1%"
cd /d "%PROJECT_ROOT%"

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
python "%PROJECT_ROOT%\docs\server.py"
exit /b %ERRORLEVEL%
