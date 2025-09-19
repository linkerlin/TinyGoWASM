package main 
import ( "fmt" ) 
func main() { 
	fmt.Println("Hello from TinyGo WebAssembly!") 
} 
// 导出函数供JavaScript调用 
//export add
func add(a, b int) int { 
	return a + b 
}
