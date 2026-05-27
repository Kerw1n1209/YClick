# YClick

在 macOS Finder 右键菜单中快速新建任意类型的空文件。

YClick 是一个 macOS 原生应用，通过 Finder Sync Extension 在访达的右键菜单中注入「新建文件」子菜单，让你可以一键在当前目录创建 `.md`、`.json`、`.swift`、`.py` 等任意类型的空白文件 —— 同时支持自定义扩展名、图标和分类。

## 功能特性

- 🖱 **右键菜单集成** —— 在 Finder 任意目录（包括空白处和已选中的文件夹）右键即可新建文件
- 📂 **全盘可用** —— 通过沙盒例外授权监听 `/`，在任何路径下都能使用
- 🎨 **自定义文件类型** —— 在主应用中添加、编辑、启用/停用任意扩展名，并指定 SF Symbol 图标和分类
- 📦 **内置常用类型** —— 预置 Text、Markdown、JSON、HTML、CSS、JavaScript、Python、Swift、Property List 等 9 种常用类型
- 🔄 **配置实时同步** —— 主应用与扩展通过 App Group 共享配置，修改即时生效
- 🪶 **极简体验** —— 创建文件时自动避免重名（`Untitled.md` → `Untitled 2.md`）

## 系统要求

- macOS 13.0 (Ventura) 及以上
- Xcode 15+（仅开发时需要）

## 安装与运行

### 方式一：使用脚本（推荐）

仓库自带 [script/build_and_run.sh](script/build_and_run.sh)，会自动完成编译、安装到 `~/Applications/`、注册扩展并重启 Finder：

```bash
./script/build_and_run.sh
```

支持的模式：

| 命令 | 说明 |
| --- | --- |
| `./script/build_and_run.sh` 或 `run` | 编译并启动应用 |
| `./script/build_and_run.sh --logs` | 启动并实时跟踪应用日志 |
| `./script/build_and_run.sh --telemetry` | 跟踪主应用 + Finder 扩展的日志 |
| `./script/build_and_run.sh --debug` | 使用 lldb 调试启动 |
| `./script/build_and_run.sh --verify` | 启动并验证进程存活 |

### 方式二：Xcode 打开

直接打开 [YClick.xcodeproj](YClick.xcodeproj)，选择 `YClick` scheme 后 `Cmd + R` 运行。

## 启用 Finder 扩展

首次运行后，需要在系统设置中启用扩展：

1. 打开 **系统设置 → 隐私与安全性 → 扩展 → 访达扩展**（或 **登录项与扩展**）
2. 勾选 **YClickFinderExtension**
3. 在 Finder 任意目录右键 → 应该能看到 **YClick → New File** 子菜单

> 如果菜单未出现，可以执行 `killall Finder` 重启访达；脚本会自动做这一步。

## 使用方法

### 创建文件

在 Finder 中右键任意位置（空白处或选中文件夹），选择 **YClick → New File → [文件类型]**，会在目标目录立即创建一个 `Untitled.<扩展名>` 的空文件。

### 管理文件类型

打开主应用 **YClick.app**：

- **左侧列表** 按分类显示所有已注册的文件类型
- **工具栏 `+`** 添加自定义类型（指定名称、扩展名、SF Symbol、分类）
- **右键菜单** 启用/停用、编辑、删除（仅自定义类型可删除）
- **「Restore Presets」** 恢复内置的预设类型

只有勾选了「Show in Finder menu」的类型才会出现在右键菜单中。

## 项目结构

```
YClick/
├── YClick/                          # 主应用 (SwiftUI)
│   ├── App/YClickApp.swift          # 应用入口
│   ├── Shared/                      # 主应用与扩展共享的模型
│   │   ├── FileType.swift           # 文件类型模型 + 内置预设
│   │   ├── FileTypeStore.swift      # 持久化存储（App Group UserDefaults）
│   │   ├── FileCreationService.swift# 文件创建逻辑
│   │   └── AppConstants.swift       # App Group ID 等常量
│   └── Views/                       # SwiftUI 界面
├── YClickFinderExtension/           # Finder Sync 扩展
│   ├── FinderSync.swift             # 扩展主类（菜单注入 + 文件创建）
│   ├── Info.plist
│   └── YClickFinderExtension.entitlements
├── Tests/YClickTests/               # 单元测试
├── script/build_and_run.sh          # 一键编译运行脚本
└── YClick.xcodeproj
```

## 技术细节

- **架构** —— 主应用与扩展共享 `Shared/` 目录下的模型层；通过 App Group `group.com.yclick.app` 共享 `UserDefaults` 存储配置
- **菜单注入** —— 继承 `FIFinderSync`，在 `menu(for:)` 中按当前启用的类型动态构建子菜单
- **目标目录解析** —— 优先使用选中的文件夹 → 选中文件的父目录 → Finder 当前显示的目录
- **沙盒授权** —— 扩展通过 `com.apple.security.temporary-exception.files.home-relative-path.read-write = "/"` 获得全盘读写权限
- **重名处理** —— `FileCreationService.uniqueURL` 在文件已存在时自动追加序号

## 测试

```bash
xcodebuild test \
  -project YClick.xcodeproj \
  -scheme YClick \
  -destination 'platform=macOS'
```

测试覆盖 `FileTypeStore` 的增删改查与 `FileCreationService` 的重名规避逻辑，参见 [Tests/YClickTests/](Tests/YClickTests/)。

## License

MIT
