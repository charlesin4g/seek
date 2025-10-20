package com.charles.seek.service;

import com.charles.seek.dto.gear.request.AddGearDto;
import com.charles.seek.dto.gear.request.EditGearDto;
import com.charles.seek.dto.gear.response.BrandDto;
import com.charles.seek.dto.gear.response.CategoryDto;
import com.charles.seek.dto.gear.response.QueryGearListDto;

import java.util.List;


public interface GearService {

    List<BrandDto> getAllBrands();

    List<QueryGearListDto> getMyGears(String owner);

    List<CategoryDto> getCategories();

    List<QueryGearListDto> addGear(AddGearDto gear);

    List<QueryGearListDto> editGear(Long gearId,EditGearDto gear);
}
