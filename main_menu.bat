@echo off
chcp 65001 >nul 2>&1
setlocal EnableExtensions EnableDelayedExpansion
set "PROJECT_ROOT=%~dp0"
if "%PROJECT_ROOT:~-1%"=="\" set "PROJECT_ROOT=%PROJECT_ROOT:~0,-1%"
cd /d "%PROJECT_ROOT%" 2>nul

REM 載入環境變數
call "%PROJECT_ROOT%\setup_env.bat" 2>nul

:MAIN_MENU
cls
echo ========================================
echo   SQA Inspection App - 主選單
echo ========================================
echo.
echo 【測試執行】
echo   [1] 執行全部測試
echo   [2] 執行單一測試
echo   [3] 啟動測試平台 (Web 控制台)
echo.
echo 【應用程式】
echo   [4] 啟動 Inspection App
echo   [5] 建置 Inspection App
echo.
echo 【報告與文件】
echo   [6] 開啟測試報告
echo   [7] 開啟操作手冊
echo   [8] 開啟操作手冊 (無 Python 版)
echo.
echo 【指南與說明】
echo   [9]  新手入門指南
echo   [10] Windows 快速開始指南
echo   [11] 無 Python 使用指南
echo   [12] 疑難排解指南
echo.
echo 【工具】
echo   [13] 環境診斷工具
echo   [14] 開啟 TPS 文件
echo   [15] 開啟 FlaUI Inspector
echo.
echo   [0] 退出
echo.
echo ========================================
echo.

set /p choice="請選擇功能 (0-15): "

REM ===== 測試執行 =====
if "%choice%"=="1" goto RUN_ALL_TESTS
if "%choice%"=="2" goto RUN_SINGLE_TEST
if "%choice%"=="3" goto START_WEB_DASHBOARD

REM ===== 應用程式 =====
if "%choice%"=="4" goto START_APP
if "%choice%"=="5" goto BUILD_APP

REM ===== 報告與文件 =====
if "%choice%"=="6" goto OPEN_REPORT
if "%choice%"=="7" goto OPEN_MANUAL
if "%choice%"=="8" goto OPEN_MANUAL_NO_PYTHON

REM ===== 指南與說明 =====
if "%choice%"=="9" goto OPEN_BEGINNER_GUIDE
if "%choice%"=="10" goto OPEN_WINDOWS_GUIDE
if "%choice%"=="11" goto OPEN_NO_PYTHON_GUIDE
if "%choice%"=="12" goto OPEN_TROUBLESHOOT_GUIDE

REM ===== 工具 =====
if "%choice%"=="13" goto RUN_DIAGNOSTIC
if "%choice%"=="14" goto OPEN_TPS
if "%choice%"=="15" goto OPEN_INSPECTOR

REM ===== 退出 =====
if "%choice%"=="0" goto EXIT_MENU

echo.
echo ❌ 無效的選擇，請輸入 0-15
timeout /t 2 >nul
goto MAIN_MENU

REM ========================================
REM   測試執行功能
REM ========================================

:RUN_ALL_TESTS
cls
echo ========================================
echo   執行全部測試
echo ========================================
echo.
echo [1/3] 建置被測程式...
call :BUILD_SEMI_INTERNAL
if errorlevel 1 (
    echo.
    echo ❌ 建置失敗，無法繼續執行測試
    pause
    goto MAIN_MENU
)

set "TEST_DIR=%PROJECT_ROOT%\Automation_testcase\Project_FlaUIBDD\Testcase_Inspection_App_FlaUI_BDD"
cd /d "%TEST_DIR%"

echo.
echo [2/3] 建置測試專案...
dotnet build -c Release
if errorlevel 1 (
    echo.
    echo ❌ 測試專案建置失敗
    pause
    goto MAIN_MENU
)

echo.
echo [3/3] 執行全部測試案例 (TC01-TC10)...
dotnet test -c Release --logger "console;verbosity=normal"

echo.
echo ========================================
echo   測試執行完成
echo ========================================
pause
goto MAIN_MENU

:RUN_SINGLE_TEST
cls
echo ========================================
echo   執行單一測試
echo ========================================
echo.
echo 可用測試: TC01, TC02, TC03, TC04, TC05,
echo          TC06, TC07, TC08, TC09, TC10
echo.

set /p TC="請輸入測試編號 (例如 TC01): "
set "TC=%TC: =%"

if "%TC%"=="" (
    echo ❌ 未指定測試編號
    pause
    goto MAIN_MENU
)

REM 驗證 TC 格式
set "VALID=0"
for %%t in (01 02 03 04 05 06 07 08 09 10) do (
    if /i "%TC%"=="TC%%t" set "VALID=1"
)
if "%VALID%"=="0" (
    echo ❌ 無效的測試編號，請使用 TC01 ~ TC10
    pause
    goto MAIN_MENU
)

