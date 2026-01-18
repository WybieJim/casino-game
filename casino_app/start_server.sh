#!/bin/bash

# 启动网页服务器供下载APK

set -e

echo "启动Casino游戏APK下载服务器..."
echo ""

cd "$(dirname "$0")/web"

if ! command -v python3 &> /dev/null; then
    echo "错误: 未找到python3，请先安装Python 3。"
    exit 1
fi

python3 server.py