#!/bin/bash

echo "=== 数据库重置脚本 ==="

# 数据库连接信息
DB_HOST="localhost"
DB_PORT="3306"
DB_ROOT_USER="root"
DB_ROOT_PASSWORD="D1gwzdsjq!!!"
DB_DEV_USER="dev_user"
DB_DEV_PASSWORD="UserPass!456"
DB_NAME="blob_backend"

echo "⚠️  警告：此脚本将删除并重新创建数据库！"
echo "数据库名: $DB_NAME"
echo "主机: $DB_HOST:$DB_PORT"
echo ""

read -p "确定要继续吗？(y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "操作已取消"
    exit 1
fi

echo "正在连接到MySQL数据库..."

# 检查MySQL连接
if ! mysql -h $DB_HOST -P $DB_PORT -u $DB_ROOT_USER -p$DB_ROOT_PASSWORD -e "SELECT 1;" > /dev/null 2>&1; then
    echo "❌ 无法连接到MySQL数据库，请检查连接信息"
    exit 1
fi

echo "✅ MySQL连接成功"

# 删除并重新创建数据库
echo "正在删除现有数据库..."
mysql -h $DB_HOST -P $DB_PORT -u $DB_ROOT_USER -p$DB_ROOT_PASSWORD -e "DROP DATABASE IF EXISTS $DB_NAME;"

echo "正在重新创建数据库..."
mysql -h $DB_HOST -P $DB_PORT -u $DB_ROOT_USER -p$DB_ROOT_PASSWORD -e "CREATE DATABASE $DB_NAME DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

if [ $? -eq 0 ]; then
    echo "✅ 数据库重新创建成功"
else
    echo "❌ 数据库重新创建失败"
    exit 1
fi

# 执行初始化SQL脚本
echo "正在执行数据库初始化脚本..."
mysql -h $DB_HOST -P $DB_PORT -u $DB_ROOT_USER -p$DB_ROOT_PASSWORD $DB_NAME < init-safe.sql

if [ $? -eq 0 ]; then
    echo "✅ 数据库初始化成功"
else
    echo "❌ 数据库初始化失败"
    exit 1
fi

# 验证数据
echo "正在验证数据..."
USER_COUNT=$(mysql -h $DB_HOST -P $DB_PORT -u $DB_ROOT_USER -p$DB_ROOT_PASSWORD $DB_NAME -s -N -e "SELECT COUNT(*) FROM users;")
TAG_COUNT=$(mysql -h $DB_HOST -P $DB_PORT -u $DB_ROOT_USER -p$DB_ROOT_PASSWORD $DB_NAME -s -N -e "SELECT COUNT(*) FROM tags;")

echo "✅ 数据库重置完成！"
echo "  用户表: $USER_COUNT 条记录"
echo "  标签表: $TAG_COUNT 条记录"

echo ""
echo "🎉 数据库重置成功！"
echo ""
echo "数据库信息："
echo "  主机: $DB_HOST:$DB_PORT"
echo "  数据库名: $DB_NAME"
echo "  开发用户: $DB_DEV_USER"
echo "  开发密码: $DB_DEV_PASSWORD"
echo ""
echo "下一步："
echo "1. 启动Spring Boot应用：java -jar BlobBackendService-1.0-SNAPSHOT.jar"
echo "2. 应用将在 http://localhost:8080 启动" 