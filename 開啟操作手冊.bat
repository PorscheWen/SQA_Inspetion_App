@echo off
chcp 65001 >nul 2>&1
setlocal EnableExtensions EnableDelayedExpansion
set "PROJECT_ROOT=%~dp0"
if defined APP_ROOT set "PROJECT_ROOT=%APP_ROOT%"
if defined SQA_APP_ROOT set "PROJECT_ROOT=%SQA_APP_ROOT%"
if "%PROJECT_ROOT:~-1%"=="\" set "PROJECT_ROOT=%PROJECT_ROOT:~0,-1%"

REM 顯示診斷資訊（用於除錯）
echo 診斷資訊:
echo   批次檔位置: %~dp0
echo   工作目錄: %PROJECT_ROOT%
echo.

cd /d "%PROJECT_ROOT%" 2>nul
if errorlevel 1 (
    echo ❌ 錯誤: 無法切換到專案目錄
    echo    目標路徑: %PROJECT_ROOT%
    echo.
    echo 💡 可能原因:
    echo    1. 路徑中包含特殊字元
    echo    2. 沒有該目錄的存取權限
    echo    3. 磁碟機不存在
    echo.
    pause
    exit /b 1
)

echo ========================================
echo   SQA Inspection App - 操作手冊
echo ========================================
echo.

set "PORT=6688"
set "URL=http://localhost:%PORT%/docs/index.html"
set "MANUAL_SERVER_PORT=%PORT%"

REM ===== 環境檢查 =====
echo [1/5] 檢查 Python 環境...
where python >nul 2>&1
if errorlevel 1 (
    echo ❌ 找不到 Python
    echo.
    echo 💡 您有兩個選擇:
    echo.
    echo    方案 A: 安裝 Python（完整功能）
    echo       1. 從 https://www.python.org/downloads/ 下載 Python 3.8+
    echo       2. 安裝時勾選 "Add Python to PATH"
    echo       3. 重新開啟命令提示字元
    echo.
    echo    方案 B: 使用無需 Python 的版本（推薦給公司電腦）
    echo       執行: 開啟操作手冊（無Python）.bat
    echo       或直接開啟: docs\index.html
    echo.
    echo 按任意鍵使用方案 B（離線開啟操作手冊）...
    pause >nul
    echo.
    echo 正在以離線模式開啟操作手冊...
    set "INDEX_FILE=%PROJECT_ROOT%\docs\index.html"
    if exist "!INDEX_FILE!" (
        start "" "!INDEX_FILE!"
        echo ✅ 已開啟操作手冊（離線模式）
        echo.
        echo ⚠️  注意: 部分互動功能（如一鍵執行 .bat）無法使用
        echo.
    ) else (
        echo ❌ 找不到 docs\index.html
        echo.
    )
    pause
    exit /b 1
)

python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 錯誤: Python 無法執行
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo ✅ Python 環境正常: %PYTHON_VERSION%
echo.

echo [2/5] 檢查必要檔案...
set "SERVER_PATH=%PROJECT_ROOT%\docs\server.py"
echo   檢查檔案: %SERVER_PATH%
if not exist "%SERVER_PATH%" (
    echo ❌ 錯誤: 找不到 docs\server.py
    echo.
    echo 💡 可能原因:
    echo    1. 專案檔案不完整（請重新下載或 git clone）
    echo    2. 檔案被防毒軟體隔離
    echo    3. 解壓縮不完整
    echo.
    echo 📂 目前目錄結構:
    if exist "%PROJECT_ROOT%\docs" (
        echo    docs\ 資料夾存在
        dir /b "%PROJECT_ROOT%\docs\*.py" 2>nul
    ) else (
        echo    ❌ docs\ 資料夾不存在！
    )
    echo.
    pause
    exit /b 1
)
echo ✅ 必要檔案存在
echo.

echo [3/5] 檢查 Port %PORT% 是否被占用...
REM 先檢查服務是否已經在執行
python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:%PORT%/api/health', timeout=2)" >nul 2>&1
if not errorlevel 1 (
    echo ✅ 操作手冊伺服器已在執行
    echo    正在開啟瀏覽器...
    start "" "%URL%"
    echo    URL: %URL%
    echo.
    echo 💡 如需重啟伺服器，請先在工作管理員中結束 python.exe 進程
    echo.
    pause
    exit /b 0
)

REM 檢查 Port 是否被其他程序占用
netstat -ano 2>nul | findstr ":%PORT% " | findstr "LISTENING" >nul 2>&1
if not errorlevel 1 (
    echo ⚠️  警告: Port %PORT% 被其他程序占用
    echo.
    echo 占用 Port 的進程:
    for /f "tokens=5" %%a in ('netstat -ano 2^>nul ^| findstr ":%PORT% " ^| findstr "LISTENING"') do (
        set "PID=%%a"
        echo    PID: !PID!
        for /f "tokens=1" %%b in ('tasklist /FI "PID eq !PID!" /NH 2^>nul') do echo    Process: %%b
    )
    echo.
    echo 💡 解決方法:
    echo    1. 關閉占用 Port 的程式
    echo    2. 或在工作管理員中結束該進程
    echo    3. 或修改 config.json 使用其他 Port
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
    echo.
    echo 💡 可能的解決方法:
    echo    1. 以系統管理員身分執行此批次檔
    echo    2. 檢查 Windows 防火牆設定
    echo    3. 檢查防毒軟體是否阻擋
    echo.
    echo ⏸️  按任意鍵繼續嘗試啟動...
    pause >nul
) else (
    echo ✅ 具有綁定 Port %PORT% 的權限
)
echo.

echo [5/5] 環境檢查完成
echo.

REM ===== 啟動服務器 =====
echo 正在啟動操作手冊伺服器 (port %PORT%) ...
echo.
echo 📌 重要提示:
echo    • 瀏覽器會自動開啟操作手冊
echo    • 保持此視窗開啟，伺服器才能運作
echo    • 按 Ctrl+C 可停止伺服器
echo.
echo 伺服器 URL: %URL%
echo ========================================
echo.

REM 3 秒後自動開啟瀏覽器
timeout /t 3 /nobreak >nul 2>&1
start "" "%URL%" 2>nul

REM 啟動 Python 伺服器
set "APP_ROOT=%PROJECT_ROOT%"
python "%SERVER_PATH%" 2>&1

REM 檢查是否發生錯誤
if errorlevel 1 (
    echo.
    echo ========================================
    echo ❌ 伺服器啟動失敗！
    echo.
    echo 💡 可能的原因:
    echo    1. Python 模組缺失（檢查是否安裝 Python 標準庫）
    echo    2. Port 權限問題（嘗試以系統管理員身分執行）
    echo    3. 防火牆阻擋（檢查 Windows Defender 或其他防毒軟體）
    echo.
    echo 📝 建議:
    echo    1. 執行: python "%SERVER_PATH%"
    echo    2. 查看詳細錯誤訊息
    echo.
    pause
    exit /b 1
)

echo.
echo 伺服器已關閉
pause
exit /b 0
