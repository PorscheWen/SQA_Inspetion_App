using System.Drawing;
using System.Drawing.Drawing2D;

namespace SemiInspectionDesktop.UI
{
    /// <summary>依半導體 Inspection Recipe 資料結構設計的工具列圖示（16x16）。</summary>
    public static class ToolbarIcons
    {
        public static Image CreateImportRecipeIcon()
        {
            Bitmap bmp = new Bitmap(16, 16);
            using (Graphics g = Graphics.FromImage(bmp))
            {
                g.Clear(Color.Transparent);
                g.SmoothingMode = SmoothingMode.AntiAlias;

                // 晶圓圓盤
                using (SolidBrush wafer = new SolidBrush(Color.FromArgb(200, 210, 220)))
                    g.FillEllipse(wafer, 1, 2, 10, 10);
                using (Pen notch = new Pen(Color.FromArgb(120, 130, 150), 1f))
                    g.DrawLine(notch, 5, 2, 5, 5);

                // Recipe 文件
                using (SolidBrush doc = new SolidBrush(Color.FromArgb(255, 140, 0)))
                    g.FillRectangle(doc, 8, 1, 7, 9);
                using (Font font = new Font("Arial", 5f, FontStyle.Bold))
                using (SolidBrush white = new SolidBrush(Color.White))
                    g.DrawString("R", font, white, 9f, 1f);

                // 匯入箭頭
                using (Pen arrow = new Pen(Color.FromArgb(0, 120, 60), 1.5f))
                {
                    g.DrawLine(arrow, 6, 12, 10, 12);
                    g.DrawLine(arrow, 9, 10, 10, 12);
                    g.DrawLine(arrow, 9, 14, 10, 12);
                }
            }
            return bmp;
        }

        public static Image CreateRawDataIcon()
        {
            Bitmap bmp = new Bitmap(16, 16);
            using (Graphics g = Graphics.FromImage(bmp))
            {
                g.Clear(Color.Transparent);
                g.SmoothingMode = SmoothingMode.AntiAlias;

                using (SolidBrush header = new SolidBrush(Color.FromArgb(68, 114, 196)))
                    g.FillRectangle(header, 1, 1, 14, 4);

                using (Pen rowPen = new Pen(Color.FromArgb(100, 100, 100), 1f))
                {
                    for (int y = 6; y <= 13; y += 3)
                        g.DrawLine(rowPen, 1, y, 14, y);
                    g.DrawLine(rowPen, 5, 5, 5, 14);
                    g.DrawLine(rowPen, 10, 5, 10, 14);
                }

                using (Font font = new Font("Arial", 5f, FontStyle.Bold))
                using (SolidBrush white = new SolidBrush(Color.White))
                    g.DrawString("RAW", font, white, 2f, 1f);
            }
            return bmp;
        }

        public static Image CreateParametersIcon()
        {
            return CreateRawDataIcon();
        }

        public static Image CreateDefectChartIcon()
        {
            Bitmap bmp = new Bitmap(16, 16);
            using (Graphics g = Graphics.FromImage(bmp))
            {
                g.Clear(Color.Transparent);
                g.SmoothingMode = SmoothingMode.AntiAlias;

                // 晶圓外框
                using (Pen waferRing = new Pen(Color.FromArgb(160, 170, 180), 1f))
                    g.DrawEllipse(waferRing, 0, 3, 12, 12);

                // 缺陷趨勢曲線
                using (Pen trend = new Pen(Color.FromArgb(0, 102, 204), 2f))
                {
                    g.DrawLine(trend, 1, 13, 4, 10);
                    g.DrawLine(trend, 4, 10, 7, 11);
                    g.DrawLine(trend, 7, 11, 11, 5);
                }

                // Defect 點（Particle / Scratch / Bridge 代表色）
                using (SolidBrush p1 = new SolidBrush(Color.FromArgb(220, 50, 50)))
                    g.FillEllipse(p1, 3, 9, 3, 3);
                using (SolidBrush p2 = new SolidBrush(Color.FromArgb(255, 165, 0)))
                    g.FillEllipse(p2, 6, 10, 3, 3);
                using (SolidBrush p3 = new SolidBrush(Color.FromArgb(180, 40, 40)))
                    g.FillEllipse(p3, 10, 4, 3, 3);
            }
            return bmp;
        }

        public static Image CreateRunInspectionIcon()
        {
            Bitmap bmp = new Bitmap(16, 16);
            using (Graphics g = Graphics.FromImage(bmp))
            {
                g.Clear(Color.Transparent);
                g.SmoothingMode = SmoothingMode.AntiAlias;

                // AOI 掃描線
                using (Pen scan = new Pen(Color.FromArgb(100, 180, 255), 1f))
                {
                    g.DrawLine(scan, 1, 4, 15, 4);
                    g.DrawLine(scan, 1, 8, 15, 8);
                    g.DrawLine(scan, 1, 12, 15, 12);
                }

                // 播放/執行三角
                PointF[] play = {
                    new PointF(5, 3), new PointF(5, 13), new PointF(13, 8)
                };
                using (SolidBrush green = new SolidBrush(Color.FromArgb(46, 160, 67)))
                    g.FillPolygon(green, play);
            }
            return bmp;
        }

        public static Image CreateAboutIcon()
        {
            Bitmap bmp = new Bitmap(16, 16);
            using (Graphics g = Graphics.FromImage(bmp))
            {
                g.Clear(Color.Transparent);
                g.SmoothingMode = SmoothingMode.AntiAlias;
                using (Pen ring = new Pen(Color.FromArgb(0, 102, 204), 2f))
                    g.DrawEllipse(ring, 2, 2, 12, 12);
                using (Font font = new Font("Arial", 9f, FontStyle.Bold))
                using (SolidBrush blue = new SolidBrush(Color.FromArgb(0, 102, 204)))
                    g.DrawString("i", font, blue, 5f, 1f);
            }
            return bmp;
        }

        // 相容舊名稱
        public static Image CreateImportJsonIcon()
        {
            return CreateImportRecipeIcon();
        }

        public static Image CreateDataTableIcon()
        {
            return CreateRawDataIcon();
        }

        public static Image CreateChartIcon()
        {
            return CreateDefectChartIcon();
        }

        public static Image CreateExcelIcon()
        {
            return CreateRawDataIcon();
        }
    }
}
