package com.charles.seek.controller;

import com.charles.seek.constant.GearSizeEnum;
import com.charles.seek.dto.gear.request.AddGearDto;
import com.charles.seek.dto.gear.request.EditGearDto;
import com.charles.seek.dto.gear.response.BrandDto;
import com.charles.seek.dto.gear.response.CategoryDto;
import com.charles.seek.dto.gear.response.QueryGearListDto;
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
    public ResponseEntity<List<CategoryDto>> getCategory() {
        return new ResponseEntity<>(gearService.getCategories(), HttpStatus.OK);
    }

    /**
     * 获取品牌列表
     */
    @GetMapping("/brands")
    public ResponseEntity<List<BrandDto>> getBrands() {
        return new ResponseEntity<>(gearService.getAllBrands(), HttpStatus.OK);
    }

    /**
     * 获取我的装备列表
     */
    @GetMapping("/my")
    public ResponseEntity<List<QueryGearListDto>> getMyGears(@RequestParam(name = "owner") String owner) {
        return new ResponseEntity<>(gearService.getMyGears(owner), HttpStatus.OK);
    }

    /**
     * 添加装备
     */
    @PutMapping("/add")
    public ResponseEntity<List<QueryGearListDto>> addGear(@RequestBody AddGearDto gear) {
        return new ResponseEntity<>(gearService.addGear(gear), HttpStatus.OK);
    }

    /**
     * 修改装备
     */
    @PostMapping("/edit")
    public ResponseEntity<List<QueryGearListDto>> editGear(@RequestParam Long gearId, @RequestBody EditGearDto gear) {
        return new ResponseEntity<>(gearService.editGear(gearId,gear), HttpStatus.OK);
    }
}
