package com.charles.seek.repository;

import com.charles.seek.model.user.UserPhotoModel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 用户照片仓库
 *
 * 说明：仅提供数据访问方法，业务逻辑由服务层处理。
 */
@Repository
public interface UserPhotoRepository extends JpaRepository<UserPhotoModel, Long> {
    /** 按所属用户查询照片（按创建时间倒序） */
    List<UserPhotoModel> findByOwnerOrderByCreatedAtDesc(String owner);
}