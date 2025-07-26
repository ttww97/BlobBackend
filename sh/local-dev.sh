#!/bin/bash

# 获取脚本所在目录的上级目录（项目根目录）
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "=== 本地开发环境启动 ==="

# 检查Java环境
if ! command -v java &> /dev/null; then
    echo "❌ 未找到Java，请先安装Java 17+"
    exit 1
fi

echo "✅ Java版本: $(java -version 2>&1 | head -1)"

# 检查Maven
if ! command -v mvn &> /dev/null; then
    echo "❌ 未找到Maven，请先安装Maven"
    exit 1
fi

echo "✅ Maven版本: $(mvn -version | head -1)"

# 检查MySQL（可选）
if command -v mysql &> /dev/null; then
    echo "✅ MySQL已安装"
else
    echo "⚠️  MySQL未安装，将使用H2内存数据库"
fi

echo ""
echo "1. 清理并编译项目..."

# 清理之前的构建
mvn clean

# 编译项目
mvn compile

echo ""
echo "2. 启动开发服务器..."

# 停止可能运行的服务
pkill -f "spring-boot:run" || true
pkill -f "BlobBackendService" || true

# 启动开发服务器
echo "启动Spring Boot开发服务器..."
mvn spring-boot:run -Dspring-boot.run.profiles=dev

echo ""
echo "🎉 本地开发服务器启动完成！"
echo ""
echo "服务信息："
echo "  后端API: http://localhost:8080"
echo "  健康检查: http://localhost:8080/api/health"
echo "  测试接口: http://localhost:8080/api/checkBackend"
echo ""
echo "调试信息："
echo "  日志输出: 实时显示在控制台"
echo "  热重载: 修改代码后自动重启"
echo "  停止服务: Ctrl+C"
echo ""
echo "API测试："
echo "  curl -X POST http://localhost:8080/api/checkBackend"
echo "  curl http://localhost:8080/api/health" 