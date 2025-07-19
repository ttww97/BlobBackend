# 数据库配置说明

## 数据库信息

根据您提供的服务器数据库信息，已配置以下连接参数：

### 连接信息
- **主机**: localhost:3306
- **数据库名**: blob_backend
- **开发用户**: dev_user
- **开发密码**: UserPass!456
- **Root密码**: D1gwzdsjq!!!

## 配置文件

### 1. 主配置文件
- **文件**: `src/main/resources/application.properties`
- **用途**: 通用配置，包含数据库连接、MyBatis配置等

### 2. 环境配置文件
- **开发环境**: `src/main/resources/application-dev.properties`
- **生产环境**: `src/main/resources/application-prod.properties`

## 数据库初始化

### 自动初始化脚本
运行以下命令在服务器上初始化数据库：

```bash
cd database
./setup-database.sh
```

这个脚本会：
1. 连接到MySQL数据库
2. 创建开发用户（如果不存在）
3. 创建数据库
4. 执行初始化SQL脚本
5. 测试连接

### 手动初始化
如果自动脚本失败，可以手动执行：

```bash
# 1. 连接到MySQL
mysql -u root -p

# 2. 创建数据库和用户
CREATE DATABASE IF NOT EXISTS blob_backend DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'dev_user'@'%' IDENTIFIED BY 'UserPass!456';
GRANT ALL PRIVILEGES ON blob_backend.* TO 'dev_user'@'%';
FLUSH PRIVILEGES;

# 3. 执行初始化脚本
mysql -u root -p blob_backend < database/init.sql
```

## 数据库表结构

### 主要表
1. **users** - 用户表
2. **blog_articles** - 博客文章表
3. **comments** - 评论表
4. **tags** - 标签表
5. **article_tags** - 文章标签关联表

### 测试数据
初始化脚本包含：
- 2个测试用户（admin, test_user）
- 5个常用标签（Java, Spring Boot, MySQL, 前端, 后端）

## 连接测试

### 应用启动时测试
Spring Boot应用启动时会自动测试数据库连接，输出类似：

```
=== 数据库连接测试 ===
✅ 数据库连接成功！
   数据库URL: jdbc:mysql://localhost:3306/blob_backend
   数据库产品: MySQL
   数据库版本: 8.0.xx
   用户名: dev_user@localhost
===================
```

### 手动测试
```bash
# 使用开发用户测试
mysql -u dev_user -p blob_backend -e "SELECT COUNT(*) FROM users;"
```

## 环境切换

### 开发环境
```bash
java -jar BlobBackendService-1.0-SNAPSHOT.jar --spring.profiles.active=dev
```

### 生产环境
```bash
java -jar BlobBackendService-1.0-SNAPSHOT.jar --spring.profiles.active=prod
```

## 故障排除

### 常见问题

1. **连接被拒绝**
   - 检查MySQL服务是否启动
   - 检查端口3306是否开放
   - 检查防火墙设置

2. **认证失败**
   - 确认用户名密码正确
   - 检查用户权限
   - 确认用户可以从应用服务器IP连接

3. **数据库不存在**
   - 运行数据库初始化脚本
   - 手动创建数据库

4. **字符集问题**
   - 确认数据库使用utf8mb4字符集
   - 检查连接URL中的字符集参数

### 日志查看
```bash
# 查看应用日志
tail -f app.log

# 查看MySQL日志
sudo tail -f /var/log/mysql/error.log
```

## 安全建议

1. **生产环境**
   - 使用强密码
   - 限制数据库用户权限
   - 配置防火墙
   - 定期备份

2. **连接安全**
   - 使用SSL连接（如需要）
   - 限制数据库访问IP
   - 定期更新密码

## 备份和恢复

### 备份数据库
```bash
mysqldump -u root -p blob_backend > backup_$(date +%Y%m%d_%H%M%S).sql
```

### 恢复数据库
```bash
mysql -u root -p blob_backend < backup_file.sql
``` 