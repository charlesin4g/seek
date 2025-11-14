package com.charles.seek.dto.user.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * 创建用户请求体
 * 
 * @author SOLO Coding
 * @since 2025-11-14
 */
@Data
@Schema(description = "创建用户请求")
public class CreateUserRequest {

    @Schema(description = "用户名", example = "alice")
    @NotBlank(message = "用户名不能为空")
    @Size(min = 3, max = 32, message = "用户名长度必须在 3-32 位")
    @Pattern(regexp = "^[a-zA-Z0-9_]+$", message = "用户名只能包含字母、数字和下划线")
    private String username;

    @Schema(description = "登录密码", example = "123456")
    @NotBlank(message = "密码不能为空")
    @Size(min = 6, max = 64, message = "密码长度必须在 6-64 位")
    private String password;

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
    private Integer sex = 0;

    @Schema(description = "个性签名", example = "Stay hungry, stay foolish.")
    @Size(max = 255, message = "签名长度不能超过 255 位")
    private String signature;
}