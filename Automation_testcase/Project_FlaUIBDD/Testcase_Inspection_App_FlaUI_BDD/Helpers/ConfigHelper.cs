using System.Configuration;
using System.IO;
using System.Reflection;

namespace Inspection_AppTests.Helpers;

public static class ConfigHelper
{
    private static string? _appRoot;

    public static string GetAppRoot()
    {
        if (!string.IsNullOrEmpty(_appRoot))
        {
            return _appRoot;
        }

        var envRoot = Environment.GetEnvironmentVariable("APP_ROOT");
        if (!string.IsNullOrWhiteSpace(envRoot) && Directory.Exists(envRoot))
        {
            _appRoot = Path.GetFullPath(envRoot);
            return _appRoot;
        }

        var dir = new DirectoryInfo(AppContext.BaseDirectory);
        while (dir != null)
        {
            if (File.Exists(Path.Combine(dir.FullName, "config.json")) &&
                File.Exists(Path.Combine(dir.FullName, "build_semi.bat")))
            {
                _appRoot = dir.FullName;
                return _appRoot;
            }

            dir = dir.Parent;
        }

        _appRoot = AppContext.BaseDirectory;
        return _appRoot;
    }

    public static string GetApplicationPath() =>
        ResolveConfiguredPath(GetConfigValue(
            "ApplicationPath",
            @"SemiInspectionDesktop\bin\Debug\SemiInspectionDesktop.exe"));

    public static string GetApplicationTitle() =>
        GetConfigValue("ApplicationTitle", "Semi Inspection Desktop");

    public static string GetProcessName() =>
        GetConfigValue("ProcessName", "SemiInspectionDesktop");

    public static string GetRecipeDataDirectory() =>
        ResolveConfiguredPath(GetConfigValue("RecipeDataDirectory",
            GetConfigValue("TestDataDirectory", "Recipe_data")));

    public static string GetTestDataDirectory() => GetRecipeDataDirectory();

    public static string GetSampleRecipePath() =>
        Path.Combine(GetRecipeDataDirectory(), GetConfigValue("SampleRecipe", "InspectionRecipe_Sample.json"));

    public static string GetSampleJsonPath() => GetSampleRecipePath();

    public static string GetImportTargetPath() =>
        Path.Combine(GetRecipeDataDirectory(), GetConfigValue("ImportTargetFile", "TC01_import_copy.json"));

    public static string GetInvalidSamplePath() =>
        Path.Combine(GetRecipeDataDirectory(), GetConfigValue("InvalidSampleFile", "_invalid_sample.txt"));

    public static int GetDefaultTimeout()
    {
        var timeout = GetConfigValue("DefaultTimeout", "30000");
        return int.TryParse(timeout, out var result) ? result : 30000;
    }

    public static string GetScreenshotDirectory() =>
        GetConfigValue("ScreenshotDirectory", "Screenshots");

    public static string GetFailureLogDirectory() =>
        GetConfigValue("FailureLogDirectory", "FailureLogs");

    public static bool WriteFailureLogOnFailure() =>
        bool.TryParse(GetConfigValue("WriteFailureLogOnFailure", "true"), out var result) && result;

    public static bool TakeScreenshotOnFailure() =>
        bool.TryParse(GetConfigValue("TakeScreenshotOnFailure", "true"), out var result) && result;

    public static bool TakeScreenshotOnClick() =>
        bool.TryParse(GetConfigValue("TakeScreenshotOnClick", "true"), out var result) && result;

    public static bool TakeScreenshotOnScenarioEnd() =>
        bool.TryParse(GetConfigValue("TakeScreenshotOnScenarioEnd", "true"), out var result) && result;

    private static string ResolveConfiguredPath(string configured)
    {
        if (string.IsNullOrWhiteSpace(configured))
        {
            return configured;
        }

        return Path.IsPathRooted(configured)
            ? Path.GetFullPath(configured)
            : Path.GetFullPath(Path.Combine(GetAppRoot(), configured));
    }

    private static string GetConfigValue(string key, string defaultValue)
    {
        try
        {
            var envValue = Environment.GetEnvironmentVariable(key);
            if (!string.IsNullOrEmpty(envValue))
            {
                return envValue;
            }

            var configValue = GetAppSettings()[key]?.Value;
            return !string.IsNullOrEmpty(configValue) ? configValue : defaultValue;
        }
        catch
        {
            return defaultValue;
        }
    }

    private static KeyValueConfigurationCollection GetAppSettings()
    {
        var assemblyName = Assembly.GetExecutingAssembly().GetName().Name;
        var configFile = Path.Combine(AppContext.BaseDirectory, $"{assemblyName}.dll.config");

        if (!File.Exists(configFile))
        {
            configFile = Path.Combine(AppContext.BaseDirectory, "App.config");
        }

        var configMap = new ExeConfigurationFileMap { ExeConfigFilename = configFile };
        return ConfigurationManager
            .OpenMappedExeConfiguration(configMap, ConfigurationUserLevel.None)
            .AppSettings.Settings;
    }
}
