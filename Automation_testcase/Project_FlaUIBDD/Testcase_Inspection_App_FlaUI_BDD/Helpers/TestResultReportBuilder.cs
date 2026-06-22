using System.Net;
using System.Text;

namespace Inspection_AppTests.Helpers;

/// <summary>步驟級 HTML 報告：每個 TestCase 含操作步驟與對應截圖。</summary>
public static class TestResultReportBuilder
{
    private static readonly object Lock = new();
    private static string _reportDirectory = string.Empty;
    private static string _featureName = "Semi Inspection Desktop 測試";
    private static string _featureDescription = string.Empty;
    private static DateTime _runStartedAt = DateTime.Now;

    private static readonly List<ScenarioRecord> Scenarios = new();
    private static ScenarioRecord? _currentScenario;
    private static StepRecord? _currentStep;

    public static string ReportFileName { get; set; } = "TestResultReport.html";

    public static void Initialize(string reportDirectory)
    {
        lock (Lock)
        {
            _reportDirectory = reportDirectory;
            Directory.CreateDirectory(reportDirectory);
            Scenarios.Clear();
            _currentScenario = null;
            _currentStep = null;
            _runStartedAt = DateTime.Now;
        }
    }

    public static void SetFeature(string featureName, string description = "")
    {
        lock (Lock)
        {
            _featureName = featureName;
            _featureDescription = description ?? string.Empty;
        }
    }

    public static void BeginScenario(string title, string tags = "")
    {
        lock (Lock)
        {
            _currentScenario = new ScenarioRecord
            {
                Title = title,
                Tags = tags,
                StartedAt = DateTime.Now,
            };
            Scenarios.Add(_currentScenario);
            _currentStep = null;
        }
    }

    public static void BeginStep(string stepType, string stepText)
    {
        lock (Lock)
        {
            if (_currentScenario == null)
            {
                BeginScenario("Unknown Scenario");
            }

            _currentStep = new StepRecord
            {
                Index = _currentScenario!.Steps.Count + 1,
                StepType = stepType,
                StepText = stepText,
                StartedAt = DateTime.Now,
            };
            _currentScenario.Steps.Add(_currentStep);
        }
    }

    public static void AddOperation(string actionTitle, string? screenshotPath = null)
    {
        lock (Lock)
        {
            if (_currentStep == null)
            {
                return;
            }

            _currentStep.Operations.Add(new OperationRecord
            {
                Title = actionTitle,
                CapturedAt = DateTime.Now,
                ScreenshotBase64 = LoadScreenshotBase64(screenshotPath),
            });
        }
    }

    public static void EndStep(bool passed, string? errorMessage = null)
    {
        lock (Lock)
        {
            if (_currentStep == null)
            {
                return;
            }

            _currentStep.Passed = passed;
            _currentStep.ErrorMessage = errorMessage;
            _currentStep.EndedAt = DateTime.Now;
            _currentStep = null;
        }
    }

    public static void EndScenario(bool passed, string? errorMessage = null)
    {
        lock (Lock)
        {
            if (_currentScenario == null)
            {
                return;
            }

            _currentScenario.Passed = passed;
            _currentScenario.ErrorMessage = errorMessage;
            _currentScenario.EndedAt = DateTime.Now;
            _currentScenario = null;
            _currentStep = null;
        }
    }

    public static void AddFinalScreenshot(string title, string? screenshotPath)
    {
        lock (Lock)
        {
            if (_currentScenario == null)
            {
                return;
            }

            var final = new StepRecord
            {
                Index = _currentScenario.Steps.Count + 1,
                StepType = "Result",
                StepText = title,
                Passed = _currentScenario.Passed,
                StartedAt = DateTime.Now,
                EndedAt = DateTime.Now,
            };
            final.Operations.Add(new OperationRecord
            {
                Title = title,
                CapturedAt = DateTime.Now,
                ScreenshotBase64 = LoadScreenshotBase64(screenshotPath),
            });
            _currentScenario.Steps.Add(final);
        }
    }

