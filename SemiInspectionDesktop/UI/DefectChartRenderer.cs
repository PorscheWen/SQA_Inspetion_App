using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;

namespace SemiInspectionDesktop.UI
{
    public static class DefectChartRenderer
    {
        const int MarginLeft = 56;
        const int MarginRight = 16;
        const int MarginTop = 36;
        const int MarginBottom = 64;

        public static void PaintChart(Graphics g, Rectangle bounds, IList<string> defectTypes, IList<int> defectCounts)
        {
            if (defectTypes == null || defectCounts == null || defectTypes.Count == 0)
                return;

            g.SmoothingMode = SmoothingMode.AntiAlias;
            g.TextRenderingHint = System.Drawing.Text.TextRenderingHint.ClearTypeGridFit;
            g.Clear(Color.White);

            Rectangle plot = new Rectangle(
                bounds.Left + MarginLeft,
                bounds.Top + MarginTop,
                Math.Max(10, bounds.Width - MarginLeft - MarginRight),
                Math.Max(10, bounds.Height - MarginTop - MarginBottom));

            using (Font titleFont = new Font("Microsoft JhengHei UI", 10f, FontStyle.Bold))
            using (Font axisFont = new Font("Microsoft JhengHei UI", 8f))
            using (Font labelFont = new Font("Microsoft JhengHei UI", 7f))
            using (SolidBrush textBrush = new SolidBrush(Color.FromArgb(40, 40, 40)))
            using (Pen axisPen = new Pen(Color.Gray, 1f))
            using (Pen gridPen = new Pen(Color.FromArgb(220, 220, 220), 1f))
            using (Pen linePen = new Pen(Color.FromArgb(0, 102, 204), 2f))
            using (SolidBrush pointBrush = new SolidBrush(Color.FromArgb(220, 50, 50)))
            {
                g.DrawString("X: Defect Type  |  Y: Defect Count", titleFont, textBrush,
                    bounds.Left + MarginLeft, bounds.Top + 8);

                int count = Math.Min(defectTypes.Count, defectCounts.Count);
                int minCount = int.MaxValue;
                int maxCount = int.MinValue;
                for (int i = 0; i < count; i++)
                {
                    if (defectCounts[i] < minCount) minCount = defectCounts[i];
                    if (defectCounts[i] > maxCount) maxCount = defectCounts[i];
                }
                if (minCount == maxCount)
                {
                    minCount = Math.Max(0, minCount - 2);
                    maxCount = maxCount + 2;
                }

                g.DrawLine(axisPen, plot.Left, plot.Top, plot.Left, plot.Bottom);
                g.DrawLine(axisPen, plot.Left, plot.Bottom, plot.Right, plot.Bottom);

                int gridLinesY = 5;
                for (int i = 0; i <= gridLinesY; i++)
                {
                    int y = plot.Bottom - (plot.Height * i / gridLinesY);
                    g.DrawLine(gridPen, plot.Left, y, plot.Right, y);
                    int tick = minCount + ((maxCount - minCount) * i / gridLinesY);
                    string tickText = tick.ToString();
                    SizeF tickSize = g.MeasureString(tickText, axisFont);
                    g.DrawString(tickText, axisFont, textBrush, plot.Left - tickSize.Width - 4f, y - (tickSize.Height / 2f));
                }

                PointF[] points = new PointF[count];
                float stepX = count > 1 ? (float)plot.Width / (count - 1) : 0f;
                for (int i = 0; i < count; i++)
                {
                    float x = plot.Left + (stepX * i);
                    float ratio = (float)(defectCounts[i] - minCount) / Math.Max(1, maxCount - minCount);
                    float y = plot.Bottom - (ratio * plot.Height);
                    points[i] = new PointF(x, y);

                    string typeLabel = Abbreviate(defectTypes[i], 10);
                    SizeF typeSize = g.MeasureString(typeLabel, labelFont);
                    g.DrawString(typeLabel, labelFont, textBrush, x - (typeSize.Width / 2f), plot.Bottom + 4f);

                    if (count > 1)
                    {
                        int gridX = plot.Left + (plot.Width * i / (count - 1));
                        g.DrawLine(gridPen, gridX, plot.Top, gridX, plot.Bottom);
                    }
                }

                if (count > 1)
                    g.DrawCurve(linePen, points, 0.35f);
                else
                    g.DrawLine(linePen, points[0].X, plot.Top, points[0].X, plot.Bottom);

                float pointRadius = 4f;
                for (int i = 0; i < count; i++)
                {
                    g.FillEllipse(pointBrush, points[i].X - pointRadius, points[i].Y - pointRadius,
                        pointRadius * 2, pointRadius * 2);
                }

                SizeF xLabelSize = g.MeasureString("Defect Type (X)", axisFont);
                g.DrawString("Defect Type (X)", axisFont, textBrush,
                    plot.Left + (plot.Width - xLabelSize.Width) / 2f, plot.Bottom + 22f);

                g.DrawString("Defect Count (Y)", axisFont, textBrush, bounds.Left + 4, plot.Top - 2);
            }
        }

        static string Abbreviate(string text, int maxLen)
        {
            if (string.IsNullOrEmpty(text))
                return "";
            if (text.Length <= maxLen)
                return text;
            return text.Substring(0, maxLen - 1) + "…";
        }
    }
}
