# BlobBackend 项目

一个前后端分离的博客系统，包含Spring Boot后端和Next.js前端。

## 项目结构

```
BlobBackend/
├── frontend/                 # Next.js前端项目
├── src/main/java/           # Spring Boot后端代码
├── src/main/resources/      # 配置文件
├── database/                # 数据库脚本
├── build/                   # 构建产物
├── sh/build.sh              # 构建脚本
├── sh/deploy.sh             # 部署脚本
└── README.md               # 项目说明
```

## 数据库配置

### 连接信息
- **主机**: localhost:3306
- **数据库名**: blob_backend
- **开发用户**: dev_user
- **开发密码**: UserPass!456
- **Root密码**: D1gwzdsjq!!!

### 快速设置

1. **本地开发**：
   ```bash
   # 构建项目
   ./sh/build.sh
   
   # 测试构建
   ./sh/test-build.sh
   ```

2. **服务器部署**：
   ```bash
   # 完整部署（包含数据库设置）
   ./sh/deploy.sh --server
   ```

## 环境要求

- **Java**: 17+
- **Node.js**: 18+
- **MySQL**: 8.0+
- **Maven**: 3.6+

## 快速开始

### 1. 构建项目
```bash
./sh/build.sh
```

### 2. 设置数据库
```bash
cd database
./sh/setup-database.sh
```

### 3. 启动服务
```bash
# 开发环境
java -jar build/BlobBackendService-1.0-SNAPSHOT.jar --spring.profiles.active=dev

# 生产环境
java -jar build/BlobBackendService-1.0-SNAPSHOT.jar --spring.profiles.active=prod
```

## 部署指南

详细部署说明请参考：
- [部署指南](DEPLOYMENT.md)
- [数据库配置](DATABASE_SETUP.md)

## 主要功能

- 用户管理
- 博客文章管理
- 评论系统
- 标签管理
- 前后端分离架构

## 技术栈

### 后端
- Spring Boot 3.4.0
- MyBatis 3.0.3
- MySQL 8.0
- Maven

### 前端
- Next.js 15.2.4
- React 19.0.0
- TypeScript
- Tailwind CSS

## 开发

### 后端开发
```bash
# 启动开发服务器
mvn spring-boot:run
```

### 前端开发
```bash
cd frontend
npm run dev
```

## 监控和维护

### 查看日志
```bash
tail -f app.log
```

### 检查服务状态
```bash
curl http://localhost:8080/actuator/health
```

### 停止服务
```bash
pkill -f BlobBackendService
```

## 许可证

MIT License