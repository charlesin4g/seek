package com.charles.seek.serviceImpl;

import com.charles.seek.model.plan.PlanModel;
import com.charles.seek.repository.PlanRepository;
import com.charles.seek.service.PlanService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class PlanServiceImpl implements PlanService {

    private final PlanRepository planRepository;

    @Override
    public PlanModel save(PlanModel plan) {
        return planRepository.save(plan);
    }

    @Override
    public Optional<PlanModel> findById(Long id) {
        return planRepository.findById(id);
    }

    @Override
    public List<PlanModel> findByOwner(String owner) {
        return planRepository.findByOwnerOrderByDateAsc(owner);
    }

    @Override
    public List<PlanModel> findByStatus(String planStatus) {
        return planRepository.findByPlanStatusOrderByDateAsc(planStatus);
    }

    @Override
    public List<PlanModel> findByDateRange(LocalDate start, LocalDate end) {
        return planRepository.findByDateBetweenOrderByDateAsc(start, end);
    }

    @Override
    public void deleteById(Long id) {
        planRepository.deleteById(id);
    }
}