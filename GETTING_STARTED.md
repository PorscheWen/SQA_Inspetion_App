# SQA Inspection App — 新手入門指南

> 🎯 **5 分鐘快速上手** Semi Inspection Desktop 的 FlaUI BDD 自動化測試平台

---

## 📖 這是什麼專案？

這是一個**完整的自動化測試系統**，包含：

1. **被測應用程式** (SUT: System Under Test)
   - **Semi Inspection Desktop** — 半導體檢測桌面應用程式（Windows Forms）
   - 功能：匯入 Recipe（配方）、查看參數、繪製缺陷圖表、模擬檢測

2. **自動化測試框架**
   - **FlaUI** — Windows UI 自動化測試工具（類似 Selenium）
   - **SpecFlow** — BDD (行為驅動開發) 框架，使用 Gherkin 語法
   - **10 個測試案例** (TC01–TC10) — 涵蓋功能測試與負面測試

3. **完整工具鏈**
   - 一鍵執行腳本
   - Web 控制台（勾選 TC、執行測試）
   - HTML 測試報告
   - 互動式操作手冊

---

## 🎨 專案架構圖

```
┌─────────────────────────────────────────────────────┐
│                  SQA Inspection App                  │
├─────────────────────────────────────────────────────┤
│                                                       │
│  ┌─────────────────┐         ┌──────────────────┐   │
│  │  被測應用程式    │         │   測試規格文件    │   │
│  │                 │         │                  │   │
│  │ SemiInspection  │◄────────│  TPS.md          │   │
│  │ Desktop.exe     │  驗證   │  (Gherkin)       │   │
│  │                 │         │                  │   │
│  │ • 匯入 Recipe   │         │  TEST_PLAN.md    │   │
│  │ • 查看參數      │         │  (10個測試案例)   │   │
│  │ • 缺陷圖表      │         │                  │   │
│  └─────────────────┘         └──────────────────┘   │
│           ▲                            │             │
│           │                            ▼             │
│           │                  ┌──────────────────┐   │
│           │                  │  BDD 自動化測試   │   │
│           │                  │                  │   │
│           │                  │ • Feature 檔案   │   │
│           └──────────────────│ • Step Definitions│  │
│               FlaUI 操作     │ • Page Objects   │   │
│                              │                  │   │
│                              │ dotnet test      │   │
│                              └──────────────────┘   │
│                                       │             │
│                                       ▼             │
│                              ┌──────────────────┐   │
│                              │   測試報告        │   │
│                              │                  │   │
│                              │ • HTML 報告      │   │
│                              │ • JUnit XML      │   │
│                              │ • 截圖記錄        │   │
│                              └──────────────────┘   │
│                                                       │
└─────────────────────────────────────────────────────┘
```

---

## 🚀 5 步驟快速開始

### 步驟 1：確認環境

**必需軟體**（Windows 環境）：
- ✅ Windows 10/11
- ✅ .NET SDK 8.0+
- ✅ MSBuild（建置被測 App）
- ✅ Python 3.x（Web 控制台，可選）

**檢查方法**：
```bat
dotnet --version      # 應顯示 8.0.x
python --version      # 應顯示 3.x
```

### 步驟 2：開啟操作手冊

#### Windows 環境

雙擊 **`main_menu.bat`**

- 🌐 自動在瀏覽器開啟：http://localhost:6688/docs/index.html
- 📚 閱讀五個章節，了解完整流程
- 🖱️ 可直接在網頁上點擊按鈕執行 .bat 腳本

#### Linux / Codespaces 環境

執行 **`./open_user_manual.sh`**

```bash
# 賦予執行權限（首次執行）
chmod +x open_user_manual.sh

# 啟動操作手冊伺服器
./open_user_manual.sh
```

腳本會自動執行 **5 項環境檢查**：
1. ✅ 檢查 Python 環境
2. ✅ 檢查必要檔案
3. ✅ 檢查 Port 6688 是否被占用
4. ✅ 檢查網路權限
5. ✅ 環境檢查完成

#### 🚨 Codespaces 特別注意

如果在 **GitHub Codespaces** 中遇到無法開啟 http://localhost:6688 的問題：

**方法 1：快速檢查**
```bash
# 執行 Port Forwarding 狀態檢查
./check_port_forwarding.sh
```

**方法 2：手動設定 Port Forwarding**
1. 按 `Ctrl + `` ` 開啟終端機面板
2. 切換到 **"PORTS"** 標籤
3. 找到 Port **6688**
4. 右鍵點擊 → **"Port Visibility"** → 選擇 **"Public"**
5. 複製 **"Forwarded Address"** 欄位的 URL（例如：`https://xxx-6688.app.github.dev`）
6. 在瀏覽器中開啟：`<URL>/docs/index.html`

**方法 3：自動化設定**

專案已包含 `.devcontainer/devcontainer.json` 配置文件，下次重新啟動 Codespace 時會自動設定。

📖 **詳細說明**：請參考 [PORT_FORWARDING_GUIDE.md](PORT_FORWARDING_GUIDE.md)

### 步驟 3：啟動被測應用程式

