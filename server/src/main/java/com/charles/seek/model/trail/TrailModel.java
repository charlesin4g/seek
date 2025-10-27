package com.charles.seek.model.trail;

import com.charles.seek.model.BaseEntity;
import com.charles.seek.model.activity.ActivityModel;
import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.Comment;

import java.time.LocalDateTime;

@EqualsAndHashCode(callSuper = true)
@Data
@Entity
@Table(name = "trail",
        indexes = {
                @Index(name = "idx_trail_owner", columnList = "owner"),
                @Index(name = "idx_trail_start_time", columnList = "start_time"),
                @Index(name = "idx_trail_activity_id", columnList = "activity_id")
        })
public class TrailModel extends BaseEntity {

    @NotBlank
    @Size(max = 100)
    @Column(name = "title", length = 100, nullable = false)
    @Comment("轨迹标题")
    private String title;

    @Size(max = 1000)
    @Column(name = "description", length = 1000)
    @Comment("轨迹描述")
    private String description;

    @Size(max = 20)
    @Column(name = "type", length = 20)
    @Comment("轨迹类型: Hike/Run/Bike 等")
    private String type;

    @Column(name = "start_time")
    @Comment("开始时间")
    private LocalDateTime startTime;

    @Column(name = "end_time")
    @Comment("结束时间")
    private LocalDateTime endTime;

    @PositiveOrZero
    @Digits(integer = 12, fraction = 2)
    // 移除 DEFAULT 0.0，避免 PostgreSQL ALTER COLUMN 语法错误；保持为 DOUBLE PRECISION
    @Column(name = "distance", columnDefinition = "DOUBLE PRECISION")
    // 使用 DOUBLE PRECISION，默认值通过应用层初始化，避免 PostgreSQL ALTER TYPE 语法错误
    @Comment("总距离(米)")
    private double distance;

    @PositiveOrZero
    @Column(name = "duration_sec", columnDefinition = "INTEGER DEFAULT 0")
    @Comment("总时长(秒)")
    private int durationSec;

    @PositiveOrZero
    @Digits(integer = 6, fraction = 2)
    // 移除 DEFAULT 0.0，避免 PostgreSQL ALTER COLUMN 语法错误；保持为 DOUBLE PRECISION
    @Column(name = "avg_speed", columnDefinition = "DOUBLE PRECISION")
    // 使用 DOUBLE PRECISION，默认值通过应用层初始化，避免 PostgreSQL ALTER TYPE 语法错误
    @Comment("平均速度(m/s)")
    private double avgSpeed;

    @PositiveOrZero
    @Digits(integer = 6, fraction = 2)
    // 移除 DEFAULT 0.0，避免 PostgreSQL ALTER COLUMN 语法错误；保持为 DOUBLE PRECISION
    @Column(name = "elevation_gain", columnDefinition = "DOUBLE PRECISION")
    // 使用 DOUBLE PRECISION，默认值通过应用层初始化，避免 PostgreSQL ALTER TYPE 语法错误
    @Comment("累计爬升(米)")
    private double elevationGain;

    // 经纬度使用 DOUBLE PRECISION 存储，以避免 scale 推断影响 DDL
    @Column(name = "min_lat", columnDefinition = "DOUBLE PRECISION")
    // 使用 DOUBLE PRECISION 避免 Hibernate 对浮点类型设置 scale 报错
    @Comment("最小纬度")
    private Double minLat;

    // 经纬度使用 DOUBLE PRECISION 存储，以避免 scale 推断影响 DDL
    @Column(name = "min_lon", columnDefinition = "DOUBLE PRECISION")
    // 使用 DOUBLE PRECISION 避免 Hibernate 对浮点类型设置 scale 报错
    @Comment("最小经度")
    private Double minLon;

    // 经纬度使用 DOUBLE PRECISION 存储，以避免 scale 推断影响 DDL
    @Column(name = "max_lat", columnDefinition = "DOUBLE PRECISION")
    // 使用 DOUBLE PRECISION 避免 Hibernate 对浮点类型设置 scale 报错
    @Comment("最大纬度")
    private Double maxLat;

    // 经纬度使用 DOUBLE PRECISION 存储，以避免 scale 推断影响 DDL
    @Column(name = "max_lon", columnDefinition = "DOUBLE PRECISION")
    // 使用 DOUBLE PRECISION 避免 Hibernate 对浮点类型设置 scale 报错
    @Comment("最大经度")
    private Double maxLon;

    @Size(max = 50)
    @Column(name = "owner", length = 50)
    @Comment("所属用户：用户名")
    private String owner;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "activity_id", foreignKey = @ForeignKey(name = "fk_trail_activity"))
    @Comment("关联活动")
    private ActivityModel activity;
}
