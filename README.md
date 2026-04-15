# Todo List & Clock - 待办清单与专注计时器

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-blue.svg)](https://dart.dev)
[![Version](https://img.shields.io/badge/version-0.2.0-green.svg)]()
[![License](https://img.shields.io/badge/license-MIT-yellow.svg)](LICENSE)

一款功能齐全的 Flutter 待办事项管理与专注计时器应用，帮助您高效管理任务并保持专注。

## ✨ 主要功能

### 📝 待办事项管理
- 创建、编辑和删除待办事项
- 任务分类与标签管理
- 任务优先级设置
- 完成状态追踪
- 数据持久化存储

### ⏱️ 专注计时器
- 番茄工作法支持
- 自定义计时时长
- 进度可视化展示
- 提醒通知功能

### 🎵 背景音乐
- 内置精选音乐库
- 专注时播放舒缓音乐
- 音乐播放控制

### 📊 统计分析
- 任务完成统计
- 专注时长记录
- 数据图表展示
- 历史趋势分析

### 🎨 精美界面
- Material Design 设计风格
- 动态颜色主题支持
- 中文字体优化
- 响应式布局

## 📦 技术栈

- **框架**: Flutter 3.9.2
- **语言**: Dart 3.9.2
- **状态管理**: Provider
- **本地存储**: 
  - SharedPreferences (轻量级数据存储)
  - SQLite (sqflite + sqflite_common_ffi)
- **图表**: fl_chart
- **音频**: audioplayers
- **主题**: dynamic_color

## 🏗️ 项目结构

```
lib/
├── main.dart              # 应用入口
├── enums/                 # 枚举定义
├── models/                # 数据模型
├── pages/                 # 页面组件
├── providers/             # 状态管理
├── utils/                 # 工具类
├── widgets/               # 可复用组件
```

```
assets/
├── fonts/                 # 字体文件 (Noto Sans SC)
├── images/                # 图片资源
└── music/                 # 音乐文件及配置
    └── songs.json         # 音乐列表配置
```

## 🚀 快速开始

### 环境要求

- Flutter SDK >= 3.9.2
- Dart SDK >= 3.9.2
- Android Studio / VS Code
- Android / iOS / Web / Desktop 开发环境（可选）

### 安装步骤

1. **克隆仓库**
   ```bash
   git clone <repository-url>
   cd todo_list_and_clock
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **运行应用**
   ```bash
   # 运行在 Chrome 浏览器
   flutter run -d chrome
   
   # 运行在 Android 设备
   flutter run -d android
   
   # 运行在 iOS 模拟器
   flutter run -d ios
   
   # 运行在桌面平台
   flutter run -d linux
   flutter run -d macos
   flutter run -d windows
   ```

4. **构建发布版本**
   ```bash
   # Android APK
   flutter build apk --release
   
   # iOS IPA
   flutter build ios --release
   
   # Web
   flutter build web --release
   ```

## 📱 支持平台

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Linux
- ✅ macOS
- ✅ Windows

## 🔧 配置说明

### 字体配置
应用使用 Noto Sans SC 中文字体，已包含在 `assets/fonts/` 目录中。

### 音乐资源
音乐文件放置在 `assets/music/` 目录，并在 `songs.json` 中配置音乐列表。

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🤝 贡献

欢迎贡献代码！请遵循以下步骤：

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📞 联系方式

如有问题或建议，请通过以下方式联系：

- 提交 Issue
- 发送邮件至项目维护者

## 🙏 致谢

感谢以下开源项目：

- [Flutter](https://flutter.dev)
- [Provider](https://pub.dev/packages/provider)
- [fl_chart](https://pub.dev/packages/fl_chart)
- [audioplayers](https://pub.dev/packages/audioplayers)
- [sqflite](https://pub.dev/packages/sqflite)

---

**Made with ❤️ using Flutter**
