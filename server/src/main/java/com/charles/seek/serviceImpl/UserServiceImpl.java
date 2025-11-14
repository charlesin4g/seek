package com.charles.seek.serviceImpl;

import com.charles.seek.dto.user.request.CreateUserRequest;
import com.charles.seek.dto.user.request.UpdateUserRequest;
import com.charles.seek.dto.user.response.UserProfile;
import com.charles.seek.model.user.UserModel;
import com.charles.seek.repository.UserRepository;
import com.charles.seek.service.OssService;
import com.charles.seek.service.UserService;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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

    /**
     * 创建新用户<br>
     * 说明：
     * <ul>
     *   <li>密码明文存储（演示用），生产请加密</li>
     *   <li>用户名、邮箱、手机号全局唯一</li>
     *   <li>头像/背景图 URL 先透传，后续可接入 OSS 校验</li>
     * </ul>
     *
     * @param request 创建用户请求
     * @return 用户资料
     * @throws DataIntegrityViolationException 用户名或邮箱冲突
     */
    @Override
    @Transactional
    public UserProfile createUser(CreateUserRequest request) {
        // 构造实体
        UserModel user = new UserModel();
        user.setUsername(request.getUsername());
        user.setPassword(request.getPassword()); // TODO: 生产环境需加密
        user.setDisplayName(request.getDisplayName() != null ? request.getDisplayName() : request.getUsername());
        user.setEmail(request.getEmail());
        user.setPhone(request.getPhone());
        user.setSex(request.getSex() != null ? request.getSex() : 0);
        user.setSignature(request.getSignature());
        user.setAvatarUrl(null);
        user.setBackgroundUrl(null);

        // 落库（唯一约束冲突会抛 DataIntegrityViolationException）
        UserModel saved = userRepository.save(user);

        // 返回 Profile（头像/背景图走 OSS 签名）
        UserProfile profile = mapper.map(saved, UserProfile.class);
        profile.setAvatarUrl(ossService.resolvePrivateUrl(profile.getAvatarUrl(), null, null));
        profile.setBackgroundUrl(ossService.resolvePrivateUrl(profile.getBackgroundUrl(), null, null));
        return profile;
    }

    /**
     * 更新用户信息<br>
     * 说明：
     * <ul>
     *   <li>只允许更新白名单字段（昵称、邮箱、手机号、性别、签名、头像、背景图）</li>
     *   <li>邮箱、手机号若修改需保证唯一</li>
     *   <li>头像/背景图 URL 先透传，后续可接入 OSS 校验</li>
     * </ul>
     *
     * @param username 用户名
     * @param request  更新用户请求
     * @return 更新后的用户资料
     */
    @Override
    @Transactional
    public UserProfile updateUser(String username, UpdateUserRequest request) {
        UserModel user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("用户不存在: " + username));

        // 白名单更新
        if (request.getDisplayName() != null) {
            user.setDisplayName(request.getDisplayName());
        }
        if (request.getEmail() != null) {
            user.setEmail(request.getEmail());
        }
        if (request.getPhone() != null) {
            user.setPhone(request.getPhone());
        }
        if (request.getSex() != null) {
            user.setSex(request.getSex());
        }
        if (request.getSignature() != null) {
            user.setSignature(request.getSignature());
        }
        if (request.getAvatarUrl() != null) {
            user.setAvatarUrl(request.getAvatarUrl());
        }
        if (request.getBackgroundUrl() != null) {
            user.setBackgroundUrl(request.getBackgroundUrl());
        }

        UserModel updated = userRepository.save(user);

        UserProfile profile = mapper.map(updated, UserProfile.class);
        profile.setAvatarUrl(ossService.resolvePrivateUrl(profile.getAvatarUrl(), null, null));
        profile.setBackgroundUrl(ossService.resolvePrivateUrl(profile.getBackgroundUrl(), null, null));
        return profile;
    }

    /**
     * 删除用户<br>
     * 说明：
     * <ul>
     *   <li>物理删除，生产可改为逻辑删除</li>
     *   <li>关联数据（活动、票据、装备、照片）由外键或业务层处理</li>
     * </ul>
     *
     * @param username 用户名
     */
    @Override
    @Transactional
    public void deleteUser(String username) {
        UserModel user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("用户不存在: " + username));
        userRepository.delete(user);
    }
}
