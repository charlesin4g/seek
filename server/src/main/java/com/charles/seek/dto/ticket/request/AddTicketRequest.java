package com.charles.seek.dto.ticket.request;

import com.charles.seek.constant.TicketCategoryEnum;
import jakarta.validation.constraints.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class AddTicketRequest {

    /**
     * 票据类别：Flight / Train
     */
    @NotNull
    private TicketCategoryEnum category;

    /**
     * 承运人：航空公司/铁路局
     */
    @Size(max = 50)
    private String carrier;

    /**
     * 班次：航班号/车次
     */
    @NotBlank
    @Size(max = 20)
    private String travelNo;

    /**
     * 票号/PNR/订单号
     */
    @Size(max = 50)
    private String ticketNo;

    /**
     * 出发城市
     */
    @Size(max = 50)
    private String fromCity;

    /**
     * 出发站/出发机场
     */
    @Size(max = 100)
    private String fromPlace;

    /**
     * 到达城市
     */
    @Size(max = 50)
    private String toCity;

    /**
     * 到达站/到达机场
     */
    @Size(max = 100)
    private String toPlace;

    /**
     * 出发时间
     */
    private LocalDateTime departureTime;

    /**
     * 到达时间
     */
    private LocalDateTime arrivalTime;

    /**
     * 舱位/席别
     */
    @Size(max = 30)
    private String seatClass;

    /**
     * 座位号
     */
    @Size(max = 20)
    private String seatNo;

    /**
     * 票价（单位：元，最多两位小数）
     */
    @PositiveOrZero
    @Digits(integer = 12, fraction = 2)
    private Double price;

    /**
     * 币种（默认 CNY），长度为3，例如 CNY、USD
     */
    @Size(max = 3)
    private String currency;

    /**
     * 乘客姓名
     */
    @Size(max = 50)
    private String passengerName;

    /**
     * 证件号码
     */
    @Size(max = 50)
    private String passengerId;

    /**
     * 预订时间
     */
    private LocalDateTime bookingTime;

    /**
     * 所属用户（用户名）
     */
    @NotBlank
    @Size(max = 50)
    private String owner;
}