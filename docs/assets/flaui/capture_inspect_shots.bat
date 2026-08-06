@echo off
setlocal EnableExtensions
cd /d "%~dp0..\..\.."
echo.
echo Capture App + FlaUInspect screenshots for FlaUI tutorial
echo Output: docs\assets\flaui\*.png
echo.
powershell -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0capture_inspect_shots.ps1" -ProjectRoot "%CD%"
set ERR=%ERRORLEVEL%
echo.
if not "%ERR%"=="0" (
  echo [X] Capture failed. Code=%ERR%
  pause
  exit /b %ERR%
)
echo [OK] Opening output folder...
start "" "%CD%\docs\assets\flaui"
exit /b 0
