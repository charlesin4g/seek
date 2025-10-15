package com.charles.seek.repository;

import com.charles.seek.model.Gear;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GearRepository extends JpaRepository<Gear, Long> {
    // 根据装备所属人员进行查找
    List<Gear> findByOwner(String owner);

    // 根据类别查找装备
    List<Gear> findByCategory(String category);

    // 查找必需品
    List<Gear> findByEssential(boolean essential);

    // 根据品牌查找
    List<Gear> findByBrand(String brand);

    // 根据重量范围查找
    List<Gear> findByWeightBetween(double minWeight, double maxWeight);


}
