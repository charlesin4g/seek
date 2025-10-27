package com.charles.seek.dto.photo.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * 新增用户照片请求对象
 *
 * 控制器接收后直接传递给服务层，业务逻辑在服务层处理。
 */
@Data
public class AddUserPhotoRequest {
    /** 所属用户ID（字符串） */
    @NotBlank
    @Size(max = 50)
    private String owner;

    /** OSS 对象键或完整 URL */
    @NotBlank
    @Size(max = 255)
    private String objectKey;

    /** 照片标题（可选） */
    @Size(max = 100)
    private String title;

    /** 照片描述（可选） */
    @Size(max = 500)
    private String description;
}