    public static void Flush()
    {
        lock (Lock)
        {
            if (string.IsNullOrWhiteSpace(_reportDirectory))
            {
                return;
            }

            var reportPath = Path.Combine(_reportDirectory, ReportFileName);
            File.WriteAllText(reportPath, BuildHtml(), Encoding.UTF8);
            Console.WriteLine($"TestResult 報告已產生: {reportPath}");
        }
    }

    public static string GetReportPath() => Path.Combine(_reportDirectory, ReportFileName);

    private static string? LoadScreenshotBase64(string? screenshotPath)
    {
        if (string.IsNullOrWhiteSpace(screenshotPath) || !File.Exists(screenshotPath))
        {
            return null;
        }

        try
        {
            return Convert.ToBase64String(File.ReadAllBytes(screenshotPath));
        }
        catch
        {
            return null;
        }
    }

    private static string BuildHtml()
    {
        var passed = Scenarios.Count(s => s.Passed);
        var failed = Scenarios.Count - passed;
        var finishedAt = DateTime.Now;

        var sb = new StringBuilder();
        sb.AppendLine("<!DOCTYPE html>");
        sb.AppendLine("<html lang=\"zh-Hant\">");
        sb.AppendLine("<head>");
        sb.AppendLine("  <meta charset=\"utf-8\" />");
        sb.AppendLine("  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />");
        sb.AppendLine($"  <title>{Encode(_featureName)} - Test Result</title>");
        sb.AppendLine("  <style>");
        sb.AppendLine(GetStyles());
        sb.AppendLine("  </style>");
        sb.AppendLine("</head>");
        sb.AppendLine("<body>");

        sb.AppendLine("  <header class=\"report-header\">");
        sb.AppendLine($"    <h1>{Encode(_featureName)}</h1>");
        sb.AppendLine("    <p class=\"subtitle\">FlaUI BDD 測試結果報告 · 含步驟截圖</p>");
        if (!string.IsNullOrWhiteSpace(_featureDescription))
        {
            sb.AppendLine($"    <p class=\"feature-desc\">{Encode(_featureDescription)}</p>");
        }
        sb.AppendLine($"    <p class=\"meta\">執行時間：{_runStartedAt:yyyy-MM-dd HH:mm:ss} ~ {finishedAt:yyyy-MM-dd HH:mm:ss}</p>");
        sb.AppendLine("  </header>");

        sb.AppendLine("  <section class=\"summary\">");
        sb.AppendLine($"    <div class=\"summary-card total\"><span class=\"num\">{Scenarios.Count}</span><span class=\"label\">Test Cases</span></div>");
        sb.AppendLine($"    <div class=\"summary-card pass\"><span class=\"num\">{passed}</span><span class=\"label\">Passed</span></div>");
        sb.AppendLine($"    <div class=\"summary-card fail\"><span class=\"num\">{failed}</span><span class=\"label\">Failed</span></div>");
        sb.AppendLine($"    <div class=\"summary-card time\"><span class=\"num\">{(finishedAt - _runStartedAt).TotalSeconds:F0}s</span><span class=\"label\">Duration</span></div>");
        sb.AppendLine("  </section>");

        AppendGuideSection(sb);

        sb.AppendLine("  <main class=\"test-list\">");
        for (var i = 0; i < Scenarios.Count; i++)
        {
            AppendScenario(sb, Scenarios[i], i + 1);
        }
        sb.AppendLine("  </main>");

        sb.AppendLine("  <div id=\"lightbox\" onclick=\"this.classList.remove('open')\">");
        sb.AppendLine("    <span class=\"close\">&times;</span>");
        sb.AppendLine("    <img id=\"lightbox-img\" src=\"\" alt=\"screenshot\" />");
        sb.AppendLine("  </div>");
        sb.AppendLine("  <script>");
        sb.AppendLine("    function openShot(link) {");
        sb.AppendLine("      var img = link.querySelector('img');");
        sb.AppendLine("      document.getElementById('lightbox-img').src = img.src;");
        sb.AppendLine("      document.getElementById('lightbox').classList.add('open');");
        sb.AppendLine("    }");
        sb.AppendLine("  </script>");

        sb.AppendLine("</body></html>");
        return sb.ToString();
    }

