# FlaUI Inspector 安装与使用说明

## 📋 简介

FlaUI Inspector 是用于检查和分析 Windows 应用程序 UI 自动化元素的工具，类似于 Windows SDK 中的 Inspect.exe。

**⚠️ 重要：FlaUI Inspector 只能在 Windows 环境中运行**

## 🚀 安装方法

### 方法 1: Windows 环境（推荐）

在 Windows PowerShell 中执行：

```powershell
cd Automation_testcase\Project_FlaUIBDD\Testcase_Inspection_App_FlaUI_BDD\tools
.\install-flauinspect.ps1
```

### 方法 2: Linux/WSL 环境（仅下载）

在 Linux 或 WSL 终端中执行：

```bash
cd Automation_testcase/Project_FlaUIBDD/Testcase_Inspection_App_FlaUI_BDD/tools
chmod +x install-flauinspect.sh
./install-flauinspect.sh
```

**注意**：虽然可以在 Linux 中下载，但工具仍需在 Windows 环境中运行。

### 方法 3: 手动下载

1. 访问：https://github.com/FlaUI/FlaUInspect/releases/download/v3.0.0/FlaUInspect.3.0.0.zip
2. 下载并解压到：`tools/FlaUIInspector/`
3. 将 `FlaUInspect.exe` 复制为 `FlaUIInspector.exe`

## 📂 安装位置

安装后的文件结构：

```
tools/
├── FlaUIInspector/
│   ├── FlaUIInspector.exe  (主程序 - 别名)
│   ├── FlaUInspect.exe     (主程序 - 原始)
│   ├── FlaUI.Core.dll
│   ├── FlaUI.UIA2.dll
│   ├── FlaUI.UIA3.dll
│   └── ... (其他依赖文件)
├── install-flauinspect.ps1 (PowerShell 安装脚本)
├── install-flauinspect.sh  (Bash 安装脚本)
└── README.md               (本文档)
```

## 🎯 使用方法

### 启动 Inspector

在 Windows 环境中，运行项目根目录下的批处理文件：

```batch
開啟Inspector.bat
```

这个脚本会：
1. 自动搜索 FlaUI Inspector 的安装位置
2. 检查并启动 SemiInspectionDesktop.exe（如果未运行）
3. 启动 FlaUI Inspector 工具

### 手动启动

直接运行：
```
tools\FlaUIInspector\FlaUIInspector.exe
```

## 🔍 Inspector 搜索路径

`開啟Inspector.bat` 会按以下顺序搜索 FlaUI Inspector：

1. 环境变量 `FLAUI_INSPECTOR_PATH` 指定的路径
2. `tools\FlaUIInspector\FlaUIInspector.exe`（本目录）
3. `FlaUIInspector\FlaUIInspector.exe`（上级目录）
4. `%USERPROFILE%\FlaUIInspector\FlaUIInspector.exe`
5. `%USERPROFILE%\Downloads\FlaUIInspector\FlaUIInspector.exe`
6. `%LOCALAPPDATA%\FlaUIInspector\FlaUIInspector.exe`
7. `%LOCALAPPDATA%\Programs\FlaUIInspector\FlaUIInspector.exe`
8. `C:\Tools\FlaUIInspector\FlaUIInspector.exe`

## 🛠️ 自定义安装位置

如果你将 FlaUI Inspector 安装到其他位置，可以设置环境变量：

```batch
set FLAUI_INSPECTOR_PATH=C:\YourPath\FlaUIInspector.exe
```

或在系统环境变量中永久设置。

## ❗ 常见问题

### Q: 为什么在 Linux/WSL 中无法运行？

**A**: FlaUI Inspector 和 SemiInspectionDesktop 都是 .NET Windows Forms 应用程序，依赖 Windows API 和 UI Automation，无法在 Linux 中运行。

### Q: 如何在开发容器中使用？

**A**: 有几种方式：

1. **推荐**：在 Windows 本地环境中运行应用和 Inspector
2. 在 Linux 开发容器中编写和维护测试代码
3. 使用 Git 在两个环境间同步代码

### Q: 提示 "FlaUIInspector.exe not found"？

**A**: 请运行对应环境的安装脚本：
- Windows: `install-flauinspect.ps1`
- Linux: `install-flauinspect.sh`（仅下载，需在 Windows 运行）

### Q: 如何验证安装成功？

**A**: 在 Windows 环境中检查文件：

```batch
dir tools\FlaUIInspector\*.exe
```

应该看到 `FlaUIInspector.exe` 和 `FlaUInspect.exe` 两个文件。

## 📚 相关资源

- **FlaUI 项目主页**: https://github.com/FlaUI/FlaUI
- **FlaUI Inspector 仓库**: https://github.com/FlaUI/FlaUInspect
- **官方文档**: https://github.com/FlaUI/FlaUI/wiki

## 🔄 版本信息

- **当前版本**: FlaUInspect v3.0.0
- **下载日期**: 2026-08-04
- **发布页面**: https://github.com/FlaUI/FlaUInspect/releases/tag/v3.0.0

## 📝 更新

如需更新到新版本：

1. 访问 [Releases 页面](https://github.com/FlaUI/FlaUInspect/releases)
2. 下载最新版本的 zip 文件
3. 解压覆盖到 `tools/FlaUIInspector/` 目录
4. 确保存在 `FlaUIInspector.exe` 别名文件
