---
name: semi-inspection-tps-bdd
description: >-
  將 Semi Inspection Desktop 的 TPS（Gherkin 測試程序規格）落地為 FlaUI C# BDD（SpecFlow +
  Page Object），或維護既有 TC01–TC10 自動化。當使用者要 TPS 轉 BDD、新增/修改 Feature、
  SpecFlow Scenario、FlaUI Page Object、對照 TEST_PLAN / SemiInspection_10_TestCases / TPS.md、
  或提及 TPS_BDD_skill 時使用。
---

# Semi Inspection：TPS → FlaUI BDD

本 skill 適用 **`SQA_Inspetion_App`**（可獨立運行，不依賴 `SQA_AI_Automation`）。

## 適用範圍

| 項目 | 路徑（相對 `SQA_Inspetion_App/`） |
|------|-----------------------------------|
| 專案根目錄 | `.`（含 `config.json`、`build_semi.bat`） |
| Gherkin TPS | `Automation_testcase/Test_cases/TPS.md` |
| 測試計畫 | `Automation_testcase/Test_cases/TEST_PLAN.md` |
| 案例總表 | `Automation_testcase/Test_cases/SemiInspection_10_TestCases.md` |
| FlaUI BDD 專案 | `Automation_testcase/Project_FlaUIBDD/Testcase_Inspection_App_FlaUI_BDD/` |
| Feature | `.../Features/Inspection_App.feature` |
| Web 控制台 | `Automation_testcase/Project_FlaUIBDD/web_dashboard/`（port **6690**） |
| 操作說明 | `.../Testcase_Inspection_App_FlaUI_BDD/操作說明.html` |

**應用程式常數（寫入 `App.config` 或環境變數，勿硬編在 Step 內）：**

| 鍵 | 值 / 說明 |
|----|-----------|
| `ProcessName` | `SemiInspectionDesktop` |
| `ApplicationTitle` | `Semi Inspection Desktop` |
| `ApplicationPath` | `SemiInspectionDesktop\bin\Debug\SemiInspectionDesktop.exe`（**相對 APP_ROOT**） |
| `RecipeDataDirectory` | `Recipe_data` |
| `SampleRecipe` | `InspectionRecipe_Sample.json` |
| `InvalidSampleFile` | `_invalid_sample.txt` |
| `ImportTargetFile` | `TC01_import_copy.json` |

路徑解析：`Helpers/ConfigHelper.cs` 會向上尋找含 `config.json` + `build_semi.bat` 的 **APP_ROOT**；`setup_env.bat` / Web 控制台亦會注入 `ApplicationPath`、`RecipeDataDirectory`。

## 三層文件（新增或修改 TC 必同步）

1. **TEST_PLAN.md** — 目的、步驟、預期、Defect#
2. **SemiInspection_10_TestCases.md** — 總表 + 控制項 AutomationId 對照
3. **TPS.md** — Gherkin 程序規格（繁體中文）
4. **Feature + Steps + PageObject** — 可執行 BDD

**規則：** 一個 Scenario 或 **Scenario Outline** = 一個 TC；標題格式 `TCxx - 簡短描述`；標籤 `@Functional` / `@Negative` + 領域標籤（`@Import`、`@RawData`、`@Chart` 等）；使用 DDT 時加 `@DDT`。

## 執行流程（Agent 依序完成）

1. **讀取** `TPS.md`、`SemiInspection_10_TestCases.md` 中對應 TC 的 Given / When / Then。
2. **對照** `Features/Inspection_App.feature` 確認 Scenario 標題、標籤、步驟語意一致。
3. **實作或更新** StepDefinitions、PageObjects；UI 操作不放 Steps 內。
4. **設定** `App.config` 使用相對路徑；必要時更新 `setup_env.bat` 環境變數。
5. **驗證**：`build_semi.bat` → `dotnet build -c Release` → `dotnet test -c Release --filter "Name~TCxx"`。
6. **報告**：確認 `reports/TestResultReport.html`、`reports/SemiInspectionTestReport.html` 已產生。
7. **摘要**：列出需 Inspector 確認的控制項、或 FileDialog / IME 等已知限制。

## 現有專案結構

