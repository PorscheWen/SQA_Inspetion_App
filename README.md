# SQA Inspection App

Semi Inspection Desktop 的 **FlaUI BDD 自動化測試平台**（可獨立運行，不依賴其他專案目錄）。

## 目錄結構

```
SQA_Inspetion_App/
├── SemiInspectionDesktop/          # 被測 WinForms 桌面程式
├── Recipe_data/                    # 測試資料（JSON、無效檔）
├── build_semi.bat / run_semi.bat   # 建置／啟動被測 App
├── run_tests.bat                   # CLI 一鍵建置 + 執行全部 TC
├── 啟動測試平台.bat                 # 開啟 Web 控制台 (port 6690)
├── config.json                     # 路徑設定摘要
├── docs/                           # HTML 操作手冊（五章節）
├── 開啟操作手冊.bat                 # 開啟 docs/index.html
├── 執行單一測試.bat                 # 執行指定 TC（如 TC01）
├── 開啟測試報告.bat                 # 開啟 TestResultReport.html
└── Automation_testcase/
    ├── Test_cases/                 # Gherkin TPS、測試計畫、案例表
    │   ├── TPS.md
    │   ├── TEST_PLAN.md
    │   └── SemiInspection_10_TestCases.md
    └── Project_FlaUIBDD/
        ├── Testcase_Inspection_App_FlaUI_BDD/   # SpecFlow + FlaUI
        └── web_dashboard/                      # 網頁控制台
```

## 操作手冊（HTML）

雙擊 **`開啟操作手冊.bat`** 或開啟 `docs/index.html`，內含五章節：

1. TPS 轉換成 BDD testcases
2. 如何修改 BDD testcases
3. 執行 BDD automation testcase
4. 如何修復 automation testcase
5. 讀取 report

## 三階段流程

| 階段 | 文件／工具 | 說明 |
|------|------------|------|
| 1. TPS → BDD | `Test_cases/TPS.md` → `Features/*.feature` | Gherkin 規格對應可執行 Scenario |
| 2. 執行測試 | `run_tests.bat` 或 Web 控制台 | FlaUI 操作 Semi Inspection Desktop |
| 3. 讀取報告 | `reports/SemiInspectionTestReport.html` | JUnit XML + HTML 報告 |

## 快速開始

### 前置需求

- Windows 10/11
- .NET SDK 8.0+
- Python 3.x（Web 控制台）
- MSBuild .NET 3.5（建置被測 App）

### CLI 執行全部測試

```bat
cd SQA_Inspetion_App
run_tests.bat
```

### Web 控制台

```bat
啟動測試平台.bat
```

瀏覽器開啟：**http://localhost:6690/**

1. **勾選 Features** — 選擇 TC01–TC10
2. **執行已勾選的測試**
3. **測試結果** — 查看通過率與 HTML 報告

### 單一 TC

```bat
cd Automation_testcase\Project_FlaUIBDD\Testcase_Inspection_App_FlaUI_BDD
dotnet test -c Release --filter "Name~TC01"
```

## 報告位置

| 類型 | 路徑 |
|------|------|
| HTML | `Automation_testcase/Project_FlaUIBDD/Testcase_Inspection_App_FlaUI_BDD/reports/SemiInspectionTestReport.html` |
| JUnit | `.../reports/junit-results.xml` |
| 失敗截圖 | `bin/Release/net8.0-windows/Screenshots/` |

## 環境變數（可覆寫 App.config）

`setup_env.bat` 會設定（`run_tests.bat`、`啟動測試平台.bat` 會自動載入）：

- `APP_ROOT` — 專案根目錄
- `ApplicationPath`
- `RecipeDataDirectory`

`App.config` 亦支援**相對路徑**（以 `APP_ROOT` 或含 `config.json` 的根目錄解析），無需寫死本機絕對路徑。

## 獨立性

本專案所有被測程式、測試資料、BDD 與 Web 控制台皆在 `SQA_Inspetion_App/` 內，**不需要** `SQA_AI_Automation` 或其他兄弟資料夾即可建置、執行測試與產生報告。
