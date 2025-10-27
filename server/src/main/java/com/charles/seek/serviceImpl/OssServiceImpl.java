package com.charles.seek.serviceImpl;

import com.charles.seek.service.OssService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

/**
 * OSS 服务实现
 *
 * 业务逻辑：
 * - 生成 Query String Authentication（GET）临时签名 URL；
 * - 仅使用 bucket 域名进行签名，避免 CNAME 造成签名校验差异；
 * - 统一追加配置的路径前缀与图片样式（可选）。
 */
@Service
@RequiredArgsConstructor
public class OssServiceImpl implements OssService {

    // 配置项（通过 application.properties 注入）
    @Value("${oss.enabled:true}")
    private boolean enabled;

    @Value("${oss.endpoint}")
    private String endpoint;

    @Value("${oss.bucket}")
    private String bucket;

    @Value("${oss.public-domain:}")
    private String publicDomain;

    @Value("${oss.prefix:}")
    private String prefix;

    @Value("${oss.image-style:}")
    private String imageStyle;

    @Value("${oss.access-key-id:}")
    private String accessKeyId;

    @Value("${oss.access-key-secret:}")
    private String accessKeySecret;

    @Value("${oss.security-token:}")
    private String securityToken;

    @Value("${oss.default-expiry-seconds:300}")
    private int defaultExpirySeconds;

    /**
     * 拼接路径，保证只有一个斜杠分隔
     */
    private String joinPath(String base, String path) {
        String b = base.endsWith("/") ? base.substring(0, base.length() - 1) : base;
        String p = path.startsWith("/") ? path.substring(1) : path;
        return b + "/" + p;
    }

    /**
     * 为签名构造 CanonicalizedResource：/bucket/objectKey
     */
    private String canonicalizedResource(String keyWithPrefix) {
        return "/" + bucket + "/" + keyWithPrefix;
    }

    /**
     * 获取用于签名与访问的 bucket 域名（https）
     */
    private String bucketDomain() {
        return "https://" + bucket + "." + endpoint;
    }

    /**
     * 获取统一前缀后的对象 key
     */
    private String withPrefix(String objectKey) {
        if (prefix == null || prefix.isEmpty()) return objectKey;
        // 使用基础 joinPath；去除可能的开头斜杠
        String joined = joinPath("", joinPath(prefix, objectKey));
        return joined.startsWith("/") ? joined.substring(1) : joined;
    }

    /**
     * HMAC-SHA1 计算并 Base64 编码
     */
    private String hmacSha1Base64(String data, String secret) {
        try {
            Mac mac = Mac.getInstance("HmacSHA1");
            SecretKeySpec keySpec = new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA1");
            mac.init(keySpec);
            byte[] raw = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(raw);
        } catch (Exception e) {
            throw new RuntimeException("HMAC-SHA1 签名失败", e);
        }
    }

    /**
     * 判断是否为绝对 URL
     */
    private boolean isAbsoluteUrl(String s) {
        if (s == null) return false;
        String v = s.trim();
        return v.startsWith("http://") || v.startsWith("https://");
    }

