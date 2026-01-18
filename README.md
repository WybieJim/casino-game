# Casino纯娱乐性质小游戏 - 项目说明书

## 项目概述

本项目是一个纯娱乐性质的21点（BlackJack）游戏应用，使用Flutter开发，可在Android设备上运行。项目完全离线运行，无任何服务器交互，仅供朋友间娱乐使用。

### 主要特性
- 🎮 经典的21点游戏，遵循标准规则
- 📱 专为Android设计（未来可扩展iOS）
- 🎨 简洁美观的用户界面
- 🔒 完全离线运行，无需网络
- 📦 包含APK构建脚本和本地分发服务器

## 项目结构

```
casino_app/
├── lib/
│   ├── main.dart              # 应用入口
│   ├── game_screen.dart       # 游戏主界面
│   └── game_logic.dart        # 游戏逻辑（牌组、规则、状态）
├── web/
│   ├── index.html             # 下载页面
│   └── server.py              # 本地HTTP服务器
├── build_apk.sh               # APK构建脚本
├── start_server.sh            # 启动下载服务器脚本
├── pubspec.yaml               # Flutter项目配置
└── README.md                  # 项目说明
```

## 快速开始

### 前提条件
- Flutter SDK（版本 >= 3.0.0）
- Android SDK（用于构建APK）
- Python 3（用于运行本地服务器）

### 运行项目

1. **进入项目目录**
   ```bash
   cd casino_app
   ```

2. **获取依赖**
   ```bash
   flutter pub get
   ```

3. **运行开发版本**
   ```bash
   flutter run
   ```
   连接Android设备或启动模拟器查看效果。

### 构建Android APK

1. **使用构建脚本**
   ```bash
   ./build_apk.sh
   ```
   脚本会自动检查环境并构建release版APK。

2. **手动构建**
   ```bash
   flutter build apk --release
   ```
   生成的APK位于：`build/app/outputs/flutter-apk/app-release.apk`

### 启动本地下载服务器

1. **启动服务器**
   ```bash
   ./start_server.sh
   ```
   或手动运行：
   ```bash
   cd web
   python3 server.py
   ```

2. **访问下载页面**
   打开浏览器访问：`http://localhost:8000`
   页面提供APK下载链接和安装说明。

## 游戏规则说明

### 基本规则
- 目标：使手中牌的点数之和尽可能接近21点，但不能超过
- 牌值：2-10按面值计算，J/Q/K计为10点，A可计为1点或11点
- 流程：玩家先要牌，可以随时停牌；庄家在点数小于17时必须继续要牌
- 胜负：爆牌（超过21点）立即输掉；最终点数高者获胜

### 游戏界面
- **庄家区域**：显示庄家牌和点数
- **玩家区域**：显示玩家牌和点数
- **控制按钮**：要牌（Hit）、停牌（Stand）
- **游戏状态**：实时显示胜负结果

## 开发指南

### 项目架构
- **数据模型**：`PlayingCard`（扑克牌）、`Deck`（牌组）
- **游戏逻辑**：`BlackJackGame`（游戏状态管理）
- **用户界面**：`GameScreen`（游戏主界面）
- **状态管理**：使用Flutter内置的StatefulWidget

### 扩展可能性
1. **添加新游戏**：德州扑克、轮盘赌等
2. **增强UI**：添加动画效果、音效、主题切换
3. **多人游戏**：通过局域网实现多人对战
4. **数据统计**：记录游戏历史和数据统计

## 常见问题

### Q: Flutter环境配置问题
A: 确保Flutter SDK已正确安装并添加到PATH，运行`flutter doctor`检查环境。

### Q: 构建APK失败
A: 检查Android SDK配置，确保有有效的签名密钥（debug签名已自动生成）。

### Q: 无法安装APK
A: 在Android设备上开启"未知来源"安装权限。

### Q: 服务器无法启动
A: 检查Python 3是否安装，端口8000是否被占用。

## 注意事项

1. **娱乐性质**：本项目仅供娱乐，禁止用于真实赌博
2. **本地运行**：所有数据存储在本地，无网络传输
3. **测试目的**：iOS版本需在TestFlight上分发
4. **开源协议**：项目代码可自由使用，但需注明出处

## 联系方式

如有问题或建议，请联系项目维护者。

---

**免责声明**：本游戏为纯娱乐软件，不涉及任何真实货币交易。请勿用于赌博活动。开发者不对任何滥用行为负责。