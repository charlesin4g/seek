package com.charles.seek.service;

import com.charles.seek.dto.photo.request.AddUserPhotoRequest;
import com.charles.seek.dto.photo.response.UserPhotoItem;

import java.util.List;

/**
 * 用户照片服务接口
 *
 * 说明：业务逻辑在服务层实现，控制器只调用这些方法。
 */
public interface UserPhotoService {
    /** 新增用户照片 */
    UserPhotoItem addPhoto(AddUserPhotoRequest request);

    /** 按所属用户查询照片（按创建时间倒序） */
    List<UserPhotoItem> listByOwner(String owner);

    /** 根据ID删除照片 */
    void deleteById(Long id);
}