using System.Drawing;
using System.Drawing.Imaging;
using FlaUI.Core.AutomationElements;

namespace Inspection_AppTests.Helpers;

public static class ScreenshotHelper
{
    public static string CaptureToFile(string filePath, Window? window = null, bool forceDesktop = false)
    {
        var directory = Path.GetDirectoryName(filePath);
        if (!string.IsNullOrEmpty(directory))
        {
            Directory.CreateDirectory(directory);
        }

        if (!forceDesktop && window != null)
        {
            try
            {
                if (window.IsAvailable && TryCaptureWindow(window, filePath))
                {
                    return filePath;
                }
            }
            catch
            {
                // fall through
            }
        }

        CaptureDesktop(filePath);
        return filePath;
    }

    private static bool TryCaptureWindow(Window window, string filePath)
    {
        using var captureImage = window.Capture();
        if (IsLikelyBlankCapture(captureImage))
        {
            return false;
        }

        captureImage.Save(filePath, ImageFormat.Png);
        Console.WriteLine($"截圖已儲存: {filePath}");
        return true;
    }

    private static bool IsLikelyBlankCapture(Bitmap bitmap)
    {
        if (bitmap.Width <= 1 || bitmap.Height <= 1)
        {
            return true;
        }

        var samplePoints = new[]
        {
            new Point(bitmap.Width / 2, bitmap.Height / 2),
            new Point(Math.Max(0, bitmap.Width / 4), Math.Max(0, bitmap.Height / 4)),
            new Point(Math.Max(0, bitmap.Width * 3 / 4), Math.Max(0, bitmap.Height * 3 / 4)),
        };

        var darkCount = 0;
        foreach (var point in samplePoints)
        {
            var color = bitmap.GetPixel(point.X, point.Y);
            if (color.R < 8 && color.G < 8 && color.B < 8)
            {
                darkCount++;
            }
        }

        return darkCount == samplePoints.Length;
    }

    public static void TakeScreenshot(Window window, string filePath)
    {
        if (!TryCaptureWindow(window, filePath))
        {
            CaptureDesktop(filePath);
        }
    }

    public static void CaptureDesktop(string filePath)
    {
        var bounds = System.Windows.Forms.Screen.PrimaryScreen?.Bounds ?? new Rectangle(0, 0, 1920, 1080);
        using var bitmap = new Bitmap(bounds.Width, bounds.Height);
        using (var g = Graphics.FromImage(bitmap))
        {
            g.CopyFromScreen(bounds.Location, Point.Empty, bounds.Size);
        }

        bitmap.Save(filePath, ImageFormat.Png);
        Console.WriteLine($"桌面截圖已儲存: {filePath}");
    }
}
