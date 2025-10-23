package com.charles.seek.dto.gear.response;

import lombok.Data;

@Data
public class CategoryResponse {
    private String code;
    private String name;

    public CategoryResponse(String code, String name) {
        this.code = code;
        this.name = name;
    }
}
