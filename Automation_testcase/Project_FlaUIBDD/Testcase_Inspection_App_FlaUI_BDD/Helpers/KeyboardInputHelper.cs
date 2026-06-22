using System.Globalization;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using FlaUI.Core.Input;
using FlaUI.Core.WindowsAPI;

namespace Inspection_AppTests.Helpers;

/// <summary>避免中文輸入法干擾路徑輸入；以剪貼簿貼上取代逐字鍵入。</summary>
public static class KeyboardInputHelper
{
    private const uint KlfActivate = 0x00000001;

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    private static extern IntPtr LoadKeyboardLayout(string pwszKlid, uint flags);

    public static void EnsureEnglishInput()
    {
        try
        {
            var english = InputLanguage.FromCulture(new CultureInfo("en-US"));
            if (english != null)
            {
                InputLanguage.CurrentInputLanguage = english;
            }
        }
        catch
        {
            // ignore
        }

        try
        {
            LoadKeyboardLayout("00000409", KlfActivate);
        }
        catch
        {
            // ignore
        }
    }

    public static void PasteText(string text, bool selectAllFirst = true)
    {
        EnsureEnglishInput();
        DismissImeComposition();

        var previous = TryGetClipboardText();
        try
        {
            SetClipboardTextSta(text);
            Thread.Sleep(120);

            if (selectAllFirst)
            {
                Keyboard.TypeSimultaneously(VirtualKeyShort.CONTROL, VirtualKeyShort.KEY_A);
                Thread.Sleep(80);
            }

            Keyboard.TypeSimultaneously(VirtualKeyShort.CONTROL, VirtualKeyShort.KEY_V);
            Thread.Sleep(150);
        }
        finally
        {
            if (previous != null)
            {
                try
                {
                    SetClipboardTextSta(previous);
                }
                catch
                {
                    // ignore restore
                }
            }
        }
    }

    private static void DismissImeComposition()
    {
        try
        {
            Keyboard.Press(VirtualKeyShort.ESCAPE);
            Thread.Sleep(80);
        }
        catch
        {
            // ignore
        }
    }

    private static string? TryGetClipboardText()
    {
        try
        {
            return GetClipboardTextSta();
        }
        catch
        {
            return null;
        }
    }

    private static void SetClipboardTextSta(string text)
    {
        RunSta(() => Clipboard.SetText(text));
    }

    private static string GetClipboardTextSta()
    {
        return RunSta(() => Clipboard.GetText());
    }

    private static void RunSta(Action action)
    {
        Exception? error = null;
        var thread = new Thread(() =>
        {
            try
            {
                action();
            }
            catch (Exception ex)
            {
                error = ex;
            }
        });
        thread.SetApartmentState(ApartmentState.STA);
        thread.Start();
        thread.Join(5000);
        if (error != null)
        {
            throw error;
        }
    }

    private static T RunSta<T>(Func<T> func)
    {
        T? result = default;
        Exception? error = null;
        var thread = new Thread(() =>
        {
            try
            {
                result = func();
            }
            catch (Exception ex)
            {
                error = ex;
            }
        });
        thread.SetApartmentState(ApartmentState.STA);
        thread.Start();
        thread.Join(5000);
        if (error != null)
        {
            throw error;
        }

        return result!;
    }
}
