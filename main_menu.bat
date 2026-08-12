@echo off
setlocal EnableExtensions EnableDelayedExpansion
set "PROJECT_ROOT=%~dp0"
if "%PROJECT_ROOT:~-1%"=="\" set "PROJECT_ROOT=%PROJECT_ROOT:~0,-1%"
cd /d "%PROJECT_ROOT%" 2>nul

REM Load environment variables
call "%PROJECT_ROOT%\setup_env.bat" 2>nul

:MAIN_MENU
cls
echo ========================================
echo   SQA Inspection App - Main Menu
echo ========================================
echo.
echo [TEST]
echo   [1] Run all tests
echo   [2] Run single test
echo   [3] Start web dashboard
echo.
echo [APPLICATION]
echo   [4] Start Inspection App
echo   [5] Build Inspection App
echo.
echo [REPORTS AND DOCS]
echo   [6] Open test report
echo   [7] Open user guide (Python)
echo   [8] Open user guide (offline, no Python)
echo.
echo [GUIDES]
echo   [9]  Getting started (web)
echo   [10] Windows quick start
echo   [11] No-Python guide
echo   [12] Troubleshooting guide
echo.
echo [TOOLS]
echo   [13] Environment diagnostic
echo   [14] Open TPS document
echo   [15] Open FlaUI Inspector
echo   [16] FlaUI.Cli record ^(export JSON → BDD stub^)
echo.
echo   [0] Exit
echo.
echo ========================================
echo.

set /p choice="Select option (0-16): "

REM ===== TEST =====
if "%choice%"=="1" goto RUN_ALL_TESTS
if "%choice%"=="2" goto RUN_SINGLE_TEST
if "%choice%"=="3" goto START_WEB_DASHBOARD

REM ===== APPLICATION =====
if "%choice%"=="4" goto START_APP
if "%choice%"=="5" goto BUILD_APP

REM ===== REPORTS AND DOCS =====
if "%choice%"=="6" goto OPEN_REPORT
if "%choice%"=="7" goto OPEN_MANUAL
if "%choice%"=="8" goto OPEN_MANUAL_NO_PYTHON

REM ===== GUIDES =====
if "%choice%"=="9" goto OPEN_BEGINNER_GUIDE
if "%choice%"=="10" goto OPEN_WINDOWS_GUIDE
if "%choice%"=="11" goto OPEN_NO_PYTHON_GUIDE
if "%choice%"=="12" goto OPEN_TROUBLESHOOT_GUIDE

REM ===== TOOLS =====
if "%choice%"=="13" goto RUN_DIAGNOSTIC
if "%choice%"=="14" goto OPEN_TPS
if "%choice%"=="15" goto OPEN_INSPECTOR
if "%choice%"=="16" goto OPEN_FLAUI_RECORD

REM ===== EXIT =====
if "%choice%"=="0" goto EXIT_MENU

echo.
echo [X] Invalid choice. Enter 0-16.
timeout /t 2 >nul
goto MAIN_MENU

REM ========================================
REM   Test functions
REM ========================================

:RUN_ALL_TESTS
cls
echo ========================================
echo   Run all tests
echo ========================================
echo.
echo [1/3] Building application under test...
call :BUILD_SEMI_INTERNAL
if errorlevel 1 (
    echo.
    echo [X] Build failed. Cannot run tests.
    pause
    goto MAIN_MENU
)

set "TEST_DIR=%PROJECT_ROOT%\Automation_testcase\Project_FlaUIBDD\Testcase_Inspection_App_FlaUI_BDD"
cd /d "%TEST_DIR%"

echo.
echo [2/3] Building test project...
dotnet build -c Release
if errorlevel 1 (
    echo.
    echo [X] Test project build failed.
    pause
    goto MAIN_MENU
)

echo.
echo [3/3] Running all test cases (TC01-TC10)...
dotnet test -c Release --logger "console;verbosity=normal"

echo.
echo ========================================
echo   Test run finished
echo ========================================
pause
goto MAIN_MENU

:RUN_SINGLE_TEST
cls
echo ========================================
echo   Run single test
echo ========================================
echo.
echo Available: TC01, TC02, TC03, TC04, TC05,
echo            TC06, TC07, TC08, TC09, TC10
echo.

set /p TC="Enter test id (e.g. TC01): "
set "TC=%TC: =%"

if "%TC%"=="" (
    echo [X] No test id specified.
    pause
    goto MAIN_MENU
)

