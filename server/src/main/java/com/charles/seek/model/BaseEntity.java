package com.charles.seek.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.Size;
import lombok.Data;
import org.hibernate.annotations.Comment;

import java.time.LocalDate;

@MappedSuperclass
@Data
public class BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Comment("ID，主键，自增长")
    private Long id;

    /**
     * 创建时间
     */
    @Column(name = "created_at", updatable = false, columnDefinition = "DATE default CURRENT_DATE")
    private LocalDate createdAt;

    /**
     * 更新时间
     */
    @Column(name = "updatedAt", columnDefinition = "DATE default CURRENT_DATE")
    private LocalDate updatedAt;

    /**
     * 状态（0:禁用, 1:启用）
     */
    @Column(name = "status", nullable = false, columnDefinition = "int default 1")
    private int status = 1;

    /**
     * 备注
     */
    @Size(max = 200, message = "备注长度不能超过200个字符")
    @Column(name = "remark", length = 200)
    private String remark;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDate.now();
        updatedAt = LocalDate.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDate.now();
    }
}
