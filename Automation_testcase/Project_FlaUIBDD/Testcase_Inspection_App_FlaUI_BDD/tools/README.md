# FlaUI 工具：Inspector + CLI 錄製

**⚠️ 僅 Windows。** FlaUI Inspector／FlaUI.Cli 都依賴 Windows UI Automation。

---

## 1. FlaUI Inspector（元素探測）

用來 Hover 控制項、抄 `AutomationId`／`Name`，**不錄製操作流程**。

### 安裝

```powershell
cd Automation_testcase\Project_FlaUIBDD\Testcase_Inspection_App_FlaUI_BDD\tools
.\install-flauinspect.ps1
```

手動：https://github.com/FlaUI/FlaUInspect/releases/download/v3.0.0/FlaUInspect.3.0.0.zip  
解壓到 `tools/FlaUIInspector/`，並複製 `FlaUInspect.exe` → `FlaUIInspector.exe`。

### 啟動

- 主選單 **[15]**
- 或 `open_inspector.bat`

圖文步驟：`docs/flaui-tutorial.html#flaui-inspect`

---

## 2. FlaUI.Cli／FlaUI.Tool（免費 CLI 錄製）

[FlaUI.Cli](https://github.com/kodroi/FlaUI.Cli)（NuGet：`FlaUI.Tool`，MIT）可：

- `session` 啟動／附加 App
- `elem find/click/type` 操作 UI
- `record start/export` 把 **CLI 指令步驟** 匯出成 JSON
- `audit` 評分 selector（Stable／Acceptable／Fragile）

**不是 TestComplete：** 不會錄滑鼠軌跡；要自己下（或用引導腳本下）`flaui elem ...`。

### 需求

- **.NET SDK 10+**（套件目標 `net10.0`）
- 若本機只有 8／9：`winget install Microsoft.DotNet.SDK.10` 後**重開終端**

### 安裝

```powershell
cd Automation_testcase\Project_FlaUIBDD\Testcase_Inspection_App_FlaUI_BDD\tools
.\install-flaui-cli.ps1
flaui --help
```

### 引導錄製 → BDD stub

```bat
open_flaui_record.bat
```

或主選單 **[16]**。情境：About／RawData／Import／Custom。

輸出：`tools/recordings/session_*/recording.json` + 轉換 stub。

手動轉換範例：

```powershell
.\Convert-FlaUIRecordToBdd.ps1 `
  -InputJson .\samples\tc06_about_record.json `
  -OutDir .\samples `
  -ScenarioName About
```

圖文步驟：`docs/flaui-tutorial.html#flaui-record`

### 目錄結構

```
tools/
├── FlaUIInspector/           # Inspector（gitignore 可忽略下載物）
├── install-flauinspect.ps1
├── install-flaui-cli.ps1
├── flaui_record_workflow.ps1
├── Convert-FlaUIRecordToBdd.ps1
├── samples/
│   ├── tc06_about_record.json
│   ├── About_stub.feature
│   ├── About_PageStub.cs
│   └── About_mapping.md
├── recordings/               # 本機錄製輸出（建議 gitignore）
└── README.md
```

---

## 3. 相關資源

- FlaUI：https://github.com/FlaUI/FlaUI
- FlaUInspect：https://github.com/FlaUI/FlaUInspect
- FlaUI.Cli：https://github.com/kodroi/FlaUI.Cli
- 專案教學：`docs/flaui-tutorial.html`
