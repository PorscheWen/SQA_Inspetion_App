// AUTO-GENERATED stub from FlaUI.Cli ??do NOT use as-is in production tests.
// Move stable locators into MainWindowPage / WorkspacePage / FileDialogPage.
using FlaUI.Core.AutomationElements;
using FlaUI.Core.Definitions;

namespace Testcase_Inspection_App_FlaUI_BDD.PageObjects.Generated
{
    public class AboutPageStub
    {
        // Inject AutomationElement window from TestHooks / BasePage in real code.
        private readonly AutomationElement _window;
        public AboutPageStub(AutomationElement window) => _window = window;

        public void Click_1_About()
        {
            var el = _window.FindFirstDescendant(cf => cf.ByAutomationId("btnToolbar0About"));
            el?.Click();
        }

        public void Click_2_OK()
        {
            var el = _window.FindFirstDescendant(cf => cf.ByName("OK"));
            el?.Click();
        }

    }
}
