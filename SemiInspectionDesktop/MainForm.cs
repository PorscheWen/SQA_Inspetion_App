using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.IO;
using System.Windows.Forms;
using SemiInspectionDesktop.Models;
using SemiInspectionDesktop.UI;

namespace SemiInspectionDesktop
{
    public partial class MainForm : Form
    {
        const int ToolTabParameters = 0;
        const int ToolTabDefectChart = 1;

        readonly List<string> chartDefectTypes = new List<string>();
        readonly List<int> chartDefectCounts = new List<int>();
        string workspaceRoot;
        string currentFilePath;
        string currentRecipeFilePath;
        InspectionRecipeLoadResult currentRecipe;

        public MainForm()
        {
            InitializeComponent();
            SetupTreeIcons();
            SetupToolbar0();
            SetupToolbar1();
            ApplyToolbarAccessibility();
            workspaceRoot = ResolveRecipeDataRoot();
            lblFileTree.Text = "File Tree (Recipe_data)";
            recipeOpenFileDialog.InitialDirectory = workspaceRoot;
            recipeImportFileDialog.InitialDirectory = workspaceRoot;
            RefreshFileTree();
            HideToolTabHeaders();
            UpdateCloseRecipeMenuState();
            AppendToolLog("Semi Inspection Desktop 已啟動。");
            AppendToolLog("File Tree 路徑: " + workspaceRoot);
        }

        void HideToolTabHeaders()
        {
            toolTabControl.Appearance = TabAppearance.FlatButtons;
            toolTabControl.SizeMode = TabSizeMode.Fixed;
            toolTabControl.ItemSize = new Size(0, 1);
            toolTabControl.Padding = new Point(0, 0);
        }

        static string ResolveRecipeDataRoot()
        {
            string besideExe = Path.Combine(Application.StartupPath, "Recipe_data");
            if (Directory.Exists(besideExe))
                return Path.GetFullPath(besideExe);

            string projectRoot = Path.GetFullPath(
                Path.Combine(Application.StartupPath, @"..\..\..\Recipe_data"));
            if (Directory.Exists(projectRoot))
                return projectRoot;

            Directory.CreateDirectory(besideExe);
            return Path.GetFullPath(besideExe);
        }

        void SetupToolbar0()
        {
            Image importIcon = ToolbarIcons.CreateImportRecipeIcon();
            toolbarImageList.Images.Add("importrecipe", importIcon);
            btnImportRecipe.Image = toolbarImageList.Images["importrecipe"];
            btnImportRecipe.DisplayStyle = ToolStripItemDisplayStyle.ImageAndText;
            btnImportRecipe.ToolTipText = ToolbarFeatureGuide.ImportRecipeTooltip;

            Image runIcon = ToolbarIcons.CreateRunInspectionIcon();
            toolbarImageList.Images.Add("runinspection", runIcon);
            btnRunInspection.Image = toolbarImageList.Images["runinspection"];
            btnRunInspection.DisplayStyle = ToolStripItemDisplayStyle.ImageAndText;
            btnRunInspection.ToolTipText = ToolbarFeatureGuide.RunInspectionTooltip;

            Image aboutIcon = ToolbarIcons.CreateAboutIcon();
            toolbarImageList.Images.Add("about", aboutIcon);
            btnToolbar0About.Image = toolbarImageList.Images["about"];
            btnToolbar0About.DisplayStyle = ToolStripItemDisplayStyle.ImageAndText;
            btnToolbar0About.ToolTipText = ToolbarFeatureGuide.AboutTooltip;
        }

        void SetupToolbar1()
        {
            Image tableIcon = ToolbarIcons.CreateRawDataIcon();
            toolbarImageList.Images.Add("rawdata", tableIcon);
            btnParameters.Image = toolbarImageList.Images["rawdata"];
            btnParameters.DisplayStyle = ToolStripItemDisplayStyle.ImageAndText;
            btnParameters.Text = ToolbarFeatureGuide.RawDataName;
            btnParameters.ToolTipText = ToolbarFeatureGuide.RawDataTooltip;

            Image chartIcon = ToolbarIcons.CreateDefectChartIcon();
            toolbarImageList.Images.Add("chart", chartIcon);
            btnDefectChart.Image = toolbarImageList.Images["chart"];
            btnDefectChart.DisplayStyle = ToolStripItemDisplayStyle.ImageAndText;
            btnDefectChart.ToolTipText = ToolbarFeatureGuide.DefectChartTooltip;
        }

