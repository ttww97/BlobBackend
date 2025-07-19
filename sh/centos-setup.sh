#!/bin/bash

echo "=== CentOS 7 环境配置脚本 ==="
echo "此脚本将配置完整的构建和部署环境"
echo ""

# 检查是否为root用户
if [[ $EUID -eq 0 ]]; then
   echo "❌ 请不要使用root用户运行此脚本"
   exit 1
fi

# 检查操作系统
if ! grep -q "CentOS Linux 7" /etc/os-release; then
    echo "❌ 此脚本仅适用于 CentOS Linux 7"
    exit 1
fi

echo "✅ 操作系统检查通过"
echo ""

# 1. 系统更新
echo "1. 更新系统包..."
sudo yum update -y

echo "安装基础开发工具..."
sudo yum groupinstall "Development Tools" -y
sudo yum install wget curl git -y

echo "✅ 系统更新完成"
echo ""

# 2. 安装 Node.js 18.x
echo "2. 安装 Node.js 18.x..."
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

echo "验证 Node.js 安装..."
node --version
npm --version

echo "✅ Node.js 安装完成"
echo ""

# 3. 安装 Yarn
echo "3. 安装 Yarn 3.6.1..."
sudo corepack enable
sudo corepack prepare yarn@3.6.1 --activate

echo "验证 Yarn 安装..."
yarn --version

echo "✅ Yarn 安装完成"
echo ""

# 4. 安装 Maven
echo "4. 安装 Maven 3.9.11..."
cd /tmp
wget https://archive.apache.org/dist/maven/maven-3/3.9.11/binaries/apache-maven-3.9.11-bin.tar.gz

sudo tar -xzf apache-maven-3.9.11-bin.tar.gz -C /opt
sudo ln -s /opt/apache-maven-3.9.11 /opt/maven

echo 'export M2_HOME=/opt/maven' | sudo tee -a /etc/profile.d/maven.sh
echo 'export PATH=$PATH:$M2_HOME/bin' | sudo tee -a /etc/profile.d/maven.sh

source /etc/profile.d/maven.sh

echo "验证 Maven 安装..."
mvn --version | head -n 1

echo "✅ Maven 安装完成"
echo ""

# 5. 安装 MySQL 8.0
echo "5. 安装 MySQL 8.0..."
sudo wget https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
sudo rpm -ivh mysql80-community-release-el7-3.noarch.rpm
sudo yum install -y mysql-community-server

sudo systemctl start mysqld
sudo systemctl enable mysqld

echo "MySQL 临时密码:"
sudo grep 'temporary password' /var/log/mysqld.log || echo "未找到临时密码，请手动检查"

echo "✅ MySQL 安装完成"
echo ""

# 6. 安装 Nginx
echo "6. 安装 Nginx..."
sudo yum install -y epel-release
sudo yum install -y nginx

sudo systemctl start nginx
sudo systemctl enable nginx

sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

echo "✅ Nginx 安装完成"
echo ""

# 7. 创建应用目录
echo "7. 创建应用目录..."
sudo mkdir -p /opt/blob-backend
sudo chown $USER:$USER /opt/blob-backend

sudo mkdir -p /var/log/blob-backend
sudo chown $USER:$USER /var/log/blob-backend

echo "✅ 目录创建完成"
echo ""

# 8. 环境验证
echo "8. 验证环境安装..."
echo "=== 环境检查 ==="
echo "Java: $(java -version 2>&1 | head -n 1)"
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo "Yarn: $(yarn --version)"
echo "Maven: $(mvn --version | head -n 1)"
echo "MySQL: $(mysql --version)"
echo "Nginx: $(nginx -v 2>&1)"
echo "=================="
echo ""

# 9. 配置 Maven 镜像（可选）
echo "9. 配置 Maven 阿里云镜像..."
mkdir -p ~/.m2
cat > ~/.m2/settings.xml << 'EOF'
<settings>
  <mirrors>
    <mirror>
      <id>aliyun</id>
      <mirrorOf>central</mirrorOf>
      <name>Aliyun Maven</name>
      <url>https://maven.aliyun.com/repository/central</url>
    </mirror>
  </mirrors>
</settings>
EOF

echo "✅ Maven 镜像配置完成"
echo ""

# 10. 系统优化
echo "10. 系统优化..."
echo '* soft nofile 65536' | sudo tee -a /etc/security/limits.conf
echo '* hard nofile 65536' | sudo tee -a /etc/security/limits.conf

echo 'net.core.somaxconn = 65535' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_max_syn_backlog = 65535' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

echo "✅ 系统优化完成"
echo ""

echo "🎉 环境配置完成！"
echo ""
echo "下一步操作："
echo "1. 配置 MySQL 数据库："
echo "   sudo mysql_secure_installation"
echo "   mysql -u root -p"
echo ""
echo "2. 上传项目文件到 /opt/blob-backend"
echo ""
echo "3. 运行构建脚本："
echo "   cd /opt/blob-backend"
echo "   chmod +x build.sh"
echo "   ./build.sh"
echo ""
echo "4. 配置 Nginx 并启动应用"
echo ""
echo "详细说明请参考：CENTOS_DEPLOYMENT_GUIDE.md" 