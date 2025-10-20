package com.charles.seek.dto.gear.response;

import lombok.Data;

@Data
public class CategoryDto {
    private String code;
    private String name;

    public CategoryDto(String code, String name) {
        this.code = code;
        this.name = name;
    }
}
