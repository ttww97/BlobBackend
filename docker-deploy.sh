#!/bin/bash

echo "=== BlobBackend Docker 部署脚本 ==="
echo "使用外部MySQL服务器: 101.35.137.86:3306"

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "错误: 未找到Docker，请先安装Docker"
    exit 1
fi

# 检查Docker Compose是否安装
if ! command -v docker-compose &> /dev/null; then
    echo "错误: 未找到Docker Compose，请先安装Docker Compose"
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
docker-compose down

# 删除旧镜像（可选）
read -p "是否删除旧镜像？(y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "删除旧镜像..."
    docker-compose down --rmi all
fi

# 构建并启动服务
echo "构建并启动服务..."
docker-compose up -d --build

# 等待服务启动
echo "等待服务启动..."
sleep 30

# 检查服务状态
echo "检查服务状态..."
docker-compose ps

# 检查健康状态
echo "检查健康状态..."
docker-compose exec app curl -f http://localhost/health || echo "应用健康检查失败"

# 显示日志
echo "显示应用日志..."
docker-compose logs app

echo "=== 部署完成 ==="
echo "前端访问地址: http://$(hostname -I | awk '{print $1}')"
echo "后端API地址: http://$(hostname -I | awk '{print $1}'):8080"
echo "MySQL服务器: 101.35.137.86:3306"
echo ""
echo "常用命令："
echo "查看日志: docker-compose logs -f"
echo "停止服务: docker-compose down"
echo "重启服务: docker-compose restart"
echo "进入容器: docker-compose exec app sh" 