# Semi Inspection Desktop — 10 Test Cases

Test plan: [TEST_PLAN.md](TEST_PLAN.md)  
Gherkin test procedures: [TPS.md](TPS.md)  
FlaUI BDD Feature: `../Project_FlaUIBDD/Testcase_Inspection_App_FlaUI_BDD/Features/Inspection_App.feature`

## Summary table

| ID | Category | Title | Main actions | Expected result | Defect# |
|----|----------|-------|--------------|-----------------|---------|
| TC01 | Functional | Import Recipe | Import Recipe + select Sample JSON + RawData | File in Recipe_data; RawData shows sample and parameters; log contains Import Recipe | 2001 |
| TC02 | Functional | File Tree | Launch and view tree | Title Semi Inspection Desktop; tree visible; sample exists | 2002 |
| TC03 | Functional | RawData | Click RawData (Ctrl+E) | DataGrid shows parameter table; log contains RawData | 2003 |
| TC04 | Functional | Defect Chart | Load Recipe → Defect Chart | Log contains Defect Chart; 5-type defect curve | 2004 |
| TC05 | Functional | Tree double-click | Double-click InspectionRecipe_Sample.json | DataGrid visible; log contains Recipe | 2005 |
| TC06 | Functional | About | Click About | About dialog shows feature description | 2006 |
| TC07 | Negative | Invalid import | Import + _invalid_sample.txt | Warning; invalid file not copied | 2007 |
| TC08 | Negative | Chart without data | Relaunch → Defect Chart | Prompt or warning; no crash | 2008 |
| TC09 | Negative | Missing file | RawData + not_exist_99999.json | Error message; main window exists | 2009 |
| TC10 | Functional | Run Inspection | Load Recipe → Run Inspection | Log contains Run Inspection and inspection summary | 2010 |

---

## Control mapping (UI Automation)

| Display name | AutomationId | Shortcut | Notes |
|--------------|--------------|----------|-------|
| Import Recipe | btnImportRecipe | Ctrl+I | Toolbar0 |
| Run Inspection | btnRunInspection | Ctrl+R | Toolbar0 + Tools menu |
| RawData | btnParameters | Ctrl+E | Toolbar1 (button text RawData) |
| Defect Chart | btnDefectChart | Ctrl+D | Toolbar1 |
| About | btnToolbar0About | — | Toolbar0 |
| Close Recipe | menuFileCloseRecipe | Ctrl+W | File menu |
| RawData table | dataGridParameters | — | Category/Parameter/Value/Unit |
| File tree | treeFiles | — | Double-click .json to load |
| Chart | pictureBoxChart | — | Defect Chart tab |
| Log | txtToolLog | — | Operation log |

---

## Test data

| File | Purpose |
|------|---------|
| `Recipe_data/InspectionRecipe_Sample.json` | Standard Recipe (5 DefectSummary types) |
| `Recipe_data/_invalid_sample.txt` | TC07 non-JSON import |
| `Recipe_data/not_exist_99999.json` | TC09 (do not create before test) |

---

## TC04 expected DefectSummary (Sample)

| DefectType | DefectCount |
|------------|-------------|
| Particle | 18 |
| Scratch | 6 |
| Bridge | 3 |
| Pattern | 9 |
| Void | 4 |

---

## TC10 expected log keywords

- `Run Inspection: starting simulated inspection`
- `Recipe: Layer1_AOI_Recipe_v1`
- `Tool: AOI-TOOL-03`
- `DefectSummary total`

---

## Excel export

Run `generate_semi_testcases.py` to produce `SemiInspection_10_TestCases.xlsx`.
