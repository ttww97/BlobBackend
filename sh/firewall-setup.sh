#!/bin/bash

echo "=== 防火墙配置脚本 ==="
echo "服务器IP: 101.35.137.86"
echo ""

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    echo "❌ 此脚本需要root权限运行"
    echo "请使用: sudo ./sh/firewall-setup.sh"
    exit 1
fi

echo "1. 检查防火墙状态..."
if command -v firewall-cmd &> /dev/null; then
    echo "✅ 使用 firewalld"
    FIREWALL_TYPE="firewalld"
elif command -v ufw &> /dev/null; then
    echo "✅ 使用 ufw"
    FIREWALL_TYPE="ufw"
elif command -v iptables &> /dev/null; then
    echo "✅ 使用 iptables"
    FIREWALL_TYPE="iptables"
else
    echo "⚠️  未检测到防火墙，跳过防火墙配置"
    FIREWALL_TYPE="none"
fi

echo ""

if [ "$FIREWALL_TYPE" = "firewalld" ]; then
    echo "2. 配置 firewalld..."
    echo "   - 启动 firewalld 服务"
    systemctl start firewalld
    systemctl enable firewalld
    
    echo "   - 开放端口 8080"
    firewall-cmd --permanent --add-port=8080/tcp
    
    echo "   - 开放端口 22 (SSH)"
    firewall-cmd --permanent --add-port=22/tcp
    
    echo "   - 开放端口 80 (HTTP)"
    firewall-cmd --permanent --add-port=80/tcp
    
    echo "   - 开放端口 443 (HTTPS)"
    firewall-cmd --permanent --add-port=443/tcp
    
    echo "   - 重新加载防火墙规则"
    firewall-cmd --reload
    
    echo "   - 查看开放的端口"
    firewall-cmd --list-ports

elif [ "$FIREWALL_TYPE" = "ufw" ]; then
    echo "2. 配置 ufw..."
    echo "   - 开放端口 8080"
    ufw allow 8080/tcp
    
    echo "   - 开放端口 22 (SSH)"
    ufw allow 22/tcp
    
    echo "   - 开放端口 80 (HTTP)"
    ufw allow 80/tcp
    
    echo "   - 开放端口 443 (HTTPS)"
    ufw allow 443/tcp
    
    echo "   - 启用防火墙"
    ufw --force enable
    
    echo "   - 查看防火墙状态"
    ufw status

elif [ "$FIREWALL_TYPE" = "iptables" ]; then
    echo "2. 配置 iptables..."
    echo "   - 开放端口 8080"
    iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
    
    echo "   - 开放端口 22 (SSH)"
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    
    echo "   - 开放端口 80 (HTTP)"
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    
    echo "   - 开放端口 443 (HTTPS)"
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT
    
    echo "   - 保存 iptables 规则"
    if command -v iptables-save &> /dev/null; then
        iptables-save > /etc/iptables/rules.v4
    fi
fi

echo ""
echo "3. 检查端口监听状态..."
echo "   检查端口 8080 是否被监听:"
netstat -tlnp | grep :8080 || echo "   ⚠️  端口 8080 未被监听"

echo ""
echo "4. 测试端口连通性..."
echo "   从本地测试端口 8080:"
curl -s http://localhost:8080/api/health > /dev/null && echo "   ✅ 本地访问正常" || echo "   ❌ 本地访问失败"

echo ""
echo "🎉 防火墙配置完成！"
echo ""
echo "📋 配置总结："
echo "   服务器IP: 101.35.137.86"
echo "   应用端口: 8080"
echo "   防火墙类型: $FIREWALL_TYPE"
echo ""
echo "🌐 访问地址："
echo "   http://101.35.137.86:8080"
echo "   http://101.35.137.86:8080/api/health"
echo "   http://101.35.137.86:8080/api/users"
echo ""
echo "🔧 下一步："
echo "1. 确保应用正在运行: ./sh/server-deploy.sh --server"
echo "2. 测试公网访问: curl http://101.35.137.86:8080/api/health"
echo "3. 如果无法访问，检查云服务器安全组设置" 