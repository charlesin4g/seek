package com.charles.seek.repository;

import com.charles.seek.model.trail.TrailPointModel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TrailPointRepository extends JpaRepository<TrailPointModel, Long> {
    List<TrailPointModel> findByTrail_IdOrderByTimestampAscSequenceAsc(Long trailId);
}