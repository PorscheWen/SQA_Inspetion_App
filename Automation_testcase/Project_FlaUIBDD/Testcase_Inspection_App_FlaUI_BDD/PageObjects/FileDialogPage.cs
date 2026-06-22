using System.Runtime.InteropServices;
using System.Text;
using Inspection_AppTests.Helpers;
using FlaUI.Core.AutomationElements;
using FlaUI.Core.Definitions;
using FlaUI.Core.Input;
using FlaUI.Core.Tools;
using FlaUI.Core.WindowsAPI;
using FlaUI.UIA3;

namespace Inspection_AppTests.PageObjects;

public class FileDialogPage
{
    private const int WmSetText = 0x000C;
    private const int WmGetText = 0x000D;
    private const int WmGetTextLength = 0x000E;

    private readonly UIA3Automation _automation;
    private Window? _ownerWindow;

    [DllImport("user32.dll", CharSet = CharSet.Unicode, EntryPoint = "SendMessageW", SetLastError = true)]
    private static extern IntPtr SendMessageSetText(IntPtr hWnd, int msg, IntPtr wParam, string? lParam);

    [DllImport("user32.dll", CharSet = CharSet.Auto, EntryPoint = "SendMessage")]
    private static extern IntPtr SendMessageGetText(IntPtr hWnd, int msg, IntPtr wParam, StringBuilder? lParam);

    [DllImport("user32.dll", CharSet = CharSet.Auto, EntryPoint = "SendMessage")]
    private static extern IntPtr SendMessageGetLength(IntPtr hWnd, int msg, IntPtr wParam, IntPtr lParam);

    [DllImport("user32.dll")]
    private static extern bool SetForegroundWindow(IntPtr hWnd);

    public FileDialogPage(UIA3Automation automation, Window? ownerWindow = null)
    {
        _automation = automation;
        _ownerWindow = ownerWindow;
    }

    public void SetOwnerWindow(Window? ownerWindow) => _ownerWindow = ownerWindow;

    public void OpenFile(string fullPath, int timeoutMs = 12000, bool requireFileExists = true)
    {
        if (requireFileExists && !File.Exists(fullPath))
        {
            throw new FileNotFoundException("Sample file not found: " + fullPath);
        }

        var dialog = WaitForOpenDialog(timeoutMs);
        if (dialog == null)
        {
            throw new InvalidOperationException("無法找到開啟檔案對話框，請確認 Import / Open 對話框已顯示。");
        }

        FocusDialogSafe(dialog);
        Thread.Sleep(500);

        if (requireFileExists && TrySelectExistingFileInDialog(dialog, fullPath))
        {
            ActionScreenshotHelper.CaptureAction($"清單選取: {Path.GetFileName(fullPath)}", dialog);
            ConfirmOpenAndWait(dialog);
            return;
        }

        var fileNameField = FindFileNameField(dialog);
        if (fileNameField == null)
        {
            ActionScreenshotHelper.CaptureAction("找不到檔名欄位", dialog);
            if (TrySetPathViaKeyboardOnDialog(dialog, fullPath))
            {
                ActionScreenshotHelper.CaptureAction($"路徑已輸入: {Path.GetFileName(fullPath)}", dialog);
                ConfirmOpenAndWait(dialog);
                return;
            }

            throw new InvalidOperationException("找不到檔案名稱輸入欄（AutomationId 1148）。");
        }

        if (!TrySetPathInFileNameField(dialog, fileNameField, fullPath)
            && !TrySetPathViaKeyboardOnDialog(dialog, fullPath))
        {
            var current = fileNameField != null ? ReadFieldText(fileNameField) : string.Empty;
            Console.WriteLine($"檔名欄目前內容: [{current}]");
            ActionScreenshotHelper.CaptureAction("檔案路徑輸入失敗", dialog);
            throw new InvalidOperationException("無法在檔案對話框輸入路徑: " + fullPath);
        }

        ActionScreenshotHelper.CaptureAction($"路徑已輸入: {Path.GetFileName(fullPath)}", dialog);
        ConfirmOpenAndWait(dialog);
    }

    private void ConfirmOpenAndWait(Window dialog)
    {
        Thread.Sleep(200);

        if (!TryConfirmOpen(dialog))
        {
            Keyboard.Press(VirtualKeyShort.RETURN);
        }

        WaitForDialogClosed(10000);
        Thread.Sleep(800);
    }