```
Automation_testcase/Project_FlaUIBDD/Testcase_Inspection_App_FlaUI_BDD/
├── Features/Inspection_App.feature
├── StepDefinitions/Inspection_AppSteps.cs
├── PageObjects/
│   ├── BasePage.cs
│   ├── MainWindowPage.cs      # 工具列、快捷鍵、About
│   ├── FileDialogPage.cs      # #32770、AutomationId 1148、剪貼簿 fallback
│   ├── MessageBoxPage.cs
│   └── WorkspacePage.cs       # treeFiles、dataGridParameters、txtToolLog
├── Hooks/TestHooks.cs
├── Helpers/
│   ├── ConfigHelper.cs
│   ├── ActionScreenshotHelper.cs
│   ├── TestResultReportBuilder.cs   # 步驟級 HTML 報告（含截圖）
│   ├── HtmlReportHelper.cs          # ExtentReports
│   ├── DialogHelper.cs
│   ├── KeyboardInputHelper.cs
│   └── ScreenshotHelper.cs
├── App.config
└── specflow.json
```

## 測試案例對照（TC01–TC10，1:1）

| TC | Scenario 標題 | 標籤 | 類別 | Defect# |
|----|---------------|------|------|---------|
| TC01 | Import Recipe 至 Recipe_data | @Functional @Import | Functional | 2001 |
| TC02 | File Tree 顯示 Recipe_data | @Functional @FileTree | Functional | 2002 |
| TC03 | RawData 參數表 | @Functional @RawData | Functional | 2003 |
| TC04 | Defect Chart 曲線圖 | @Functional @Chart | Functional | 2004 |
| TC05 | 檔案樹雙擊開啟 Recipe | @Functional @FileTree | Functional | 2005 |
| TC06 | About 對話框 | @Functional @About | Functional | 2006 |
| TC07 | 匯入非 JSON 檔 | @Negative @Import | Negative | 2007 |
| TC08 | 無 Recipe 時繪圖 | @Negative @Chart | Negative | 2008 |
| TC09 | 開啟不存在 Recipe | @Negative @RawData | Negative | 2009 |
| TC10 | Run Inspection 模擬檢測 | @Functional @Inspection | Functional | 2010 |

## 控制項對照（Page Object 對應）

| 顯示名稱 | AutomationId | 快捷鍵 | Page 類別 |
|----------|--------------|--------|-----------|
| Import Recipe | btnImportRecipe | Ctrl+I | `MainWindowPage` |
| Run Inspection | btnRunInspection | Ctrl+R | `MainWindowPage` |
| RawData | btnParameters | Ctrl+E | `MainWindowPage` |
| Defect Chart | btnDefectChart | Ctrl+D | `MainWindowPage` |
| About | btnToolbar0About | — | `MainWindowPage` |
| 檔案樹 | treeFiles | 雙擊 .json | `WorkspacePage` |
| RawData 表格 | dataGridParameters | — | `WorkspacePage` |
| 日誌 | txtToolLog | — | `WorkspacePage` |
| 圖表 | pictureBoxChart | — | `WorkspacePage` |
| 開啟檔案對話框 | #32770 / 1148 | Alt+N 等 | `FileDialogPage` |
| MessageBox | — | — | `MessageBoxPage` |

工具列按鈕文字（與 Feature 一致）：`Import Recipe`、`RawData`、`Defect Chart`、`Run Inspection`、`About`。

## TPS → BDD 轉換任務

### 1. Feature File

- 每個 TPS Scenario → `Inspection_App.feature` 中一個 `Scenario` 或 `Scenario Outline`。
- 語言：繁體中文（`# language: zh-TW` 可寫在 TPS；Feature 步驟與 Steps 綁定一致）。
- 重用既有 Given / When / Then；新步驟先在 TPS.md 定稿再實作 Step。
- **有多組測試資料時**改用 `Scenario Outline` + `Examples`（見下方 **DDT** 章節）。

### 2. Step Definitions