REM Validate TC format
set "VALID=0"
for %%t in (01 02 03 04 05 06 07 08 09 10) do (
    if /i "%TC%"=="TC%%t" set "VALID=1"
)
if "%VALID%"=="0" (
    echo [X] Invalid test id. Use TC01 to TC10.
    pause
    goto MAIN_MENU
)

echo.
echo [1/3] Building application under test...
call :BUILD_SEMI_INTERNAL
if errorlevel 1 (
    echo.
    echo [X] Build failed.
    pause
    goto MAIN_MENU
)

set "TEST_DIR=%PROJECT_ROOT%\Automation_testcase\Project_FlaUIBDD\Testcase_Inspection_App_FlaUI_BDD"
cd /d "%TEST_DIR%"

echo.
echo [2/3] Building test project...
dotnet build -c Release
if errorlevel 1 (
    echo [X] Test project build failed.
    pause
    goto MAIN_MENU
)

echo.
echo [3/3] Running test: %TC%...
dotnet test -c Release --filter "Name~%TC%"

echo.
echo ========================================
echo   Test run finished
echo ========================================
pause
goto MAIN_MENU

:START_WEB_DASHBOARD
cls
echo ========================================
echo   Start web dashboard
echo ========================================
echo.

REM Check Python
where python >nul 2>&1
if errorlevel 1 (
    echo [X] Python not found.
    echo.
    echo This feature requires Python.
    echo.
    echo Alternatives:
    echo   - Option [1] Run all tests
    echo   - Option [2] Run single test
    echo.
    pause
    goto MAIN_MENU
)

set "PORT=6690"
set "URL=http://localhost:%PORT%/"
set "FLAUIBDD_DASHBOARD_PORT=%PORT%"
set "DASHBOARD=%PROJECT_ROOT%\Automation_testcase\Project_FlaUIBDD\web_dashboard"

echo Checking application under test...
if not exist "%PROJECT_ROOT%\SemiInspectionDesktop\bin\Debug\SemiInspectionDesktop.exe" (
    echo App not found. Building...
    call :BUILD_SEMI_INTERNAL
    if errorlevel 1 (
        pause
        goto MAIN_MENU
    )
)

echo.
echo Starting web dashboard...
echo URL: %URL%
echo.
echo Tip: Press Ctrl+C to stop the server.
echo.

start "" "%URL%"
python "%DASHBOARD%\server.py"

pause
goto MAIN_MENU

REM ========================================
REM   Application functions
REM ========================================

:START_APP
cls
echo ========================================
echo   Start Inspection App
echo ========================================
echo.

set "EXE=%PROJECT_ROOT%\SemiInspectionDesktop\bin\Debug\SemiInspectionDesktop.exe"

if not exist "%EXE%" (
    echo App not found. Building...
    call :BUILD_SEMI_INTERNAL
    if errorlevel 1 (
        pause
        goto MAIN_MENU
    )
)

echo Starting: %EXE%
echo.

start "" "%EXE%"

echo [OK] Application started.
timeout /t 2 >nul
goto MAIN_MENU

:BUILD_APP
cls
echo ========================================
echo   Build Inspection App
echo ========================================
echo.

call :BUILD_SEMI_INTERNAL

echo.
pause
goto MAIN_MENU

REM ========================================
REM   Reports and docs
REM ========================================

:OPEN_REPORT
cls
echo ========================================
echo   Open test report
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
    echo [X] Test report not found.
    echo.
    echo Run tests first:
    echo   - Option [1] Run all tests
    echo   - Option [2] Run single test
    echo.
    pause
    goto MAIN_MENU
)

echo Opening report: !REPORT!
echo.

REM Prefer Edge/Chrome if available
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

echo [OK] Test report opened.
timeout /t 2 >nul
goto MAIN_MENU

:OPEN_MANUAL
cls
echo ========================================
echo   Open user guide (requires Python)
echo ========================================
echo.

where python >nul 2>&1
if errorlevel 1 (
    echo [X] Python not found.
    echo.
    echo Alternatives:
    echo   - Option [8] Open user guide offline
    echo   - Open docs\index.html directly
    echo.
    pause
    goto MAIN_MENU
)

set "PORT=6688"
set "URL=http://localhost:%PORT%/docs/index.html"
set "MANUAL_SERVER_PORT=%PORT%"

echo Starting user guide server (port %PORT%)...
echo URL: %URL%
echo.
echo Tip: Press Ctrl+C to stop the server.
echo.

timeout /t 2 >nul
start "" "%URL%"
python "%PROJECT_ROOT%\docs\server.py"

pause
goto MAIN_MENU

:OPEN_MANUAL_NO_PYTHON
cls
echo ========================================
echo   Open user guide (offline)
echo ========================================
echo.

