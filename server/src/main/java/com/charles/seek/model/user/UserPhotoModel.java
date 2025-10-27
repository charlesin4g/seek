package com.charles.seek.model.user;

import com.charles.seek.model.BaseEntity;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.Comment;

/**
 * 用户照片实体模型
 *
 * 说明：
 * - 与用户通过字符串字段 `owner` 关联，存储用户ID，保持与现有数据模型一致；
 * - 图片资源来自 OSS，存储对象键（或完整 URL），由服务层负责签名与解析；
 */
@EqualsAndHashCode(callSuper = true)
@Data
@Entity
@Table(name = "user_photo",
        indexes = {
                @Index(name = "idx_user_photo_owner", columnList = "owner"),
                @Index(name = "idx_user_photo_created_at", columnList = "created_at")
        })
public class UserPhotoModel extends BaseEntity {

    /** 所属用户ID（字符串，与现有模型保持一致） */
    @NotBlank
    @Size(max = 50)
    @Column(name = "owner", length = 50, nullable = false)
    @Comment("所属用户ID（字符串）")
    private String owner;

    /** OSS 对象键或完整 URL */
    @NotBlank
    @Size(max = 255)
    @Column(name = "object_key", length = 255, nullable = false)
    @Comment("OSS 对象键或完整 URL")
    private String objectKey;

    /** 照片标题（可选） */
    @Size(max = 100)
    @Column(name = "title", length = 100)
    @Comment("照片标题")
    private String title;

    /** 照片描述（可选） */
    @Size(max = 500)
    @Column(name = "description", length = 500)
    @Comment("照片描述")
    private String description;
}