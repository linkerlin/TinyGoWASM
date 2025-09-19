# TinyGo WebAssembly 开发指南

## 🚀 项目简介

这是一个使用 **TinyGo** 将 Go 代码编译为 **WebAssembly (WASM)** 的示例项目，展示了如何在浏览器中运行 Go 代码，实现高性能的 Web 应用开发。

## 📖 什么是 TinyGo？

TinyGo 是一个专为嵌入式系统和 WebAssembly 优化的 Go 编译器。它能够让 Go 代码在资源受限的环境中运行，包括：

- **微控制器**（Arduino、Raspberry Pi Pico 等）
- **WebAssembly**（浏览器环境）
- **命令行工具**（小型可执行文件）

### TinyGo 的核心优势

| 特性 | 标准 Go | TinyGo |
|------|---------|---------|
| 二进制大小 | 几 MB | 几十 KB |
| 内存占用 | 较高 | 极低 |
| 编译速度 | 中等 | 快速 |
| 目标平台 | 服务器/桌面 | 嵌入式/WebAssembly |
| 标准库支持 | 完整 | 核心子集 |

## 🎯 为什么选择 TinyGo + WebAssembly？

### 1. **性能优势**
- **接近原生性能**：WebAssembly 提供接近原生的执行速度
- **小型二进制文件**：相比标准 Go，TinyGo 生成的 WASM 文件更小
- **快速加载**：小文件体积意味着更快的网络加载时间

### 2. **开发效率**
- **熟悉的语法**：使用你喜爱的 Go 语言语法
- **类型安全**：Go 的强类型系统在编译时捕获错误
- **并发模型**：虽然浏览器环境限制，但仍可利用 Go 的并发思维

### 3. **应用场景**
- **图像处理**：客户端图像滤镜、压缩、格式转换
- **数据加密**：客户端加密解密，保护用户隐私
- **游戏开发**：高性能游戏逻辑和物理引擎
- **科学计算**：复杂的数学运算和数据处理
- **区块链**：客户端加密钱包和智能合约交互

## 🛠️ 环境搭建

### 安装 TinyGo

#### macOS (使用 Homebrew)
```bash
brew install tinygo
```

#### Linux
```bash
wget https://github.com/tinygo-org/tinygo/releases/download/v0.30.0/tinygo_0.30.0_amd64.deb
sudo dpkg -i tinygo_0.30.0_amd64.deb
```

#### Windows
下载安装包：https://github.com/tinygo-org/tinygo/releases

### 验证安装
```bash
tinygo version
```

## 📋 项目结构

```
TinyGoWASM/
├── main.go          # Go 源代码
├── main.wasm        # 编译后的 WebAssembly 文件
├── index.html       # 网页界面和 JavaScript 加载器
├── go.mod           # Go 模块文件
├── README.md        # 项目文档
└── LICENSE          # 许可证
```

## 🔧 核心代码解析

### Go 代码 (`main.go`)

```go
package main

import (
    "fmt"
)

func main() {
    fmt.Println("Hello from TinyGo WebAssembly!")
}

// 导出函数供JavaScript调用
//export add
func add(a, b int) int {
    return a + b
}
```

**关键点说明：**
- `//export add`：这个注释告诉 TinyGo 将此函数导出到 WebAssembly
- 导出的函数可以被 JavaScript 直接调用
- `main()` 函数在 WASM 加载时自动执行

### 编译命令

```bash
# 编译为 WebAssembly
tinygo build -o main.wasm -target wasm main.go

# 或者使用优化标志
tinygo build -o main.wasm -target wasm -opt=2 -no-debug main.go
# 或者
tinygo build -o main.wasm -target wasm -gc=conservative -scheduler=asyncify -opt=2 -no-debug  main.go
```

### HTML 和 JavaScript (`index.html`)

项目包含了一个完整的 TinyGo 运行时环境，负责：

1. **内存管理**：管理 WebAssembly 线性内存
2. **函数调用**：处理 JavaScript 与 Go 之间的函数调用
3. **类型转换**：在 JavaScript 和 Go 类型之间进行转换
4. **错误处理**：捕获和处理运行时错误

**主要功能：**
```javascript
// 加载 WASM 文件
const response = await fetch('main.wasm');
const buffer = await response.arrayBuffer();

// 实例化 WebAssembly
const result = await WebAssembly.instantiate(buffer, go.importObject);

// 运行 TinyGo 运行时
await go.run(result.instance);

// 调用导出的函数
const sum = result.instance.exports.add(5, 3);
console.log("5 + 3 =", sum); // 输出：5 + 3 = 8
```

## 🚀 快速开始

> **⏰ 赶时间？** 查看 [QUICKSTART.md](QUICKSTART.md) 获取最简洁的入门指南！

### 一键开始（推荐）

我们为你准备了多种自动化工具，让一切变得简单：

#### 方法 1：使用 Makefile（最简单）
```bash
# 编译并启动开发服务器
make run

# 或者分步执行
make build    # 编译 WASM
make server   # 编译 Go 服务器
make run-only # 启动服务器
```