set "INDEX_FILE=%PROJECT_ROOT%\docs\index.html"

if not exist "%INDEX_FILE%" (
    echo [X] Not found: docs\index.html
    pause
    goto MAIN_MENU
)

echo Opening: %INDEX_FILE%
echo.
echo Tip: Offline version; some interactive features may be unavailable.
echo.

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

echo [OK] User guide opened.
timeout /t 2 >nul
goto MAIN_MENU

REM ========================================
REM   Guides
REM ========================================

:OPEN_BEGINNER_GUIDE
cls
echo ========================================
echo   Getting started (web)
echo ========================================
echo.

set "GS_HTML=%PROJECT_ROOT%\docs\00-getting-started.html"
set "GS_MD=%PROJECT_ROOT%\GETTING_STARTED.md"

if not exist "%GS_HTML%" (
    echo [X] Not found: docs\00-getting-started.html
    if exist "%GS_MD%" (
        echo Opening Markdown fallback...
        start "" "%GS_MD%"
    )
    pause
    goto MAIN_MENU
)

echo Opening: %GS_HTML%
echo Markdown: %GS_MD%
echo.

set "BROWSER="
if exist "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe" set "BROWSER=%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"
if not defined BROWSER if exist "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" set "BROWSER=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
if not defined BROWSER if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" set "BROWSER=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if not defined BROWSER if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" set "BROWSER=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"

if defined BROWSER (
    start "" "%BROWSER%" "%GS_HTML%"
) else (
    start "" "%GS_HTML%"
)

echo [OK] Getting started page opened.
timeout /t 2 >nul
goto MAIN_MENU

:OPEN_WINDOWS_GUIDE
start "" "%PROJECT_ROOT%\WINDOWS_QUICK_START.md"
echo [OK] Windows quick start guide opened.
timeout /t 2 >nul
goto MAIN_MENU

:OPEN_NO_PYTHON_GUIDE
start "" "%PROJECT_ROOT%\NO_PYTHON_GUIDE.md"
echo [OK] No-Python guide opened.
timeout /t 2 >nul
goto MAIN_MENU

:OPEN_TROUBLESHOOT_GUIDE
start "" "%PROJECT_ROOT%\WINDOWS_TROUBLESHOOTING.md"
echo [OK] Troubleshooting guide opened.
timeout /t 2 >nul
goto MAIN_MENU

REM ========================================
REM   Tools
REM ========================================

:RUN_DIAGNOSTIC
cls
echo ========================================
echo   Environment diagnostic
echo ========================================
echo.
echo Checking system environment...
echo.

echo [1/8] System info
echo ----------------------------------------
ver
echo User: %USERNAME%
echo Project path: %PROJECT_ROOT%
echo.

echo [2/8] Python
echo ----------------------------------------
where python >nul 2>&1
if errorlevel 1 (
    echo [X] Python not found
) else (
    echo [OK] Python path:
    where python
    python --version 2>&1
)
echo.

echo [3/8] .NET
echo ----------------------------------------
where dotnet >nul 2>&1
if errorlevel 1 (
    echo [X] .NET SDK not found
) else (
    echo [OK] .NET version:
    dotnet --version
)
echo.

echo [4/8] Project folders
echo ----------------------------------------
if exist "%PROJECT_ROOT%\docs" (
    echo [OK] docs\ exists
) else (
    echo [X] docs\ missing
)
if exist "%PROJECT_ROOT%\SemiInspectionDesktop" (
    echo [OK] SemiInspectionDesktop\ exists
) else (
    echo [X] SemiInspectionDesktop\ missing
)
if exist "%PROJECT_ROOT%\Automation_testcase" (
    echo [OK] Automation_testcase\ exists
) else (
    echo [X] Automation_testcase\ missing
)
echo.

echo [5/8] App under test
echo ----------------------------------------
if exist "%PROJECT_ROOT%\SemiInspectionDesktop\bin\Debug\SemiInspectionDesktop.exe" (
    echo [OK] App is built
) else (
    echo [!] App not built yet (use option [5])
)
echo.

echo [6/8] Test report
echo ----------------------------------------
set "TEST_DIR=%PROJECT_ROOT%\Automation_testcase\Project_FlaUIBDD\Testcase_Inspection_App_FlaUI_BDD"
if exist "%TEST_DIR%\reports\TestResultReport.html" (
    echo [OK] Test report exists
) else (
    echo [!] Test report not found (run tests first)
)
echo.

