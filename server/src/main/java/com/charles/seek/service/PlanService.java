package com.charles.seek.service;

import com.charles.seek.model.plan.PlanModel;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface PlanService {
    PlanModel save(PlanModel plan);
    Optional<PlanModel> findById(Long id);
    List<PlanModel> findByOwner(String owner);
    List<PlanModel> findByStatus(String planStatus);
    List<PlanModel> findByDateRange(LocalDate start, LocalDate end);
    void deleteById(Long id);
}