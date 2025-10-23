package com.charles.seek.serviceImpl;

import com.charles.seek.constant.ActivityTypeEnum;
import com.charles.seek.dto.activity.request.AddActivityRequest;
import com.charles.seek.dto.activity.request.EditActivityRequest;
import com.charles.seek.dto.activity.response.QueryActivityResponse;
import com.charles.seek.model.activity.ActivityModel;
import com.charles.seek.repository.ActivityRepository;
import com.charles.seek.service.ActivityService;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ActivityServiceImpl implements ActivityService {

    private final ActivityRepository activityRepository;
    private final ModelMapper mapper;

    @Override
    public QueryActivityResponse create(AddActivityRequest request) {
        ActivityModel model = mapper.map(request, ActivityModel.class);
        ActivityModel saved = activityRepository.save(model);
        return mapper.map(saved, QueryActivityResponse.class);
    }

    @Override
    public Optional<QueryActivityResponse> update(Long id, EditActivityRequest request) {
        return activityRepository.findById(id).map(existing -> {
            // 更新字段（严格映射，null 跳过由 ModelMapperConfig 控制）
            mapper.map(request, existing);
            ActivityModel saved = activityRepository.save(existing);
            return mapper.map(saved, QueryActivityResponse.class);
        });
    }

    @Override
    public Optional<QueryActivityResponse> getById(Long id) {
        return activityRepository.findById(id)
                .map(a -> mapper.map(a, QueryActivityResponse.class));
    }

    @Override
    public List<QueryActivityResponse> listAll() {
        return activityRepository.findAll().stream()
                .sorted((a, b) -> {
                    LocalDateTime ta = a.getActivityTime();
                    LocalDateTime tb = b.getActivityTime();
                    if (ta == null && tb == null) return 0;
                    if (ta == null) return 1;
                    if (tb == null) return -1;
                    return tb.compareTo(ta);
                })
                .map(a -> mapper.map(a, QueryActivityResponse.class))
                .collect(Collectors.toList());
    }

    @Override
    public List<QueryActivityResponse> listByType(ActivityTypeEnum type) {
        return activityRepository.findByTypeOrderByActivityTimeDesc(type).stream()
                .map(a -> mapper.map(a, QueryActivityResponse.class))
                .collect(Collectors.toList());
    }

    @Override
    public List<QueryActivityResponse> listByTimeRange(java.time.LocalDateTime start, java.time.LocalDateTime end) {
        return activityRepository.findByActivityTimeBetweenOrderByActivityTimeDesc(start, end).stream()
                .map(a -> mapper.map(a, QueryActivityResponse.class))
                .collect(Collectors.toList());
    }

    @Override
    public List<QueryActivityResponse> listByOwner(String owner) {
        return activityRepository.findByOwnerOrderByActivityTimeDesc(owner)
                .stream()
                .map(a -> mapper.map(a, QueryActivityResponse.class))
                .collect(Collectors.toList());
    }

    @Override
    public void deleteById(Long id) {
        activityRepository.deleteById(id);
    }



    private static Integer parseInt(String s, int def) {
        try {
            if (s == null || s.isBlank()) return def;
            return (int) Math.round(Double.parseDouble(s.trim()));
        } catch (Exception e) { return def; }
    }

    private static Double parseDouble(String s, double def) {
        try {
            if (s == null || s.isBlank()) return def;
            return Double.parseDouble(s.trim());
        } catch (Exception e) { return def; }
    }

    private static Double parseNullableDouble(String s) {
        try {
            if (s == null || s.isBlank()) return null;
            return Double.parseDouble(s.trim());
        } catch (Exception e) { return null; }
    }

    private static LocalDateTime parseDateTime(String s, java.time.format.DateTimeFormatter... fmts) {
        if (s == null || s.isBlank()) return null;
        for (var f : fmts) {
            try {
                return LocalDateTime.parse(s.trim(), f);
            } catch (Exception ignored) {}
        }
        // 尝试 ISO_LOCAL_DATE_TIME
        try { return LocalDateTime.parse(s.trim()); } catch (Exception ignored) {}
        return null;
    }

    private static ActivityTypeEnum parseType(String s) {
        if (s == null || s.isBlank()) return null;
        String v = s.trim();
        for (ActivityTypeEnum e : ActivityTypeEnum.values()) {
            if (e.getName().equalsIgnoreCase(v) || e.getCode().equalsIgnoreCase(v) || e.name().equalsIgnoreCase(v)) {
                return e;
            }
        }
        // 简单兼容中文关键词
        if (v.contains("远足")) return ActivityTypeEnum.Hike;
        if (v.contains("跑")) return ActivityTypeEnum.Run;
        if (v.contains("骑")) return ActivityTypeEnum.Cycle;
        if (v.contains("游")) return ActivityTypeEnum.Swim;
        return null;
    }
}