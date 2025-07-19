#!/bin/bash

# 获取脚本所在目录的上级目录（项目根目录）
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "=== 完整部署脚本 ==="

# 检查是否在服务器环境
if [ "$1" != "--server" ]; then
    echo "⚠️  此脚本需要在服务器上运行"
    echo "使用方法: ./deploy.sh --server"
    exit 1
fi

echo "1. 检查环境..."

# 检查Java
if ! command -v java &> /dev/null; then
    echo "❌ 未找到Java，请先安装Java 17+"
    exit 1
fi

# 检查MySQL
if ! command -v mysql &> /dev/null; then
    echo "❌ 未找到MySQL客户端，请先安装MySQL"
    exit 1
fi

echo "✅ 环境检查通过"

echo ""
echo "2. 设置数据库..."

# 运行数据库初始化脚本
if [ -f "database/setup-database.sh" ]; then
    echo "正在初始化数据库..."
    cd database
    ./setup-database.sh
    cd ..
else
    echo "❌ 数据库初始化脚本未找到"
    exit 1
fi

echo ""
echo "3. 启动后端服务..."

# 检查JAR文件是否存在
if [ ! -f "build/BlobBackendService-1.0-SNAPSHOT.jar" ]; then
    echo "❌ JAR文件未找到，请先运行 ./build.sh"
    exit 1
fi

# 停止现有服务
echo "停止现有服务..."
pkill -f BlobBackendService || true

# 启动服务
echo "启动后端服务..."
nohup java -jar build/BlobBackendService-1.0-SNAPSHOT.jar --spring.profiles.active=prod > app.log 2>&1 &

# 等待服务启动
echo "等待服务启动..."
sleep 10

# 检查服务状态
if curl -s http://localhost:8080/actuator/health > /dev/null 2>&1; then
    echo "✅ 后端服务启动成功"
else
    echo "❌ 后端服务启动失败，查看日志："
    tail -20 app.log
    exit 1
fi

echo ""
echo "4. 配置Nginx..."

# 检查Nginx
if command -v nginx &> /dev/null; then
    echo "检测到Nginx，请手动配置："
    echo "1. 复制 nginx.conf.example 到 /etc/nginx/sites-available/your-app"
    echo "2. 修改配置中的路径和域名"
    echo "3. 启用站点：sudo ln -s /etc/nginx/sites-available/your-app /etc/nginx/sites-enabled/"
    echo "4. 重启Nginx：sudo systemctl reload nginx"
else
    echo "未检测到Nginx，请安装并配置Web服务器"
fi

echo ""
echo "🎉 部署完成！"
echo ""
echo "服务信息："
echo "  后端服务: http://localhost:8080"
echo "  日志文件: app.log"
echo "  数据库: blob_backend"
echo ""
echo "下一步："
echo "1. 配置Nginx代理前端静态文件"
echo "2. 设置域名和SSL证书"
echo "3. 配置防火墙和安全设置"
echo ""
echo "监控命令："
echo "  查看日志: tail -f app.log"
echo "  检查状态: curl http://localhost:8080/actuator/health"
echo "  停止服务: pkill -f BlobBackendService" 