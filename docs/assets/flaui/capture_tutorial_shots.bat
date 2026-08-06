@echo off
setlocal EnableExtensions
cd /d "%~dp0..\..\.."
echo.
echo Capture FlaUI tutorial screenshots (Inspection App)
echo Output: docs\assets\flaui\*.png
echo.
powershell -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0capture_tutorial_shots.ps1" -ProjectRoot "%CD%"
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
