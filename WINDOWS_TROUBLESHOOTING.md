# Windows 11 疑難排解指南

## 🔍 快速診斷

執行 **診斷工具.bat** 來自動檢查您的環境：

```
雙擊執行: 診斷工具.bat
```

---

## ❌ 常見問題與解決方法

### 問題 1: 找不到 Python

**症狀：**
```
❌ 錯誤: 找不到 Python
```

**解決方法：**

#### 方法 A: 安裝 Python（推薦）
1. 前往 https://www.python.org/downloads/
2. 下載 Python 3.8 或更新版本
3. ⚠️ **重要**: 安裝時勾選「Add Python to PATH」
4. 重新開啟命令提示字元

#### 方法 B: 手動加入 PATH
1. 按 `Win + X`，選擇「系統」
2. 點擊「進階系統設定」→「環境變數」
3. 在「系統變數」中找到 `Path`，點擊「編輯」
4. 新增 Python 安裝路徑（例如：`C:\Python312\` 和 `C:\Python312\Scripts\`）
5. 按「確定」並重新開啟命令提示字元

#### 驗證安裝：
```cmd
python --version
```

---

### 問題 2: Port 6688 被占用

**症狀：**
```
⚠️ 警告: Port 6688 被其他程序占用
```

**解決方法：**

#### 方法 A: 關閉占用的程式
1. 按 `Ctrl + Shift + Esc` 開啟工作管理員
2. 找到占用 Port 的進程（通常是 `python.exe`）
3. 右鍵 → 結束工作

#### 方法 B: 使用命令關閉
```cmd
REM 查詢占用 Port 6688 的 PID
netstat -ano | findstr :6688

REM 結束該進程（將 PID 替換成實際的數字）
taskkill /F /PID [PID]
```

#### 方法 C: 使用不同的 Port
編輯 `main_menu.bat`，修改：
```batch
set "PORT=6688"  →  set "PORT=8888"
```

---

### 問題 3: 找不到 docs\server.py

**症狀：**
```
❌ 錯誤: 找不到 docs\server.py
```

**解決方法：**

#### 方法 A: 檢查檔案完整性
1. 確認專案資料夾中有 `docs\` 子資料夾
2. 確認 `docs\server.py` 檔案存在
3. 如果檔案缺失，請重新從 GitHub 下載：
   ```cmd
   git clone https://github.com/PorscheWen/SQA_Inspetion_App.git
   ```

#### 方法 B: 檢查解壓縮
- 如果是從 ZIP 下載，請確保完整解壓縮所有檔案
- 避免在壓縮檔內直接執行

#### 方法 C: 檢查防毒軟體
- 某些防毒軟體可能會隔離 `.py` 檔案
- 檢查防毒軟體的隔離區並還原檔案
- 將專案資料夾加入白名單

---

### 問題 4: 防火牆阻擋

**症狀：**
```
⚠️ 警告: 可能無法綁定 Port 6688
```

**解決方法：**

#### 方法 A: 新增防火牆例外
1. 開啟「Windows Defender 防火牆」
2. 點擊「允許應用程式或功能通過 Windows Defender 防火牆」
3. 點擊「變更設定」
4. 點擊「允許其他應用程式」
5. 瀏覽並選擇 `python.exe`（通常在 `C:\Python312\python.exe`）
6. 勾選「私人」和「公用」
7. 按「確定」

#### 方法 B: 以系統管理員身分執行
1. 右鍵點擊 `main_menu.bat`
2. 選擇「以系統管理員身分執行」

---

### 問題 5: 批次檔閃退（視窗立即關閉）

**症狀：**
- 雙擊 `.bat` 檔案後視窗一閃即逝

**解決方法：**

#### 方法 A: 從命令提示字元執行
1. 按 `Win + R`
2. 輸入 `cmd` 並按 Enter
3. 使用 `cd` 切換到專案目錄：
   ```cmd
   cd C:\path\to\SQA_Inspetion_App
   ```
4. 執行：
   ```cmd
   main_menu.bat
   ```
5. 現在可以看到完整的錯誤訊息

#### 方法 B: 修改批次檔（已包含在新版本）
- 新版批次檔已經在錯誤時自動暫停
- 如果還是閃退，檢查是否使用最新版本

---

### 問題 6: 瀏覽器無法開啟或顯示錯誤

**症狀：**
- 伺服器啟動但瀏覽器無法連線
- 顯示「無法連線到這個網站」

**解決方法：**

#### 方法 A: 手動開啟瀏覽器
1. 等待伺服器完全啟動（約 3-5 秒）
2. 開啟瀏覽器
3. 在網址列輸入：`http://localhost:6688/docs/index.html`

