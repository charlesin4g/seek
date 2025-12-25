package com.charles.seek.controller;

import com.charles.seek.dto.rustfs.PresignUploadResponse;
import com.charles.seek.service.RustFsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.Duration;

@RestController
@RequestMapping("/api/rustfs")
@RequiredArgsConstructor
@Validated
public class RustFsController {

    private final RustFsService rustFsService;

    /**
     * 为前端生成上传 RustFS 的预签名 URL。
     * 前端拿到该 URL 后，在有效期内可以直接对 RustFS 发起 HTTP PUT 上传。
     */
    @GetMapping("/presign-upload")
    public ResponseEntity<PresignUploadResponse> generatePresignedUploadUrl(
            @RequestParam("objectKey") String objectKey,
            @RequestParam(value = "ttlSeconds", required = false, defaultValue = "900") long ttlSeconds,
            @RequestParam(value = "contentType", required = false, defaultValue = "image/jpeg") String contentType
    ) {
        if (objectKey == null || objectKey.isBlank()) {
            return ResponseEntity.badRequest().build();
        }

        // 为避免滥用，这里对有效期做一个上限控制，例如最多 1 小时
        long safeTtl = Math.min(ttlSeconds, 3600L);

        try {
            String url = rustFsService.generatePresignedPutUrl(objectKey, Duration.ofSeconds(safeTtl));
            PresignUploadResponse body = new PresignUploadResponse(url, contentType);
            return ResponseEntity.ok(body);
        } catch (IllegalStateException e) {
            // RustFS 未启用或配置不完整
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).build();
        } catch (Exception e) {
            // 兜底异常处理，避免把详细错误暴露给前端
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
