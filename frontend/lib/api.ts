// API请求基础配置 - 后端独立运行在 8081 端口
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8081';

// 通用请求函数
async function apiRequest<T>(
  endpoint: string,
  options: RequestInit = {}
): Promise<T> {
  const url = `${API_BASE_URL}${endpoint}`;
  
  const defaultOptions: RequestInit = {
    headers: {
      'Content-Type': 'application/json',
      ...options.headers,
    },
    ...options,
  };

  try {
    const response = await fetch(url, defaultOptions);
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    return await response.json();
  } catch (error) {
    console.error('API request failed:', error);
    throw error;
  }
}

// 检查后端连接
export async function checkBackend(): Promise<{ message: string }> {
  return apiRequest<{ message: string }>('/api/checkBackend', {
    method: 'POST',
    body: JSON.stringify({ timestamp: new Date().toISOString() }),
  });
}

// 其他API函数可以在这里添加
export const api = {
  checkBackend,
}; 