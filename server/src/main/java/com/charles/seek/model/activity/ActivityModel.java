package com.charles.seek.model.activity;

import com.charles.seek.constant.ActivityTypeEnum;
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
@Table(name = "activity",
        indexes = {
                @Index(name = "idx_activity_time", columnList = "activity_time"),
                @Index(name = "idx_activity_type", columnList = "type"),
                @Index(name = "idx_activity_owner", columnList = "owner")
        })
public class ActivityModel extends BaseEntity {

    /** 活动时间 */
    @Column(name = "activity_time")
    @Comment("活动时间")
    private LocalDateTime activityTime;

    /** 活动名称 */
    @NotBlank
    @Size(max = 100)
    @Column(name = "name", length = 100, nullable = false)
    @Comment("活动名称")
    private String name;

    /** 活动类型：远足、骑行、跑步、游泳 */
    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(name = "type", length = 20, nullable = false)
    @Comment("活动类型：Hike/Run/Cycle/Swim")
    private ActivityTypeEnum type;

    /** 活动描述 */
    @Size(max = 1000)
    @Column(name = "description", length = 1000)
    @Comment("活动描述")
    private String description;

    /** 全程耗时(秒) */
    @PositiveOrZero
    @Column(name = "total_duration_sec", columnDefinition = "INTEGER DEFAULT 0")
    @Comment("全程耗时(秒)")
    private Integer totalDurationSec = 0;

    /** 距离(米) */
    @PositiveOrZero
    @Digits(integer = 12, fraction = 2)
    @Column(name = "distance", columnDefinition = "NUMERIC(12,2) DEFAULT 0.00")
    @Comment("距离(米)")
    private Double distance = 0.0;

    /** 最大心率 */
    @PositiveOrZero
    @Column(name = "max_heart_rate", columnDefinition = "INTEGER DEFAULT 0")
    @Comment("最大心率")
    private Integer maxHeartRate = 0;

    /** 平均心率 */
    @PositiveOrZero
    @Column(name = "avg_heart_rate", columnDefinition = "INTEGER DEFAULT 0")
    @Comment("平均心率")
    private Integer avgHeartRate = 0;

    /** 移动时间(秒) */
    @PositiveOrZero
    @Column(name = "moving_time_sec", columnDefinition = "INTEGER DEFAULT 0")
    @Comment("移动时间(秒)")
    private Integer movingTimeSec = 0;

    /** 海拔爬升(米) */
    @PositiveOrZero
    @Digits(integer = 8, fraction = 2)
    @Column(name = "elevation_gain", columnDefinition = "NUMERIC(8,2) DEFAULT 0.00")
    @Comment("海拔爬升(米)")
    private Double elevationGain = 0.0;

    /** 海拔下降(米) */
    @PositiveOrZero
    @Digits(integer = 8, fraction = 2)
    @Column(name = "elevation_loss", columnDefinition = "NUMERIC(8,2) DEFAULT 0.00")
    @Comment("海拔下降(米)")
    private Double elevationLoss = 0.0;

    /** 最低海拔(米) */
    @Digits(integer = 8, fraction = 2)
    @Column(name = "min_elevation", columnDefinition = "NUMERIC(8,2)")
    @Comment("最低海拔(米)")
    private Double minElevation;

    /** 最高海拔(米) */
    @Digits(integer = 8, fraction = 2)
    @Column(name = "max_elevation", columnDefinition = "NUMERIC(8,2)")
    @Comment("最高海拔(米)")
    private Double maxElevation;

    /** 最大速度(m/s) */
    @PositiveOrZero
    @Digits(integer = 6, fraction = 2)
    @Column(name = "max_speed", columnDefinition = "NUMERIC(6,2) DEFAULT 0.00")
    @Comment("最大速度(m/s)")
    private Double maxSpeed = 0.0;

    /** 平均速度(m/s) */
    @PositiveOrZero
    @Digits(integer = 6, fraction = 2)
    @Column(name = "avg_speed", columnDefinition = "NUMERIC(6,2) DEFAULT 0.00")
    @Comment("平均速度(m/s)")
    private Double avgSpeed = 0.0;

    /** 消耗热量(kcal) */
    @PositiveOrZero
    @Column(name = "calories", columnDefinition = "INTEGER DEFAULT 0")
    @Comment("消耗热量(kcal)")
    private Integer calories = 0;

    /** 所属用户：用户名 */
    @Size(max = 50)
    @Column(name = "owner", length = 50)
    @Comment("所属用户：用户名")
    private String owner;
}