    private static bool TrySelectExistingFileInDialog(Window dialog, string fullPath)
    {
        try
        {
            var folder = Path.GetDirectoryName(fullPath);
            var fileName = Path.GetFileName(fullPath);
            if (string.IsNullOrWhiteSpace(folder) || string.IsNullOrWhiteSpace(fileName))
            {
                return false;
            }

            TryNavigateToFolder(dialog, folder);
            Thread.Sleep(600);

            foreach (var item in dialog.FindAllDescendants())
            {
                var name = item.Name ?? string.Empty;
                if (!name.Equals(fileName, StringComparison.OrdinalIgnoreCase)
                    && !name.StartsWith(fileName, StringComparison.OrdinalIgnoreCase))
                {
                    continue;
                }

                try
                {
                    item.Click();
                    Thread.Sleep(300);
                    return true;
                }
                catch
                {
                    // try next
                }
            }
        }
        catch
        {
            // ignore
        }

        return false;
    }

    private static void TryNavigateToFolder(Window dialog, string folder)
    {
        try
        {
            var combo = dialog.FindFirstDescendant(cf => cf.ByClassName("ComboBoxEx32"));
            if (combo != null)
            {
                combo.Focus();
                Thread.Sleep(150);
                KeyboardInputHelper.PasteText(folder);
                Keyboard.Press(VirtualKeyShort.RETURN);
                Thread.Sleep(500);
                return;
            }
        }
        catch
        {
            // ignore
        }

        FocusDialogSafe(dialog);
        KeyboardInputHelper.PasteText(folder);
        Keyboard.Press(VirtualKeyShort.RETURN);
        Thread.Sleep(500);
    }

    private static bool TrySetPathViaKeyboardOnDialog(Window dialog, string fullPath)
    {
        try
        {
            FocusDialogSafe(dialog);
            Thread.Sleep(200);
            Keyboard.TypeSimultaneously(VirtualKeyShort.ALT, VirtualKeyShort.KEY_N);
            Thread.Sleep(150);
            KeyboardInputHelper.PasteText(fullPath);
            Thread.Sleep(300);
            return true;
        }
        catch
        {
            return false;
        }
    }

    private static bool TrySetPathInFileNameField(Window dialog, AutomationElement? fileNameField, string fullPath)
    {
        if (fileNameField == null)
        {
            return false;
        }
        foreach (var candidate in BuildPathCandidates(fullPath))
        {
            if (TrySetPathViaWin32Message(fileNameField, candidate, fullPath))
            {
                return true;
            }

            if (TrySetPathViaValuePattern(fileNameField, candidate, fullPath))
            {
                return true;
            }

            if (TrySetPathViaFlaUITextBox(fileNameField, candidate, fullPath))
            {
                return true;
            }

            if (TrySetPathViaClipboard(fileNameField, candidate, fullPath))
            {
                return true;
            }
        }

        if (TrySetPathViaAddressBar(dialog, fullPath))
        {
            return TrySetPathViaWin32Message(fileNameField, Path.GetFileName(fullPath), fullPath)
                || TrySetPathViaClipboard(fileNameField, Path.GetFileName(fullPath), fullPath);
        }

        return false;
    }

    private static IEnumerable<string> BuildPathCandidates(string fullPath)
    {
        yield return fullPath;
        yield return Path.GetFileName(fullPath);
        yield return $"\"{fullPath}\"";
    }

    private static bool TrySetPathViaAddressBar(Window dialog, string fullPath)
    {
        try
        {
            var folder = Path.GetDirectoryName(fullPath);
            if (string.IsNullOrWhiteSpace(folder) || !Directory.Exists(folder))
            {
                return false;
            }

            var combo = dialog.FindFirstDescendant(cf => cf.ByClassName("ComboBoxEx32"))
                ?? dialog.FindFirstDescendant(cf => cf.ByControlType(ControlType.ComboBox));

            if (combo == null)
            {
                return false;
            }

            FocusFileNameFieldOnly(combo);
            KeyboardInputHelper.PasteText(folder);
            Keyboard.Press(VirtualKeyShort.RETURN);
            Thread.Sleep(600);
            return true;
        }
        catch
        {
            return false;
        }
    }

