package com.charles.seek.serviceImpl;

import com.charles.seek.dto.trail.request.AddTrailRequest;
import com.charles.seek.dto.trail.request.EditTrailRequest;
import com.charles.seek.model.activity.ActivityModel;
import com.charles.seek.model.trail.TrailModel;
import com.charles.seek.model.trail.TrailPointModel;
import com.charles.seek.repository.TrailPointRepository;
import com.charles.seek.repository.TrailRepository;
import com.charles.seek.repository.ActivityRepository;
import com.charles.seek.service.TrailService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class TrailServiceImpl implements TrailService {

    private final TrailRepository trailRepository;
    private final TrailPointRepository trailPointRepository;
    private final ActivityRepository activityRepository;

    @Override
    public TrailModel saveTrail(TrailModel trail) {
        return trailRepository.save(trail);
    }

    @Override
    public TrailModel create(AddTrailRequest request) {
        TrailModel trail = new TrailModel();
        trail.setTitle(request.getTitle());
        trail.setDescription(request.getDescription());
        trail.setType(request.getType());
        trail.setStartTime(request.getStartTime());
        trail.setEndTime(request.getEndTime());
        trail.setDistance(request.getDistance() == null ? 0.0 : request.getDistance());
        trail.setDurationSec(request.getDurationSec() == null ? 0 : request.getDurationSec());
        trail.setAvgSpeed(request.getAvgSpeed() == null ? 0.0 : request.getAvgSpeed());
        trail.setElevationGain(request.getElevationGain() == null ? 0.0 : request.getElevationGain());
        trail.setMinLat(request.getMinLat());
        trail.setMinLon(request.getMinLon());
        trail.setMaxLat(request.getMaxLat());
        trail.setMaxLon(request.getMaxLon());
        trail.setOwner(request.getOwner());
        if (request.getActivityId() != null) {
            ActivityModel activity = activityRepository.findById(request.getActivityId())
                    .orElseThrow(() -> new IllegalArgumentException("Activity not found: " + request.getActivityId()));
            trail.setActivity(activity);
        }
        return trailRepository.save(trail);
    }

    @Override
    public Optional<TrailModel> update(Long id, EditTrailRequest request) {
        return trailRepository.findById(id).map(existing -> {
            existing.setTitle(request.getTitle());
            existing.setDescription(request.getDescription());
            existing.setType(request.getType());
            existing.setStartTime(request.getStartTime());
            existing.setEndTime(request.getEndTime());
            existing.setDistance(request.getDistance() == null ? existing.getDistance() : request.getDistance());
            existing.setDurationSec(request.getDurationSec() == null ? existing.getDurationSec() : request.getDurationSec());
            existing.setAvgSpeed(request.getAvgSpeed() == null ? existing.getAvgSpeed() : request.getAvgSpeed());
            existing.setElevationGain(request.getElevationGain() == null ? existing.getElevationGain() : request.getElevationGain());
            existing.setMinLat(request.getMinLat());
            existing.setMinLon(request.getMinLon());
            existing.setMaxLat(request.getMaxLat());
            existing.setMaxLon(request.getMaxLon());
            if (request.getOwner() != null) {
                existing.setOwner(request.getOwner());
            }
            if (request.getActivityId() != null) {
                ActivityModel activity = activityRepository.findById(request.getActivityId())
                        .orElseThrow(() -> new IllegalArgumentException("Activity not found: " + request.getActivityId()));
                existing.setActivity(activity);
            }
            return trailRepository.save(existing);
        });
    }

    @Override
    public Optional<TrailModel> findById(Long id) {
        return trailRepository.findById(id);
    }

    @Override
    public List<TrailModel> findByActivityId(Long activityId) {
        return trailRepository.findByActivity_IdOrderByStartTimeDesc(activityId);
    }

    @Override
    public List<TrailModel> findByOwner(String owner) {
        return trailRepository.findByOwnerOrderByStartTimeDesc(owner);
    }

    @Override
    public List<TrailPointModel> findPoints(Long trailId) {
        return trailPointRepository.findByTrail_IdOrderByTimestampAscSequenceAsc(trailId);
    }

    @Override
    public void addPoints(Long trailId, List<TrailPointModel> points) {
        TrailModel trail = trailRepository.findById(trailId)
                .orElseThrow(() -> new IllegalArgumentException("Trail not found: " + trailId));
        for (TrailPointModel p : points) {
            p.setTrail(trail);
        }
        trailPointRepository.saveAll(points);
    }

    @Override
    public void deleteById(Long id) {
        trailRepository.deleteById(id);
    }
}