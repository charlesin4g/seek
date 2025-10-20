package com.charles.seek.dto.gear.response;

import lombok.Data;

@Data
public class QueryGearListDto {
    private String id;
    private String name;
    private String category;
    private double weight;
    private String brand;
    /**
     * 这里购入时间转换成yy-mm形式
     */
    private String purchaseDate;
    private double price;
    private int quantity;
}
