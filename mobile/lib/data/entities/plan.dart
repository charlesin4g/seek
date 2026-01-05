/// 关于计划表(plan)和活动表(activity)的一点说明
/// 计划表是一个总表，已完成的计划不等于活动
/// 但是完成后单日的计划可以等同于是一个活动
/// 活动记录的时候一场徒步/跑步/骑行行为，包含轨迹文件
/// (已完成)计划记录的是一个或多个活动的总和
/// 行程可以关联到某一场具体的活动
library;
import 'package:floor/floor.dart';
import 'package:mobile/annotations/field_info.dart';
import 'package:mobile/data/datetime_converter.dart';

@Entity(tableName: 'plan')
class Plan {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'name')
  @FieldInfo('计划名称', isRequired: true, example: '黄山三天两夜徒步之旅')
  final String name;

  @ColumnInfo(name: 'description')
  @FieldInfo('计划描述', example: '周末与好友一起徒步黄山，欣赏云海和日出')
  final String? description;

  @ColumnInfo(name: 'start_date')
  @FieldInfo('开始日期', isRequired: true, example: '2024-05-01')
  @TypeConverters([DateTimeConverter])
  final DateTime startDate;

  @ColumnInfo(name: 'end_date')
  @FieldInfo('结束日期', isRequired: true, example: '2024-05-03')
  @TypeConverters([DateTimeConverter])
  final DateTime endDate;

  @ColumnInfo(name: 'budget')
  @FieldInfo('预算金额(元)', example: '1500.0')
  final double? budget;

  @ColumnInfo(name: 'actual_cost')
  @FieldInfo('实际花费(元)', example: '1350.0')
  final double? actualCost;

  @ColumnInfo(name: 'destination')
  @FieldInfo('目的地', isRequired: true, example: '黄山风景名胜区')
  final String destination;

  @ColumnInfo(name: 'destination_lat')
  @FieldInfo('目的地纬度', example: '30.132')
  final double? destinationLat;

  @ColumnInfo(name: 'destination_lng')
  @FieldInfo('目的地经度', example: '118.168')
  final double? destinationLng;

  @ColumnInfo(name: 'participants')
  @FieldInfo('参与人员(JSON数组)', example: '["张三", "李四", "王五"]')
  final String? participants;

  @ColumnInfo(name: 'images')
  @FieldInfo('图片链接集合(JSON数组)', example: '["https://example.com/cover1.jpg", "https://example.com/cover2.jpg"]')
  final String? images;

  @ColumnInfo(name: 'star_image')
  @FieldInfo('封面图片链接', example: 'https://example.com/cover.jpg')
  final String? starImage;

  @ColumnInfo(name: 'status')
  @FieldInfo(
    '计划状态',
    isRequired: true,
    example: 'planning',
    enumValues: [
      'planning: 计划中',
      'confirmed: 已确认',
      'inProgress: 进行中',
      'completed: 已完成',
      'cancelled: 已取消',
      'postponed: 已推迟',
    ],
  )
  final String status;

  @ColumnInfo(name: 'notes')
  @FieldInfo('备注信息', example: '需要提前预约黄山门票')
  final String? notes;

  Plan({
    this.id,
    required this.name,
    this.description,
    required this.startDate,
    required this.endDate,
    this.budget,
    this.actualCost,
    required this.destination,
    this.destinationLat,
    this.destinationLng,
    this.participants,
    this.images,
    this.starImage,
    required this.status,
    this.notes,
  });
}