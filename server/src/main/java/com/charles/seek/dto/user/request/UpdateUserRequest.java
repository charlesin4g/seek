package com.charles.seek.dto.user.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * 更新用户请求体
 * 
 * @author SOLO Coding
 * @since 2025-11-14
 */
@Data
@Schema(description = "更新用户请求")
public class UpdateUserRequest {

    @Schema(description = "显示昵称", example = "Alice")
    @Size(max = 64, message = "昵称长度不能超过 64 位")
    private String displayName;

    @Schema(description = "邮箱", example = "alice@example.com")
    @Email(message = "邮箱格式不正确")
    @Size(max = 128, message = "邮箱长度不能超过 128 位")
    private String email;

    @Schema(description = "手机号", example = "13800138000")
    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式不正确")
    private String phone;

    @Schema(description = "性别：0 未知，1 男，2 女", example = "1")
    private Integer sex;

    @Schema(description = "个性签名", example = "Stay hungry, stay foolish.")
    @Size(max = 255, message = "签名长度不能超过 255 位")
    private String signature;

    @Schema(description = "头像 URL", example = "https://example.com/avatar.jpg")
    @Size(max = 512, message = "头像 URL 长度不能超过 512 位")
    private String avatarUrl;

    @Schema(description = "背景图 URL", example = "https://example.com/bg.jpg")
    @Size(max = 512, message = "背景图 URL 长度不能超过 512 位")
    private String backgroundUrl;
}