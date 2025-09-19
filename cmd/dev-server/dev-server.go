package main

import (
	"flag"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"strings"
	"syscall"
)

// DevServer 开发服务器结构体
type DevServer struct {
	port      int
	dir       string
	server    *http.Server
	mimeTypes map[string]string
}

// NewDevServer 创建新的开发服务器
func NewDevServer(port int, dir string) *DevServer {
	return &DevServer{
		port: port,
		dir:  dir,
		mimeTypes: map[string]string{
			".wasm": "application/wasm",
			".js":   "application/javascript",
			".html": "text/html",
			".css":  "text/css",
			".json": "application/json",
			".png":  "image/png",
			".jpg":  "image/jpeg",
			".gif":  "image/gif",
			".svg":  "image/svg+xml",
			".ico":  "image/x-icon",
		},
	}
}

// 检查端口是否可用
func (ds *DevServer) isPortAvailable(port int) bool {
	addr := ":" + strconv.Itoa(port)
	ln, err := net.Listen("tcp", addr)
	if err != nil {
		return false
	}
	ln.Close()
	return true
}

// 找到可用端口
func (ds *DevServer) findAvailablePort(startPort int) int {
	for port := startPort; port <= startPort+10; port++ {
		if ds.isPortAvailable(port) {
			return port
		}
	}
	return 0
}

// 自定义文件服务器处理器
func (ds *DevServer) fileHandler(w http.ResponseWriter, r *http.Request) {
	// 安全处理路径
	path := r.URL.Path
	if path == "/" {
		path = "/index.html"
	}

	// 移除开头的斜杠
	path = strings.TrimPrefix(path, "/")

	// 获取文件扩展名
	ext := ""
	if idx := strings.LastIndex(path, "."); idx != -1 {
		ext = path[idx:]
	}

	// 设置 MIME 类型
	if mimeType, ok := ds.mimeTypes[ext]; ok {
		w.Header().Set("Content-Type", mimeType)
	}

	// 特殊处理 WASM 文件
	if ext == ".wasm" {
		w.Header().Set("Content-Type", "application/wasm")
		w.Header().Set("Cache-Control", "no-cache")
	}

	// 尝试读取文件
	data, err := os.ReadFile(path)
	if err != nil {
		if os.IsNotExist(err) {
			http.NotFound(w, r)
			return
		}
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	// 写入响应
	w.Write(data)
}

// Start 启动开发服务器
func (ds *DevServer) Start() error {
	// 找到可用端口
	finalPort := ds.findAvailablePort(ds.port)
	if finalPort == 0 {
		return fmt.Errorf("无法找到可用端口，端口范围 %d-%d 都被占用", ds.port, ds.port+10)
	}

	if finalPort != ds.port {
		fmt.Printf("⚠️  端口 %d 被占用，使用端口 %d\n", ds.port, finalPort)
		ds.port = finalPort
	}

	// 设置路由
	mux := http.NewServeMux()
	mux.HandleFunc("/", ds.fileHandler)

	// 创建服务器
	ds.server = &http.Server{
		Addr:    ":" + strconv.Itoa(ds.port),
		Handler: mux,
	}

	// 启动服务器
	fmt.Printf("🌐 TinyGo WebAssembly 开发服务器\n")
	fmt.Printf("====================================\n")
	fmt.Printf("📁 服务目录: %s\n", ds.dir)
	fmt.Printf("🌐 服务器地址: http://localhost:%d\n", ds.port)
	fmt.Printf("\n")

	// 检查重要文件
	if _, err := os.Stat("index.html"); os.IsNotExist(err) {
		fmt.Printf("⚠️  警告: index.html 不存在！\n")
	}

	if _, err := os.Stat("main.wasm"); os.IsNotExist(err) {
		fmt.Printf("⚠️  警告: main.wasm 不存在！\n")
		fmt.Printf("   请先运行: ./build.sh\n")
	}

	fmt.Printf("\n")
	fmt.Printf("🚀 服务器启动成功！\n")
	fmt.Printf("按 Ctrl+C 停止服务器\n")
	fmt.Printf("\n")

	// 设置信号处理
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)

	// 在 goroutine 中启动服务器
	go func() {
		if err := ds.server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Printf("服务器错误: %v", err)
		}
	}()

	// 等待中断信号
	<-sigChan
	fmt.Printf("\n🛑 正在关闭服务器...\n")
	return ds.Stop()
}

// Stop 停止开发服务器
func (ds *DevServer) Stop() error {
	if ds.server != nil {
		return ds.server.Close()
	}
	return nil
}

func main() {
	// 命令行参数
	var (
		port = flag.Int("port", 8000, "服务器端口")
		dir  = flag.String("dir", ".", "服务目录")
		help = flag.Bool("help", false, "显示帮助信息")
	)

	flag.Parse()

	if *help {
		fmt.Printf("TinyGo WebAssembly 开发服务器\n")
		fmt.Printf("用法: %s [选项]\n", os.Args[0])
		fmt.Printf("\n选项:\n")
		flag.PrintDefaults()
		fmt.Printf("\n示例:\n")
		fmt.Printf("  %s                    # 使用默认端口 8000\n", os.Args[0])
		fmt.Printf("  %s -port 3000         # 使用端口 3000\n", os.Args[0])
		fmt.Printf("  %s -dir ./dist        # 指定服务目录\n", os.Args[0])
		return
	}

	// 验证目录是否存在
	if _, err := os.Stat(*dir); os.IsNotExist(err) {
		log.Fatalf("❌ 目录不存在: %s", *dir)
	}

	// 创建并启动开发服务器
	server := NewDevServer(*port, *dir)
	if err := server.Start(); err != nil {
		log.Fatalf("❌ 服务器启动失败: %v", err)
	}

	fmt.Printf("✅ 服务器已关闭\n")
}