    private static bool TrySetPathViaWin32Message(AutomationElement fileNameField, string text, string fullPath)
    {
        try
        {
            var handle = fileNameField.Properties.NativeWindowHandle.ValueOrDefault;
            if (handle == IntPtr.Zero)
            {
                return false;
            }

            FocusFileNameFieldOnly(fileNameField);
            SendMessageSetText(handle, WmSetText, IntPtr.Zero, text);
            Thread.Sleep(250);
            return PathLooksSet(fileNameField, fullPath);
        }
        catch
        {
            return false;
        }
    }

    private static bool TrySetPathViaValuePattern(AutomationElement fileNameField, string text, string fullPath)
    {
        try
        {
            if (!fileNameField.Patterns.Value.IsSupported)
            {
                return false;
            }

            FocusFileNameFieldOnly(fileNameField);
            fileNameField.Patterns.Value.Pattern.SetValue(text);
            Thread.Sleep(250);
            return PathLooksSet(fileNameField, fullPath);
        }
        catch
        {
            return false;
        }
    }

    private static bool TrySetPathViaFlaUITextBox(AutomationElement fileNameField, string text, string fullPath)
    {
        try
        {
            var textBox = fileNameField.AsTextBox();
            FocusFileNameFieldOnly(fileNameField);
            textBox.Text = text;
            Thread.Sleep(250);
            return PathLooksSet(fileNameField, fullPath);
        }
        catch
        {
            return false;
        }
    }

    private static bool TrySetPathViaClipboard(AutomationElement fileNameField, string text, string fullPath)
    {
        try
        {
            FocusFileNameFieldOnly(fileNameField);
            KeyboardInputHelper.PasteText(text);
            Thread.Sleep(250);
            return PathLooksSet(fileNameField, fullPath);
        }
        catch
        {
            return false;
        }
    }

    private static void FocusFileNameFieldOnly(AutomationElement fileNameField)
    {
        KeyboardInputHelper.EnsureEnglishInput();

        try
        {
            fileNameField.Focus();
            Thread.Sleep(150);
        }
        catch
        {
            // ignore
        }

        try
        {
            Keyboard.TypeSimultaneously(VirtualKeyShort.ALT, VirtualKeyShort.KEY_N);
            Thread.Sleep(120);
        }
        catch
        {
            // ignore
        }

        try
        {
            var handle = fileNameField.Properties.NativeWindowHandle.ValueOrDefault;
            if (handle != IntPtr.Zero)
            {
                SetForegroundWindow(handle);
            }
        }
        catch
        {
            // ignore
        }
    }

    private static bool TryConfirmOpen(Window dialog)
    {
        try
        {
            var openButton = dialog.FindFirstDescendant(cf => cf.ByAutomationId("1"))
                ?? dialog.FindFirstDescendant(cf => cf.ByName("Open"))
                ?? dialog.FindFirstDescendant(cf => cf.ByName("開啟"))
                ?? dialog.FindFirstDescendant(cf => cf.ByName("打开"))
                ?? dialog.FindFirstDescendant(cf => cf.ByName("確定"))
                ?? dialog.FindFirstDescendant(cf => cf.ByName("确定"));

            if (openButton == null)
            {
                return false;
            }

            if (openButton.Patterns.Invoke.IsSupported)
            {
                openButton.Patterns.Invoke.Pattern.Invoke();
            }
            else
            {
                openButton.Click();
            }

            ActionScreenshotHelper.CaptureClick(
                ActionScreenshotHelper.DescribeElement(openButton),
                dialog,
                openButton);
            Thread.Sleep(300);
            return true;
        }
        catch
        {
            return false;
        }
    }

    private static AutomationElement? FindFileNameField(Window dialog)
    {
        return dialog.FindFirstDescendant(cf => cf.ByAutomationId("1148"));
    }

    private static bool PathLooksSet(AutomationElement field, string fullPath)
    {
        var current = ReadFieldText(field);
        if (string.IsNullOrWhiteSpace(current))
        {
            return false;
        }

        var normalizedCurrent = current.Trim().Trim('"');
        var fileName = Path.GetFileName(fullPath);
        return normalizedCurrent.Equals(fullPath, StringComparison.OrdinalIgnoreCase)
            || normalizedCurrent.Equals(fileName, StringComparison.OrdinalIgnoreCase)
            || normalizedCurrent.EndsWith("\\" + fileName, StringComparison.OrdinalIgnoreCase)
            || normalizedCurrent.EndsWith("/" + fileName, StringComparison.OrdinalIgnoreCase);
    }

