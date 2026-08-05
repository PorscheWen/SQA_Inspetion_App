@echo off
chcp 65001 > nul
setlocal

REM ===============================================
REM 開啟新手入門指南 (http://localhost:6688/docs/新手入門指南.html)
REM ===============================================

echo ========================================
echo 🚀 開啟新手入門指南
echo ========================================
echo.

REM 1. 檢查 Python 是否安裝
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [錯誤] 找不到 Python。請先安裝 Python 3.x
    echo 下載網址: https://www.python.org/downloads/
    pause
    exit /b 1
)

REM 2. 檢查必要檔案
if not exist "docs\server.py" (
    echo [錯誤] 找不到 docs\server.py
    pause
    exit /b 1
)

if not exist "docs\新手入門指南.html" (
    echo [錯誤] 找不到 docs\新手入門指南.html
    pause
    exit /b 1
)

REM 3. 檢查 Port 6688 是否已被占用
netstat -ano | findstr ":6688" >nul 2>&1
if %errorlevel% equ 0 (
    echo [提示] Port 6688 已在使用中（伺服器可能已啟動）
    echo [提示] 直接開啟瀏覽器...
    timeout /t 2 /nobreak >nul
    start "" "http://localhost:6688/docs/新手入門指南.html"
    exit /b 0
)

REM 4. 啟動 Python 伺服器（在新視窗）
echo [1/2] 啟動 Python 伺服器 (Port 6688)...
start "操作手冊伺服器 (Port 6688)" cmd /k "cd docs && python server.py"

REM 5. 等待伺服器啟動
echo [2/2] 等待伺服器啟動...
timeout /t 3 /nobreak >nul

REM 6. 開啟瀏覽器
echo [完成] 開啟瀏覽器: http://localhost:6688/docs/新手入門指南.html
start "" "http://localhost:6688/docs/新手入門指南.html"

echo.
echo ========================================
echo ✅ 新手入門指南已開啟
echo ========================================
echo.
echo 💡 提示:
echo   - 伺服器將在新的 CMD 視窗中執行
echo   - 關閉 CMD 視窗即可停止伺服器
echo   - 瀏覽器網址: http://localhost:6688/docs/新手入門指南.html
echo.

endlocal
