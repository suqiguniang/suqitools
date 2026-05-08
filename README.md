# Navigation Panel

一个基于 Flutter 的 Android 导航面板应用。

## 功能

- **导航面板主页**: 以卡片网格形式展示可访问的服务
- **SunPanel 服务**: 点击卡片即可在应用内 WebView 中访问 `sunpanel.suqi.qzz.io:8443`
- **设置页面**: 显示项目的 GitHub 仓库地址（待确定）

## 项目结构

```
lib/
├── main.dart              # 应用入口
├── models/
│   └── panel_item_model.dart  # 面板项数据模型
├── screens/
│   ├── home_screen.dart   # 导航面板主页
│   ├── webview_screen.dart # WebView 页面
│   └── settings_screen.dart # 设置页面
└── widgets/
    └── panel_card.dart    # 服务卡片组件
```

## 构建

### 本地构建

确保已安装 Flutter SDK，然后运行：

```bash
flutter pub get
flutter build apk --release
```

### GitHub Actions

项目已配置 GitHub Actions 工作流 (`.github/workflows/build.yml`)：

- 每次推送到 `main`/`master` 分支时自动构建 APK
- 推送标签 `v*` 时自动构建并上传到 Release
- 构建产物可在 Actions 页面下载

## 配置

### 修改 GitHub 地址

编辑 `lib/screens/settings_screen.dart` 中的 `_githubPlaceholder` 常量：

```dart
static const String _githubPlaceholder = 'https://github.com/yourusername/navigation-panel';
```

### 添加更多服务

在 `lib/screens/home_screen.dart` 的 `_items` 列表中添加新的 `PanelItemModel`：

```dart
PanelItemModel(
  id: 'new_service',
  title: '新服务',
  description: '描述文本',
  iconAsset: 'assets/icons/new_service.svg',
  url: 'https://example.com',
),
```

## 技术栈

- Flutter 3.24+
- webview_flutter (内嵌网页)
- url_launcher (外部链接)
