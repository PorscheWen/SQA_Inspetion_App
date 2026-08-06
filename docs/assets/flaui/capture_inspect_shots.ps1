# Re-capture App + FlaUInspect screenshots using PrintWindow (not what is under other windows).
param([string]$ProjectRoot = "")

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes

if (-not $ProjectRoot) {
    $ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
}
$outDir = Join-Path $ProjectRoot "docs\assets\flaui"
$appExe = Join-Path $ProjectRoot "SemiInspectionDesktop\bin\Debug\SemiInspectionDesktop.exe"
$inspExe = Join-Path $ProjectRoot "Automation_testcase\Project_FlaUIBDD\Testcase_Inspection_App_FlaUI_BDD\tools\FlaUIInspector\FlaUInspect.exe"
if (-not (Test-Path $inspExe)) {
    $inspExe = Join-Path $ProjectRoot "Automation_testcase\Project_FlaUIBDD\Testcase_Inspection_App_FlaUI_BDD\tools\FlaUIInspector\FlaUIInspector.exe"
}
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
if (-not (Test-Path $appExe)) { throw "Missing app: $appExe" }
if (-not (Test-Path $inspExe)) { throw "Missing FlaUInspect" }

Add-Type @"
using System;
using System.Text;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public static class CapApi {
  public const int PW_RENDERFULLCONTENT = 2;
  public delegate bool EnumProc(IntPtr hWnd, IntPtr lParam);
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc cb, IntPtr l);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint pid);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetWindowText(IntPtr hWnd, StringBuilder s, int n);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassName(IntPtr hWnd, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT r);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
  [DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
  [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr hwnd, IntPtr hdcBlt, int nFlags);
  [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
  public static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);
  public static readonly IntPtr HWND_NOTOPMOST = new IntPtr(-2);
  public const uint SWP_NOMOVE = 0x0002;
  public const uint SWP_NOSIZE = 0x0001;
  public const uint SWP_SHOWWINDOW = 0x0040;
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }

  public static List<IntPtr> WindowsForPid(uint targetPid) {
    var list = new List<IntPtr>();
    EnumWindows((h, l) => {
      uint p; GetWindowThreadProcessId(h, out p);
      if (p == targetPid && IsWindowVisible(h)) list.Add(h);
      return true;
    }, IntPtr.Zero);
    return list;
  }

  public static string Title(IntPtr h) {
    var sb = new StringBuilder(512);
    GetWindowText(h, sb, 512);
    return sb.ToString();
  }

  public static string ClassName(IntPtr h) {
    var sb = new StringBuilder(256);
    GetClassName(h, sb, 256);
    return sb.ToString();
  }
}
"@

function Get-LargestWindowForPid([int]$processId, [string]$titleHint = "") {
    $best = [IntPtr]::Zero
    $bestArea = -1
    $bad = @("Chrome", "Edge", "Firefox", "Cursor", "Getting Started", "PS2", "ROM")
    foreach ($h in [CapApi]::WindowsForPid([uint32]$processId)) {
        $r = New-Object CapApi+RECT
        [void][CapApi]::GetWindowRect($h, [ref]$r)
        $w = $r.Right - $r.Left
        $ht = $r.Bottom - $r.Top
        if ($w -lt 200 -or $ht -lt 150) { continue }
        $area = $w * $ht
        $title = [CapApi]::Title($h)
        $cls = [CapApi]::ClassName($h)
        Write-Host ("  pid={0} hwnd={1} {2}x{3} class={4} title='{5}'" -f $processId, $h.ToInt64(), $w, $ht, $cls, $title)
        $score = [double]$area
        if ($titleHint -and $title -like "*$titleHint*") { $score += 50000000 }
        foreach ($b in $bad) {
            if ($title -like "*$b*") { $score -= 20000000 }
        }
        if ($cls -like "WindowsForms*") { $score += 1000000 }
        if ($cls -like "HwndWrapper*") { $score += 500000 }
        if ($cls -like "Chrome*") { $score -= 10000000 }
        if ($score -gt $bestArea) {
            $bestArea = $score
            $best = $h
        }
    }
    return $best
}

