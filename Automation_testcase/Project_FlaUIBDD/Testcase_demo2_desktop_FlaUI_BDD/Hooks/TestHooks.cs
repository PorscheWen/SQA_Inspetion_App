using System.Diagnostics;
using Demo2DesktopTests.Helpers;
using Demo2DesktopTests.PageObjects;
using FlaUI.Core;
using FlaUI.Core.AutomationElements;
using FlaUI.Core.Definitions;
using FlaUI.Core.Tools;
using FlaUI.UIA3;
using NUnit.Framework;
using TechTalk.SpecFlow;

namespace Demo2DesktopTests.Hooks;

[Binding]
public class TestHooks
{
    private static UIA3Automation? _automation;
    private static FlaUI.Core.Application? _application;
    private static Window? _mainWindow;
    private readonly ScenarioContext _scenarioContext;

    public TestHooks(ScenarioContext scenarioContext)
    {
        _scenarioContext = scenarioContext;
    }

    [BeforeTestRun]
    public static void BeforeTestRun()
    {
        _automation = new UIA3Automation();
        var reportsDir = Path.Combine(TestContext.CurrentContext.WorkDirectory, "reports");
        HtmlReportHelper.InitializeReport(reportsDir, "SemiInspectionTestReport.html");
        TestResultReportBuilder.Initialize(reportsDir);
    }

    [BeforeFeature]
    public static void BeforeFeature(FeatureContext featureContext)
    {
        HtmlReportHelper.CreateFeature(featureContext.FeatureInfo.Title, featureContext.FeatureInfo.Description ?? "");
        TestResultReportBuilder.SetFeature(
            featureContext.FeatureInfo.Title,
            featureContext.FeatureInfo.Description ?? string.Empty);
    }

    [BeforeScenario]
    public void BeforeScenario()
    {
        var title = _scenarioContext.ScenarioInfo.Title;
        var tags = string.Join(", ", _scenarioContext.ScenarioInfo.Tags);
        HtmlReportHelper.CreateScenario(title, tags);
        TestResultReportBuilder.BeginScenario(title, tags);
        ActionScreenshotHelper.ResetForScenario(title);
        if (_scenarioContext.ScenarioInfo.Tags.Length > 0)
        {
            HtmlReportHelper.AssignCategory(_scenarioContext.ScenarioInfo.Tags);
        }

        LaunchApplication();
        Thread.Sleep(2500);

        _mainWindow = WaitForMainWindow();
        if (_mainWindow == null)
        {
            throw new InvalidOperationException("無法取得 Semi Inspection 主視窗");
        }

        _mainWindow.Focus();

        _scenarioContext.Set(_mainWindow, "MainWindow");
        _scenarioContext.Set(new MainWindowPage(_mainWindow, _automation!), "MainWindowPage");
        _scenarioContext.Set(new WorkspacePage(_mainWindow, _automation!), "WorkspacePage");
        var fileDialog = new FileDialogPage(_automation!, _mainWindow);
        _scenarioContext.Set(fileDialog, "FileDialogPage");
        _scenarioContext.Set(new MessageBoxPage(_automation!), "MessageBoxPage");
    }

    [BeforeStep]
    public void BeforeStep()
    {
        var stepInfo = _scenarioContext.StepContext?.StepInfo;
        if (stepInfo == null)
        {
            return;
        }

        var stepLabel = $"{stepInfo.StepDefinitionType} {stepInfo.Text}";
        HtmlReportHelper.StartStep(stepLabel);
        TestResultReportBuilder.BeginStep(stepInfo.StepDefinitionType.ToString(), stepInfo.Text);
    }

    [AfterStep]
    public void AfterStep()
    {
        var stepInfo = _scenarioContext.StepContext?.StepInfo;
        if (stepInfo == null)
        {
            return;
        }

        ActionScreenshotHelper.CaptureStepEnd(_mainWindow);

        var stepText = $"{stepInfo.StepDefinitionType} {stepInfo.Text}";
        if (_scenarioContext.TestError != null)
        {
            var message = stepText + "\n錯誤: " + _scenarioContext.TestError.Message
                + "\n" + (_scenarioContext.TestError.StackTrace ?? string.Empty);
            HtmlReportHelper.EndStepFail(message);
            TestResultReportBuilder.EndStep(false, _scenarioContext.TestError.Message);
        }
        else
        {
            HtmlReportHelper.EndStepPass(stepText);
            TestResultReportBuilder.EndStep(true);
        }
    }

