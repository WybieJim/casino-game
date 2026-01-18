# Casino纯娱乐性质小游戏

一个纯娱乐性质的21点（BlackJack）游戏应用，使用Flutter开发，支持Android和Linux桌面平台。

## 🎮 游戏特性

- **经典21点游戏**：遵循标准BlackJack规则
- **简洁美观的界面**：Material Design设计风格
- **完全离线运行**：无需网络连接
- **智能庄家AI**：自动遵循17点规则
- **多平台支持**：Android和Linux桌面

## 🚀 快速开始

### 前提条件
- Flutter SDK (版本 >= 3.0.0)
- Android SDK (用于构建Android APK)
- Linux桌面环境 (用于桌面运行)

### 1. 克隆项目
```bash
git clone <repository-url>
cd casino_app
```

### 2. 获取依赖
```bash
flutter pub get
```

### 3. 运行游戏

#### 在Linux桌面运行（推荐用于开发调试）
```bash
# 启用Linux桌面支持（首次运行需要）
flutter config --enable-linux-desktop

# 运行游戏
flutter run -d linux
```

#### 在Android设备运行
```bash
# 连接Android设备或启动模拟器
flutter run -d <device-id>
```

#### 在Web浏览器运行
```bash
flutter run -d chrome
```

### 4. 常用开发命令

```bash
# 查看可用设备
flutter devices

# 热重载（运行中按 'r' 键）
# 热重启（运行中按 'R' 键）
# 退出应用（运行中按 'q' 键）

# 清理构建缓存
flutter clean

# 检查Flutter环境
flutter doctor
```

## 📱 构建Android APK

### 使用构建脚本
```bash
./build_apk.sh
```

### 手动构建
```bash
# 构建release版APK
flutter build apk --release

# 构建app bundle（Google Play格式）
flutter build appbundle --release
```

构建完成后，APK文件位于：
```
build/app/outputs/flutter-apk/app-release.apk
```

## 🌐 本地下载服务器

### 启动服务器
```bash
./start_server.sh
# 或手动运行
cd web
python3 server.py
```

### 访问下载页面
打开浏览器访问：`http://localhost:8000`

页面提供：
- APK下载链接
- 安装说明
- 游戏规则介绍

## 🎯 游戏规则

### 基本规则
- **目标**：使手中牌的点数之和尽可能接近21点，但不能超过
- **牌值**：
  - 2-10：按面值计算
  - J、Q、K：计为10点
  - A：可计为1点或11点（自动选择最优值）
- **流程**：
  1. 玩家先要牌，可以随时停牌
  2. 庄家在点数小于17时必须继续要牌
  3. 爆牌（超过21点）立即输掉
- **胜负**：最终点数高者获胜，平局则打平

### 游戏界面
- **庄家区域**：显示庄家牌和当前点数
- **玩家区域**：显示玩家牌和当前点数
- **控制按钮**：
  - 要牌（Hit）：再要一张牌
  - 停牌（Stand）：停止要牌，轮到庄家
- **游戏状态**：实时显示胜负结果和提示信息

## 🔧 项目结构

```
casino_app/
├── lib/
│   ├── main.dart              # 应用入口
│   ├── game_screen.dart       # 游戏主界面
│   └── game_logic.dart        # 游戏逻辑核心
├── web/
│   ├── index.html             # APK下载页面
│   └── server.py              # 本地HTTP服务器
├── linux/                     # Linux桌面平台配置
├── android/                   # Android平台配置
├── build_apk.sh               # APK构建脚本
├── start_server.sh            # 服务器启动脚本
└── pubspec.yaml               # 项目依赖配置
```

## 🐛 故障排除

### 常见问题

#### 1. Flutter运行到Web而不是桌面
```bash
# 指定Linux设备运行
flutter run -d linux

# 或启用Linux桌面支持
flutter config --enable-linux-desktop
```

#### 2. 缺少Linux桌面支持
```bash
# 添加Linux平台支持
flutter create --platforms=linux .
```

#### 3. 依赖获取失败
```bash
# 清理缓存后重新获取
flutter clean
flutter pub get

# 使用国内镜像（如网络不畅）
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
```

#### 4. Android APK安装失败
- 在Android设备上开启"未知来源"安装权限
- 确保APK签名正确

### 调试技巧

1. **查看完整错误信息**：运行 `flutter run -v` 查看详细日志
2. **检查环境配置**：运行 `flutter doctor -v` 诊断问题
3. **热重载失败时**：尝试热重启（按 'R' 键）
4. **内存泄漏检查**：使用Flutter DevTools进行性能分析

## 📝 开发指南

### 扩展功能建议
1. **添加新游戏**：德州扑克、轮盘赌等
2. **增强UI**：动画效果、音效、主题切换
3. **游戏统计**：胜率统计、游戏历史记录
4. **多人模式**：局域网多人对战

### 代码架构
- **数据模型**：`PlayingCard`（扑克牌）、`Deck`（牌组）
- **游戏逻辑**：`BlackJackGame`（状态管理、规则实现）
- **用户界面**：`GameScreen`（界面布局、交互处理）
- **状态管理**：使用Flutter内置的StatefulWidget

## ⚠️ 注意事项

1. **娱乐性质**：本项目仅供娱乐，禁止用于真实赌博
2. **本地运行**：所有数据存储在本地，无网络传输
3. **测试目的**：iOS版本需在TestFlight上分发
4. **开源协议**：项目代码可自由使用，请遵守相关法律法规

## 📞 支持与反馈

如有问题或建议，请：
1. 查看 `项目说明书.md` 获取详细文档
2. 运行 `flutter doctor` 检查环境配置
3. 提供详细的错误信息和重现步骤

---

**免责声明**：本游戏为纯娱乐软件，不涉及任何真实货币交易。请勿用于赌博活动。开发者不对任何滥用行为负责。