function Get-InspectWindowForTarget([int]$inspPid, [string]$targetTitle) {
    $exact = [IntPtr]::Zero
    $fallback = [IntPtr]::Zero
    $fallbackArea = 0
    foreach ($h in [CapApi]::WindowsForPid([uint32]$inspPid)) {
        $title = [CapApi]::Title($h)
        $r = New-Object CapApi+RECT
        [void][CapApi]::GetWindowRect($h, [ref]$r)
        $w = $r.Right - $r.Left
        $ht = $r.Bottom - $r.Top
        if ($w -lt 200 -or $ht -lt 150) { continue }
        Write-Host ("  inspect-win {0}x{1} title='{2}'" -f $w, $ht, $title)
        if ($title -like "*$targetTitle*") {
            return $h
        }
        # Fresh picker / untitled WPF main — keep as fallback only if no Process: chrome etc.
        $area = $w * $ht
        if ($title -notlike "*Chrome*" -and $title -notlike "*Edge*" -and $title -notlike "*Process: *" -and $area -gt $fallbackArea) {
            $fallbackArea = $area
            $fallback = $h
        }
        if ($title -like "Process: *" -and $title -like "*$targetTitle*") {
            $exact = $h
        }
    }
    if ($exact -ne [IntPtr]::Zero) { return $exact }
    return $fallback
}

function Capture-PrintWindow([IntPtr]$hwnd, [string]$path) {
    if ($hwnd -eq [IntPtr]::Zero) { throw "Invalid hwnd for $path" }
    if ([CapApi]::IsIconic($hwnd)) { [void][CapApi]::ShowWindow($hwnd, 9) }
    $flags = [CapApi]::SWP_NOMOVE -bor [CapApi]::SWP_NOSIZE -bor [CapApi]::SWP_SHOWWINDOW
    [void][CapApi]::SetWindowPos($hwnd, [CapApi]::HWND_TOPMOST, 0, 0, 0, 0, $flags)
    [void][CapApi]::SetForegroundWindow($hwnd)
    Start-Sleep -Milliseconds 300

    $r = New-Object CapApi+RECT
    [void][CapApi]::GetWindowRect($hwnd, [ref]$r)
    $w = [Math]::Max(1, $r.Right - $r.Left)
    $h = [Math]::Max(1, $r.Bottom - $r.Top)

    $bmp = New-Object System.Drawing.Bitmap $w, $h
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $hdc = $g.GetHdc()
    $ok = [CapApi]::PrintWindow($hwnd, $hdc, [CapApi]::PW_RENDERFULLCONTENT)
    $g.ReleaseHdc($hdc)

    if (-not $ok) {
        Write-Host "  PrintWindow failed, CopyFromScreen fallback for $path"
        $g.CopyFromScreen($r.Left, $r.Top, 0, 0, (New-Object System.Drawing.Size($w, $h)))
    }

    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()

    [void][CapApi]::SetWindowPos($hwnd, [CapApi]::HWND_NOTOPMOST, 0, 0, 0, 0, $flags)
    Write-Host "[OK] $path (${w}x${h}) title='$([CapApi]::Title($hwnd))'"
}

function Capture-ToBitmap([IntPtr]$hwnd) {
    $flags = [CapApi]::SWP_NOMOVE -bor [CapApi]::SWP_NOSIZE -bor [CapApi]::SWP_SHOWWINDOW
    if ([CapApi]::IsIconic($hwnd)) { [void][CapApi]::ShowWindow($hwnd, 9) }
    [void][CapApi]::SetWindowPos($hwnd, [CapApi]::HWND_TOPMOST, 0, 0, 0, 0, $flags)
    [void][CapApi]::SetForegroundWindow($hwnd)
    Start-Sleep -Milliseconds 300
    $r = New-Object CapApi+RECT
    [void][CapApi]::GetWindowRect($hwnd, [ref]$r)
    $w = [Math]::Max(1, $r.Right - $r.Left)
    $h = [Math]::Max(1, $r.Bottom - $r.Top)
    $bmp = New-Object System.Drawing.Bitmap $w, $h
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $hdc = $g.GetHdc()
    $ok = [CapApi]::PrintWindow($hwnd, $hdc, [CapApi]::PW_RENDERFULLCONTENT)
    $g.ReleaseHdc($hdc)
    if (-not $ok) {
        $g.CopyFromScreen($r.Left, $r.Top, 0, 0, (New-Object System.Drawing.Size($w, $h)))
    }
    $g.Dispose()
    [void][CapApi]::SetWindowPos($hwnd, [CapApi]::HWND_NOTOPMOST, 0, 0, 0, 0, $flags)
    return $bmp
}

