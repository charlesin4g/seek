package com.charles.seek.controller;

import com.charles.seek.dto.trail.request.AddTrailRequest;
import com.charles.seek.dto.trail.request.EditTrailRequest;
import com.charles.seek.model.trail.TrailModel;
import com.charles.seek.service.TrailService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/trail")
@RequiredArgsConstructor
@Tag(name = "轨迹管理", description = "轨迹相关操作")
public class TrailController {
    private final TrailService trailService;

    @GetMapping("/activity/{activityId}")
    public List<TrailModel> listByActivity(@PathVariable("activityId") Long activityId) {
        return trailService.findByActivityId(activityId);
    }

    @PostMapping
    public ResponseEntity<TrailModel> create(@Valid @RequestBody AddTrailRequest request) {
        return ResponseEntity.ok(trailService.create(request));
    }

    @PutMapping("/{id}")
    public ResponseEntity<TrailModel> update(@PathVariable("id") Long id,
                                             @Valid @RequestBody EditTrailRequest request) {
        return trailService.update(id, request)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

}
