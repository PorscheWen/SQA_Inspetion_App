@echo off
setlocal EnableExtensions
set "PROJECT_ROOT=%~dp0"
if defined APP_ROOT set "PROJECT_ROOT=%APP_ROOT%"
if defined SQA_APP_ROOT set "PROJECT_ROOT=%SQA_APP_ROOT%"
if "%PROJECT_ROOT:~-1%"=="\" set "PROJECT_ROOT=%PROJECT_ROOT:~0,-1%"
cd /d "%PROJECT_ROOT%"
call "%PROJECT_ROOT%\setup_env.bat"

set "PORT=6690"
set "URL=http://localhost:%PORT%/"
set "FLAUIBDD_DASHBOARD_PORT=%PORT%"
set "DASHBOARD=%PROJECT_ROOT%\Automation_testcase\Project_FlaUIBDD\web_dashboard"

echo.
echo SQA Inspection App — FlaUI BDD 測試平台
echo   %URL%
echo.

if not exist "%PROJECT_ROOT%\SemiInspectionDesktop\bin\Debug\SemiInspectionDesktop.exe" (
    echo 找不到被測程式，正在建置...
    call "%~dp0build_semi.bat"
    if errorlevel 1 (
        pause
        exit /b 1
    )
)

start "" "%URL%"
python "%DASHBOARD%\server.py"
exit /b %ERRORLEVEL%
