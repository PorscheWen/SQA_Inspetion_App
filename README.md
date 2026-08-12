# SQA Inspection App

Semi Inspection Desktop 的 **FlaUI BDD 自動化測試平台**（可獨立運行，不依賴其他專案目錄）。

---

## 🪟 Windows 11 用戶請先看這裡！

### 🚀 快速開始 - 使用統一主選單

**只需雙擊一個批次檔，即可使用所有功能：**

```bat
雙擊： main_menu.bat
```

**主選單包含所有功能：**
- ✅ 測試執行（全部測試、單一測試、Web 控制台）
- ✅ 應用程式（啟動、建置）
- ✅ 報告與文件（測試報告、操作手冊）
- ✅ 指南與說明（新手入門、疑難排解等）
- ✅ 工具（環境診斷、TPS、Inspector）

---

### 🏢 公司電腦無法安裝 Python？
**不用擔心！大部分功能都不需要 Python。**

在主選單中選擇：
- ✅ [1] 執行全部測試（無需 Python）
- ✅ [2] 執行單一測試（無需 Python）
- ✅ [6] 開啟測試報告（無需 Python）
- ✅ [8] 開啟操作手冊 (無 Python 版)
- ✅ [11] 無 Python 使用指南

或查看 [NO_PYTHON_GUIDE.md](NO_PYTHON_GUIDE.md)

---

### 遇到問題？

在主選單中選擇：
- **[13] 環境診斷工具** - 自動檢查系統環境
- **[10] Windows 快速開始指南**
- **[12] 疑難排解指南**

或查看文件：
- 📘 [WINDOWS_QUICK_START.md](WINDOWS_QUICK_START.md)
- 🔧 [WINDOWS_TROUBLESHOOTING.md](WINDOWS_TROUBLESHOOTING.md)

### 常見問題快速修復
| 問題 | 解決方法 |
|------|----------|
| 🏢 公司電腦無法安裝 Python | 選單選項 [11] 查看無 Python 使用指南 |
| ❌ 找不到 Python | 選單選項 [8] 使用離線版操作手冊 |
| 💥 不知道如何開始 | 執行「main_menu.bat」，所有功能都在裡面 |
| 🔍 需要診斷環境 | 選單選項 [13] 環境診斷工具 |

---

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
├── main_menu.bat                 # 開啟 docs/index.html
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

**使用主選單開啟：** 執行 `main_menu.bat`，選擇 [7] 或 [8]

- **選項 [7]**：開啟操作手冊（需要 Python，提供完整互動功能）
- **選項 [8]**：開啟操作手冊（無 Python 版，離線閱讀）
- **直接開啟**：`docs/index.html`

操作手冊內含五章節：

1. TPS 轉換成 BDD testcases
2. 如何修改 BDD testcases
3. 執行 BDD automation testcase
4. 如何修復 automation testcase
5. 讀取 report

## 三階段流程

| 階段 | 文件／工具 | 說明 |
|------|------------|------|
| 1. TPS → BDD | `Test_cases/TPS.md` → `Features/*.feature` | Gherkin 規格對應可執行 Scenario |
| 2. 執行測試 | 主選單 [1] [2] [3] | FlaUI 操作 Semi Inspection Desktop |
| 3. 讀取報告 | 主選單 [6] | JUnit XML + HTML 報告 |

## 🆘 疑難排解（Windows 11）

使用主選單的環境診斷工具：

```bat
# 執行主選單
雙擊： main_menu.bat

# 選擇選項 [13] 環境診斷工具
```

診斷工具會自動檢查：
- ✅ Python 環境與版本
- ✅ .NET 環境與版本  
- ✅ 專案檔案完整性
- ✅ Port 占用狀況
- ✅ 被測程式與測試報告狀態

### 詳細疑難排解指南

在主選單中選擇 [12] 或直接開啟 [WINDOWS_TROUBLESHOOTING.md](WINDOWS_TROUBLESHOOTING.md)

常見問題包括：
1. ❌ 找不到 Python → 使用離線版操作手冊（選單選項 [8]）
2. ⚠️ Port 被占用 → 診斷工具會顯示占用進程
3. ❌ 找不到檔案 → 檢查專案完整性
4. 🔒 防火牆阻擋 → 以系統管理員執行主選單
5. 💥 不知道如何開始 → 執行主選單，跟著選項操作

---

## 快速開始

### 🎯 方式 A：使用主選單（強烈推薦）

```bat
雙擊： main_menu.bat
```

**主選單提供 15 個功能選項：**

```
【測試執行】
  [1] 執行全部測試
  [2] 執行單一測試
  [3] 啟動測試平台 (Web 控制台)

【應用程式】
  [4] 啟動 Inspection App
  [5] 建置 Inspection App

【報告與文件】
  [6] 開啟測試報告
  [7] 開啟操作手冊
  [8] 開啟操作手冊 (無 Python 版)

【指南與說明】
  [9]  新手入門指南
  [10] Windows 快速開始指南
  [11] 無 Python 使用指南
  [12] 疑難排解指南

【工具】
  [13] 環境診斷工具
  [14] 開啟 TPS 文件
  [15] 開啟 FlaUI Inspector
  [16] FlaUI.Cli 錄製（匯出 JSON → BDD stub）

  [0] 退出
```

FlaUI 教學（含 Inspector／CLI 錄製圖文）：[`docs/flaui-tutorial.html`](docs/flaui-tutorial.html)
---

### 🎯 方式 B：使用命令列

如果需要直接執行特定功能：

#### 執行全部測試

```bat
# 在主選單中選擇 [1]
# 或使用命令列：
cd SQA_Inspetion_App
cd Automation_testcase\Project_FlaUIBDD\Testcase_Inspection_App_FlaUI_BDD
dotnet test -c Release
```

#### 執行單一測試

```bat
# 在主選單中選擇 [2]
# 或使用命令列：
cd Automation_testcase\Project_FlaUIBDD\Testcase_Inspection_App_FlaUI_BDD
dotnet test -c Release --filter "Name~TC01"
```

#### 建置應用程式

```bat
# 在主選單中選擇 [5]
# 或直接執行：
build_semi.bat
```

---

## 前置需求

- Windows 10/11
- .NET SDK 8.0+
- Python 3.x（部分功能，如 Web 控制台、操作手冊伺服器）
- MSBuild .NET 3.5（建置被測 App）

**注意**：Python 不是必需的，大部分功能都可以在沒有 Python 的情況下使用。

### 執行測試的三種方式

#### 方式 1：使用主選單（最簡單）

```bat
# 執行主選單
雙擊： main_menu.bat

# 選擇 [1] 執行全部測試
# 或選擇 [2] 執行單一測試
```

#### 方式 2：使用 Web 控制台（需要 Python）

```bat
# 在主選單中選擇 [3]
# 或使用命令列：
cd Automation_testcase\Project_FlaUIBDD\web_dashboard
python server.py
```

瀏覽器開啟：**http://localhost:6690/**

1. **勾選 Features** — 選擇 TC01–TC10
2. **執行已勾選的測試**
3. **測試結果** — 查看通過率與 HTML 報告

#### 方式 3：使用命令列

```bat
# 執行全部測試
cd Automation_testcase\Project_FlaUIBDD\Testcase_Inspection_App_FlaUI_BDD
dotnet build -c Release
dotnet test -c Release

# 執行單一測試
dotnet test -c Release --filter "Name~TC01"
```

## 報告位置

在主選單中選擇 [6] 開啟測試報告，或手動開啟：

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