**方法 A：使用腳本**
```bat
啟動InspectionApp.bat
```

**方法 B：手動建置**
```bat
build_semi.bat
run_semi.bat
```

**驗證成功**：
- ✅ 視窗標題顯示 "Semi Inspection Desktop"
- ✅ 左側顯示檔案樹（File Tree）
- ✅ 工具列有 Import Recipe、About 等按鈕

### 步驟 4：執行第一個測試

**方式 A：執行全部測試（推薦新手）**
```bat
run_tests.bat
```

這會：
1. 建置被測應用程式
2. 建置測試專案
3. 執行所有 10 個測試案例
4. 自動開啟 HTML 報告

**方式 B：執行單一測試**
```bat
執行單一測試.bat TC01
```

**方式 C：使用 Web 控制台**
```bat
啟動測試平台.bat
```
- 開啟 http://localhost:6690/
- 勾選要執行的測試案例
- 點擊「執行已勾選的測試」

### 步驟 5：查看測試報告

雙擊 **`開啟測試報告.bat`**

報告位置：
```
Automation_testcase/Project_FlaUIBDD/
  Testcase_Inspection_App_FlaUI_BDD/
    reports/
      ├── TestResultReport.html      ← 主要報告
      ├── SemiInspectionTestReport.html
      ├── junit-results.xml
      └── media/                     ← 失敗截圖
```

**報告內容包含**：
- ✅ 測試通過率
- 📊 每個測試案例的結果（Pass/Fail）
- 📸 失敗時的截圖
- ⏱️ 執行時間
- 📝 詳細步驟記錄

---

## 🤖 FlaUI 操作詳解

### 什麼是 FlaUI？

**FlaUI** 是 .NET 平台的 **UI 自動化測試框架**，用於測試 Windows 桌面應用程式（WPF、WinForms、Win32）。

- 類似於 Web 測試的 **Selenium**
- 基於 Windows **UI Automation API**
- 支援 UIA2 和 UIA3 兩種引擎（本專案使用 UIA3）

### 🎯 核心概念

#### 1. Automation Element（自動化元素）

所有 UI 控制項都是 `AutomationElement`：

```csharp
// 按鈕、文字框、表格、樹狀視圖等都是 AutomationElement
AutomationElement button = window.FindFirstDescendant(cf => cf.ByAutomationId("btnImportRecipe"));
AutomationElement textBox = window.FindFirstDescendant(cf => cf.ByName("txtToolLog"));
AutomationElement dataGrid = window.FindFirstDescendant(cf => cf.ByClassName("DataGridView"));
```

#### 2. 查找策略（Locators）

| 方法 | 說明 | 範例 | 優先級 |
|------|------|------|--------|
| `ByAutomationId` | 使用控制項 ID（最穩定） | `cf.ByAutomationId("btnImportRecipe")` | ⭐⭐⭐⭐⭐ |
| `ByName` | 使用控制項名稱（顯示文字） | `cf.ByName("Import Recipe")` | ⭐⭐⭐ |
| `ByClassName` | 使用控制項類別 | `cf.ByClassName("DataGridView")` | ⭐⭐ |
| `ByControlType` | 使用控制項類型 | `cf.ByControlType(ControlType.Button)` | ⭐ |

**建議**：優先使用 `AutomationId`（最穩定且不受語言影響）

#### 3. 操作方法

```csharp
// 點擊
button.Click();
button.DoubleClick();

// 輸入文字
textBox.Enter("Hello World");
textBox.Text = "Hello World";  // 直接設定

// 鍵盤操作
Keyboard.Press(VirtualKeyShort.KEY_I, modifiers: ModifierKeys.Control);  // Ctrl+I
Keyboard.Type("test.json");

// 滑鼠操作
Mouse.MoveTo(element.BoundingRectangle.Center());
Mouse.Click(MouseButton.Left);

// 等待元素
var element = Retry.WhileNull(
    () => window.FindFirstDescendant(cf => cf.ByName("RawData")),
    TimeSpan.FromSeconds(10)
).Result;
```

### 📝 Page Object 模式

本專案使用 **Page Object Pattern** 封裝 UI 操作。

#### BasePage（基礎頁面類別）

所有 Page Object 繼承自 `BasePage`，提供通用查找方法：

```csharp
public abstract class BasePage
{
    protected readonly Window Window;
    protected readonly UIA3Automation Automation;
    
    // 查找方法
    protected AutomationElement? FindByName(string name, int timeoutMs = 0);
    protected AutomationElement? FindByAutomationId(string automationId, int timeoutMs = 0);
    protected AutomationElement? FindByNameContains(string partial, int timeoutMs = 5000);
    protected AutomationElement? FindWinFormsControl(string controlName);
}
```

#### MainWindowPage（主視窗操作）

封裝主視窗的所有操作：

```csharp
public class MainWindowPage : BasePage
{
    // 點擊工具列按鈕
    public void ClickToolbar(string buttonText)
    {
        // 1. 先嘗試快捷鍵（更快速）
        if (TryInvokeShortcut(shortcut))
            return;
            
        // 2. 再嘗試點擊按鈕
        var button = FindByAutomationId("btnImportRecipe");
        button.Click();
    }
    
    // 發送快捷鍵
    public void SendShortcut(VirtualKeyShort key, bool ctrl = false)
    {
        FocusMainWindow();
        if (ctrl)
            Keyboard.Press(key, ModifierKeys.Control);
        else
            Keyboard.Press(key);
    }
}
```

