package com.charles.seek.controller;

import com.charles.seek.model.ticket.TrainStationModel;
import com.charles.seek.service.TrainStationService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/ticket")
@RequiredArgsConstructor
@Validated
@Tag(name = "火车站管理", description = "火车站信息相关接口")
public class TrainStationController {

    private final TrainStationService stationService;

    /**
     * 新增火车站
     */
    @PostMapping("/station/add")
    public ResponseEntity<TrainStationModel> addStation(@Valid @RequestBody TrainStationModel req) {
        String code = req.getStationCode();
        if (code == null || code.trim().isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        String normalized = code.trim().toUpperCase();
        if (stationService.existsByCode(normalized)) {
            return ResponseEntity.status(409).build();
        }
        req.setStationCode(normalized);
        TrainStationModel saved = stationService.save(req);
        return ResponseEntity.ok(saved);
    }

    /**
     * 根据代码查询火车站
     */
    @GetMapping("/station")
    public ResponseEntity<TrainStationModel> getByCode(
            @RequestParam(name = "code") @NotBlank @Size(max = 10) String code) {
        String normalized = code.trim().toUpperCase();
        return stationService.findByCode(normalized)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    /**
     * 模糊搜索火车站（按名称或城市）
     */
    @GetMapping("/station/search")
    public ResponseEntity<List<TrainStationModel>> search(
            @RequestParam(name = "keyword", required = false) @Size(max = 100) String keyword) {
        return ResponseEntity.ok(stationService.searchByKeyword(keyword));
    }
}