package com.charles.seek.model.gear;

import com.charles.seek.model.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.Comment;

@EqualsAndHashCode(callSuper = true)
@Data
@Entity
@Table(name = "brand")
public class BrandModel extends BaseEntity {

    @NotBlank(message = "名称不能为空")
    @Size(min = 1, max = 50, message = "名称长度必须在1-50个字符之间")
    @Column(name = "name", length = 50, nullable = false, unique = true)
    @Comment("品牌实际名称，登录账号，唯一")
    private String name;

    @Size(max = 50, message = "显示名称长度不能超过50个字符")
    @Column(name = "display_name", length = 50)
    @Comment("显示名称，用于界面展示")
    private String displayName;

    @Comment("顺序号，用于界面展示排序")
    @Column(name = "sequence", columnDefinition = "INTEGER DEFAULT 0")
    private int sequence;

}
