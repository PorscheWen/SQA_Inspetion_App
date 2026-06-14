using Demo2DesktopTests.Helpers;
using FlaUI.Core.AutomationElements;
using FlaUI.Core.Definitions;
using FlaUI.Core.Tools;
using FlaUI.Core.WindowsAPI;
using FlaUI.UIA3;

namespace Demo2DesktopTests.PageObjects;

public class MessageBoxPage
{
    private readonly UIA3Automation _automation;

    public MessageBoxPage(UIA3Automation automation)
    {
        _automation = automation;
    }

    public void ClickOk(int timeoutMs = 5000)
    {
        var dialog = WaitForDialog(timeoutMs);
        if (dialog == null)
        {
            return;
        }

        var ok = dialog.FindFirstDescendant(cf => cf.ByName("確定"))
            ?? dialog.FindFirstDescendant(cf => cf.ByName("OK"))
            ?? dialog.FindFirstDescendant(cf => cf.ByControlType(ControlType.Button));

        if (ok != null)
        {
            ok.Click();
            ActionScreenshotHelper.CaptureClick(
                ActionScreenshotHelper.DescribeElement(ok),
                dialog,
                ok);
        }
        else
        {
            FlaUI.Core.Input.Keyboard.Press(VirtualKeyShort.RETURN);
            ActionScreenshotHelper.CaptureClick("OK (Enter)", dialog);
        }

        Thread.Sleep(300);
    }

    private Window? WaitForDialog(int timeoutMs)
    {
        return Retry.WhileNull(
            () =>
            {
                var desktop = _automation.GetDesktop();
                foreach (var w in desktop.FindAllChildren(cf => cf.ByControlType(ControlType.Window)))
                {
                    var win = w.AsWindow();
                    if (win == null || string.IsNullOrEmpty(win.Title))
                    {
                        continue;
                    }

                    if (win.ClassName == "#32770" ||
                        win.Title.Contains("About", StringComparison.OrdinalIgnoreCase) ||
                        win.Title.Contains("Import Recipe", StringComparison.OrdinalIgnoreCase) ||
                        win.Title.Contains("Defect Chart", StringComparison.OrdinalIgnoreCase) ||
                        win.Title.Contains("Run Inspection", StringComparison.OrdinalIgnoreCase) ||
                        win.Title.Contains("開啟 Recipe", StringComparison.OrdinalIgnoreCase) ||
                        win.Title.Contains("Semi Inspection", StringComparison.OrdinalIgnoreCase))
                    {
                        return win;
                    }
                }

                return null;
            },
            TimeSpan.FromMilliseconds(timeoutMs)).Result;
    }
}