#### WorkspacePage（工作區操作）

封裝資料顯示區域的操作：

```csharp
public class WorkspacePage : BasePage
{
    // 檢查樹狀視圖是否可見
    public bool IsTreeVisible(int waitMs = 10000)
    {
        return WaitForTree(waitMs) != null;
    }
    
    // 雙擊檔案樹項目
    public void DoubleClickTreeItem(string partialName)
    {
        var tree = WaitForTree(8000);
        foreach (var el in tree.FindAllDescendants())
        {
            var name = el.Name ?? string.Empty;
            if (name.Contains(partialName, StringComparison.OrdinalIgnoreCase))
            {
                el.DoubleClick();
                Thread.Sleep(1500);
                return;
            }
        }
    }
    
    // 檢查日誌是否包含文字
    public bool LogContains(string expected, int waitMs = 10000)
    {
        var deadline = DateTime.UtcNow.AddMilliseconds(waitMs);
        while (DateTime.UtcNow < deadline)
        {
            if (TryReadLogContains(expected))
                return true;
            Thread.Sleep(250);
        }
        return false;
    }
}
```

#### FileDialogPage（檔案對話框操作）

封裝 Windows 檔案對話框的操作：

```csharp
public class FileDialogPage
{
    // 選擇並開啟檔案
    public void OpenFile(string fullPath, int timeoutMs = 12000)
    {
        // 1. 等待對話框出現
        var dialog = WaitForOpenDialog(timeoutMs);
        
        // 2. 聚焦對話框
        FocusDialogSafe(dialog);
        
        // 3. 尋找檔名欄位（AutomationId: 1148）
        var fileNameField = FindFileNameField(dialog);
        
        // 4. 輸入檔案路徑
        TrySetPathInFileNameField(dialog, fileNameField, fullPath);
        
        // 5. 點擊「開啟」按鈕
        ConfirmOpenAndWait(dialog);
    }
}
```

### 🎨 實戰範例

#### 範例 1：點擊工具列按鈕

**需求**：點擊 "Import Recipe" 按鈕

**Step Definition**：
```csharp
[When(@"I click toolbar ""(.*)""")]
public void WhenIClickToolbar(string buttonText)
{
    Main.ClickToolbar(buttonText);  // 呼叫 Page Object
    Thread.Sleep(500);  // 等待 UI 更新
}
```

**Page Object 實作**：
```csharp
public void ClickToolbar(string buttonText)
{
    // 映射表：按鈕文字 → (AutomationId, 快捷鍵)
    var toolbarMap = new Dictionary<string, (string, VirtualKeyShort?)>
    {
        ["Import Recipe"] = ("btnImportRecipe", VirtualKeyShort.KEY_I),
        ["RawData"] = ("btnParameters", VirtualKeyShort.KEY_E),
        ["Defect Chart"] = ("btnDefectChart", VirtualKeyShort.KEY_D),
    };
    
    if (toolbarMap.TryGetValue(buttonText, out var mapped))
    {
        // 1. 優先使用快捷鍵（Ctrl+I）
        if (mapped.Item2.HasValue)
        {
            Keyboard.Press(mapped.Item2.Value, ModifierKeys.Control);
            return;
        }
        
        // 2. 使用 AutomationId 查找並點擊
        var button = FindByAutomationId(mapped.Item1);
        button?.Click();
    }
}
```

#### 範例 2：選擇檔案

**需求**：在檔案對話框中選擇 `InspectionRecipe_Sample.json`

**Step Definition**：
```csharp
[When(@"I select file ""(.*)"" in the file dialog")]
public void WhenISelectFileInFileDialog(string fileName)
{
    var path = Path.Combine(ConfigHelper.GetRecipeDataDirectory(), fileName);
    FileDialog.OpenFile(path);  // 呼叫 FileDialogPage
    Workspace.WaitAfterDataTableAction();
}
```

**Page Object 實作**：
```csharp
public void OpenFile(string fullPath, int timeoutMs = 12000)
{
    // 1. 等待對話框（最多 12 秒）
    var dialog = WaitForOpenDialog(timeoutMs);
    if (dialog == null)
        throw new InvalidOperationException("找不到開啟檔案對話框");
    
    // 2. 聚焦對話框（確保接收輸入）
    SetForegroundWindow(dialog.NativeWindowHandle);
    Thread.Sleep(500);
    
    // 3. 嘗試在檔案清單中選取（如果已顯示）
    if (TrySelectExistingFileInDialog(dialog, fullPath))
    {
        ConfirmOpenAndWait(dialog);
        return;
    }
    
    // 4. 尋找檔名欄位（AutomationId: 1148）
    var fileNameField = dialog.FindFirstDescendant(cf => cf.ByAutomationId("1148"));
    
    // 5. 直接設定文字（使用 Win32 SendMessage）
    if (fileNameField != null)
    {
        SendMessageSetText(fileNameField.NativeWindowHandle, WM_SETTEXT, IntPtr.Zero, fullPath);
        Thread.Sleep(500);
    }
    
    // 6. 按 Enter 確認
    Keyboard.Press(VirtualKeyShort.RETURN);
    Thread.Sleep(1000);
}
```

