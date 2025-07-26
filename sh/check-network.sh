#!/bin/bash

echo "=== 网络连接检查脚本 ==="
SERVER_IP="101.35.137.86"
SERVER_PORT="8080"

echo "服务器信息："
echo "  IP地址: $SERVER_IP"
echo "  端口: $SERVER_PORT"
echo ""

echo "1. 检查应用是否正在运行..."
if pgrep -f "BlobBackendService" > /dev/null; then
    echo "✅ 应用正在运行"
    echo "   进程ID: $(pgrep -f BlobBackendService)"
else
    echo "❌ 应用未运行"
    echo "   请先启动应用: ./sh/server-deploy.sh --server"
    exit 1
fi

echo ""
echo "2. 检查端口监听状态..."
if netstat -tlnp | grep ":8080" > /dev/null; then
    echo "✅ 端口 8080 正在监听"
    echo "   监听详情:"
    netstat -tlnp | grep ":8080"
else
    echo "❌ 端口 8080 未监听"
    exit 1
fi

echo ""
echo "3. 检查本地访问..."
if curl -s http://localhost:8080/api/health > /dev/null; then
    echo "✅ 本地访问正常"
else
    echo "❌ 本地访问失败"
    exit 1
fi

echo ""
echo "4. 检查防火墙状态..."

# 检查 firewalld
if command -v firewall-cmd &> /dev/null; then
    echo "   检查 firewalld..."
    if systemctl is-active firewalld > /dev/null; then
        echo "   ✅ firewalld 正在运行"
        if firewall-cmd --list-ports | grep "8080" > /dev/null; then
            echo "   ✅ 端口 8080 已在 firewalld 中开放"
        else
            echo "   ❌ 端口 8080 未在 firewalld 中开放"
            echo "   正在开放端口 8080..."
            sudo firewall-cmd --permanent --add-port=8080/tcp
            sudo firewall-cmd --reload
            echo "   ✅ 端口 8080 已开放"
        fi
    else
        echo "   ⚠️  firewalld 未运行"
    fi
fi

# 检查 iptables
if command -v iptables &> /dev/null; then
    echo "   检查 iptables..."
    if iptables -L INPUT -n | grep "8080" > /dev/null; then
        echo "   ✅ 端口 8080 已在 iptables 中开放"
    else
        echo "   ❌ 端口 8080 未在 iptables 中开放"
        echo "   正在开放端口 8080..."
        sudo iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
        echo "   ✅ 端口 8080 已开放"
    fi
fi

echo ""
echo "5. 检查云服务器安全组..."
echo "   ⚠️  请手动检查云服务器控制台的安全组设置："
echo "   - 确保端口 8080 已开放"
echo "   - 确保源地址为 0.0.0.0/0 或特定IP"
echo ""

echo "6. 测试外部访问..."
echo "   从服务器测试外部访问:"
if curl -s --connect-timeout 10 http://$SERVER_IP:8080/api/health > /dev/null; then
    echo "   ✅ 外部访问正常"
else
    echo "   ❌ 外部访问失败"
    echo "   可能的原因："
    echo "   - 云服务器安全组未开放端口 8080"
    echo "   - 防火墙规则配置错误"
    echo "   - 网络配置问题"
fi

echo ""
echo "7. 检查应用绑定地址..."
echo "   检查应用是否绑定到 0.0.0.0:8080"
if netstat -tlnp | grep ":8080" | grep "0.0.0.0" > /dev/null; then
    echo "   ✅ 应用已绑定到 0.0.0.0:8080"
else
    echo "   ❌ 应用未绑定到 0.0.0.0:8080"
    echo "   请检查 application-prod.properties 中的配置："
    echo "   server.address=0.0.0.0"
fi

echo ""
echo "🎉 网络检查完成！"
echo ""
echo "📋 如果外部访问仍然失败，请检查："
echo "1. 云服务器安全组设置"
echo "2. 应用配置文件中的 server.address=0.0.0.0"
echo "3. 防火墙规则"
echo ""
echo "🔧 手动测试命令："
echo "   curl http://$SERVER_IP:8080/api/health"
echo "   telnet $SERVER_IP 8080" 