    /**
     * 生成 GET 私有签名 URL
     */
    @Override
    public String signGetUrl(String objectKey, Integer expiresSeconds, String style) {
        if (!enabled) {
            // 未启用 OSS，直接返回原 key（不建议暴露）
            return objectKey;
        }
        if (bucket == null || bucket.isEmpty()) {
            throw new IllegalStateException("bucket 未配置，无法生成签名 URL");
        }
        if (accessKeyId == null || accessKeyId.isEmpty() || accessKeySecret == null || accessKeySecret.isEmpty()) {
            throw new IllegalStateException("AccessKey 未配置，无法生成签名 URL");
        }

        String keyWithPrefix = withPrefix(objectKey);

        // 过期时间（秒级时间戳）
        long nowSec = System.currentTimeMillis() / 1000;
        long expires = nowSec + (long) (expiresSeconds == null ? defaultExpirySeconds : expiresSeconds);

        // StringToSign
        String stringToSign = String.join("\n",
                "GET",
                "", // Content-MD5
                "", // Content-Type
                String.valueOf(expires),
                canonicalizedResource(keyWithPrefix)
        );

        // HMAC-SHA1 签名
        String signature = hmacSha1Base64(stringToSign, accessKeySecret);

        // 目标对象 URL 使用 bucket 域名
        String objectUrl = joinPath(bucketDomain(), keyWithPrefix);

        StringBuilder url = new StringBuilder(objectUrl)
                .append("?OSSAccessKeyId=").append(UriEncoder.encode(accessKeyId))
                .append("&Expires=").append(expires)
                .append("&Signature=").append(UriEncoder.encode(signature));

        // 追加 STS token（若采用 STS 场景）
        if (securityToken != null && !securityToken.isEmpty()) {
            url.append("&x-oss-security-token=").append(UriEncoder.encode(securityToken));
        }

        // 图片样式（不参与签名，可追加在查询参数）
        String effectiveStyle = (style != null && !style.isEmpty()) ? style : imageStyle;
        if (effectiveStyle != null && !effectiveStyle.isEmpty()) {
            url.append("&").append(effectiveStyle);
        }

        return url.toString();
    }

    /**
     * 生成 PUT 临时签名 URL（用于前端直传）
     *
     * 说明：
     * - 使用 Query String Authentication，HTTP 方法为 PUT；
     * - 前端使用该 URL 直接 PUT 二进制内容到 OSS；
     * - Content-Type 不参与签名，前端可自行设置；
     */
    @Override
    public String signPutUrl(String objectKey, Integer expiresSeconds) {
        if (!enabled) {
            return objectKey;
        }
        if (bucket == null || bucket.isEmpty()) {
            throw new IllegalStateException("bucket 未配置，无法生成签名 URL");
        }
        if (accessKeyId == null || accessKeyId.isEmpty() || accessKeySecret == null || accessKeySecret.isEmpty()) {
            throw new IllegalStateException("AccessKey 未配置，无法生成签名 URL");
        }

        String keyWithPrefix = withPrefix(objectKey);

        long nowSec = System.currentTimeMillis() / 1000;
        long expires = nowSec + (long) (expiresSeconds == null ? defaultExpirySeconds : expiresSeconds);

        // StringToSign for PUT
        String stringToSign = String.join("\n",
                "PUT",
                "", // Content-MD5
                "", // Content-Type (不参与)
                String.valueOf(expires),
                canonicalizedResource(keyWithPrefix)
        );

        String signature = hmacSha1Base64(stringToSign, accessKeySecret);

        String objectUrl = joinPath(bucketDomain(), keyWithPrefix);

        StringBuilder url = new StringBuilder(objectUrl)
                .append("?OSSAccessKeyId=").append(UriEncoder.encode(accessKeyId))
                .append("&Expires=").append(expires)
                .append("&Signature=").append(UriEncoder.encode(signature));

        if (securityToken != null && !securityToken.isEmpty()) {
            url.append("&x-oss-security-token=").append(UriEncoder.encode(securityToken));
        }

        return url.toString();
    }

    /**
     * 解析私有资源完整 URL（绝对 URL 原样返回；key 进行签名）
     */
    @Override
    public String resolvePrivateUrl(String keyOrUrl, Integer expiresSeconds, String style) {
        if (keyOrUrl == null || keyOrUrl.trim().isEmpty()) return null;
        if (isAbsoluteUrl(keyOrUrl)) return keyOrUrl;
        return signGetUrl(keyOrUrl.trim(), expiresSeconds, style);
    }

    /**
     * 简单 URI 编码工具（仅用于查询参数值）
     */
    private static class UriEncoder {
        static String encode(String s) {
            return java.net.URLEncoder.encode(s, StandardCharsets.UTF_8);
        }
    }
}