package com.charles.seek.controller;

import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/trail")
@RequiredArgsConstructor
@Tag(name = "轨迹管理", description = "轨迹相关操作")
public class TrailController {
}
