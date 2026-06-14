namespace SemiInspectionDesktop.UI
{
    /// <summary>工具列功能介紹，對應 Inspection Recipe JSON 資料區段。</summary>
    public static class ToolbarFeatureGuide
    {
        public const string ImportRecipeName = "Import Recipe";
        public const string RunInspectionName = "Run Inspection";
        public const string RawDataName = "RawData";
        public const string DefectChartName = "Defect Chart";
        public const string AboutName = "About";

        public const string ImportRecipeTooltip =
            "匯入 AOI Inspection Recipe (JSON) 至 Recipe_data\r\n"
            + "資料區段：Lot/Wafer、OpticalMode、DetectionPolicy、\r\n"
            + "ReportingPolicy、InspectionPolicy、DefectSummary\r\n"
            + "快捷鍵：Ctrl+I";

        public const string RunInspectionTooltip =
            "依目前 Recipe 執行模擬 AOI 檢測\r\n"
            + "讀取：ToolID、Illumination、Algorithm、Threshold\r\n"
            + "統計 DefectSummary 缺陷合計\r\n"
            + "快捷鍵：Ctrl+R";

        public const string RawDataTooltip =
            "檢視 Inspection Raw Data 參數表\r\n"
            + "(Category / Parameter / Value / Unit)\r\n"
            + "含 OpticalMode、DetectionPolicy、InspectionPolicy\r\n"
            + "快捷鍵：Ctrl+E";

        public const string DefectChartTooltip =
            "繪製 DefectSummary 缺陷趨勢圖\r\n"
            + "X 軸：DefectType (Particle, Scratch, Bridge…)\r\n"
            + "Y 軸：DefectCount\r\n"
            + "快捷鍵：Ctrl+D";

        public const string AboutTooltip =
            "Semi Inspection Desktop 功能說明\r\n"
            + "半導體 AOI Recipe 檢視與模擬檢測工具";

        public static string BuildAboutMessage(string recipeDataPath)
        {
            return "Semi Inspection Desktop\r\n"
                + "半導體 AOI Inspection Recipe 檢視工具\r\n\r\n"
                + "【工具列功能】\r\n"
                + "• Import Recipe — 載入 JSON Recipe（Lot/Wafer + 三大 Policy）\r\n"
                + "• Run Inspection — 依 Recipe 模擬 AOI 掃描與缺陷統計\r\n"
                + "• RawData — 參數表（OpticalMode / Detection / Reporting / Inspection）\r\n"
                + "• Defect Chart — DefectType vs DefectCount 曲線圖\r\n\r\n"
                + "【Recipe 資料區段】\r\n"
                + "Lot/Wafer：RecipeName, WaferID, LotID, Layer, Step, ToolID\r\n"
                + "OpticalMode：Illumination, Aperture, PixelSize, FocusOffset, ScanSpeed\r\n"
                + "DetectionPolicy：Algorithm, Threshold, SegmentBreak, SNRMin\r\n"
                + "ReportingPolicy：MaxNuisanceRate, DefectClassSet, ReportEnabled\r\n"
                + "InspectionPolicy：ZoneOfInterest, RuleAction, MaxRetry\r\n"
                + "DefectSummary：DefectType, DefectCount, Severity, DOI\r\n\r\n"
                + "Recipe_data：" + recipeDataPath + "\r\n"
                + "Close Recipe：Ctrl+W";
        }
    }
}
