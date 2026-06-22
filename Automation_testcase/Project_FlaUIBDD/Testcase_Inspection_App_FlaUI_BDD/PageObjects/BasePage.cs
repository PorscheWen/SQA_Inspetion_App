using System.Runtime.InteropServices;
using System.Text;
using FlaUI.Core;
using FlaUI.Core.AutomationElements;
using FlaUI.Core.Definitions;
using FlaUI.Core.Exceptions;
using FlaUI.Core.Input;
using FlaUI.Core.Tools;
using FlaUI.UIA3;

namespace Inspection_AppTests.PageObjects;

public abstract class BasePage : IDisposable
{
    protected readonly Window Window;
    protected readonly UIA3Automation Automation;
    private readonly int _defaultTimeoutMs;

    protected BasePage(Window window, UIA3Automation automation)
    {
        Window = window ?? throw new ArgumentNullException(nameof(window));
        Automation = automation ?? throw new ArgumentNullException(nameof(automation));
        _defaultTimeoutMs = Helpers.ConfigHelper.GetDefaultTimeout();
    }

    protected AutomationElement? FindByName(string name, int timeoutMs = 0)
    {
        timeoutMs = timeoutMs > 0 ? timeoutMs : _defaultTimeoutMs;
        return Retry.WhileNull(
            () => Window.FindFirstDescendant(cf => cf.ByName(name)),
            TimeSpan.FromMilliseconds(timeoutMs)).Result;
    }

    protected AutomationElement? FindByAutomationId(string automationId, int timeoutMs = 0)
    {
        timeoutMs = timeoutMs > 0 ? timeoutMs : _defaultTimeoutMs;
        return Retry.WhileNull(
            () => Window.FindFirstDescendant(cf => cf.ByAutomationId(automationId)),
            TimeSpan.FromMilliseconds(timeoutMs)).Result;
    }

    protected AutomationElement? FindByNameContains(string partial, int timeoutMs = 5000)
    {
        return Retry.WhileNull(
            () =>
            {
                foreach (var el in Window.FindAllDescendants())
                {
                    var n = el.Name ?? string.Empty;
                    if (n.Contains(partial, StringComparison.OrdinalIgnoreCase))
                    {
                        return el;
                    }
                }
                return null;
            },
            TimeSpan.FromMilliseconds(timeoutMs)).Result;
    }

    protected AutomationElement? FindByClassName(string className, int timeoutMs = 0)
    {
        timeoutMs = timeoutMs > 0 ? timeoutMs : _defaultTimeoutMs;
        return Retry.WhileNull(
            () => Window.FindFirstDescendant(cf => cf.ByClassName(className)),
            TimeSpan.FromMilliseconds(timeoutMs)).Result;
    }

    /// <summary>WinForms 控制項：依 Name / AutomationId 尋找（兩者通常皆為 Designer.Name）。</summary>
    protected AutomationElement? FindWinFormsControl(string controlName)
    {
        var byId = Window.FindFirstDescendant(cf => cf.ByAutomationId(controlName));
        if (byId != null)
        {
            return byId;
        }

        return Window.FindFirstDescendant(cf => cf.ByName(controlName));
    }

    private const int WmGetText = 0x000D;
    private const int WmGetTextLength = 0x000E;

    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    private static extern IntPtr SendMessage(IntPtr hWnd, int msg, IntPtr wParam, StringBuilder? lParam);

    protected static string ReadText(AutomationElement element)
    {
        var nativeText = ReadNativeWindowText(element);
        if (!string.IsNullOrEmpty(nativeText))
        {
            return nativeText;
        }

        try
        {
            var textBox = element.AsTextBox();
            if (textBox != null)
            {
                var text = textBox.Text;
                if (!string.IsNullOrEmpty(text))
                {
                    return text;
                }
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
                var value = element.Patterns.Value.Pattern.Value.Value;
                if (!string.IsNullOrEmpty(value))
                {
                    return value;
                }
            }
            catch
            {
                // ignore
            }
        }

        if (element.Patterns.Text.IsSupported)
        {
            try
            {
                var text = element.Patterns.Text.Pattern.DocumentRange.GetText(-1);
                if (!string.IsNullOrEmpty(text))
                {
                    return text;
                }
            }
            catch
            {
                // ignore
            }
        }

        if (element.Patterns.LegacyIAccessible.IsSupported)
        {
            try
            {
                var value = element.Patterns.LegacyIAccessible.Pattern.Value.Value;
                if (!string.IsNullOrEmpty(value))
                {
                    return value;
                }
            }
            catch
            {
                // ignore
            }
        }

        if (!string.IsNullOrWhiteSpace(element.Name))
        {
            return element.Name;
        }

        return string.Empty;
    }

    protected static string ReadNativeWindowText(AutomationElement element)
    {
        try
        {
            var handle = element.Properties.NativeWindowHandle.ValueOrDefault;
            if (handle == IntPtr.Zero)
            {
                return string.Empty;
            }

            var length = SendMessage(handle, WmGetTextLength, IntPtr.Zero, null).ToInt32();
            if (length <= 0)
            {
                return string.Empty;
            }

            var buffer = new StringBuilder(length + 1);
            SendMessage(handle, WmGetText, (IntPtr)(length + 1), buffer);
            return buffer.ToString();
        }
        catch
        {
            return string.Empty;
        }
    }

    protected bool TryInvokeClick(AutomationElement element, string? label = null)
    {
        var clickLabel = label ?? Helpers.ActionScreenshotHelper.DescribeElement(element);
        try
        {
            if (element.Patterns.Invoke.IsSupported)
            {
                element.Patterns.Invoke.Pattern.Invoke();
                Thread.Sleep(300);
                Helpers.ActionScreenshotHelper.CaptureClick(clickLabel, Window, element);
                Thread.Sleep(200);
                return true;
            }
        }
        catch
        {
            // fall through
        }

        return false;
    }

    protected void Click(AutomationElement element, string? label = null)
    {
        var clickLabel = label ?? Helpers.ActionScreenshotHelper.DescribeElement(element);

        try
        {
            if (element.Patterns.Invoke.IsSupported)
            {
                element.Patterns.Invoke.Pattern.Invoke();
                Thread.Sleep(300);
                Helpers.ActionScreenshotHelper.CaptureClick(clickLabel, Window, element);
                Thread.Sleep(200);
                return;
            }
        }
        catch
        {
            // fall through
        }

        try
        {
            element.Click();
        }
        catch (NoClickablePointException)
        {
            try
            {
                ClickByBounds(element);
            }
            catch (System.Runtime.InteropServices.COMException)
            {
                throw new ElementNotAvailableException("Element is not clickable via UIA bounds.");
            }
        }
        catch (System.Runtime.InteropServices.COMException)
        {
            throw new ElementNotAvailableException("Element click timed out via UIA.");
        }

        Thread.Sleep(300);
        Helpers.ActionScreenshotHelper.CaptureClick(clickLabel, Window, element);
        Thread.Sleep(200);
    }

    private void ClickByBounds(AutomationElement element)
    {
        var rect = element.BoundingRectangle;
        if (rect.IsEmpty)
        {
            throw new ElementNotAvailableException("Element has no clickable bounds.");
        }

        Mouse.Click(new System.Drawing.Point(rect.X + rect.Width / 2, rect.Y + rect.Height / 2));
    }

    protected void RequireElement(AutomationElement? element, string label)
    {
        if (element == null)
        {
            throw new ElementNotAvailableException(label);
        }
    }

    public virtual void Dispose() { }
}
