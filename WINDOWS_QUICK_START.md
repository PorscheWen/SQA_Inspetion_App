# 🚀 Windows 11 快速開始指南

## 📦 下載專案

### 方法 1: Git Clone（推薦）
```cmd
git clone https://github.com/PorscheWen/SQA_Inspetion_App.git
cd SQA_Inspetion_App
```

### 方法 2: ZIP 下載
1. 前往 GitHub 專案頁面
2. 點擊綠色「Code」按鈕 → 「Download ZIP」
3. ⚠️ **重要**：完整解壓縮到非中文路徑（如 `C:\Projects\SQA_Inspetion_App`）
4. ❌ 避免：直接在 ZIP 檔內執行

---

## ✅ 環境需求檢查

### 1. Python 3.8+（必須）

**檢查是否已安裝：**
```cmd
python --version
```

**如果顯示版本號（如 `Python 3.12.1`）→ ✅ 已安裝**

**如果顯示錯誤 → ❌ 需要安裝：**
1. 前往 https://www.python.org/downloads/
2. 下載並安裝 Python 3.8 或更新版本
3. ⚠️ **關鍵步驟**：勾選「**Add Python to PATH**」
4. 重新開啟命令提示字元

### 2. .NET SDK 8.0+（必須）

**檢查是否已安裝：**
```cmd
dotnet --version
```

**如果需要安裝：**
1. 前往 https://dotnet.microsoft.com/download
2. 下載並安裝 .NET SDK 8.0 或更新版本

### 3. MSBuild（通常隨 Visual Studio 安裝）

**如果沒有 Visual Studio：**
- 下載 [Build Tools for Visual Studio](https://visualstudio.microsoft.com/downloads/)
- 選擇「.NET desktop development」工作負載

---

## 🔍 第一步：診斷環境

在執行任何批次檔前，先執行診斷工具：

```cmd
雙擊： 診斷工具.bat
```

這會檢查：
- ✅ Python 環境
- ✅ 檔案完整性
- ✅ Port 可用性
- ✅ 網路權限

如果發現問題，請參考 [WINDOWS_TROUBLESHOOTING.md](WINDOWS_TROUBLESHOOTING.md)

---

## 📖 開啟操作手冊

### 方法 1: 一鍵啟動（推薦）

```cmd
雙擊： main_menu.bat
```

成功後會看到：
```
✅ Python 環境正常: Python 3.12.1
✅ 必要檔案存在
✅ Port 6688 可用
✅ 具有綁定 Port 6688 的權限
✅ 環境檢查完成

正在啟動操作手冊伺服器 (port 6688) ...
```

瀏覽器會自動開啟操作手冊。

### 方法 2: 手動執行

如果批次檔無法執行：

```cmd
cd C:\path\to\SQA_Inspetion_App\docs
python server.py
```

然後開啟瀏覽器訪問：http://localhost:6688/docs/index.html

---

## 🧪 執行測試

### 方法 1: 執行全部測試（CLI）

```cmd
雙擊： run_tests.bat
```

這會：
1. 建置被測程式（SemiInspectionDesktop）
2. 建置測試專案
3. 執行全部 10 個測試案例
4. 產生 HTML 報告

### 方法 2: 使用 Web 控制台

```cmd
雙擊： 啟動測試平台.bat
```

瀏覽器會開啟 http://localhost:6690/

在控制台中：
1. ✅ 勾選要執行的測試案例（TC01-TC10）
2. 🚀 點擊「執行已勾選的測試」
3. 📊 查看即時執行結果

### 方法 3: 執行單一測試

```cmd
雙擊： 執行單一測試.bat
```

然後輸入測試編號（如 `TC01`）

---

## 📊 查看測試報告

```cmd
雙擊： 開啟測試報告.bat
```

或手動開啟：
```
Automation_testcase\Project_FlaUIBDD\Testcase_Inspection_App_FlaUI_BDD\reports\SemiInspectionTestReport.html
```

報告包含：
- ✅ 通過的測試
- ❌ 失敗的測試
- 📸 執行過程截圖
- ⏱️ 執行時間
- 📝 詳細步驟記錄

---

## ❌ 常見問題

### 問題：批次檔閃退

**解決方法：**
1. 按 `Win + R` → 輸入 `cmd` → Enter
2. 拖曳批次檔到命令提示字元視窗
3. 按 Enter
4. 現在可以看到完整錯誤訊息

### 問題：找不到 Python

**解決方法：**
```cmd
# 檢查 Python 是否在 PATH 中
where python

# 如果沒有輸出，需要重新安裝 Python 並勾選 "Add to PATH"
```

### 問題：Port 被占用

**解決方法：**
```cmd
# 查看占用 Port 6688 的進程
netstat -ano | findstr :6688

# 結束該進程（PID 是上一個命令的最後一欄）
taskkill /F /PID <PID>
```

### 問題：防火牆阻擋

**解決方法：**
1. 右鍵批次檔
2. 選擇「以系統管理員身分執行」

---

## 🔐 權限問題

如果遇到權限相關錯誤：

### 方法 1: 以系統管理員執行
1. 右鍵點擊批次檔
2. 選擇「以系統管理員身分執行」

### 方法 2: 修改資料夾權限
1. 右鍵點擊 `SQA_Inspetion_App` 資料夾
2. 內容 → 安全性 → 編輯
3. 確保您的使用者帳戶有「完全控制」權限

---

## 📁 建議的目錄結構

```
C:\Projects\                         # ✅ 英文路徑，無空格
└── SQA_Inspetion_App\              # ✅ 專案根目錄
    ├── 診斷工具.bat                # ← 先執行這個
    ├── main_menu.bat
    ├── 開啟疑難排解指南.bat
    ├── run_tests.bat
    ├── 啟動測試平台.bat
    └── ...

❌ 避免：
C:\Users\張三\桌面\SQA_Inspetion_App\  # 包含中文
C:\Program Files\SQA_Inspetion_App\    # 需要管理員權限
```

---

## 🆘 需要協助？

1. **自動診斷：** 執行 `診斷工具.bat`
2. **詳細說明：** 閱讀 [WINDOWS_TROUBLESHOOTING.md](WINDOWS_TROUBLESHOOTING.md)
3. **操作手冊：** 執行 `main_menu.bat` 查看五個章節的詳細教學
4. **回報問題：** 在 GitHub Issues 提供診斷工具的輸出結果

---

## ✨ 成功指標

如果一切正常，您應該能夠：

- [x] 執行診斷工具無錯誤
- [x] 開啟操作手冊（瀏覽器自動開啟）
- [x] 啟動測試平台（Web 控制台）
- [x] 執行測試並看到報告
- [x] 在報告中看到綠色的 ✅ 通過標記

---

## 🎯 下一步

成功完成上述步驟後，請參考：

1. **[操作手冊](docs/index.html)**：詳細了解五個測試流程
2. **[新手入門指南](GETTING_STARTED.md)**：深入學習 BDD 測試編寫
3. **[TEST_PLAN.md](Automation_testcase/Test_cases/TEST_PLAN.md)**：理解測試策略

祝測試愉快！🚀
