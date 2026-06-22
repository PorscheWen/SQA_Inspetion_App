# TPS — Test Procedure Specification (Gherkin)

**Test Procedure Specification**  
Describes 10 test procedures for Semi Inspection Desktop in Gherkin syntax.

| Item | Value |
|------|-------|
| Source | [TEST_PLAN.md](TEST_PLAN.md) |
| Application under test | `SemiInspectionDesktop\bin\Debug\SemiInspectionDesktop.exe` |
| Test data directory | `Recipe_data/` |
| Standard sample | `InspectionRecipe_Sample.json` |
| Automation Feature | `../Project_FlaUIBDD/Testcase_Inspection_App_FlaUI_BDD/Features/Inspection_App.feature` |
| Language | English (step wording matches FlaUI BDD) |

## Preconditions (Background)

```gherkin
Background: Semi Inspection Desktop test environment
  Given the working directory is SQA_Inspetion_App
  And build_semi.bat has been run to build the application
  And Recipe_data contains InspectionRecipe_Sample.json
  And Recipe_data contains _invalid_sample.txt (for TC07)
```

## Feature

```gherkin
Feature: Semi Inspection Desktop Tests
  As a tester
  I want to verify Recipe, RawData, and chart features
  So that the Recipe_data workflow works correctly

  # --- Functional (7) ---

  @Functional @Import @Defect2001
  Scenario: TC01 - Import Recipe to Recipe_data
    # Purpose: verify Import Recipe imports JSON and shows RawData
    Given test data is ready
    And the application has relaunched
    When I click toolbar "Import Recipe"
    And I select sample InspectionRecipe_Sample.json in the file dialog
    And I click toolbar "RawData"
    Then Recipe_data should contain InspectionRecipe_Sample.json
    And the data table should be visible
    And the RawData view should show filename InspectionRecipe_Sample.json
    And the RawData parameter table should contain "Layer1_AOI_Recipe_v1"
    And the RawData parameter table should contain "W-20260605-001"
    And the RawData parameter table should contain "Brightfield"
    And the log should contain "Import Recipe"

  @Functional @FileTree @Defect2002
  Scenario: TC02 - File Tree shows Recipe_data
    # Purpose: left tree points to Recipe_data
    Given test data is ready
    And the application has started
    Then the main window title should be "Semi Inspection Desktop"
    And the file tree should be visible
    And Recipe_data should contain InspectionRecipe_Sample.json

  @Functional @RawData @Defect2003
  Scenario: TC03 - RawData parameter table
    # Purpose: RawData button switches and loads inspection parameters (btnParameters / Ctrl+E)
    Given test data is ready
    And the application has started
    When I click toolbar "RawData"
    Then the data table should be visible
    And the log should contain "RawData"

  @Functional @Chart @Defect2004
  Scenario: TC04 - Defect Chart
    # Purpose: DefectSummary draws DefectType / DefectCount curve (Sample has 5 types)
    Given test data is ready
    And the application has started
    When I click toolbar "RawData"
    And I click toolbar "Defect Chart"
    Then the log should contain "Defect Chart"

  @Functional @FileTree @Defect2005
  Scenario: TC05 - Double-click Recipe in file tree
    # Purpose: open JSON Recipe from File Tree
    Given test data is ready
    And the application has started
    When I double-click InspectionRecipe_Sample.json in the file tree
    Then the data table should be visible
    And the log should contain "Recipe"

  @Functional @About @Defect2006
  Scenario: TC06 - About dialog
    # Purpose: About shows feature and Inspection data section description
    Given the application has started
    When I click toolbar "About"
    And I close the message dialog

  @Functional @Inspection @Defect2010
  Scenario: TC10 - Run Inspection simulation
    # Purpose: run simulated AOI inspection from Recipe and write log
    Given test data is ready
    And the application has started
    When I click toolbar "RawData"
    And I click toolbar "Run Inspection"
    Then the log should contain "Run Inspection"

  # --- Negative (3) ---

  @Negative @Import @Defect2007
  Scenario: TC07 - Import non-JSON file
    # Purpose: non-JSON import shows warning and does not write TC01_import_copy.json
    Given test data is ready
    And the application has started
    When I click toolbar "Import Recipe"
    And I select invalid file _invalid_sample.txt in the file dialog
    Then the invalid file should not be copied as TC01_import_copy.json
    And I close the message dialog

  @Negative @Chart @Defect2008
  Scenario: TC08 - Chart without Recipe
    # Purpose: Defect Chart without loaded Recipe does not crash
    Given the application has relaunched
    When I click toolbar "Defect Chart"
    Then the main window should still exist

  @Negative @RawData @Defect2009
  Scenario: TC09 - Open non-existent Recipe
    # Purpose: missing JSON shows error and main window remains
    Given the application has started
    When I open RawData via shortcut and select missing file not_exist_99999.json
    Then the main window should still exist
```

## Scenario mapping

| ID | Tags | Defect# | Category |
|----|------|---------|----------|
| TC01 | @Functional @Import | 2001 | Functional |
| TC02 | @Functional @FileTree | 2002 | Functional |
| TC03 | @Functional @RawData | 2003 | Functional |
| TC04 | @Functional @Chart | 2004 | Functional |
| TC05 | @Functional @FileTree | 2005 | Functional |
| TC06 | @Functional @About | 2006 | Functional |
| TC07 | @Negative @Import | 2007 | Negative |
| TC08 | @Negative @Chart | 2008 | Negative |
| TC09 | @Negative @RawData | 2009 | Negative |
| TC10 | @Functional @Inspection | 2010 | Functional |

## Test data (Gherkin notes)

```gherkin
# Standard Recipe (TC01, TC04, TC05, TC10)
#   Recipe_data/InspectionRecipe_Sample.json
#   DefectSummary 5 types: Particle(18), Scratch(6), Bridge(3), Pattern(9), Void(4)

# Invalid import (TC07)
#   Recipe_data/_invalid_sample.txt

# Missing file (TC09, do not create beforehand)
#   Recipe_data/not_exist_99999.json
```

## Execution

**Manual:** Follow each Scenario's Given / When / Then steps.

**Automation (FlaUI BDD):**

```bat
cd SQA_Inspetion_App
run_tests.bat
```

## Revision history

| Version | Date | Description |
|---------|------|-------------|
| 1.0 | 2026-06-05 | Initial Gherkin TPS from TEST_PLAN.md |
| 1.1 | 2026-06-21 | English step wording; TC01 RawData parameter checks |
