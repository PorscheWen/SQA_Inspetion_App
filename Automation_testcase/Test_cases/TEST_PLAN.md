# Semi Inspection Desktop — 測試計畫（10 Test Cases）

| 類別 | 數量 |
|------|------|
| Functional | 7 |
| Negative | 3 |
| **合計** | **10** |

**被測程式：** `SemiInspectionDesktop\bin\Debug\SemiInspectionDesktop.exe`  
**測試資料：** `Recipe_data/InspectionRecipe_Sample.json`  
**詳細案例表：** [SemiInspection_10_TestCases.md](SemiInspection_10_TestCases.md)  
**Gherkin 測試程序（TPS）：** [TPS.md](TPS.md)

---

## Functional Test（7）

### TC01 — Import Recipe 至 Recipe_data
- **目的**：驗證 Import Recipe 可匯入 JSON 並顯示 RawData。
- **步驟**：Import Recipe（Ctrl+I）→ 選 `InspectionRecipe_Sample.json`。
- **預期**：檔案在 Recipe_data；DataGrid 有資料；日誌含「Import Recipe」。
- **Defect#**：2001

### TC02 — File Tree 顯示 Recipe_data
- **目的**：左側樹狀目錄指向 Recipe_data。
- **步驟**：啟動程式 → 檢視 File Tree。
- **預期**：視窗標題「Semi Inspection Desktop」；樹狀目錄可見；樣本 JSON 存在。
- **Defect#**：2002

### TC03 — RawData 參數表
- **目的**：RawData 按鈕切換並載入 Inspection 參數。
- **步驟**：點工具列 **RawData**（AutomationId: `btnParameters`，Ctrl+E）。
- **預期**：DataGrid 顯示 Category / Parameter / Value / Unit；日誌含「RawData」。
- **Defect#**：2003

### TC04 — Defect Chart 曲線圖
- **目的**：DefectSummary 繪製 DefectType / DefectCount 曲線。
- **步驟**：載入 Recipe → 點 **Defect Chart**（Ctrl+D）。
- **預期**：日誌含「Defect Chart: 已繪製 5 類」；圖表 Tab 顯示曲線（Sample 共 5 類缺陷）。
- **Defect#**：2004

### TC05 — 檔案樹雙擊開啟 Recipe
- **目的**：從 File Tree 直接開 JSON Recipe。
- **步驟**：雙擊 `InspectionRecipe_Sample.json`。
- **預期**：RawData 顯示 Recipe；日誌含「Recipe」。
- **Defect#**：2005

### TC06 — About 對話框
- **目的**：About 顯示功能與 Inspection 資料區段說明。
- **步驟**：點 Toolbar0 **About**。
- **預期**：MessageBox 含 Recipe_data 路徑與工具列功能說明。
- **Defect#**：2006

### TC10 — Run Inspection 模擬檢測
- **目的**：依 Recipe 執行模擬 AOI 檢測並寫入日誌。
- **步驟**：載入 Recipe → 點 **Run Inspection**（Ctrl+R，Toolbar0 或 Tools 選單）。
- **預期**：日誌含「Run Inspection」、Recipe 名稱、ToolID、DefectSummary 合計。
- **Defect#**：2010

---

## Negative Test（3）

### TC07 — 匯入非 JSON 檔
- **步驟**：Import Recipe → 選 `_invalid_sample.txt`。
- **預期**：警告「請選擇 .json Recipe 檔案」；不寫入 TC01_import_copy.json。
- **Defect#**：2007

### TC08 — 無 Recipe 時繪圖
- **步驟**：重新啟動後直接按 Defect Chart（未載入 Recipe）。
- **預期**：提示無 DefectSummary 或自動載入後仍無資料時警告；程式不崩潰。
- **Defect#**：2008

### TC09 — 開啟不存在 Recipe
- **步驟**：RawData 快捷鍵（Ctrl+E）→ 選 `not_exist_99999.json`。
- **預期**：錯誤訊息；主視窗仍存在。
- **Defect#**：2009

---

## 建置與執行

```bat
cd SQA_Inspetion_App
build_semi.bat
run_semi.bat
```

## 產生 Excel 測試案例表

```bat
python Automation_testcase\Test_cases\generate_semi_testcases.py
```

產出：`SemiInspection_10_TestCases.xlsx`

## 自動化對應

FlaUI BDD：`Automation_testcase/Project_FlaUIBDD/Testcase_demo2_desktop_FlaUI_BDD/Features/Demo2Desktop.feature`
