# 后端API部署指南

## 📋 概述

本指南提供两种部署方式：
1. **本地开发环境** - 用于开发和调试
2. **服务器生产环境** - 用于生产部署

## 🏠 本地开发部署

### 环境要求
- Java 17+
- Maven 3.6+
- MySQL（可选，默认使用H2内存数据库）

### 快速启动

```bash
# 1. 给脚本执行权限
chmod +x sh/*.sh

# 2. 启动本地开发服务器
./sh/local-dev.sh
```

### 手动启动

```bash
# 1. 编译项目
mvn clean compile

# 2. 启动开发服务器
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

### 本地测试

```bash
# 测试API接口
./sh/test-api.sh

# 或手动测试
curl http://localhost:8080/api/health
curl -X POST http://localhost:8080/api/checkBackend
```

### 开发环境特性
- **H2内存数据库** - 无需配置MySQL
- **热重载** - 修改代码后自动重启
- **详细日志** - 便于调试
- **H2控制台** - http://localhost:8080/h2-console

## 🖥️ 服务器生产部署

### 环境要求
- CentOS 7+
- Java 17+
- Maven 3.6+
- MySQL 5.7+

### 快速部署

```bash
# 1. 解压项目文件
unzip BlobBackend.zip
cd BlobBackend

# 2. 给脚本执行权限
chmod +x sh/*.sh

# 3. 部署到服务器
./sh/server-deploy.sh --server
```

### 手动部署

```bash
# 1. 构建项目
mvn clean package -DskipTests

# 2. 配置数据库
cd database
./setup-database.sh
cd ..

# 3. 启动服务
nohup java -Xms512m -Xmx1g \
  -Dspring.profiles.active=prod \
  -jar target/BlobBackendService-1.0-SNAPSHOT.jar \
  > logs/app.log 2>&1 &
```

### 服务器测试

```bash
# 测试本地API
./sh/test-api.sh

# 测试远程API（替换为你的服务器IP）
./sh/test-api.sh http://your-server-ip:8080
```

## 🔧 配置说明

### 开发环境配置 (`application-dev.properties`)
```properties
# H2内存数据库
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.username=sa
spring.datasource.password=

# 详细日志
logging.level.org.example=DEBUG

# CORS支持
spring.web.cors.allowed-origins=*
```

### 生产环境配置 (`application-prod.properties`)
```properties
# MySQL数据库
spring.datasource.url=jdbc:mysql://localhost:3306/blob_backend
spring.datasource.username=dev_user
spring.datasource.password=UserPass!456

# 生产日志
logging.level.org.example=INFO

# 性能优化
spring.jpa.hibernate.ddl-auto=validate
```

## 📡 API接口

### 健康检查
```http
GET /api/health
```

### 测试接口
```http
POST /api/checkBackend
Content-Type: application/json

Response: {"message": "Hello blog"}
```

## 🛠️ 常用命令

### 服务管理
```bash
# 启动服务
./sh/local-dev.sh                    # 本地开发
./sh/server-deploy.sh --server       # 服务器部署

# 停止服务
pkill -f BlobBackendService

# 查看日志
tail -f logs/app.log                 # 服务器
# 控制台直接显示                    # 本地开发
```

### 测试API
```bash
# 本地测试
./sh/test-api.sh

# 远程测试
./sh/test-api.sh http://your-server-ip:8080

# 手动测试
curl http://localhost:8080/api/health
curl -X POST http://localhost:8080/api/checkBackend
```

### 构建和部署
```bash
# 构建项目
mvn clean package

# 运行测试
mvn test

# 跳过测试构建
mvn clean package -DskipTests
```

## 🔍 故障排除

### 常见问题

#### 1. 端口被占用
```bash
# 检查端口占用
netstat -tlnp | grep :8080

# 停止占用进程
pkill -f BlobBackendService
```

#### 2. 数据库连接失败
```bash
# 检查MySQL服务
systemctl status mysql

# 检查数据库配置
cat src/main/resources/application-prod.properties
```

#### 3. 内存不足
```bash
# 调整JVM参数
java -Xms256m -Xmx512m -jar target/BlobBackendService-1.0-SNAPSHOT.jar
```

#### 4. 权限问题
```bash
# 给脚本执行权限
chmod +x sh/*.sh
chmod +x database/*.sh
```

### 日志分析
```bash
# 查看错误日志
grep ERROR logs/app.log

# 查看启动日志
grep "Started" logs/app.log

# 实时监控日志
tail -f logs/app.log
```

## 📊 监控和维护

### 健康检查
```bash
# 检查服务状态
curl http://localhost:8080/api/health

# 检查进程
ps aux | grep BlobBackendService
```

### 性能监控
```bash
# 查看内存使用
jstat -gc <pid>

# 查看线程状态
jstack <pid>
```

### 备份和恢复
```bash
# 备份数据库
mysqldump -u dev_user -p blob_backend > backup.sql

# 恢复数据库
mysql -u dev_user -p blob_backend < backup.sql
```

## 🚀 扩展功能

### 添加新API接口
1. 在 `src/main/java/org/example/controller/` 创建新的Controller
2. 添加相应的Service和Mapper
3. 更新API测试脚本

### 配置Nginx代理
```nginx
location /api/ {
    proxy_pass http://localhost:8080;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```

### 设置SSL证书
```bash
# 使用Let's Encrypt
certbot --nginx -d your-domain.com
```

---

**提示**: 本地开发时建议使用H2内存数据库，服务器部署时使用MySQL生产数据库。 