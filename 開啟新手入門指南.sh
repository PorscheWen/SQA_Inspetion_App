#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# ===============================================
# 開啟新手入門指南 (Linux / macOS / Codespaces)
# ===============================================

set -e

# 顏色定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "========================================"
echo -e "${GREEN}🚀 開啟新手入門指南${NC}"
echo "========================================"
echo ""

# 1. 檢查 Python 環境
echo -e "${BLUE}[1/5] 檢查 Python 環境...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}[錯誤] 找不到 Python 3${NC}"
    echo "請先安裝 Python 3.x"
    exit 1
fi
PYTHON_VERSION=$(python3 --version 2>&1)
echo -e "${GREEN}✅ ${PYTHON_VERSION}${NC}"
echo ""

# 2. 檢查必要檔案
echo -e "${BLUE}[2/5] 檢查必要檔案...${NC}"
if [ ! -f "docs/server.py" ]; then
    echo -e "${RED}[錯誤] 找不到 docs/server.py${NC}"
    exit 1
fi
if [ ! -f "docs/新手入門指南.html" ]; then
    echo -e "${RED}[錯誤] 找不到 docs/新手入門指南.html${NC}"
    exit 1
fi
echo -e "${GREEN}✅ 必要檔案已存在${NC}"
echo ""

# 3. 檢查 Port 6688 是否被占用
echo -e "${BLUE}[3/5] 檢查 Port 6688...${NC}"
if lsof -Pi :6688 -sTCP:LISTEN -t >/dev/null 2>&1 || netstat -tln 2>/dev/null | grep -q ":6688 "; then
    echo -e "${YELLOW}⚠️  Port 6688 已在使用中（伺服器可能已啟動）${NC}"
    echo -e "${YELLOW}   如需重啟，請先終止現有進程：${NC}"
    echo -e "${YELLOW}   lsof -ti:6688 | xargs kill -9${NC}"
    echo ""
    PID=$(lsof -ti:6688 2>/dev/null || echo "")
    if [ -n "$PID" ]; then
        echo -e "${YELLOW}   現有進程 PID: $PID${NC}"
    fi
else
    echo -e "${GREEN}✅ Port 6688 可用${NC}"
fi
echo ""

# 4. 檢查網路權限
echo -e "${BLUE}[4/5] 檢查網路權限...${NC}"
if [ -n "${CODESPACE_NAME:-}" ]; then
    echo -e "${YELLOW}⚠️  偵測到 GitHub Codespaces 環境${NC}"
    echo -e "${YELLOW}   請確認 Port Forwarding 已設定為 Public${NC}"
    echo -e "${YELLOW}   詳見: PORT_FORWARDING_GUIDE.md${NC}"
fi
echo -e "${GREEN}✅ 環境檢查完成${NC}"
echo ""

# 5. 啟動伺服器
echo -e "${BLUE}[5/5] 啟動操作手冊伺服器...${NC}"
cd docs
echo -e "${GREEN}✅ 伺服器啟動中... (Port 6688)${NC}"
echo ""
echo "========================================"
echo -e "${GREEN}✅ 新手入門指南已啟動${NC}"
echo "========================================"
echo ""
echo -e "${YELLOW}💡 提示:${NC}"
echo "   • 本機網址: http://localhost:6688/docs/新手入門指南.html"

if [ -n "${CODESPACE_NAME:-}" ]; then
    FORWARDED_URL="https://${CODESPACE_NAME}-6688.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-app.github.dev}"
    echo "   • Codespaces 網址: ${FORWARDED_URL}/docs/新手入門指南.html"
    echo ""
    echo -e "${YELLOW}   🔧 如無法開啟，請執行: ./check_port_forwarding.sh${NC}"
fi

echo ""
echo "   • 按 Ctrl+C 停止伺服器"
echo ""

# 執行伺服器（會阻塞在這裡）
exec python3 server.py
