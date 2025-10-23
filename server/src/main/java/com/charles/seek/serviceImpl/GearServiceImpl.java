package com.charles.seek.serviceImpl;

import com.charles.seek.constant.GearCategoryEnum;
import com.charles.seek.dto.gear.request.AddGearRequest;
import com.charles.seek.dto.gear.request.EditGearRequest;
import com.charles.seek.dto.gear.response.BrandResponse;
import com.charles.seek.dto.gear.response.CategoryResponse;
import com.charles.seek.dto.gear.response.QueryGearListResponse;
import com.charles.seek.model.gear.GearModel;
import com.charles.seek.repository.BrandRepository;
import com.charles.seek.repository.GearRepository;
import com.charles.seek.service.GearService;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class GearServiceImpl implements GearService {

    private final GearRepository gearRepository;
    private final BrandRepository brandRepository;
    private final ModelMapper mapper;

    /**
     * 获取所有品牌列表
     */
    @Override
    public List<BrandResponse> getAllBrands() {
        var brands = brandRepository.findAll(Sort.by(Sort.Direction.ASC, "sequence"));
        return brands.stream().map(b -> mapper.map(b, BrandResponse.class)).collect(Collectors.toList());
    }

    /**
     * 获取我的装备
     */
    @Override
    public List<QueryGearListResponse> getMyGears(String owner) {
        var gears = gearRepository.findByOwner(owner);
        return gears.stream()
                .map(g -> {
                    var dto = mapper.map(g, QueryGearListResponse.class);
                    dto.setName(g.getName());
                    dto.setPurchaseDate(g.getSimplePurchaseDate());
                    return dto;
                })
                .collect(Collectors.toList());
    }

    /**
     * 新增装备
     */
    @Override
    public List<QueryGearListResponse> addGear(AddGearRequest gear) {
        var newGear = mapper.map(gear, GearModel.class);
        var result = gearRepository.save(newGear);
        if (result.getId() != null) {
            return this.getMyGears(result.getOwner());
        }
        return null;
    }

    @Override
    public List<QueryGearListResponse> editGear(Long gearId, EditGearRequest gear) {
        var model = gearRepository.findById(gearId)
                .orElseThrow(() -> new RuntimeException("装备不存在: " + gear.getName()));
        mapper.map(gear, model);
        gearRepository.save(model);
        return this.getMyGears(model.getOwner());
    }

    @Override
    public List<CategoryResponse> getCategories() {
        return Arrays.stream(GearCategoryEnum.values())
                .map(enumValue -> new CategoryResponse(enumValue.getCode(), enumValue.getName()))
                .collect(Collectors.toList());
    }
}
