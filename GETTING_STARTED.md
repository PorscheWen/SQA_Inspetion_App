# SQA Inspection App — 新手入門指南

> **主要入口（網頁版，已整合本文件精華）：** [`docs/00-getting-started.html`](docs/00-getting-started.html)  
> 開啟方式：`main_menu.bat` → **[9] Getting started (web)**，或操作手冊導覽「新手入門」。

本文 Markdown **不再重複** 5 步驟、選單對照、FAQ 等上手內容（請看網頁）。  
以下僅保留 **FlaUI 深度附錄**（Locators、Page Object、實戰範例、反模式）。

## 網頁版章節導覽

| 主題 | 連結 |
|------|------|
| 這是什麼專案 / 架構 | [overview](docs/00-getting-started.html#overview) · [architecture](docs/00-getting-started.html#architecture) |
| 流程圖（誰做什麼） | [flowcharts](docs/00-getting-started.html#flowcharts) |
| main_menu / .bat | [main-menu](docs/00-getting-started.html#main-menu) · [bats](docs/00-getting-started.html#bats) |
| 5 步驟快速開始 | [quick-start](docs/00-getting-started.html#quick-start) |
| 學習路徑 / TC 導覽 | [learning-path](docs/00-getting-started.html#learning-path) · [tc-guide](docs/00-getting-started.html#tc-guide) |
| 檔案位置 / FAQ / 建議 | [paths](docs/00-getting-started.html#paths) · [faq](docs/00-getting-started.html#faq) · [tips](docs/00-getting-started.html#tips) |
| 操作手冊五章 | [docs/index.html](docs/index.html) |

---

<a id="flaui-appendix"></a>

## FlaUI 操作詳解（附錄）

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

**上手內容請回網頁版：** [docs/00-getting-started.html](docs/00-getting-started.html)
