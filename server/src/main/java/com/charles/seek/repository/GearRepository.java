package com.charles.seek.repository;

import com.charles.seek.model.gear.GearModel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GearRepository extends JpaRepository<GearModel, Long> {
    // 根据装备所属人员进行查找
    List<GearModel> findByOwner(String owner);

}
