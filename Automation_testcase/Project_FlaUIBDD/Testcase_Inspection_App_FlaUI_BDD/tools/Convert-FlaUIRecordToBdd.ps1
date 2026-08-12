# Convert FlaUI.Cli record export JSON into SpecFlow / Page Object stubs.
# Output is a starting point — always review selectors and wrap into existing Page Objects.
param(
    [Parameter(Mandatory = $true)]
    [string]$InputJson,
    [string]$OutDir = "",
    [string]$ScenarioName = "Recorded"
)

$ErrorActionPreference = "Stop"
if (-not (Test-Path $InputJson)) { throw "Missing JSON: $InputJson" }
if (-not $OutDir) { $OutDir = Split-Path -Parent $InputJson }
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$raw = Get-Content -LiteralPath $InputJson -Raw -Encoding UTF8
$data = $null
try { $data = $raw | ConvertFrom-Json } catch { throw "Invalid JSON: $InputJson" }

function Get-Steps($obj) {
    if ($null -eq $obj) { return @() }
    if ($obj.steps) { return @($obj.steps) }
    if ($obj.Steps) { return @($obj.Steps) }
    if ($obj -is [System.Collections.IEnumerable] -and -not ($obj -is [string])) { return @($obj) }
    return @()
}

$steps = Get-Steps $data
$safeName = ($ScenarioName -replace '[^\w\-]', '_')
$featurePath = Join-Path $OutDir "${safeName}_stub.feature"
$pagePath = Join-Path $OutDir "${safeName}_PageStub.cs"
$mapPath = Join-Path $OutDir "${safeName}_mapping.md"

$gherkin = New-Object System.Collections.Generic.List[string]
$gherkin.Add("Feature: Recorded stub — $ScenarioName")
$gherkin.Add("  # Generated from FlaUI.Cli recording. Merge into Inspection_App.feature manually.")
$gherkin.Add("")
$gherkin.Add("  @Recorded @Stub")
$gherkin.Add("  Scenario: $ScenarioName from flaui record")
$gherkin.Add("    Given the application is running")

$page = New-Object System.Collections.Generic.List[string]
$page.Add("// AUTO-GENERATED stub from FlaUI.Cli — do NOT use as-is in production tests.")
$page.Add("// Move stable locators into MainWindowPage / WorkspacePage / FileDialogPage.")
$page.Add("using FlaUI.Core.AutomationElements;")
$page.Add("using FlaUI.Core.Definitions;")
$page.Add("")
$page.Add("namespace Testcase_Inspection_App_FlaUI_BDD.PageObjects.Generated")
$page.Add("{")
$page.Add("    public class ${safeName}PageStub")
$page.Add("    {")
$page.Add("        // Inject AutomationElement window from TestHooks / BasePage in real code.")
$page.Add("        private readonly AutomationElement _window;")
$page.Add("        public ${safeName}PageStub(AutomationElement window) => _window = window;")
$page.Add("")

$map = New-Object System.Collections.Generic.List[string]
$map.Add("# FlaUI.Cli -> SpecFlow / Page Object mapping")
$map.Add("")
$map.Add("| # | CLI command | Selector | Quality | Suggested Gherkin | Suggested Page method |")
$map.Add("|---|-------------|----------|---------|-------------------|------------------------|")

