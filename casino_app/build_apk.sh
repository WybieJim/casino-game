#!/bin/bash

# 构建Android APK脚本
# 确保Flutter已安装并配置好Android SDK

set -e

echo "开始构建Android APK..."

# 设置Flutter中国镜像（如果需要）
# export PUB_HOSTED_URL=https://pub.flutter-io.cn
# export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# 检查Flutter是否可用
if ! command -v flutter &> /dev/null; then
    echo "错误: Flutter未安装。请先安装Flutter并添加到PATH。"
    exit 1
fi

# 运行flutter doctor检查环境
echo "检查Flutter环境..."
flutter doctor -v

# 获取依赖
echo "获取依赖..."
flutter pub get

# 构建APK（发布模式）
echo "构建APK（release模式）..."
flutter build apk --release

echo "构建完成！APK文件位于: build/app/outputs/flutter-apk/app-release.apk"
echo "你可以将其复制到网页服务器供下载。"