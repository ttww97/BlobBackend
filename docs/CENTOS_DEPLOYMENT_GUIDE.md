# CentOS 7 服务器部署指南

## 📋 系统信息
- **操作系统**: CentOS Linux 7 (Core)
- **Java版本**: 24.0.1 (已安装)
- **目标**: 配置完整的构建和部署环境

## 🚀 环境配置步骤

### 1. 系统更新
```bash
# 更新系统包
sudo yum update -y

# 安装基础开发工具
sudo yum groupinstall "Development Tools" -y
sudo yum install wget curl git -y
```

### 2. 安装 Node.js 18.x
```bash
# 下载并安装 Node.js 18.x
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# 验证安装
node --version  # 应该显示 v18.x.x
npm --version   # 应该显示 9.x.x 或更高
```

### 3. 安装 Yarn
```bash
# 启用 Corepack (Node.js 16.10+ 内置)
sudo corepack enable

# 设置 Yarn 版本
sudo corepack prepare yarn@3.6.1 --activate

# 验证安装
yarn --version  # 应该显示 3.6.1
```

### 4. 安装 Maven
```bash
# 下载 Maven 3.9.11
cd /tmp
wget https://archive.apache.org/dist/maven/maven-3/3.9.11/binaries/apache-maven-3.9.11-bin.tar.gz

# 解压到 /opt
sudo tar -xzf apache-maven-3.9.11-bin.tar.gz -C /opt

# 创建软链接
sudo ln -s /opt/apache-maven-3.9.11 /opt/maven

# 配置环境变量
echo 'export M2_HOME=/opt/maven' | sudo tee -a /etc/profile.d/maven.sh
echo 'export PATH=$PATH:$M2_HOME/bin' | sudo tee -a /etc/profile.d/maven.sh

# 重新加载环境变量
source /etc/profile.d/maven.sh

# 验证安装
mvn --version
```

### 5. 安装 MySQL 8.0
```bash
# 下载 MySQL 8.0 仓库
sudo wget https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm

# 安装仓库
sudo rpm -ivh mysql80-community-release-el7-3.noarch.rpm

# 安装 MySQL 服务器
sudo yum install -y mysql-community-server

# 启动 MySQL 服务
sudo systemctl start mysqld
sudo systemctl enable mysqld

# 获取临时密码
sudo grep 'temporary password' /var/log/mysqld.log

# 安全配置
sudo mysql_secure_installation
```

### 6. 配置 MySQL 数据库
```bash
# 登录 MySQL
mysql -u root -p

# 创建数据库和用户
CREATE DATABASE blob_backend DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'dev_user'@'%' IDENTIFIED BY 'UserPass!456';
GRANT ALL PRIVILEGES ON blob_backend.* TO 'dev_user'@'%';
FLUSH PRIVILEGES;
EXIT;

# 执行初始化脚本
mysql -u root -p blob_backend < database/init.sql
```

### 7. 安装 Nginx
```bash
# 安装 EPEL 仓库
sudo yum install -y epel-release

# 安装 Nginx
sudo yum install -y nginx

# 启动 Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# 配置防火墙
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

### 8. 创建应用目录
```bash
# 创建应用目录
sudo mkdir -p /opt/blob-backend
sudo chown $USER:$USER /opt/blob-backend

# 创建日志目录
sudo mkdir -p /var/log/blob-backend
sudo chown $USER:$USER /var/log/blob-backend
```

## 🔧 环境验证

### 验证所有工具安装
```bash
# 检查版本
echo "=== 环境检查 ==="
echo "Java: $(java -version 2>&1 | head -n 1)"
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo "Yarn: $(yarn --version)"
echo "Maven: $(mvn --version | head -n 1)"
echo "MySQL: $(mysql --version)"
echo "Nginx: $(nginx -v 2>&1)"
```

### 验证数据库连接
```bash
# 测试数据库连接
mysql -u dev_user -p -h localhost blob_backend -e "SELECT 1;"
```

## 📦 项目部署

### 1. 上传项目文件
```bash
# 在服务器上创建项目目录
cd /opt/blob-backend

# 上传项目文件 (使用 scp 或其他方式)
# scp -r /path/to/local/BlobBackend/* user@server:/opt/blob-backend/
```

### 2. 构建项目
```bash
# 进入项目目录
cd /opt/blob-backend

