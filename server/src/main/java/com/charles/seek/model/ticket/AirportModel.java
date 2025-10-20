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
@Table(name = "airport",
        indexes = {
                @Index(name = "idx_airport_iata", columnList = "iata_code"),
                @Index(name = "idx_airport_icao", columnList = "icao_code"),
                @Index(name = "idx_airport_city", columnList = "city")
        })
public class AirportModel extends BaseEntity {

    @NotBlank(message = "IATA代码不能为空")
    @Size(min = 3, max = 3, message = "IATA代码必须为3位")
    @Column(name = "iata_code", length = 3, nullable = false, unique = true)
    @Comment("IATA三字码，例如 PVG、PEK")
    private String iataCode;

    @Size(min = 4, max = 4, message = "ICAO代码必须为4位")
    @Column(name = "icao_code", length = 4, unique = true)
    @Comment("ICAO四字码，例如 ZSPD、ZBAA")
    private String icaoCode;

    @NotBlank(message = "机场名称不能为空")
    @Size(max = 100, message = "机场名称长度不能超过100个字符")
    @Column(name = "name", length = 100, nullable = false)
    @Comment("机场中文/英文名称")
    private String name;

    @Size(max = 100, message = "城市名称长度不能超过100个字符")
    @Column(name = "city", length = 100)
    @Comment("所在城市")
    private String city;

    @Size(max = 100, message = "国家名称长度不能超过100个字符")
    @Column(name = "country", length = 100)
    @Comment("国家/地区")
    private String country;

    @Size(max = 50, message = "时区标识长度不能超过50个字符")
    @Column(name = "timezone", length = 50)
    @Comment("时区，如 Asia/Shanghai")
    private String timezone;

    @DecimalMin(value = "-90.0", message = "纬度范围应在[-90,90]")
    @DecimalMax(value = "90.0", message = "纬度范围应在[-90,90]")
    @Column(name = "latitude", columnDefinition = "NUMERIC(9,6)")
    @Comment("纬度")
    private Double latitude;

    @DecimalMin(value = "-180.0", message = "经度范围应在[-180,180]")
    @DecimalMax(value = "180.0", message = "经度范围应在[-180,180]")
    @Column(name = "longitude", columnDefinition = "NUMERIC(9,6)")
    @Comment("经度")
    private Double longitude;

    @PositiveOrZero(message = "海拔不能为负数")
    @Column(name = "elevation", columnDefinition = "NUMERIC(6,2)")
    @Comment("海拔(米)")
    private Double elevation;
}