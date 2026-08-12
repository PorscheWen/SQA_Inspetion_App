@echo off
setlocal EnableExtensions
set "SCRIPT_DIR=%~dp0"
set "TOOLS=%SCRIPT_DIR%Automation_testcase\Project_FlaUIBDD\Testcase_Inspection_App_FlaUI_BDD\tools"
set "WF=%TOOLS%\flaui_record_workflow.ps1"

echo ========================================
echo   FlaUI.Cli Record (Semi Inspection)
echo ========================================
echo.
echo  Records flaui CLI steps (find/click/type), NOT mouse capture.
echo  Docs: docs\flaui-tutorial.html#flaui-record
echo.
echo  Scenarios:
echo    [1] About   (default, like TC06)
echo    [2] RawData
echo    [3] Import Recipe
echo    [4] Custom  (you run flaui commands yourself)
echo    [0] Cancel
echo.

set /p choice="Select (0-4): "
if "%choice%"=="0" goto :eof
if "%choice%"=="1" set "SCENARIO=About"
if "%choice%"=="2" set "SCENARIO=RawData"
if "%choice%"=="3" set "SCENARIO=Import"
if "%choice%"=="4" set "SCENARIO=Custom"
if not defined SCENARIO set "SCENARIO=About"

if not exist "%WF%" (
  echo [X] Missing %WF%
  pause
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%WF%" -Scenario "%SCENARIO%" -ConvertAfterExport
echo.
pause
