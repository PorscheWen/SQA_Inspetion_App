$ErrorActionPreference = 'Stop'
$dest = Join-Path $PSScriptRoot 'FlaUIInspector'
$zip = Join-Path $env:TEMP 'FlaUInspect.3.0.0.zip'
$url = 'https://github.com/FlaUI/FlaUInspect/releases/download/v3.0.0/FlaUInspect.3.0.0.zip'
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
Expand-Archive -Path $zip -DestinationPath $dest -Force
$main = Join-Path $dest 'FlaUInspect.exe'
$alias = Join-Path $dest 'FlaUIInspector.exe'
if (Test-Path $main) {
    Copy-Item -Path $main -Destination $alias -Force
}
Get-ChildItem $dest -Filter *.exe | Select-Object Name, Length | Format-Table -AutoSize | Out-String | Write-Output