    private static void AppendGuideSection(StringBuilder sb)
    {
        sb.AppendLine("  <section class=\"report-guide\">");
        sb.AppendLine("    <h2 class=\"guide-heading\">測試說明</h2>");
        sb.AppendLine("    <div class=\"guide-grid\">");

        sb.AppendLine("      <article class=\"guide-card\">");
        sb.AppendLine("        <h3>測試注意事項</h3>");
        sb.AppendLine("        <ul>");
        sb.AppendLine("          <li>執行前請先跑 <code>build_semi.bat</code> 建置被測 WinForms，並確認 <code>Recipe_data</code> 含樣本 JSON 與 TC07 無效檔。</li>");
        sb.AppendLine("          <li>路徑由 <code>App.config</code> 或 <code>setup_env.bat</code> 注入；勿在 Step 內硬編 EXE / 資料夾路徑。</li>");
        sb.AppendLine("          <li>每個 Scenario 會啟動（或重啟）獨立 <code>SemiInspectionDesktop</code> 程序；測試進行中請勿以滑鼠/鍵盤操作被測視窗。</li>");
        sb.AppendLine("          <li>TC01 使用 <code>@DDT</code>，Examples 共 3 列，每列會完整重跑匯入流程；篩選：<code>--filter \"Category=DDT\"</code>。</li>");
        sb.AppendLine("          <li>失敗時優先查看本報告步驟截圖，或 <code>Screenshots/</code> 目錄中同時間戳 PNG。</li>");
        sb.AppendLine("        </ul>");
        sb.AppendLine("      </article>");

        sb.AppendLine("      <article class=\"guide-card\">");
        sb.AppendLine("        <h3>已知瓶頸</h3>");
        sb.AppendLine("        <ul>");
        sb.AppendLine("          <li><strong>FileDialog（#32770）</strong>：IME 中文環境下檔名欄位 UIA 可能不穩，已實作剪貼簿 + Alt+N fallback；仍偶發找不到對話框（TC01）。</li>");
        sb.AppendLine("          <li><strong>RawData 表格</strong>：<code>dataGridParameters</code> UIA 列舉較慢，切換 RawData 後需等待載入。</li>");
        sb.AppendLine("          <li><strong>檔案樹</strong>：<code>treeFiles</code> / SysTreeView32 在不同 Windows 版本 UIA 深度不一，雙擊前需確認節點可見。</li>");
        sb.AppendLine("          <li><strong>Defect Chart</strong>：繪圖後需約 1～2 秒穩定時間；無 Recipe 時僅驗證主視窗未當掉（TC08）。</li>");
        sb.AppendLine("          <li><strong>執行時間</strong>：10 TC 含 DDT 展開約 2～3 分鐘；不建議平行執行（程序啟動/關閉競爭）。</li>");
        sb.AppendLine("        </ul>");
        sb.AppendLine("      </article>");

        sb.AppendLine("      <article class=\"guide-card\">");
        sb.AppendLine("        <h3>BDD 與 DDT 解說</h3>");
        sb.AppendLine("        <p><strong>BDD（Behavior-Driven Development）</strong>：以 Gherkin 描述行為（Given / When / Then），<code>Inspection_App.feature</code> 對應 TC01～TC10；StepDefinitions 只做編排與 Assert，FlaUI 操作在 Page Object。</p>");
        sb.AppendLine("        <p><strong>DDT（Data-Driven Testing）</strong>：同一流程以多組資料重複驗證。SpecFlow 使用 <code>Scenario Outline</code> + <code>Examples</code>；步驟中的 <code>&lt;placeholder&gt;</code> 對應表格欄位。</p>");
        sb.AppendLine("        <pre class=\"guide-code\">@Functional @Import @DDT");
        sb.AppendLine("Scenario Outline: TC01 - Import Recipe to Recipe_data");
        sb.AppendLine("  ...");
        sb.AppendLine("  And the RawData parameter table should contain \"&lt;expected_parameter&gt;\"");
        sb.AppendLine("");
        sb.AppendLine("  Examples:");
        sb.AppendLine("    | recipe_file                  | expected_parameter   |");
        sb.AppendLine("    | InspectionRecipe_Sample.json | Layer1_AOI_Recipe_v1 |");
        sb.AppendLine("    | InspectionRecipe_Sample.json | W-20260605-001     |");
        sb.AppendLine("    | InspectionRecipe_Sample.json | Brightfield        |</pre>");
        sb.AppendLine("        <p class=\"guide-note\">規則：一 TC 一 Scenario 或 Outline；DDT 加 <code>@DDT</code> 標籤。詳見 <code>Automation_testcase/TPS_BDD_skill.md</code>。</p>");
        sb.AppendLine("      </article>");

        sb.AppendLine("    </div>");
        sb.AppendLine("  </section>");
    }