echo.
echo [1/3] 建置被測程式...
call :BUILD_SEMI_INTERNAL
if errorlevel 1 (
    echo.
    echo ❌ 建置失敗
    pause
    goto MAIN_MENU
)

set "TEST_DIR=%PROJECT_ROOT%\Automation_testcase\Project_FlaUIBDD\Testcase_Inspection_App_FlaUI_BDD"
cd /d "%TEST_DIR%"

echo.
echo [2/3] 建置測試專案...
dotnet build -c Release
if errorlevel 1 (
    echo ❌ 測試專案建置失敗
    pause
    goto MAIN_MENU
)

echo.
echo [3/3] 執行測試: %TC%...
dotnet test -c Release --filter "Name~%TC%"

echo.
echo ========================================
echo   測試執行完成
echo ========================================
pause
goto MAIN_MENU

:START_WEB_DASHBOARD
cls
echo ========================================
echo   啟動測試平台 (Web 控制台)
echo ========================================
echo.

REM 檢查 Python
where python >nul 2>&1
if errorlevel 1 (
    echo ❌ 找不到 Python
    echo.
    echo 此功能需要 Python 環境。
    echo.
    echo 替代方案:
    echo   • 使用選項 [1] 執行全部測試
    echo   • 使用選項 [2] 執行單一測試
    echo.
    pause
    goto MAIN_MENU
)

set "PORT=6690"
set "URL=http://localhost:%PORT%/"
set "FLAUIBDD_DASHBOARD_PORT=%PORT%"
set "DASHBOARD=%PROJECT_ROOT%\Automation_testcase\Project_FlaUIBDD\web_dashboard"

echo 正在檢查被測程式...
if not exist "%PROJECT_ROOT%\SemiInspectionDesktop\bin\Debug\SemiInspectionDesktop.exe" (
    echo 找不到被測程式，正在建置...
    call :BUILD_SEMI_INTERNAL
    if errorlevel 1 (
        pause
        goto MAIN_MENU
    )
)

echo.
echo 啟動 Web 控制台...
echo URL: %URL%
echo.
echo 💡 按 Ctrl+C 停止伺服器
echo.

start "" "%URL%"
python "%DASHBOARD%\server.py"

pause
goto MAIN_MENU

REM ========================================
REM   應用程式功能
REM ========================================

:START_APP
cls
echo ========================================
echo   啟動 Inspection App
echo ========================================
echo.

set "EXE=%PROJECT_ROOT%\SemiInspectionDesktop\bin\Debug\SemiInspectionDesktop.exe"

if not exist "%EXE%" (
    echo 找不到應用程式，正在建置...
    call :BUILD_SEMI_INTERNAL
    if errorlevel 1 (
        pause
        goto MAIN_MENU
    )
)

echo 正在啟動: %EXE%
echo.

start "" "%EXE%"

echo ✅ 應用程式已啟動
timeout /t 2 >nul
goto MAIN_MENU

:BUILD_APP
cls
echo ========================================
echo   建置 Inspection App
echo ========================================
echo.

call :BUILD_SEMI_INTERNAL

echo.
pause
goto MAIN_MENU

REM ========================================
REM   報告與文件功能
REM ========================================

:OPEN_REPORT
cls
echo ========================================
echo   開啟測試報告
echo ========================================
echo.

set "TEST_DIR=%PROJECT_ROOT%\Automation_testcase\Project_FlaUIBDD\Testcase_Inspection_App_FlaUI_BDD"
set "REPORT_BIN=%TEST_DIR%\bin\Release\net8.0-windows\reports\TestResultReport.html"
set "REPORT_SYNC=%TEST_DIR%\reports\TestResultReport.html"

if exist "%REPORT_BIN%" (
    set "REPORT=%REPORT_BIN%"
) else if exist "%REPORT_SYNC%" (
    set "REPORT=%REPORT_SYNC%"
) else (
    echo ❌ 找不到測試報告
    echo.
    echo 請先執行測試:
    echo   • 選項 [1] 執行全部測試
    echo   • 選項 [2] 執行單一測試
    echo.
    pause
    goto MAIN_MENU
)

echo 正在開啟報告: !REPORT!
echo.

REM 嘗試用現代瀏覽器開啟
set "BROWSER="
if exist "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe" set "BROWSER=%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"
if not defined BROWSER if exist "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" set "BROWSER=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
if not defined BROWSER if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" set "BROWSER=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if not defined BROWSER if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" set "BROWSER=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"

if defined BROWSER (
    start "" "!BROWSER!" "!REPORT!"
) else (
    start "" "!REPORT!"
)

echo ✅ 已開啟測試報告
timeout /t 2 >nul
goto MAIN_MENU

:OPEN_MANUAL
cls
echo ========================================
echo   開啟操作手冊 (需要 Python)
echo ========================================
echo.

