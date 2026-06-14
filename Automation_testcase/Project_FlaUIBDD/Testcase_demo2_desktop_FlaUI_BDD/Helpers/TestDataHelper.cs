namespace Demo2DesktopTests.Helpers;

public static class TestDataHelper
{
    public static void EnsureTestDataReady()
    {
        var dir = ConfigHelper.GetRecipeDataDirectory();
        if (!Directory.Exists(dir))
        {
            Directory.CreateDirectory(dir);
        }

        var sample = ConfigHelper.GetSampleRecipePath();
        if (!File.Exists(sample))
        {
            throw new FileNotFoundException("Missing sample recipe: " + sample);
        }

        var invalid = ConfigHelper.GetInvalidSamplePath();
        if (!File.Exists(invalid))
        {
            File.WriteAllText(invalid, "invalid for import test");
        }
    }

    public static void DeleteImportTargetIfExists()
    {
        var path = ConfigHelper.GetImportTargetPath();
        if (File.Exists(path))
        {
            File.Delete(path);
        }
    }

    public static bool ImportTargetExists() => File.Exists(ConfigHelper.GetImportTargetPath());

    public static bool FileExistsInRecipeData(string fileName) =>
        File.Exists(Path.Combine(ConfigHelper.GetRecipeDataDirectory(), fileName));

    public static bool FileExistsInTestData(string fileName) => FileExistsInRecipeData(fileName);
}
