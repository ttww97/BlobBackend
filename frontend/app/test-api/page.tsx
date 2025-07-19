'use client';

import { useState } from 'react';
import { checkBackend } from '../../lib/api';

export default function TestApiPage() {
  const [result, setResult] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleCheckBackend = async () => {
    setLoading(true);
    setError('');
    setResult('');

    try {
      const response = await checkBackend();
      setResult(response.message);
    } catch (err) {
      setError(err instanceof Error ? err.message : '请求失败');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ padding: '20px', maxWidth: '800px', margin: '0 auto' }}>
      <h1>API 测试页面</h1>
      
      <div style={{ marginBottom: '20px' }}>
        <h2>后端连接测试</h2>
        <button 
          onClick={handleCheckBackend}
          disabled={loading}
          style={{
            padding: '10px 20px',
            backgroundColor: loading ? '#ccc' : '#007bff',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: loading ? 'not-allowed' : 'pointer'
          }}
        >
          {loading ? '请求中...' : '测试后端连接'}
        </button>
      </div>

      {result && (
        <div style={{ 
          padding: '15px', 
          backgroundColor: '#d4edda', 
          border: '1px solid #c3e6cb',
          borderRadius: '4px',
          marginBottom: '20px'
        }}>
          <h3>响应结果:</h3>
          <p>{result}</p>
        </div>
      )}

      {error && (
        <div style={{ 
          padding: '15px', 
          backgroundColor: '#f8d7da', 
          border: '1px solid #f5c6cb',
          borderRadius: '4px',
          marginBottom: '20px'
        }}>
          <h3>错误信息:</h3>
          <p>{error}</p>
        </div>
      )}

      <div style={{ 
        padding: '15px', 
        backgroundColor: '#f8f9fa', 
        border: '1px solid #dee2e6',
        borderRadius: '4px'
      }}>
        <h3>请求信息:</h3>
        <p><strong>方法:</strong> POST</p>
        <p><strong>端点:</strong> /api/checkBackend</p>
        <p><strong>请求体:</strong> 包含时间戳的JSON</p>
        <p><strong>预期响应:</strong> Hello blog</p>
      </div>
    </div>
  );
} 