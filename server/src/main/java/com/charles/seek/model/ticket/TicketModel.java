package com.charles.seek.model.ticket;

import com.charles.seek.constant.TicketCategoryEnum;
import com.charles.seek.model.BaseEntity;
import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.Comment;

import java.time.LocalDateTime;

@EqualsAndHashCode(callSuper = true)
@Data
@Entity
@Table(name = "ticket",
        indexes = {
                @Index(name = "idx_ticket_owner", columnList = "owner"),
                @Index(name = "idx_ticket_departure_time", columnList = "departure_time"),
                @Index(name = "idx_ticket_travel_no", columnList = "travel_no")
        })
public class TicketModel extends BaseEntity {

    /**
     * 票据类别：Flight / Train
     */
    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(name = "category", length = 20, nullable = false)
    @Comment("票据类别：Flight/Train")
    private TicketCategoryEnum category;

    /**
     * 承运人：航空公司/铁路局
     */
    @Size(max = 50, message = "承运人长度不能超过50个字符")
    @Column(name = "carrier", length = 50)
    @Comment("承运人：航空公司/铁路局")
    private String carrier;

    /**
     * 班次：航班号/车次
     */
    @NotBlank(message = "班次不能为空")
    @Size(max = 20, message = "班次长度不能超过20个字符")
    @Column(name = "travel_no", length = 20, nullable = false)
    @Comment("班次：航班号/车次")
    private String travelNo;

    /**
     * 票号/PNR/订单号
     */
    @Size(max = 50, message = "票号长度不能超过50个字符")
    @Column(name = "ticket_no", length = 50)
    @Comment("票号/PNR/订单号")
    private String ticketNo;

    /**
     * 出发城市
     */
    @Size(max = 50, message = "出发城市长度不能超过50个字符")
    @Column(name = "from_city", length = 50)
    @Comment("出发城市")
    private String fromCity;

    /**
     * 出发站/出发机场
     */
    @Size(max = 100, message = "出发地长度不能超过100个字符")
    @Column(name = "from_place", length = 100)
    @Comment("出发站/出发机场")
    private String fromPlace;

    /**
     * 到达城市
     */
    @Size(max = 50, message = "到达城市长度不能超过50个字符")
    @Column(name = "to_city", length = 50)
    @Comment("到达城市")
    private String toCity;

    /**
     * 到达站/到达机场
     */
    @Size(max = 100, message = "到达地长度不能超过100个字符")
    @Column(name = "to_place", length = 100)
    @Comment("到达站/到达机场")
    private String toPlace;

    /**
     * 出发时间
     */
    @Column(name = "departure_time")
    @Comment("出发时间")
    private LocalDateTime departureTime;

    /**
     * 到达时间
     */
    @Column(name = "arrival_time")
    @Comment("到达时间")
    private LocalDateTime arrivalTime;

    /**
     * 舱位/席别
     */
    @Size(max = 30, message = "舱位/席别长度不能超过30个字符")
    @Column(name = "seat_class", length = 30)
    @Comment("舱位/席别")
    private String seatClass;

    /**
     * 座位号
     */
    @Size(max = 20, message = "座位号长度不能超过20个字符")
    @Column(name = "seat_no", length = 20)
    @Comment("座位号")
    private String seatNo;

    /**
     * 票价
     */
    @PositiveOrZero(message = "票价不能为负数")
    @Digits(integer = 12, fraction = 2, message = "票价格式不正确")
    // 移除 DEFAULT 0.0，避免 PostgreSQL ALTER COLUMN 语法错误；保持为 DOUBLE PRECISION
    @Column(name = "price", columnDefinition = "DOUBLE PRECISION")
    // 使用 DOUBLE PRECISION，默认值通过应用层或构造器初始化，避免 PostgreSQL ALTER TYPE 语法错误
    @Comment("票价")
    private double price;

    /**
     * 币种（默认 CNY）
     */
    @Size(max = 3, message = "币种长度不能超过3个字符")
    @Column(name = "currency", length = 3)
    @Comment("币种，默认CNY")
    private String currency = "CNY";

    /**
     * 乘客姓名
     */
    @Size(max = 50, message = "乘客姓名长度不能超过50个字符")
    @Column(name = "passenger_name", length = 50)
    @Comment("乘客姓名")
    private String passengerName;

    /**
     * 证件号码
     */
    @Size(max = 50, message = "证件号码长度不能超过50个字符")
    @Column(name = "passenger_id", length = 50)
    @Comment("证件号码")
    private String passengerId;

    /**
     * 预订时间
     */
    @Column(name = "booking_time")
    @Comment("预订时间")
    private LocalDateTime bookingTime;

    /**
     * 所属用户（用户名）
     */
    @Size(max = 50, message = "所属用户长度不能超过50个字符")
    @Column(name = "owner", length = 50)
    @Comment("所属用户：用户名")
    private String owner;
}
