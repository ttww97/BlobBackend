# CentOS 7 服务器部署总结

## 📋 项目概述

**BlobBackend** 是一个前后端分离的博客系统，包含：
- **后端**: Spring Boot + MyBatis + MySQL
- **前端**: Next.js + React + TypeScript
- **部署**: CentOS 7 + Nginx + Java 24

## 🎯 部署目标

在 CentOS 7 服务器上配置完整的构建和部署环境，使 `build.sh` 脚本能够正常运行。

## 📦 环境要求

### 系统环境
- **操作系统**: CentOS Linux 7 (Core)
- **Java版本**: 24.0.1 (已安装)
- **内存**: 建议 2GB+
- **磁盘**: 建议 10GB+ 可用空间

### 需要安装的组件
- **Node.js**: 18.x
- **npm**: 9.x+
- **Yarn**: 3.6.1
- **Maven**: 3.9.11
- **MySQL**: 8.0
- **Nginx**: 最新版本

## 🚀 快速部署步骤

### 第一步：环境配置
```bash
# 1. 上传项目文件到服务器
scp -r /path/to/BlobBackend/* user@server:/opt/blob-backend/

# 2. 登录服务器
ssh user@server

# 3. 运行环境配置脚本
cd /opt/blob-backend
chmod +x sh/centos-setup.sh
./sh/centos-setup.sh
```

### 第二步：数据库配置
```bash
# 1. 配置 MySQL 安全设置
sudo mysql_secure_installation

# 2. 创建数据库和用户
mysql -u root -p
CREATE DATABASE blob_backend DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'dev_user'@'%' IDENTIFIED BY 'UserPass!456';
GRANT ALL PRIVILEGES ON blob_backend.* TO 'dev_user'@'%';
FLUSH PRIVILEGES;
EXIT;

# 3. 执行数据库初始化
mysql -u root -p blob_backend < database/init.sql
```

### 第三步：项目构建
```bash
# 1. 进入项目目录
cd /opt/blob-backend

# 2. 运行构建脚本
chmod +x sh/build.sh
./sh/build.sh
```

### 第四步：Nginx配置
```bash
# 1. 复制Nginx配置
sudo cp config/nginx.conf.production /etc/nginx/conf.d/blob-backend.conf

# 2. 修改域名配置
sudo vi /etc/nginx/conf.d/blob-backend.conf
# 将 your-domain.com 替换为实际域名

# 3. 测试并重启Nginx
sudo nginx -t
sudo systemctl reload nginx
```

### 第五步：启动应用
```bash
# 1. 运行生产环境启动脚本
chmod +x sh/start-production.sh
./sh/start-production.sh
```

## 📁 文件结构

```
/opt/blob-backend/
├── frontend/                    # Next.js前端项目
├── src/                         # Spring Boot后端代码
├── database/                    # 数据库脚本
│   ├── init.sql                # 数据库初始化
│   └── setup-database.sh       # 数据库设置脚本
├── build/                       # 构建产物
│   ├── BlobBackendService-1.0-SNAPSHOT.jar
│   └── frontend/               # 前端静态文件
├── sh/build.sh                  # 构建脚本
├── sh/deploy.sh                 # 部署脚本
├── sh/centos-setup.sh          # CentOS环境配置脚本
├── sh/start-production.sh      # 生产环境启动脚本
├── config/nginx.conf.production # Nginx生产配置
└── 各种文档文件
```

## 🔧 配置文件说明

### 数据库配置
- **开发环境**: `src/main/resources/application-dev.properties`
- **生产环境**: `src/main/resources/application-prod.properties`
- **数据库信息**:
  - 主机: localhost:3306
  - 数据库: blob_backend
  - 用户: dev_user
  - 密码: UserPass!456

### Nginx配置
- **文件**: `nginx.conf.production`
- **端口**: 80 (HTTP)
- **前端**: 静态文件服务
- **后端**: API代理到8080端口

## 🛠️ 常用命令

### 服务管理
```bash
# 启动后端服务
java -jar build/BlobBackendService-1.0-SNAPSHOT.jar --spring.profiles.active=prod

# 停止服务
pkill -f BlobBackendService

# 查看日志
tail -f /var/log/blob-backend/app.log

# 检查服务状态
curl http://localhost:8080/api/health
```