# 运行构建脚本
chmod +x build.sh
./build.sh
```

### 3. 配置 Nginx
```bash
# 复制 Nginx 配置
sudo cp nginx.conf.example /etc/nginx/conf.d/blob-backend.conf

# 修改配置中的路径和域名
sudo vi /etc/nginx/conf.d/blob-backend.conf

# 测试配置
sudo nginx -t

# 重启 Nginx
sudo systemctl reload nginx
```

### 4. 启动应用
```bash
# 启动后端服务
nohup java -jar build/BlobBackendService-1.0-SNAPSHOT.jar \
  --spring.profiles.active=prod \
  > /var/log/blob-backend/app.log 2>&1 &

# 检查服务状态
ps aux | grep BlobBackendService
curl http://localhost:8080/api/health
```

## 🛠️ 常用命令

### 服务管理
```bash
# 启动后端服务
java -jar build/BlobBackendService-1.0-SNAPSHOT.jar --spring.profiles.active=prod

# 停止服务
pkill -f BlobBackendService

# 查看日志
tail -f /var/log/blob-backend/app.log

# 重启 Nginx
sudo systemctl reload nginx
```

### 数据库管理
```bash
# 备份数据库
mysqldump -u root -p blob_backend > backup_$(date +%Y%m%d_%H%M%S).sql

# 恢复数据库
mysql -u root -p blob_backend < backup_file.sql
```

## 🔍 故障排除

### 常见问题

1. **Node.js 版本问题**
   ```bash
   # 如果 Node.js 版本不兼容，使用 nvm
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
   source ~/.bashrc
   nvm install 18.20.8
   nvm use 18.20.8
   ```

2. **Yarn 安装失败**
   ```bash
   # 使用 npm 安装 Yarn
   npm install -g yarn@3.6.1
   ```

3. **Maven 下载慢**
   ```bash
   # 配置阿里云镜像
   sudo mkdir -p ~/.m2
   echo '<settings><mirrors><mirror><id>aliyun</id><mirrorOf>central</mirrorOf><name>Aliyun Maven</name><url>https://maven.aliyun.com/repository/central</url></mirror></mirrors></settings>' > ~/.m2/settings.xml
   ```

4. **MySQL 连接失败**
   ```bash
   # 检查 MySQL 服务状态
   sudo systemctl status mysqld
   
   # 检查防火墙
   sudo firewall-cmd --list-all
   ```

5. **端口被占用**
   ```bash
   # 检查端口占用
   sudo netstat -tlnp | grep :8080
   sudo netstat -tlnp | grep :80
   ```

## 📊 性能优化

### 系统优化
```bash
# 增加文件描述符限制
echo '* soft nofile 65536' | sudo tee -a /etc/security/limits.conf
echo '* hard nofile 65536' | sudo tee -a /etc/security/limits.conf

# 优化内核参数
echo 'net.core.somaxconn = 65535' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_max_syn_backlog = 65535' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

### JVM 优化
```bash
# 启动时添加 JVM 参数
java -Xms512m -Xmx2g -XX:+UseG1GC \
  -jar build/BlobBackendService-1.0-SNAPSHOT.jar \
  --spring.profiles.active=prod
```

## 🔒 安全配置

### 防火墙配置
```bash
# 只开放必要端口
sudo firewall-cmd --permanent --remove-port=22/tcp
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
```

### MySQL 安全
```bash
# 删除匿名用户
mysql -u root -p -e "DELETE FROM mysql.user WHERE User='';"

# 删除测试数据库
mysql -u root -p -e "DROP DATABASE IF EXISTS test;"

# 刷新权限
mysql -u root -p -e "FLUSH PRIVILEGES;"
```

## 📝 部署检查清单

- [ ] 系统更新完成
- [ ] Node.js 18.x 安装成功
- [ ] Yarn 3.6.1 安装成功
- [ ] Maven 3.9.11 安装成功
- [ ] MySQL 8.0 安装并配置
- [ ] Nginx 安装并配置
- [ ] 项目文件上传完成
- [ ] 构建脚本运行成功
- [ ] 后端服务启动成功
- [ ] 前端静态文件部署成功
- [ ] Nginx 代理配置正确
- [ ] 防火墙配置完成
- [ ] 数据库连接测试通过
- [ ] API 接口测试通过

---

**注意**: 请根据实际服务器配置调整相关参数，如内存大小、磁盘空间等。 