    [AfterScenario]
    public void AfterScenario()
    {
        try
        {
            ActionScreenshotHelper.CaptureScenarioComplete(_mainWindow);
            var passed = _scenarioContext.TestError == null;
            TestResultReportBuilder.EndScenario(
                passed,
                passed ? null : _scenarioContext.TestError?.Message);
        }
        catch (Exception ex)
        {
            Console.WriteLine("測試完成截圖失敗: " + ex.Message);
            TestResultReportBuilder.EndScenario(false, ex.Message);
        }
        finally
        {
            CloseApplication();
        }
    }

    [AfterTestRun]
    public static void AfterTestRun()
    {
        HtmlReportHelper.FlushReport();
        TestResultReportBuilder.Flush();
        _automation?.Dispose();
    }

    public static void LaunchApplication()
    {
        var exe = ConfigHelper.GetApplicationPath();
        if (!File.Exists(exe))
        {
            throw new FileNotFoundException("SemiInspectionDesktop.exe not found: " + exe);
        }

        var processName = ConfigHelper.GetProcessName();
        var existing = Process.GetProcessesByName(processName);
        if (existing.Length > 0)
        {
            _application = FlaUI.Core.Application.Attach(existing[0]);
            return;
        }

        _application = FlaUI.Core.Application.Launch(exe);
    }

    public static void CloseApplication()
    {
        DialogHelper.DismissOpenDialogs(_automation);

        try
        {
            _mainWindow?.Close();
        }
        catch
        {
            // ignore
        }

        try
        {
            _application?.Close();
        }
        catch
        {
            // ignore
        }

        _application?.Dispose();
        _application = null;
        _mainWindow = null;

        var processName = ConfigHelper.GetProcessName();
        foreach (var p in Process.GetProcessesByName(processName))
        {
            try
            {
                p.Kill();
                p.WaitForExit(3000);
            }
            catch
            {
                // ignore
            }
        }
    }

    public static void RelaunchApplication()
    {
        CloseApplication();
        Thread.Sleep(1000);
        LaunchApplication();
        Thread.Sleep(1500);
        _mainWindow = WaitForMainWindow();
        if (_mainWindow == null)
        {
            throw new InvalidOperationException("重新啟動後無法取得主視窗");
        }

        _mainWindow.Focus();
    }

    public static void BindPagesToScenario(ScenarioContext scenarioContext)
    {
        if (_mainWindow == null || _automation == null)
        {
            throw new InvalidOperationException("主視窗尚未就緒");
        }

        scenarioContext.Set(_mainWindow, "MainWindow");
        scenarioContext.Set(new MainWindowPage(_mainWindow, _automation), "MainWindowPage");
        scenarioContext.Set(new WorkspacePage(_mainWindow, _automation), "WorkspacePage");
        scenarioContext.Set(new FileDialogPage(_automation, _mainWindow), "FileDialogPage");
        scenarioContext.Set(new MessageBoxPage(_automation), "MessageBoxPage");
    }

    private static Window? WaitForMainWindow()
    {
        var title = ConfigHelper.GetApplicationTitle();
        var timeout = TimeSpan.FromMilliseconds(ConfigHelper.GetDefaultTimeout());

        var perAttempt = TimeSpan.FromSeconds(2);
        return Retry.WhileNull(
            () =>
            {
                if (_application != null)
                {
                    try
                    {
                        var win = _application.GetMainWindow(_automation!, perAttempt);
                        if (win != null && win.Title.Contains(title, StringComparison.OrdinalIgnoreCase))
                        {
                            return win;
                        }
                    }
                    catch
                    {
                        // ignore single attempt timeout
                    }
                }

                try
                {
                    var desktop = _automation!.GetDesktop();
                    foreach (var w in desktop.FindAllChildren(cf => cf.ByControlType(ControlType.Window)))
                    {
                        var window = w.AsWindow();
                        if (window?.Title.Contains(title, StringComparison.OrdinalIgnoreCase) == true)
                        {
                            return window;
                        }
                    }
                }
                catch
                {
                    // ignore
                }

                return null;
            },
            timeout).Result;
    }
}
