@echo off
setlocal
set "PROJECT_ROOT=%~dp0"
if defined APP_ROOT set "PROJECT_ROOT=%APP_ROOT%"
if defined SQA_APP_ROOT set "PROJECT_ROOT=%SQA_APP_ROOT%"
if "%PROJECT_ROOT:~-1%"=="\" set "PROJECT_ROOT=%PROJECT_ROOT:~0,-1%"
cd /d "%PROJECT_ROOT%"

set EXE=SemiInspectionDesktop\bin\Debug\SemiInspectionDesktop.exe

if not exist "%EXE%" (
  echo [SemiInspection] 尚未建置，先執行 build_semi.bat ...
  call "%~dp0build_semi.bat"
  if errorlevel 1 (
    echo ERROR: 建置失敗，無法啟動 SemiInspectionDesktop。
    pause
    exit /b 1
  )
)

if exist "Recipe_data" (
  if not exist "SemiInspectionDesktop\bin\Debug\Recipe_data" mkdir "SemiInspectionDesktop\bin\Debug\Recipe_data"
  xcopy /Y "Recipe_data\*.*" "SemiInspectionDesktop\bin\Debug\Recipe_data\" >nul 2>&1
)

if not exist "%EXE%" (
  echo ERROR: 找不到 %EXE%
  pause
  exit /b 1
)

start "" "%CD%\%EXE%"
echo Started: %CD%\%EXE%
exit /b 0