        void ApplyToolbarAccessibility()
        {
            btnImportRecipe.AccessibleName = btnImportRecipe.Text;
            btnRunInspection.AccessibleName = btnRunInspection.Text;
            btnToolbar0About.AccessibleName = btnToolbar0About.Text;
            btnParameters.AccessibleName = btnParameters.Text;
            btnDefectChart.AccessibleName = btnDefectChart.Text;
            dataGridParameters.AccessibleName = dataGridParameters.Name;
            txtToolLog.AccessibleName = txtToolLog.Name;
            treeFiles.AccessibleName = treeFiles.Name;
            menuFileCloseRecipe.AccessibleName = menuFileCloseRecipe.Text;
        }

        void SetupTreeIcons()
        {
            treeImageList.Images.Clear();
            treeImageList.Images.Add("folder", SystemIcons.WinLogo.ToBitmap());
            treeImageList.Images.Add("file", SystemIcons.Application.ToBitmap());
        }

        public void AppendToolLog(string message)
        {
            if (string.IsNullOrEmpty(message))
                return;
            txtToolLog.AppendText(DateTime.Now.ToString("HH:mm:ss") + " " + message + Environment.NewLine);
            string logText = txtToolLog.Text;
            if (logText.Length > 512)
                logText = logText.Substring(logText.Length - 512);
            txtToolLog.AccessibleName = logText;
        }

        void SwitchToToolTab(int tabIndex)
        {
            if (tabIndex < 0 || tabIndex >= toolTabControl.TabCount)
                return;
            toolTabControl.SelectedIndex = tabIndex;
        }

        void btnToolbar0About_Click(object sender, EventArgs e)
        {
            ShowAboutDialog();
        }

        void btnImportRecipe_Click(object sender, EventArgs e)
        {
            ImportRecipeFile();
        }

