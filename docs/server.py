#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""操作手冊本機伺服器：提供 docs 靜態頁面與一鍵執行 .bat API（port 6688）。"""

from __future__ import annotations

import json
import os
import subprocess
import sys
from http import HTTPStatus
from http.server import SimpleHTTPRequestHandler
from pathlib import Path
from socketserver import ThreadingMixIn, TCPServer
from urllib.parse import unquote, urlparse

PORT = int(os.environ.get("MANUAL_SERVER_PORT", "6688"))
DOCS_DIR = Path(__file__).resolve().parent
APP_ROOT = DOCS_DIR.parent

ALLOWED_BATS: dict[str, str] = {
    "啟動InspectionApp.bat": "啟動 Inspection App",
    "run_semi.bat": "啟動被測 App",
    "run_tests.bat": "執行全部測試",
    "執行單一測試.bat": "執行單一測試",
    "開啟測試報告.bat": "開啟測試報告",
    "啟動測試平台.bat": "啟動測試平台",
    "build_semi.bat": "建置被測 App",
    "開啟操作手冊.bat": "重新開啟操作手冊",
}

DEFAULT_EXE = APP_ROOT / "SemiInspectionDesktop" / "bin" / "Debug" / "SemiInspectionDesktop.exe"


def launch_in_new_console(command: list[str], cwd: Path) -> None:
    subprocess.Popen(
        command,
        cwd=str(cwd),
        creationflags=subprocess.CREATE_NEW_CONSOLE,
    )


class ManualHandler(SimpleHTTPRequestHandler):
    extensions_map = {
        **getattr(SimpleHTTPRequestHandler, "extensions_map", {}),
        ".md": "text/plain; charset=utf-8",
        ".feature": "text/plain; charset=utf-8",
    }

    def log_message(self, format: str, *args) -> None:
        if args and str(args[0]).startswith("GET /api/"):
            return
        super().log_message(format, *args)

    def translate_path(self, path: str) -> str:
        parsed = urlparse(path)
        rel = unquote(parsed.path)

        if rel in ("", "/"):
            return str(DOCS_DIR / "index.html")

        if rel.startswith("/docs/"):
            target = DOCS_DIR / rel[len("/docs/") :]
        else:
            target = APP_ROOT / rel.lstrip("/")

        try:
            target.resolve().relative_to(APP_ROOT.resolve())
        except ValueError:
            return str(DOCS_DIR / "index.html")

        return str(target)

    def _send_json(self, payload: dict, code: int = HTTPStatus.OK) -> None:
        body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(body)

    def _read_json_body(self) -> dict:
        length = int(self.headers.get("Content-Length", 0))
        if length <= 0:
            return {}
        raw = self.rfile.read(length)
        return json.loads(raw.decode("utf-8"))

    def do_OPTIONS(self) -> None:
        self.send_response(HTTPStatus.NO_CONTENT)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def do_GET(self) -> None:
        parsed = urlparse(self.path)
        if parsed.path == "/api/health":
            self._send_json(
                {
                    "ok": True,
                    "port": PORT,
                    "appRoot": str(APP_ROOT),
                    "docsUrl": f"http://localhost:{PORT}/docs/index.html",
                }
            )
            return

        if parsed.path in ("/", "/index.html"):
            self.path = "/docs/index.html"

        return super().do_GET()

    def do_POST(self) -> None:
        parsed = urlparse(self.path)

        if parsed.path == "/api/launch-bat":
            try:
                body = self._read_json_body()
            except json.JSONDecodeError:
                self._send_json({"error": "無效的 JSON"}, HTTPStatus.BAD_REQUEST)
                return

            bat_name = (body.get("bat") or "").strip()
            if bat_name not in ALLOWED_BATS:
                self._send_json({"error": f"不允許執行的批次檔: {bat_name}"}, HTTPStatus.BAD_REQUEST)
                return

            bat_path = APP_ROOT / bat_name
            if not bat_path.is_file():
                self._send_json({"error": f"找不到批次檔: {bat_path}"}, HTTPStatus.NOT_FOUND)
                return

            args = body.get("args") or []
            if isinstance(args, str):
                args = [args] if args.strip() else []

            cmd = ["cmd", "/c", str(bat_path), *args]
            try:
                launch_in_new_console(cmd, APP_ROOT)
            except OSError as exc:
                self._send_json({"error": f"無法啟動: {exc}"}, HTTPStatus.INTERNAL_SERVER_ERROR)
                return

            label = ALLOWED_BATS[bat_name]
            arg_text = " ".join(args)
            message = f"已啟動 {label}" + (f" ({arg_text})" if arg_text else "")
            self._send_json({"ok": True, "message": message, "bat": bat_name, "args": args})
            return

        if parsed.path == "/api/launch-exe":
            try:
                body = self._read_json_body()
            except json.JSONDecodeError:
                self._send_json({"error": "無效的 JSON"}, HTTPStatus.BAD_REQUEST)
                return

            rel = (body.get("exe") or "SemiInspectionDesktop/bin/Debug/SemiInspectionDesktop.exe").strip()
            exe_path = (APP_ROOT / rel).resolve()
            try:
                exe_path.relative_to(APP_ROOT.resolve())
            except ValueError:
                self._send_json({"error": "路徑不合法"}, HTTPStatus.BAD_REQUEST)
                return

            if not exe_path.is_file():
                build_bat = APP_ROOT / "build_semi.bat"
                if build_bat.is_file():
                    proc = subprocess.run(
                        ["cmd", "/c", str(build_bat)],
                        cwd=str(APP_ROOT),
                        capture_output=True,
                        text=True,
                        encoding="utf-8",
                        errors="replace",
                    )
                    if proc.returncode != 0:
                        self._send_json(
                            {"error": "找不到 EXE，且 build_semi.bat 建置失敗"},
                            HTTPStatus.INTERNAL_SERVER_ERROR,
                        )
                        return

            if not exe_path.is_file():
                self._send_json({"error": f"找不到執行檔: {exe_path}"}, HTTPStatus.NOT_FOUND)
                return

            try:
                os.startfile(str(exe_path))  # type: ignore[attr-defined]
            except OSError as exc:
                self._send_json({"error": f"無法啟動 EXE: {exc}"}, HTTPStatus.INTERNAL_SERVER_ERROR)
                return

            self._send_json({"ok": True, "message": f"已啟動 {exe_path.name}", "exe": str(exe_path)})
            return

        self.send_error(HTTPStatus.NOT_FOUND)


class ThreadingHTTPServer(ThreadingMixIn, TCPServer):
    allow_reuse_address = True
    daemon_threads = True


def main() -> None:
    with ThreadingHTTPServer(("", PORT), ManualHandler) as httpd:
        url = f"http://localhost:{PORT}/docs/index.html"
        print("SQA Inspection App — 操作手冊伺服器")
        print(f"  {url}")
        print("  瀏覽器內可一鍵執行 .bat（新視窗）")
        print("按 Ctrl+C 停止。")
        httpd.serve_forever()


if __name__ == "__main__":
    main()
