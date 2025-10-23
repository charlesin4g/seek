package com.charles.seek.dto.trail.request;

import jakarta.validation.constraints.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class EditTrailRequest {
    @NotBlank
    @Size(max = 100)
    private String title;

    @Size(max = 1000)
    private String description;

    @Size(max = 20)
    private String type;

    private LocalDateTime startTime;

    private LocalDateTime endTime;

    @PositiveOrZero
    @Digits(integer = 12, fraction = 2)
    private Double distance;

    @PositiveOrZero
    private Integer durationSec;

    @PositiveOrZero
    @Digits(integer = 6, fraction = 2)
    private Double avgSpeed;

    @PositiveOrZero
    @Digits(integer = 6, fraction = 2)
    private Double elevationGain;

    @DecimalMin(value = "-90.0")
    @DecimalMax(value = "90.0")
    private Double minLat;

    @DecimalMin(value = "-180.0")
    @DecimalMax(value = "180.0")
    private Double minLon;

    @DecimalMin(value = "-90.0")
    @DecimalMax(value = "90.0")
    private Double maxLat;

    @DecimalMin(value = "-180.0")
    @DecimalMax(value = "180.0")
    private Double maxLon;

    @Size(max = 50)
    private String owner;

    // 关联活动ID（可选）
    @Positive
    private Long activityId;
}