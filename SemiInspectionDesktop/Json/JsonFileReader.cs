using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;

namespace SemiInspectionDesktop.Json
{
    public sealed class JsonFileReader
    {
        public sealed class JsonLoadResult
        {
            public string FilePath { get; set; }
            public DataTable Table { get; set; }
        }

        public static Dictionary<string, object> LoadDictionary(string filePath)
        {
            if (!File.Exists(filePath))
                throw new FileNotFoundException("找不到 JSON 檔案。", filePath);

            string ext = Path.GetExtension(filePath).ToLowerInvariant();
            if (ext != ".json")
                throw new NotSupportedException("僅支援 .json 格式。");

            string json = ReadUtf8Text(filePath);
            object root = SimpleJsonParser.Parse(json);
            Dictionary<string, object> dict = root as Dictionary<string, object>;
            if (dict == null)
                throw new InvalidOperationException("JSON 根節點必須為物件。");
            return dict;
        }

        public static JsonLoadResult Load(string filePath)
        {
            if (!File.Exists(filePath))
                throw new FileNotFoundException("找不到 JSON 檔案。", filePath);

            string ext = Path.GetExtension(filePath).ToLowerInvariant();
            if (ext != ".json")
                throw new NotSupportedException("僅支援 .json 格式。");

            string json = ReadUtf8Text(filePath);
            if (string.IsNullOrEmpty(json))
                throw new InvalidOperationException("JSON 檔案為空。");

            object root = SimpleJsonParser.Parse(json);
            if (root == null)
                throw new InvalidOperationException("JSON 內容無法解析。");

            List<Dictionary<string, object>> rows = ExtractRows(root);
            if (rows.Count == 0)
                throw new InvalidOperationException("JSON 中找不到可載入的資料列。");

            DataTable table = BuildTable(rows);
            return new JsonLoadResult
            {
                FilePath = filePath,
                Table = table
            };
        }

        static string ReadUtf8Text(string filePath)
        {
            byte[] bytes = File.ReadAllBytes(filePath);
            if (bytes.Length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF)
                return Encoding.UTF8.GetString(bytes, 3, bytes.Length - 3);
            return Encoding.UTF8.GetString(bytes);
        }

        static List<Dictionary<string, object>> ExtractRows(object root)
        {
            List<Dictionary<string, object>> rows = new List<Dictionary<string, object>>();

            List<object> array = root as List<object>;
            if (array != null)
            {
                foreach (object item in array)
                    AddRow(rows, item);
                return rows;
            }

            Dictionary<string, object> dict = root as Dictionary<string, object>;
            if (dict == null)
                return rows;

            object nested = GetFirstArray(dict, "Record", "Records", "records", "data", "items");
            if (nested != null)
            {
                List<object> nestedArray = nested as List<object>;
                if (nestedArray != null)
                {
                    foreach (object item in nestedArray)
                        AddRow(rows, item);
                    return rows;
                }
            }

            rows.Add(dict);
            return rows;
        }

        static object GetFirstArray(Dictionary<string, object> dict, params string[] keys)
        {
            foreach (string key in keys)
            {
                foreach (KeyValuePair<string, object> pair in dict)
                {
                    if (string.Equals(pair.Key, key, StringComparison.OrdinalIgnoreCase))
                        return pair.Value;
                }
            }
            return null;
        }

        static void AddRow(List<Dictionary<string, object>> rows, object item)
        {
            Dictionary<string, object> row = item as Dictionary<string, object>;
            if (row != null)
                rows.Add(row);
        }

        static DataTable BuildTable(List<Dictionary<string, object>> rows)
        {
            List<string> columns = new List<string>();
            foreach (Dictionary<string, object> row in rows)
            {
                foreach (string key in row.Keys)
                {
                    if (!columns.Contains(key))
                        columns.Add(key);
                }
            }

            DataTable table = new DataTable();
            foreach (string column in columns)
                table.Columns.Add(column, typeof(string));

            foreach (Dictionary<string, object> row in rows)
            {
                DataRow dataRow = table.NewRow();
                foreach (string column in columns)
                {
                    object value;
                    if (row.TryGetValue(column, out value) && value != null)
                        dataRow[column] = Convert.ToString(value);
                    else
                        dataRow[column] = "";
                }
                table.Rows.Add(dataRow);
            }

            return table;
        }

        sealed class SimpleJsonParser
        {
            readonly string _text;
            int _index;

            SimpleJsonParser(string text)
            {
                _text = text;
                _index = 0;
            }

            public static object Parse(string text)
            {
                SimpleJsonParser parser = new SimpleJsonParser(text);
                parser.SkipWhitespace();
                object value = parser.ParseValue();
                parser.SkipWhitespace();
                if (parser._index < parser._text.Length)
                    throw new InvalidOperationException("JSON 格式錯誤：多餘字元。");
                return value;
            }

            object ParseValue()
            {
                SkipWhitespace();
                if (_index >= _text.Length)
                    throw new InvalidOperationException("JSON 格式錯誤：內容不完整。");

