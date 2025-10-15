package com.charles.seek.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import jakarta.validation.constraints.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;

@EqualsAndHashCode(callSuper = true)
@Data
@Entity
@Table(name = "gear")
public class Gear extends BaseEntity {
    /**
     * 名称
     */
    @NotBlank(message = "名称不能为空")
    @Size(min = 1, max = 100, message = "名称长度必须在1-100个字符之间")
    @Column(name = "name", length = 100, nullable = false)
    private String name;
    /**
     * 分类
     */
    @NotBlank(message = "分类不能为空")
    @Size(min = 1, max = 50, message = "分类长度必须在1-50个字符之间")
    @Column(name = "category", length = 50, nullable = false)
    private String category;
    /**
     * 描述
     */
    @Size(max = 500, message = "描述长度不能超过500个字符")
    @Column(name = "description", length = 500)
    private String description;
    /**
     * 品牌
     */
    @Size(max = 50, message = "品牌长度不能超过50个字符")
    @Column(name = "brand", length = 50)
    private String brand;
    /**
     * 颜色
     */
    @Size(max = 10, message = "颜色长度不能超过10个字符")
    @Column(name = "color", length = 10)
    private String color;
    /**
     * 尺码 XS、S、M、L、XL、XXL、XXXL
     */
    @Size(max = 6, message = "尺码长度不能超过6个字符")
    @Column(name = "size", length = 6)
    private String size;
    /**
     * 重量
     */
    @PositiveOrZero(message = "重量不能为负数")
    @Digits(integer = 5, fraction = 2, message = "重量格式不正确")
    @Column(name = "weight", columnDefinition = "NUMERIC(7,2) DEFAULT 0.00")
    private double weight;
    /**
     * 购买/办理日期
     */
    @PastOrPresent(message = "购买日期不能是未来日期")
    @Column(name = "purchase_date", columnDefinition = "DATE DEFAULT CURRENT_DATE")
    private LocalDate purchaseDate;
    /**
     * 价格
     */
    @PositiveOrZero(message = "价格不能为负数")
    @Digits(integer = 10, fraction = 2, message = "价格格式不正确")
    @Column(name = "price", columnDefinition = "NUMERIC(12,2) DEFAULT 0.00")
    private double price;
    /**
     * 是否使用中/是否有效
     */
    @Column(name = "essential", columnDefinition = "BOOLEAN DEFAULT TRUE")
    private boolean essential;
    /**
     * 拥有数量
     */
    @Min(value = 0, message = "数量不能小于0")
    @Max(value = 999, message = "数量不能超过999")
    @Column(name = "quantity", columnDefinition = "INTEGER DEFAULT 1")
    private int quantity;

    @Column(name = "owner")
    private String owner;

    /**
     * 构造函数 - 设置默认值
     */
    public Gear() {
        this.weight = 0.00;
        this.purchaseDate = LocalDate.now();
        this.price = 0.00;
        this.essential = true;
        this.quantity = 1;
    }
}
