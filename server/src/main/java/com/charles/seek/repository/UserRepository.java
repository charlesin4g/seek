package com.charles.seek.repository;

import com.charles.seek.model.user.UserModel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<UserModel, Long> {
    /**
     * 根据用户名获取用户详细信息
     */
    Optional<UserModel> findByUsername(String username);
}