    private static void AppendScenario(StringBuilder sb, ScenarioRecord scenario, int caseIndex)
    {
        var statusClass = scenario.Passed ? "pass" : "fail";
        var statusText = scenario.Passed ? "PASSED" : "FAILED";
        var duration = (scenario.EndedAt - scenario.StartedAt).TotalSeconds;
        var anchor = $"tc-{caseIndex}";

        sb.AppendLine($"  <article class=\"testcase open {statusClass}\" id=\"{anchor}\">");
        sb.AppendLine("    <div class=\"tc-header\" onclick=\"this.parentElement.classList.toggle('open')\">");
        sb.AppendLine($"      <span class=\"tc-index\">TC{caseIndex:D2}</span>");
        sb.AppendLine($"      <span class=\"tc-title\">{Encode(scenario.Title)}</span>");
        sb.AppendLine($"      <span class=\"tc-status {statusClass}\">{statusText}</span>");
        sb.AppendLine($"      <span class=\"tc-duration\">{duration:F1}s</span>");
        sb.AppendLine("      <span class=\"tc-toggle\">▼</span>");
        sb.AppendLine("    </div>");

        if (!string.IsNullOrWhiteSpace(scenario.Tags))
        {
            sb.AppendLine($"    <div class=\"tc-tags\">Tags: {Encode(scenario.Tags)}</div>");
        }

        if (!scenario.Passed && !string.IsNullOrWhiteSpace(scenario.ErrorMessage))
        {
            sb.AppendLine($"    <div class=\"tc-error\">{Encode(scenario.ErrorMessage)}</div>");
        }

        sb.AppendLine("    <div class=\"tc-body\">");
        sb.AppendLine("      <table class=\"steps-table\">");
        sb.AppendLine("        <thead><tr><th>#</th><th>操作步驟</th><th>狀態</th><th>時間</th></tr></thead>");
        sb.AppendLine("        <tbody>");

        foreach (var step in scenario.Steps)
        {
            AppendStep(sb, step);
        }

        sb.AppendLine("        </tbody>");
        sb.AppendLine("      </table>");
        sb.AppendLine("    </div>");
        sb.AppendLine("  </article>");
    }

    private static void AppendStep(StringBuilder sb, StepRecord step)
    {
        var statusClass = step.Passed ? "pass" : "fail";
        var statusText = step.Passed ? "Pass" : "Fail";
        var stepLabel = $"{step.StepType} {step.StepText}".Trim();
        var durationMs = (step.EndedAt - step.StartedAt).TotalMilliseconds;

        sb.AppendLine("          <tr class=\"step-row\">");
        sb.AppendLine($"            <td class=\"step-no\">{step.Index}</td>");
        sb.AppendLine($"            <td class=\"step-name\">{Encode(stepLabel)}</td>");
        sb.AppendLine($"            <td class=\"step-status {statusClass}\">{statusText}</td>");
        sb.AppendLine($"            <td class=\"step-time\">{durationMs:F0} ms</td>");
        sb.AppendLine("          </tr>");

        if (!step.Passed && !string.IsNullOrWhiteSpace(step.ErrorMessage))
        {
            sb.AppendLine("          <tr class=\"step-error-row\">");
            sb.AppendLine($"            <td></td><td colspan=\"3\" class=\"step-error\">{Encode(step.ErrorMessage)}</td>");
            sb.AppendLine("          </tr>");
        }

        if (step.Operations.Count == 0)
        {
            return;
        }

        sb.AppendLine("          <tr class=\"step-ops-row\">");
        sb.AppendLine("            <td></td>");
        sb.AppendLine("            <td colspan=\"3\" class=\"step-ops\">");

        for (var i = 0; i < step.Operations.Count; i++)
        {
            var op = step.Operations[i];
            sb.AppendLine($"              <div class=\"operation\">");
            sb.AppendLine($"                <div class=\"op-title\"><span class=\"op-badge\">操作 {step.Index}.{i + 1}</span> {Encode(op.Title)} <span class=\"op-time\">{op.CapturedAt:HH:mm:ss.fff}</span></div>");
            if (!string.IsNullOrEmpty(op.ScreenshotBase64))
            {
                sb.AppendLine($"                <a class=\"shot-link\" href=\"#\" onclick=\"openShot(this);return false;\">");
                sb.AppendLine($"                  <img class=\"shot-thumb\" src=\"data:image/png;base64,{op.ScreenshotBase64}\" alt=\"{Encode(op.Title)}\" />");
                sb.AppendLine("                </a>");
            }
            else
            {
                sb.AppendLine("                <div class=\"no-shot\">（無截圖）</div>");
            }
            sb.AppendLine("              </div>");
        }

        sb.AppendLine("            </td>");
        sb.AppendLine("          </tr>");
    }

