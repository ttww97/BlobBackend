# GitHub Actions 工作流说明

## 工作流文件

### `deploy.yml`（推荐用于简单部署）
用于构建和部署前后端分离架构的完整工作流。
- 使用 `nohup` 后台运行后端服务
- 适合快速部署和测试

### `deploy-systemd.yml`（推荐用于生产环境）
使用 systemd 管理后端服务的工作流。
- 使用 systemd 管理后端服务
- 支持自动重启和开机自启
- 更好的日志管理和服务监控
- 适合生产环境

## 功能说明

### 1. 构建阶段（Build Job）
- 构建前端和后端项目
- 生成 WAR 包（用于前端部署到 Tomcat）
- 生成 JAR 包（用于后端独立运行）
- 上传构建产物

### 2. 部署阶段（Deploy Job）
- 部署后端 JAR 包到服务器（端口 8081）
- 部署前端 WAR 包到 Tomcat（端口 8080）
- 验证部署状态

## 配置要求

### GitHub Secrets 配置

在 GitHub 仓库设置中添加以下 Secrets：

1. **SERVER_HOST**: 服务器 IP 地址或域名
   ```
   例如: 101.35.137.86
   ```

2. **SERVER_USER**: SSH 用户名
   ```
   例如: root 或 deploy
   ```

3. **SERVER_SSH_KEY**: SSH 私钥
   ```
   完整的 SSH 私钥内容（包括 -----BEGIN RSA PRIVATE KEY----- 和 -----END RSA PRIVATE KEY-----）
   ```

4. **SERVER_PORT** (可选): SSH 端口
   ```
   默认: 22
   ```

### 服务器配置要求

1. **Java 17+**: 用于运行后端 JAR 包
2. **Tomcat**: 用于部署前端 WAR 包（端口 8080）
3. **防火墙**: 开放 8080 和 8081 端口
4. **目录结构**:
   ```
   /opt/blob-backend/
   ├── deploy/          # 部署文件目录
   └── logs/            # 日志目录
   ```

## 使用说明

### 选择工作流
- **开发/测试环境**: 使用 `deploy.yml`（简单快速）
- **生产环境**: 使用 `deploy-systemd.yml`（稳定可靠）

### 自动触发
- 推送到 `main` 或 `master` 分支时自动触发

### 手动触发
- 在 GitHub Actions 页面点击 "Run workflow" 手动触发

### 禁用自动部署
如果只想构建不部署，可以：
1. 删除或注释掉 `deploy` job
2. 或者修改 `if` 条件，只在特定分支触发部署

## 部署流程

1. **构建阶段**:
   - 检出代码
   - 设置 Java 和 Node.js 环境
   - 构建项目（生成 WAR 和 JAR）
   - 验证构建产物
   - 上传构建产物

2. **部署阶段**:
   - 下载构建产物
   - 上传到服务器
   - 停止旧的后端服务
   - 启动新的后端服务（端口 8081）
   - 部署前端 WAR 包到 Tomcat（端口 8080）
   - 验证部署状态

## 注意事项

1. **端口配置**:
   - 前端: 8080（Tomcat）
   - 后端: 8081（独立运行）

2. **Tomcat 配置**:
   - 需要根据实际 Tomcat 安装路径修改 `TOMCAT_WEBAPPS` 变量
   - 可能需要配置 Tomcat 自动部署

3. **服务管理**:
   - 后端服务使用 `nohup` 后台运行
   - 建议使用 systemd 管理后端服务（可选）

4. **日志查看**:
   - `deploy.yml`: `tail -f /opt/blob-backend/logs/app.log`
   - `deploy-systemd.yml`: `sudo journalctl -u blob-backend -f`

5. **服务管理**（仅 `deploy-systemd.yml`）:
   ```bash
   # 查看状态
   sudo systemctl status blob-backend
   
   # 重启服务
   sudo systemctl restart blob-backend
   
   # 停止服务
   sudo systemctl stop blob-backend
   
   # 查看日志
   sudo journalctl -u blob-backend -f
   ```

## 故障排查

### 后端服务启动失败
1. 检查 Java 版本: `java -version`
2. 查看日志: `tail -20 /opt/blob-backend/logs/app.log`
3. 检查端口占用: `netstat -tlnp | grep 8081`

### 前端部署失败
1. 检查 Tomcat 状态: `systemctl status tomcat`
2. 检查 Tomcat 日志: `tail -f /opt/tomcat/logs/catalina.out`
3. 检查 WAR 包权限: `ls -l /opt/tomcat/webapps/ROOT.war`

### SSH 连接失败
1. 检查 SSH 密钥格式
2. 检查服务器防火墙
3. 检查 SSH 服务状态

