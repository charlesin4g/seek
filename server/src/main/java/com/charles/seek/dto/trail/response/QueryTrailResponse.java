package com.charles.seek.dto.trail.response;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class QueryTrailResponse {
    private Long id;
    private String title;
    private String description;
    private String type;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private Double distance;
    private Integer durationSec;
    private Double avgSpeed;
    private Double elevationGain;
    private Double minLat;
    private Double minLon;
    private Double maxLat;
    private Double maxLon;
    private String owner;
    private Long activityId;
}