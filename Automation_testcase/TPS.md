# TPS — Test Procedure Specification（Gherkin）

**Test Procedure Specification（測試程序規格）**  
以 Gherkin 語法描述 Semi Inspection Desktop 之 10 項測試程序。

| 項目 | 內容 |
|------|------|
| 專案根目錄 | `SQA_Inspetion_App/`（可獨立運行） |
| 來源 | [Test_cases/TEST_PLAN.md](Test_cases/TEST_PLAN.md) |
| 案例總表 | [Test_cases/SemiInspection_10_TestCases.md](Test_cases/SemiInspection_10_TestCases.md) |
| BDD 撰寫 skill | [TPS_BDD_skill.md](TPS_BDD_skill.md) |
| 被測程式 | `../SemiInspectionDesktop/bin/Debug/SemiInspectionDesktop.exe` |
| 測試資料目錄 | `../Recipe_data/` |
| 標準樣本 | `InspectionRecipe_Sample.json` |
| 自動化 Feature | `Project_FlaUIBDD/Testcase_demo2_desktop_FlaUI_BDD/Features/Demo2Desktop.feature` |
| Web 控制台 | `Project_FlaUIBDD/web_dashboard/`（http://localhost:6690） |
| 語言 | 繁體中文（步驟用語與 FlaUI BDD 一致） |

## 前置條件（Background）

```gherkin
# language: zh-TW
Background: Semi Inspection Desktop 測試環境
  Given 工作目錄為 SQA_Inspetion_App
  And 已執行 build_semi.bat 建置被測程式
  And Recipe_data 含 InspectionRecipe_Sample.json
  And Recipe_data 含 _invalid_sample.txt（TC07 用）
```

## Feature

```gherkin
# language: zh-TW
Feature: Semi Inspection Desktop 測試
  作為測試人員
  我想要驗證 Semi Inspection Desktop 的 Recipe、RawData 與圖表功能
  以確保 Recipe_data 工作流程正常

  # --- Functional（7）---

  @Functional @Import @Defect2001
  Scenario: TC01 - Import Recipe 至 Recipe_data
    # 目的：驗證 Import Recipe 可匯入 JSON 並顯示 RawData
    Given 測試資料已就緒
    And 應用程式已重新啟動
    When 我點擊工具列「Import Recipe」
    And 我在檔案對話框選擇樣本 InspectionRecipe_Sample.json
    Then Recipe_data 應存在 InspectionRecipe_Sample.json
    And 資料表應可見
    And 日誌區應包含「Import Recipe」

  @Functional @FileTree @Defect2002
  Scenario: TC02 - File Tree 顯示 Recipe_data
    # 目的：左側樹狀目錄指向 Recipe_data
    Given 測試資料已就緒
    And 應用程式已啟動
    Then 主視窗標題應為「Semi Inspection Desktop」
    And 檔案樹應可見
    And Recipe_data 應存在 InspectionRecipe_Sample.json

  @Functional @RawData @Defect2003
  Scenario: TC03 - RawData 參數表
    # 目的：RawData 按鈕切換並載入 Inspection 參數（btnParameters / Ctrl+E）
    Given 測試資料已就緒
    And 應用程式已啟動
    When 我點擊工具列「RawData」
    Then 資料表應可見
    And 日誌區應包含「RawData」

  @Functional @Chart @Defect2004
  Scenario: TC04 - Defect Chart 曲線圖
    # 目的：DefectSummary 繪製 DefectType / DefectCount 曲線（Sample 共 5 類）
    Given 測試資料已就緒
    And 應用程式已啟動
    When 我點擊工具列「RawData」
    And 我點擊工具列「Defect Chart」
    Then 日誌區應包含「Defect Chart」

  @Functional @FileTree @Defect2005
  Scenario: TC05 - 檔案樹雙擊開啟 Recipe
    # 目的：從 File Tree 直接開 JSON Recipe
    Given 測試資料已就緒
    And 應用程式已啟動
    When 我在檔案樹雙擊 InspectionRecipe_Sample.json
    Then 資料表應可見
    And 日誌區應包含「Recipe」

  @Functional @About @Defect2006
  Scenario: TC06 - About 對話框
    # 目的：About 顯示功能與 Inspection 資料區段說明
    Given 應用程式已啟動
    When 我點擊工具列「About」
    And 我關閉訊息對話框

  @Functional @Inspection @Defect2010
  Scenario: TC10 - Run Inspection 模擬檢測
    # 目的：依 Recipe 執行模擬 AOI 檢測並寫入日誌
    Given 測試資料已就緒
    And 應用程式已啟動
    When 我點擊工具列「RawData」
    And 我點擊工具列「Run Inspection」
    Then 日誌區應包含「Run Inspection」

  # --- Negative（3）---

  @Negative @Import @Defect2007
  Scenario: TC07 - 匯入非 JSON 檔
    # 目的：非 JSON 匯入應警告且不寫入 TC01_import_copy.json
    Given 測試資料已就緒
    And 應用程式已啟動
    When 我點擊工具列「Import Recipe」
    And 我在檔案對話框選擇無效檔 _invalid_sample.txt
    Then 不應將無效檔複製為 TC01_import_copy.json
    And 我關閉訊息對話框

  @Negative @Chart @Defect2008
  Scenario: TC08 - 無 Recipe 時繪圖
    # 目的：未載入 Recipe 時按 Defect Chart 不當機
    Given 應用程式已重新啟動
    When 我點擊工具列「Defect Chart」
    Then 主視窗仍應存在

  @Negative @RawData @Defect2009
  Scenario: TC09 - 開啟不存在 Recipe
    # 目的：選擇不存在 JSON 時顯示錯誤且主視窗仍存在
    Given 應用程式已啟動
    When 我使用快捷鍵開啟 RawData 並選擇不存在檔 not_exist_99999.json
    Then 主視窗仍應存在
```

