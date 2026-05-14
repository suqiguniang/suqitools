# 苏小盒 (SuXiaoBox)

一个便捷的导航工具 App，支持网页快捷方式和 WOL 远程开机功能。

## 功能特性

- **网页导航**: 添加常用网页快捷方式，快速访问
- **WOL 远程开机**: 通过局域网 UDP 广播发送唤醒信号
- **桌面小组件**: 支持 Android 桌面小组件，快速访问
- **卡片管理**: 自由添加、删除、管理导航卡片

## 技术栈

- React Native (跨平台)
- TypeScript
- Android App Widget

## GitHub 地址

<url id="" type="url" status="" title="" wc="">https://github.com/suqiguniang/suqitools</url>

## 软件图标

<url id="" type="url" status="" title="" wc="">https://suqiguniang.github.io/img/111238110.png</url>

## 开发

```bash
# 安装依赖
npm install

# 运行 Android
npx react-native run-android

# 构建发布版本
cd android
./gradlew assembleRelease
```

## CI/CD

本项目使用 GitHub Actions 自动构建 Android APK。每次推送到 main 分支或发起 Pull Request 时都会触发构建。

构建的 APK 可以在 Actions 页面下载。