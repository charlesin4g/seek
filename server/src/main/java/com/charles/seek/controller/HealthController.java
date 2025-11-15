package com.charles.seek.controller;

import com.charles.seek.service.HealthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * 健康检查控制器
 * 仅负责暴露端点，业务逻辑由 {@link HealthService} 处理
 *
 * @author SOLO Coding
 * @since 2025-11-14
 */
@RestController
@RequestMapping("/health")
@RequiredArgsConstructor
@Tag(name = "健康检查", description = "系统健康状态查询")
public class HealthController {

    private final HealthService healthService;

    /**
     * 聚合健康检查
     */
    @GetMapping("/check")
    @Operation(summary = "健康检查", description = "返回数据库、磁盘等健康状态")
    public ResponseEntity<Map<String, Object>> check() {
        Map<String, Object> result = healthService.check();
        return ResponseEntity.ok(result);
    }
}