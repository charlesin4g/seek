package com.charles.seek.dto.activity.request;

import com.charles.seek.constant.ActivityTypeEnum;
import jakarta.validation.constraints.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class AddActivityRequest {
    /** 活动时间 */
    private LocalDateTime activityTime;

    /** 活动名称 */
    @NotBlank
    @Size(max = 100)
    private String name;

    /** 活动类型 */
    @NotNull
    private ActivityTypeEnum type;

    /** 活动描述 */
    @Size(max = 1000)
    private String description;

    /** 全程耗时(秒) */
    @PositiveOrZero
    private Integer totalDurationSec;

    /** 距离(米) */
    @PositiveOrZero
    @Digits(integer = 12, fraction = 2)
    private Double distance;

    /** 最大心率 */
    @PositiveOrZero
    private Integer maxHeartRate;

    /** 平均心率 */
    @PositiveOrZero
    private Integer avgHeartRate;

    /** 移动时间(秒) */
    @PositiveOrZero
    private Integer movingTimeSec;

    /** 海拔爬升(米) */
    @PositiveOrZero
    @Digits(integer = 8, fraction = 2)
    private Double elevationGain;

    /** 海拔下降(米) */
    @PositiveOrZero
    @Digits(integer = 8, fraction = 2)
    private Double elevationLoss;

    /** 最低海拔(米) */
    @Digits(integer = 8, fraction = 2)
    private Double minElevation;

    /** 最高海拔(米) */
    @Digits(integer = 8, fraction = 2)
    private Double maxElevation;

    /** 最大速度(m/s) */
    @PositiveOrZero
    @Digits(integer = 6, fraction = 2)
    private Double maxSpeed;

    /** 平均速度(m/s) */
    @PositiveOrZero
    @Digits(integer = 6, fraction = 2)
    private Double avgSpeed;

    /** 消耗热量(kcal) */
    @PositiveOrZero
    private Integer calories;

    @NotBlank
    @Size(max = 50)
    private String owner;
}