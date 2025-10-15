package com.charles.seek.controller;

import com.charles.seek.constant.SizeEnum;
import com.charles.seek.model.Gear;
import com.charles.seek.service.GearService;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/gear")
@Tag(name = "装备管理", description = "装备相关操作")
public class GearController {

    private final GearService gearService;

    @Autowired
    public GearController(GearService gearService) {
        this.gearService = gearService;
    }

    /**
     * 获取尺码列表
     */
    @GetMapping("/sizes")
    public ResponseEntity<List<String>> getSizes() {
        return new ResponseEntity<>(SizeEnum.getSizeCodes(), HttpStatus.OK);
    }

    @GetMapping
    public ResponseEntity<List<Gear>> getMyGears(String owner) {
        return new ResponseEntity<>(gearService.getMyGears(owner), HttpStatus.OK);
    }
}