$i = 0
$methodIdx = 0
foreach ($step in $steps) {
    $i++
    $cmd = ""
    if ($step.command) { $cmd = [string]$step.command }
    elseif ($step.cmd) { $cmd = [string]$step.cmd }
    elseif ($step.Command) { $cmd = [string]$step.Command }
    $cmd = $cmd.Trim().ToLowerInvariant()

    $args = $step.args
    if (-not $args) { $args = $step.Args }
    if (-not $args) { $args = $step.parameters }

    $aid = $null; $name = $null; $text = $null; $quality = ""
    if ($args) {
        if ($args.aid) { $aid = [string]$args.aid }
        if ($args.AutomationId) { $aid = [string]$args.AutomationId }
        if ($args.name) { $name = [string]$args.name }
        if ($args.text) { $text = [string]$args.text }
        if ($args.value) { $text = [string]$args.value }
    }
    if ($step.result) {
        if (-not $aid -and $step.result.automationId) { $aid = [string]$step.result.automationId }
        if (-not $name -and $step.result.name) { $name = [string]$step.result.name }
        if ($step.result.selectorQuality) { $quality = [string]$step.result.selectorQuality }
    }
    if ($step.selectorQuality) { $quality = [string]$step.selectorQuality }

    $selector = if ($aid) { "aid=$aid" } elseif ($name) { "name=$name" } else { "(see JSON)" }
    $gStep = ""
    $pageMethod = ""

    if ($cmd -match 'find') {
        $gStep = "# find only - no Gherkin action"
        $pageMethod = "(locator prep)"
    }
    elseif ($cmd -match 'click') {
        $methodIdx++
        $label = if ($name) { $name } elseif ($aid) { $aid } else { "Control$methodIdx" }
        $gStep = "When I click toolbar `"$label`""
        if ($name -and $name -notmatch 'toolbar|About|Import|RawData|Defect|Run') {
            $gStep = "When I click `"$label`""
        }
        $gherkin.Add("    $gStep")
        $methodName = "Click_${methodIdx}_" + (($label -replace '[^\w]', '_'))
        $pageMethod = "$methodName()"
        $findExpr = if ($aid) {
            "cf => cf.ByAutomationId(`"$aid`")"
        } elseif ($name) {
            "cf => cf.ByName(`"$name`")"
        } else {
            "cf => cf.ByAutomationId(`"TODO`")"
        }
        $page.Add("        public void $methodName()")
        $page.Add("        {")
        $page.Add("            var el = _window.FindFirstDescendant($findExpr);")
        $page.Add("            el?.Click();")
        $page.Add("        }")
        $page.Add("")
    }
    elseif ($cmd -match 'type|set-value') {
        $methodIdx++
        $gStep = "When I enter `"$text`" into the field"
        $gherkin.Add("    $gStep")
        $methodName = "Type_${methodIdx}"
        $pageMethod = "$methodName()"
        $findExpr = if ($aid) {
            "cf => cf.ByAutomationId(`"$aid`")"
        } elseif ($name) {
            "cf => cf.ByName(`"$name`")"
        } else {
            "cf => cf.ByAutomationId(`"TODO`")"
        }
        $esc = if ($null -eq $text) { "" } else { $text.Replace('"', '\"') }
        $page.Add("        public void $methodName()")
        $page.Add("        {")
        $page.Add("            var el = _window.FindFirstDescendant($findExpr);")
        $page.Add("            el?.AsTextBox()?.Enter(`"$esc`");")
        $page.Add("        }")
        $page.Add("")
    }
    elseif ($cmd -match 'keys') {
        $keys = if ($args.keys) { [string]$args.keys } else { "ctrl+?" }
        $gStep = "When I press keys `"$keys`""
        $gherkin.Add("    $gStep")
        $pageMethod = "Keyboard shortcut (prefer existing MainWindowPage)"
    }
    elseif ($cmd -match 'get-value|get-state') {
        $gStep = "Then the control should show expected value"
        $gherkin.Add("    $gStep")
        $pageMethod = "Assert via WorkspacePage / LogContains"
    }
    else {
        $gStep = "# $cmd"
        $pageMethod = "(manual)"
    }

    $map.Add("| $i | ``$cmd`` | ``$selector`` | $quality | $gStep | $pageMethod |")
}

$gherkin.Add("    Then the main window title should be `"Semi Inspection Desktop`"")
$page.Add("    }")
$page.Add("}")

$gherkin -join "`r`n" | Set-Content -LiteralPath $featurePath -Encoding UTF8
$page -join "`r`n" | Set-Content -LiteralPath $pagePath -Encoding UTF8
$map -join "`r`n" | Set-Content -LiteralPath $mapPath -Encoding UTF8

Write-Host "[OK] Converted stubs:"
Write-Host "  $featurePath"
Write-Host "  $pagePath"
Write-Host "  $mapPath"
Write-Host ""
Write-Host "Merge rules:"
Write-Host "  1) Prefer AutomationId rated Stable"
Write-Host "  2) Put UI ops into existing PageObjects (not StepDefinitions)"
Write-Host "  3) Reuse steps already in Inspection_App.feature when wording matches"
