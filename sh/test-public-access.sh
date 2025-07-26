#!/bin/bash

echo "=== 公网访问测试脚本 ==="
SERVER_IP="101.35.137.86"
SERVER_PORT="8080"
BASE_URL="http://$SERVER_IP:$SERVER_PORT"

echo "服务器信息："
echo "  IP地址: $SERVER_IP"
echo "  端口: $SERVER_PORT"
echo "  基础URL: $BASE_URL"
echo ""

echo "1. 测试服务器连通性..."
if ping -c 3 $SERVER_IP > /dev/null 2>&1; then
    echo "✅ 服务器连通性正常"
else
    echo "❌ 服务器连通性失败"
    echo "   请检查服务器是否在线"
    exit 1
fi

echo ""
echo "2. 测试端口连通性..."
if nc -z $SERVER_IP $SERVER_PORT 2>/dev/null; then
    echo "✅ 端口 $SERVER_PORT 连通性正常"
else
    echo "❌ 端口 $SERVER_PORT 连通性失败"
    echo "   可能的原因："
    echo "   - 应用未启动"
    echo "   - 防火墙阻止"
    echo "   - 云服务器安全组未开放端口"
    echo ""
    echo "   建议检查："
    echo "   1. 应用是否运行: ps aux | grep java"
    echo "   2. 端口是否监听: netstat -tlnp | grep :$SERVER_PORT"
    echo "   3. 防火墙配置: sudo ./sh/firewall-setup.sh"
    exit 1
fi

echo ""
echo "3. 测试API接口..."

echo "   3.1 测试健康检查接口..."
response=$(curl -s -w "%{http_code}" "$BASE_URL/api/health")
http_code="${response: -3}"
body="${response%???}"

if [ "$http_code" = "200" ]; then
    echo "   ✅ 健康检查接口正常 (HTTP $http_code)"
    echo "   响应: $body"
else
    echo "   ❌ 健康检查接口失败 (HTTP $http_code)"
    echo "   响应: $body"
fi

echo ""
echo "   3.2 测试checkBackend接口..."
response=$(curl -s -w "%{http_code}" -X POST "$BASE_URL/api/checkBackend")
http_code="${response: -3}"
body="${response%???}"

if [ "$http_code" = "200" ]; then
    echo "   ✅ checkBackend接口正常 (HTTP $http_code)"
    echo "   响应: $body"
else
    echo "   ❌ checkBackend接口失败 (HTTP $http_code)"
    echo "   响应: $body"
fi

echo ""
echo "   3.3 测试用户接口..."
response=$(curl -s -w "%{http_code}" "$BASE_URL/api/users")
http_code="${response: -3}"
body="${response%???}"

if [ "$http_code" = "200" ]; then
    echo "   ✅ 用户接口正常 (HTTP $http_code)"
    echo "   响应: $body"
else
    echo "   ❌ 用户接口失败 (HTTP $http_code)"
    echo "   响应: $body"
fi

echo ""
echo "4. 测试CORS支持..."
response=$(curl -s -w "%{http_code}" -X OPTIONS \
  -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type" \
  "$BASE_URL/api/checkBackend")
http_code="${response: -3}"

if [ "$http_code" = "200" ] || [ "$http_code" = "204" ]; then
    echo "✅ CORS支持正常 (HTTP $http_code)"
else
    echo "⚠️  CORS可能未配置 (HTTP $http_code)"
fi

echo ""
echo "🎉 公网访问测试完成！"
echo ""
echo "📋 测试结果："
echo "   服务器: $SERVER_IP"
echo "   端口: $SERVER_PORT"
echo "   基础URL: $BASE_URL"
echo ""
echo "🌐 可访问的API地址："
echo "   健康检查: $BASE_URL/api/health"
echo "   测试接口: $BASE_URL/api/checkBackend"
echo "   用户接口: $BASE_URL/api/users"
echo ""
echo "🔧 如果测试失败，请检查："
echo "1. 应用是否正在运行"
echo "2. 防火墙是否开放端口 8080"
echo "3. 云服务器安全组是否允许端口 8080"
echo "4. 应用是否配置为监听 0.0.0.0:8080"
echo ""
echo "📱 前端调用示例："
echo "   fetch('$BASE_URL/api/health')"
echo "   fetch('$BASE_URL/api/checkBackend', { method: 'POST' })"
echo "   fetch('$BASE_URL/api/users')" 