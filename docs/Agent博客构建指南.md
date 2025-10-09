## 概述

本文档指导如何在本项目中构建一个可扩展智能体/AI 博客网站，采用前端 Vue3、后端 Spring Boot（可打包为 WAR），支持在本地 Tomcat 打开网页以及将 WAR 部署到服务器（CentOS 7）。

## 技术栈与目录

- 后端：Spring Boot 3、MyBatis、MySQL；支持 WAR 部署
- 前端：Vue3 + Vite，使用 `frontend-maven-plugin` 集成到 Maven 构建
- 目录关键位置：
  - `src/main/java`：后端代码
  - `src/main/resources`：配置
  - `frontend/`：Vue3 前端（构建输出到 `frontend/dist`）
  - `docs/Agent博客构建指南.md`：本文档

## 构建产物与运行方式

- Maven 构建会：
  1) 在 `frontend/` 执行 `npm ci && npm run build` 产出 `dist/`
  2) 使用 `maven-war-plugin` 将 `dist/` 内容打包进 WAR 根目录
  3) 生成 `BlobBackendService-1.0-SNAPSHOT.war`

### 本地运行

1. 安装 JDK 17+ 与 Maven 3.6+
2. 运行构建
   ```bash
   mvn -q -DskipTests clean package
   ```
3. 使用本地 Tomcat 部署 WAR（以 Tomcat 9 为例，更兼容 CentOS7）：
   - 将 `target/BlobBackendService-1.0-SNAPSHOT.war` 拷贝到 `${TOMCAT_HOME}/webapps/ROOT.war`
   - 启动 Tomcat：`${TOMCAT_HOME}/bin/startup.sh`
   - 访问 `http://localhost:8080/`

提示：也可通过 `mvn spring-boot:run` 以 JAR 方式开发调试，但部署建议用 WAR。

### 服务器部署（CentOS 7）

1. 准备环境
   - Java 17
   - Tomcat 9.x（推荐 9.0.87-）
   - MySQL 8.0（或兼容版本）
2. 构建并上传 WAR
   ```bash
   mvn -q -DskipTests clean package
   scp target/BlobBackendService-1.0-SNAPSHOT.war user@server:/opt/tomcat/webapps/ROOT.war
   ```
3. 启动/重启 Tomcat
   ```bash
   sudo systemctl restart tomcat
   ```
4. 打开浏览器访问：`http://<server-ip>/`

## 前端说明（Vue3）

- 代码位置：`frontend/`
- 开发调试：
  ```bash
  cd frontend
  npm i
  npm run dev
  ```
- 主要页面：
  - 首页：文章列表 `/`
  - 登录：`/login`
  - 注册：`/register`
  - 文章编辑：`/editor`
- 代理：开发时通过 `vite.config.ts` 将 `/api` 代理到 `http://localhost:8080`

## 后端说明（Spring Boot）

- WAR 支持：`pom.xml` 设置 `<packaging>war</packaging>`，并提供 `org.example.ServletInitializer`
- 外部 Tomcat 部署：`spring-boot-starter-tomcat` 设为 `provided`
- 重要配置：`src/main/resources/application.properties`
  - 数据源、MyBatis、端口、日志等
- 主要 REST 路由（示例）：
  - `GET /api/articles` 获取文章列表
  - `POST /api/articles` 新建/保存文章
  - `POST /api/users/login` 登录
  - `POST /api/users/register` 注册

注意：请根据业务需要完善 Controller、Service、Mapper 与表结构。

## 与 CentOS 7 的兼容性建议

- 使用 Tomcat 9 而非 10（Servlet API 兼容更稳妥）
- 保持 Node 版本在 18 LTS，构建时由 `frontend-maven-plugin` 注入，不污染系统
- MySQL 8.0 如遇到 OpenSSL 兼容问题，可使用 `allowPublicKeyRetrieval=true`

## 常见问题

- 构建找不到 `frontend/dist`：请确保 `frontend` 能成功 `npm ci && npm run build`
- WAR 部署 404：检查是否部署为 `ROOT.war` 或访问路径是否包含上下文路径
- 后端 500：查看 Tomcat `logs/catalina.out` 与应用日志定位

## 变更点摘要

- `pom.xml`：切换 WAR 打包，加入 `frontend-maven-plugin` 与 `maven-war-plugin` 资源拷贝
- `src/main/java/org/example/ServletInitializer.java`：添加 WAR 启动入口
- `frontend/`：新增最小可用 Vue3 工程与基础页面


