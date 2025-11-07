// 简单的API测试脚本
// 使用Node.js内置的fetch API

async function testCheckBackend() {
  try {
    console.log('🧪 测试 checkBackend API...');
    
    const response = await fetch('http://localhost:8081/api/checkBackend', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        timestamp: new Date().toISOString()
      })
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    console.log('✅ API调用成功！');
    console.log('📄 响应数据:', JSON.stringify(data, null, 2));
    
    // 验证响应
    if (data.message === 'Hello blog') {
      console.log('✅ 响应验证通过！');
    } else {
      console.log('❌ 响应验证失败！');
    }
    
  } catch (error) {
    console.error('❌ API调用失败:', error.message);
  }
}

async function testHealth() {
  try {
    console.log('\n🏥 测试健康检查API...');
    
    const response = await fetch('http://localhost:8081/api/health');
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    console.log('✅ 健康检查成功！');
    console.log('📄 响应数据:', JSON.stringify(data, null, 2));
    
  } catch (error) {
    console.error('❌ 健康检查失败:', error.message);
  }
}

// 运行测试
async function runTests() {
  console.log('🚀 开始API测试...\n');
  
  await testCheckBackend();
  await testHealth();
  
  console.log('\n🎉 测试完成！');
}

runTests(); 