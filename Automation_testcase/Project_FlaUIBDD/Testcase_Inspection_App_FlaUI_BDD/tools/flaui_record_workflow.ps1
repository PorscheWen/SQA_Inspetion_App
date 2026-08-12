# Guided FlaUI.Cli record workflow for Semi Inspection Desktop.
# Records CLI elem commands (not raw mouse), exports JSON, optional BDD stub conversion.
param(
    [ValidateSet("About", "Import", "RawData", "Custom")]
    [string]$Scenario = "About",
    [switch]$SkipInstallCheck,
    [switch]$ConvertAfterExport
)

$ErrorActionPreference = "Stop"
$ToolsDir = $PSScriptRoot
# tools -> Testcase_... -> Project_FlaUIBDD -> Automation_testcase -> repo root
$ProjectRoot = (Resolve-Path (Join-Path $ToolsDir "..\..\..\..")).Path
$AppExe = Join-Path $ProjectRoot "SemiInspectionDesktop\bin\Debug\SemiInspectionDesktop.exe"
$OutDir = Join-Path $ToolsDir "recordings"
$Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$SessionDir = Join-Path $OutDir "session_$Stamp"
New-Item -ItemType Directory -Force -Path $SessionDir | Out-Null

Write-Host "========================================"
Write-Host "  FlaUI.Cli Record Workflow"
Write-Host "========================================"
Write-Host " Project : $ProjectRoot"
Write-Host " Scenario: $Scenario"
Write-Host " Output  : $SessionDir"
Write-Host ""
Write-Host " NOTE: flaui records CLI elem commands (find/click/type),"
Write-Host "       not TestComplete-style mouse capture while you click the UI."
Write-Host ""

if (-not $SkipInstallCheck) {
    if (-not (Get-Command flaui -ErrorAction SilentlyContinue)) {
        Write-Host "[!] flaui not found. Run install-flaui-cli.ps1 first."
        $install = Join-Path $ToolsDir "install-flaui-cli.ps1"
        if (Test-Path $install) {
            & $install
        }
        if (-not (Get-Command flaui -ErrorAction SilentlyContinue)) {
            throw "flaui CLI still unavailable."
        }
    }
}

if (-not (Test-Path $AppExe)) {
    Write-Host "[!] App not found: $AppExe"
    Write-Host "    Build via main_menu [5] then retry."
    throw "SemiInspectionDesktop.exe missing"
}

Push-Location $SessionDir
try {
    Write-Host "[1/6] session new ..."
    flaui session new --app $AppExe --wait-title "Semi Inspection" --wait-timeout 45000
    if ($LASTEXITCODE -ne 0) { throw "session new failed" }

    Write-Host "[2/6] record start ..."
    flaui record start
    if ($LASTEXITCODE -ne 0) { throw "record start failed" }

    switch ($Scenario) {
        "About" {
            Write-Host "[3/6] Scenario About: find/click About toolbar ..."
            flaui elem find --aid "btnToolbar0About" | Tee-Object -FilePath "last_find.json" | Out-Host
            $raw = Get-Content "last_find.json" -Raw -ErrorAction SilentlyContinue
            $id = $null
            if ($raw -match '"elementId"\s*:\s*"([^"]+)"') { $id = $Matches[1] }
            elseif ($raw -match '"id"\s*:\s*"([^"]+)"') { $id = $Matches[1] }
            if (-not $id) {
                flaui elem find --name "About" | Tee-Object -FilePath "last_find.json" | Out-Host
                $raw = Get-Content "last_find.json" -Raw -ErrorAction SilentlyContinue
                if ($raw -match '"elementId"\s*:\s*"([^"]+)"') { $id = $Matches[1] }
                elseif ($raw -match '"id"\s*:\s*"([^"]+)"') { $id = $Matches[1] }
            }
            if ($id) {
                flaui elem click --id $id
            } else {
                Write-Host "    Could not parse element id; try manual: flaui elem click --id <id>"
            }
            Start-Sleep -Seconds 1
            flaui screenshot --output "step_about.png"
        }
        "RawData" {
            Write-Host "[3/6] Scenario RawData: find/click RawData ..."
            flaui elem find --aid "btnParameters" | Tee-Object -FilePath "last_find.json" | Out-Host
            $raw = Get-Content "last_find.json" -Raw
            $id = $null
            if ($raw -match '"elementId"\s*:\s*"([^"]+)"') { $id = $Matches[1] }
            elseif ($raw -match '"id"\s*:\s*"([^"]+)"') { $id = $Matches[1] }
            if ($id) { flaui elem click --id $id }
            Start-Sleep -Seconds 1
            flaui screenshot --output "step_rawdata.png"
        }
        "Import" {
            Write-Host "[3/6] Scenario Import: find/click Import Recipe ..."
            flaui elem find --aid "btnImportRecipe" | Tee-Object -FilePath "last_find.json" | Out-Host
            $raw = Get-Content "last_find.json" -Raw
            $id = $null
            if ($raw -match '"elementId"\s*:\s*"([^"]+)"') { $id = $Matches[1] }
            elseif ($raw -match '"id"\s*:\s*"([^"]+)"') { $id = $Matches[1] }
            if ($id) { flaui elem click --id $id }
            Start-Sleep -Seconds 1
            flaui screenshot --output "step_import.png"
            Write-Host "    File dialog may be open — close it manually or continue with Custom steps."
        }
        "Custom" {
            Write-Host "[3/6] Custom mode — run flaui elem commands in another terminal,"
            Write-Host "      working directory: $SessionDir"
            Write-Host "      Examples:"
            Write-Host "        flaui elem tree --depth 2"
            Write-Host "        flaui elem find --aid btnImportRecipe"
            Write-Host "        flaui elem click --id <id>"
            Write-Host ""
            Read-Host "Press Enter when finished interacting"
        }
    }

    Write-Host "[4/6] record stop + list ..."
    flaui record stop
    flaui record list | Tee-Object -FilePath "record_list.json" | Out-Host

    $exportPath = Join-Path $SessionDir "recording.json"
    Write-Host "[5/6] record export -> $exportPath"
    flaui record export --out $exportPath
    flaui audit --recording 2>$null | Tee-Object -FilePath "audit.json" | Out-Host

    Write-Host "[6/6] session end (keep app open) ..."
    flaui session end

    Write-Host ""
    Write-Host "[OK] Recording saved:"
    Write-Host "  $exportPath"
    Write-Host ""

    if ($ConvertAfterExport -or $Scenario -ne "Custom") {
        $convert = Join-Path $ToolsDir "Convert-FlaUIRecordToBdd.ps1"
        if (Test-Path $convert) {
            & $convert -InputJson $exportPath -OutDir $SessionDir -ScenarioName $Scenario
        }
    }

    Write-Host "Next:"
    Write-Host "  - Review recording.json + generated stubs"
    Write-Host "  - Copy stable AutomationId into PageObjects"
    Write-Host "  - Align Gherkin with Inspection_App.feature"
    Write-Host "  - Docs: docs/flaui-tutorial.html#flaui-record"
}
finally {
    Pop-Location
}
