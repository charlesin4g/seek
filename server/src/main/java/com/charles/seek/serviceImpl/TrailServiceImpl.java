package com.charles.seek.serviceImpl;

import com.charles.seek.model.trail.TrailModel;
import com.charles.seek.model.trail.TrailPointModel;
import com.charles.seek.repository.TrailPointRepository;
import com.charles.seek.repository.TrailRepository;
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

    @Override
    public TrailModel saveTrail(TrailModel trail) {
        // 级联保存 points（如已设置）
        return trailRepository.save(trail);
    }

    @Override
    public Optional<TrailModel> findById(Long id) {
        return trailRepository.findById(id);
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