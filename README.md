# SQA Inspection App

Semi Inspection Desktop 的 **FlaUI BDD 自動化測試平台**（可獨立運行，不依賴其他專案目錄）。

---

## 🪟 Windows 11 用戶請先看這裡！

### 🏢 公司電腦無法安裝 Python？
**不用擔心！大部分功能都不需要 Python。**

```bat
雙擊： 開啟無Python使用指南.bat
```

或查看 [無Python使用指南.md](無Python使用指南.md)

**可用功能（無需 Python）：**
- ✅ 查看操作手冊（離線版）→ `開啟操作手冊（無Python）.bat`
- ✅ 執行全部測試 → `run_tests.bat`
- ✅ 查看測試報告 → `開啟測試報告.bat`
- ✅ 啟動被測程式 → `啟動InspectionApp.bat`

**需要 Python 的功能（受限）：**
- ⚠️ Web 測試控制台 → 改用命令列執行
- ⚠️ 操作手冊互動按鈕 → 手動執行對應 .bat

---

### 第一次使用？執行診斷工具
```bat
雙擊： 診斷工具.bat
```

### 遇到問題？查看指南
- 📘 **快速開始**：[WINDOWS_快速開始.md](WINDOWS_快速開始.md) 或執行 `開啟快速開始指南.bat`
- 🔧 **疑難排解**：[WINDOWS_疑難排解.md](WINDOWS_疑難排解.md) 或執行 `開啟疑難排解指南.bat`
- 🏢 **無 Python**：[無Python使用指南.md](無Python使用指南.md) 或執行 `開啟無Python使用指南.bat`

### 常見問題快速修復
| 問題 | 解決方法 |
|------|----------|
| 🏢 公司電腦無法安裝 Python | 使用無 Python 版本工具 |
| ❌ 找不到 Python | 安裝 Python 3.8+ 並勾選「Add to PATH」 |
| 💥 批次檔閃退 | 從命令提示字元執行查看錯誤 |
| 🔒 Port 被占用 | 執行診斷工具查看占用進程 |
| 🚫 防火牆阻擋 | 以系統管理員身分執行 |

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

## 🆘 疑難排解（Windows 11）

如果執行批次檔時遇到問題（如閃退、找不到 Python、Port 占用等），請使用以下工具：

### 自動診斷工具

```bat
診斷工具.bat
```

此工具會自動檢查：
- ✅ Python 環境與版本
- ✅ 專案檔案完整性
- ✅ Port 占用狀況
- ✅ 防火牆與網路權限
- ✅ 檔案系統權限

### 詳細疑難排解指南

開啟 [WINDOWS_疑難排解.md](WINDOWS_疑難排解.md) 或執行：

```bat
開啟疑難排解指南.bat
```

常見問題包括：
1. ❌ 找不到 Python → 安裝 Python 並加入 PATH
2. ⚠️ Port 6688/6690 被占用 → 關閉占用的程式
3. ❌ 找不到 docs\server.py → 重新下載或檢查解壓縮
4. 🔒 防火牆阻擋 → 新增例外規則或以系統管理員執行
5. 💥 批次檔閃退 → 從命令提示字元執行查看錯誤訊息

---

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
