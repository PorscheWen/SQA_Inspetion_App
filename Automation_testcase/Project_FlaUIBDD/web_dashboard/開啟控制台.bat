@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"
call "%~dp0..\..\..\setup_env.bat"

set "PORT=6690"
set "URL=http://localhost:%PORT%/"
set "APP_ROOT=%~dp0..\..\.."
set "BUILD_BAT=%APP_ROOT%\build_semi.bat"
set "EXE_PATH=%APP_ROOT%\SemiInspectionDesktop\bin\Debug\SemiInspectionDesktop.exe"
set "FLAUIBDD_DASHBOARD_PORT=%PORT%"

echo.
echo SQA Inspection App — FlaUI BDD 測試控制台
echo   %URL%
echo.

if not exist "%EXE_PATH%" (
    echo 找不到 SemiInspectionDesktop.exe，正在執行 build_semi.bat...
    call "%BUILD_BAT%"
    if errorlevel 1 (
        pause
        exit /b 1
    )
) else (
    echo SemiInspectionDesktop 已就緒
)

start "" "%URL%"
python "%~dp0server.py"
exit /b %ERRORLEVEL%