#### 範例 3：雙擊檔案樹項目

**需求**：在檔案樹中雙擊 `InspectionRecipe_Sample.json`

**Step Definition**：
```csharp
[When(@"I double-click (.+) in the file tree")]
public void WhenIDoubleClickInFileTree(string fileName)
{
    Workspace.DoubleClickTreeItem(fileName);
    
    // 如果 DataGrid 沒出現，點擊 RawData 按鈕
    if (!Workspace.IsGridVisible())
    {
        Main.ClickToolbar("RawData");
    }
}
```

**Page Object 實作**：
```csharp
public void DoubleClickTreeItem(string partialName)
{
    // 1. 等待樹狀視圖出現
    var tree = WaitForTree(8000);
    if (tree == null)
    {
        Console.WriteLine("TreeView not found");
        return;
    }
    
    // 2. 遍歷所有子節點
    foreach (var el in tree.FindAllDescendants())
    {
        var name = el.Name ?? string.Empty;
        
        // 3. 找到包含指定名稱的項目
        if (name.Contains(partialName, StringComparison.OrdinalIgnoreCase))
        {
            // 4. 雙擊
            el.DoubleClick();
            
            // 5. 擷取操作截圖（除錯用）
            ActionScreenshotHelper.CaptureClick($"雙擊 {partialName}", Window, el);
            
            Thread.Sleep(1500);
            return;
        }
    }
    
    Console.WriteLine($"Tree item not found: {partialName}");
}
```

#### 範例 4：驗證日誌內容

**需求**：檢查日誌視窗是否包含 "Import Recipe"

**Step Definition**：
```csharp
[Then(@"the log should contain ""(.*)""")]
public void ThenTheLogShouldContain(string expected)
{
    var found = Workspace.LogContains(expected, waitMs: 10000);
    ClassicAssert.IsTrue(found, $"日誌中找不到: {expected}");
}
```

**Page Object 實作**：
```csharp
public bool LogContains(string expected, int waitMs = 10000)
{
    var deadline = DateTime.UtcNow.AddMilliseconds(waitMs);
    
    // 輪詢檢查（最多 10 秒）
    while (DateTime.UtcNow < deadline)
    {
        // 1. 尋找日誌控制項（txtToolLog）
        var logBox = FindByAutomationId("txtToolLog");
        if (logBox == null)
        {
            Thread.Sleep(250);
            continue;
        }
        
        // 2. 讀取日誌內容
        var logText = ReadText(logBox);
        
        // 3. 檢查是否包含預期文字
        if (logText.Contains(expected, StringComparison.OrdinalIgnoreCase))
        {
            return true;
        }
        
        Thread.Sleep(250);  // 等待後重試
    }
    
    return false;  // 超時
}

// 讀取控制項文字的輔助方法
protected static string ReadText(AutomationElement element)
{
    // 1. 嘗試使用 Win32 SendMessage（最可靠）
    var nativeText = ReadNativeWindowText(element);
    if (!string.IsNullOrEmpty(nativeText))
        return nativeText;
    
    // 2. 嘗試使用 TextBox 模式
    try
    {
        var textBox = element.AsTextBox();
        if (textBox != null && !string.IsNullOrEmpty(textBox.Text))
            return textBox.Text;
    }
    catch { }
    
    // 3. 嘗試使用 Value Pattern
    if (element.Patterns.Value.IsSupported)
    {
        var value = element.Patterns.Value.Pattern.Value.Value;
        if (!string.IsNullOrEmpty(value))
            return value;
    }
    
    // 4. 最後使用 Name 屬性
    return element.Name ?? string.Empty;
}
```

### 🛠️ 常用技巧

#### 1. 等待元素出現

```csharp
// 使用 Retry.WhileNull
var element = Retry.WhileNull(
    () => window.FindFirstDescendant(cf => cf.ByAutomationId("btnImportRecipe")),
    TimeSpan.FromSeconds(10)  // 最多等 10 秒
).Result;

// 使用輪詢檢查
var deadline = DateTime.UtcNow.AddSeconds(10);
AutomationElement? element = null;
while (DateTime.UtcNow < deadline)
{
    element = window.FindFirstDescendant(cf => cf.ByName("RawData"));
    if (element != null) break;
    Thread.Sleep(250);
}
```

#### 2. 聚焦視窗

```csharp
// 確保視窗有焦點（接收鍵盤輸入）
protected void FocusMainWindow()
{
    if (!Window.IsOffscreen)
    {
        Window.Focus();
        Thread.Sleep(200);
    }
}

// 使用 Win32 API 強制前景
[DllImport("user32.dll")]
private static extern bool SetForegroundWindow(IntPtr hWnd);

SetForegroundWindow(window.NativeWindowHandle);
```

#### 3. 處理多個視窗

