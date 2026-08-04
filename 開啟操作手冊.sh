#!/bin/bash
# 啟動操作手冊伺服器

cd "$(dirname "$0")"

PORT=6688
URL="http://localhost:${PORT}/docs/index.html"

echo "========================================"
echo "  SQA Inspection App - 操作手冊"
echo "========================================"
echo ""

# 檢查服務器是否已在運行
if curl -s "http://127.0.0.1:${PORT}/api/health" >/dev/null 2>&1; then
    echo "操作手冊伺服器已在執行"
    echo "請在瀏覽器中開啟: ${URL}"
    exit 0
fi

# 啟動服務器
echo "啟動操作手冊伺服器 (port ${PORT}) ..."
echo "請在瀏覽器中開啟: ${URL}"
echo ""

cd docs
python3 server.py
