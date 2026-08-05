# 🏢 公司電腦無 Python 使用指南

## 📋 概述

如果您的公司電腦因權限限制無法安裝 Python，本指南將幫助您充分使用此測試平台的大部分功能。

---

## ✅ 不需要 Python 的功能（可直接使用）

### 1. 查看操作手冊（離線版）

```cmd
雙擊： main_menu.bat（選項 [8]）
```

或直接開啟：`docs\index.html`

**可用內容：**
- ✅ 完整的五章節教學文件
- ✅ 所有文字說明與圖片
- ✅ 章節導航
- ❌ 一鍵執行 .bat 按鈕（需要伺服器）

---

### 2. 查看測試報告

```cmd
雙擊： 開啟測試報告.bat
```

**功能：**
- ✅ 查看 HTML 測試報告
- ✅ 查看測試結果統計
- ✅ 查看失敗測試的截圖
- ✅ 查看詳細執行記錄

**報告位置：**
```
Automation_testcase\Project_FlaUIBDD\Testcase_Inspection_App_FlaUI_BDD\reports\
├── TestResultReport.html       ← 主要報告
├── SemiInspectionTestReport.html
└── junit-results.xml
```

---

### 3. 執行測試（需要 .NET SDK）

```cmd
雙擊： run_tests.bat
```

**前置需求：**
- ✅ .NET SDK 8.0+（通常公司電腦已安裝）
- ✅ MSBuild（Visual Studio 或 Build Tools）
- ❌ 不需要 Python

**功能：**
- ✅ 建置被測程式
- ✅ 執行全部 10 個測試案例
- ✅ 產生 HTML 報告
- ✅ 產生 JUnit XML 報告

---

### 4. 執行單一測試

```cmd
雙擊： 執行單一測試.bat
```

輸入測試編號（如 TC01）即可執行。

**不需要 Python！**

---

### 5. 啟動被測程式

```cmd
雙擊： 啟動InspectionApp.bat
```

或

```cmd
雙擊： run_semi.bat
```

**功能：**
- ✅ 直接啟動 SemiInspectionDesktop.exe
- ✅ 手動測試功能

---

### 6. 查看文件檔案

以下文件可以用任何文字編輯器或 Markdown 瀏覽器開啟：

```
├── README.md                    # 專案說明
├── GETTING_STARTED.md              # 新手教學
├── WINDOWS_QUICK_START.md          # Windows 快速開始
├── WINDOWS_TROUBLESHOOTING.md          # 疑難排解指南
├── NO_PYTHON_GUIDE.md          # 本文件
└── Automation_testcase\
    └── Test_cases\
        ├── TPS.md               # 測試規格
        ├── TEST_PLAN.md         # 測試計畫
        └── SemiInspection_10_TestCases.md  # 測試案例
```

使用方法：
- 在 VS Code 中開啟（如果有）
- 用 Notepad++ 開啟
- 用 Windows 內建記事本開啟
- 上傳到 GitHub 線上查看

---

## ❌ 需要 Python 的功能（無法使用）

### 1. 操作手冊伺服器（互動版）

**原本功能：**
- 在瀏覽器中一鍵執行 .bat 檔案
- 提供 HTTP 伺服器

**替代方案：**
- 使用 `main_menu.bat（選項 [8]）` 開啟離線版
- 手動執行對應的 .bat 檔案

---

### 2. Web 測試控制台

**無法使用：** `啟動測試平台.bat`

**原本功能：**
- 網頁介面選擇測試案例
- 即時查看測試執行狀態
- 視覺化測試結果

**替代方案：**
- 使用命令列執行測試：
  ```cmd
  run_tests.bat          # 執行全部測試
  執行單一測試.bat        # 執行單一測試
  ```
- 執行完後用瀏覽器開啟報告：
  ```cmd
  開啟測試報告.bat
  ```

---

## 🔄 完整工作流程（無 Python 環境）

### 情境 1: 執行測試並查看報告

```cmd
# 步驟 1: 執行全部測試
雙擊： run_tests.bat

# 步驟 2: 查看測試報告
雙擊： 開啟測試報告.bat
```

**不需要 Python！**

---

### 情境 2: 執行特定測試

```cmd
# 步驟 1: 執行單一測試
雙擊： 執行單一測試.bat
# 輸入: TC01

# 步驟 2: 查看報告
雙擊： 開啟測試報告.bat
```

---

### 情境 3: 查看操作手冊

```cmd
# 方法 1: 離線版（推薦）
雙擊： main_menu.bat（選項 [8]）

# 方法 2: 直接開啟 HTML
start docs\index.html

# 方法 3: 用瀏覽器拖曳開啟
# 將 docs\index.html 拖到 Edge 或 Chrome 視窗
```

---

### 情境 4: 手動測試被測程式

```cmd
# 啟動被測程式
雙擊： 啟動InspectionApp.bat

# 手動操作並測試功能
```

---

## 📊 功能對照表

