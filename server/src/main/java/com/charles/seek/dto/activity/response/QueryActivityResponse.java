package com.charles.seek.dto.activity.response;

import com.charles.seek.constant.ActivityTypeEnum;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class QueryActivityResponse {
    private String id;
    private LocalDateTime activityTime;
    private String name;
    private ActivityTypeEnum type;
    private String description;
    private Integer totalDurationSec;
    private Double distance;
    private Integer maxHeartRate;
    private Integer avgHeartRate;
    private Integer movingTimeSec;
    private Double elevationGain;
    private Double elevationLoss;
    private Double minElevation;
    private Double maxElevation;
    private Double maxSpeed;
    private Double avgSpeed;
    private Integer calories;
    private String owner;
}