```csharp
// 尋找所有視窗
var desktop = Automation.GetDesktop();
var allWindows = desktop.FindAllChildren();

// 找到特定標題的視窗
var dialog = allWindows.FirstOrDefault(w => 
    w.Name.Contains("開啟", StringComparison.OrdinalIgnoreCase));
```

#### 4. 使用快捷鍵（更快更穩定）

```csharp
// Ctrl + I（匯入 Recipe）
Keyboard.Press(VirtualKeyShort.KEY_I, ModifierKeys.Control);

// Ctrl + E（查看 RawData）
Keyboard.Press(VirtualKeyShort.KEY_E, ModifierKeys.Control);

// Ctrl + D（繪製圖表）
Keyboard.Press(VirtualKeyShort.KEY_D, ModifierKeys.Control);

// 優先使用快捷鍵，失敗才用滑鼠點擊（降低失敗率）
```

#### 5. 擷取截圖（除錯用）

```csharp
// 擷取整個視窗
var capture = Window.Capture();
capture.Save("screenshot.png");

// 使用 ActionScreenshotHelper（自動加入報告）
ActionScreenshotHelper.CaptureAction("點擊按鈕", window);
ActionScreenshotHelper.CaptureClick("雙擊項目", window, element);
```

#### 6. 讀取表格資料

```csharp
// 尋找 DataGrid
var grid = window.FindFirstDescendant(cf => cf.ByClassName("DataGridView"));

// 取得所有列
var rows = grid.FindAllChildren(cf => cf.ByControlType(ControlType.DataItem));

// 讀取每一列的內容
foreach (var row in rows)
{
    var cells = row.FindAllChildren();
    foreach (var cell in cells)
    {
        Console.WriteLine($"Cell: {cell.Name}");
    }
}
```

### 🐛 除錯技巧

#### 1. 使用 FlaUI Inspector

**安裝**：
```bash
cd Automation_testcase\Project_FlaUIBDD\Testcase_Inspection_App_FlaUI_BDD\tools
.\install-flauinspect.ps1
```

**使用方法**：
1. 執行 `open_inspector.bat`
2. 點擊 **Hover Mode**
3. 將滑鼠移到控制項上
4. 查看屬性：
   - `AutomationId`（用於程式碼）
   - `Name`（顯示名稱）
   - `ClassName`（控制項類別）
   - `ControlType`（控制項類型）

#### 2. 輸出除錯資訊

```csharp
// 在 Page Object 中加入 Console.WriteLine
public void ClickToolbar(string buttonText)
{
    Console.WriteLine($"[DEBUG] 尋找按鈕: {buttonText}");
    
    var button = FindByAutomationId("btnImportRecipe");
    if (button == null)
    {
        Console.WriteLine($"[ERROR] 找不到按鈕: {buttonText}");
        return;
    }
    
    Console.WriteLine($"[INFO] 找到按鈕，準備點擊");
    button.Click();
    Console.WriteLine($"[INFO] 已點擊按鈕");
}
```

#### 3. 加大等待時間（排除時序問題）

```csharp
// 暫時加大等待時間
Thread.Sleep(2000);  // 從 500ms 改為 2000ms

// 或增加 Retry 超時時間
var element = Retry.WhileNull(
    () => window.FindFirstDescendant(cf => cf.ByName("RawData")),
    TimeSpan.FromSeconds(30)  // 從 10 秒改為 30 秒
).Result;
```

#### 4. 列出所有子元素

```csharp
// 輸出視窗中的所有控制項
var allElements = window.FindAllDescendants();
foreach (var el in allElements)
{
    Console.WriteLine($"Name: {el.Name}, AutomationId: {el.AutomationId}, ClassName: {el.ClassName}");
}
```

### 📚 FlaUI 最佳實踐

#### ✅ DO（建議）

1. **優先使用 AutomationId**
   ```csharp
   FindByAutomationId("btnImportRecipe")  // ✅ 穩定
   FindByName("Import Recipe")            // ⚠️ 受語言影響
   ```

2. **使用 Page Object 封裝操作**
   ```csharp
   // ✅ 好的做法
   Main.ClickToolbar("Import Recipe");
   
   // ❌ 壞的做法（不要在 Step 中直接操作）
   var button = Window.FindFirstDescendant(...);
   button.Click();
   ```

3. **優先使用快捷鍵**
   ```csharp
   // ✅ 更快更穩定
   Keyboard.Press(VirtualKeyShort.KEY_I, ModifierKeys.Control);
   
   // ⚠️ 較慢且可能失敗
   button.Click();
   ```

4. **加入適當的等待**
   ```csharp
   button.Click();
   Thread.Sleep(500);  // 等待 UI 更新
   ```

5. **使用輪詢檢查（處理非同步更新）**
   ```csharp
   // ✅ 輪詢直到條件滿足
   var deadline = DateTime.UtcNow.AddSeconds(10);
   while (DateTime.UtcNow < deadline)
   {
       if (CheckCondition()) return true;
       Thread.Sleep(250);
   }
   ```

#### ❌ DON'T（避免）

