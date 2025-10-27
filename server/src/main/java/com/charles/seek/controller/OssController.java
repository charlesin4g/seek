package com.charles.seek.controller;

import com.charles.seek.service.OssService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * OSS 控制器
 *
 * 规则：controller 中只调用 service 方法，业务逻辑在 service
 */
@RestController
@RequestMapping("/api/oss")
@RequiredArgsConstructor
@Validated
@Tag(name = "OSS 签名", description = "生成私有资源的临时签名 URL")
public class OssController {

    private final OssService ossService;

    /**
     * 生成 GET 私有签名 URL
     *
     * @param key 对象 key（例如：avatar/abc.png），不接受绝对 URL
     * @param expiresSeconds 过期秒数（可选）
     * @param style 可选图片样式（例如：x-oss-process=image/resize,w_256）
     * @return {"url": "https://..."}
     */
    @GetMapping("/sign")
    public ResponseEntity<?> sign(@RequestParam("key") String key,
                                  @RequestParam(value = "expires", required = false) Integer expiresSeconds,
                                  @RequestParam(value = "style", required = false) String style) {
        if (key == null || key.trim().isEmpty()) {
            return ResponseEntity.badRequest().body("key 不能为空");
        }
        // 仅调用服务方法生成签名 URL
        String url = ossService.signGetUrl(key.trim(), expiresSeconds, style);
        return ResponseEntity.ok().body(java.util.Map.of("url", url));
    }

    /**
     * 生成 PUT 临时签名 URL（用于前端直传）
     *
     * @param key 对象 key（不接受绝对 URL）
     * @param expiresSeconds 过期秒数（可选）
     * @return {"url": "https://..."}
     */
    @GetMapping("/sign-put")
    public ResponseEntity<?> signPut(@RequestParam("key") String key,
                                     @RequestParam(value = "expires", required = false) Integer expiresSeconds) {
        if (key == null || key.trim().isEmpty()) {
            return ResponseEntity.badRequest().body("key 不能为空");
        }
        // 仅调用服务方法生成 PUT 签名 URL
        String url = ossService.signPutUrl(key.trim(), expiresSeconds);
        return ResponseEntity.ok().body(java.util.Map.of("url", url));
    }
}