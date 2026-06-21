# Recipe_data — Test Data

Test fixtures for Semi Inspection Desktop FlaUI BDD (TC01–TC10).

| File | Used by | Purpose |
|------|---------|---------|
| `InspectionRecipe_Sample.json` | TC01, TC03–TC05, TC10 | Standard AOI Recipe with DefectSummary (5 types) |
| `_invalid_sample.txt` | TC07 | Non-JSON import negative test |
| `not_exist_99999.json` | TC09 | Missing file (do not create before test) |
| `TC01_import_copy.json` | TC07 assertion | Must not be created when importing invalid file |

## Configuration

Paths are resolved from `SQA_Inspetion_App` root via:

- `config.json` → `paths.recipeData`
- `App.config` → `RecipeDataDirectory`, `SampleRecipe`, `InvalidSampleFile`, `ImportTargetFile`
- `setup_env.bat` → `RecipeDataDirectory` environment variable

## Runtime copy

`build_semi.bat` and `run_semi.bat` copy this folder to `SemiInspectionDesktop/bin/Debug/Recipe_data/`.
