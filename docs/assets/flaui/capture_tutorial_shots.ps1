# Capture Semi Inspection Desktop screenshots for FlaUI tutorial docs.
# Saves PNGs under docs/assets/flaui/
# Usage:
#   powershell -ExecutionPolicy Bypass -File docs/assets/flaui/capture_tutorial_shots.ps1

param(
    [string]$ProjectRoot = "",
    [int]$SettleMs = 1500
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes

if (-not $ProjectRoot) {
    $ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
}

$outDir = Join-Path $ProjectRoot "docs\assets\flaui"
$exe = Join-Path $ProjectRoot "SemiInspectionDesktop\bin\Debug\SemiInspectionDesktop.exe"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

if (-not (Test-Path $exe)) {
    Write-Host "[X] App not found: $exe  (run build_semi.bat first)"
    exit 1
}

Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class NativeWin {
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
  [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern void mouse_event(int dwFlags, int dx, int dy, int dwData, int dwExtraInfo);
  [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, IntPtr processId);
  [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint idAttach, uint idAttachTo, bool fAttach);
  [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
  [DllImport("user32.dll")] public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }

  public static void ForceForeground(IntPtr hWnd) {
    ShowWindow(hWnd, 9);
    uint foreThread = GetWindowThreadProcessId(GetForegroundWindow(), IntPtr.Zero);
    uint appThread = GetCurrentThreadId();
    if (foreThread != appThread) AttachThreadInput(foreThread, appThread, true);
    BringWindowToTop(hWnd);
    SetForegroundWindow(hWnd);
    if (foreThread != appThread) AttachThreadInput(foreThread, appThread, false);
  }

  public static void CtrlKey(byte vk) {
    const uint KEYUP = 0x0002;
    keybd_event(0x11, 0, 0, UIntPtr.Zero);
    System.Threading.Thread.Sleep(40);
    keybd_event(vk, 0, 0, UIntPtr.Zero);
    System.Threading.Thread.Sleep(40);
    keybd_event(vk, 0, KEYUP, UIntPtr.Zero);
    System.Threading.Thread.Sleep(40);
    keybd_event(0x11, 0, KEYUP, UIntPtr.Zero);
  }
}
"@

function Find-TopWindow([string]$NameLike) {
    $root = [System.Windows.Automation.AutomationElement]::RootElement
    $cond = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
        [System.Windows.Automation.ControlType]::Window)
    foreach ($w in $root.FindAll([System.Windows.Automation.TreeScope]::Children, $cond)) {
        $n = $w.Current.Name
        if ($n -and $n -like $NameLike) { return $w }
    }
    return $null
}

function Wait-TopWindow([string]$NameLike, [int]$TimeoutMs = 15000) {
    $deadline = [DateTime]::UtcNow.AddMilliseconds($TimeoutMs)
    while ([DateTime]::UtcNow -lt $deadline) {
        $w = Find-TopWindow $NameLike
        if ($w) { return $w }
        Start-Sleep -Milliseconds 200
    }
    return $null
}

function Find-DialogWindow([int]$TimeoutMs = 8000) {
    $deadline = [DateTime]::UtcNow.AddMilliseconds($TimeoutMs)
    $root = [System.Windows.Automation.AutomationElement]::RootElement
    $cond = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
        [System.Windows.Automation.ControlType]::Window)
    while ([DateTime]::UtcNow -lt $deadline) {
        foreach ($w in $root.FindAll([System.Windows.Automation.TreeScope]::Children, $cond)) {
            $n = [string]$w.Current.Name
            $cls = [string]$w.Current.ClassName
            if ($cls -eq "#32770") { return $w }
            if ($n -and $n -ne "Semi Inspection Desktop") {
                if ($n.StartsWith("Import", [StringComparison]::OrdinalIgnoreCase)) { return $w }
                if ($n.StartsWith("Open", [StringComparison]::OrdinalIgnoreCase)) { return $w }
            }
        }
        Start-Sleep -Milliseconds 200
    }
    return $null
}

