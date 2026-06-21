@echo off
chcp 65001 >nul 2>&1
setlocal EnableExtensions

set "URL=http://localhost:6688/Automation_testcase/Test_cases/TPS.md"
set "TPS=%~dp0TPS.md"

python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:6688/api/health', timeout=2)" >nul 2>&1
if not errorlevel 1 (
    start "" "%URL%"
    echo 已在瀏覽器開啟: %URL%
    exit /b 0
)

if not exist "%TPS%" (
    echo [ERROR] 找不到 TPS.md
    pause
    exit /b 1
)

start "" "%TPS%"
echo 已在瀏覽器開啟: %TPS%
echo 若出現亂碼，請先執行專案根目錄的 開啟操作手冊.bat 再雙擊本檔。
exit /b 0