#### 方法 B: 檢查伺服器狀態
確認命令提示字元中沒有錯誤訊息，應顯示：
```
SQA Inspection App — 操作手冊伺服器
  http://localhost:6688/docs/index.html
```

#### 方法 C: 清除瀏覽器快取
1. 按 `Ctrl + Shift + Delete`
2. 清除「快取的圖片和檔案」
3. 重新整理頁面 (`F5`)

---

### 問題 7: 編碼亂碼

**症狀：**
- 中文顯示為亂碼或問號

**解決方法：**

#### 方法 A: 設定命令提示字元編碼
在命令提示字元中執行：
```cmd
chcp 65001
```

#### 方法 B: 使用 Windows Terminal（推薦）
1. 從 Microsoft Store 安裝「Windows Terminal」
2. 使用 Windows Terminal 執行批次檔
3. Windows Terminal 預設支援 UTF-8

---

### 問題 8: 公司電腦無法安裝 Python

**症狀：**
- 公司電腦有權限限制
- IT 部門不允許安裝 Python
- 使用受管理的企業環境

**解決方法：**

#### 方法 A: 使用無 Python 版本工具（推薦）

**1. 查看操作手冊（離線版）**
```cmd
雙擊： main_menu.bat（選項 [8]）
```

或直接開啟：
```cmd
start docs\index.html
```

**2. 執行測試（不需要 Python）**
```cmd
雙擊： run_tests.bat
```

**3. 查看測試報告（不需要 Python）**
```cmd
雙擊： 開啟測試報告.bat
```

#### 方法 B: 完整的無 Python 工作流程

詳細說明請參考：
```cmd
雙擊： main_menu.bat（選項 [11]）
```

或查看 [NO_PYTHON_GUIDE.md](NO_PYTHON_GUIDE.md)

#### 功能對照

| 功能 | 需要 Python | 替代方案 |
|------|------------|---------|
| 操作手冊 | ❌ | 離線 HTML 版 |
| 執行測試 | ❌ | 使用 dotnet test |
| 查看報告 | ❌ | 直接開啟 HTML |
| Web 控制台 | ✅ | 命令列執行 |

#### 核心功能不受影響

**重要**：即使沒有 Python，您仍然可以：
- ✅ 執行所有測試
- ✅ 查看測試報告
- ✅ 編輯測試案例
- ✅ 閱讀操作手冊
- ✅ 啟動被測程式

唯一的差異是無法使用 Web 控制台（互動式介面）。

---

## 🛠️ 進階診斷

### 手動測試 Python 伺服器

```cmd
cd C:\path\to\SQA_Inspetion_App\docs
python server.py
```

查看詳細錯誤訊息。

### 檢查 Python 模組

```cmd
python -c "import http.server, socketserver, json, urllib"
```

如果出現錯誤，表示 Python 安裝不完整。

### 測試 Port 綁定

```cmd
python -c "import socket; s=socket.socket(); s.bind(('127.0.0.1', 6688)); print('Port 6688 可用'); s.close()"
```

---

## 📞 還是無法解決？

### 收集診斷資訊

1. 執行 **診斷工具.bat**
2. 將所有輸出訊息複製
3. 在 GitHub Issues 中回報問題：
   - 作業系統版本
   - Python 版本
   - 完整錯誤訊息
   - 診斷工具輸出

### 臨時替代方案

如果無法啟動伺服器，可以直接開啟 HTML 檔案：

```cmd
start docs\index.html
```

⚠️ 注意：直接開啟 HTML 檔案時，部分功能（如一鍵執行 .bat）可能無法使用。

---

## ✅ 成功標誌

如果一切正常，您應該看到：

```
========================================
  SQA Inspection App - 操作手冊
========================================

[1/5] 檢查 Python 環境...
✅ Python 環境正常: Python 3.12.1

[2/5] 檢查必要檔案...
✅ 必要檔案存在

[3/5] 檢查 Port 6688 是否被占用...
✅ Port 6688 可用

[4/5] 檢查網路權限...
✅ 具有綁定 Port 6688 的權限

[5/5] 環境檢查完成

正在啟動操作手冊伺服器 (port 6688) ...

📌 重要提示:
   • 瀏覽器會自動開啟操作手冊
   • 保持此視窗開啟，伺服器才能運作
   • 按 Ctrl+C 可停止伺服器
```

然後瀏覽器會自動開啟操作手冊頁面。

---

## 🔗 相關資源

- [Python 官方網站](https://www.python.org/)
- [GitHub 專案](https://github.com/PorscheWen/SQA_Inspetion_App)
- [新手入門指南](GETTING_STARTED.md)