function Save-SideBySide($left, $right, $path, $lLabel, $rLabel) {
    $gap = 16; $labelH = 40
    $tw = $left.Width + $gap + $right.Width
    $th = $labelH + [Math]::Max($left.Height, $right.Height)
    $out = New-Object System.Drawing.Bitmap $tw, $th
    $g = [System.Drawing.Graphics]::FromImage($out)
    $g.Clear([System.Drawing.Color]::FromArgb(13, 17, 23))
    $font = New-Object System.Drawing.Font "Segoe UI", 12, ([System.Drawing.FontStyle]::Bold)
    $brush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 140, 0))
    $g.DrawString($lLabel, $font, $brush, 8, 10)
    $g.DrawString($rLabel, $font, $brush, ($left.Width + $gap + 8), 10)
    $g.DrawImage($left, 0, $labelH)
    $g.DrawImage($right, ($left.Width + $gap), $labelH)
    $out.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $brush.Dispose(); $font.Dispose(); $g.Dispose(); $out.Dispose()
    Write-Host "[OK] $path"
}

function Save-Uia3Card($path) {
    $bmp = New-Object System.Drawing.Bitmap 920, 320
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.Clear([System.Drawing.Color]::FromArgb(13, 17, 23))
    $title = New-Object System.Drawing.Font "Segoe UI", 16, ([System.Drawing.FontStyle]::Bold)
    $body = New-Object System.Drawing.Font "Segoe UI", 12
    $mono = New-Object System.Drawing.Font "Consolas", 14, ([System.Drawing.FontStyle]::Bold)
    $orange = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 140, 0))
    $gray = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(180, 180, 180))
    $green = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(144, 238, 144))
    $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(85, 85, 85), 2)
    $gpen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(144, 238, 144), 3)
    $g.DrawString("Step 2 - Choose UIA3 (FlaUInspect)", $title, $orange, 24, 24)
    $g.DrawString("Match project FlaUI.UIA3. Do not use UIA2 for daily practice.", $body, $gray, 24, 64)
    $r2 = New-Object System.Drawing.Rectangle 80, 120, 280, 90
    $r3 = New-Object System.Drawing.Rectangle 420, 120, 320, 90
    $g.FillRectangle((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(37, 37, 37))), $r2)
    $g.DrawRectangle($pen, $r2)
    $g.DrawString("UIA2", $mono, $gray, 180, 155)
    $g.FillRectangle((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(31, 42, 31))), $r3)
    $g.DrawRectangle($gpen, $r3)
    $g.DrawString("UIA3  selected", $mono, $green, 490, 155)
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    foreach ($x in @($title, $body, $mono, $orange, $gray, $green, $pen, $gpen, $g, $bmp)) { $x.Dispose() }
    Write-Host "[OK] $path"
}

function Invoke-ButtonByName($window, [string]$name) {
    $n = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty, $name)
    $t = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ControlTypeProperty, [System.Windows.Automation.ControlType]::Button)
    $el = $window.FindFirst([System.Windows.Automation.TreeScope]::Descendants, (New-Object System.Windows.Automation.AndCondition($n, $t)))
    if (-not $el) { return $false }
    try {
        $p = $el.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
        if ($p) { $p.Invoke(); return $true }
    } catch {}
    return $false
}

function Get-UiaWindowForPid([int]$processId) {
    $root = [System.Windows.Automation.AutomationElement]::RootElement
    $c = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ControlTypeProperty, [System.Windows.Automation.ControlType]::Window)
    foreach ($w in $root.FindAll([System.Windows.Automation.TreeScope]::Children, $c)) {
        if ($w.Current.ProcessId -eq $processId) { return $w }
    }
    return $null
}

Write-Host "========================================"
Write-Host " RE-CAPTURE (PrintWindow, by process)"
Write-Host "========================================"

# Close targets; leave browsers alone but we use PrintWindow so overlap is OK
foreach ($n in @("SemiInspectionDesktop", "FlaUInspect", "FlaUIInspector")) {
    Get-Process -Name $n -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}
