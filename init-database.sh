#!/bin/bash

echo "=== 初始化外部MySQL数据库 ==="
echo "MySQL服务器: 101.35.137.86:3306"

# 检查mysql客户端是否安装
if ! command -v mysql &> /dev/null; then
    echo "错误: 未找到mysql客户端，请先安装MySQL客户端"
    echo "安装命令: sudo yum install -y mysql"
    exit 1
fi

# 数据库配置
DB_HOST="101.35.137.86"
DB_PORT="3306"
DB_USER="dev_user"
DB_PASS="UserPass!456"
DB_NAME="blob_backend"

echo "连接到MySQL服务器..."
echo "请确保数据库用户有创建数据库的权限"

# 创建数据库
echo "创建数据库 $DB_NAME..."
mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS -e "CREATE DATABASE IF NOT EXISTS $DB_NAME DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

if [ $? -eq 0 ]; then
    echo "✓ 数据库创建成功"
else
    echo "✗ 数据库创建失败"
    exit 1
fi

# 检查数据库是否已经有数据
echo "检查数据库现有数据..."
USER_COUNT=$(mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS -s -N -e "USE $DB_NAME; SELECT COUNT(*) FROM users;" 2>/dev/null || echo "0")

if [ "$USER_COUNT" -gt 0 ]; then
    echo "⚠ 数据库已存在数据，跳过初始化脚本"
    echo "现有用户数量: $USER_COUNT"
else
    echo "执行数据库初始化脚本..."
    mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS $DB_NAME < database/init.sql
    
    if [ $? -eq 0 ]; then
        echo "✓ 数据库初始化成功"
    else
        echo "⚠ 数据库初始化遇到错误，但可能部分成功"
        echo "继续检查数据库状态..."
    fi
fi

# 验证数据库
echo "验证数据库..."
mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS -e "USE $DB_NAME; SHOW TABLES;"

# 显示数据库统计信息
echo "数据库统计信息:"
mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS -e "USE $DB_NAME; SELECT 'users' as table_name, COUNT(*) as count FROM users UNION ALL SELECT 'blog_articles', COUNT(*) FROM blog_articles UNION ALL SELECT 'tags', COUNT(*) FROM tags;" 2>/dev/null || echo "无法获取统计信息"

echo "=== 数据库初始化完成 ==="
echo "数据库: $DB_NAME"
echo "服务器: $DB_HOST:$DB_PORT"
echo "用户: $DB_USER" 