### 构建和部署
```bash
# 重新构建
./sh/build.sh

# 重新部署
./sh/start-production.sh

# 查看构建产物
ls -la build/
```

### 数据库管理
```bash
# 备份数据库
mysqldump -u root -p blob_backend > backup_$(date +%Y%m%d_%H%M%S).sql

# 恢复数据库
mysql -u root -p blob_backend < backup_file.sql

# 连接数据库
mysql -u dev_user -p blob_backend
```

## 🔍 故障排除

### 常见问题

1. **构建失败**
   ```bash
   # 检查Node.js版本
   node --version  # 应该是 v18.x.x
   
   # 检查Yarn版本
   yarn --version  # 应该是 3.6.1
   
   # 清理并重新安装依赖
   cd frontend && rm -rf node_modules && yarn install
   ```

2. **数据库连接失败**
   ```bash
   # 检查MySQL服务状态
   sudo systemctl status mysqld
   
   # 检查数据库连接
   mysql -u dev_user -p -h localhost blob_backend -e "SELECT 1;"
   ```

3. **端口被占用**
   ```bash
   # 检查端口占用
   sudo netstat -tlnp | grep :8080
   sudo netstat -tlnp | grep :80
   
   # 杀死占用进程
   sudo kill -9 <PID>
   ```

4. **Nginx配置错误**
   ```bash
   # 测试配置
   sudo nginx -t
   
   # 查看错误日志
   sudo tail -f /var/log/nginx/error.log
   ```

## 📊 性能优化

### JVM优化
```bash
# 生产环境启动参数
java -Xms512m -Xmx2g -XX:+UseG1GC \
  -Dspring.profiles.active=prod \
  -jar build/BlobBackendService-1.0-SNAPSHOT.jar
```

### 系统优化
```bash
# 增加文件描述符限制
echo '* soft nofile 65536' | sudo tee -a /etc/security/limits.conf
echo '* hard nofile 65536' | sudo tee -a /etc/security/limits.conf

# 优化内核参数
echo 'net.core.somaxconn = 65535' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

## 🔒 安全配置

### 防火墙设置
```bash
# 只开放必要端口
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload
```

### MySQL安全
```bash
# 删除匿名用户和测试数据库
mysql -u root -p -e "DELETE FROM mysql.user WHERE User='';"
mysql -u root -p -e "DROP DATABASE IF EXISTS test;"
mysql -u root -p -e "FLUSH PRIVILEGES;"
```

## 📝 部署检查清单

### 环境配置
- [ ] CentOS 7 系统更新完成
- [ ] Node.js 18.x 安装成功
- [ ] Yarn 3.6.1 安装成功
- [ ] Maven 3.9.11 安装成功
- [ ] MySQL 8.0 安装并配置
- [ ] Nginx 安装并配置

### 项目部署
- [ ] 项目文件上传到 `/opt/blob-backend`
- [ ] 数据库创建和初始化完成
- [ ] `build.sh` 脚本运行成功
- [ ] 后端JAR包生成成功
- [ ] 前端静态文件生成成功

### 服务启动
- [ ] 后端服务启动成功
- [ ] API接口测试通过
- [ ] Nginx配置正确
- [ ] 前端访问正常
- [ ] 日志记录正常

### 安全配置
- [ ] 防火墙配置完成
- [ ] MySQL安全设置完成
- [ ] 敏感文件访问限制
- [ ] 日志文件权限正确

## 🎉 部署完成

部署完成后，您可以通过以下方式访问：

- **前端**: http://your-domain.com (需要配置域名)
- **后端API**: http://your-domain.com/api/
- **健康检查**: http://your-domain.com/health

## 📚 相关文档

- [CentOS部署指南](CENTOS_DEPLOYMENT_GUIDE.md) - 详细的环境配置说明
- [数据库配置](DATABASE_SETUP.md) - 数据库设置和配置
- [API测试总结](API_TEST_SUMMARY.md) - API功能测试说明

---

**注意**: 请根据实际服务器配置调整相关参数，如内存大小、域名等。 