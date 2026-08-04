@echo off
setlocal EnableExtensions
set "PROJECT_ROOT=%~dp0"
if defined APP_ROOT set "PROJECT_ROOT=%APP_ROOT%"
if defined SQA_APP_ROOT set "PROJECT_ROOT=%SQA_APP_ROOT%"
if "%PROJECT_ROOT:~-1%"=="\" set "PROJECT_ROOT=%PROJECT_ROOT:~0,-1%"
cd /d "%PROJECT_ROOT%"
call "%PROJECT_ROOT%\setup_env.bat"

echo.
echo [SQA Inspection App] 建置被測程式...
call "%~dp0build_semi.bat"
if errorlevel 1 exit /b 1

set "TEST_DIR=%PROJECT_ROOT%\Automation_testcase\Project_FlaUIBDD\Testcase_Inspection_App_FlaUI_BDD"
cd /d "%TEST_DIR%"

echo.
echo [SQA Inspection App] 建置 FlaUI BDD 測試專案...
dotnet build -c Release
if errorlevel 1 exit /b 1

echo.
echo [SQA Inspection App] 執行全部測試案例 (10 TC)...
dotnet test -c Release --logger "console;verbosity=normal"
exit /b %ERRORLEVEL%
