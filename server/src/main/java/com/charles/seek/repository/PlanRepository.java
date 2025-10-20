package com.charles.seek.repository;

import com.charles.seek.model.plan.PlanModel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface PlanRepository extends JpaRepository<PlanModel, Long> {
    List<PlanModel> findByOwnerOrderByDateAsc(String owner);
    List<PlanModel> findByPlanStatusOrderByDateAsc(String planStatus);
    List<PlanModel> findByDateBetweenOrderByDateAsc(LocalDate start, LocalDate end);
}