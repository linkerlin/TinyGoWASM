#!/bin/bash

# TinyGo WebAssembly HTTP 服务器启动脚本

echo "🌐 TinyGo WebAssembly 开发服务器"
echo "===================================="

# 检查端口是否被占用
check_port() {
    if command -v lsof &> /dev/null; then
        if lsof -i :$1 &> /dev/null; then
            return 0
        fi
    elif command -v netstat &> /dev/null; then
        if netstat -tuln | grep -q ":$1 "; then
            return 0
        fi
    fi
    return 1
}

# 默认端口
PORT=8000

# 检查是否提供了自定义端口
if [ $# -gt 0 ]; then
    if [[ $1 =~ ^[0-9]+$ ]]; then
        PORT=$1
    else
        echo "❌ 端口号必须是数字"
        exit 1
    fi
fi

# 检查端口是否被占用
if check_port $PORT; then
    echo "❌ 端口 $PORT 已被占用！"
    read -p "是否尝试其他端口？(y/n): " try_other
    if [[ $try_other == "y" || $try_other == "Y" ]]; then
        # 尝试找到可用端口
        for ((i=8001; i<=8010; i++)); do
            if ! check_port $i; then
                PORT=$i
                echo "✅ 使用端口 $PORT"
                break
            fi
        done
        if [ $PORT -eq 8000 ]; then
            echo "❌ 端口 8000-8010 都被占用！"
            exit 1
        fi
    else
        exit 1
    fi
fi

echo "📁 服务器目录: $(pwd)"
echo "🌐 服务器地址: http://localhost:$PORT"
echo ""

# 检查文件是否存在
if [ ! -f "index.html" ]; then
    echo "⚠️  警告: index.html 不存在！"
fi

if [ ! -f "main.wasm" ]; then
    echo "⚠️  警告: main.wasm 不存在！"
    echo "   请先运行: ./build.sh"
fi

echo ""
echo "🚀 启动服务器..."
echo "按 Ctrl+C 停止服务器"
echo ""

# 首先尝试使用 Go 开发服务器
if command -v go &> /dev/null; then
    echo "使用 Go 开发服务器"
    
    # 检查 dev-server.go 是否存在
    if [ -f "cmd/dev-server/dev-server.go" ]; then
        echo "编译 Go 开发服务器..."
        go build -o dev-server cmd/dev-server/dev-server.go
        if [ $? -eq 0 ]; then
            echo "✅ Go 开发服务器编译成功！"
            ./dev-server -port $PORT
        else
            echo "❌ Go 开发服务器编译失败，尝试其他选项..."
        fi
    else
        echo "⚠️  dev-server.go 不存在，尝试其他服务器选项..."
    fi
fi

# 如果 Go 服务器不可用，尝试其他选项
echo "尝试备选服务器..."

if command -v python3 &> /dev/null; then
    echo "使用 Python 3 HTTP 服务器"
    python3 -m http.server $PORT
elif command -v python &> /dev/null; then
    echo "使用 Python 2 HTTP 服务器"
    python -m SimpleHTTPServer $PORT
elif command -v node &> /dev/null && command -v npx &> /dev/null; then
    echo "使用 Node.js http-server"
    npx http-server -p $PORT -c-1
elif command -v ruby &> /dev/null; then
    echo "使用 Ruby HTTP 服务器"
    ruby -run -e httpd . -p $PORT
else
    echo "❌ 未找到合适的 HTTP 服务器！"
    echo "请安装以下任一工具："
    echo "  - Go: https://golang.org/dl/"
    echo "  - Python: https://www.python.org/downloads/"
    echo "  - Node.js: https://nodejs.org/"
    echo "  - Ruby: https://www.ruby-lang.org/en/downloads/"
    exit 1
fi