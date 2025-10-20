package com.charles.seek.dto.gear.request;

import com.charles.seek.constant.SizeEnum;
import lombok.Data;

import java.time.LocalDate;

@Data
public class addGear {
    private String name;
    private String description;
    private String category;
    private String brand;
    private String color;
    private String size;
    private double weight;
    private LocalDate purchaseDate;
    private double price;
    private boolean essential = true;
    private int quantity;
}
