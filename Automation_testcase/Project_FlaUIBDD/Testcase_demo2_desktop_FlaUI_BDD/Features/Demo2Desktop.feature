Feature: Semi Inspection Desktop 測試
  作為測試人員
  我想要驗證 Semi Inspection Desktop 的 Recipe、RawData 與圖表功能
  以確保 Recipe_data 工作流程正常

@Functional @Import
Scenario: TC01 - Import Recipe 至 Recipe_data
  Given 測試資料已就緒
  And 應用程式已重新啟動
  When 我點擊工具列「Import Recipe」
  And 我在檔案對話框選擇樣本 InspectionRecipe_Sample.json
  Then Recipe_data 應存在 InspectionRecipe_Sample.json
  And 資料表應可見
  And 日誌區應包含「Import Recipe」

@Functional @FileTree
Scenario: TC02 - File Tree 顯示 Recipe_data
  Given 測試資料已就緒
  And 應用程式已啟動
  Then 主視窗標題應為「Semi Inspection Desktop」
  And 檔案樹應可見
  And Recipe_data 應存在 InspectionRecipe_Sample.json

@Functional @RawData
Scenario: TC03 - RawData 參數表
  Given 測試資料已就緒
  And 應用程式已啟動
  When 我點擊工具列「RawData」
  Then 資料表應可見
  And 日誌區應包含「RawData」

@Functional @Chart
Scenario: TC04 - Defect Chart 曲線圖
  Given 測試資料已就緒
  And 應用程式已啟動
  When 我點擊工具列「RawData」
  And 我點擊工具列「Defect Chart」
  Then 日誌區應包含「Defect Chart」

@Functional @FileTree
Scenario: TC05 - 檔案樹雙擊開啟 Recipe
  Given 測試資料已就緒
  And 應用程式已啟動
  When 我在檔案樹雙擊 InspectionRecipe_Sample.json
  Then 資料表應可見
  And 日誌區應包含「Recipe」

@Functional @About
Scenario: TC06 - About 對話框
  Given 應用程式已啟動
  When 我點擊工具列「About」
  And 我關閉訊息對話框

@Negative
Scenario: TC07 - 匯入非 JSON 檔
  Given 測試資料已就緒
  And 應用程式已啟動
  When 我點擊工具列「Import Recipe」
  And 我在檔案對話框選擇無效檔 _invalid_sample.txt
  Then 不應將無效檔複製為 TC01_import_copy.json
  And 我關閉訊息對話框

@Negative @Chart
Scenario: TC08 - 無 Recipe 時繪圖
  Given 應用程式已重新啟動
  When 我點擊工具列「Defect Chart」
  Then 主視窗仍應存在

@Negative
Scenario: TC09 - 開啟不存在 Recipe
  Given 應用程式已啟動
  When 我使用快捷鍵開啟 RawData 並選擇不存在檔 not_exist_99999.json
  Then 主視窗仍應存在

@Functional @Inspection
Scenario: TC10 - Run Inspection 模擬檢測
  Given 測試資料已就緒
  And 應用程式已啟動
  When 我點擊工具列「RawData」
  And 我點擊工具列「Run Inspection」
  Then 日誌區應包含「Run Inspection」
