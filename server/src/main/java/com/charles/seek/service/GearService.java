package com.charles.seek.service;

import com.charles.seek.dto.gear.request.AddGearRequest;
import com.charles.seek.dto.gear.request.EditGearRequest;
import com.charles.seek.dto.gear.response.BrandResponse;
import com.charles.seek.dto.gear.response.CategoryResponse;
import com.charles.seek.dto.gear.response.QueryGearListResponse;

import java.util.List;


public interface GearService {

    List<BrandResponse> getAllBrands();

    List<QueryGearListResponse> getMyGears(String owner);

    List<CategoryResponse> getCategories();

    List<QueryGearListResponse> addGear(AddGearRequest gear);

    List<QueryGearListResponse> editGear(Long gearId, EditGearRequest gear);
}
