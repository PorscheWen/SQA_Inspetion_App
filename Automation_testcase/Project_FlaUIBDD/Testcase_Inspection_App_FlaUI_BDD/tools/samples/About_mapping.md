# FlaUI.Cli -> SpecFlow / Page Object mapping

| # | CLI command | Selector | Quality | Suggested Gherkin | Suggested Page method |
|---|-------------|----------|---------|-------------------|------------------------|
| 1 | `elem find` | `aid=btnToolbar0About` | Stable | # find only - no Gherkin action | (locator prep) |
| 2 | `elem click` | `aid=btnToolbar0About` | Stable | When I click toolbar "About" | Click_1_About() |
| 3 | `elem find` | `name=OK` | Acceptable | # find only - no Gherkin action | (locator prep) |
| 4 | `elem click` | `name=OK` | Acceptable | When I click "OK" | Click_2_OK() |
