using FlaUI.Core.AutomationElements;
using NUnit.Framework;

namespace Demo2DesktopTests.Helpers;

/// <summary>點擊與情境結束時截圖，並附加至 HTML 報告。</summary>
public static class ActionScreenshotHelper
{
    private static int _sequence;
    private static string _scenarioKey = "scenario";

    public static void ResetForScenario(string scenarioTitle)
    {
        _sequence = 0;
        _scenarioKey = Sanitize(scenarioTitle);
    }

    public static void CaptureClick(string label, Window? window = null, AutomationElement? element = null)
    {
        if (!ConfigHelper.TakeScreenshotOnClick())
        {
            return;
        }

        var clickLabel = string.IsNullOrWhiteSpace(label)
            ? DescribeElement(element)
            : label;

        CaptureAndAttach("click", $"點擊: {clickLabel}", window, forceDesktop: IsCommonDialog(window));
    }

    private static string CaptureToFile(string category, string reportTitle, Window? window, bool forceDesktop = false)
    {
        _sequence++;
        var dir = Path.Combine(TestContext.CurrentContext.WorkDirectory, ConfigHelper.GetScreenshotDirectory());
        Directory.CreateDirectory(dir);

        var fileName = $"{_scenarioKey}_{_sequence:D3}_{category}_{Sanitize(reportTitle)}_{DateTime.Now:HHmmssfff}.png";
        var path = Path.Combine(dir, fileName);

        ScreenshotHelper.CaptureToFile(path, window, forceDesktop);
        HtmlReportHelper.AttachScreenshot(path, reportTitle);
        TestResultReportBuilder.AddOperation(reportTitle, path);
        return path;
    }

    public static void CaptureScenarioComplete(Window? window = null)
    {
        if (!ConfigHelper.TakeScreenshotOnScenarioEnd())
        {
            return;
        }

        var path = CaptureToFile("complete", "測試完成", window);
        TestResultReportBuilder.AddFinalScreenshot("測試完成", path);
    }

    public static void CaptureStepEnd(Window? window = null)
    {
        if (!ConfigHelper.TakeScreenshotOnClick())
        {
            return;
        }

        CaptureToFile("step-end", "步驟完成", window);
    }

    public static void CaptureAction(string label, Window? window = null)
    {
        if (!ConfigHelper.TakeScreenshotOnClick())
        {
            return;
        }

        CaptureToFile("action", label, window, forceDesktop: IsCommonDialog(window));
    }

    public static string DescribeElement(AutomationElement? element)
    {
        if (element == null)
        {
            return "element";
        }

        try
        {
            var name = element.Properties.Name.ValueOrDefault;
            if (!string.IsNullOrWhiteSpace(name))
            {
                return name;
            }
        }
        catch
        {
            // ignore
        }

        try
        {
            var automationId = element.Properties.AutomationId.ValueOrDefault;
            if (!string.IsNullOrWhiteSpace(automationId))
            {
                return automationId;
            }
        }
        catch
        {
            // ignore
        }

        try
        {
            return element.ControlType.ToString();
        }
        catch
        {
            return "element";
        }
    }

    private static void CaptureAndAttach(string category, string reportTitle, Window? window, bool forceDesktop = false)
    {
        try
        {
            CaptureToFile(category, reportTitle, window, forceDesktop);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"截圖失敗 ({reportTitle}): {ex.Message}");
        }
    }

    private static string Sanitize(string name)
    {
        if (string.IsNullOrWhiteSpace(name))
        {
            return "unknown";
        }

        foreach (var c in Path.GetInvalidFileNameChars())
        {
            name = name.Replace(c, '_');
        }

        name = name.Replace(':', '_').Replace(' ', '_');
        return name.Length > 60 ? name[..60] : name;
    }

    private static bool IsCommonDialog(Window? window)
    {
        if (window == null)
        {
            return false;
        }

        try
        {
            return string.Equals(window.ClassName, "#32770", StringComparison.OrdinalIgnoreCase);
        }
        catch
        {
            return true;
        }
    }
}
