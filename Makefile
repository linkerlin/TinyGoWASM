# TinyGo WebAssembly 项目 Makefile

# 变量定义
TINYGO := tinygo
GO := go
WASM_FILE := main.wasm
GO_SOURCE := main.go
SERVER_SOURCE := dev-server.go
SERVER_BINARY := dev-server

# 默认目标
.PHONY: all
all: build

# 编译 WASM
.PHONY: build
build:
	@echo "🔧 编译 TinyGo WebAssembly..."
	$(TINYGO) build -o $(WASM_FILE) -target wasm $(GO_SOURCE)
	@echo "✅ 编译完成！文件大小:"
	@ls -lh $(WASM_FILE) | awk '{print "📦 " $$5}'

# 生产模式编译
.PHONY: build-prod
build-prod:
	@echo "⚡ 生产模式编译..."
	$(TINYGO) build -o $(WASM_FILE) -target wasm -opt=2 -no-debug $(GO_SOURCE)
	@echo "✅ 生产模式编译完成！文件大小:"
	@ls -lh $(WASM_FILE) | awk '{print "📦 " $$5}'

# 编译开发服务器
.PHONY: server
server:
	@echo "🔨 编译 Go 开发服务器..."
	$(GO) build -o $(SERVER_BINARY) cmd/dev-server/dev-server.go
	@echo "✅ 开发服务器编译完成！"

# 启动开发服务器（自动编译服务器）
.PHONY: run
run: server
	@echo "🚀 启动开发服务器..."
	./$(SERVER_BINARY)

# 直接运行开发服务器（不重新编译）
.PHONY: run-only
run-only:
	@echo "🚀 启动开发服务器..."
	./$(SERVER_BINARY)

# 清理生成的文件
.PHONY: clean
clean:
	@echo "🧹 清理生成的文件..."
	rm -f $(WASM_FILE) $(SERVER_BINARY)
	@echo "✅ 清理完成！"

# 完整重建
.PHONY: rebuild
rebuild: clean build

# 显示帮助
.PHONY: help
help:
	@echo "TinyGo WebAssembly 项目 Makefile"
	@echo "================================="
	@echo ""
	@echo "使用方法:"
	@echo "  make build      - 编译 WASM 文件（开发模式）"
	@echo "  make build-prod - 编译 WASM 文件（生产模式，优化大小）"
	@echo "  make server     - 编译 Go 开发服务器"
	@echo "  make run        - 编译并启动开发服务器"
	@echo "  make run-only   - 直接启动开发服务器（不重新编译）"
	@echo "  make clean      - 清理生成的文件"
	@echo "  make rebuild    - 完整重建（清理+编译）"
	@echo "  make help       - 显示此帮助信息"
	@echo ""
	@echo "快捷命令:"
	@echo "  make            - 等同于 make build"
	@echo ""

# 检查依赖
.PHONY: check
check:
	@echo "🔍 检查依赖..."
	@which tinygo > /dev/null && echo "✅ TinyGo 已安装: $$(tinygo version)" || echo "❌ TinyGo 未安装"
	@which go > /dev/null && echo "✅ Go 已安装: $$(go version)" || echo "❌ Go 未安装"
	@echo ""
	@echo "📁 项目文件:"
	@ls -la *.go *.wasm 2>/dev/null || echo "暂无相关文件"