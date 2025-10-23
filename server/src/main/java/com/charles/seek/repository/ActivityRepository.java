package com.charles.seek.repository;

import com.charles.seek.constant.ActivityTypeEnum;
import com.charles.seek.model.activity.ActivityModel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ActivityRepository extends JpaRepository<ActivityModel, Long> {
    List<ActivityModel> findByActivityTimeBetweenOrderByActivityTimeDesc(LocalDateTime start, LocalDateTime end);
    List<ActivityModel> findByTypeOrderByActivityTimeDesc(ActivityTypeEnum type);
    List<ActivityModel> findByOwnerOrderByActivityTimeDesc(String owner);
}