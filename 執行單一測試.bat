@echo off
chcp 65001 >nul 2>&1
setlocal EnableExtensions
cd /d "%~dp0"
call "%~dp0setup_env.bat"

set "TC=%~1"
if "%TC%"=="" (
    echo.
    echo 用法: 執行單一測試.bat TC01
    echo       執行單一測試.bat TC07
    echo.
    set /p TC="請輸入 TC 編號 (例如 TC01): "
)

for /f "tokens=*" %%a in ("%TC%") do set "TC=%%a"
set "TC=%TC: =%"

if "%TC%"=="" (
    echo [ERROR] 未指定 TC 編號
    pause
    exit /b 1
)

set "VALID=0"
for %%t in (01 02 03 04 05 06 07 08 09 10) do (
    if /i "%TC%"=="TC%%t" set "VALID=1"
)
if "%VALID%"=="0" (
    echo [ERROR] 格式錯誤，請使用 TC01 ~ TC10
    pause
    exit /b 1
)

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
echo [SQA Inspection App] 執行 %TC% ...
dotnet test -c Release --no-build --filter "Name~%TC%" --logger "console;verbosity=normal"
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if %EXIT_CODE% equ 0 (
    echo [%TC%] 測試通過
    echo 可執行 開啟測試報告.bat 查看 HTML 報告
) else (
    echo [%TC%] 測試失敗 ^(exit code %EXIT_CODE%^)
    echo 請執行 開啟測試報告.bat 查看失敗步驟，或參考 docs\04-修復測試.html
)
echo.
pause
exit /b %EXIT_CODE%
