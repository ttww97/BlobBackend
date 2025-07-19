# 项目结构说明

## 📁 目录结构

```
BlobBackend/
├── src/                          # Spring Boot后端源码
│   └── main/
│       ├── java/org/example/
│       │   ├── controller/       # 控制器层
│       │   ├── service/          # 服务层
│       │   ├── entity/           # 实体类
│       │   ├── mapper/           # MyBatis映射器
│       │   ├── config/           # 配置类
│       │   └── BlobBackendApplication.java
│       └── resources/
│           ├── application.properties      # 主配置
│           ├── application-dev.properties  # 开发环境
│           └── application-prod.properties # 生产环境
├── frontend/                     # Next.js前端项目
│   ├── app/                      # Next.js 13+ App Router
│   ├── components/               # React组件
│   ├── lib/                      # 工具库
│   ├── public/                   # 静态资源
│   ├── package.json              # 前端依赖
│   └── test-api.js               # API测试脚本
├── database/                     # 数据库相关
│   ├── init.sql                  # 数据库初始化脚本
│   └── setup-database.sh         # 数据库设置脚本
├── sh/                           # Shell脚本
│   ├── build.sh                  # 项目构建脚本
│   ├── deploy.sh                 # 部署脚本
│   ├── test-build.sh             # 构建测试脚本
│   ├── centos-setup.sh           # CentOS环境配置
│   └── start-production.sh       # 生产环境启动
├── config/                       # 配置文件
│   ├── nginx.conf.example        # Nginx示例配置
│   └── nginx.conf.production     # Nginx生产配置
├── docs/                         # 文档
│   ├── README.md                 # 项目说明
│   ├── PROJECT_STRUCTURE.md      # 本文档
│   ├── API_TEST_SUMMARY.md       # API测试总结
│   ├── DATABASE_SETUP.md         # 数据库配置
│   ├── CENTOS_DEPLOYMENT_GUIDE.md # CentOS部署指南
│   ├── DEPLOYMENT_SUMMARY.md     # 部署总结
│   └── DEPLOYMENT.md             # 部署指南
├── build/                        # 构建产物（自动生成）
│   ├── BlobBackendService-1.0-SNAPSHOT.jar
│   └── frontend/                 # 前端静态文件
├── target/                       # Maven构建目录（自动生成）
├── pom.xml                       # Maven配置
└── .gitignore                    # Git忽略文件
```

## 🔧 脚本说明

### 构建脚本 (`sh/`)
- **`build.sh`** - 主构建脚本，构建前端和后端
- **`test-build.sh`** - 测试构建产物是否正确
- **`deploy.sh`** - 完整部署脚本（包含数据库设置）
- **`centos-setup.sh`** - CentOS 7环境配置脚本
- **`start-production.sh`** - 生产环境启动脚本

### 数据库脚本 (`database/`)
- **`init.sql`** - 数据库表结构和初始数据
- **`setup-database.sh`** - 自动数据库设置脚本

### 配置文件 (`config/`)
- **`nginx.conf.example`** - Nginx配置示例
- **`nginx.conf.production`** - Nginx生产环境配置

## 📚 文档说明 (`docs/`)

### 核心文档
- **`README.md`** - 项目总览和快速开始
- **`PROJECT_STRUCTURE.md`** - 项目结构说明（本文档）

### 部署文档
- **`CENTOS_DEPLOYMENT_GUIDE.md`** - CentOS 7详细部署指南
- **`DEPLOYMENT_SUMMARY.md`** - 部署流程总结
- **`DEPLOYMENT.md`** - 通用部署指南

### 技术文档
- **`API_TEST_SUMMARY.md`** - API功能测试说明
- **`DATABASE_SETUP.md`** - 数据库配置详细说明

## 🚀 使用流程

### 开发环境
1. **构建项目**: `./sh/build.sh`
2. **测试构建**: `./sh/test-build.sh`
3. **启动后端**: `java -jar build/BlobBackendService-1.0-SNAPSHOT.jar --spring.profiles.active=dev`
4. **启动前端**: `cd frontend && npm run dev`

### 生产环境
1. **环境配置**: `./sh/centos-setup.sh`
2. **数据库设置**: `cd database && ./sh/setup-database.sh`
3. **项目构建**: `./sh/build.sh`
4. **Nginx配置**: 复制 `config/nginx.conf.production`
5. **启动应用**: `./sh/start-production.sh`

## 📝 注意事项

### 脚本路径
- 所有脚本都使用相对路径，会自动定位到项目根目录
- 脚本可以在任何目录下运行，会自动切换到项目根目录

### 配置文件
- 开发环境使用 `application-dev.properties`
- 生产环境使用 `application-prod.properties`
- Nginx配置需要根据实际域名修改

### 构建产物
- 后端JAR包: `build/BlobBackendService-1.0-SNAPSHOT.jar`
- 前端静态文件: `build/frontend/`
- 构建产物会在 `build/` 目录下

## 🔍 常见操作

### 查看项目状态
```bash
# 检查构建产物
./sh/test-build.sh

# 检查服务状态
curl http://localhost:8080/api/health

# 查看日志
tail -f /var/log/blob-backend/app.log
```

### 重新构建
```bash
# 清理并重新构建
./sh/build.sh

# 仅测试构建
./sh/test-build.sh
```

### 部署更新
```bash
# 停止服务
pkill -f BlobBackendService

# 重新构建
./sh/build.sh

# 启动服务
./sh/start-production.sh
```

---

**提示**: 所有脚本都包含了详细的错误检查和提示信息，如果遇到问题请查看脚本输出的错误信息。 