    private static string ReadFieldText(AutomationElement element)
    {
        try
        {
            var handle = element.Properties.NativeWindowHandle.ValueOrDefault;
            if (handle != IntPtr.Zero)
            {
                var length = SendMessageGetLength(handle, WmGetTextLength, IntPtr.Zero, IntPtr.Zero).ToInt32();
                if (length > 0)
                {
                    var buffer = new StringBuilder(length + 1);
                    SendMessageGetText(handle, WmGetText, (IntPtr)(length + 1), buffer);
                    if (buffer.Length > 0)
                    {
                        return buffer.ToString();
                    }
                }
            }
        }
        catch
        {
            // ignore
        }

        try
        {
            var textBox = element.AsTextBox();
            if (!string.IsNullOrEmpty(textBox.Text))
            {
                return textBox.Text;
            }
        }
        catch
        {
            // ignore
        }

        if (element.Patterns.Value.IsSupported)
        {
            try
            {
                return element.Patterns.Value.Pattern.Value.Value ?? string.Empty;
            }
            catch
            {
                // ignore
            }
        }

        return string.Empty;
    }

    private static void FocusDialogSafe(Window dialog)
    {
        try
        {
            dialog.SetForeground();
            dialog.Focus();
        }
        catch
        {
            // ignore
        }
    }

    private Window? WaitForOpenDialog(int timeoutMs)
    {
        return Retry.WhileNull(FindOpenDialog, TimeSpan.FromMilliseconds(timeoutMs)).Result;
    }

    private void WaitForDialogClosed(int timeoutMs)
    {
        Retry.WhileTrue(
            () => FindOpenDialog() != null,
            TimeSpan.FromMilliseconds(timeoutMs));
    }

    private Window? FindOpenDialog()
    {
        try
        {
            Window? titleMatch = null;
            Window? fieldMatch = null;
            Window? fallback = null;

            foreach (var root in GetSearchRoots())
            {
                foreach (var w in root.FindAllDescendants(cf => cf.ByControlType(ControlType.Window)))
                {
                    var win = w.AsWindow();
                    if (win == null || !win.IsAvailable)
                    {
                        continue;
                    }

                    var title = win.Title ?? string.Empty;
                    if (IsLikelyOpenFileDialogTitle(title))
                    {
                        titleMatch = win;
                    }

                    if (win.ClassName == "#32770" && fallback == null)
                    {
                        fallback = win;
                    }
                }

                var fileNameField = root.FindFirstDescendant(cf => cf.ByAutomationId("1148"));
                if (fileNameField != null)
                {
                    var fromField = WalkUpToWindow(fileNameField);
                    if (fromField != null && fromField.ClassName == "#32770")
                    {
                        fieldMatch = fromField;
                    }
                }
            }

            return titleMatch ?? fieldMatch ?? fallback;
        }
        catch
        {
            return null;
        }
    }

    private IEnumerable<AutomationElement> GetSearchRoots()
    {
        yield return _automation.GetDesktop();

        if (_ownerWindow != null && _ownerWindow.IsAvailable)
        {
            yield return _ownerWindow;
        }
    }

    private static bool IsLikelyOpenFileDialogTitle(string title)
    {
        if (string.IsNullOrWhiteSpace(title))
        {
            return false;
        }

        return title.Contains("Import Recipe", StringComparison.OrdinalIgnoreCase) ||
               title.Contains("Import JSON", StringComparison.OrdinalIgnoreCase) ||
               title.Contains("開啟", StringComparison.OrdinalIgnoreCase) ||
               title.Contains("打开", StringComparison.OrdinalIgnoreCase) ||
               title.Contains("Open", StringComparison.OrdinalIgnoreCase) ||
               title.Contains("Browse", StringComparison.OrdinalIgnoreCase) ||
               title.Contains("浏览", StringComparison.OrdinalIgnoreCase);
    }

    private static Window? WalkUpToWindow(AutomationElement element)
    {
        var current = element;
        for (var depth = 0; depth < 12 && current != null; depth++)
        {
            if (current.ControlType == ControlType.Window)
            {
                return current.AsWindow();
            }

            try
            {
                current = current.Parent;
            }
            catch
            {
                break;
            }
        }

        return null;
    }
}
