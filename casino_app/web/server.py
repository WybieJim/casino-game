#!/usr/bin/env python3
"""
简单的HTTP服务器，用于分发Android APK安装包。
运行：python3 server.py
默认端口：8000
访问：http://localhost:8000
"""

import http.server
import socketserver
import os
import sys

PORT = 8000
APK_FILE = "app-release.apk"
APK_PATH = "../build/app/outputs/flutter-apk/" + APK_FILE

class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        # 如果请求APK文件但文件不存在，提供提示
        if self.path == f'/{APK_FILE}' and not os.path.exists(APK_PATH):
            self.send_response(404)
            self.send_header('Content-type', 'text/html; charset=utf-8')
            self.end_headers()
            self.wfile.write(f"""
                <html>
                <body>
                <h1>APK文件未找到</h1>
                <p>请先运行构建脚本生成APK文件：<code>./build_apk.sh</code></p>
                <p>APK预期路径：{APK_PATH}</p>
                <a href="/">返回首页</a>
                </body>
                </html>
            """.encode('utf-8'))
            return
        super().do_GET()

    def log_message(self, format, *args):
        # 自定义日志格式
        print(f"[HTTP] {self.address_string()} - {format % args}")

if __name__ == "__main__":
    # 切换到web目录
    web_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(web_dir)
    
    # 如果APK文件存在，创建符号链接到web目录
    if os.path.exists(APK_PATH):
        target_link = os.path.join(web_dir, APK_FILE)
        if not os.path.exists(target_link):
            os.symlink(os.path.abspath(APK_PATH), target_link)
            print(f"已创建APK符号链接: {target_link}")
    else:
        print(f"提示: APK文件不存在。请先运行构建脚本。")
        print(f"预期路径: {APK_PATH}")
    
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print(f"服务器启动在端口 {PORT}")
        print(f"访问地址: http://localhost:{PORT}")
        print("按 Ctrl+C 停止服务器")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n服务器已停止")
            sys.exit(0)