- `[Binding]` 類別 `Inspection_AppSteps`。
- `ScenarioContext` 保存匯入檔路徑、選取的樹節點等。
- Steps 只做編排與 Assert；FlaUI 操作委派 Page Object。
- 失敗 / 點擊 / 步驟完成截圖：`ActionScreenshotHelper` → `Screenshots/`。
- **DDT 步驟**：以 `(.*)` 或 `"(.*)"` 接收 `<placeholder>`；檔名以 `ConfigHelper.GetRecipeDataDirectory()` 組完整路徑；**勿**為 Examples 每一列寫死獨立 Step。

## DDT（Data-Driven Testing / 資料驅動測試）

### 概念

**DDT** 指同一測試流程以**多組輸入／預期結果**重複執行。在 SpecFlow 中以 **`Scenario Outline` + `Examples` 表格** 實作；表格欄位對應步驟中的 `<placeholder>`，SpecFlow 每列產生一個獨立測試案例。

### 何時使用

| 情境 | 作法 | 本專案範例 |
|------|------|------------|
| 同一 TC 需驗證多組參數值 | `Scenario Outline` + `Examples` | **TC01** RawData 參數表（3 列） |
| 同一 TC 需測多個檔名／路徑 | 步驟參數化 + `Examples` | 未來 Recipe_data 新增 JSON 時擴充 TC05 |
| 僅一組固定資料 | 維持 `Scenario`，步驟仍可用參數化 regex | TC02–TC10 多數案例 |
| 不同業務目的 | 維持獨立 Scenario（一 TC 一 Scenario/Outline） | 不將 TC03 與 TC04 合併 |

### Feature 撰寫規範

```gherkin
@Functional @Import @DDT
Scenario Outline: TC01 - Import Recipe to Recipe_data
  Given test data is ready
  And the application has relaunched
  When I click toolbar "Import Recipe"
  And I select file "<recipe_file>" in the file dialog
  And I click toolbar "RawData"
  Then Recipe_data should contain "<recipe_file>"
  And the data table should be visible
  And the RawData view should show filename <recipe_file>
  And the RawData parameter table should contain "<expected_parameter>"
  And the log should contain "Import Recipe"

  Examples:
    | recipe_file                   | expected_parameter    |
    | InspectionRecipe_Sample.json  | Layer1_AOI_Recipe_v1 |
    | InspectionRecipe_Sample.json  | W-20260605-001       |
    | InspectionRecipe_Sample.json  | Brightfield          |
```

**規則：**

- 標題仍為 `TCxx - 簡短描述`；使用 Outline 時寫 `Scenario Outline:`。
- 加 `@DDT` 標籤，方便 `--filter "Category=DDT"` 或 Web 控制台篩選。
- `Examples` 表頭用 **snake_case**（如 `recipe_file`、`expected_parameter`），與 `<placeholder>` 一致。
- 檔名 placeholder 寫在引號內 `"<recipe_file>"`；不含空格的檔名展示步驟可不加引號 `<recipe_file>`。
- 斷言字串用 `"<expected_parameter>"`；固定常數（如 log 關鍵字 `"Import Recipe"`）維持字面量。

### Step Definitions 規範

```csharp
[When(@"I select file ""(.*)"" in the file dialog")]
public void WhenISelectFileInFileDialog(string fileName)
{
    var path = Path.Combine(ConfigHelper.GetRecipeDataDirectory(), fileName);
    FileDialog.OpenFile(path);
    Workspace.WaitAfterDataTableAction();
}

[Then(@"Recipe_data should contain ""(.*)""")]
public void ThenRecipeDataShouldContain(string fileName)
{
    var path = Path.Combine(ConfigHelper.GetRecipeDataDirectory(), fileName);
    ClassicAssert.IsTrue(File.Exists(path), "Recipe_data should contain " + fileName);
}
```

- 一組 regex 綁定所有 Examples 列；**禁止** `InspectionRecipe_Sample\.json` 寫死在 Step regex 內（改由 Examples 或 `App.config` 提供）。
- 需要列級上下文時，可存入 `ScenarioContext`（如 `_scenarioContext["recipe_file"] = fileName`）。
- 報告：SpecFlow 會為每列 Examples 產生獨立 Scenario 名稱（含列索引），`TestResultReport.html` 逐步驟記錄。

### 本專案 DDT 對照

