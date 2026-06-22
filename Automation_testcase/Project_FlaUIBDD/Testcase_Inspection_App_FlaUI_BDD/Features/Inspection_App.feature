Feature: Semi Inspection Desktop Tests
  As a tester
  I want to verify Recipe, RawData, and chart features
  So that the Recipe_data workflow works correctly

@Functional @Import @DDT
Scenario Outline: TC01 - Import Recipe to Recipe_data
  Given test data is ready
  And the application has relaunched
  When I click toolbar "Import Recipe"
  And I select file "<recipe_file>" in the file dialog
  And I click toolbar "RawData"
  Then Recipe_data should contain "<recipe_file>"
  And the data table should be visible
  And the RawData view should show filename <recipe_file>
  And the RawData parameter table should contain "<expected_parameter>"
  And the log should contain "Import Recipe"

  Examples:
    | recipe_file                   | expected_parameter    |
    | InspectionRecipe_Sample.json  | Layer1_AOI_Recipe_v1 |
    | InspectionRecipe_Sample.json  | W-20260605-001       |
    | InspectionRecipe_Sample.json  | Brightfield          |

@Functional @FileTree
Scenario: TC02 - File Tree shows Recipe_data
  Given test data is ready
  And the application has started
  Then the main window title should be "Semi Inspection Desktop"
  And the file tree should be visible
  And Recipe_data should contain "InspectionRecipe_Sample.json"

@Functional @RawData
Scenario: TC03 - RawData parameter table
  Given test data is ready
  And the application has started
  When I click toolbar "RawData"
  Then the data table should be visible
  And the log should contain "RawData"

@Functional @Chart
Scenario: TC04 - Defect Chart
  Given test data is ready
  And the application has started
  When I click toolbar "RawData"
  And I click toolbar "Defect Chart"
  Then the log should contain "Defect Chart"

@Functional @FileTree
Scenario: TC05 - Double-click Recipe in file tree
  Given test data is ready
  And the application has started
  When I double-click InspectionRecipe_Sample.json in the file tree
  Then the data table should be visible
  And the log should contain "Recipe"

@Functional @About
Scenario: TC06 - About dialog
  Given the application has started
  When I click toolbar "About"
  And I close the message dialog

@Negative @Import
Scenario: TC07 - Import non-JSON file
  Given test data is ready
  And the application has started
  When I click toolbar "Import Recipe"
  And I select invalid file "_invalid_sample.txt" in the file dialog
  Then the invalid file should not be copied as TC01_import_copy.json
  And I close the message dialog

@Negative @Chart
Scenario: TC08 - Chart without Recipe
  Given the application has relaunched
  When I click toolbar "Defect Chart"
  Then the main window should still exist

@Negative @RawData
Scenario: TC09 - Open non-existent Recipe
  Given the application has started
  When I open RawData via shortcut and select missing file "not_exist_99999.json"
  Then the main window should still exist

@Functional @Inspection
Scenario: TC10 - Run Inspection simulation
  Given test data is ready
  And the application has started
  When I click toolbar "RawData"
  And I click toolbar "Run Inspection"
  Then the log should contain "Run Inspection"
