@echo off
chcp 65001 >nul 2>&1
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

set "APP_ROOT=%~dp0..\..\..\"
set "APP_EXE=%APP_ROOT%SemiInspectionDesktop\bin\Debug\SemiInspectionDesktop.exe"
set "INSPECTOR_EXE="

echo.
echo FlaUI Inspector + Semi Inspection Desktop
echo.

if defined FLAUI_INSPECTOR_PATH if exist "!FLAUI_INSPECTOR_PATH!" (
    set "INSPECTOR_EXE=!FLAUI_INSPECTOR_PATH!"
    goto :launch
)

for %%P in (
    "%~dp0tools\FlaUIInspector\FlaUIInspector.exe"
    "%~dp0FlaUIInspector\FlaUIInspector.exe"
    "%USERPROFILE%\FlaUIInspector\FlaUIInspector.exe"
    "%USERPROFILE%\Downloads\FlaUIInspector\FlaUIInspector.exe"
    "%LOCALAPPDATA%\FlaUIInspector\FlaUIInspector.exe"
    "%LOCALAPPDATA%\Programs\FlaUIInspector\FlaUIInspector.exe"
    "C:\Tools\FlaUIInspector\FlaUIInspector.exe"
) do (
    if exist %%~P (
        set "INSPECTOR_EXE=%%~P"
        goto :launch
    )
)

echo [ERROR] FlaUIInspector.exe not found.
pause
exit /b 1

:launch
echo Using: %INSPECTOR_EXE%
echo.

tasklist /FI "IMAGENAME eq SemiInspectionDesktop.exe" 2>nul | find /I "SemiInspectionDesktop.exe" >nul
if errorlevel 1 (
    if exist "%APP_EXE%" (
        echo Starting SemiInspectionDesktop...
        start "" "%APP_EXE%"
        timeout /t 2 /nobreak >nul
    ) else (
        echo Warning: SemiInspectionDesktop.exe not found.
        echo Run build_semi.bat first.
    )
) else (
    echo SemiInspectionDesktop is already running.
)

echo Starting FlaUI Inspector...
start "" "%INSPECTOR_EXE%"
echo.
echo In Inspector, select process SemiInspectionDesktop.
echo Check controls: treeFiles, dataGridParameters, btnImportRecipe
echo.
exit /b 0
