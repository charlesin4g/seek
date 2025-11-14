package com.charles.seek.controller;

import com.charles.seek.dto.user.request.CreateUserRequest;
import com.charles.seek.dto.user.request.UpdateUserRequest;
import com.charles.seek.dto.user.response.UserProfile;
import com.charles.seek.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/user")
@Tag(name = "用户管理", description = "用户相关操作")
public class UserController {

    private final UserService userService;

    @PostMapping("/login")
    @Operation(summary = "用户登录", description = "使用用户名+密码登录，返回用户资料")
    public ResponseEntity<UserProfile> login(
            @Parameter(description = "用户名", example = "alice") @RequestParam("username") String username,
            @Parameter(description = "密码", example = "123456") @RequestParam("password") String password) {
        boolean check = userService.checkPassword(username, password);
        if (check) {
            return ResponseEntity.ok(userService.getByUsername(username));
        } else {
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * 根据用户名获取用户资料
     */
    @GetMapping("/{username}")
    @Operation(summary = "获取用户资料", description = "根据用户名查询用户公开资料")
    public ResponseEntity<UserProfile> getProfile(
            @Parameter(description = "用户名", example = "alice") @PathVariable("username") String username) {
        return ResponseEntity.ok(userService.getByUsername(username));
    }

    /**
     * 创建用户
     */
    @PostMapping
    @Operation(summary = "创建用户", description = "注册新用户账户，用户名、邮箱、手机号全局唯一")
    public ResponseEntity<UserProfile> createUser(@Valid @RequestBody CreateUserRequest request) {
        UserProfile profile = userService.createUser(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(profile);
    }

    /**
     * 更新用户
     */
    @PutMapping("/{username}")
    @Operation(summary = "更新用户", description = "更新指定用户的信息，支持白名单字段")
    public ResponseEntity<UserProfile> updateUser(
            @Parameter(description = "用户名", example = "alice") @PathVariable("username") String username,
            @Valid @RequestBody UpdateUserRequest request) {
        UserProfile profile = userService.updateUser(username, request);
        return ResponseEntity.ok(profile);
    }

    /**
     * 删除用户
     */
    @DeleteMapping("/{username}")
    @Operation(summary = "删除用户", description = "删除指定用户账户及关联数据（物理删除）")
    public ResponseEntity<Void> deleteUser(
            @Parameter(description = "用户名", example = "alice") @PathVariable("username") String username) {
        userService.deleteUser(username);
        return ResponseEntity.noContent().build();
    }
}
