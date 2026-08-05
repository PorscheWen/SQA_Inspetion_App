#!/bin/bash
# 啟動操作手冊伺服器

set -e  # 遇到錯誤時退出

cd "$(dirname "$0")"

PORT=6688
URL="http://localhost:${PORT}/docs/index.html"

echo "========================================"
echo "  SQA Inspection App - 操作手冊"
echo "========================================"
echo ""

# ===== 環境檢查 =====
echo "[1/5] 檢查 Python 環境..."
if ! command -v python3 &> /dev/null; then
    echo "❌ 錯誤: 找不到 python3，請先安裝 Python 3"
    exit 1
fi
PYTHON_VERSION=$(python3 --version 2>&1)
echo "✅ Python 環境正常: $PYTHON_VERSION"
echo ""

echo "[2/5] 檢查必要檔案..."
if [ ! -f "docs/server.py" ]; then
    echo "❌ 錯誤: 找不到 docs/server.py"
    exit 1
fi
echo "✅ 必要檔案存在"
echo ""

echo "[3/5] 檢查 Port ${PORT} 是否被占用..."
if lsof -Pi :${PORT} -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    PID=$(lsof -Pi :${PORT} -sTCP:LISTEN -t)
    PROCESS=$(ps -p $PID -o comm= 2>/dev/null || echo "未知")
    echo "⚠️  Port ${PORT} 已被占用"
    echo "   PID: $PID"
    echo "   Process: $PROCESS"
    echo ""
    
    # 檢查是否是我們自己的服務器
    if curl -s "http://127.0.0.1:${PORT}/api/health" >/dev/null 2>&1; then
        echo "✅ 操作手冊伺服器已在執行"
        echo "   請在瀏覽器中開啟: ${URL}"
        echo ""
        
        # 在 Codespaces 中提示 port forwarding
        if [ -n "$CODESPACES" ]; then
            echo "💡 注意: 您在 GitHub Codespaces 環境中"
            echo "   請確認 Port ${PORT} 已被轉發 (forwarded)"
            echo "   可能需要在 PORTS 面板中手動設定為 Public"
        fi
        exit 0
    else
        echo "❌ Port 被其他程序占用，請先停止該程序"
        echo "   可使用以下命令停止: kill $PID"
        exit 1
    fi
fi
echo "✅ Port ${PORT} 可用"
echo ""

echo "[4/5] 檢查網路權限..."
# 測試是否能綁定 port (不實際綁定，只是檢查)
if python3 -c "import socket; s=socket.socket(); s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1); s.bind(('127.0.0.1', ${PORT})); s.close()" 2>/dev/null; then
    echo "✅ 具有綁定 Port ${PORT} 的權限"
else
    echo "⚠️  警告: 可能無法綁定 Port ${PORT}"
fi
echo ""

echo "[5/5] 環境檢查完成"
echo ""

# ===== 啟動服務器 =====
echo "正在啟動操作手冊伺服器 (port ${PORT}) ..."
echo ""

# 在 Codespaces 中提供額外提示
if [ -n "$CODESPACES" ]; then
    echo "💡 GitHub Codespaces 環境偵測"
    echo "   服務啟動後，VS Code 會自動提示 Port Forwarding"
    echo "   或手動在 PORTS 面板中將 Port ${PORT} 設為 Public"
    echo ""
fi

echo "伺服器 URL: ${URL}"
echo "按 Ctrl+C 停止伺服器"
echo "========================================"
echo ""

# 設定環境變數並啟動
export MANUAL_SERVER_PORT=${PORT}
export APP_ROOT="$(pwd)"

cd docs
exec python3 server.py
