package com.charles.seek.dto.user.mapper;

import com.charles.seek.dto.user.response.UserProfile;
import com.charles.seek.model.User;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")  // 只使用Spring组件模型
public interface UserMapper {

    @Mapping(source = "id", target = "userId")
    UserProfile toUserProfile(User user);
}
