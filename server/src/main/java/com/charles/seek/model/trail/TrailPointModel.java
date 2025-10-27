package com.charles.seek.model.trail;

import com.charles.seek.model.BaseEntity;
import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.Comment;

import java.time.LocalDateTime;

@EqualsAndHashCode(callSuper = true)
@Data
@Entity
@Table(name = "trail_point",
        indexes = {
                @Index(name = "idx_trail_point_trail_id", columnList = "trail_id"),
                @Index(name = "idx_trail_point_timestamp", columnList = "timestamp")
        })
public class TrailPointModel extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "trail_id", nullable = false)
    @Comment("所属轨迹")
    private TrailModel trail;

    @Column(name = "sequence", columnDefinition = "INTEGER DEFAULT 0")
    @Comment("轨迹点顺序")
    private int sequence;

    @Column(name = "timestamp")
    @Comment("采集时间")
    private LocalDateTime timestamp;

    @DecimalMin(value = "-90.0", message = "纬度范围应在[-90,90]")
    @DecimalMax(value = "90.0", message = "纬度范围应在[-90,90]")
    // 经纬度使用 DOUBLE PRECISION 存储，以避免 scale 推断影响 DDL
    @Column(name = "latitude", columnDefinition = "DOUBLE PRECISION")
    // 使用 DOUBLE PRECISION 避免 Hibernate 对浮点类型设置 scale 报错
    @Comment("纬度")
    private Double latitude;

    @DecimalMin(value = "-180.0", message = "经度范围应在[-180,180]")
    @DecimalMax(value = "180.0", message = "经度范围应在[-180,180]")
    // 经纬度使用 DOUBLE PRECISION 存储，以避免 scale 推断影响 DDL
    @Column(name = "longitude", columnDefinition = "DOUBLE PRECISION")
    // 使用 DOUBLE PRECISION 避免 Hibernate 对浮点类型设置 scale 报错
    @Comment("经度")
    private Double longitude;

    // 使用 DOUBLE PRECISION 存储海拔，避免小数位约束导致 DDL 异常
    @Column(name = "elevation", columnDefinition = "DOUBLE PRECISION")
    // 使用 DOUBLE PRECISION 避免 Hibernate 对浮点类型设置 scale 报错
    @Comment("海拔(米)")
    private Double elevation;

    @PositiveOrZero
    // 移除 DEFAULT 0.0，避免 PostgreSQL ALTER COLUMN 语法错误；保持为 DOUBLE PRECISION
    @Column(name = "speed", columnDefinition = "DOUBLE PRECISION")
    // 使用 DOUBLE PRECISION 避免 Hibernate 对浮点类型设置 scale 报错
    @Comment("速度(m/s)")
    private Double speed;

    @Size(max = 20)
    @Column(name = "point_type", length = 20)
    @Comment("点类型：track/poi")
    private String pointType;

    @Size(max = 200)
    @Column(name = "note", length = 200)
    @Comment("备注/标注")
    private String note;
}