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

REM ===== 環境檢查 =====
echo [1/5] 檢查 Python 環境...
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 錯誤: 找不到 Python，請先安裝 Python 3
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo ✅ Python 環境正常: %PYTHON_VERSION%
echo.

echo [2/5] 檢查必要檔案...
if not exist "%PROJECT_ROOT%\docs\server.py" (
    echo ❌ 錯誤: 找不到 docs\server.py
    pause
    exit /b 1
)
echo ✅ 必要檔案存在
echo.

echo [3/5] 檢查 Port %PORT% 是否被占用...
python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:%PORT%/api/health', timeout=2)" >nul 2>&1
if not errorlevel 1 (
    echo ✅ 操作手冊伺服器已在執行
    echo    正在開啟瀏覽器...
    start "" "%URL%"
    echo    URL: %URL%
    echo.
    pause
    exit /b 0
)

REM 檢查 Port 是否被其他程序占用
netstat -ano | findstr ":%PORT% " | findstr "LISTENING" >nul 2>&1
if not errorlevel 1 (
    echo ⚠️  警告: Port %PORT% 似乎被其他程序占用
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%PORT% " ^| findstr "LISTENING"') do (
        echo    PID: %%a
        for /f "tokens=1" %%b in ('tasklist /FI "PID eq %%a" /NH 2^>nul') do echo    Process: %%b
    )
    echo    請先關閉該程序或使用不同的 Port
    echo.
    pause
    exit /b 1
)
echo ✅ Port %PORT% 可用
echo.

echo [4/5] 檢查網路權限...
python -c "import socket; s=socket.socket(); s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1); s.bind(('127.0.0.1', %PORT%)); s.close()" >nul 2>&1
if errorlevel 1 (
    echo ⚠️  警告: 可能無法綁定 Port %PORT%
    echo    請檢查防火牆設定或使用管理員權限執行
) else (
    echo ✅ 具有綁定 Port %PORT% 的權限
)
echo.

echo [5/5] 環境檢查完成
echo.

REM ===== 啟動服務器 =====
echo 正在啟動操作手冊伺服器 (port %PORT%) ...
echo.
echo 伺服器 URL: %URL%
echo 按 Ctrl+C 停止伺服器
echo ========================================
echo.

start "" "%URL%"
python "%PROJECT_ROOT%\docs\server.py"
exit /b %ERRORLEVEL%