#### 方法 2：使用 Shell 脚本（功能丰富）
```bash
# 1. 编译项目（交互式选择编译模式）
./build.sh

# 2. 启动开发服务器（自动检测可用端口，优先使用 Go 开发服务器）
./server.sh

# 3. 打开浏览器访问：http://localhost:8000
```

**🎯 新特性：** 现在优先使用 **Go 开发服务器**，无需 Python 依赖！服务器会自动编译并启动 Go 编写的开发服务器，提供更好的 WebAssembly 支持。

### 传统步骤

#### 1. 克隆项目
```bash
git clone <your-repo-url>
cd TinyGoWASM
```

#### 2. 安装 TinyGo
按照上面的环境搭建步骤安装 TinyGo

#### 3. 编译项目
```bash
tinygo build -o main.wasm -target wasm main.go
```

#### 4. 运行项目
由于 WebAssembly 需要通过 HTTP 服务器加载，你可以使用以下任一方法：

**方法 1：使用 Python 简单服务器**
```bash
# Python 3
python -m http.server 8000

# Python 2
python -m SimpleHTTPServer 8000
```

**方法 2：使用 Node.js http-server**
```bash
npx http-server -p 8000
```

**方法 3：使用 Go 内置服务器**
```bash
go run -mod=mod github.com/shurcooL/goexec 'http.ListenAndServe(":8000", http.FileServer(http.Dir(".")))'
```

#### 5. 访问应用
打开浏览器，访问 `http://localhost:8000`，查看控制台输出！

### 🔍 验证成功

成功运行时，你应该在浏览器控制台看到：
```
WASM 文件加载成功，大小: XXXX 字节
WASM 实例化成功
内存初始化成功，大小: XXXX 字节
Hello from TinyGo WebAssembly!
5 + 3 = 8
```

## 🎨 进阶开发

### 导出多个函数
```go
//export multiply
func multiply(a, b float64) float64 {
    return a * b
}

//export greet
func greet(name string) string {
    return "Hello, " + name + "!"
}
```

### 使用结构体
```go
//export createPoint
func createPoint(x, y float64) Point {
    return Point{X: x, Y: y}
}

type Point struct {
    X float64
    Y float64
}
```

### 错误处理
```go
//export safeDivide
func safeDivide(a, b float64) (float64, error) {
    if b == 0 {
        return 0, fmt.Errorf("division by zero")
    }
    return a / b, nil
}
```

## 📊 性能优化技巧

### 1. 减小文件大小
```bash
# 使用优化级别 2
tinygo build -o main.wasm -target wasm -opt=2 main.go

# 移除调试信息
tinygo build -o main.wasm -target wasm -no-debug main.go

# 同时使用
tinygo build -o main.wasm -target wasm -opt=2 -no-debug main.go
```

### 2. 内存管理
- 合理设置初始内存大小
- 避免内存泄漏
- 及时释放不需要的对象

### 3. 函数调用优化
- 减少频繁的跨语言调用
- 批量处理数据
- 使用指针传递大数据结构

## 🔍 调试技巧

### 1. 浏览器开发者工具
- 在 Console 中查看输出
- 使用 Sources 面板调试 JavaScript
- Performance 面板分析性能

### 2. 日志记录
```go
func main() {
    fmt.Println("WASM 模块加载完成")
    fmt.Printf("内存使用：%d 字节\n", memory.Size())
}
```

### 3. 错误处理
```javascript
try {
    const result = await WebAssembly.instantiate(buffer, go.importObject);
} catch (error) {
    console.error('WASM 加载失败:', error);
}
```

## 🌐 浏览器兼容性

| 浏览器 | 最低版本 | 支持情况 |
|--------|----------|----------|
| Chrome | 57+ | ✅ 完全支持 |
| Firefox | 52+ | ✅ 完全支持 |
| Safari | 11+ | ✅ 完全支持 |
| Edge | 16+ | ✅ 完全支持 |
| 移动浏览器 | iOS 11+, Android 7+ | ✅ 支持 |

## 📚 学习资源

### 官方资源
- [TinyGo 官网](https://tinygo.org/)
- [TinyGo GitHub](https://github.com/tinygo-org/tinygo)
- [WebAssembly 官网](https://webassembly.org/)

### 教程和文档
- [TinyGo WebAssembly 指南](https://tinygo.org/docs/guides/webassembly/)
- [Go 语言官方文档](https://golang.org/doc/)
- [MDN WebAssembly 文档](https://developer.mozilla.org/en-US/docs/WebAssembly)

### 社区支持
- [TinyGo Discord](https://discord.gg/ujp6bP2)
- [TinyGo 论坛](https://forum.tinygo.org/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/tinygo)

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

### 提交 Issue
- 描述清楚遇到的问题
- 提供复现步骤
- 包含环境信息（操作系统、TinyGo 版本等）

### 提交代码
1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

- [TinyGo 团队](https://tinygo.org/) - 创建了这个优秀的编译器
- [WebAssembly 社区](https://webassembly.org/) - 推动了 Web 技术的发展
- [Go 语言团队](https://golang.org/) - 开发了出色的编程语言

---

**Happy Coding! 🎉**

如果你有任何问题或建议，欢迎随时联系我们！