function Capture-Hwnd([IntPtr]$hwnd, [string]$Path) {
    if ($hwnd -eq [IntPtr]::Zero) { throw "Invalid HWND" }
    if ([NativeWin]::IsIconic($hwnd)) { [void][NativeWin]::ShowWindow($hwnd, 9) }
    [void][NativeWin]::SetForegroundWindow($hwnd)
    Start-Sleep -Milliseconds 200
    $rect = New-Object NativeWin+RECT
    if (-not [NativeWin]::GetWindowRect($hwnd, [ref]$rect)) { throw "GetWindowRect failed" }
    $w = [Math]::Max(1, $rect.Right - $rect.Left)
    $h = [Math]::Max(1, $rect.Bottom - $rect.Top)
    $bmp = New-Object System.Drawing.Bitmap $w, $h
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    try {
        $g.CopyFromScreen($rect.Left, $rect.Top, 0, 0, (New-Object System.Drawing.Size($w, $h)))
        $bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $g.Dispose()
        $bmp.Dispose()
    }
    Write-Host "[OK] $Path (${w}x${h})"
}

function Click-NamedButton($window, [string]$name) {
    $nameCond = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::NameProperty, $name)
    $btnType = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
        [System.Windows.Automation.ControlType]::Button)
    $el = $window.FindFirst(
        [System.Windows.Automation.TreeScope]::Descendants,
        (New-Object System.Windows.Automation.AndCondition($nameCond, $btnType)))
    if (-not $el) {
        Write-Host "[!] Button not found: $name"
        return $false
    }

    # Prefer InvokePattern (avoids bad BoundingRectangle on multi-monitor / DPI)
    try {
        $inv = $el.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
        if ($inv) {
            Write-Host "  Invoke '$name'"
            $inv.Invoke()
            return $true
        }
    } catch {
        Write-Host "  Invoke failed: $($_.Exception.Message)"
    }

    try {
        $pt = $el.GetClickablePoint()
        $x = [int]$pt.X
        $y = [int]$pt.Y
        Write-Host "  ClickablePoint '$name' at $x,$y"
        if ($x -ge 0 -and $y -ge 0) {
            [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
            Start-Sleep -Milliseconds 120
            [NativeWin]::mouse_event(0x0002, 0, 0, 0, 0)
            Start-Sleep -Milliseconds 40
            [NativeWin]::mouse_event(0x0004, 0, 0, 0, 0)
            return $true
        }
    } catch {
        Write-Host "  GetClickablePoint failed: $($_.Exception.Message)"
    }

    # Fallback: center of BoundingRectangle if on-screen
    $r = $el.Current.BoundingRectangle
    $x = [int]($r.X + $r.Width / 2)
    $y = [int]($r.Y + $r.Height / 2)
    Write-Host "  Bounds center '$name' at $x,$y (W=$($r.Width) H=$($r.Height))"
    if ($x -lt 0 -or $y -lt 0 -or $r.Width -le 1) {
        Write-Host "[!] Off-screen / invalid click target"
        return $false
    }
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
    Start-Sleep -Milliseconds 120
    [NativeWin]::mouse_event(0x0002, 0, 0, 0, 0)
    Start-Sleep -Milliseconds 40
    [NativeWin]::mouse_event(0x0004, 0, 0, 0, 0)
    return $true
}

Write-Host "========================================"
Write-Host " Capture FlaUI tutorial screenshots"
Write-Host " Out: $outDir"
Write-Host "========================================"

Get-Process -Name "SemiInspectionDesktop" -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "Closing PID $($_.Id)..."
    Stop-Process -Id $_.Id -Force
}
Start-Sleep -Milliseconds 800

Write-Host "Starting app..."
$proc = Start-Process -FilePath $exe -PassThru
Start-Sleep -Milliseconds $SettleMs

$main = Wait-TopWindow "*Semi Inspection Desktop*" 20000
if (-not $main) { Write-Host "[X] Main window not found"; exit 1 }

$hwndMain = [IntPtr]$main.Current.NativeWindowHandle
[void][NativeWin]::ShowWindow($hwndMain, 9)
[void][NativeWin]::SetForegroundWindow($hwndMain)
Start-Sleep -Milliseconds 400

Capture-Hwnd $hwndMain (Join-Path $outDir "01_main_window_filetree.png")

Write-Host "Opening Import Recipe dialog (Ctrl+I)..."
[NativeWin]::ForceForeground($hwndMain)
Start-Sleep -Milliseconds 500
# Same approach as FlaUI tests: Import uses Ctrl+I shortcut
[NativeWin]::CtrlKey([byte][char]'I')
Start-Sleep -Milliseconds 1500

