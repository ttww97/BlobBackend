# 多阶段构建 - 前端构建阶段
FROM node:18-alpine AS frontend-builder

WORKDIR /app/frontend

# 复制前端依赖文件
COPY frontend/package*.json ./
COPY frontend/yarn.lock ./

# 安装依赖
RUN yarn install --frozen-lockfile

# 复制前端源代码
COPY frontend/ ./

# 构建前端
RUN yarn build

# 后端构建阶段
FROM maven:3.9.11-openjdk-17 AS backend-builder

WORKDIR /app

# 复制后端源代码
COPY src/ ./src/
COPY pom.xml ./

# 构建后端
RUN mvn clean package -DskipTests

# 最终运行阶段
FROM openjdk:17-jre-alpine

# 安装nginx和必要的工具
RUN apk add --no-cache nginx curl

# 创建应用目录和用户
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

WORKDIR /app

# 复制前端构建产物
COPY --from=frontend-builder /app/frontend/.next /app/frontend/.next
COPY --from=frontend-builder /app/frontend/public /app/frontend/public

# 复制后端JAR包
COPY --from=backend-builder /app/target/*.jar app.jar

# 复制nginx配置
COPY config/nginx.conf.example /etc/nginx/http.d/default.conf

# 创建启动脚本
RUN echo '#!/bin/sh' > /app/start.sh && \
    echo 'echo "Starting nginx..."' >> /app/start.sh && \
    echo 'nginx' >> /app/start.sh && \
    echo 'echo "Starting Spring Boot application..."' >> /app/start.sh && \
    echo 'java -Xms512m -Xmx1g -jar app.jar --spring.profiles.active=prod' >> /app/start.sh && \
    chmod +x /app/start.sh

# 设置权限
RUN chown -R appuser:appgroup /app /var/lib/nginx /var/log/nginx /var/run/nginx

# 切换到非root用户
USER appuser

# 暴露端口
EXPOSE 80 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/health || exit 1

# 启动应用
CMD ["/app/start.sh"] 