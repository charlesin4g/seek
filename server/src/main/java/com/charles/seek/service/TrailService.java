package com.charles.seek.service;

import com.charles.seek.model.trail.TrailModel;
import com.charles.seek.model.trail.TrailPointModel;

import java.util.List;
import java.util.Optional;

public interface TrailService {
    TrailModel saveTrail(TrailModel trail);
    Optional<TrailModel> findById(Long id);
    List<TrailModel> findByOwner(String owner);
    List<TrailPointModel> findPoints(Long trailId);
    void addPoints(Long trailId, List<TrailPointModel> points);
    void deleteById(Long id);
}