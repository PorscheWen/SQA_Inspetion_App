# Port Forwarding 設定指南 (Codespaces)

## 問題診斷
當您在 GitHub Codespaces 中無法訪問 `http://localhost:6688` 時，通常是因為：
1. Port 未被正確轉發
2. Port 的 Visibility 設定為 Private（預設）

## 解決方案

### 方法一：使用 VS Code PORTS 面板（推薦）

1. **開啟 PORTS 面板**
   - 按 `Ctrl + `` ` 開啟終端機面板
   - 點擊面板上方的 **"PORTS"** 標籤
   - 或使用快捷鍵：`Ctrl + Shift + P` → 輸入 "View: Toggle Ports" → Enter

2. **找到 Port 6688**
   - 在 PORTS 列表中尋找 `6688`
   - 如果沒有，請先執行 `./開啟操作手冊.sh` 啟動服務

3. **設定為 Public**
   - 在 Port 6688 的列上按右鍵
   - 選擇 **"Port Visibility"** → **"Public"**
   - 或者點擊 Visibility 欄位，直接切換為 Public

4. **複製轉發的 URL**
   - 在 "Forwarded Address" 欄位會顯示公開 URL
   - 通常格式為：`https://xxx-6688.app.github.dev`
   - 右鍵點擊該 URL → **"Open in Browser"**

5. **訪問操作手冊**
   - 在開啟的瀏覽器中，URL 後面加上 `/docs/index.html`
   - 完整 URL：`https://xxx-6688.app.github.dev/docs/index.html`

### 方法二：使用檢查腳本

```bash
# 執行檢查腳本查看狀態和公開 URL
./check_port_forwarding.sh
```

### 方法三：使用命令列工具

```bash
# 使用 gh CLI 設定 port forwarding
gh codespace ports visibility 6688:public -c $CODESPACE_NAME
```

## 常見問題

### Q1: Port 列表中沒有 6688？
**A:** 確認服務已啟動：
```bash
./開啟操作手冊.sh
```

### Q2: 設定為 Public 後仍無法訪問？
**A:** 
1. 檢查服務是否正常運行：
   ```bash
   curl http://localhost:6688/api/health
   ```
2. 重新啟動服務：
   ```bash
   # 按 Ctrl+C 停止現有服務
   ./開啟操作手冊.sh
   ```

### Q3: 如何永久保持 Public 設定？
**A:** 在專案根目錄創建 `.devcontainer/devcontainer.json`：
```json
{
  "forwardPorts": [6688],
  "portsAttributes": {
    "6688": {
      "label": "操作手冊伺服器",
      "onAutoForward": "notify",
      "visibility": "public"
    }
  }
}
```

## 快速檢查清單

- [ ] 服務已啟動（執行 `./開啟操作手冊.sh`）
- [ ] Port 6688 顯示在 PORTS 面板
- [ ] Visibility 設定為 **Public**
- [ ] 可以在本地訪問 `http://localhost:6688/api/health`
- [ ] 取得公開 URL（格式：`https://xxx-6688.app.github.dev`）
- [ ] 瀏覽器開啟 `<公開URL>/docs/index.html`

## 自動化設定

如果需要在每次啟動 Codespace 時自動設定，請執行：

```bash
# 創建 devcontainer 設定
mkdir -p .devcontainer
cat > .devcontainer/devcontainer.json << 'EOF'
{
  "name": "SQA Inspection App",
  "forwardPorts": [6688, 5000],
  "portsAttributes": {
    "6688": {
      "label": "操作手冊伺服器",
      "onAutoForward": "notify",
      "visibility": "public"
    },
    "5000": {
      "label": "測試控制台",
      "onAutoForward": "silent",
      "visibility": "public"
    }
  }
}
EOF

# 提交變更
git add .devcontainer/
git commit -m "Add devcontainer port forwarding configuration"
```

重新啟動 Codespace 後，Port 6688 會自動設定為 Public。

## 需要協助？

如果仍然無法解決問題，請提供以下資訊：
1. `./check_port_forwarding.sh` 的輸出結果
2. PORTS 面板的截圖
3. 瀏覽器控制台的錯誤訊息（F12 → Console）
