#!/bin/bash

echo "=== 数据库初始化脚本 ==="

# 数据库连接信息
DB_HOST="localhost"
DB_PORT="3306"
DB_ROOT_USER="root"
DB_ROOT_PASSWORD="D1gwzdsjq!!!"
DB_DEV_USER="dev_user"
DB_DEV_PASSWORD="UserPass!456"
DB_NAME="blob_backend"

echo "正在连接到MySQL数据库..."

# 检查MySQL连接
if ! mysql -h $DB_HOST -P $DB_PORT -u $DB_ROOT_USER -p$DB_ROOT_PASSWORD -e "SELECT 1;" > /dev/null 2>&1; then
    echo "❌ 无法连接到MySQL数据库，请检查连接信息"
    exit 1
fi

echo "✅ MySQL连接成功"

# 创建开发用户（如果不存在）
echo "正在创建开发用户..."
mysql -h $DB_HOST -P $DB_PORT -u $DB_ROOT_USER -p$DB_ROOT_PASSWORD << EOF
CREATE USER IF NOT EXISTS '$DB_DEV_USER'@'%' IDENTIFIED BY '$DB_DEV_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_DEV_USER'@'%';
FLUSH PRIVILEGES;
EOF

if [ $? -eq 0 ]; then
    echo "✅ 开发用户创建成功"
else
    echo "❌ 开发用户创建失败"
    exit 1
fi

# 创建数据库
echo "正在创建数据库..."
mysql -h $DB_HOST -P $DB_PORT -u $DB_ROOT_USER -p$DB_ROOT_PASSWORD << EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EOF

if [ $? -eq 0 ]; then
    echo "✅ 数据库创建成功"
else
    echo "❌ 数据库创建失败"
    exit 1
fi

# 执行初始化SQL脚本
echo "正在执行数据库初始化脚本..."
mysql -h $DB_HOST -P $DB_PORT -u $DB_ROOT_USER -p$DB_ROOT_PASSWORD $DB_NAME < init-safe.sql

if [ $? -eq 0 ]; then
    echo "✅ 数据库初始化成功"
else
    echo "⚠️  数据库初始化过程中出现警告，继续检查..."
    # 检查是否至少有一些数据被插入
    USER_COUNT=$(mysql -h $DB_HOST -P $DB_PORT -u $DB_ROOT_USER -p$DB_ROOT_PASSWORD $DB_NAME -s -N -e "SELECT COUNT(*) FROM users;")
    if [ "$USER_COUNT" -gt 0 ]; then
        echo "✅ 数据库初始化完成，用户表中有 $USER_COUNT 条记录"
    else
        echo "❌ 数据库初始化失败，用户表中没有数据"
        exit 1
    fi
fi

# 测试开发用户连接
echo "正在测试开发用户连接..."
if mysql -h $DB_HOST -P $DB_PORT -u $DB_DEV_USER -p$DB_DEV_PASSWORD $DB_NAME -e "SELECT COUNT(*) FROM users;" > /dev/null 2>&1; then
    echo "✅ 开发用户连接测试成功"
else
    echo "❌ 开发用户连接测试失败"
    exit 1
fi

echo ""
echo "🎉 数据库设置完成！"
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
echo "3. 数据库连接测试将在应用启动时自动执行" 