echo [7/8] Ports
echo ----------------------------------------
netstat -ano 2>nul | findstr ":6688 " | findstr "LISTENING" >nul 2>&1
if not errorlevel 1 (
    echo [!] Port 6688 in use (user guide)
) else (
    echo [OK] Port 6688 available
)
netstat -ano 2>nul | findstr ":6690 " | findstr "LISTENING" >nul 2>&1
if not errorlevel 1 (
    echo [!] Port 6690 in use (web dashboard)
) else (
    echo [OK] Port 6690 available
)
echo.

echo [8/8] Diagnostic complete
echo ========================================
echo.

echo Tips:
if not exist "%PROJECT_ROOT%\SemiInspectionDesktop\bin\Debug\SemiInspectionDesktop.exe" (
    echo   - Use option [5] to build the app
)
echo   - If Python is missing, see the No-Python guide
echo   - Details: WINDOWS_TROUBLESHOOTING.md
echo.

pause
goto MAIN_MENU

:OPEN_TPS
start "" "%PROJECT_ROOT%\Automation_testcase\Test_cases\TPS.md"
echo [OK] TPS document opened.
timeout /t 2 >nul
goto MAIN_MENU

:OPEN_INSPECTOR
cls
echo ========================================
echo   Open FlaUI Inspector
echo ========================================
echo.

set "INSPECTOR_BAT=%PROJECT_ROOT%\Automation_testcase\Project_FlaUIBDD\Testcase_Inspection_App_FlaUI_BDD\open_inspector.bat"

if exist "%INSPECTOR_BAT%" (
    echo Starting FlaUI Inspector...
    call "%INSPECTOR_BAT%"
) else (
    echo [X] Inspector launch script not found.
    echo.
    echo Path:
    echo %INSPECTOR_BAT%
    pause
)

goto MAIN_MENU

:OPEN_FLAUI_RECORD
cls
echo ========================================
echo   FlaUI.Cli Record → BDD stub
echo ========================================
echo.
echo  Records CLI elem steps (not mouse capture).
echo  Guide: docs\flaui-tutorial.html#flaui-record
echo.

set "RECORD_BAT=%PROJECT_ROOT%\open_flaui_record.bat"
if exist "%RECORD_BAT%" (
    call "%RECORD_BAT%"
) else (
    echo [X] open_flaui_record.bat not found.
    echo %RECORD_BAT%
    pause
)

goto MAIN_MENU

REM ========================================
REM   Internal helpers
REM ========================================

:BUILD_SEMI_INTERNAL
echo Building SemiInspectionDesktop...

set "MSBUILD="
if exist "%ProgramFiles%\MSBuild\14.0\Bin\MSBuild.exe" set "MSBUILD=%ProgramFiles%\MSBuild\14.0\Bin\MSBuild.exe"
if exist "%ProgramFiles(x86)%\MSBuild\14.0\Bin\MSBuild.exe" set "MSBUILD=%ProgramFiles(x86)%\MSBuild\14.0\Bin\MSBuild.exe"
if exist "%WINDIR%\Microsoft.NET\Framework\v3.5\MSBuild.exe" set "MSBUILD=%WINDIR%\Microsoft.NET\Framework\v3.5\MSBuild.exe"
if exist "%WINDIR%\Microsoft.NET\Framework64\v3.5\MSBuild.exe" set "MSBUILD=%WINDIR%\Microsoft.NET\Framework64\v3.5\MSBuild.exe"

if "%MSBUILD%"=="" (
    echo [X] MSBuild not found.
    echo.
    echo Install:
    echo   - Visual Studio
    echo   - Build Tools for Visual Studio
    echo.
    exit /b 1
)

"%MSBUILD%" "%PROJECT_ROOT%\SemiInspectionDesktop.sln" /p:Configuration=Debug /v:m
if errorlevel 1 (
    echo [X] Build failed.
    exit /b 1
)

REM Copy recipe data
if exist "%PROJECT_ROOT%\Recipe_data" (
    if not exist "%PROJECT_ROOT%\SemiInspectionDesktop\bin\Debug\Recipe_data" mkdir "%PROJECT_ROOT%\SemiInspectionDesktop\bin\Debug\Recipe_data"
    xcopy /Y "%PROJECT_ROOT%\Recipe_data\*.*" "%PROJECT_ROOT%\SemiInspectionDesktop\bin\Debug\Recipe_data\" >nul 2>&1
)

echo [OK] Build succeeded: SemiInspectionDesktop\bin\Debug\SemiInspectionDesktop.exe
exit /b 0

REM ========================================
REM   Exit
REM ========================================

:EXIT_MENU
cls
echo.
echo ========================================
echo   Thank you for using SQA Inspection App
echo ========================================
echo.
timeout /t 1 >nul
exit /b 0
