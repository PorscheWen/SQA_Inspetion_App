using FlaUI.Core.AutomationElements;
using FlaUI.Core.Definitions;
using FlaUI.Core.Input;
using FlaUI.Core.WindowsAPI;
using FlaUI.UIA3;

namespace Demo2DesktopTests.Helpers;

/// <summary>關閉可能阻擋 UIA 的對話框，避免 TearDown 逾時。</summary>
public static class DialogHelper
{
    private static readonly string[] OpenDialogTitleHints =
    [
        "Open", "Browse", "Import", "開啟", "打开", "浏览", "Import Recipe", "Import JSON"
    ];

    public static void DismissOpenDialogs(UIA3Automation? automation, int escapePresses = 4)
    {
        try
        {
            for (var i = 0; i < escapePresses; i++)
            {
                Keyboard.Press(VirtualKeyShort.ESCAPE);
                Thread.Sleep(250);
            }
        }
        catch
        {
            // ignore
        }

        if (automation == null)
        {
            return;
        }

        CloseFilePickerWindows(automation);
    }

    private static void CloseFilePickerWindows(UIA3Automation automation)
    {
        try
        {
            var desktop = automation.GetDesktop();
            foreach (var w in desktop.FindAllChildren(cf => cf.ByControlType(ControlType.Window)))
            {
                var win = w.AsWindow();
                if (win == null || !win.IsAvailable)
                {
                    continue;
                }

                var className = win.ClassName ?? string.Empty;
                var title = win.Title ?? string.Empty;
                var isCommonDialog = className == "#32770";
                var isExplorerShell = className.Contains("Cabinet", StringComparison.OrdinalIgnoreCase)
                    || className.Equals("ExploreWClass", StringComparison.OrdinalIgnoreCase);
                var looksLikeOpenDialog = OpenDialogTitleHints.Any(
                    hint => title.Contains(hint, StringComparison.OrdinalIgnoreCase));

                if (!isCommonDialog && !isExplorerShell && !looksLikeOpenDialog)
                {
                    continue;
                }

                if (isExplorerShell && !looksLikeOpenDialog)
                {
                    continue;
                }

                try
                {
                    win.Close();
                }
                catch
                {
                    // ignore
                }
            }
        }
        catch
        {
            // ignore
        }
    }
}
