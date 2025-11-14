package com.charles.seek.service;

import com.charles.seek.dto.user.request.CreateUserRequest;
import com.charles.seek.dto.user.request.UpdateUserRequest;
import com.charles.seek.dto.user.response.UserProfile;

public interface UserService {

    boolean checkPassword(String username, String password);

    UserProfile getByUsername(String username);

    /**
     * 创建新用户
     * 
     * @param request 创建用户请求
     * @return 用户资料
     */
    UserProfile createUser(CreateUserRequest request);

    /**
     * 更新用户信息
     * 
     * @param username 用户名
     * @param request  更新用户请求
     * @return 更新后的用户资料
     */
    UserProfile updateUser(String username, UpdateUserRequest request);

    /**
     * 删除用户
     * 
     * @param username 用户名
     */
    void deleteUser(String username);
}
