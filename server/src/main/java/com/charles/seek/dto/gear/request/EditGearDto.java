package com.charles.seek.dto.gear.request;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class AddGearDto {
    private String name;
    private String description;
    private String category;
    private String brand;
    private String color;
    private String size;
    private double weight;
    private LocalDateTime purchaseDate;
    private double price;
    private boolean essential = true;
    private int quantity;
    private Long owner;
}