1. ❌ **不要在 Step Definitions 中寫 FlaUI 操作**
   ```csharp
   // ❌ 錯誤：直接在 Step 中操作
   [When(@"I click Import Recipe")]
   public void WhenIClickImportRecipe()
   {
       var button = _window.FindFirstDescendant(...);
       button.Click();
   }
   
   // ✅ 正確：透過 Page Object
   [When(@"I click Import Recipe")]
   public void WhenIClickImportRecipe()
   {
       _mainWindow.ClickToolbar("Import Recipe");
   }
   ```

2. ❌ **不要寫死等待時間**
   ```csharp
   // ❌ 固定等待（浪費時間或不夠）
   Thread.Sleep(5000);
   var element = window.FindFirstDescendant(...);
   
   // ✅ 使用 Retry（一旦找到就繼續）
   var element = Retry.WhileNull(
       () => window.FindFirstDescendant(...),
       TimeSpan.FromSeconds(5)
   ).Result;
   ```

3. ❌ **不要忽略 null 檢查**
   ```csharp
   // ❌ 可能拋出 NullReferenceException
   var button = FindByAutomationId("btnTest");
   button.Click();
   
   // ✅ 檢查 null
   var button = FindByAutomationId("btnTest");
   if (button == null)
       throw new ElementNotFoundException("找不到按鈕");
   button.Click();
   ```

4. ❌ **不要重複查找元素**
   ```csharp
   // ❌ 每次都重新查找
   window.FindFirstDescendant(...).Click();
   window.FindFirstDescendant(...).GetText();
   
   // ✅ 查找一次，重複使用
   var element = window.FindFirstDescendant(...);
   element.Click();
   var text = element.GetText();
   ```

### 🎓 學習資源

- **FlaUI GitHub**：https://github.com/FlaUI/FlaUI
- **FlaUI 文件**：https://github.com/FlaUI/FlaUI/wiki
- **本專案範例**：
  - `PageObjects/MainWindowPage.cs`
  - `PageObjects/WorkspacePage.cs`
  - `PageObjects/FileDialogPage.cs`
  - `StepDefinitions/Inspection_AppSteps.cs`

---

## 📚 學習路徑（建議順序）

### 🔰 Level 1：了解專案（30 分鐘）

1. **閱讀 README.md** — 了解專案結構
2. **開啟操作手冊** — 瀏覽五個章節的標題
3. **執行 run_tests.bat** — 觀看自動化測試運行
4. **查看測試報告** — 理解測試結果格式

### 🔰 Level 2：理解測試規格（1 小時）

1. **閱讀 TEST_PLAN.md** — 了解 10 個測試案例
   - 路徑：`Automation_testcase/Test_cases/TEST_PLAN.md`
   - 內容：每個 TC 的目的、步驟、預期結果

2. **閱讀 TPS.md** — 學習 Gherkin 語法
   - 路徑：`Automation_testcase/Test_cases/TPS.md`
   - 格式：Given / When / Then

3. **手動操作被測應用程式** — 熟悉 UI
   - 執行 `run_semi.bat`
   - 嘗試：匯入 Recipe、查看參數、繪製圖表

### 🔰 Level 3：理解自動化測試（2 小時）

1. **閱讀操作手冊第 1 章**：TPS 轉 BDD
   - 理解三層文件鏈
   - TPS → Feature → StepDefinitions → PageObjects

2. **查看 Feature 檔案**
   ```
   Automation_testcase/Project_FlaUIBDD/
     Testcase_Inspection_App_FlaUI_BDD/
       Features/Inspection_App.feature
   ```

3. **查看 Step Definitions**
   ```
   StepDefinitions/Inspection_AppSteps.cs
   ```

4. **查看 Page Objects**
   ```
   PageObjects/
     ├── MainWindowPage.cs
     ├── WorkspacePage.cs
     └── FileDialogPage.cs
   ```

5. **學習 FlaUI 基礎**（⭐ 新增）
   - 閱讀本文「🤖 FlaUI 操作詳解」章節
   - 理解 Page Object 模式
   - 查看實戰範例（4 個完整範例）

### 🔰 Level 4：修改與維護測試（2-3 小時）

1. **閱讀操作手冊第 2 章**：修改 BDD
2. **閱讀操作手冊第 4 章**：修復測試
3. **安裝 FlaUI Inspector**（⭐ 重要）
   ```bat
   cd Automation_testcase\Project_FlaUIBDD\Testcase_Inspection_App_FlaUI_BDD\tools
   .\install-flauinspect.ps1
   open_inspector.bat
   ```
4. **實作練習**：
   - 使用 Inspector 查看 UI 元素的 AutomationId
   - 修改一個現有的測試步驟
   - 在 Page Object 中新增一個操作方法
   - 執行測試，確認通過

### 🔰 Level 5：新增測試案例（進階）

1. **設計新的測試場景**
2. **在 TPS.md 中撰寫 Gherkin**
3. **更新 Feature 檔案**
4. **實作 Step Definitions**（只做編排和 Assert）
5. **實作 Page Objects**（封裝所有 FlaUI 操作）
   - 使用 Inspector 查找 AutomationId
   - 優先使用快捷鍵
   - 加入適當的等待和錯誤處理
