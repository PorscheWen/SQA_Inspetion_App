# 環境檢查功能說明

## 🎯 問題背景

在 GitHub Codespaces 或容器環境中，由於 Port Forwarding 設定問題，導致無法順利開啟 http://localhost:6688/docs/index.html。

## ✅ 已實施的改進

### 1. 啟動腳本增強（`開啟操作手冊.sh`）

增加了 **5 項環境檢查**：

```
[1/5] 檢查 Python 環境
   ✅ 確認 Python 3 是否安裝
   
[2/5] 檢查必要檔案
   ✅ 確認 docs/server.py 存在
   
[3/5] 檢查 Port 6688 是否被占用
   ✅ 檢測是否有其他程序占用
   ✅ 識別占用的 PID 和程序名稱
   
[4/5] 檢查網路權限
   ✅ 驗證是否有權限綁定 Port
   
[5/5] 環境檢查完成
   ✅ Codespaces 環境自動偵測
   ✅ 提供 Port Forwarding 設定提示
```

### 2. Port Forwarding 狀態檢查工具（`check_port_forwarding.sh`）

執行此腳本可以：
- ✅ 檢查本地服務是否運行
- ✅ 自動偵測 Codespaces 環境
- ✅ 構建並測試公開 URL
- ✅ 診斷 Port Forwarding 問題（200/302/000 狀態碼）
- ✅ 提供詳細的設定步驟指引

### 3. DevContainer 配置（`.devcontainer/devcontainer.json`）

自動化設定 Port Forwarding：
- Port 6688：操作手冊伺服器（自動設為 Public）
- Port 5000：測試控制台（自動設為 Public）
- 下次重啟 Codespace 時會自動套用

### 4. 完整設定指南（`PORT_FORWARDING_GUIDE.md`）

包含：
- 📋 三種 Port Forwarding 設定方法
- ❓ 常見問題與解答
- ✅ 快速檢查清單
- 🔧 自動化設定腳本

### 5. 更新新手入門指南（`新手入門指南.md`）

新增：
- Linux/Codespaces 環境使用說明
- Port Forwarding 問題診斷方法
- 三種解決方案的快速指引

## 🚀 使用方法

### 步驟 1：啟動服務（含環境檢查）

```bash
./開啟操作手冊.sh
```

### 步驟 2：診斷 Port Forwarding

```bash
./check_port_forwarding.sh
```

### 步驟 3：根據診斷結果處理

#### 情況 A：收到 ✅ 200 狀態碼
```
✅ Port Forwarding 已正確設定且可公開存取
🌐 請使用以下 URL 開啟操作手冊：
   https://xxx-6688.app.github.dev/docs/index.html
```
→ 直接開啟提示的 URL

#### 情況 B：收到 ⚠️ 302 狀態碼（最常見）
```
⚠️  Port 已轉發但需要調整 Visibility 設定
📋 設定步驟：
   1. 按 Ctrl+` 開啟終端機面板
   2. 切換到 'PORTS' 標籤
   3. 找到 Port 6688
   4. 右鍵點擊 → 'Port Visibility' → 選擇 'Public'
```
→ 按照步驟設定為 Public

#### 情況 C：收到 ❌ 000 狀態碼
```
❌ 無法連接到公開 URL（連線逾時）
```
→ 檢查服務是否正常運行，參考 PORT_FORWARDING_GUIDE.md

## 📂 相關文件

| 文件 | 用途 |
|------|------|
| `開啟操作手冊.sh` | 啟動服務（含環境檢查） |
| `開啟操作手冊.bat` | Windows 版本（含環境檢查） |
| `check_port_forwarding.sh` | Port Forwarding 狀態診斷 |
| `PORT_FORWARDING_GUIDE.md` | 完整設定指南 |
| `.devcontainer/devcontainer.json` | 自動化 Port Forwarding 配置 |
| `新手入門指南.md` | 已更新含 Codespaces 說明 |

## 🔍 常見狀況判斷流程

```
啟動服務
    │
    ├─→ 環境檢查失敗？
    │   ├─→ Python 未安裝 → 安裝 Python 3
    │   ├─→ Port 被占用 → 停止占用程序
    │   └─→ 權限不足 → 檢查防火牆設定
    │
    └─→ 環境檢查通過
        │
        └─→ 執行 check_port_forwarding.sh
            │
            ├─→ 200 ✅ → 直接使用提供的 URL
            ├─→ 302 ⚠️  → 設定 Port 為 Public
            └─→ 000 ❌ → 參考 PORT_FORWARDING_GUIDE.md
```

## 💡 最佳實踐

1. **首次使用**：執行 `./開啟操作手冊.sh`，觀察環境檢查結果
2. **遇到問題**：執行 `./check_port_forwarding.sh` 診斷
3. **自動化設定**：`.devcontainer/devcontainer.json` 已配置，重啟 Codespace 生效
4. **詳細說明**：參考 `PORT_FORWARDING_GUIDE.md` 的完整指南

## 🎓 技術細節

### 環境檢查機制

- **Python 版本檢查**：`python3 --version`
- **Port 占用檢查**：`lsof -Pi :6688 -sTCP:LISTEN`
- **健康檢查端點**：`/api/health`（由 docs/server.py 提供）
- **網路權限測試**：Socket binding 測試

### Codespaces 偵測

- **環境變數**：`$CODESPACES`
- **URL 構建**：`https://${CODESPACE_NAME}-${PORT}.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}`
- **HTTP 狀態碼意義**：
  - `200`：Public，可正常存取
  - `302`：Private，需要 GitHub 驗證（需改為 Public）
  - `000`：連線失敗或逾時

## 🔄 後續維護

- ✅ 所有環境檢查腳本已完成
- ✅ Windows (.bat) 和 Linux (.sh) 版本同步更新
- ✅ DevContainer 配置已加入版本控制
- ✅ 文檔已更新並交叉引用

---

**變更日期**：2026-08-04  
**影響範圍**：環境檢查、Port Forwarding 診斷、Codespaces 支援
