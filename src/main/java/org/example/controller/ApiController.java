package org.example.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*") // 允许跨域请求
public class ApiController {

    /**
     * 检查后端连接
     * POST /api/checkBackend
     */
    @PostMapping("/checkBackend")
    public ResponseEntity<Map<String, Object>> checkBackend(@RequestBody(required = false) Map<String, Object> requestBody) {
        Map<String, Object> response = new HashMap<>();
        
        response.put("message", "Hello blog");
        response.put("timestamp", LocalDateTime.now().toString());
        response.put("status", "success");
        
        // 如果有请求体，也返回请求体信息
        if (requestBody != null) {
            response.put("receivedData", requestBody);
        }
        
        return ResponseEntity.ok(response);
    }

    /**
     * 健康检查接口
     * GET /api/health
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("timestamp", LocalDateTime.now().toString());
        response.put("service", "BlobBackend");
        return ResponseEntity.ok(response);
    }
} 