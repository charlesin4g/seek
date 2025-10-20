package com.charles.seek.controller;

import com.charles.seek.dto.user.response.UserProfile;
import com.charles.seek.service.UserService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/user")
@Tag(name = "用户管理", description = "用户相关操作")
public class UserController {

    private final UserService userService;

    @PostMapping("/login")
    public ResponseEntity<UserProfile> login(@RequestParam(name = "username") String username, @RequestParam(name = "password") String password) {
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
    public ResponseEntity<UserProfile> getProfile(@PathVariable("username") String username) {
        return ResponseEntity.ok().body(userService.getByUsername(username));
    }
}
