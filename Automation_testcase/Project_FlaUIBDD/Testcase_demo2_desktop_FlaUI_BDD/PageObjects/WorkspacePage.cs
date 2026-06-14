using FlaUI.Core.AutomationElements;
using FlaUI.Core.Definitions;
using FlaUI.Core.Tools;
using FlaUI.UIA3;

namespace Demo2DesktopTests.PageObjects;

public class WorkspacePage : BasePage
{
    public WorkspacePage(Window window, UIA3Automation automation) : base(window, automation) { }

    public bool IsTreeVisible(int waitMs = 10000)
    {
        return WaitForTree(waitMs) != null;
    }

    public bool IsGridVisible(int waitMs = 15000)
    {
        return WaitForDataGrid(waitMs) != null;
    }

    public bool LogContains(string expected, int waitMs = 10000)
    {
        var deadline = DateTime.UtcNow.AddMilliseconds(waitMs);
        while (DateTime.UtcNow < deadline)
        {
            if (TryReadLogContains(expected))
            {
                return true;
            }

            Thread.Sleep(250);
        }

        return false;
    }

    public void DoubleClickTreeItem(string partialName)
    {
        var tree = WaitForTree(8000);
        if (tree == null)
        {
            Console.WriteLine("TreeView not found for double-click");
            return;
        }

        foreach (var el in tree.FindAllDescendants())
        {
            var name = el.Name ?? string.Empty;
            if (name.Contains(partialName, StringComparison.OrdinalIgnoreCase))
            {
                el.DoubleClick();
                Helpers.ActionScreenshotHelper.CaptureClick($"雙擊 {partialName}", Window, el);
                Thread.Sleep(1500);
                return;
            }
        }

        var fallback = FindByNameContains(partialName, timeoutMs: 3000);
        if (fallback != null)
        {
            fallback.DoubleClick();
            Helpers.ActionScreenshotHelper.CaptureClick($"雙擊 {partialName}", Window, fallback);
            Thread.Sleep(1500);
            return;
        }

        Console.WriteLine($"Tree item not found: {partialName}; caller may use fallback");
    }

    public void TakeScreenshot(string fileName)
    {
        var dir = Path.Combine(AppContext.BaseDirectory, Helpers.ConfigHelper.GetScreenshotDirectory());
        Directory.CreateDirectory(dir);
        var path = Path.Combine(dir, fileName);
        var capture = Window.Capture();
        capture.Save(path);
        Console.WriteLine($"Screenshot: {path}");
    }

    public void WaitAfterDataTableAction()
    {
        WaitForDataGrid(15000);
        Thread.Sleep(800);
    }

    private AutomationElement? WaitForTree(int timeoutMs)
    {
        return Retry.WhileNull(FindTreeView, TimeSpan.FromMilliseconds(timeoutMs)).Result;
    }

    private AutomationElement? WaitForDataGrid(int timeoutMs)
    {
        return Retry.WhileNull(FindDataGrid, TimeSpan.FromMilliseconds(timeoutMs)).Result;
    }

    private AutomationElement? FindTreeView()
    {
        foreach (var name in new[] { "treeFiles", "fileTree" })
        {
            var el = FindWinFormsControl(name);
            if (el != null)
            {
                return el;
            }
        }

        return Window.FindFirstDescendant(cf => cf.ByControlType(ControlType.Tree))
            ?? Window.FindFirstDescendant(cf => cf.ByClassName("SysTreeView32"))
            ?? Window.FindFirstDescendant(cf => cf.ByClassName("TreeView"));
    }

    private AutomationElement? FindDataGrid()
    {
        var el = FindWinFormsControl("dataGridParameters");
        if (el != null)
        {
            return el;
        }

        return Window.FindFirstDescendant(cf => cf.ByControlType(ControlType.DataGrid))
            ?? Window.FindFirstDescendant(cf => cf.ByClassName("DataGridView"))
            ?? Window.FindFirstDescendant(cf => cf.ByClassName("WindowsForms10.SysDataGridView"));
    }

    private bool TryReadLogContains(string expected)
    {
        foreach (var controlName in new[] { "txtToolLog", "lblToolPlugin", "statusLabel", "statusStrip" })
        {
            var el = FindWinFormsControl(controlName);
            if (el != null && TextContains(el, expected))
            {
                return true;
            }
        }

        foreach (var el in Window.FindAllDescendants())
        {
            if (ElementTextContains(el, expected))
            {
                return true;
            }
        }

        return false;
    }

    private static bool ElementTextContains(AutomationElement element, string expected)
    {
        var name = element.Name ?? string.Empty;
        if (name.Contains(expected, StringComparison.OrdinalIgnoreCase))
        {
            return true;
        }

        var native = ReadNativeWindowText(element);
        if (native.Contains(expected, StringComparison.OrdinalIgnoreCase))
        {
            return true;
        }

        var text = ReadText(element);
        return text.Contains(expected, StringComparison.OrdinalIgnoreCase);
    }

    private static bool TextContains(AutomationElement element, string expected)
    {
        var text = ReadText(element);
        return !string.IsNullOrEmpty(text)
            && text.Contains(expected, StringComparison.OrdinalIgnoreCase);
    }
}
