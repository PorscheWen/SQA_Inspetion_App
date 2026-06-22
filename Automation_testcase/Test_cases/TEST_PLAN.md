# Semi Inspection Desktop — Test Plan (10 Test Cases)

| Category | Count |
|----------|-------|
| Functional | 7 |
| Negative | 3 |
| **Total** | **10** |

**Application under test:** `SemiInspectionDesktop\bin\Debug\SemiInspectionDesktop.exe`  
**Test data:** `Recipe_data/InspectionRecipe_Sample.json`  
**Detailed case table:** [SemiInspection_10_TestCases.md](SemiInspection_10_TestCases.md)  
**Gherkin test procedures (TPS):** [TPS.md](TPS.md)

---

## Functional Tests (7)

### TC01 — Import Recipe to Recipe_data
- **Purpose:** Verify Import Recipe imports JSON and displays RawData.
- **Steps:** Import Recipe (Ctrl+I) → select `InspectionRecipe_Sample.json` → switch to RawData.
- **Expected:** File in Recipe_data; RawData shows sample filename; parameter table contains RecipeName / WaferID / OpticalMode data; log contains "Import Recipe".
- **Defect#:** 2001

### TC02 — File Tree shows Recipe_data
- **Purpose:** Left tree points to Recipe_data.
- **Steps:** Launch app → view File Tree.
- **Expected:** Window title "Semi Inspection Desktop"; tree visible; sample JSON exists.
- **Defect#:** 2002

### TC03 — RawData parameter table
- **Purpose:** RawData button switches and loads inspection parameters.
- **Steps:** Click toolbar **RawData** (AutomationId: `btnParameters`, Ctrl+E).
- **Expected:** DataGrid shows Category / Parameter / Value / Unit; log contains "RawData".
- **Defect#:** 2003

### TC04 — Defect Chart
- **Purpose:** DefectSummary draws DefectType / DefectCount curve.
- **Steps:** Load Recipe → click **Defect Chart** (Ctrl+D).
- **Expected:** Log contains "Defect Chart: plotted 5 types"; chart tab shows curve (Sample has 5 defect types).
- **Defect#:** 2004

### TC05 — Double-click Recipe in file tree
- **Purpose:** Open JSON Recipe from File Tree.
- **Steps:** Double-click `InspectionRecipe_Sample.json`.
- **Expected:** RawData shows Recipe; log contains "Recipe".
- **Defect#:** 2005

### TC06 — About dialog
- **Purpose:** About shows feature and Inspection data section description.
- **Steps:** Click Toolbar0 **About**.
- **Expected:** MessageBox contains Recipe_data path and toolbar feature description.
- **Defect#:** 2006

### TC10 — Run Inspection simulation
- **Purpose:** Run simulated AOI inspection from Recipe and write log.
- **Steps:** Load Recipe → click **Run Inspection** (Ctrl+R, Toolbar0 or Tools menu).
- **Expected:** Log contains "Run Inspection", Recipe name, ToolID, DefectSummary total.
- **Defect#:** 2010

---

## Negative Tests (3)

### TC07 — Import non-JSON file
- **Steps:** Import Recipe → select `_invalid_sample.txt`.
- **Expected:** Warning "Please select a .json Recipe file"; does not write TC01_import_copy.json.
- **Defect#:** 2007

### TC08 — Chart without Recipe
- **Steps:** Relaunch app → click Defect Chart directly (no Recipe loaded).
- **Expected:** Prompt for missing DefectSummary or warning after auto-load fails; app does not crash.
- **Defect#:** 2008

### TC09 — Open non-existent Recipe
- **Steps:** RawData shortcut (Ctrl+E) → select `not_exist_99999.json`.
- **Expected:** Error message; main window still exists.
- **Defect#:** 2009

---

## Build and run

```bat
cd SQA_Inspetion_App
build_semi.bat
run_semi.bat
```

## Generate Excel test case table

```bat
python Automation_testcase\Test_cases\generate_semi_testcases.py
```

Output: `SemiInspection_10_TestCases.xlsx`

## Automation mapping

FlaUI BDD: `Automation_testcase/Project_FlaUIBDD/Testcase_Inspection_App_FlaUI_BDD/Features/Inspection_App.feature`
