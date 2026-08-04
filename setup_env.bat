@echo off
setlocal
set "PROJECT_ROOT=%~dp0"
if defined APP_ROOT set "PROJECT_ROOT=%APP_ROOT%"
if defined SQA_APP_ROOT set "PROJECT_ROOT=%SQA_APP_ROOT%"
if "%PROJECT_ROOT:~-1%"=="\" set "PROJECT_ROOT=%PROJECT_ROOT:~0,-1%"

set "APP_ROOT=%PROJECT_ROOT%"
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
