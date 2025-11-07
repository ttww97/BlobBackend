#!/bin/bash

# 获取脚本所在目录的上级目录（项目根目录）
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "开始构建项目..."

# 加载nvm并使用Node.js 18
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use 18

# 检查Node.js是否安装
if ! command -v node &> /dev/null; then
    echo "错误: 未找到Node.js，请先安装Node.js"
    exit 1
fi

# 检查Maven是否安装
if ! command -v mvn &> /dev/null; then
    echo "错误: 未找到Maven，请先安装Maven"
    exit 1
fi

# 创建构建目录
mkdir -p build

echo "1. 构建前端项目..."
cd frontend

# 安装依赖
echo "安装前端依赖..."
npm install

# 构建前端
echo "构建前端..."
npm run build

# 检查构建是否成功
if [ $? -ne 0 ]; then
    echo "前端构建失败"
    exit 1
fi

# 创建前端静态文件目录
mkdir -p ../build/frontend

# 复制构建产物到build目录
cp -r .next/static ../build/frontend/
cp -r .next/server ../build/frontend/
cp -r public ../build/frontend/

echo "前端构建完成"

echo "2. 构建后端项目..."
cd ..

# 清理之前的构建
mvn clean

# 构建后端
echo "构建后端JAR包..."
mvn package -DskipTests

# 检查构建是否成功
if [ $? -ne 0 ]; then
    echo "后端构建失败"
    exit 1
fi

# 复制后端JAR包到build目录（查找 backend 分类器的jar）
if [ -f "target/BlobBackendService-1.0-SNAPSHOT-backend.jar" ]; then
    cp target/BlobBackendService-1.0-SNAPSHOT-backend.jar build/
    echo "✅ 后端JAR包已复制到 build/ 目录"
else
    echo "⚠️  未找到后端JAR包，请检查构建配置"
fi

echo "3. 创建部署包..."
cd build

# 创建部署说明文件
cat > README.md << EOF
# 部署说明

## 后端部署
1. 确保服务器已安装Java 17或更高版本
2. 运行后端服务：
   \`\`\`bash
   java -jar BlobBackendService-1.0-SNAPSHOT-backend.jar
   \`\`\`
3. 后端服务将在 http://localhost:8081 启动

## 前端部署
1. 将frontend目录部署到Web服务器（如Nginx）
2. 配置Nginx代理后端API请求到后端服务
3. 前端静态文件位于frontend目录中

## 生产环境配置
- 修改application.properties中的数据库连接信息
- 配置CORS设置
- 设置适当的安全配置
EOF

echo "构建完成！"
echo "构建产物位于 build/ 目录中"
echo ""
echo "部署步骤："
echo "1. 将 build/BlobBackendService-1.0-SNAPSHOT-backend.jar 部署到服务器并启动（端口 8081）"
echo "2. 将 build/frontend/ 目录部署到Tomcat（端口 8080）或Nginx"
echo "3. 配置Nginx反向代理 /api/ 请求到后端（端口 8081）"
echo "4. 配置防火墙开放 8080 和 8081 端口" 