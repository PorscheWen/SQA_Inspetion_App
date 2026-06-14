using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using SemiInspectionDesktop.Json;

namespace SemiInspectionDesktop.Models
{
    public sealed class InspectionRecipeLoadResult
    {
        public string FilePath { get; set; }
        public DataTable Parameters { get; set; }
        public List<string> DefectTypes { get; set; }
        public List<int> DefectCounts { get; set; }
        public string RecipeName { get; set; }
        public string WaferId { get; set; }
        public string LotId { get; set; }
    }

    public static class InspectionRecipeService
    {
        public static InspectionRecipeLoadResult Load(string filePath)
        {
            Dictionary<string, object> root = JsonFileReader.LoadDictionary(filePath);
            InspectionRecipeLoadResult result = new InspectionRecipeLoadResult();
            result.FilePath = filePath;
            result.RecipeName = GetString(root, "RecipeName");
            result.WaferId = GetString(root, "WaferID");
            result.LotId = GetString(root, "LotID");
            result.Parameters = BuildParameterTable(root);
            result.DefectTypes = new List<string>();
            result.DefectCounts = new List<int>();
            LoadDefectSummary(root, result.DefectTypes, result.DefectCounts);
            return result;
        }

        static DataTable BuildParameterTable(Dictionary<string, object> root)
        {
            DataTable table = new DataTable();
            table.Columns.Add("Category", typeof(string));
            table.Columns.Add("Parameter", typeof(string));
            table.Columns.Add("Value", typeof(string));
            table.Columns.Add("Unit", typeof(string));

            AddRow(table, "Lot/Wafer", "RecipeName", GetString(root, "RecipeName"), "");
            AddRow(table, "Lot/Wafer", "WaferID", GetString(root, "WaferID"), "");
            AddRow(table, "Lot/Wafer", "LotID", GetString(root, "LotID"), "");
            AddRow(table, "Lot/Wafer", "Layer", GetString(root, "Layer"), "");
            AddRow(table, "Lot/Wafer", "Step", GetString(root, "Step"), "");
            AddRow(table, "Lot/Wafer", "ToolID", GetString(root, "ToolID"), "");

            AddSection(table, "OpticalMode", root, new string[][] {
                new string[] { "Illumination", "" }, new string[] { "Aperture", "" },
                new string[] { "PixelSize", "um" }, new string[] { "FocusOffset", "um" },
                new string[] { "ScanSpeed", "mm/s" }
            });
            AddSection(table, "DetectionPolicy", root, new string[][] {
                new string[] { "Algorithm", "" }, new string[] { "Threshold", "gray" },
                new string[] { "SegmentBreak", "" }, new string[] { "SNRMin", "dB" }
            });
            AddSection(table, "ReportingPolicy", root, new string[][] {
                new string[] { "MaxNuisanceRate", "%" }, new string[] { "DefectClassSet", "" },
                new string[] { "ReportEnabled", "" }
            });
            AddSection(table, "InspectionPolicy", root, new string[][] {
                new string[] { "ZoneOfInterest", "" }, new string[] { "RuleAction", "" },
                new string[] { "MaxRetry", "" }
            });

            return table;
        }

        static void AddSection(DataTable table, string sectionName, Dictionary<string, object> root, string[][] fields)
        {
            object sectionObj;
            if (!root.TryGetValue(sectionName, out sectionObj))
                return;
            Dictionary<string, object> section = sectionObj as Dictionary<string, object>;
            if (section == null)
                return;
            foreach (string[] field in fields)
                AddRow(table, sectionName, field[0], GetString(section, field[0]), field[1]);
        }

        static void LoadDefectSummary(Dictionary<string, object> root, List<string> types, List<int> counts)
        {
            object summaryObj;
            if (!root.TryGetValue("DefectSummary", out summaryObj) || summaryObj == null)
                return;

            List<object> list = summaryObj as List<object>;
            if (list != null)
            {
                foreach (object item in list)
                    AddDefectSummaryRow(item, types, counts);
                return;
            }

            ArrayList arrayList = summaryObj as ArrayList;
            if (arrayList != null)
            {
                foreach (object item in arrayList)
                    AddDefectSummaryRow(item, types, counts);
            }
        }

        static void AddDefectSummaryRow(object item, List<string> types, List<int> counts)
        {
            Dictionary<string, object> row = item as Dictionary<string, object>;
            if (row == null)
                return;
            string type = GetString(row, "DefectType");
            if (string.IsNullOrEmpty(type))
                return;
            int count = GetInt(row, "DefectCount");
            if (count <= 0)
                count = GetInt(row, "DefectNumber");
            if (count <= 0)
                return;
            types.Add(type);
            counts.Add(count);
        }

        static void AddRow(DataTable table, string category, string parameter, string value, string unit)
        {
            table.Rows.Add(category, parameter, value ?? "", unit ?? "");
        }

        static string GetString(Dictionary<string, object> dict, string key)
        {
            if (dict == null)
                return "";
            object value;
            if (!dict.TryGetValue(key, out value) || value == null)
                return "";
            return Convert.ToString(value);
        }

        static int GetInt(Dictionary<string, object> dict, string key)
        {
            if (dict == null)
                return 0;
            object value;
            if (!dict.TryGetValue(key, out value) || value == null)
                return 0;
            if (value is int)
                return (int)value;
            if (value is double)
                return (int)Math.Round((double)value);
            string text = Convert.ToString(value);
            int parsed;
            if (int.TryParse(text, out parsed))
                return parsed;
            double d;
            if (double.TryParse(text, out d))
                return (int)Math.Round(d);
            return 0;
        }
    }
}