                char ch = _text[_index];
                if (ch == '{')
                    return ParseObject();
                if (ch == '[')
                    return ParseArray();
                if (ch == '"')
                    return ParseString();
                if (ch == 't' || ch == 'f')
                    return ParseBoolean();
                if (ch == 'n')
                    return ParseNull();
                if (ch == '-' || (ch >= '0' && ch <= '9'))
                    return ParseNumber();

                throw new InvalidOperationException("JSON 格式錯誤：未知值 @" + _index + "。");
            }

            Dictionary<string, object> ParseObject()
            {
                Dictionary<string, object> obj = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
                Expect('{');
                SkipWhitespace();
                if (TryConsume('}'))
                    return obj;

                while (true)
                {
                    SkipWhitespace();
                    string key = ParseString();
                    SkipWhitespace();
                    Expect(':');
                    object value = ParseValue();
                    obj[key] = value;
                    SkipWhitespace();
                    if (TryConsume('}'))
                        return obj;
                    Expect(',');
                }
            }

            List<object> ParseArray()
            {
                List<object> array = new List<object>();
                Expect('[');
                SkipWhitespace();
                if (TryConsume(']'))
                    return array;

                while (true)
                {
                    array.Add(ParseValue());
                    SkipWhitespace();
                    if (TryConsume(']'))
                        return array;
                    Expect(',');
                    SkipWhitespace();
                }
            }

            string ParseString()
            {
                Expect('"');
                StringBuilder sb = new StringBuilder();
                while (_index < _text.Length)
                {
                    char ch = _text[_index++];
                    if (ch == '"')
                        return sb.ToString();
                    if (ch == '\\')
                    {
                        if (_index >= _text.Length)
                            throw new InvalidOperationException("JSON 格式錯誤：字串跳脫不完整。");
                        char esc = _text[_index++];
                        switch (esc)
                        {
                            case '"': sb.Append('"'); break;
                            case '\\': sb.Append('\\'); break;
                            case '/': sb.Append('/'); break;
                            case 'b': sb.Append('\b'); break;
                            case 'f': sb.Append('\f'); break;
                            case 'n': sb.Append('\n'); break;
                            case 'r': sb.Append('\r'); break;
                            case 't': sb.Append('\t'); break;
                            case 'u':
                                if (_index + 4 > _text.Length)
                                    throw new InvalidOperationException("JSON 格式錯誤：Unicode 跳脫不完整。");
                                string hex = _text.Substring(_index, 4);
                                _index += 4;
                                sb.Append((char)Convert.ToInt32(hex, 16));
                                break;
                            default:
                                throw new InvalidOperationException("JSON 格式錯誤：不支援的跳脫字元。");
                        }
                    }
                    else
                    {
                        sb.Append(ch);
                    }
                }

                throw new InvalidOperationException("JSON 格式錯誤：字串未結束。");
            }

            object ParseNumber()
            {
                int start = _index;
                if (_text[_index] == '-')
                    _index++;
                while (_index < _text.Length && char.IsDigit(_text[_index]))
                    _index++;
                if (_index < _text.Length && _text[_index] == '.')
                {
                    _index++;
                    while (_index < _text.Length && char.IsDigit(_text[_index]))
                        _index++;
                }
                if (_index < _text.Length && (_text[_index] == 'e' || _text[_index] == 'E'))
                {
                    _index++;
                    if (_index < _text.Length && (_text[_index] == '+' || _text[_index] == '-'))
                        _index++;
                    while (_index < _text.Length && char.IsDigit(_text[_index]))
                        _index++;
                }

                string number = _text.Substring(start, _index - start);
                int intValue;
                if (int.TryParse(number, out intValue))
                    return intValue;
                return number;
            }

            object ParseBoolean()
            {
                if (Match("true"))
                    return true;
                if (Match("false"))
                    return false;
                throw new InvalidOperationException("JSON 格式錯誤：布林值不正確。");
            }

            object ParseNull()
            {
                if (Match("null"))
                    return null;
                throw new InvalidOperationException("JSON 格式錯誤：null 值不正確。");
            }

            void SkipWhitespace()
            {
                while (_index < _text.Length)
                {
                    char ch = _text[_index];
                    if (ch == ' ' || ch == '\t' || ch == '\r' || ch == '\n')
                        _index++;
                    else
                        break;
                }
            }

            void Expect(char expected)
            {
                SkipWhitespace();
                if (_index >= _text.Length || _text[_index] != expected)
                    throw new InvalidOperationException("JSON 格式錯誤：預期 '" + expected + "'。");
                _index++;
            }

            bool TryConsume(char expected)
            {
                if (_index < _text.Length && _text[_index] == expected)
                {
                    _index++;
                    return true;
                }
                return false;
            }

            bool Match(string literal)
            {
                if (_text.Length - _index < literal.Length)
                    return false;
                if (string.Compare(_text, _index, literal, 0, literal.Length, StringComparison.Ordinal) != 0)
                    return false;
                _index += literal.Length;
                return true;
            }
        }
    }
}

