#!/bin/bash

# 获取脚本所在目录的上级目录（项目根目录）
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "=== 生产环境启动脚本 ==="

# 检查应用目录
if [ ! -d "/opt/blob-backend" ]; then
    echo "❌ 应用目录不存在，请先部署项目到 /opt/blob-backend"
    exit 1
fi

cd /opt/blob-backend

# 检查JAR文件
if [ ! -f "build/BlobBackendService-1.0-SNAPSHOT.jar" ]; then
    echo "❌ JAR文件不存在，请先运行构建脚本"
    exit 1
fi

# 检查前端文件
if [ ! -d "build/frontend" ]; then
    echo "❌ 前端文件不存在，请先运行构建脚本"
    exit 1
fi

echo "✅ 文件检查通过"

# 停止现有服务
echo "停止现有服务..."
pkill -f BlobBackendService || true
sleep 2

# 启动后端服务
echo "启动后端服务..."
nohup java -Xms512m -Xmx2g -XX:+UseG1GC \
  -Dspring.profiles.active=prod \
  -jar build/BlobBackendService-1.0-SNAPSHOT.jar \
  > /var/log/blob-backend/app.log 2>&1 &

# 等待服务启动
echo "等待服务启动..."
sleep 10

# 检查服务状态
if curl -s http://localhost:8080/api/health > /dev/null 2>&1; then
    echo "✅ 后端服务启动成功"
else
    echo "❌ 后端服务启动失败，查看日志："
    tail -20 /var/log/blob-backend/app.log
    exit 1
fi

# 检查Nginx配置
echo "检查Nginx配置..."
if [ -f "/etc/nginx/conf.d/blob-backend.conf" ]; then
    sudo nginx -t
    if [ $? -eq 0 ]; then
        echo "✅ Nginx配置正确"
        sudo systemctl reload nginx
        echo "✅ Nginx重新加载完成"
    else
        echo "❌ Nginx配置有误"
        exit 1
    fi
else
    echo "⚠️  Nginx配置文件不存在，请手动配置"
fi

echo ""
echo "🎉 生产环境启动完成！"
echo ""
echo "服务信息："
echo "  后端服务: http://localhost:8080"
echo "  前端访问: http://your-domain.com (需要配置域名)"
echo "  日志文件: /var/log/blob-backend/app.log"
echo ""
echo "监控命令："
echo "  查看日志: tail -f /var/log/blob-backend/app.log"
echo "  检查状态: curl http://localhost:8080/api/health"
echo "  停止服务: pkill -f BlobBackendService" 