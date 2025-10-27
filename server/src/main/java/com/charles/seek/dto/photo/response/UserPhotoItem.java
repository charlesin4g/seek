package com.charles.seek.dto.photo.response;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 用户照片返回对象
 *
 * 说明：url 字段为服务层解析后的可访问地址（可能为签名 URL）。
 */
@Data
public class UserPhotoItem {
    private Long id;
    private String url; // 已解析的完整 URL（可能为临时签名）
    private String title;
    private String description;
    private LocalDateTime createdAt;
}