| TC | 類型 | Examples 欄位 | 說明 |
|----|------|---------------|------|
| TC01 | **Scenario Outline** | `recipe_file`, `expected_parameter` | 匯入後驗證 3 組 RawData 參數 |
| TC02–TC10 | Scenario（步驟參數化） | — | 單列資料；步驟用 `"<file>"` 形式以便日後擴充 |

### 3. Page Object Model

- 方法名對應業務動作（如 `ClickToolbar("Import Recipe")`、`SelectFileInDialog(path)`）。
- `BasePage`：`FindElement`、`WaitUntilEnabled`、共用 `Window`、點擊截圖。
- `FileDialogPage`：優先 UIA Value；fallback 剪貼簿 + `Alt+N`（IME 環境）。

### 4. Hooks 與基礎架構

- `BeforeTestRun`：初始化 ExtentReports + `TestResultReportBuilder`。
- `BeforeScenario`：啟動 / Attach `SemiInspectionDesktop`、準備測試資料。
- `AfterScenario`：記錄步驟結果、Scenario 完成截圖、關閉程序。
- `App.config` + `ConfigHelper`：EXE、Recipe_data、逾時（預設 30000 ms）。

### 5. 斷言慣例

- 日誌關鍵字 → `WorkspacePage` 讀 `txtToolLog`，`Assert.That(log, Does.Contain(...))`。
- 檔案存在 → `File.Exists` 於 `Recipe_data`。
- MessageBox → `MessageBoxPage` 驗證後關閉。
- 主視窗仍存 → `MainWindowPage` 確認視窗未消失。

### 6. 技術棧

- SpecFlow 3.9+、FlaUI 4.x、NUnit 4.x、**.NET 8**（被測 App 為 .NET 3.5 WinForms）。
- 平行執行時每 Scenario 獨立程序實例（`TestHooks` 管理 Launch / Kill）。

## 建置與執行

```bat
cd SQA_Inspetion_App
build_semi.bat                    REM 建置被測 WinForms
run_tests.bat                     REM 全套 TC + 報告（含 setup_env.bat）

REM 單一 TC
cd Automation_testcase\Project_FlaUIBDD\Testcase_Inspection_App_FlaUI_BDD
dotnet test -c Release --filter "Name~TC01"
```

**Web 控制台：**

```bat
cd SQA_Inspetion_App
啟動測試平台.bat
```

瀏覽器：**http://localhost:6690/** — 勾選 Feature、執行測試、預覽報告。

## 報告產出

| 報告 | 路徑 | 說明 |
|------|------|------|
| TestResult（步驟 + 截圖） | `bin/Release/net8.0-windows/reports/TestResultReport.html` | 步驟級 HTML 報告；**首頁含測試注意事項、已知瓶頸、BDD/DDT 解說** |
| ExtentReports | `bin/Release/net8.0-windows/reports/SemiInspectionTestReport.html` | 傳統 HTML |
| 別名（相容舊連結） | `reports/Inspection_AppTestReport.html` → SemiInspectionTestReport | Web 控制台別名 |
| JUnit | `reports/junit-results.xml` | CI / 控制台解析 |

測試結束後 Web 控制台會同步 `bin/.../reports/` → 專案 `reports/`。

## 完成檢查清單

- [ ] TPS.md、TEST_PLAN、SemiInspection_10_TestCases 與 Feature 同步
- [ ] 10 個 Scenario / Scenario Outline 與 TC01–TC10 對齊
- [ ] TC01 使用 `Scenario Outline` + `@DDT`；其餘 TC 步驟已參數化（檔名、無效檔等）
- [ ] 控制項 AutomationId 與 `SemiInspection_10_TestCases.md` 一致
- [ ] `App.config` 使用相對路徑（或可覆寫的環境變數）
- [ ] TC07–TC09 驗證 MessageBox / 主視窗仍存在
- [ ] TC01 FileDialog 在 IME 環境可 fallback
- [ ] `dotnet test -c Release` 通過；報告含步驟截圖
- [ ] 必要時更新 `操作說明.html`

## 延伸閱讀

- 專案 README：`SQA_Inspetion_App/README.md`
- Gherkin 完整版：`Test_cases/TPS.md`
- FlaUI 實戰細節（FileDialog、LogContains 等）：維護時參考同 repo 內 `PageObjects/`、`Helpers/` 既有實作
