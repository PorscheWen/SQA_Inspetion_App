# Semi Inspection Desktop — 10 Test Cases

對應測試計畫：[TEST_PLAN.md](TEST_PLAN.md)  
Gherkin 測試程序：[TPS.md](TPS.md)  
FlaUI BDD Feature：`../Project_FlaUIBDD/Testcase_demo2_desktop_FlaUI_BDD/Features/Demo2Desktop.feature`

## 案例總表

| ID | 類別 | 標題 | 主要操作 | 預期結果 | Defect# |
|----|------|------|----------|----------|---------|
| TC01 | Functional | Import Recipe | Import Recipe + 選 Sample JSON | Recipe_data 有檔案；DataGrid 可見；日誌含 Import Recipe | 2001 |
| TC02 | Functional | File Tree | 啟動後檢視樹 | 標題 Semi Inspection Desktop；樹可見；Sample 存在 | 2002 |
| TC03 | Functional | RawData | 點 RawData (Ctrl+E) | DataGrid 顯示參數表；日誌含 RawData | 2003 |
| TC04 | Functional | Defect Chart | 載入 Recipe → Defect Chart | 日誌含 Defect Chart；5 類缺陷曲線 | 2004 |
| TC05 | Functional | 樹狀雙擊 | 雙擊 InspectionRecipe_Sample.json | DataGrid 可見；日誌含 Recipe | 2005 |
| TC06 | Functional | About | 點 About | About 對話框顯示功能說明 | 2006 |
| TC07 | Negative | 無效匯入 | Import + _invalid_sample.txt | 警告；不複製無效檔 | 2007 |
| TC08 | Negative | 無資料繪圖 | 重啟後直接 Defect Chart | 提示或警告；不當機 | 2008 |
| TC09 | Negative | 不存在檔 | RawData + not_exist_99999.json | 錯誤訊息；主視窗存在 | 2009 |
| TC10 | Functional | Run Inspection | 載入 Recipe → Run Inspection | 日誌含 Run Inspection 與檢測摘要 | 2010 |

---

## 控制項對照（UI Automation）

| 顯示名稱 | AutomationId | 快捷鍵 | 備註 |
|----------|--------------|--------|------|
| Import Recipe | btnImportRecipe | Ctrl+I | Toolbar0 |
| Run Inspection | btnRunInspection | Ctrl+R | Toolbar0 + Tools 選單 |
| RawData | btnParameters | Ctrl+E | Toolbar1（按鈕文字 RawData） |
| Defect Chart | btnDefectChart | Ctrl+D | Toolbar1 |
| About | btnToolbar0About | — | Toolbar0 |
| Close Recipe | menuFileCloseRecipe | Ctrl+W | File 選單 |
| RawData 表格 | dataGridParameters | — | Category/Parameter/Value/Unit |
| 檔案樹 | treeFiles | — | 雙擊 .json 載入 |
| 圖表 | pictureBoxChart | — | Defect Chart Tab |
| 日誌 | txtToolLog | — | 操作 log |

---

## 測試資料

| 檔案 | 用途 |
|------|------|
| `Recipe_data/InspectionRecipe_Sample.json` | 標準 Recipe（5 類 DefectSummary） |
| `Recipe_data/_invalid_sample.txt` | TC07 非 JSON 匯入 |
| `Recipe_data/not_exist_99999.json` | TC09（測試時不需預先建立） |

---

## TC04 預期 DefectSummary（Sample）

| DefectType | DefectCount |
|------------|-------------|
| Particle | 18 |
| Scratch | 6 |
| Bridge | 3 |
| Pattern | 9 |
| Void | 4 |

---

## TC10 預期日誌關鍵字

- `Run Inspection: 開始模擬檢測`
- `Recipe: Layer1_AOI_Recipe_v1`
- `Tool: AOI-TOOL-03`
- `DefectSummary 合計`

---

## Excel 匯出

執行 `generate_semi_testcases.py` 產生 `SemiInspection_10_TestCases.xlsx`。