$dlg = Find-DialogWindow 5000
if (-not $dlg) {
    Write-Host "  Fallback: Invoke toolbar button..."
    [void](Click-NamedButton $main "Import Recipe")
    Start-Sleep -Milliseconds 1500
    $dlg = Find-DialogWindow 8000
}
$path2 = Join-Path $outDir "02_import_file_dialog.png"
if ($dlg) {
    Write-Host "Dialog: $($dlg.Current.Name) class=$($dlg.Current.ClassName)"
    Capture-Hwnd ([IntPtr]$dlg.Current.NativeWindowHandle) $path2
    $ws = New-Object -ComObject WScript.Shell
    [void]$ws.AppActivate($dlg.Current.Name)
    Start-Sleep -Milliseconds 200
    $ws.SendKeys("{ESC}")
    Start-Sleep -Milliseconds 600
}
else {
    Write-Host "[!] App Import dialog not opened by automation in this session."
    Write-Host "    Capturing a standalone OpenFileDialog (title=Import Recipe) for docs."
    $recipeDir = [System.IO.Path]::GetFullPath((Join-Path $ProjectRoot "Recipe_data"))
    $rs = [runspacefactory]::CreateRunspace()
    $rs.ApartmentState = "STA"
    $rs.Open()
    $ps = [powershell]::Create()
    $ps.Runspace = $rs
    [void]$ps.AddScript({
        param($dir)
        Add-Type -AssemblyName System.Windows.Forms
        $ofd = New-Object System.Windows.Forms.OpenFileDialog
        $ofd.Title = "Import Recipe"
        $ofd.Filter = "Recipe JSON (*.json)|*.json|All files (*.*)|*.*"
        $ofd.InitialDirectory = $dir
        $sample = Join-Path $dir "InspectionRecipe_Sample.json"
        if (Test-Path $sample) { $ofd.FileName = "InspectionRecipe_Sample.json" }
        [void]$ofd.ShowDialog()
    }).AddArgument($recipeDir)
    $handle = $ps.BeginInvoke()
    Start-Sleep -Milliseconds 1200
    $dlg2 = Find-DialogWindow 8000
    if ($dlg2) {
        Write-Host "Fallback dialog: $($dlg2.Current.Name)"
        Capture-Hwnd ([IntPtr]$dlg2.Current.NativeWindowHandle) $path2
        $ws = New-Object -ComObject WScript.Shell
        [void]$ws.AppActivate($dlg2.Current.Name)
        Start-Sleep -Milliseconds 200
        $ws.SendKeys("{ESC}")
        Start-Sleep -Milliseconds 400
    }
    else {
        Write-Host "[X] Fallback dialog also not found."
    }
    try { [void]$ps.EndInvoke($handle) } catch {}
    $ps.Dispose()
    $rs.Close()
    $rs.Dispose()
}

$main = Wait-TopWindow "*Semi Inspection Desktop*" 8000
if (-not $main) {
    Write-Host "[!] Main window missing after dialog — restarting app for RawData shot"
    Get-Process -Name "SemiInspectionDesktop" -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Milliseconds 500
    $proc = Start-Process -FilePath $exe -PassThru
    Start-Sleep -Milliseconds $SettleMs
    $main = Wait-TopWindow "*Semi Inspection Desktop*" 15000
}
if (-not $main) { Write-Host "[X] Main window lost"; exit 1 }
$hwndMain = [IntPtr]$main.Current.NativeWindowHandle
[NativeWin]::ForceForeground($hwndMain)
Start-Sleep -Milliseconds 300

Write-Host "Opening RawData..."
[void](Click-NamedButton $main "RawData")
Start-Sleep -Milliseconds 900

$main = Wait-TopWindow "*Semi Inspection Desktop*" 5000
if ($main) {
    Capture-Hwnd ([IntPtr]$main.Current.NativeWindowHandle) (Join-Path $outDir "03_rawdata_grid.png")
}

Write-Host ""
Write-Host "Done:"
Get-ChildItem $outDir -Filter "*.png" | ForEach-Object {
    Write-Host ("  {0,-32} {1,8} bytes  {2}" -f $_.Name, $_.Length, $_.LastWriteTime.ToString("HH:mm:ss"))
}
Write-Host ""
if ($proc -and -not $proc.HasExited) {
    Write-Host "App left running (PID $($proc.Id)). Close manually or use FlaUInspect [15]."
} else {
    Write-Host "App not running. Start again with main_menu [4] or [15]."
}
exit 0
