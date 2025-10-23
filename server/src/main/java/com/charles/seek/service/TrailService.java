package com.charles.seek.service;

import com.charles.seek.dto.trail.request.AddTrailRequest;
import com.charles.seek.dto.trail.request.EditTrailRequest;
import com.charles.seek.model.trail.TrailModel;
import com.charles.seek.model.trail.TrailPointModel;

import java.util.List;
import java.util.Optional;

public interface TrailService {
    TrailModel saveTrail(TrailModel trail);
    // 新增：通过请求创建轨迹（支持 activityId）
    TrailModel create(AddTrailRequest request);
    // 新增：通过请求更新轨迹（支持 activityId）
    Optional<TrailModel> update(Long id, EditTrailRequest request);

    Optional<TrailModel> findById(Long id);
    List<TrailModel> findByOwner(String owner);
    // 新增：按活动筛选
    List<TrailModel> findByActivityId(Long activityId);

    List<TrailPointModel> findPoints(Long trailId);
    void addPoints(Long trailId, List<TrailPointModel> points);
    void deleteById(Long id);

}