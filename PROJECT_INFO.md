# 苏小盒 (SuXiaoBox)

一个便捷的导航工具 App，支持网页快捷方式和 WOL 远程开机功能。

## 项目结构

```
SuXiaoBox/
├── src/
│   ├── components/       # React 组件
│   │   ├── CardItem.tsx     # 卡片组件
│   │   └── AddCardModal.tsx # 添加卡片弹窗
│   ├── screens/          # 页面组件
│   │   ├── HomeScreen.tsx    # 首页（卡片列表）
│   │   ├── WebViewScreen.tsx # 网页浏览页
│   │   └── SettingsScreen.tsx # 设置页
│   ├── types.ts          # TypeScript 类型定义
│   ├── storage.ts        # 本地存储工具
│   └── wol.ts            # WOL 唤醒功能
├── android/              # Android 原生代码
│   └── app/src/main/
│       ├── java/com/suxiaobox/widget/  # 桌面小组件
│       └── res/                      # Android 资源文件
├── .github/workflows/    # GitHub Actions CI/CD
├── App.tsx               # 主应用组件
├── package.json
└── README.md
```

## 已实现功能

### 1. 导航卡片页面
- 支持添加网页卡片和 WOL 卡片
- 长按删除卡片
- 卡片数据本地持久化存储（AsyncStorage）
- 支持下拉刷新

### 2. WOL 远程开机
- 通过局域网 UDP 广播发送唤醒信号（Magic Packet）
- 支持自定义 MAC 地址、IP 地址和端口
- 使用 react-native-udp 实现 UDP 通信

### 3. 桌面小组件（Android App Widget）
- 支持添加到 Android 桌面
- 快速打开应用、网页和 WOL 功能
- 包含 WidgetProvider、布局文件和配置文件

### 4. 设置页面
- 显示应用信息和版本号
- GitHub 仓库链接：[https://github.com/suqiguniang/suqitools](https://github.com/suqiguniang/suqitools)
- 应用图标：[https://suqiguniang.github.io/img/111238110.png](https://suqiguniang.github.io/img/111238110.png)
- 功能介绍说明

### 5. GitHub Actions CI/CD
- 自动构建 Android APK
- 支持 push 到 main/master 分支自动触发
- 支持 Pull Request 触发
- 支持手动触发（workflow_dispatch）
- 构建产物自动上传为 Artifacts

### 6. 测试签名密钥
- 已生成测试用签名密钥（android/app/my-release-key.keystore）
- 密钥别名：my-key-alias
- 密码：android

## 技术栈

- **React Native** 0.85.3（跨平台框架）
- **TypeScript**（类型安全）
- **React Navigation**（底部标签导航 + 堆栈导航）
- **AsyncStorage**（本地数据持久化）
- **react-native-udp**（UDP 广播实现 WOL）
- **react-native-webview**（网页浏览）
- **react-native-vector-icons**（Material Design 图标）

## 开发环境要求

- Node.js >= 22.11.0
- Java JDK 17（用于 Android 构建）
- Android Studio（Android SDK 和模拟器）
- React Native CLI

## 安装和运行

```bash
# 安装依赖
npm install

# 启动 Metro 服务
npx react-native start

# 运行 Android 调试版本
npx react-native run-android

# 构建 Android 发布版本
cd android
./gradlew assembleRelease
```

## CI/CD 说明

本项目使用 GitHub Actions 自动构建 Android APK。

### 触发方式
1. 推送代码到 `main` 或 `master` 分支
2. 向 `main` 或 `master` 分支发起 Pull Request
3. 在 Actions 页面手动触发

### 构建流程
1. 检出代码
2. 设置 Node.js 环境
3. 设置 Java 环境（JDK 17）
4. 安装 npm 依赖
5. 构建 Android Release APK
6. 上传构建产物到 Artifacts（保留 30 天）

### 下载 APK
构建完成后，可以在 GitHub Actions 页面的 Artifacts 部分下载 `app-release.apk`。

## 项目配置

### Android 配置
- **应用 ID**: `com.suxiaobox`
- **版本号**: 1
- **版本名称**: 1.0
- **最低 SDK**: 根据 React Native 默认配置
- **目标 SDK**: 根据 React Native 默认配置

### 签名配置
发布构建使用测试签名密钥：
- 密钥库文件：`android/app/my-release-key.keystore`
- 密钥别名：`my-key-alias`
- 密钥库密码：`android`
- 密钥密码：`android`

**注意**：在生产环境中，请使用您自己的发布密钥替换测试密钥。

## 注意事项

1. **Java 环境**：当前构建环境需要配置 JAVA_HOME 环境变量指向 JDK 安装目录
2. **Android SDK**：需要安装 Android SDK 并配置 ANDROID_HOME 环境变量
3. **WOL 功能**：需要在同一局域网内使用，目标设备需要启用 Wake-on-LAN 功能
4. **桌面小组件**：需要在 AndroidManifest.xml 中注册 WidgetProvider

## 许可证

© 2024 苏小盒. All rights reserved.