package com.charles.seek.controller;

import com.charles.seek.constant.GearSizeEnum;
import com.charles.seek.dto.gear.request.AddGearRequest;
import com.charles.seek.dto.gear.request.EditGearRequest;
import com.charles.seek.dto.gear.response.BrandResponse;
import com.charles.seek.dto.gear.response.CategoryResponse;
import com.charles.seek.dto.gear.response.QueryGearListResponse;
import com.charles.seek.service.GearService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/gear")
@RequiredArgsConstructor
@Tag(name = "装备管理", description = "装备相关操作")
public class GearController {

    private final GearService gearService;

    /**
     * 获取尺码列表
     */
    @GetMapping("/sizes")
    public ResponseEntity<List<String>> getSizes() {
        return new ResponseEntity<>(GearSizeEnum.getSizeCodes(), HttpStatus.OK);
    }

    /**
     * 获取装备分类列表
     *
     * @return
     */
    @GetMapping("/category")
    public ResponseEntity<List<CategoryResponse>> getCategory() {
        return new ResponseEntity<>(gearService.getCategories(), HttpStatus.OK);
    }

    /**
     * 获取品牌列表
     */
    @GetMapping("/brands")
    public ResponseEntity<List<BrandResponse>> getBrands() {
        return new ResponseEntity<>(gearService.getAllBrands(), HttpStatus.OK);
    }

    /**
     * 获取我的装备列表
     */
    @GetMapping("/my")
    public ResponseEntity<List<QueryGearListResponse>> getMyGears(@RequestParam(name = "owner") String owner) {
        return new ResponseEntity<>(gearService.getMyGears(owner), HttpStatus.OK);
    }

    /**
     * 添加装备
     */
    @PutMapping("/add")
    public ResponseEntity<List<QueryGearListResponse>> addGear(@RequestBody AddGearRequest gear) {
        return new ResponseEntity<>(gearService.addGear(gear), HttpStatus.OK);
    }

    /**
     * 修改装备
     */
    @PostMapping("/edit")
    public ResponseEntity<List<QueryGearListResponse>> editGear(@RequestParam("gearId") Long gearId, @RequestBody EditGearRequest gear) {
        return new ResponseEntity<>(gearService.editGear(gearId,gear), HttpStatus.OK);
    }
}
