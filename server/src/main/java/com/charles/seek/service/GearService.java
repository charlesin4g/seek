package com.charles.seek.service;

import com.charles.seek.model.Gear;
import com.charles.seek.repository.GearRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class GearService {

    private final GearRepository gearRepository;

    public List<Gear> getMyGears(String owner) {
        return gearRepository.findByOwner(owner);
    }

    // 获取所有装备
    public List<Gear> getAllGear() {
        return gearRepository.findAll();
    }

    // 根据ID获取装备
    public Optional<Gear> getGearById(Long id) {
        return gearRepository.findById(id);
    }

    // 添加新装备
    public Gear addGear(Gear gear) {
        return gearRepository.save(gear);
    }

    // 删除装备
    public void deleteGear(Long id) {
        gearRepository.deleteById(id);
    }

    // 根据类别获取装备
    public List<Gear> getGearByCategory(String category) {
        return gearRepository.findByCategory(category);
    }

    // 获取所有必需品
    public List<Gear> getEssentialGear() {
        return gearRepository.findByEssential(true);
    }

    // 根据品牌获取装备
    public List<Gear> getGearByBrand(String brand) {
        return gearRepository.findByBrand(brand);
    }

    // 根据重量范围获取装备
    public List<Gear> getGearByWeightRange(double min, double max) {
        return gearRepository.findByWeightBetween(min, max);
    }
}
