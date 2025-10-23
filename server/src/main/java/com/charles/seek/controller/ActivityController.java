package com.charles.seek.controller;

import com.charles.seek.constant.ActivityTypeEnum;
import com.charles.seek.dto.activity.request.AddActivityRequest;
import com.charles.seek.dto.activity.request.EditActivityRequest;
import com.charles.seek.dto.activity.response.QueryActivityResponse;
import com.charles.seek.service.ActivityService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/activity")
@RequiredArgsConstructor
public class ActivityController {

    private final ActivityService activityService;

    @PostMapping
    public ResponseEntity<QueryActivityResponse> create(@RequestBody AddActivityRequest request) {
        QueryActivityResponse response = activityService.create(request);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Optional<QueryActivityResponse>> update(@PathVariable Long id, @RequestBody EditActivityRequest request) {
        Optional<QueryActivityResponse> response = activityService.update(id, request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Optional<QueryActivityResponse>> getById(@PathVariable Long id) {
        return ResponseEntity.ok(activityService.getById(id));
    }

    @GetMapping("/list")
    public ResponseEntity<List<QueryActivityResponse>> listAll() {
        return ResponseEntity.ok(activityService.listAll());
    }

    @GetMapping("/type/{type}")
    public ResponseEntity<List<QueryActivityResponse>> listByType(@PathVariable ActivityTypeEnum type) {
        return ResponseEntity.ok(activityService.listByType(type));
    }

    @GetMapping("/time")
    public ResponseEntity<List<QueryActivityResponse>> listByTimeRange(@RequestParam LocalDateTime start,
                                                                       @RequestParam LocalDateTime end) {
        return ResponseEntity.ok(activityService.listByTimeRange(start, end));
    }

    @GetMapping("/owner/{owner}")
    public ResponseEntity<List<QueryActivityResponse>> listByOwner(@PathVariable String owner) {
        return ResponseEntity.ok(activityService.listByOwner(owner));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        activityService.deleteById(id);
        return ResponseEntity.ok().build();
    }

}