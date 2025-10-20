package com.charles.seek.constant;

import lombok.Getter;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@Getter
public enum GearSizeEnum {
    // 国际通用尺码
    XS("XS", "超小号", "Extra Small"),
    S("S", "小号", "Small"),
    M("M", "中号", "Medium"),
    L("L", "大号", "Large"),
    XL("XL", "加大号", "Extra Large"),
    XXL("XXL", "双加大号", "Double Extra Large"),
    XXXL("XXXL", "三加大号", "Triple Extra Large"),

    // 特殊尺码
    FREE("FREE", "均码", "Free Size"),
    CUSTOM("CUSTOM", "定制", "Custom Size");

    // 尺码代码
    private final String code;
    // 中文描述
    private final String chineseName;
    // 英文描述
    private final String englishName;

    GearSizeEnum(String code, String chineseName, String englishName) {
        this.code = code;
        this.chineseName = chineseName;
        this.englishName = englishName;
    }

    /**
     * 获取所有尺码的code列表
     * @return 包含所有枚举值code的List
     */
    public static List<String> getSizeCodes() {
        return Arrays.stream(values())
                .map(GearSizeEnum::getCode)
                .collect(Collectors.toList());
    }
}
