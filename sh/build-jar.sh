#!/bin/bash

# 构建后端 JAR 包的脚本
# 使用方法: ./sh/build-jar.sh

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "=== 构建后端 JAR 包 ==="

# 检查 Maven
if ! command -v mvn &> /dev/null; then
    echo "❌ 未找到 Maven，请先安装 Maven"
    exit 1
fi

echo "1. 临时修改 pom.xml 中的 tomcat scope..."

# 备份 pom.xml
cp pom.xml pom.xml.backup

# 临时修改 tomcat scope 为 compile（用于生成 jar）
sed -i '' 's/<scope>provided<\/scope>/<scope>compile<\/scope>/g' pom.xml

echo "2. 构建项目（生成 WAR 和 JAR）..."
mvn clean package -DskipTests

echo "3. 使用 Spring Boot Maven Plugin 生成可执行 JAR..."
# 使用 spring-boot-maven-plugin 生成 jar（临时修改 packaging）
mvn spring-boot:repackage \
    -Dspring-boot.repackage.classifier=backend \
    -Dspring-boot.repackage.finalName=BlobBackendService-1.0-SNAPSHOT-backend

# 恢复 pom.xml
mv pom.xml.backup pom.xml

echo "4. 检查生成的 JAR 文件..."
if [ -f "target/BlobBackendService-1.0-SNAPSHOT-backend.jar" ]; then
    echo "✅ 后端 JAR 包生成成功: target/BlobBackendService-1.0-SNAPSHOT-backend.jar"
    ls -lh target/BlobBackendService-1.0-SNAPSHOT-backend.jar
else
    echo "⚠️  未找到后端 JAR 包，请检查构建日志"
fi

echo ""
echo "=== 构建完成 ==="
echo ""
echo "生成的文件："
echo "  WAR 包（前端）: target/BlobBackendService-1.0-SNAPSHOT.war"
echo "  JAR 包（后端）: target/BlobBackendService-1.0-SNAPSHOT-backend.jar"
echo ""
echo "部署说明："
echo "  1. WAR 包部署到 Tomcat（端口 8080）"
echo "  2. JAR 包独立运行（端口 8081）: java -jar target/BlobBackendService-1.0-SNAPSHOT-backend.jar"

