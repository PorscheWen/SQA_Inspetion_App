#!/bin/bash
# 檢查 Port Forwarding 狀態

echo "=========================================="
echo " Port Forwarding 狀態檢查"
echo "=========================================="
echo ""

PORT=6688

# 檢查本地服務是否運行
echo "[1] 檢查本地服務 (localhost:${PORT})..."
if curl -s "http://127.0.0.1:${PORT}/api/health" >/dev/null 2>&1; then
    echo "✅ 本地服務正常運行"
else
    echo "❌ 本地服務未運行，請先執行 ./open_user_manual.sh"
    exit 1
fi
echo ""

# 在 Codespaces 中檢查公開 URL
if [ -n "$CODESPACES" ]; then
    echo "[2] Codespaces 環境偵測"
    echo "   Codespace Name: ${CODESPACE_NAME}"
    
    # 構建公開 URL
    PUBLIC_URL="https://${CODESPACE_NAME}-${PORT}.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
    
    echo ""
    echo "預期的公開 URL:"
    echo "   ${PUBLIC_URL}"
    echo ""
    
    echo "[3] 測試公開 URL 存取..."
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "${PUBLIC_URL}/api/health" 2>/dev/null || echo "000")
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo "✅ Port Forwarding 已正確設定且可公開存取"
        echo ""
        echo "🌐 請使用以下 URL 開啟操作手冊："
        echo "   ${PUBLIC_URL}/docs/index.html"
    elif [ "$HTTP_CODE" = "302" ]; then
        echo "⚠️  Port 已轉發但需要調整 Visibility 設定 (收到 302 重定向)"
        echo ""
        echo "📋 設定步驟："
        echo "   1. 按 Ctrl+\` 開啟終端機面板"
        echo "   2. 切換到 'PORTS' 標籤"
        echo "   3. 找到 Port ${PORT}"
        echo "   4. 右鍵點擊 → 'Port Visibility' → 選擇 'Public'"
        echo "   5. 複製 'Forwarded Address' 欄位的 URL"
        echo "   6. 在瀏覽器中開啟該 URL + /docs/index.html"
        echo ""
        echo "📖 詳細說明請參考: PORT_FORWARDING_GUIDE.md"
    elif [ "$HTTP_CODE" = "000" ]; then
        echo "❌ 無法連接到公開 URL（連線逾時）"
        echo ""
        echo "💡 請檢查 VS Code 的 PORTS 面板："
        echo "   1. 按 Ctrl+\` 開啟終端機面板"
        echo "   2. 切換到 'PORTS' 標籤"
        echo "   3. 找到 Port ${PORT}"
        echo "   4. 右鍵點擊 → 'Port Visibility' → 選擇 'Public'"
        echo ""
        echo "📖 詳細說明請參考: PORT_FORWARDING_GUIDE.md"
    else
        echo "⚠️  收到非預期的 HTTP 狀態碼: ${HTTP_CODE}"
        echo ""
        echo "💡 請檢查 VS Code 的 PORTS 面板，確認："
        echo "   • Port ${PORT} 已被轉發"
        echo "   • Visibility 設定為 'Public'"
        echo ""
        echo "📖 詳細說明請參考: PORT_FORWARDING_GUIDE.md"
    fi
else
    echo "[2] 本機環境"
    echo "   請直接開啟: http://localhost:${PORT}/docs/index.html"
fi

echo ""
echo "=========================================="
