#!/bin/bash

# 获取脚本所在目录的上级目录（项目根目录）
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "=== API 测试脚本 ==="

# 默认测试本地
API_BASE="http://localhost:8080"

# 如果提供了参数，使用指定的地址
if [ ! -z "$1" ]; then
    API_BASE="$1"
fi

echo "测试API地址: $API_BASE"
echo ""

# 测试健康检查
echo "1. 测试健康检查..."
echo "   GET $API_BASE/api/health"
response=$(curl -s -w "\n%{http_code}" "$API_BASE/api/health")
http_code=$(echo "$response" | tail -1)
body=$(echo "$response" | head -1)

if [ "$http_code" = "200" ]; then
    echo "   ✅ 健康检查通过"
    echo "   响应: $body"
else
    echo "   ❌ 健康检查失败 (HTTP $http_code)"
    echo "   响应: $body"
fi

echo ""

# 测试checkBackend接口
echo "2. 测试checkBackend接口..."
echo "   POST $API_BASE/api/checkBackend"
response=$(curl -s -w "\n%{http_code}" -X POST "$API_BASE/api/checkBackend")
http_code=$(echo "$response" | tail -1)
body=$(echo "$response" | head -1)

if [ "$http_code" = "200" ]; then
    echo "   ✅ checkBackend接口正常"
    echo "   响应: $body"
else
    echo "   ❌ checkBackend接口失败 (HTTP $http_code)"
    echo "   响应: $body"
fi

echo ""

# 测试CORS
echo "3. 测试CORS支持..."
echo "   OPTIONS $API_BASE/api/checkBackend"
response=$(curl -s -w "\n%{http_code}" -X OPTIONS \
  -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type" \
  "$API_BASE/api/checkBackend")
http_code=$(echo "$response" | tail -1)

if [ "$http_code" = "200" ] || [ "$http_code" = "204" ]; then
    echo "   ✅ CORS支持正常"
else
    echo "   ⚠️  CORS可能未配置 (HTTP $http_code)"
fi

echo ""
echo "=== 测试完成 ==="
echo ""
echo "使用说明："
echo "  本地测试: ./sh/test-api.sh"
echo "  远程测试: ./sh/test-api.sh http://your-server-ip:8080"
echo ""
echo "API文档："
echo "  GET  $API_BASE/api/health          - 健康检查"
echo "  POST $API_BASE/api/checkBackend    - 测试接口" 