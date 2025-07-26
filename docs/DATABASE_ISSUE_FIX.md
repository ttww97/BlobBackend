# 🔧 数据库问题解决指南

## ❌ 常见问题

### 问题1：重复键错误
```
ERROR 1062 (23000) at line 69: Duplicate entry 'admin' for key 'username'
```

**原因**：数据库初始化脚本尝试插入已存在的数据，导致唯一键冲突。

**解决方案**：
1. 使用 `INSERT IGNORE` 语句（已修复）
2. 使用数据库重置脚本
3. 手动清理重复数据

### 问题2：数据库连接失败
```
❌ 无法连接到MySQL数据库，请检查连接信息
```

**原因**：MySQL服务未启动或连接信息错误。

**解决方案**：
1. 检查MySQL服务状态：`systemctl status mysql`
2. 启动MySQL服务：`systemctl start mysql`
3. 验证连接信息是否正确

## 🛠️ 解决方案

### 方案1：使用修复后的脚本（推荐）

```bash
# 重新运行数据库初始化脚本
cd database
./setup-database.sh
```

**特点**：
- 使用 `INSERT IGNORE` 避免重复键错误
- 自动检查数据是否成功插入
- 提供详细的错误信息

### 方案2：重置数据库（彻底解决）

```bash
# 完全重置数据库
cd database
./reset-database.sh
```

**特点**：
- 删除并重新创建数据库
- 确保干净的数据环境
- 需要确认操作（安全提示）

### 方案3：手动修复

```sql
-- 连接到MySQL
mysql -u root -p

-- 删除重复数据
USE blob_backend;
DELETE FROM users WHERE username IN ('admin', 'test_user');
DELETE FROM tags WHERE name IN ('Java', 'Spring Boot', 'MySQL', '前端', '后端');

-- 重新插入数据
INSERT INTO users (username, password, email, nickname) VALUES 
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'admin@example.com', '管理员'),
('test_user', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'test@example.com', '测试用户');

INSERT INTO tags (name, description) VALUES 
('Java', 'Java编程相关'),
('Spring Boot', 'Spring Boot框架'),
('MySQL', 'MySQL数据库'),
('前端', '前端开发技术'),
('后端', '后端开发技术');
```

## 📋 修复后的文件

### 1. `database/init-safe.sql`
- 使用 `INSERT IGNORE` 避免重复键错误
- 使用 `CREATE INDEX IF NOT EXISTS` 避免索引重复
- 可以安全地重复执行

### 2. `database/setup-database.sh`
- 改进的错误处理
- 自动检查数据插入结果
- 提供详细的执行状态

### 3. `database/reset-database.sh`
- 完全重置数据库的选项
- 安全确认提示
- 数据验证功能

## 🚀 使用步骤

### 快速修复
```bash
# 1. 进入数据库目录
cd database

# 2. 运行修复后的初始化脚本
./setup-database.sh

# 3. 检查结果
mysql -u root -p -e "USE blob_backend; SELECT COUNT(*) FROM users;"
```

### 彻底重置
```bash
# 1. 进入数据库目录
cd database

# 2. 运行重置脚本（会提示确认）
./reset-database.sh

# 3. 输入 'y' 确认重置
```

## 🔍 验证修复

### 检查数据库状态
```bash
# 检查用户表
mysql -u root -p -e "USE blob_backend; SELECT * FROM users;"

# 检查标签表
mysql -u root -p -e "USE blob_backend; SELECT * FROM tags;"

# 检查表结构
mysql -u root -p -e "USE blob_backend; SHOW TABLES;"
```

### 测试应用连接
```bash
# 启动应用
./sh/server-deploy.sh --server

# 测试API
curl http://localhost:8080/api/users
```

## 📝 预防措施

### 1. 使用安全的SQL语句
- 使用 `INSERT IGNORE` 而不是 `INSERT`
- 使用 `CREATE TABLE IF NOT EXISTS`
- 使用 `CREATE INDEX IF NOT EXISTS`

### 2. 改进错误处理
- 检查SQL执行结果
- 提供详细的错误信息
- 自动验证数据完整性

### 3. 提供多种解决方案
- 增量修复（保留现有数据）
- 完全重置（干净环境）
- 手动修复（精确控制）

## 🎯 总结

**问题原因**：数据库初始化脚本没有处理重复数据的情况。

**解决方案**：
1. ✅ 修复了 `init.sql` 使用 `INSERT IGNORE`
2. ✅ 创建了更安全的 `init-safe.sql`
3. ✅ 改进了 `setup-database.sh` 的错误处理
4. ✅ 提供了 `reset-database.sh` 重置选项

**建议**：使用修复后的脚本重新运行数据库初始化，或者使用重置脚本获得干净的环境。

---

**状态**：✅ 问题已修复
**时间**：2025-07-26
**影响**：数据库初始化脚本现在可以安全地重复执行 