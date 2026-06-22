using Inspection_AppTests.Helpers;
using Inspection_AppTests.Hooks;
using Inspection_AppTests.PageObjects;
using FlaUI.Core.WindowsAPI;
using NUnit.Framework;
using NUnit.Framework.Legacy;
using TechTalk.SpecFlow;

namespace Inspection_AppTests.StepDefinitions;

[Binding]
public class Inspection_AppSteps
{
    private readonly ScenarioContext _scenarioContext;

    public Inspection_AppSteps(ScenarioContext scenarioContext)
    {
        _scenarioContext = scenarioContext;
    }

    private MainWindowPage Main => _scenarioContext.Get<MainWindowPage>("MainWindowPage");
    private WorkspacePage Workspace => _scenarioContext.Get<WorkspacePage>("WorkspacePage");
    private FileDialogPage FileDialog => _scenarioContext.Get<FileDialogPage>("FileDialogPage");
    private MessageBoxPage MessageBox => _scenarioContext.Get<MessageBoxPage>("MessageBoxPage");

    [Given(@"test data is ready")]
    public void GivenTestDataIsReady()
    {
        TestDataHelper.EnsureTestDataReady();
    }

    [Given(@"the application has started")]
    public void GivenTheApplicationHasStarted()
    {
        ClassicAssert.IsTrue(Main.IsMainWindowVisible(), "Main window is not visible");
        Thread.Sleep(1000);
    }

    [Given(@"the application has relaunched")]
    public void GivenTheApplicationHasRelaunched()
    {
        TestHooks.RelaunchApplication();
        TestHooks.BindPagesToScenario(_scenarioContext);
        ClassicAssert.IsTrue(Main.IsMainWindowVisible());
    }

    [When(@"I click toolbar ""(.*)""")]
    public void WhenIClickToolbar(string buttonText)
    {
        if (string.Equals(buttonText, "Run Inspection", StringComparison.OrdinalIgnoreCase))
        {
            Main.SendShortcut(VirtualKeyShort.KEY_R, ctrl: true);
            Thread.Sleep(800);
            return;
        }

        Main.ClickToolbar(buttonText);
        if (string.Equals(buttonText, "RawData", StringComparison.OrdinalIgnoreCase))
        {
            Workspace.WaitAfterDataTableAction();
        }
        else if (string.Equals(buttonText, "Defect Chart", StringComparison.OrdinalIgnoreCase))
        {
            Thread.Sleep(1500);
        }
        else
        {
            Thread.Sleep(500);
        }
    }

    [When(@"I select file ""(.*)"" in the file dialog")]
    public void WhenISelectFileInFileDialog(string fileName)
    {
        var path = Path.Combine(ConfigHelper.GetRecipeDataDirectory(), fileName);
        FileDialog.OpenFile(path);
        Workspace.WaitAfterDataTableAction();
    }

    [When(@"I select invalid file ""(.*)"" in the file dialog")]
    public void WhenISelectInvalidFileInFileDialog(string fileName)
    {
        var path = Path.Combine(ConfigHelper.GetRecipeDataDirectory(), fileName);
        FileDialog.OpenFile(path);
    }

    [When(@"I double-click (.+) in the file tree")]
    public void WhenIDoubleClickInFileTree(string fileName)
    {
        Workspace.DoubleClickTreeItem(fileName);
        if (!Workspace.IsGridVisible())
        {
            Main.ClickToolbar("RawData");
        }
    }

    [When(@"I close the message dialog")]
    [Then(@"I close the message dialog")]
    public void WhenICloseTheMessageDialog()
    {
        MessageBox.ClickOk();
    }

    [When(@"I open RawData via shortcut and select missing file ""(.*)""")]
    public void WhenIOpenRawDataViaShortcutAndSelectMissingFile(string fileName)
    {
        Main.SendParametersShortcut();
        Thread.Sleep(500);
        var missing = Path.Combine(ConfigHelper.GetRecipeDataDirectory(), fileName);
        try
        {
            FileDialog.OpenFile(missing, requireFileExists: false);
            MessageBox.ClickOk();
        }
        catch
        {
        }
    }

    [Then(@"Recipe_data should contain ""(.*)""")]
    public void ThenRecipeDataShouldContain(string fileName)
    {
        var path = Path.Combine(ConfigHelper.GetRecipeDataDirectory(), fileName);
        ClassicAssert.IsTrue(
            File.Exists(path),
            "Recipe_data should contain " + fileName);
    }

    [Then(@"the main window title should be ""(.*)""")]
    public void ThenTheMainWindowTitleShouldBe(string expected)
    {
        ClassicAssert.AreEqual(expected, Main.GetWindowTitle());
    }

    [Then(@"the file tree should be visible")]
    public void ThenTheFileTreeShouldBeVisible()
    {
        ClassicAssert.IsTrue(
            Workspace.IsTreeVisible(),
            "File Tree not visible (check treeFiles / SysTreeView32 UIA access)");
    }

    [Then(@"the data table should be visible")]
    public void ThenTheDataTableShouldBeVisible()
    {
        ClassicAssert.IsTrue(
            Workspace.IsGridVisible(),
            "DataGridView not visible (check dataGridParameters on RawData tab)");
    }

    [Then(@"the RawData view should show filename (.+)")]
    public void ThenTheRawDataViewShouldShowFilename(string fileName)
    {
        ClassicAssert.IsTrue(
            Workspace.RawDataShowsFileName(fileName),
            "RawData view does not show filename: " + fileName);
    }

    [Then(@"the RawData parameter table should contain ""(.*)""")]
    public void ThenTheRawDataParameterTableShouldContain(string expected)
    {
        ClassicAssert.IsTrue(
            Workspace.GridContainsText(expected),
            "RawData parameter table does not contain: " + expected);
    }

    [Then(@"the log should contain ""(.*)""")]
    public void ThenTheLogShouldContain(string expected)
    {
        ClassicAssert.IsTrue(
            Workspace.LogContains(expected),
            "Log does not contain: " + expected + " (check txtToolLog / lblToolPlugin)");
    }

    [Then(@"the invalid file should not be copied as TC01_import_copy\.json")]
    public void ThenTheInvalidFileShouldNotBeCopiedAsTc01ImportCopy()
    {
        ClassicAssert.IsFalse(
            TestDataHelper.ImportTargetExists(),
            "Invalid file must not be copied to TC01_import_copy.json");
    }

    [Then(@"the main window should still exist")]
    public void ThenTheMainWindowShouldStillExist()
    {
        ClassicAssert.IsTrue(Main.IsMainWindowVisible());
    }
}
