using Demo2DesktopTests.Helpers;
using Demo2DesktopTests.Hooks;
using Demo2DesktopTests.PageObjects;
using FlaUI.Core.WindowsAPI;
using NUnit.Framework;
using NUnit.Framework.Legacy;
using TechTalk.SpecFlow;

namespace Demo2DesktopTests.StepDefinitions;

[Binding]
public class Demo2DesktopSteps
{
    private readonly ScenarioContext _scenarioContext;

    public Demo2DesktopSteps(ScenarioContext scenarioContext)
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

    [When(@"I select sample InspectionRecipe_Sample\.json in the file dialog")]
    public void WhenISelectSampleInspectionRecipeInFileDialog()
    {
        FileDialog.OpenFile(ConfigHelper.GetSampleRecipePath());
        Workspace.WaitAfterDataTableAction();
    }

    [When(@"I select invalid file _invalid_sample\.txt in the file dialog")]
    public void WhenISelectInvalidFileInFileDialog()
    {
        FileDialog.OpenFile(ConfigHelper.GetInvalidSamplePath());
    }

    [When(@"I double-click InspectionRecipe_Sample\.json in the file tree")]
    public void WhenIDoubleClickInspectionRecipeInFileTree()
    {
        Workspace.DoubleClickTreeItem("InspectionRecipe_Sample.json");
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

    [When(@"I open RawData via shortcut and select missing file not_exist_99999\.json")]
    public void WhenIOpenRawDataViaShortcutAndSelectMissingFile()
    {
        Main.SendParametersShortcut();
        Thread.Sleep(500);
        var missing = Path.Combine(ConfigHelper.GetRecipeDataDirectory(), "not_exist_99999.json");
        try
        {
            FileDialog.OpenFile(missing, requireFileExists: false);
            MessageBox.ClickOk();
        }
        catch
        {
        }
    }

    [Then(@"Recipe_data should contain InspectionRecipe_Sample\.json")]
    public void ThenRecipeDataShouldContainInspectionRecipeSampleJson()
    {
        ClassicAssert.IsTrue(
            File.Exists(ConfigHelper.GetSampleRecipePath()),
            "Recipe_data should contain InspectionRecipe_Sample.json");
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
