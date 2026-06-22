@echo off
chcp 65001 >nul 2>&1
setlocal EnableExtensions
cd /d "%~dp0"

set "TEST_DIR=%~dp0Automation_testcase\Project_FlaUIBDD\Testcase_Inspection_App_FlaUI_BDD"
set "REPORT_BIN=%TEST_DIR%\bin\Release\net8.0-windows\reports\TestResultReport.html"
set "REPORT_SYNC=%TEST_DIR%\reports\TestResultReport.html"

echo ========================================
echo   SQA Inspection App - 開啟測試報告
echo ========================================
echo.

if exist "%REPORT_BIN%" (
    set "REPORT=%REPORT_BIN%"
) else if exist "%REPORT_SYNC%" (
    set "REPORT=%REPORT_SYNC%"
) else (
    echo [WARN] 找不到 TestResultReport.html
    echo   請先執行 run_tests.bat 或 執行單一測試.bat
    echo.
    echo 預期位置:
    echo   %REPORT_BIN%
    echo   %REPORT_SYNC%
    pause
    exit /b 1
)

start "" "%REPORT%"
echo 已開啟: %REPORT%
echo.
echo 其他報告:
echo   SemiInspectionTestReport.html  ^(ExtentReports^)
echo   reports\junit-results.xml      ^(JUnit^)
echo.
pause