    private static string Encode(string? text) => WebUtility.HtmlEncode(text ?? string.Empty);

    private static string GetStyles() => """
        * { box-sizing: border-box; }
        body { margin: 0; font-family: "Segoe UI", "Microsoft JhengHei", sans-serif; background: #eef2f7; color: #1f2937; }
        .report-header { background: linear-gradient(135deg, #1e3a5f, #2563eb); color: #fff; padding: 24px 32px; }
        .report-header h1 { margin: 0 0 8px; font-size: 1.6rem; }
        .subtitle, .feature-desc, .meta { margin: 4px 0; opacity: 0.92; }
        .summary { display: flex; gap: 16px; padding: 20px 32px; flex-wrap: wrap; }
        .summary-card { background: #fff; border-radius: 10px; padding: 16px 24px; min-width: 120px; box-shadow: 0 2px 8px rgba(0,0,0,.08); text-align: center; }
        .summary-card .num { display: block; font-size: 1.8rem; font-weight: 700; }
        .summary-card.pass .num { color: #16a34a; }
        .summary-card.fail .num { color: #dc2626; }
        .summary-card.time .num { color: #2563eb; font-size: 1.4rem; }
        .summary-card .label { font-size: .85rem; color: #64748b; }
        .report-guide { padding: 0 32px 24px; }
        .guide-heading { margin: 0 0 16px; font-size: 1.15rem; color: #1e3a5f; }
        .guide-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px; }
        .guide-card { background: #fff; border-radius: 10px; padding: 18px 20px; box-shadow: 0 2px 8px rgba(0,0,0,.06); border-top: 4px solid #2563eb; }
        .guide-card h3 { margin: 0 0 12px; font-size: 1rem; color: #1e40af; }
        .guide-card ul { margin: 0; padding-left: 1.2rem; font-size: .88rem; line-height: 1.55; color: #334155; }
        .guide-card li { margin-bottom: 8px; }
        .guide-card li:last-child { margin-bottom: 0; }
        .guide-card p { margin: 0 0 10px; font-size: .88rem; line-height: 1.55; color: #334155; }
        .guide-card p:last-child { margin-bottom: 0; }
        .guide-card code { background: #f1f5f9; padding: 1px 5px; border-radius: 4px; font-size: .82rem; }
        .guide-code { margin: 10px 0; padding: 12px; background: #0f172a; color: #e2e8f0; border-radius: 8px; font-size: .78rem; line-height: 1.45; overflow-x: auto; white-space: pre-wrap; }
        .guide-note { font-size: .82rem !important; color: #64748b !important; }
        .test-list { padding: 0 32px 40px; }
        .testcase { background: #fff; border-radius: 10px; margin-bottom: 16px; box-shadow: 0 2px 8px rgba(0,0,0,.06); overflow: hidden; border-left: 5px solid #94a3b8; }
        .testcase.pass { border-left-color: #16a34a; }
        .testcase.fail { border-left-color: #dc2626; }
        .tc-header { display: flex; align-items: center; gap: 12px; padding: 14px 18px; cursor: pointer; background: #f8fafc; user-select: none; }
        .tc-header:hover { background: #f1f5f9; }
        .tc-index { font-weight: 700; color: #2563eb; min-width: 48px; }
        .tc-title { flex: 1; font-weight: 600; }
        .tc-status { font-size: .75rem; font-weight: 700; padding: 4px 10px; border-radius: 999px; }
        .tc-status.pass { background: #dcfce7; color: #166534; }
        .tc-status.fail { background: #fee2e2; color: #991b1b; }
        .tc-duration { color: #64748b; font-size: .85rem; }
        .tc-toggle { color: #64748b; transition: transform .2s; }
        .testcase.open .tc-toggle { transform: rotate(180deg); }
        .tc-tags, .tc-error { padding: 0 18px 8px; font-size: .85rem; color: #64748b; }
        .tc-error { color: #b91c1c; white-space: pre-wrap; }
        .tc-body { display: none; padding: 0 12px 16px; }
        .testcase.open .tc-body { display: block; }
        .steps-table { width: 100%; border-collapse: collapse; font-size: .9rem; }
        .steps-table th { text-align: left; background: #e2e8f0; padding: 8px 10px; }
        .steps-table td { padding: 8px 10px; vertical-align: top; border-bottom: 1px solid #e2e8f0; }
        .step-no { width: 40px; font-weight: 700; color: #475569; }
        .step-status.pass { color: #16a34a; font-weight: 600; }
        .step-status.fail { color: #dc2626; font-weight: 600; }
        .step-time { width: 90px; color: #64748b; white-space: nowrap; }
        .step-error { color: #b91c1c; white-space: pre-wrap; font-size: .85rem; }
        .step-ops { background: #fafbfc; }
        .operation { margin-bottom: 16px; padding-bottom: 12px; border-bottom: 1px dashed #cbd5e1; }
        .operation:last-child { border-bottom: none; margin-bottom: 0; }
        .op-title { margin-bottom: 8px; font-size: .88rem; }
        .op-badge { display: inline-block; background: #dbeafe; color: #1d4ed8; font-size: .75rem; font-weight: 700; padding: 2px 8px; border-radius: 4px; margin-right: 6px; }
        .op-time { color: #94a3b8; font-size: .78rem; margin-left: 8px; }
        .shot-thumb { max-width: 100%; width: 720px; border: 1px solid #cbd5e1; border-radius: 6px; box-shadow: 0 2px 6px rgba(0,0,0,.1); cursor: zoom-in; }
        .no-shot { color: #94a3b8; font-size: .85rem; font-style: italic; }
        #lightbox { display: none; position: fixed; inset: 0; background: rgba(0,0,0,.85); z-index: 9999; align-items: center; justify-content: center; padding: 24px; }
        #lightbox.open { display: flex; }
        #lightbox img { max-width: 95vw; max-height: 95vh; border-radius: 8px; }
        #lightbox .close { position: absolute; top: 16px; right: 24px; color: #fff; font-size: 2rem; cursor: pointer; }
        """;

    private sealed class ScenarioRecord
    {
        public string Title { get; set; } = string.Empty;
        public string Tags { get; set; } = string.Empty;
        public bool Passed { get; set; } = true;
        public string? ErrorMessage { get; set; }
        public DateTime StartedAt { get; set; }
        public DateTime EndedAt { get; set; }
        public List<StepRecord> Steps { get; } = new();
    }

    private sealed class StepRecord
    {
        public int Index { get; set; }
        public string StepType { get; set; } = string.Empty;
        public string StepText { get; set; } = string.Empty;
        public bool Passed { get; set; } = true;
        public string? ErrorMessage { get; set; }
        public DateTime StartedAt { get; set; }
        public DateTime EndedAt { get; set; }
        public List<OperationRecord> Operations { get; } = new();
    }

    private sealed class OperationRecord
    {
        public string Title { get; set; } = string.Empty;
        public DateTime CapturedAt { get; set; }
        public string? ScreenshotBase64 { get; set; }
    }
}