where python >nul 2>&1
if errorlevel 1 (
    echo ❌ 找不到 Python
    echo.
    echo 替代方案:
    echo   • 使用選項 [8] 開啟操作手冊 (無 Python 版)
    echo   • 直接開啟: docs\index.html
    echo.
    pause
    goto MAIN_MENU
)

set "PORT=6688"
set "URL=http://localhost:%PORT%/docs/index.html"
set "MANUAL_SERVER_PORT=%PORT%"

echo 正在啟動操作手冊伺服器 (port %PORT%)...
echo URL: %URL%
echo.
echo 💡 按 Ctrl+C 停止伺服器
echo.

timeout /t 2 >nul
start "" "%URL%"
python "%PROJECT_ROOT%\docs\server.py"

pause
goto MAIN_MENU

:OPEN_MANUAL_NO_PYTHON
cls
echo ========================================
echo   開啟操作手冊 (離線版)
echo ========================================
echo.

set "INDEX_FILE=%PROJECT_ROOT%\docs\index.html"

if not exist "%INDEX_FILE%" (
    echo ❌ 找不到: docs\index.html
    pause
    goto MAIN_MENU
)

echo 正在開啟: %INDEX_FILE%
echo.
echo 💡 這是離線版本，部分互動功能無法使用
echo.

REM 嘗試用現代瀏覽器開啟
set "BROWSER="
if exist "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe" set "BROWSER=%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"
if not defined BROWSER if exist "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" set "BROWSER=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
if not defined BROWSER if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" set "BROWSER=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if not defined BROWSER if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" set "BROWSER=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"

if defined BROWSER (
    start "" "%BROWSER%" "%INDEX_FILE%"
) else (
    start "" "%INDEX_FILE%"
)

echo ✅ 已開啟操作手冊
timeout /t 2 >nul
goto MAIN_MENU

REM ========================================
REM   指南與說明功能
REM ========================================

:OPEN_BEGINNER_GUIDE
start "" "%PROJECT_ROOT%\GETTING_STARTED.md"
echo ✅ 已開啟新手入門指南
timeout /t 2 >nul
goto MAIN_MENU

:OPEN_WINDOWS_GUIDE
start "" "%PROJECT_ROOT%\WINDOWS_QUICK_START.md"
echo ✅ 已開啟 Windows 快速開始指南
timeout /t 2 >nul
goto MAIN_MENU

:OPEN_NO_PYTHON_GUIDE
start "" "%PROJECT_ROOT%\NO_PYTHON_GUIDE.md"
echo ✅ 已開啟無 Python 使用指南
timeout /t 2 >nul
goto MAIN_MENU

:OPEN_TROUBLESHOOT_GUIDE
start "" "%PROJECT_ROOT%\WINDOWS_TROUBLESHOOTING.md"
echo ✅ 已開啟疑難排解指南
timeout /t 2 >nul
goto MAIN_MENU

REM ========================================
REM   工具功能
REM ========================================

:RUN_DIAGNOSTIC
cls
echo ========================================
echo   環境診斷工具
echo ========================================
echo.
echo 正在檢查系統環境...
echo.

echo [1/8] 系統資訊
echo ----------------------------------------
ver
echo 使用者: %USERNAME%
echo 專案路徑: %PROJECT_ROOT%
echo.

echo [2/8] Python 環境
echo ----------------------------------------
where python >nul 2>&1
if errorlevel 1 (
    echo ❌ 找不到 Python
) else (
    echo ✅ Python 路徑:
    where python
    python --version 2>&1
)
echo.

echo [3/8] .NET 環境
echo ----------------------------------------
where dotnet >nul 2>&1
if errorlevel 1 (
    echo ❌ 找不到 .NET SDK
) else (
    echo ✅ .NET 版本:
    dotnet --version
)
echo.

echo [4/8] 專案檔案結構
echo ----------------------------------------
if exist "%PROJECT_ROOT%\docs" (
    echo ✅ docs\ 資料夾存在
) else (
    echo ❌ docs\ 資料夾不存在
)
if exist "%PROJECT_ROOT%\SemiInspectionDesktop" (
    echo ✅ SemiInspectionDesktop\ 資料夾存在
) else (
    echo ❌ SemiInspectionDesktop\ 資料夾不存在
)
if exist "%PROJECT_ROOT%\Automation_testcase" (
    echo ✅ Automation_testcase\ 資料夾存在
) else (
    echo ❌ Automation_testcase\ 資料夾不存在
)
echo.

echo [5/8] 被測程式狀態
echo ----------------------------------------
if exist "%PROJECT_ROOT%\SemiInspectionDesktop\bin\Debug\SemiInspectionDesktop.exe" (
    echo ✅ 被測程式已建置
) else (
    echo ⚠️  被測程式未建置（需要執行建置）
)
echo.

