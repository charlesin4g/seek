package com.charles.seek.repository;

import com.charles.seek.model.trail.TrailModel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TrailRepository extends JpaRepository<TrailModel, Long> {
    List<TrailModel> findByOwnerOrderByStartTimeDesc(String owner);
}