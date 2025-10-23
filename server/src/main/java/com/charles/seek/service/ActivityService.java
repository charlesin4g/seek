package com.charles.seek.service;

import com.charles.seek.constant.ActivityTypeEnum;
import com.charles.seek.dto.activity.request.AddActivityRequest;
import com.charles.seek.dto.activity.request.EditActivityRequest;
import com.charles.seek.dto.activity.response.QueryActivityResponse;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface ActivityService {
    QueryActivityResponse create(AddActivityRequest request);
    Optional<QueryActivityResponse> update(Long id, EditActivityRequest request);
    Optional<QueryActivityResponse> getById(Long id);
    List<QueryActivityResponse> listAll();
    List<QueryActivityResponse> listByType(ActivityTypeEnum type);
    List<QueryActivityResponse> listByTimeRange(LocalDateTime start, LocalDateTime end);
    List<QueryActivityResponse> listByOwner(String owner);
    void deleteById(Long id);
}