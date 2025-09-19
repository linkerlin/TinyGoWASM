# 🚀 快速开始指南

## 1. 安装 TinyGo

### macOS
```bash
brew install tinygo
```

### Linux
```bash
wget https://github.com/tinygo-org/tinygo/releases/download/v0.30.0/tinygo_0.30.0_amd64.deb
sudo dpkg -i tinygo_0.30.0_amd64.deb
```

### Windows
下载安装包：https://github.com/tinygo-org/tinygo/releases

## 2. 验证安装
```bash
tinygo version
```

## 3. 编译项目

### 使用自动编译脚本（推荐）
```bash
./build.sh
```

### 手动编译
```bash
tinygo build -o main.wasm -target wasm main.go
```

## 4. 启动服务器

### 使用 Makefile（最简单）
```bash
# 一键编译并启动
make run
```

### 使用自动服务器脚本（推荐）
```bash
./server.sh
```

**🎯 新特性：** 现在优先使用 **Go 开发服务器**，无需 Python 依赖！

### 手动启动
```bash
# 使用 Go 开发服务器（推荐）
go run dev-server.go

# Python 3（备选）
python -m http.server 8000

# Node.js（备选）
npx http-server -p 8000
```

## 5. 访问应用
打开浏览器，访问：http://localhost:8000

查看浏览器控制台输出！

## 📋 一键命令

如果你赶时间，这里是一键完成所有步骤的命令：

```bash
# 1. 安装 TinyGo (macOS)
brew install tinygo

# 2. 编译并启动（最简单的方法）
make run

# 或者分步执行：
# make build    # 编译 WASM
# make run      # 编译并启动服务器
```

## 🔍 验证成功

成功运行时，你应该看到：

1. **编译成功消息**：✅ 编译成功！
2. **文件大小信息**：📦 WASM 文件大小: XX KB
3. **服务器启动消息**：🚀 启动服务器...
4. **浏览器控制台输出**：
   - "WASM 文件加载成功"
   - "Hello from TinyGo WebAssembly!"
   - "5 + 3 = 8"

## ❓ 常见问题

### Q: 编译失败怎么办？
A: 检查 TinyGo 是否安装成功：`tinygo version`

### Q: 端口被占用怎么办？
A: 使用其他端口：`./server.sh 8001`

### Q: 浏览器没有输出？
A: 打开浏览器开发者工具，查看 Console 标签页

### Q: main.wasm 文件不存在？
A: 先运行编译命令：`./build.sh`

## 🎯 下一步

- 修改 `main.go` 添加你自己的函数
- 查看完整的 [README.md](README.md) 了解更多高级功能
- 尝试导出更多函数到 JavaScript
- 探索 TinyGo 的其他应用场景

**祝你编程愉快！🎉**