#!/bin/bash
# FlaUI Inspector 安装脚本 (下载用)
# 注意: FlaUI Inspector 只能在 Windows 上运行

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="$SCRIPT_DIR/FlaUIInspector"
ZIP_FILE="/tmp/FlaUInspect.3.0.0.zip"
URL="https://github.com/FlaUI/FlaUInspect/releases/download/v3.0.0/FlaUInspect.3.0.0.zip"

echo "Downloading FlaUI Inspector..."
mkdir -p "$DEST_DIR"

curl -L "$URL" -o "$ZIP_FILE"

echo "Extracting files..."
unzip -o "$ZIP_FILE" -d "$DEST_DIR"

# 创建别名 (Windows 需要)
if [ -f "$DEST_DIR/FlaUInspect.exe" ]; then
    cp "$DEST_DIR/FlaUInspect.exe" "$DEST_DIR/FlaUIInspector.exe"
fi

echo ""
echo "✓ Download completed!"
echo "Location: $DEST_DIR"
echo ""
echo "⚠️  NOTE: FlaUI Inspector is a Windows-only tool."
echo "   To run it, you need a Windows environment."
echo ""

ls -lh "$DEST_DIR"/*.exe 2>/dev/null || true
