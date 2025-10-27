package com.charles.seek.controller;

import com.charles.seek.dto.photo.request.AddUserPhotoRequest;
import com.charles.seek.dto.photo.response.UserPhotoItem;
import com.charles.seek.service.UserPhotoService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 用户照片控制器
 *
 * 说明：
 * - 控制器仅负责接收参数并调用服务层方法；
 * - 业务逻辑（OSS URL 解析/签名、实体转换等）在服务层处理。
 */
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/photo")
@Tag(name = "用户照片", description = "用户照片墙相关接口")
public class UserPhotoController {

    private final UserPhotoService photoService;

    /** 新增用户照片 */
    @PostMapping("/add")
    public ResponseEntity<UserPhotoItem> add(@Valid @RequestBody AddUserPhotoRequest request) {
        return ResponseEntity.ok(photoService.addPhoto(request));
    }

    /** 按所属用户查询照片（按创建时间倒序） */
    @GetMapping("/owner/{owner}")
    public ResponseEntity<List<UserPhotoItem>> listByOwner(
            @PathVariable("owner") @NotBlank @Size(max = 50) String owner) {
        return ResponseEntity.ok(photoService.listByOwner(owner));
    }

    /** 根据ID删除照片 */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable("id") Long id) {
        photoService.deleteById(id);
        return ResponseEntity.ok().build();
    }
}