echo [6/8] 測試報告狀態
echo ----------------------------------------
set "TEST_DIR=%PROJECT_ROOT%\Automation_testcase\Project_FlaUIBDD\Testcase_Inspection_App_FlaUI_BDD"
if exist "%TEST_DIR%\reports\TestResultReport.html" (
    echo ✅ 測試報告存在
) else (
    echo ⚠️  測試報告不存在（需要執行測試）
)
echo.

echo [7/8] Port 檢查
echo ----------------------------------------
netstat -ano 2>nul | findstr ":6688 " | findstr "LISTENING" >nul 2>&1
if not errorlevel 1 (
    echo ⚠️  Port 6688 被占用（操作手冊）
) else (
    echo ✅ Port 6688 可用
)
netstat -ano 2>nul | findstr ":6690 " | findstr "LISTENING" >nul 2>&1
if not errorlevel 1 (
    echo ⚠️  Port 6690 被占用（測試平台）
) else (
    echo ✅ Port 6690 可用
)
echo.

echo [8/8] 診斷完成
echo ========================================
echo.

echo 💡 建議:
if not exist "%PROJECT_ROOT%\SemiInspectionDesktop\bin\Debug\SemiInspectionDesktop.exe" (
    echo   • 執行選項 [5] 建置應用程式
)
echo   • 如果找不到 Python，請參考無 Python 使用指南
echo   • 詳細疑難排解請查看 WINDOWS_TROUBLESHOOTING.md
echo.

pause
goto MAIN_MENU

:OPEN_TPS
start "" "%PROJECT_ROOT%\Automation_testcase\Test_cases\TPS.md"
echo ✅ 已開啟 TPS 文件
timeout /t 2 >nul
goto MAIN_MENU

:OPEN_INSPECTOR
cls
echo ========================================
echo   開啟 FlaUI Inspector
echo ========================================
echo.

set "INSPECTOR_BAT=%PROJECT_ROOT%\Automation_testcase\Project_FlaUIBDD\Testcase_Inspection_App_FlaUI_BDD\open_inspector.bat"

if exist "%INSPECTOR_BAT%" (
    echo 正在啟動 FlaUI Inspector...
    call "%INSPECTOR_BAT%"
) else (
    echo ❌ 找不到 Inspector 啟動腳本
    echo.
    echo 請檢查路徑:
    echo %INSPECTOR_BAT%
    pause
)

goto MAIN_MENU

REM ========================================
REM   內部函式
REM ========================================

:BUILD_SEMI_INTERNAL
echo 正在建置 SemiInspectionDesktop...

set "MSBUILD="
if exist "%ProgramFiles%\MSBuild\14.0\Bin\MSBuild.exe" set "MSBUILD=%ProgramFiles%\MSBuild\14.0\Bin\MSBuild.exe"
if exist "%ProgramFiles(x86)%\MSBuild\14.0\Bin\MSBuild.exe" set "MSBUILD=%ProgramFiles(x86)%\MSBuild\14.0\Bin\MSBuild.exe"
if exist "%WINDIR%\Microsoft.NET\Framework\v3.5\MSBuild.exe" set "MSBUILD=%WINDIR%\Microsoft.NET\Framework\v3.5\MSBuild.exe"
if exist "%WINDIR%\Microsoft.NET\Framework64\v3.5\MSBuild.exe" set "MSBUILD=%WINDIR%\Microsoft.NET\Framework64\v3.5\MSBuild.exe"

if "%MSBUILD%"=="" (
    echo ❌ 找不到 MSBuild
    echo.
    echo 請安裝:
    echo   • Visual Studio
    echo   • Build Tools for Visual Studio
    echo.
    exit /b 1
)

"%MSBUILD%" "%PROJECT_ROOT%\SemiInspectionDesktop.sln" /p:Configuration=Debug /v:m
if errorlevel 1 (
    echo ❌ 建置失敗
    exit /b 1
)

REM 複製測試資料
if exist "%PROJECT_ROOT%\Recipe_data" (
    if not exist "%PROJECT_ROOT%\SemiInspectionDesktop\bin\Debug\Recipe_data" mkdir "%PROJECT_ROOT%\SemiInspectionDesktop\bin\Debug\Recipe_data"
    xcopy /Y "%PROJECT_ROOT%\Recipe_data\*.*" "%PROJECT_ROOT%\SemiInspectionDesktop\bin\Debug\Recipe_data\" >nul 2>&1
)

echo ✅ 建置成功: SemiInspectionDesktop\bin\Debug\SemiInspectionDesktop.exe
exit /b 0

REM ========================================
REM   退出
REM ========================================

:EXIT_MENU
cls
echo.
echo ========================================
echo   感謝使用 SQA Inspection App
echo ========================================
echo.
timeout /t 1 >nul
exit /b 0
