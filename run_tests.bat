@echo off
setlocal EnableExtensions
cd /d "%~dp0"
call "%~dp0setup_env.bat"

echo.
echo [SQA Inspection App] 建置被測程式...
call "%~dp0build_semi.bat"
if errorlevel 1 exit /b 1

set "TEST_DIR=%~dp0Automation_testcase\Project_FlaUIBDD\Testcase_demo2_desktop_FlaUI_BDD"
cd /d "%TEST_DIR%"

echo.
echo [SQA Inspection App] 建置 FlaUI BDD 測試專案...
dotnet build -c Release
if errorlevel 1 exit /b 1

echo.
echo [SQA Inspection App] 執行全部測試案例 (10 TC)...
dotnet test -c Release --logger "console;verbosity=normal"
exit /b %ERRORLEVEL%