        void ImportRecipeFile()
        {
            if (!Directory.Exists(workspaceRoot))
                Directory.CreateDirectory(workspaceRoot);

            recipeImportFileDialog.InitialDirectory = workspaceRoot;
            recipeImportFileDialog.Title = "Import Recipe";
            if (recipeImportFileDialog.ShowDialog(this) != DialogResult.OK)
                return;

            string sourcePath = recipeImportFileDialog.FileName;
            if (!IsJsonFile(sourcePath))
            {
                MessageBox.Show(this, "請選擇 .json Recipe 檔案。", "Import Recipe",
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            try
            {
                string fileName = Path.GetFileName(sourcePath);
                string destPath = Path.Combine(workspaceRoot, fileName);
                string fullSource = Path.GetFullPath(sourcePath);
                string fullDest = Path.GetFullPath(destPath);

                if (!string.Equals(fullSource, fullDest, StringComparison.OrdinalIgnoreCase))
                    File.Copy(sourcePath, destPath, true);

                OpenRecipeFile(fullDest);
                RefreshFileTree();
                if (string.Equals(fullSource, fullDest, StringComparison.OrdinalIgnoreCase))
                    AppendToolLog("Import Recipe: 已載入 " + fullDest);
                else
                    AppendToolLog("Import Recipe: " + sourcePath + " -> " + destPath);
                statusLabel.Text = "Import Recipe: " + Path.GetFileName(fullDest);
            }
            catch (Exception ex)
            {
                AppendToolLog("Import Recipe 失敗: " + ex.Message);
                MessageBox.Show(this, ex.Message, "Import Recipe",
                    MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        void RefreshFileTree()
        {
            treeFiles.BeginUpdate();
            treeFiles.Nodes.Clear();
            if (!Directory.Exists(workspaceRoot))
            {
                statusLabel.Text = "找不到 Recipe_data: " + workspaceRoot;
                treeFiles.EndUpdate();
                return;
            }

            TreeNode root = new TreeNode(Path.GetFileName(workspaceRoot));
            root.Tag = workspaceRoot;
            root.ImageKey = root.SelectedImageKey = "folder";
            BuildDirectoryNodes(root, workspaceRoot);
            treeFiles.Nodes.Add(root);
            root.Expand();
            statusLabel.Text = "File Tree: " + workspaceRoot;
            treeFiles.EndUpdate();
        }

        void BuildDirectoryNodes(TreeNode parent, string path)
        {
            try
            {
                string[] dirs = Directory.GetDirectories(path);
                Array.Sort(dirs, StringComparer.OrdinalIgnoreCase);
                foreach (string dir in dirs)
                {
                    string name = Path.GetFileName(dir);
                    if (name.StartsWith(".") || name == "obj" || name == "bin")
                        continue;
                    TreeNode node = new TreeNode(name);
                    node.Tag = dir;
                    node.ImageKey = node.SelectedImageKey = "folder";
                    parent.Nodes.Add(node);
                    BuildDirectoryNodes(node, dir);
                }

                string[] files = Directory.GetFiles(path);
                Array.Sort(files, StringComparer.OrdinalIgnoreCase);
                foreach (string file in files)
                {
                    TreeNode node = new TreeNode(Path.GetFileName(file));
                    node.Tag = file;
                    node.ImageKey = node.SelectedImageKey = "file";
                    parent.Nodes.Add(node);
                }
            }
            catch (UnauthorizedAccessException)
            {
            }
        }

        void treeFiles_AfterSelect(object sender, TreeViewEventArgs e)
        {
            if (e.Node == null || e.Node.Tag == null)
                return;
            string path = e.Node.Tag as string;
            if (path == null)
                return;
            if (Directory.Exists(path))
                statusLabel.Text = "資料夾: " + path;
            else
                statusLabel.Text = "檔案: " + path;
        }

        void treeFiles_NodeMouseDoubleClick(object sender, TreeNodeMouseClickEventArgs e)
        {
            if (e.Node == null || e.Node.Tag == null)
                return;
            string path = e.Node.Tag as string;
            if (path == null || Directory.Exists(path))
            {
                if (Directory.Exists(path))
                    e.Node.Expand();
                return;
            }
            if (IsJsonFile(path))
                OpenRecipeFile(path);
            else
                OpenFileInWorkspace(path);
        }

        static bool IsJsonFile(string path)
        {
            return string.Equals(Path.GetExtension(path), ".json", StringComparison.OrdinalIgnoreCase);
        }

        void btnParameters_Click(object sender, EventArgs e)
        {
            SwitchToToolTab(ToolTabParameters);
            AppendToolLog("RawData: 切換至參數表檢視");
            statusLabel.Text = "RawData: parameters view";
            EnsureRecipeLoaded();
        }

        void EnsureRecipeLoaded()
        {
            if (dataGridParameters.DataSource != null)
                return;

            string samplePath = Path.Combine(workspaceRoot, "InspectionRecipe_Sample.json");
            if (File.Exists(samplePath))
            {
                OpenRecipeFile(samplePath);
                return;
            }

            recipeOpenFileDialog.InitialDirectory = workspaceRoot;
            if (recipeOpenFileDialog.ShowDialog(this) == DialogResult.OK)
                OpenRecipeFile(recipeOpenFileDialog.FileName);
        }

        void OpenRecipeFile(string filePath)
        {
            try
            {
                InspectionRecipeLoadResult result = InspectionRecipeService.Load(filePath);
                ApplyRecipeResult(result);
            }
            catch (Exception ex)
            {
                AppendToolLog("Recipe 開啟失敗: " + ex.Message);
                MessageBox.Show(this, ex.Message, "開啟 Recipe",
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        void ApplyRecipeResult(InspectionRecipeLoadResult result)
        {
            currentRecipe = result;
            SwitchToToolTab(ToolTabParameters);
            dataGridParameters.DataSource = result.Parameters;
            currentRecipeFilePath = result.FilePath;

            chartDefectTypes.Clear();
            chartDefectCounts.Clear();
            if (result.DefectTypes != null && result.DefectCounts != null)
            {
                chartDefectTypes.AddRange(result.DefectTypes);
                chartDefectCounts.AddRange(result.DefectCounts);
            }

            lblToolPlugin.Text = "RawData - " + Path.GetFileName(result.FilePath)
                + " [" + result.RecipeName + "]";
            lblToolPlugin.AccessibleName = lblToolPlugin.Text;
            AppendToolLog("已載入 Recipe: " + result.FilePath);
            AppendToolLog("Lot/Wafer: " + result.LotId + " / " + result.WaferId);
            AppendToolLog("參數列數: " + result.Parameters.Rows.Count);
            AppendToolLog("DefectSummary: " + chartDefectTypes.Count + " 類型");
            statusLabel.Text = "Recipe: " + result.FilePath;
            pictureBoxChart.Invalidate();
            UpdateCloseRecipeMenuState();
        }

        void UpdateCloseRecipeMenuState()
        {
            bool hasRecipe = dataGridParameters.DataSource != null
                || !string.IsNullOrEmpty(currentRecipeFilePath);
            menuFileCloseRecipe.Enabled = hasRecipe;
        }

        void CloseRecipeFile()
        {
            if (!menuFileCloseRecipe.Enabled)
                return;

            string closedPath = currentRecipeFilePath;
            if (string.IsNullOrEmpty(closedPath))
                closedPath = "(in-memory recipe)";

            dataGridParameters.DataSource = null;
            currentRecipeFilePath = null;
            currentRecipe = null;
            chartDefectTypes.Clear();
            chartDefectCounts.Clear();
            pictureBoxChart.Invalidate();
            lblToolPlugin.Text = "Tool Plugin Workspace";
            AppendToolLog("Close Recipe: " + closedPath);
            statusLabel.Text = "Recipe: 已關閉";
            UpdateCloseRecipeMenuState();
        }

        void menuFileCloseRecipe_Click(object sender, EventArgs e)
        {
            CloseRecipeFile();
        }

        void btnDefectChart_Click(object sender, EventArgs e)
        {
            SwitchToToolTab(ToolTabDefectChart);
            AppendToolLog("Defect Chart: 切換至圖表檢視");
            ShowDefectChart();
        }

        void ShowDefectChart()
        {
            try
            {
                EnsureRecipeLoaded();
                SyncChartDataFromRecipe();

                if (chartDefectTypes.Count == 0)
                {
                    MessageBox.Show(this,
                        "Recipe 中找不到 DefectSummary 資料。\r\n請確認 JSON 含 DefectSummary 陣列。",
                        "Defect Chart",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Warning);
                    return;
                }

                SwitchToToolTab(ToolTabDefectChart);
                pictureBoxChart.Invalidate();
                pictureBoxChart.Refresh();
                lblToolPlugin.Text = "Defect Chart (" + chartDefectTypes.Count + " types)";
                lblToolPlugin.AccessibleName = lblToolPlugin.Text;
                AppendToolLog("Defect Chart: 已繪製 " + chartDefectTypes.Count + " 類 DefectType / DefectCount 曲線圖。");
                statusLabel.Text = "Defect Chart: " + chartDefectTypes.Count + " types";
            }
            catch (Exception ex)
            {
                AppendToolLog("Defect Chart 失敗: " + ex.Message);
                MessageBox.Show(this, ex.Message, "Defect Chart", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        void SyncChartDataFromRecipe()
        {
            if (chartDefectTypes.Count > 0)
                return;

            if (!string.IsNullOrEmpty(currentRecipeFilePath) && File.Exists(currentRecipeFilePath))
            {
                InspectionRecipeLoadResult refreshed = InspectionRecipeService.Load(currentRecipeFilePath);
                currentRecipe = refreshed;
                chartDefectTypes.Clear();
                chartDefectCounts.Clear();
                if (refreshed.DefectTypes != null && refreshed.DefectCounts != null)
                {
                    chartDefectTypes.AddRange(refreshed.DefectTypes);
                    chartDefectCounts.AddRange(refreshed.DefectCounts);
                }
                return;
            }

            if (currentRecipe == null)
                return;

            if (currentRecipe.DefectTypes != null && currentRecipe.DefectCounts != null
                && currentRecipe.DefectTypes.Count > 0)
            {
                chartDefectTypes.Clear();
                chartDefectCounts.Clear();
                chartDefectTypes.AddRange(currentRecipe.DefectTypes);
                chartDefectCounts.AddRange(currentRecipe.DefectCounts);
            }
        }

        void RunInspection()
        {
            if (currentRecipe == null)
            {
                MessageBox.Show(this,
                    "請先載入 Inspection Recipe（Import Recipe 或雙擊 .json）。",
                    "Run Inspection",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Information);
                return;
            }

            AppendToolLog("Run Inspection: 開始模擬檢測...");
            AppendToolLog("  Recipe: " + currentRecipe.RecipeName);
            AppendToolLog("  Tool: " + GetParameterValue("ToolID"));
            AppendToolLog("  Optical: " + GetParameterValue("Illumination")
                + " / PixelSize=" + GetParameterValue("PixelSize"));
            AppendToolLog("  Detection: " + GetParameterValue("Algorithm")
                + " / Threshold=" + GetParameterValue("Threshold"));
            int totalDefects = 0;
            for (int i = 0; i < chartDefectCounts.Count; i++)
                totalDefects += chartDefectCounts[i];
            AppendToolLog("  DefectSummary 合計: " + totalDefects + " defects / "
                + chartDefectTypes.Count + " types");
            AppendToolLog("Run Inspection: 完成（模擬）。");
            statusLabel.Text = "Run Inspection: complete - " + currentRecipe.RecipeName;
        }

        string GetParameterValue(string parameterName)
        {
            if (currentRecipe == null || currentRecipe.Parameters == null)
                return "";
            foreach (DataRow row in currentRecipe.Parameters.Rows)
            {
                string name = Convert.ToString(row["Parameter"]).Trim();
                if (string.Equals(name, parameterName, StringComparison.OrdinalIgnoreCase))
                    return Convert.ToString(row["Value"]);
            }
            return "";
        }

        void pictureBoxChart_Paint(object sender, PaintEventArgs e)
        {
            if (chartDefectTypes.Count == 0)
            {
                using (Font font = new Font("Microsoft JhengHei UI", 9f))
                using (SolidBrush brush = new SolidBrush(Color.Gray))
                {
                    e.Graphics.DrawString("按「Defect Chart」顯示 DefectType / DefectCount 曲線圖", font, brush, 12, 12);
                }
                return;
            }

            DefectChartRenderer.PaintChart(e.Graphics, pictureBoxChart.ClientRectangle,
                chartDefectTypes, chartDefectCounts);
        }

        void pictureBoxChart_Resize(object sender, EventArgs e)
        {
            pictureBoxChart.Invalidate();
        }

        void OpenFileInWorkspace(string path)
        {
            currentFilePath = path;
            try
            {
                txtFileContent.Text = File.ReadAllText(path);
                AppendToolLog("開啟檔案: " + path);
                statusLabel.Text = "已開啟: " + path;
            }
            catch (Exception ex)
            {
                AppendToolLog("無法開啟檔案: " + ex.Message);
            }
        }

        void menuFileNew_Click(object sender, EventArgs e)
        {
            txtFileContent.Clear();
            currentFilePath = null;
            AppendToolLog("新文件");
            statusLabel.Text = "File: 新文件";
        }

        void menuFileOpen_Click(object sender, EventArgs e)
        {
            if (openFileDialog.ShowDialog(this) != DialogResult.OK)
                return;
            OpenFileInWorkspace(openFileDialog.FileName);
        }

        void menuFileSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(currentFilePath))
            {
                if (saveFileDialog.ShowDialog(this) != DialogResult.OK)
                    return;
                currentFilePath = saveFileDialog.FileName;
            }
            File.WriteAllText(currentFilePath, txtFileContent.Text);
            AppendToolLog("已儲存: " + currentFilePath);
            statusLabel.Text = "File: 已儲存 " + currentFilePath;
            RefreshFileTree();
        }

        void menuFileRefreshTree_Click(object sender, EventArgs e)
        {
            RefreshFileTree();
            AppendToolLog("檔案樹已重新整理。");
        }

        void menuFileExit_Click(object sender, EventArgs e)
        {
            Close();
        }

        void btnRunInspection_Click(object sender, EventArgs e)
        {
            RunInspection();
        }

        void menuToolsRunInspection_Click(object sender, EventArgs e)
        {
            RunInspection();
        }

        void menuToolsAbout_Click(object sender, EventArgs e)
        {
            ShowAboutDialog();
        }

        void ShowAboutDialog()
        {
            MessageBox.Show(
                this,
                ToolbarFeatureGuide.BuildAboutMessage(workspaceRoot),
                "About",
                MessageBoxButtons.OK,
                MessageBoxIcon.Information);
        }
    }
}
