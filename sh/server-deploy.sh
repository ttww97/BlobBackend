#!/bin/bash

# 获取脚本所在目录的上级目录（项目根目录）
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "=== 服务器后端部署 ==="

# 检查是否在服务器环境
if [ "$1" != "--server" ]; then
    echo "⚠️  此脚本需要在服务器上运行"
    echo "使用方法: ./server-deploy.sh --server"
    exit 1
fi

echo "1. 检查环境..."

# 检查Java
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

# 检查MySQL
if ! command -v mysql &> /dev/null; then
    echo "❌ 未找到MySQL客户端，请先安装MySQL"
    exit 1
fi

echo "✅ MySQL已安装"

echo ""
echo "2. 构建项目..."

# 清理并构建
mvn clean package -DskipTests

# 检查JAR文件
if [ ! -f "target/BlobBackendService-1.0-SNAPSHOT.jar" ]; then
    echo "❌ 构建失败，JAR文件未生成"
    exit 1
fi

echo "✅ 项目构建成功"

echo ""
echo "3. 设置数据库..."

# 运行数据库初始化脚本
if [ -f "database/setup-database.sh" ]; then
    echo "正在初始化数据库..."
    cd database
    ./setup-database.sh
    cd ..
else
    echo "⚠️  数据库初始化脚本未找到，请手动配置数据库"
fi

echo ""
echo "4. 启动后端服务..."

# 停止现有服务
echo "停止现有服务..."
pkill -f BlobBackendService || true
sleep 2

# 创建日志目录
mkdir -p logs

# 启动服务
echo "启动后端服务..."
nohup java -Xms512m -Xmx1g \
  -Dspring.profiles.active=prod \
  -jar target/BlobBackendService-1.0-SNAPSHOT.jar \
  > logs/app.log 2>&1 &

# 等待服务启动
echo "等待服务启动..."
sleep 10

# 检查服务状态
if curl -s http://localhost:8080/api/health > /dev/null 2>&1; then
    echo "✅ 后端服务启动成功"
else
    echo "❌ 后端服务启动失败，查看日志："
    tail -20 logs/app.log
    exit 1
fi

echo ""
echo "🎉 服务器部署完成！"
echo ""
echo "服务信息："
echo "  后端API: http://localhost:8080"
echo "  健康检查: http://localhost:8080/api/health"
echo "  测试接口: http://localhost:8080/api/checkBackend"
echo "  日志文件: logs/app.log"
echo ""
echo "监控命令："
echo "  查看日志: tail -f logs/app.log"
echo "  检查状态: curl http://localhost:8080/api/health"
echo "  停止服务: pkill -f BlobBackendService"
echo ""
echo "API测试："
echo "  curl -X POST http://localhost:8080/api/checkBackend"
echo "  curl http://localhost:8080/api/health" 