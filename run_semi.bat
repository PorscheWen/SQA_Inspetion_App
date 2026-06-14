@echo off
setlocal
cd /d "%~dp0"

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
