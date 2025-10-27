package com.charles.seek.model.ticket;

import com.charles.seek.model.BaseEntity;
import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.Comment;

@EqualsAndHashCode(callSuper = true)
@Data
@Entity
@Table(name = "train_station",
        indexes = {
                @Index(name = "idx_station_code", columnList = "station_code"),
                @Index(name = "idx_station_city", columnList = "city")
        })
public class TrainStationModel extends BaseEntity {

    /**
     * 车站代码（电报码/简码），如 SHH、BJP
     */
    @NotBlank(message = "车站代码不能为空")
    @Size(min = 2, max = 10, message = "车站代码长度需在2-10之间")
    @Column(name = "station_code", length = 10, nullable = false, unique = true)
    @Comment("车站代码（电报码/简码），如 SHH、BJP")
    private String stationCode;

    /**
     * 车站名称
     */
    @NotBlank(message = "车站名称不能为空")
    @Size(max = 100, message = "车站名称长度不能超过100个字符")
    @Column(name = "name", length = 100, nullable = false)
    @Comment("车站名称")
    private String name;

    /**
     * 所在城市
     */
    @Size(max = 100, message = "城市名称长度不能超过100个字符")
    @Column(name = "city", length = 100)
    @Comment("所在城市")
    private String city;

    /**
     * 国家/地区
     */
    @Size(max = 100, message = "国家名称长度不能超过100个字符")
    @Column(name = "country", length = 100)
    @Comment("国家/地区")
    private String country;

    /**
     * 时区，例如 Asia/Shanghai
     */
    @Size(max = 50, message = "时区标识长度不能超过50个字符")
    @Column(name = "timezone", length = 50)
    @Comment("时区，如 Asia/Shanghai")
    private String timezone;

    /**
     * 纬度
     */
    @DecimalMin(value = "-90.0", message = "纬度范围应在[-90,90]")
    @DecimalMax(value = "90.0", message = "纬度范围应在[-90,90]")
    @Column(name = "latitude", columnDefinition = "DOUBLE PRECISION")
    // 使用 DOUBLE PRECISION 避免 Hibernate 对浮点类型设置 scale 报错
    @Comment("纬度")
    private Double latitude;

    /**
     * 经度
     */
    @DecimalMin(value = "-180.0", message = "经度范围应在[-180,180]")
    @DecimalMax(value = "180.0", message = "经度范围应在[-180,180]")
    @Column(name = "longitude", columnDefinition = "DOUBLE PRECISION")
    // 使用 DOUBLE PRECISION 避免 Hibernate 对浮点类型设置 scale 报错
    @Comment("经度")
    private Double longitude;

    /**
     * 海拔(米)
     */
    @PositiveOrZero(message = "海拔不能为负数")
    @Column(name = "elevation", columnDefinition = "DOUBLE PRECISION")
    // 使用 DOUBLE PRECISION 避免 Hibernate 对浮点类型设置 scale 报错
    @Comment("海拔(米)")
    private Double elevation;
}