## Scenario 對照表

| ID | 標籤 | Defect# | 類別 |
|----|------|---------|------|
| TC01 | @Functional @Import | 2001 | Functional |
| TC02 | @Functional @FileTree | 2002 | Functional |
| TC03 | @Functional @RawData | 2003 | Functional |
| TC04 | @Functional @Chart | 2004 | Functional |
| TC05 | @Functional @FileTree | 2005 | Functional |
| TC06 | @Functional @About | 2006 | Functional |
| TC07 | @Negative @Import | 2007 | Negative |
| TC08 | @Negative @Chart | 2008 | Negative |
| TC09 | @Negative @RawData | 2009 | Negative |
| TC10 | @Functional @Inspection | 2010 | Functional |

## 測試資料（Gherkin 註記）

```gherkin
# 標準 Recipe（TC01、TC04、TC05、TC10）
#   Recipe_data/InspectionRecipe_Sample.json
#   DefectSummary 5 類：Particle(18)、Scratch(6)、Bridge(3)、Pattern(9)、Void(4)

# 無效匯入（TC07）
#   Recipe_data/_invalid_sample.txt

# 不存在檔（TC09，不需預先建立）
#   Recipe_data/not_exist_99999.json
```

## 執行方式

**手動：** 依各 Scenario 的 Given / When / Then 逐步操作。

**自動化（FlaUI BDD）：**

```bat
cd SQA_Inspetion_App
run_tests.bat
```

**單一 TC：**

```bat
cd SQA_Inspetion_App\Automation_testcase\Project_FlaUIBDD\Testcase_demo2_desktop_FlaUI_BDD
dotnet test -c Release --filter "Name~TC01"
```

**Web 控制台：**

```bat
cd SQA_Inspetion_App
啟動測試平台.bat
```

瀏覽器開啟 http://localhost:6690/，勾選 Feature 後執行測試。

## 報告位置

| 類型 | 路徑（相對 FlaUI 專案） |
|------|-------------------------|
| TestResult（步驟 + 截圖） | `bin/Release/net8.0-windows/reports/TestResultReport.html` |
| ExtentReports | `bin/Release/net8.0-windows/reports/SemiInspectionTestReport.html` |
| JUnit | `reports/junit-results.xml` |

## 修訂紀錄

| 版本 | 日期 | 說明 |
|------|------|------|
| 1.0 | 2026-06-05 | 依 TEST_PLAN.md 初版 Gherkin TPS |
| 1.1 | 2026-06-14 | 路徑改為 SQA_Inspetion_App 獨立專案；補 Web 控制台與報告說明 |
