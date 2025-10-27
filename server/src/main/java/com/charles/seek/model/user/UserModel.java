package com.charles.seek.model.user;

import com.charles.seek.model.BaseEntity;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.Comment;


/**
 * 用户信息表 - 存储系统用户基本信息
 * 包含用户登录认证和基本信息管理
 */

@EqualsAndHashCode(callSuper = true)
@Data
@Entity
@Table(name = "\"user\"",
        indexes = {
                @Index(name = "idx_user_username", columnList = "username", unique = true),
                @Index(name = "idx_user_email", columnList = "email"),
                @Index(name = "idx_user_phone", columnList = "phone")
        },
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_user_username", columnNames = "username")
        })
public class UserModel extends BaseEntity {
    /**
     * 用户名 - 登录账号
     * 系统唯一，用于用户登录和身份识别
     */
    @NotBlank(message = "用户名不能为空")
    @Size(min = 1, max = 50, message = "名称长度必须在1-50个字符之间")
    @Column(name = "username", length = 50, nullable = false, unique = true)
    @Comment("用户名，登录账号，唯一")
    private String username;

    /**
     * 用户显示名称 - 用于界面显示
     * 可以重复，用户可自定义修改
     */
    @Size(max = 50, message = "显示名称长度不能超过50个字符")
    @Column(name = "display_name", length = 50)
    @Comment("用户显示名称，用于界面展示")
    private String displayName;

    /**
     * 密码 - 登录密码
     * 存储加密后的用户密码，用于身份验证
     */
    @NotBlank(message = "密码不能为空")
    @Size(max = 255)
    @Column(name = "password", nullable = false)
    @Comment("密码，加密存储")
    private String password;

    /**
     * 邮箱地址
     * 用户邮箱，可用于找回密码和接收通知
     */
    @Column(name = "email", length = 100)
    @Comment("邮箱地址")
    private String email;

    /**
     * 手机号码
     * 用户手机号，可用于验证和联系
     */
    @Column(name = "phone", length = 20)
    @Comment("手机号码")
    private String phone;

    /**
     * 性别
     * 0-未知 1-男 2-女
     */
    @Column(name = "sex", nullable = false, columnDefinition = "int default 0")
    @Comment("性别：0-未知 1-男 2-女")
    private int sex;

    /**
     * 个人签名
     * 用户个人签名，用于个人资料展示
     */
    @Size(max = 200, message = "个人签名长度不能超过200个字符")
    @Column(name = "signature", length = 200)
    @Comment("个人签名")
    private String signature;

    /**
     * 头像地址
     * 用户头像图片的 URL
     */
    @Size(max = 255, message = "头像地址长度不能超过255个字符")
    @Column(name = "avatar_url", length = 255)
    @Comment("用户头像 URL")
    private String avatarUrl;

    /**
     * 背景图地址
     * 用户主页背景图的 URL
     */
    @Size(max = 255, message = "背景图地址长度不能超过255个字符")
    @Column(name = "background_url", length = 255)
    @Comment("用户背景图 URL")
    private String backgroundUrl;
}