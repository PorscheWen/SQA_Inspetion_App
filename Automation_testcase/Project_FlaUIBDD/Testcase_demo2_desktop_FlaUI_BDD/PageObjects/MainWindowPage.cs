using FlaUI.Core.AutomationElements;
using FlaUI.Core.Definitions;
using FlaUI.Core.Exceptions;
using FlaUI.Core.Input;
using FlaUI.Core.Tools;
using FlaUI.Core.WindowsAPI;
using FlaUI.UIA3;

namespace Demo2DesktopTests.PageObjects;

public class MainWindowPage : BasePage
{
    private const int ToolbarLookupMs = 2500;

    private static readonly Dictionary<string, (string AutomationId, VirtualKeyShort? Shortcut)> ToolbarMap =
        new(StringComparer.OrdinalIgnoreCase)
        {
            ["Import Recipe"] = ("btnImportRecipe", VirtualKeyShort.KEY_I),
            ["About"] = ("btnToolbar0About", null),
            ["RawData"] = ("btnParameters", VirtualKeyShort.KEY_E),
            ["Defect Chart"] = ("btnDefectChart", VirtualKeyShort.KEY_D),
            ["Run Inspection"] = ("btnRunInspection", VirtualKeyShort.KEY_R),
        };

    public MainWindowPage(Window window, UIA3Automation automation) : base(window, automation) { }

    public void ClickToolbar(string buttonText)
    {
        FocusMainWindow();

        if (string.Equals(buttonText, "About", StringComparison.OrdinalIgnoreCase))
        {
            if (TryClickToolbarElement("btnToolbar0About", buttonText))
            {
                return;
            }

            OpenAboutViaKeyboard();
            return;
        }

        if (string.Equals(buttonText, "Import Recipe", StringComparison.OrdinalIgnoreCase))
        {
            SendImportRecipeShortcut();
            Thread.Sleep(1000);
            return;
        }

        if (ToolbarMap.TryGetValue(buttonText, out var mapped))
        {
            if (mapped.Shortcut.HasValue && TryInvokeShortcut(mapped.Shortcut.Value))
            {
                return;
            }

            if (TryClickToolbarElement(mapped.AutomationId, buttonText))
            {
                return;
            }
        }
        else if (TryClickToolbarElement(null, buttonText))
        {
            return;
        }

        throw new ElementNotAvailableException($"找不到工具列按鈕: {buttonText}");
    }

    public void OpenAboutViaKeyboard()
    {
        FocusMainWindow();
        Keyboard.Press(VirtualKeyShort.F10);
        Thread.Sleep(300);
        Keyboard.Press(VirtualKeyShort.RIGHT);
        Thread.Sleep(200);
        Keyboard.Press(VirtualKeyShort.DOWN);
        Thread.Sleep(200);
        for (var i = 0; i < 4; i++)
        {
            Keyboard.Press(VirtualKeyShort.DOWN);
            Thread.Sleep(80);
        }

        Keyboard.Press(VirtualKeyShort.RETURN);
        Thread.Sleep(500);
    }

    public void SendShortcut(VirtualKeyShort key, bool ctrl = false)
    {
        FocusMainWindow();
        if (ctrl)
        {
            Keyboard.TypeSimultaneously(VirtualKeyShort.CONTROL, key);
        }
        else
        {
            Keyboard.Type(key);
        }

        Thread.Sleep(500);
    }

    public void SendParametersShortcut() => SendShortcut(VirtualKeyShort.KEY_E, ctrl: true);

    public void SendImportRecipeShortcut() => SendShortcut(VirtualKeyShort.KEY_I, ctrl: true);

    public string GetWindowTitle() => Window.Title;

    public bool IsMainWindowVisible() => Window.IsAvailable;

    private void FocusMainWindow()
    {
        try
        {
            Window.Focus();
            Window.SetForeground();
        }
        catch
        {
        }

        Thread.Sleep(300);
    }

    private bool TryClickToolbarElement(string? automationId, string displayText)
    {
        if (!string.IsNullOrEmpty(automationId))
        {
            var byId = FindByAutomationId(automationId, ToolbarLookupMs);
            if (byId != null)
            {
                Click(byId);
                return true;
            }
        }

        var byName = FindByName(displayText, ToolbarLookupMs);
        if (byName != null)
        {
            Click(byName);
            return true;
        }

        var byPartial = FindToolbarButtonByText(displayText, ToolbarLookupMs);
        if (byPartial != null)
        {
            Click(byPartial);
            return true;
        }

        return false;
    }

    private AutomationElement? FindToolbarButtonByText(string text, int timeoutMs)
    {
        var el = FindWinFormsControl("btnImportRecipe");
        if (el != null && text.Contains("Import", StringComparison.OrdinalIgnoreCase))
        {
            return el;
        }

        el = FindWinFormsControl("btnParameters");
        if (el != null && (text.Contains("Raw", StringComparison.OrdinalIgnoreCase)
            || text.Contains("Parameter", StringComparison.OrdinalIgnoreCase)))
        {
            return el;
        }

        el = FindWinFormsControl("btnDefectChart");
        if (el != null && text.Contains("Defect", StringComparison.OrdinalIgnoreCase))
        {
            return el;
        }

        el = FindWinFormsControl("btnToolbar0About");
        if (el != null && text.Contains("About", StringComparison.OrdinalIgnoreCase))
        {
            return el;
        }

        el = FindWinFormsControl("btnRunInspection");
        if (el != null && text.Contains("Run", StringComparison.OrdinalIgnoreCase))
        {
            return el;
        }

        return null;
    }

    private static bool TryInvokeShortcut(VirtualKeyShort key)
    {
        Keyboard.TypeSimultaneously(VirtualKeyShort.CONTROL, key);
        Thread.Sleep(800);
        return true;
    }
}