Start-Sleep -Milliseconds 800

Write-Host "Start App..."
$appProc = Start-Process $appExe -PassThru
Start-Sleep -Milliseconds 2000
$appHwnd = Get-LargestWindowForPid $appProc.Id "Semi Inspection"
if ($appHwnd -eq [IntPtr]::Zero) {
    Start-Sleep -Milliseconds 2000
    $appHwnd = Get-LargestWindowForPid $appProc.Id "Semi"
}
if ($appHwnd -eq [IntPtr]::Zero) { throw "SemiInspectionDesktop window not found for PID $($appProc.Id)" }

[void][CapApi]::ShowWindow($appHwnd, 9)
[void][CapApi]::MoveWindow($appHwnd, 40, 40, 1200, 800, $true)
Start-Sleep -Milliseconds 500
Capture-PrintWindow $appHwnd (Join-Path $outDir "01_main_window_filetree.png")

Write-Host "Start FlaUInspect..."
$inspProc = Start-Process $inspExe -PassThru
Start-Sleep -Milliseconds 4500

# Try select UIA3
$inspUia = Get-UiaWindowForPid $inspProc.Id
if ($inspUia) {
    $nm = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty, "UIA3")
    $btn = $inspUia.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $nm)
    if ($btn) {
        try {
            $ip = $btn.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
            if ($ip) { $ip.Invoke(); Write-Host "Chose UIA3"; Start-Sleep -Milliseconds 1200 }
        } catch {}
    }
}

$inspHwnd = Get-LargestWindowForPid $inspProc.Id
if ($inspHwnd -eq [IntPtr]::Zero) {
    Start-Sleep -Milliseconds 2500
    $inspHwnd = Get-LargestWindowForPid $inspProc.Id
}
if ($inspHwnd -eq [IntPtr]::Zero) { throw "FlaUInspect window not found for PID $($inspProc.Id)" }

[void][CapApi]::MoveWindow($inspHwnd, 520, 60, 1000, 720, $true)
Start-Sleep -Milliseconds 600

# Step 1: picker view (App + FlaUInspect side by side) before attaching
$L = Capture-ToBitmap $appHwnd
$R = Capture-ToBitmap $inspHwnd
Save-SideBySide $L $R (Join-Path $outDir "inspect_01_launch.png") "Semi Inspection Desktop" "FlaUInspect"
$L.Dispose(); $R.Dispose()

Save-Uia3Card (Join-Path $outDir "inspect_02_uia3.png")

# Attach FlaUInspect to Semi Inspection Desktop via mouse double-click only
Write-Host "Attaching FlaUInspect to Semi Inspection Desktop..."
Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class MouseClick {
  [DllImport("user32.dll")] public static extern void mouse_event(uint f, uint x, uint y, uint d, UIntPtr e);
  public const uint LEFTDOWN = 0x0002; public const uint LEFTUP = 0x0004;
  public static void Dbl() {
    mouse_event(LEFTDOWN,0,0,0,UIntPtr.Zero); mouse_event(LEFTUP,0,0,0,UIntPtr.Zero);
    System.Threading.Thread.Sleep(80);
    mouse_event(LEFTDOWN,0,0,0,UIntPtr.Zero); mouse_event(LEFTUP,0,0,0,UIntPtr.Zero);
  }
}
"@ -ErrorAction SilentlyContinue

$inspUia = Get-UiaWindowForPid $inspProc.Id
if ($inspUia) {
    [void][CapApi]::SetForegroundWindow($inspHwnd)
    Start-Sleep -Milliseconds 400
    $listCond = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
        [System.Windows.Automation.ControlType]::ListItem)
    $items = $inspUia.FindAll([System.Windows.Automation.TreeScope]::Descendants, $listCond)
    $targetItem = $null
    foreach ($item in $items) {
        $name = [string]$item.Current.Name
        if ($name -like "*Semi Inspection Desktop*") {
            $targetItem = $item
            Write-Host "  found list item: $name"
            break
        }
    }
    if ($targetItem) {
        try {
            $sel = $targetItem.GetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern)
            if ($sel) { $sel.Select(); Start-Sleep -Milliseconds 200 }
        } catch {}
        $rect = $targetItem.Current.BoundingRectangle
        $cx = [int]($rect.X + $rect.Width / 2)
        $cy = [int]($rect.Y + $rect.Height / 2)
        Write-Host "  double-click at $cx,$cy"
        [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($cx, $cy)
        [MouseClick]::Dbl()
    } else {
        Write-Host "  [!] Semi Inspection Desktop list item not found"
    }
}

