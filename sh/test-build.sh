#!/bin/bash

# 获取脚本所在目录的上级目录（项目根目录）
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "测试构建产物..."

# 检查JAR文件
if [ -f "build/BlobBackendService-1.0-SNAPSHOT.jar" ]; then
    echo "✅ 后端JAR文件构建成功"
    echo "   文件大小: $(ls -lh build/BlobBackendService-1.0-SNAPSHOT.jar | awk '{print $5}')"
else
    echo "❌ 后端JAR文件未找到"
    exit 1
fi

# 检查前端文件
if [ -d "build/frontend" ]; then
    echo "✅ 前端构建产物目录存在"
    echo "   包含文件:"
    ls -la build/frontend/
else
    echo "❌ 前端构建产物目录未找到"
    exit 1
fi

# 检查静态文件
if [ -d "build/frontend/static" ]; then
    echo "✅ 前端静态文件存在"
    echo "   静态文件数量: $(find build/frontend/static -type f | wc -l)"
else
    echo "❌ 前端静态文件未找到"
fi

echo ""
echo "🎉 构建测试完成！"
echo ""
echo "下一步部署建议："
echo "1. 后端部署："
echo "   java -jar build/BlobBackendService-1.0-SNAPSHOT.jar"
echo ""
echo "2. 前端部署："
echo "   将 build/frontend/ 目录部署到Nginx"
echo "   参考 nginx.conf.example 配置文件"
echo ""
echo "3. 数据库配置："
echo "   创建 application.properties 文件配置数据库连接" 