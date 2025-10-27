package com.charles.seek.serviceImpl;

import com.charles.seek.dto.user.response.UserProfile;
import com.charles.seek.repository.UserRepository;
import com.charles.seek.service.OssService;
import com.charles.seek.service.UserService;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final ModelMapper mapper;
    private final OssService ossService;

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
        // 基本信息映射
        UserProfile profile = mapper.map(user, UserProfile.class);
        // 头像与背景图使用后端生成的临时签名 URL（若为绝对 URL 则原样返回）
        // 业务逻辑：统一走 OssService，controller 不处理业务
        profile.setAvatarUrl(ossService.resolvePrivateUrl(profile.getAvatarUrl(), null, null));
        profile.setBackgroundUrl(ossService.resolvePrivateUrl(profile.getBackgroundUrl(), null, null));
        return profile;
    }
}
