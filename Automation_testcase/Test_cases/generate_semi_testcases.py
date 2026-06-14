# -*- coding: utf-8 -*-
"""Generate Semi Inspection Desktop - 10 test cases (7 functional, 3 negative)."""
import os
import zipfile
from xml.sax.saxutils import escape

NS = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
REL_NS = "http://schemas.openxmlformats.org/package/2006/relationships"
CT_NS = "http://schemas.openxmlformats.org/package/2006/content-types"

TEST_CASES = [
    ("TC01", "Functional", "Import Recipe", "Import Recipe 至 Recipe_data",
     "SemiInspectionDesktop.exe 已啟動；Recipe_data 可寫入",
     "1. 點 Toolbar0「Import Recipe」(Ctrl+I)\n2. 選 InspectionRecipe_Sample.json\n3. 確認 RawData 表格",
     "JSON 複製到 Recipe_data；DataGrid 顯示參數；日誌含 Import Recipe", "High", 2001, "Ready"),
    ("TC02", "Functional", "File Tree", "File Tree 顯示 Recipe_data",
     "應用程式已啟動",
     "1. 檢視左側 File Tree\n2. 確認根節點 Recipe_data",
     "視窗標題 Semi Inspection Desktop；樹可見；Sample JSON 存在", "High", 2002, "Ready"),
    ("TC03", "Functional", "RawData", "RawData 參數表",
     "Recipe_data 含 InspectionRecipe_Sample.json",
     "1. 點 Toolbar1「RawData」(Ctrl+E)\n2. 確認 DataGrid",
     "顯示 Category/Parameter/Value/Unit；日誌含 RawData", "High", 2003, "Ready"),
    ("TC04", "Functional", "Defect Chart", "Defect Chart 曲線圖",
     "已載入含 DefectSummary 的 Recipe",
     "1. 點 Toolbar1「Defect Chart」(Ctrl+D)\n2. 檢視圖表區",
     "日誌含 Defect Chart 已繪製 5 類；X=DefectType Y=DefectCount", "High", 2004, "Ready"),
    ("TC05", "Functional", "File Tree Open", "檔案樹雙擊開啟 Recipe",
     "Recipe_data 有 InspectionRecipe_Sample.json",
     "1. 在 File Tree 雙擊 .json\n2. 檢視 RawData",
     "DataGrid 顯示 Recipe 參數；日誌含 Recipe", "Medium", 2005, "Ready"),
    ("TC06", "Functional", "About", "About 對話框",
     "應用程式已啟動",
     "1. 點 Toolbar0「About」",
     "顯示 About（含 Recipe_data 路徑與 Inspection 功能說明）", "Low", 2006, "Ready"),
    ("TC07", "Negative", "Invalid Import", "匯入非 JSON 檔",
     "應用程式已啟動；_invalid_sample.txt 存在",
     "1. 點 Import Recipe\n2. 選擇 _invalid_sample.txt",
     "警告「請選擇 .json Recipe 檔案」；不寫入 TC01_import_copy.json", "High", 2007, "Ready"),
    ("TC08", "Negative", "Chart No Data", "無 Recipe 時繪圖",
     "重新啟動後尚未載入 Recipe",
     "1. 直接點 Defect Chart\n2. 關閉提示（若有）",
     "提示無 DefectSummary 或自動載入失敗警告；不當機", "Medium", 2008, "Ready"),
    ("TC09", "Negative", "Missing File", "開啟不存在 Recipe",
     "應用程式已啟動",
     "1. Ctrl+E 開啟 RawData 檔案對話框\n2. 選 not_exist_99999.json",
     "顯示錯誤訊息；主視窗仍可操作", "Medium", 2009, "Ready"),
    ("TC10", "Functional", "Run Inspection", "Run Inspection 模擬檢測",
     "已載入 InspectionRecipe_Sample.json",
     "1. 點 Toolbar0「Run Inspection」(Ctrl+R)\n2. 檢視日誌",
     "日誌含 Run Inspection、Recipe 名稱、ToolID、DefectSummary 合計", "High", 2010, "Ready"),
]


def col_letter(n):
    s = ""
    while n:
        n, r = divmod(n - 1, 26)
        s = chr(65 + r) + s
    return s


def sheet_xml(rows):
    lines = [
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',
        '<worksheet xmlns="%s">' % NS,
        "<sheetData>",
    ]
    for r_idx, row in enumerate(rows, 1):
        lines.append('<row r="%d">' % r_idx)
        for c_idx, val in enumerate(row, 1):
            ref = "%s%d" % (col_letter(c_idx), r_idx)
            if isinstance(val, (int, float)) and not isinstance(val, bool):
                lines.append('<c r="%s"><v>%s</v></c>' % (ref, val))
            else:
                text = escape(str(val))
                lines.append(
                    '<c r="%s" t="inlineStr"><is><t>%s</t></is></c>' % (ref, text)
                )
        lines.append("</row>")
    lines.append("</sheetData></worksheet>")
    return "\n".join(lines)


def build_xlsx(path, rows):
    sheet = sheet_xml(rows)
    content_types = """<?xml version="1.0" encoding="UTF-8"?>
<Types xmlns="%s">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
  <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
  <Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>
</Types>""" % CT_NS
    rels_root = """<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="%s">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
</Relationships>""" % REL_NS
    workbook = """<?xml version="1.0" encoding="UTF-8"?>
<workbook xmlns="%s" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <sheets><sheet name="TestCases" sheetId="1" r:id="rId1"/></sheets>
</workbook>""" % NS
    wb_rels = """<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="%s">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>""" % REL_NS
    styles = """<?xml version="1.0" encoding="UTF-8"?>
<styleSheet xmlns="%s"><fonts count="1"/><fills count="1"/><borders count="1"/><cellStyleXfs count="1"/><cellXfs count="1"/></styleSheet>""" % NS
    with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as zf:
        zf.writestr("[Content_Types].xml", content_types)
        zf.writestr("_rels/.rels", rels_root)
        zf.writestr("xl/workbook.xml", workbook)
        zf.writestr("xl/_rels/workbook.xml.rels", wb_rels)
        zf.writestr("xl/worksheets/sheet1.xml", sheet)
        zf.writestr("xl/styles.xml", styles)


def main():
    header = [
        "Test ID", "Category", "Test Type", "Title", "Preconditions",
        "Steps", "Expected Result", "Priority", "Defect Number", "Status",
    ]
    rows = [header]
    for tc in TEST_CASES:
        rows.append(list(tc))

    base = os.path.dirname(os.path.abspath(__file__))
    out_cases = os.path.join(base, "SemiInspection_10_TestCases.xlsx")
    build_xlsx(out_cases, rows)
    print("Created:", out_cases)


if __name__ == "__main__":
    main()