6. **執行測試並除錯**
   - 查看測試報告
   - 分析失敗截圖
   - 使用 Console.WriteLine 輸出除錯資訊

---

## 🎯 10 個測試案例快速導覽

| ID | 類型 | 測試內容 | 複雜度 |
|---|---|---|---|
| **TC01** | 功能 | 匯入 Recipe 檔案 | ⭐⭐ |
| **TC02** | 功能 | 檔案樹顯示 | ⭐ |
| **TC03** | 功能 | 查看參數表格 | ⭐⭐ |
| **TC04** | 功能 | 繪製缺陷圖表 | ⭐⭐⭐ |
| **TC05** | 功能 | 雙擊檔案樹開啟 Recipe | ⭐⭐ |
| **TC06** | 功能 | 關於對話框 | ⭐ |
| **TC07** | 負面 | 匯入無效檔案 | ⭐⭐ |
| **TC08** | 負面 | 未載入資料時繪圖 | ⭐⭐ |
| **TC09** | 負面 | 開啟不存在的檔案 | ⭐⭐ |
| **TC10** | 功能 | 執行檢測模擬 | ⭐⭐⭐ |

**建議新手學習順序**：TC02 → TC06 → TC03 → TC01 → TC05 → TC07

---

## 🔧 重要檔案位置速查

### 📝 測試規格

```
Automation_testcase/Test_cases/
  ├── TPS.md                         ← Gherkin 測試程序
  ├── TEST_PLAN.md                   ← 10 個 TC 詳細說明
  └── SemiInspection_10_TestCases.md ← TC 對照表
```

### 🤖 自動化測試

```
Automation_testcase/Project_FlaUIBDD/
  Testcase_Inspection_App_FlaUI_BDD/
    ├── Features/
    │   └── Inspection_App.feature   ← BDD 場景
    ├── StepDefinitions/
    │   └── Inspection_AppSteps.cs   ← 步驟綁定
    ├── PageObjects/
    │   ├── MainWindowPage.cs        ← 主視窗操作
    │   ├── WorkspacePage.cs         ← 工作區操作
    │   └── FileDialogPage.cs        ← 檔案對話框
    └── reports/                     ← 測試報告
```

### 📚 操作手冊

```
docs/
  ├── index.html                     ← 首頁（總覽）
  ├── 01-tps-to-bdd.html               ← 第 1 章
  ├── 02-edit-bdd.html                ← 第 2 章
  ├── 03-run-tests.html               ← 第 3 章
  ├── 04-fix-tests.html               ← 第 4 章
  └── 05-read-reports.html               ← 第 5 章
```

### 🎮 被測應用程式

```
SemiInspectionDesktop/
  ├── Program.cs                     ← 程式入口
  ├── MainForm.cs                    ← 主視窗
  ├── Models/
  │   └── InspectionRecipeService.cs ← Recipe 服務
  └── UI/
      ├── DefectChartRenderer.cs     ← 圖表繪製
      └── ToolbarIcons.cs            ← 工具列圖示
```

### 🗂️ 測試資料

```
Recipe_data/
  ├── InspectionRecipe_Sample.json   ← 標準測試資料
  └── _invalid_sample.txt            ← 無效檔案（TC07）
```

---

## ❓ 常見問題 (FAQ)

### Q1: 我在 Linux 開發容器中，可以執行測試嗎？

❌ **不行**。FlaUI 和 Semi Inspection Desktop 都是 **Windows 專用**應用程式。

**解決方案**：
- 在 Linux 中：編寫程式碼、修改測試腳本
- 在 Windows 中：執行應用程式和自動化測試
- 使用 Git 在兩個環境間同步

### Q2: 如何查看 UI 元素的 AutomationId？

使用 **FlaUI Inspector**：

1. 執行安裝腳本（只需一次）：
   ```bat
   cd Automation_testcase\Project_FlaUIBDD\
     Testcase_Inspection_App_FlaUI_BDD\tools
   .\install-flauinspect.ps1
   ```

2. 啟動 Inspector：
   ```bat
   open_inspector.bat
   ```

3. 在 Inspector 中：
   - 點擊「Hover Mode」
   - 將滑鼠移到應用程式的控制項上
   - 查看屬性面板中的 AutomationId

**詳細說明**：[tools/README.md](Automation_testcase/Project_FlaUIBDD/Testcase_Inspection_App_FlaUI_BDD/tools/README.md)

### Q3: 測試失敗了，怎麼除錯？

按照以下順序排查：

1. **查看測試報告** — 了解失敗原因
   ```bat
   開啟測試報告.bat
   ```

2. **查看失敗截圖** — 檢查 UI 狀態
   ```
   bin/Release/net8.0-windows/Screenshots/
   ```

3. **手動重現** — 在被測應用程式中手動執行相同步驟
   ```bat
   run_semi.bat
   ```

4. **使用 Inspector** — 確認控制項 ID 是否正確
   ```bat
   open_inspector.bat
   ```

5. **閱讀操作手冊第 4 章** — 修復測試指南
   ```
   docs/04-fix-tests.html
   ```

### Q4: 如何新增一個測試案例？

