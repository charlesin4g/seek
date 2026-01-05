import 'package:floor/floor.dart';
import 'package:mobile/annotations/field_info.dart';
import 'package:mobile/data/datetime_converter.dart';
import 'package:mobile/data/entities/plan.dart';

@Entity(
  tableName: 'itinerary',
  foreignKeys: [
    ForeignKey(
      childColumns: ['plan_id'],
      parentColumns: ['id'],
      entity: Plan,
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
)
class Itinerary {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'plan_id')
  @FieldInfo('所属计划ID', isRequired: true)
  final int planId;

  @ColumnInfo(name: 'day_number')
  @FieldInfo('第几天', isRequired: true, example: '1')
  final int dayNumber;

  @ColumnInfo(name: 'date')
  @FieldInfo('行程日期', isRequired: true, example: '2024-05-01')
  @TypeConverters([DateTimeConverter])
  final DateTime date;

  @ColumnInfo(name: 'title')
  @FieldInfo('行程标题', isRequired: true, example: '第一天：抵达黄山，游览温泉区')
  final String title;

  @ColumnInfo(name: 'description')
  @FieldInfo('行程详情描述', example: '上午从合肥出发，中午抵达黄山，下午游览温泉区，晚上入住酒店')
  final String? description;

  @ColumnInfo(name: 'itinerary_type')
  @FieldInfo(
    '行程类型',
    isRequired: true,
    example: 'activity',
    enumValues: [
      'transportation: 交通',
      'accommodation: 住宿',
      'activity: 活动',
      'other: 其他',
    ],
  )
  final String itineraryType;

  // 关联字段
  @ColumnInfo(name: 'ticket_id')
  @FieldInfo('关联票务ID(当类型为交通时)', example: '1')
  final int? ticketId;

  @ColumnInfo(name: 'hotel_id')
  @FieldInfo('关联酒店ID(当类型为住宿时)', example: '1')
  final int? hotelId;

  @ColumnInfo(name: 'activity_id')
  @FieldInfo('关联活动ID(当类型为活动时)', example: '1')
  final int? activityId;

  // 关联详情（当无具体关联表时使用）
  @ColumnInfo(name: 'itinerary_description')
  @FieldInfo('关联详情（当无具体关联表时使用）', example: '吃饭')
  final String? itineraryDescription;

  // 时间信息
  @ColumnInfo(name: 'start_time')
  @FieldInfo('开始时间', example: '08:00')
  final String? startTime;

  @ColumnInfo(name: 'end_time')
  @FieldInfo('结束时间', example: '18:00')
  final String? endTime;

  // 费用信息
  @ColumnInfo(name: 'estimated_cost')
  @FieldInfo('预估费用(元)', example: '300.0')
  final double? estimatedCost;

  @ColumnInfo(name: 'actual_cost')
  @FieldInfo('实际费用(元)', example: '280.0')
  final double? actualCost;

  @ColumnInfo(name: 'notes')
  @FieldInfo('备注', example: '**********')
  final String? notes;

  @ColumnInfo(name: 'order_index')
  @FieldInfo('排序索引', example: '1')
  final int? order;

  Itinerary({
    this.id,
    required this.planId,
    required this.dayNumber,
    required this.date,
    required this.title,
    this.description,
    required this.itineraryType,
    this.itineraryDescription,
    this.ticketId,
    this.hotelId,
    this.activityId,
    this.startTime,
    this.endTime,
    this.estimatedCost,
    this.actualCost,
    this.notes,
    this.order = 0, 
  });
  }