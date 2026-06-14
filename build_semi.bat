@echo off
setlocal
cd /d "%~dp0"

echo [SemiInspection] Building solution (VS 2008 / .NET 3.5)...

set MSBUILD=
if exist "%ProgramFiles%\MSBuild\14.0\Bin\MSBuild.exe" set "MSBUILD=%ProgramFiles%\MSBuild\14.0\Bin\MSBuild.exe"
if exist "%ProgramFiles(x86)%\MSBuild\14.0\Bin\MSBuild.exe" set "MSBUILD=%ProgramFiles(x86)%\MSBuild\14.0\Bin\MSBuild.exe"
if exist "%WINDIR%\Microsoft.NET\Framework\v3.5\MSBuild.exe" set "MSBUILD=%WINDIR%\Microsoft.NET\Framework\v3.5\MSBuild.exe"
if exist "%WINDIR%\Microsoft.NET\Framework64\v3.5\MSBuild.exe" set "MSBUILD=%WINDIR%\Microsoft.NET\Framework64\v3.5\MSBuild.exe"

if "%MSBUILD%"=="" (
  echo ERROR: 找不到 MSBuild。
  exit /b 1
)

"%MSBUILD%" SemiInspectionDesktop.sln /p:Configuration=Debug /v:m
if errorlevel 1 exit /b 1

if exist "Recipe_data" (
  if not exist "SemiInspectionDesktop\bin\Debug\Recipe_data" mkdir "SemiInspectionDesktop\bin\Debug\Recipe_data"
  xcopy /Y "Recipe_data\*.*" "SemiInspectionDesktop\bin\Debug\Recipe_data\" >nul 2>&1
)

echo Build OK: SemiInspectionDesktop\bin\Debug\SemiInspectionDesktop.exe
exit /b 0
