Feature: Recorded stub ??About
  # Generated from FlaUI.Cli recording. Merge into Inspection_App.feature manually.

  @Recorded @Stub
  Scenario: About from flaui record
    Given the application is running
    When I click toolbar "About"
    When I click "OK"
    Then the main window title should be "Semi Inspection Desktop"
