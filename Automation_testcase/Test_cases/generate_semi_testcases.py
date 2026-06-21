# -*- coding: utf-8 -*-
"""Generate Semi Inspection Desktop - 10 test cases (7 functional, 3 negative)."""
import os
import zipfile
from xml.sax.saxutils import escape

NS = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
REL_NS = "http://schemas.openxmlformats.org/package/2006/relationships"
CT_NS = "http://schemas.openxmlformats.org/package/2006/content-types"

TEST_CASES = [
    ("TC01", "Functional", "Import Recipe", "Import Recipe to Recipe_data",
     "SemiInspectionDesktop.exe running; Recipe_data writable",
     "1. Click Toolbar0 Import Recipe (Ctrl+I)\n2. Select InspectionRecipe_Sample.json\n3. Verify RawData table",
     "JSON copied to Recipe_data; DataGrid shows parameters; log contains Import Recipe", "High", 2001, "Ready"),
    ("TC02", "Functional", "File Tree", "File Tree shows Recipe_data",
     "Application has started",
     "1. View left File Tree\n2. Confirm root node Recipe_data",
     "Window title Semi Inspection Desktop; tree visible; Sample JSON exists", "High", 2002, "Ready"),
    ("TC03", "Functional", "RawData", "RawData parameter table",
     "Recipe_data contains InspectionRecipe_Sample.json",
     "1. Click Toolbar1 RawData (Ctrl+E)\n2. Confirm DataGrid",
     "Shows Category/Parameter/Value/Unit; log contains RawData", "High", 2003, "Ready"),
    ("TC04", "Functional", "Defect Chart", "Defect Chart curve",
     "Recipe with DefectSummary loaded",
     "1. Click Toolbar1 Defect Chart (Ctrl+D)\n2. View chart area",
     "Log contains Defect Chart plotted 5 types; X=DefectType Y=DefectCount", "High", 2004, "Ready"),
    ("TC05", "Functional", "File Tree Open", "Double-click Recipe in file tree",
     "Recipe_data has InspectionRecipe_Sample.json",
     "1. Double-click .json in File Tree\n2. View RawData",
     "DataGrid shows Recipe parameters; log contains Recipe", "Medium", 2005, "Ready"),
    ("TC06", "Functional", "About", "About dialog",
     "Application has started",
     "1. Click Toolbar0 About",
     "Shows About (Recipe_data path and Inspection feature description)", "Low", 2006, "Ready"),
    ("TC07", "Negative", "Invalid Import", "Import non-JSON file",
     "Application has started; _invalid_sample.txt exists",
     "1. Click Import Recipe\n2. Select _invalid_sample.txt",
     "Warning Please select .json Recipe file; does not write TC01_import_copy.json", "High", 2007, "Ready"),
    ("TC08", "Negative", "Chart No Data", "Chart without Recipe",
     "Relaunched without loaded Recipe",
     "1. Click Defect Chart directly\n2. Close prompt if shown",
     "Prompt for missing DefectSummary or auto-load warning; no crash", "Medium", 2008, "Ready"),
    ("TC09", "Negative", "Missing File", "Open non-existent Recipe",
     "Application has started",
     "1. Ctrl+E open RawData file dialog\n2. Select not_exist_99999.json",
     "Shows error message; main window still operable", "Medium", 2009, "Ready"),
    ("TC10", "Functional", "Run Inspection", "Run Inspection simulation",
     "InspectionRecipe_Sample.json loaded",
     "1. Click Toolbar0 Run Inspection (Ctrl+R)\n2. View log",
     "Log contains Run Inspection, Recipe name, ToolID, DefectSummary total", "High", 2010, "Ready"),
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
