package com.charles.seek.constant;

import lombok.Getter;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@Getter
public enum GearCategoryEnum {
    Sleeping("Sleeping", "睡眠系统"),
    CarryingSystem("CarryingSystem", "背负系统"),
    Clothing("Clothing", "服装"),
    CookingEquipment("CookingEquipment", "炊事工具"),
    Photography("Photography", "摄影系统"),
    Auxiliary("Auxiliary", "辅助工具"),
    Food("Food", "食物"),
    Identification("Identification", "证件");

    // 代码
    private final String code;
    // 中文描述
    private final String name;

    GearCategoryEnum(String code, String name) {
        this.code = code;
        this.name = name;
    }

    /**
     * 获取所有分类列表
     */
    public static List<String> getCategories() {
        return Arrays.stream(values())
                .map(GearCategoryEnum::getName)
                .collect(Collectors.toList());
    }
}
