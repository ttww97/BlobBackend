#!/bin/bash

echo "=== BlobBackend 手动部署脚本 ==="
echo "使用外部MySQL服务器: 101.35.137.86:3306"

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "错误: 未找到Docker，请先安装Docker"
    exit 1
fi

# 检查Maven是否安装
if ! command -v mvn &> /dev/null; then
    echo "错误: 未找到Maven，请先安装Maven"
    exit 1
fi

# 测试MySQL连接
echo "测试MySQL连接..."
if command -v mysql &> /dev/null; then
    mysql -h 101.35.137.86 -P 3306 -u dev_user -pUserPass!456 -e "SELECT 1;" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✓ MySQL连接成功"
    else
        echo "⚠ MySQL连接失败，请检查数据库配置"
        read -p "是否继续部署？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
else
    echo "⚠ 未安装mysql客户端，跳过连接测试"
fi

# 停止并删除现有容器
echo "停止现有容器..."
docker stop blob-app 2>/dev/null || true
docker rm blob-app 2>/dev/null || true

# 删除旧镜像（可选）
read -p "是否删除旧镜像？(y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "删除旧镜像..."
    docker rmi blob-backend 2>/dev/null || true
fi

# 构建后端JAR包
echo "构建后端JAR包..."
mvn clean package -DskipTests

if [ $? -ne 0 ]; then
    echo "✗ 后端构建失败"
    exit 1
fi

# 检查JAR文件
if [ ! -f target/*.jar ]; then
    echo "✗ 未找到JAR文件"
    exit 1
fi

echo "✓ 后端构建成功"

# 构建Docker镜像（使用简化Dockerfile）
echo "构建Docker镜像..."
docker build -f Dockerfile.simple -t blob-backend .

if [ $? -ne 0 ]; then
    echo "✗ 镜像构建失败"
    exit 1
fi

# 运行容器
echo "启动应用容器..."
docker run -d \
  --name blob-app \
  -p 80:80 \
  -p 8080:8080 \
  -e SPRING_DATASOURCE_URL="jdbc:mysql://101.35.137.86:3306/blob_backend?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true" \
  -e SPRING_DATASOURCE_USERNAME="dev_user" \
  -e SPRING_DATASOURCE_PASSWORD="UserPass!456" \
  -e JAVA_OPTS="-Xms512m -Xmx1g" \
  --restart unless-stopped \
  blob-backend

if [ $? -eq 0 ]; then
    echo "✓ 容器启动成功"
else
    echo "✗ 容器启动失败"
    exit 1
fi

# 等待服务启动
echo "等待服务启动..."
sleep 30

# 检查容器状态
echo "检查容器状态..."
docker ps | grep blob-app

# 检查健康状态
echo "检查健康状态..."
curl -f http://localhost:8080/api/health 2>/dev/null || echo "应用健康检查失败"

# 显示日志
echo "显示应用日志..."
docker logs blob-app

echo "=== 部署完成 ==="
echo "前端访问地址: http://$(hostname -I | awk '{print $1}')"
echo "后端API地址: http://$(hostname -I | awk '{print $1}'):8080"
echo "MySQL服务器: 101.35.137.86:3306"
echo ""
echo "常用命令："
echo "查看日志: docker logs -f blob-app"
echo "停止服务: docker stop blob-app"
echo "重启服务: docker restart blob-app"
echo "进入容器: docker exec -it blob-app sh" 