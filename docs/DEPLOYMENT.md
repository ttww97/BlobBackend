# 项目部署指南

## 概述

本项目采用前后端分离架构：
- **前端**: Next.js应用，构建为静态文件
- **后端**: Spring Boot应用，打包为可执行JAR文件

## 快速开始

### 1. 构建项目

运行构建脚本：
```bash
./build.sh
```

这将：
- 构建前端Next.js应用
- 构建后端Spring Boot应用
- 生成部署包到 `build/` 目录

### 2. 部署到服务器

#### 后端部署

1. 将 `build/BlobBackendService-1.0-SNAPSHOT.jar` 上传到服务器
2. 确保服务器已安装Java 17+
3. 运行后端服务：
```bash
java -jar BlobBackendService-1.0-SNAPSHOT.jar
```

#### 前端部署

1. 将 `build/frontend/` 目录上传到Web服务器
2. 配置Nginx（参考 `nginx.conf.example`）
3. 重启Nginx服务

## 详细部署步骤

### 环境要求

- **后端**: Java 17+, MySQL 8.0+
- **前端**: Node.js 18+, Yarn
- **Web服务器**: Nginx 1.18+

### 后端配置

1. **数据库配置**
   创建 `application.properties` 文件：
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/your_database
spring.datasource.username=your_username
spring.datasource.password=your_password
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

mybatis.mapper-locations=classpath:mapper/*.xml
mybatis.type-aliases-package=org.example.entity

server.port=8080
```

2. **生产环境运行**
```bash
# 后台运行
nohup java -jar BlobBackendService-1.0-SNAPSHOT.jar > app.log 2>&1 &

# 或使用systemd服务
sudo systemctl start your-app
```

### 前端配置

1. **Nginx配置**
   复制 `nginx.conf.example` 到 `/etc/nginx/sites-available/your-app`
   修改配置中的路径和域名

2. **启用站点**
```bash
sudo ln -s /etc/nginx/sites-available/your-app /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 安全配置

1. **HTTPS配置**
   使用Let's Encrypt获取SSL证书：
```bash
sudo certbot --nginx -d your-domain.com
```

2. **防火墙配置**
```bash
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 22
```

## 监控和维护

### 日志查看
```bash
# 后端日志
tail -f app.log

# Nginx日志
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### 服务管理
```bash
# 重启后端服务
pkill -f BlobBackendService
java -jar BlobBackendService-1.0-SNAPSHOT.jar

# 重启Nginx
sudo systemctl restart nginx
```

## 故障排除

### 常见问题

1. **端口冲突**
   - 检查8080端口是否被占用：`netstat -tulpn | grep 8080`
   - 修改application.properties中的server.port

2. **数据库连接失败**
   - 检查MySQL服务状态：`sudo systemctl status mysql`
   - 验证数据库连接信息

3. **前端无法访问后端API**
   - 检查Nginx配置中的proxy_pass设置
   - 验证后端服务是否正常运行

### 性能优化

1. **JVM调优**
```bash
java -Xms512m -Xmx2g -jar BlobBackendService-1.0-SNAPSHOT.jar
```

2. **Nginx缓存配置**
   参考nginx.conf.example中的缓存设置

## 备份和恢复

### 数据库备份
```bash
mysqldump -u username -p database_name > backup.sql
```

### 应用备份
```bash
tar -czf app-backup.tar.gz /path/to/your/app/
```

## 更新部署

1. 运行构建脚本生成新版本
2. 停止当前服务
3. 备份当前版本
4. 部署新版本
5. 启动服务并验证

```bash
# 更新流程
./build.sh
pkill -f BlobBackendService
cp BlobBackendService-1.0-SNAPSHOT.jar backup/
java -jar BlobBackendService-1.0-SNAPSHOT.jar
``` 