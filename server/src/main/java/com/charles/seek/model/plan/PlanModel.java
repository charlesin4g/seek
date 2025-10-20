package com.charles.seek.model.plan;

import com.charles.seek.model.BaseEntity;
import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.Comment;

import java.time.LocalDate;

@EqualsAndHashCode(callSuper = true)
@Data
@Entity
@Table(name = "plan",
        indexes = {
                @Index(name = "idx_plan_owner", columnList = "owner"),
                @Index(name = "idx_plan_date", columnList = "date"),
                @Index(name = "idx_plan_status", columnList = "plan_status")
        })
public class PlanModel extends BaseEntity {

    @NotBlank
    @Size(max = 100)
    @Column(name = "name", length = 100, nullable = false)
    @Comment("计划名称")
    private String name;

    @NotNull
    @Column(name = "date", nullable = false)
    @Comment("计划日期")
    private LocalDate date;

    @Size(max = 1000)
    @Column(name = "description", length = 1000)
    @Comment("计划描述")
    private String description;

    @PositiveOrZero
    @Digits(integer = 5, fraction = 2)
    @Column(name = "distance", columnDefinition = "NUMERIC(7,2) DEFAULT 0.00")
    @Comment("徒步距离(公里)")
    private Double distance = 0.0;

    @Size(max = 20)
    @Column(name = "difficulty_level", length = 20)
    @Comment("难度级别")
    private String difficultyLevel = "中等";

    @PositiveOrZero
    @Column(name = "estimated_duration", columnDefinition = "INTEGER DEFAULT 120")
    @Comment("预计时长(分钟)")
    private Integer estimatedDuration = 120;

    @Size(max = 200)
    @Column(name = "location", length = 200)
    @Comment("地点")
    private String location;

    @Min(1)
    @Column(name = "participants", columnDefinition = "INTEGER DEFAULT 1")
    @Comment("参与人数")
    private Integer participants = 1;

    @Size(max = 20)
    @Column(name = "plan_status", length = 20)
    @Comment("计划状态")
    private String planStatus = "计划中";

    @Min(1)
    @Column(name = "max_participants", columnDefinition = "INTEGER DEFAULT 10")
    @Comment("最大参与人数")
    private Integer maxParticipants = 10;

    @Column(name = "is_public", columnDefinition = "BOOLEAN DEFAULT FALSE")
    @Comment("是否公开")
    private Boolean isPublic = false;

    @Size(max = 500)
    @Column(name = "required_equipment", length = 500)
    @Comment("所需装备")
    private String requiredEquipment;

    @Size(max = 50)
    @Column(name = "weather_condition", length = 50)
    @Comment("天气条件")
    private String weatherCondition;

    @Size(max = 50)
    @Column(name = "owner", length = 50)
    @Comment("所属用户：用户名")
    private String owner;
}