| 功能 | 需要 Python | 替代方案 | 可用性 |
|------|------------|---------|--------|
| 查看操作手冊 | ❌ | 離線 HTML 版 | ✅ 90% |
| 執行測試 | ❌ | 使用 .NET CLI | ✅ 100% |
| 查看報告 | ❌ | 直接開啟 HTML | ✅ 100% |
| 啟動被測程式 | ❌ | 直接執行 .exe | ✅ 100% |
| Web 控制台 | ✅ | 命令列執行 | ⚠️ 70% |
| 一鍵執行按鈕 | ✅ | 手動執行 .bat | ⚠️ 80% |

---

## 💡 推薦工作流程

### 對於公司電腦用戶

1. **查看文件**
   ```cmd
   main_menu.bat（選項 [8]）
   ```

2. **執行測試**
   ```cmd
   run_tests.bat
   ```

3. **查看結果**
   ```cmd
   開啟測試報告.bat
   ```

4. **如需修改測試**
   - 編輯 `.feature` 檔案（BDD 測試場景）
   - 編輯 `StepDefinitions` 中的 C# 程式碼
   - 重新執行測試

---

## 🔧 必要的環境需求（無 Python）

### 最低需求

- ✅ Windows 10/11
- ✅ .NET SDK 8.0+
- ✅ MSBuild（Visual Studio 或 Build Tools）

### 檢查方法

```cmd
# 檢查 .NET
dotnet --version
# 應顯示: 8.0.x 或更新

# 檢查 MSBuild
where msbuild
# 應顯示路徑
```

### 如果缺少 .NET

即使無法安裝 Python，通常公司電腦可以安裝 .NET SDK：

1. 前往：https://dotnet.microsoft.com/download
2. 下載 .NET SDK 8.0
3. 執行安裝程式（通常不需要管理員權限）

---

## 📝 批次檔功能分類

### 🟢 不需要 Python

```cmd
main_menu.bat（選項 [8]）  ← 新增！推薦使用
開啟測試報告.bat
run_tests.bat
執行單一測試.bat
啟動InspectionApp.bat
run_semi.bat
build_semi.bat
診斷工具.bat              ← 部分功能需要 Python
工具選單（簡化版）.bat      ← 互動式選單（簡化版，推薦）
公司電腦工具選單.bat        ← 互動式選單（美化版）
開啟快速開始指南.bat
開啟疑難排解指南.bat
main_menu.bat（選項 [9]）
```

**提示：** 如果「公司電腦工具選單.bat」顯示亂碼或無法執行，請使用「工具選單（簡化版）.bat」。

### 🔴 需要 Python

```cmd
main_menu.bat          ← 啟動 HTTP 伺服器
啟動測試平台.bat           ← Web 控制台
```

---

## 🆘 遇到問題？

### 問題：執行測試時出現錯誤

**可能原因：**
- .NET SDK 未安裝或版本過舊
- MSBuild 找不到

**解決方法：**
```cmd
# 檢查 .NET 版本
dotnet --version

# 如果版本 < 8.0，需要更新
# 下載：https://dotnet.microsoft.com/download
```

---

### 問題：無法開啟操作手冊

**解決方法 1：使用無 Python 版本**
```cmd
main_menu.bat（選項 [8]）
```

**解決方法 2：直接開啟 HTML**
```cmd
start docs\index.html
```

**解決方法 3：用瀏覽器拖曳**
- 開啟 Edge 或 Chrome
- 將 `docs\index.html` 拖到瀏覽器視窗

---

### 問題：報告中找不到截圖

**可能原因：**
測試執行時沒有產生截圖（可能是測試通過了）

**檢查位置：**
```
Automation_testcase\Project_FlaUIBDD\Testcase_Inspection_App_FlaUI_BDD\
└── bin\Release\net8.0-windows\Screenshots\
```

失敗的測試會自動截圖。

---

## ✨ 優點：無 Python 環境的好處

1. **更快的啟動**：不需要啟動 Python 伺服器
2. **更簡單**：直接開啟 HTML，沒有 Port 占用問題
3. **離線可用**：不依賴網路或 localhost
4. **權限友善**：公司環境通常允許執行 .exe 和 .bat

---

## 📞 需要協助？

如果遇到任何問題：

1. **查看診斷工具**
   ```cmd
   診斷工具.bat
   ```
   （部分功能仍可用）

2. **查看疑難排解指南**
   - `WINDOWS_TROUBLESHOOTING.md`
   - 涵蓋常見問題

3. **查看測試計畫**
   - `Automation_testcase\Test_cases\TEST_PLAN.md`
   - 了解測試架構

---

## 🎯 總結

### 可以做的事（無 Python）

- ✅ 查看操作手冊（離線版）
- ✅ 執行全部測試
- ✅ 執行單一測試
- ✅ 查看測試報告
- ✅ 啟動被測程式
- ✅ 編輯測試案例
- ✅ 查看所有文件

### 無法做的事

- ❌ 使用 Web 測試控制台（互動式）
- ❌ 在操作手冊中使用一鍵執行按鈕

### 影響程度

**不影響核心功能！** 所有測試執行、報告查看、程式測試都可以正常進行。

---

**👉 立即開始：** 執行 `main_menu.bat（選項 [8]）` 查看完整教學！
