# 快速参考指南

## 🚀 常用命令

### 开发环境
```bash
# 构建项目
./sh/build.sh

# 测试构建
./sh/test-build.sh

# 启动后端（开发模式）
java -jar build/BlobBackendService-1.0-SNAPSHOT.jar --spring.profiles.active=dev

# 启动前端（开发模式）
cd frontend && npm run dev
```

### 生产环境
```bash
# CentOS环境配置
./sh/centos-setup.sh

# 数据库设置
cd database && ./sh/setup-database.sh

# 项目构建
./sh/build.sh

# 生产环境启动
./sh/start-production.sh
```

### 部署相关
```bash
# 完整部署（包含数据库）
./sh/deploy.sh --server

# 重新构建
./sh/build.sh

# 重启服务
pkill -f BlobBackendService
./sh/start-production.sh
```

## 📁 重要文件位置

### 脚本文件 (`sh/`)
- `build.sh` - 主构建脚本
- `test-build.sh` - 构建测试
- `deploy.sh` - 部署脚本
- `centos-setup.sh` - CentOS环境配置
- `start-production.sh` - 生产环境启动

### 配置文件 (`config/`)
- `nginx.conf.production` - Nginx生产配置
- `nginx.conf.example` - Nginx示例配置

### 数据库文件 (`database/`)
- `init.sql` - 数据库初始化
- `setup-database.sh` - 数据库设置

### 文档文件 (`docs/`)
- `README.md` - 项目说明
- `PROJECT_STRUCTURE.md` - 项目结构
- `DEPLOYMENT_SUMMARY.md` - 部署总结
- `CENTOS_DEPLOYMENT_GUIDE.md` - CentOS部署指南

## 🔧 配置信息

### 数据库配置
- **主机**: localhost:3306
- **数据库**: blob_backend
- **用户**: dev_user
- **密码**: UserPass!456

### 服务端口
- **后端API**: 8080
- **前端开发**: 3000
- **Nginx**: 80

### 构建产物
- **后端JAR**: `build/BlobBackendService-1.0-SNAPSHOT.jar`
- **前端静态**: `build/frontend/`

## 🛠️ 故障排除

### 常见问题
```bash
# 检查服务状态
curl http://localhost:8080/api/health

# 查看日志
tail -f /var/log/blob-backend/app.log

# 检查端口占用
sudo netstat -tlnp | grep :8080

# 检查构建产物
./sh/test-build.sh
```

### 环境检查
```bash
# 检查工具版本
java -version
node --version
yarn --version
mvn --version
mysql --version
nginx -v
```

## 📝 快速部署步骤

### 1. 环境准备
```bash
# 上传项目到服务器
scp -r /path/to/BlobBackend/* user@server:/opt/blob-backend/

# 登录服务器
ssh user@server
cd /opt/blob-backend
```

### 2. 一键配置
```bash
# 运行环境配置脚本
chmod +x sh/centos-setup.sh
./sh/centos-setup.sh
```

### 3. 数据库设置
```bash
# 配置MySQL
sudo mysql_secure_installation

# 创建数据库
mysql -u root -p
CREATE DATABASE blob_backend;
CREATE USER 'dev_user'@'%' IDENTIFIED BY 'UserPass!456';
GRANT ALL PRIVILEGES ON blob_backend.* TO 'dev_user'@'%';
FLUSH PRIVILEGES;
EXIT;

# 初始化数据库
mysql -u root -p blob_backend < database/init.sql
```

### 4. 构建和部署
```bash
# 构建项目
chmod +x sh/build.sh
./sh/build.sh

# 配置Nginx
sudo cp config/nginx.conf.production /etc/nginx/conf.d/blob-backend.conf
sudo nginx -t
sudo systemctl reload nginx

# 启动应用
chmod +x sh/start-production.sh
./sh/start-production.sh
```

## 🎯 验证部署

### 检查服务
```bash
# 后端健康检查
curl http://localhost:8080/api/health

# API测试
curl -X POST http://localhost:8080/api/checkBackend \
  -H "Content-Type: application/json" \
  -d '{"timestamp":"test"}'

# 前端访问（需要配置域名）
curl http://your-domain.com
```

### 查看日志
```bash
# 应用日志
tail -f /var/log/blob-backend/app.log

# Nginx日志
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

---

**提示**: 所有脚本都包含详细的错误检查和提示信息。如遇问题，请查看脚本输出的错误信息。 