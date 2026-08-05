@echo off
chcp 65001 >nul 2>&1
setlocal EnableExtensions EnableDelayedExpansion

echo ========================================
echo   SQA Inspection App - 環境診斷工具
echo ========================================
echo.
echo 此工具會檢查您的環境並提供診斷報告
echo.
pause

set "PROJECT_ROOT=%~dp0"
if "%PROJECT_ROOT:~-1%"=="\" set "PROJECT_ROOT=%PROJECT_ROOT:~0,-1%"

echo 開始診斷...
echo.

REM ===== 系統資訊 =====
echo [1/8] 系統資訊
echo ----------------------------------------
ver
echo 使用者: %USERNAME%
echo 電腦名稱: %COMPUTERNAME%
echo 當前路徑: %CD%
echo 專案路徑: %PROJECT_ROOT%
echo.

REM ===== Python 檢查 =====
echo [2/8] Python 環境
echo ----------------------------------------
where python >nul 2>&1
if errorlevel 1 (
    echo ❌ 找不到 Python
    echo    請從 https://www.python.org/downloads/ 安裝
) else (
    echo ✅ Python 路徑:
    where python
    echo.
    python --version 2>&1
    echo.
    echo Python 可執行檔位置:
    python -c "import sys; print(sys.executable)" 2>&1
)
echo.

REM ===== 檔案結構檢查 =====
echo [3/8] 專案檔案結構
echo ----------------------------------------
if exist "%PROJECT_ROOT%\docs" (
    echo ✅ docs\ 資料夾存在
    if exist "%PROJECT_ROOT%\docs\server.py" (
        echo ✅ docs\server.py 存在
    ) else (
        echo ❌ docs\server.py 不存在
    )
    if exist "%PROJECT_ROOT%\docs\index.html" (
        echo ✅ docs\index.html 存在
    ) else (
        echo ⚠️  docs\index.html 不存在
    )
) else (
    echo ❌ docs\ 資料夾不存在
)
echo.

if exist "%PROJECT_ROOT%\SemiInspectionDesktop" (
    echo ✅ SemiInspectionDesktop\ 資料夾存在
) else (
    echo ⚠️  SemiInspectionDesktop\ 資料夾不存在
)
echo.

REM ===== Port 檢查 =====
echo [4/8] Port 占用檢查
echo ----------------------------------------
echo 檢查常用 Port...
for %%p in (6688 8000 8080 5000) do (
    netstat -ano 2>nul | findstr ":%%p " | findstr "LISTENING" >nul 2>&1
    if not errorlevel 1 (
        echo ⚠️  Port %%p 被占用
        for /f "tokens=5" %%a in ('netstat -ano 2^>nul ^| findstr ":%%p " ^| findstr "LISTENING"') do (
            set "PID=%%a"
            for /f "tokens=1" %%b in ('tasklist /FI "PID eq !PID!" /NH 2^>nul') do (
                echo    PID: !PID! - Process: %%b
            )
        )
    ) else (
        echo ✅ Port %%p 可用
    )
)
echo.

REM ===== Python 模組檢查 =====
echo [5/8] Python 標準模組
echo ----------------------------------------
python -c "import http.server; print('✅ http.server')" 2>nul || echo ❌ http.server
python -c "import socketserver; print('✅ socketserver')" 2>nul || echo ❌ socketserver
python -c "import json; print('✅ json')" 2>nul || echo ❌ json
python -c "import urllib; print('✅ urllib')" 2>nul || echo ❌ urllib
python -c "import pathlib; print('✅ pathlib')" 2>nul || echo ❌ pathlib
echo.

REM ===== 網路測試 =====
echo [6/8] 網路連線測試
echo ----------------------------------------
ping -n 1 127.0.0.1 >nul 2>&1
if errorlevel 1 (
    echo ❌ localhost 無法連線
) else (
    echo ✅ localhost (127.0.0.1) 連線正常
)
echo.

REM ===== 防火牆檢查 =====
echo [7/8] Windows 防火牆狀態
echo ----------------------------------------
netsh advfirewall show allprofiles state 2>nul | findstr "State"
if errorlevel 1 (
    echo ⚠️  無法檢查防火牆狀態（可能需要管理員權限）
)
echo.

REM ===== 權限測試 =====
echo [8/8] 檔案系統權限
echo ----------------------------------------
echo 測試檔案: > "%TEMP%\sqa_test.txt" 2>nul
if exist "%TEMP%\sqa_test.txt" (
    echo ✅ 可以寫入暫存資料夾
    del "%TEMP%\sqa_test.txt" 2>nul
) else (
    echo ❌ 無法寫入暫存資料夾
)

echo 測試檔案: > "%PROJECT_ROOT%\test.tmp" 2>nul
if exist "%PROJECT_ROOT%\test.tmp" (
    echo ✅ 可以寫入專案資料夾
    del "%PROJECT_ROOT%\test.tmp" 2>nul
) else (
    echo ❌ 無法寫入專案資料夾（可能需要管理員權限）
)
echo.

REM ===== 診斷總結 =====
echo ========================================
echo   診斷完成
echo ========================================
echo.
echo 💡 如果發現問題，請檢查上述標記為 ❌ 或 ⚠️ 的項目
echo.
echo 📝 常見解決方法:
echo    1. Python 未安裝 → 安裝 Python 3.8+ 並勾選 "Add to PATH"
echo    2. Port 被占用 → 關閉占用的程式或重新啟動電腦
echo    3. 防火牆阻擋 → 新增例外規則允許 Python
echo    4. 權限不足 → 以系統管理員身分執行
echo.
pause
