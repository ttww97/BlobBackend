#!/bin/bash

echo "=== 公网访问修复脚本 ==="
echo "服务器IP: 101.35.137.86"
echo ""

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    echo "❌ 此脚本需要root权限运行"
    echo "请使用: sudo ./sh/fix-public-access.sh"
    exit 1
fi

echo "1. 停止现有应用..."
pkill -f BlobBackendService || true
sleep 2

echo ""
echo "2. 检查应用配置..."
if grep -q "server.address=0.0.0.0" src/main/resources/application-prod.properties; then
    echo "✅ 应用配置正确 (server.address=0.0.0.0)"
else
    echo "❌ 应用配置错误，正在修复..."
    echo "server.address=0.0.0.0" >> src/main/resources/application-prod.properties
    echo "✅ 应用配置已修复"
fi

echo ""
echo "3. 配置防火墙..."

# 配置 firewalld
if command -v firewall-cmd &> /dev/null; then
    echo "   配置 firewalld..."
    systemctl start firewalld
    systemctl enable firewalld
    firewall-cmd --permanent --add-port=8080/tcp
    firewall-cmd --permanent --add-port=22/tcp
    firewall-cmd --reload
    echo "   ✅ firewalld 配置完成"
fi

# 配置 iptables
if command -v iptables &> /dev/null; then
    echo "   配置 iptables..."
    iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    echo "   ✅ iptables 配置完成"
fi

echo ""
echo "4. 重新启动应用..."
cd /path/to/your/project  # 请替换为实际项目路径
./sh/server-deploy.sh --server

echo ""
echo "5. 等待应用启动..."
sleep 10

echo ""
echo "6. 验证配置..."
echo "   检查端口监听:"
netstat -tlnp | grep ":8080"

echo ""
echo "   测试本地访问:"
if curl -s http://localhost:8080/api/health > /dev/null; then
    echo "   ✅ 本地访问正常"
else
    echo "   ❌ 本地访问失败"
fi

echo ""
echo "   测试外部访问:"
if curl -s --connect-timeout 10 http://101.35.137.86:8080/api/health > /dev/null; then
    echo "   ✅ 外部访问正常"
else
    echo "   ❌ 外部访问失败"
    echo ""
    echo "   🔧 如果外部访问仍然失败，请检查："
    echo "   1. 云服务器安全组设置"
    echo "   2. 确保端口 8080 已开放"
    echo "   3. 确保源地址为 0.0.0.0/0"
fi

echo ""
echo "🎉 修复完成！"
echo ""
echo "📋 如果问题仍然存在，请执行以下步骤："
echo "1. 运行网络检查: ./sh/check-network.sh"
echo "2. 检查云服务器安全组设置"
echo "3. 联系云服务商技术支持"
echo ""
echo "🌐 测试地址："
echo "   http://101.35.137.86:8080/api/health"
echo "   http://101.35.137.86:8080/api/checkBackend"
echo "   http://101.35.137.86:8080/api/users" 