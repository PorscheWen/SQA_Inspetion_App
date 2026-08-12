# Install FlaUI.Tool (global .NET tool) for CLI recording / element ops.
# Requires .NET SDK 10+ (FlaUI.Tool targets net10.0). Windows only.
$ErrorActionPreference = 'Stop'

Write-Host "========================================"
Write-Host "  Install FlaUI.Tool (flaui CLI)"
Write-Host "========================================"
Write-Host ""

function Get-DotNetMajorVersions {
    $sdks = & dotnet --list-sdks 2>$null
    if (-not $sdks) { return @() }
    $majors = @()
    foreach ($line in $sdks) {
        if ($line -match '^(\d+)\.') {
            $majors += [int]$Matches[1]
        }
    }
    return ($majors | Select-Object -Unique)
}

$majors = Get-DotNetMajorVersions
if (-not ($majors | Where-Object { $_ -ge 10 })) {
    Write-Host "[!] FlaUI.Tool requires .NET SDK 10 or later."
    Write-Host "    Installed SDK majors: $($majors -join ', ')"
    Write-Host ""
    Write-Host "Install SDK 10, then re-run this script:"
    Write-Host "  winget install Microsoft.DotNet.SDK.10"
    Write-Host "  https://dotnet.microsoft.com/download/dotnet/10.0"
    Write-Host ""
    $ans = Read-Host "Try winget install now? (Y/N)"
    if ($ans -match '^[Yy]') {
        winget install --id Microsoft.DotNet.SDK.10 -e --accept-package-agreements --accept-source-agreements
        Write-Host ""
        Write-Host "Close this window, open a NEW terminal, then run install-flaui-cli.ps1 again."
        exit 2
    }
    exit 1
}

Write-Host "Installing / updating global tool FlaUI.Tool ..."
$existing = & dotnet tool list -g 2>$null | Select-String -Pattern 'flaui.tool' -SimpleMatch
if ($existing) {
    & dotnet tool update --global FlaUI.Tool
} else {
    & dotnet tool install --global FlaUI.Tool
}

Write-Host ""
Write-Host "Verify:"
& flaui --help 2>&1 | Select-Object -First 8
if ($LASTEXITCODE -ne 0 -and -not (Get-Command flaui -ErrorAction SilentlyContinue)) {
    Write-Host ""
    Write-Host "[X] flaui not on PATH. Restart the terminal after installing .NET tools."
    Write-Host "    Typical path: $env:USERPROFILE\.dotnet\tools"
    exit 1
}

Write-Host ""
Write-Host "[OK] FlaUI.Tool ready. Next:"
Write-Host "  1) open_flaui_record.bat  (guided record for Semi Inspection Desktop)"
Write-Host "  2) Or see docs/flaui-tutorial.html#flaui-record"
Write-Host ""
