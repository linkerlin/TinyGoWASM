#!/bin/bash

# TinyGo WebAssembly 编译脚本

echo "🚀 TinyGo WebAssembly 编译器"
echo "=============================="

# 检查 TinyGo 是否安装
if ! command -v tinygo &> /dev/null; then
    echo "❌ TinyGo 未安装！请先安装 TinyGo："
    echo "   macOS: brew install tinygo"
    echo "   Linux: 查看 https://tinygo.org/getting-started/"
    echo "   Windows: 下载安装包 https://github.com/tinygo-org/tinygo/releases"
    exit 1
fi

# 显示 TinyGo 版本
echo "✅ TinyGo 版本: $(tinygo version)"

# 编译选项
echo ""
echo "选择编译模式："
echo "1. 开发模式 (快速编译，包含调试信息)"
echo "2. 生产模式 (优化大小和性能)"
echo "3. 自定义模式"
read -p "请输入选项 (1-3): " choice

case $choice in
    1)
        echo "🔧 开发模式编译..."
        tinygo build -o main.wasm -target wasm main.go
        ;;
    2)
        echo "⚡ 生产模式编译..."
        tinygo build -o main.wasm -target wasm -gc=conservative -scheduler=asyncify -opt=2 -no-debug  main.go
        ;;
    3)
        echo "🎨 自定义编译选项："
        echo "可用选项："
        echo "  -opt=0/1/2    优化级别 (0=无优化, 1=简单优化, 2=完全优化)"
        echo "  -no-debug     移除调试信息"
        echo "  -scheduler    调度器类型 (tasks, asyncify, none)"
        echo "  -panic         panic 处理 (print, trap)"
        read -p "输入自定义选项 (例如: -opt=2 -no-debug): " custom_opts
        tinygo build -o main.wasm -target wasm $custom_opts main.go
        ;;
    *)
        echo "❌ 无效选项，使用默认开发模式"
        tinygo build -o main.wasm -target wasm main.go
        ;;
esac

# 检查结果
if [ $? -eq 0 ]; then
    echo "✅ 编译成功！"
    
    # 显示文件大小
    if [ -f "main.wasm" ]; then
        size=$(ls -lh main.wasm | awk '{print $5}')
        echo "📦 WASM 文件大小: $size"
        
        # 显示导出函数
        echo ""
        echo "🔍 导出的函数："
        if command -v wasm-objdump &> /dev/null; then
            wasm-objdump -x main.wasm | grep -E "^.*export" | head -10
        else
            echo "   安装 WebAssembly Binary Toolkit 查看导出函数："
            echo "   macOS: brew install wabt"
            echo "   Linux: sudo apt-get install wabt"
        fi
    fi
    
    echo ""
    echo "🌐 运行项目："
    echo "1. 启动 HTTP 服务器（推荐 Go 服务器）："
    echo "   ./server.sh"
    echo "   或"
    echo "   go run cmd/dev-server.go"
    echo "   或"
    echo "   python -m http.server 8000"
    echo ""
    echo "2. 打开浏览器访问：http://localhost:8000"
    echo ""
    echo "3. 查看浏览器控制台输出！"
    
else
    echo "❌ 编译失败！请检查错误信息"
    exit 1
fi