完整流程（閱讀操作手冊第 2 章）：

1. **在 TPS.md 中撰寫 Gherkin**
   ```gherkin
   Scenario: TC11_New_Feature
     Given the application is launched
     When the user performs new action
     Then the expected result should appear
   ```

2. **更新 Feature 檔案**
   ```gherkin
   @TC11 @Functional
   Scenario: TC11_New_Feature
     Given I have launched the Semi Inspection Desktop application
     ...
   ```

3. **實作 Step Definitions**
   ```csharp
   [When(@"the user performs new action")]
   public void WhenTheUserPerformsNewAction()
   {
       _mainWindow.PerformNewAction();
   }
   ```

4. **實作 Page Objects**
   ```csharp
   public void PerformNewAction()
   {
       var button = _window.FindFirstDescendant(cf => 
           cf.ByAutomationId("btnNewAction"));
       button.Click();
   }
   ```

5. **執行測試**
   ```bat
   執行單一測試.bat TC11
   ```

### Q5: Web 控制台無法開啟？

檢查 Python 和 port：

```bat
# 檢查 Python
python --version

# 手動啟動
cd Automation_testcase\Project_FlaUIBDD\web_dashboard
python server.py

# 如果 port 6690 被佔用，修改 server.py
```

### Q6: 報告中的截圖在哪裡？

**成功的測試**：無截圖

**失敗的測試**：
```
bin/Release/net8.0-windows/
  Screenshots/
    TC01_Failed_20260804_153022.png
    TC08_Failed_20260804_153045.png
```

截圖會自動嵌入 HTML 報告中。

---

## 📖 延伸學習資源

### 官方文件

- **FlaUI 文件**：https://github.com/FlaUI/FlaUI
- **SpecFlow 文件**：https://docs.specflow.org/
- **Gherkin 語法**：https://cucumber.io/docs/gherkin/

### 專案內部文件

1. **操作手冊五章節** — `docs/index.html`
2. **TEST_PLAN.md** — 測試計畫
3. **TPS.md** — Gherkin 測試程序
4. **tools/README.md** — FlaUI Inspector 使用說明

### 實作範例

- **Feature 檔案**：`Features/Inspection_App.feature`
- **Step Definitions**：`StepDefinitions/Inspection_AppSteps.cs`
- **Page Objects**：`PageObjects/` 目錄下所有檔案

---

## 🎓 給新手的建議

### ✅ DO（建議做的事）

1. **從操作手冊開始** — 按照章節順序閱讀
2. **先手動操作應用程式** — 了解功能後再看測試
3. **執行現有測試** — 觀察自動化過程
4. **閱讀簡單的 TC** — 從 TC02、TC06 開始
5. **安裝並熟悉 FlaUI Inspector** — 查看 UI 元素屬性（⭐ 重要）
6. **閱讀 FlaUI 操作詳解** — 理解 Page Object 模式和實戰範例
7. **參考現有的 Page Objects** — 學習操作模式和最佳實踐
8. **優先使用 AutomationId** — 比 Name 更穩定
9. **優先使用快捷鍵** — 比滑鼠點擊更快更穩定
10. **小步迭代** — 一次修改一個測試，馬上驗證

### ❌ DON'T（避免的事）

1. ❌ 不要在 Linux 環境中執行測試（無法運行）
2. ❌ 不要在 Step Definitions 中直接寫 FlaUI 操作（應放在 Page Objects）
3. ❌ 不要使用 Name 查找元素（優先用 AutomationId）
4. ❌ 不要寫死絕對路徑（使用相對路徑或環境變數）
5. ❌ 不要忽略等待時間（UI 更新需要時間）
6. ❌ 不要忽略 null 檢查（元素可能找不到）
7. ❌ 不要跳過 TPS 文件（這是測試規格的來源）
8. ❌ 不要在不理解的情況下複製程式碼
9. ❌ 不要同時修改多個測試案例
10. ❌ 不要忽略測試失敗（每次失敗都有原因）

---

## 🎉 恭喜！你已經了解專案基礎

### 接下來可以：

1. ⭐ **執行你的第一個測試** → 執行 `run_tests.bat`
2. 📖 **深入閱讀操作手冊** → 開啟 `docs/index.html`
3. 🤖 **學習 FlaUI 操作** → 閱讀本文「FlaUI 操作詳解」章節
4. 🔍 **安裝 FlaUI Inspector** → 執行 `tools/install-flauinspect.ps1`
5. 📝 **探索測試程式碼** → 查看 `Features/` 和 `PageObjects/`
6. ✏️ **修改一個測試** → 從簡單的 TC02 開始
7. 🎯 **實作一個 Page Object 方法** → 參考現有範例
8. 🚀 **新增自己的測試** → 按照第 2 章的指引

### 需要幫助？

- 📚 查看操作手冊第 4 章：修復測試
- 🔍 查看 [tools/README.md](Automation_testcase/Project_FlaUIBDD/Testcase_Inspection_App_FlaUI_BDD/tools/README.md)
- 📝 閱讀 TEST_PLAN.md 和 TPS.md

---

**祝你學習順利！🎊**
