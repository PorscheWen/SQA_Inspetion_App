@echo off
setlocal
set "APP_ROOT=%~dp0"
if "%APP_ROOT:~-1%"=="\" set "APP_ROOT=%APP_ROOT:~0,-1%"

set "ApplicationPath=%APP_ROOT%\SemiInspectionDesktop\bin\Debug\SemiInspectionDesktop.exe"
set "RecipeDataDirectory=%APP_ROOT%\Recipe_data"
set "ProcessName=SemiInspectionDesktop"
set "ApplicationTitle=Semi Inspection Desktop"

endlocal & (
  set "APP_ROOT=%APP_ROOT%"
  set "ApplicationPath=%ApplicationPath%"
  set "RecipeDataDirectory=%RecipeDataDirectory%"
  set "ProcessName=%ProcessName%"
  set "ApplicationTitle=%ApplicationTitle%"
)
