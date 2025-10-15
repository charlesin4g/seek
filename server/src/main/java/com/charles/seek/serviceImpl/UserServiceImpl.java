package com.charles.seek.serviceImpl;

import com.charles.seek.dto.user.mapper.UserMapper;
import com.charles.seek.dto.user.response.UserProfile;
import com.charles.seek.repository.UserRepository;
import com.charles.seek.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final UserMapper userMapper;

    /**
     * 验证密码
     */
    @Override
    public boolean checkPassword(String username, String password) {
        var user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("用户不存在: " + username));
        return user.getPassword().equals(password);
    }

    /**
     * 根据用户名获取用户相信信息
     */
    @Override
    public UserProfile getByUsername(String username) {
        var user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("用户不存在: " + username));

        return userMapper.toUserProfile(user);
    }
}