# Wait for Process: ... Semi Inspection Desktop window
$inspTree = [IntPtr]::Zero
for ($i = 0; $i -lt 10; $i++) {
    Start-Sleep -Milliseconds 500
    $inspTree = Get-InspectWindowForTarget $inspProc.Id "Semi Inspection"
    if ($inspTree -ne [IntPtr]::Zero) {
        $t = [CapApi]::Title($inspTree)
        if ($t -like "*Semi Inspection*") { break }
    }
}
if ($inspTree -ne [IntPtr]::Zero) {
    $inspHwnd = $inspTree
    [void][CapApi]::MoveWindow($inspHwnd, 520, 40, 1100, 780, $true)
    Start-Sleep -Milliseconds 600
}
Write-Host ("  inspect hwnd after attach: {0} title='{1}'" -f $inspHwnd.ToInt64(), [CapApi]::Title($inspHwnd))

# Step 4: App toolbar vs FlaUInspect
$L2 = Capture-ToBitmap $appHwnd
$R2 = Capture-ToBitmap $inspHwnd
Save-SideBySide $L2 $R2 (Join-Path $outDir "inspect_03_hover.png") "App (toolbar targets)" "FlaUInspect"
$L2.Dispose(); $R2.Dispose()

# Step 5: FlaUInspect properties / tree
Capture-PrintWindow $inspHwnd (Join-Path $outDir "inspect_04_properties.png")

# RawData on real app
$appUia = Get-UiaWindowForPid $appProc.Id
if ($appUia) {
    [void](Invoke-ButtonByName $appUia "RawData")
    Start-Sleep -Milliseconds 1000
    Capture-PrintWindow $appHwnd (Join-Path $outDir "03_rawdata_grid.png")
}

# Import Recipe dialog: invoke from app process only
Write-Host "Opening Import Recipe dialog from App..."
if ($appUia) {
    [void](Invoke-ButtonByName $appUia "Import Recipe")
    Start-Sleep -Milliseconds 1500
}
# Find #32770 owned by same process OR titled Import Recipe
$dlgHwnd = [IntPtr]::Zero
foreach ($h in [CapApi]::WindowsForPid([uint32]$appProc.Id)) {
    $title = [CapApi]::Title($h)
    $cls = [CapApi]::ClassName($h)
    if ($cls -eq "#32770" -or $title -eq "Import Recipe") {
        $dlgHwnd = $h
        Write-Host "  dialog hwnd=$($h.ToInt64()) title='$title' class=$cls"
        break
    }
}
if ($dlgHwnd -eq [IntPtr]::Zero) {
    # Fallback: any top-level Import Recipe dialog
    $root = [System.Windows.Automation.AutomationElement]::RootElement
    $wc = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ControlTypeProperty, [System.Windows.Automation.ControlType]::Window)
    foreach ($w in $root.FindAll([System.Windows.Automation.TreeScope]::Children, $wc)) {
        if ([string]$w.Current.Name -eq "Import Recipe") {
            $dlgHwnd = [IntPtr]$w.Current.NativeWindowHandle
            break
        }
    }
}
if ($dlgHwnd -ne [IntPtr]::Zero) {
    Capture-PrintWindow $dlgHwnd (Join-Path $outDir "02_import_file_dialog.png")
    $shell = New-Object -ComObject WScript.Shell
    [void]$shell.AppActivate("Import Recipe")
    Start-Sleep -Milliseconds 200
    $shell.SendKeys("{ESC}")
    Start-Sleep -Milliseconds 400
} else {
    Write-Host "[!] Could not open App Import dialog; keeping previous 02_ if present"
}

Write-Host ""
Write-Host "PNG files:"
Get-ChildItem $outDir -Filter "*.png" | Sort-Object Name | ForEach-Object {
    Write-Host ("  {0,-34} {1,8}" -f $_.Name, $_.Length)
}
Write-Host ("Done. App PID={0} FlaUInspect PID={1}" -f $appProc.Id, $inspProc.Id)
exit 0
