@echo off
setlocal EnableExtensions
cd /d "%~dp0"
call "%~dp0setup_env.bat"

set "PORT=6690"
set "URL=http://localhost:%PORT%/"
set "FLAUIBDD_DASHBOARD_PORT=%PORT%"
set "DASHBOARD=%~dp0Automation_testcase\Project_FlaUIBDD\web_dashboard"

echo.
echo SQA Inspection App — FlaUI BDD 測試平台
echo   %URL%
echo.

if not exist "%~dp0SemiInspectionDesktop\bin\Debug\SemiInspectionDesktop.exe" (
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
