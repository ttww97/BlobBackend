#!/bin/bash

echo "使用Docker构建前端..."

# 创建临时Dockerfile用于前端构建
cat > Dockerfile.frontend << EOF
FROM node:18-alpine

WORKDIR /app

# 复制前端文件
COPY frontend/package*.json ./
COPY frontend/yarn.lock ./

# 安装依赖
RUN yarn install --frozen-lockfile

# 复制源代码
COPY frontend/ ./

# 构建
RUN yarn build

# 复制构建产物到宿主机
CMD ["sh", "-c", "cp -r .next /output/ && cp -r public /output/"]
EOF

# 创建输出目录
mkdir -p build/frontend

# 运行Docker构建
docker build -f Dockerfile.frontend -t frontend-builder .
docker run --rm -v $(pwd)/build/frontend:/output frontend-builder

# 清理临时文件
rm Dockerfile.frontend
docker rmi frontend-builder

echo "前端构建完成，文件位于 build/frontend/" 