package com.charles.seek.constant;

import lombok.Getter;

@Getter
public enum ActivityTypeEnum {
    Hike("Hike", "远足"),
    Cycle("Cycle", "骑行"),
    Run("Run", "跑步"),
    Swim("Swim", "游泳");

    private final String code;
    private final String name;

    ActivityTypeEnum(String code, String name) {
        this.code = code;
        this.name = name;
    }
}