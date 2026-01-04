import 'package:floor/floor.dart';
import 'package:mobile/annotations/field_info.dart';
import 'package:mobile/data/datetime_converter.dart';

@Entity(tableName: 'activity')
class Activity {
  @PrimaryKey()
  @FieldInfo('活动ID', isRequired: true, example: 'act_20240115123456')
  final String id;

  @ColumnInfo(name: 'name')
  @FieldInfo('活动名称', isRequired: true, example: '周末登山活动')
  final String name;

  @ColumnInfo(name: 'type')
  @FieldInfo(
    '活动类型',
    isRequired: true,
    example: 'HIKE',
    enumValues: ['HIKE: 徒步', 'RUN: 跑步', 'SWIM: 游泳', 'RIDE: 骑行'],
  )
  final String type;

  @ColumnInfo(name: 'description')
  @FieldInfo('活动描述', example: '周末和朋友一起登山健身')
  final String? description;

  @ColumnInfo(name: 'activity_time')
  @FieldInfo('活动时间', isRequired: true, example: '2024-01-15 08:00:00')
  @TypeConverters([DateTimeConverter])
  final DateTime activityTime;

  @ColumnInfo(name: 'avg_heart_rate')
  @FieldInfo('平均心率(次/分钟)', example: '120')
  final int? avgHeartRate;

  @ColumnInfo(name: 'max_heart_rate')
  @FieldInfo('最大心率(次/分钟)', example: '150')
  final int? maxHeartRate;

  @ColumnInfo(name: 'avg_speed')
  @FieldInfo('平均速度(km/h)', example: '6.5')
  final double? avgSpeed;

  @ColumnInfo(name: 'max_speed')
  @FieldInfo('最大速度(km/h)', example: '12.3')
  final double? maxSpeed;

  @ColumnInfo(name: 'calories')
  @FieldInfo('消耗能量(卡路里)', example: '350')
  final int? calories;

  @ColumnInfo(name: 'distance')
  @FieldInfo('距离(km)', example: '5.2')
  final double? distance;

  @ColumnInfo(name: 'elevation_gain')
  @FieldInfo('爬升海拔(m)', example: '350')
  final int? elevationGain;

  @ColumnInfo(name: 'elevation_loss')
  @FieldInfo('下降海拔(m)', example: '300')
  final int? elevationLoss;

  @ColumnInfo(name: 'max_elevation')
  @FieldInfo('最高海拔(m)', example: '850')
  final int? maxElevation;

  @ColumnInfo(name: 'min_elevation')
  @FieldInfo('最低海拔(m)', example: '500')
  final int? minElevation;

  @ColumnInfo(name: 'moving_time')
  @FieldInfo('移动时间(秒)', example: '3600')
  final int? movingTime;

  @ColumnInfo(name: 'total_time')
  @FieldInfo('总消耗时间(秒)', example: '4500')
  final int? totalTime;

  @ColumnInfo(name: 'location')
  @FieldInfo('位置', example: '北京香山公园')
  final String? location;

  @ColumnInfo(name: 'image_count')
  @FieldInfo('图片数量', example: '3')
  final int? imageCount;

  @ColumnInfo(name: 'images')
  @FieldInfo('图片链接地址(JSON数组)', example: '["img1.jpg", "img2.jpg"]')
  final String? images;

  @ColumnInfo(name: 'star_image')
  @FieldInfo('星标图片', example: 'star_img.jpg')
  final String? starImage;

  @ColumnInfo(name: 'la')
  @FieldInfo('纬度', example: '39.9042')
  final double? la;

  @ColumnInfo(name: 'lo')
  @FieldInfo('经度', example: '116.4074')
  final double? lo;

  Activity({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    required this.activityTime,
    this.avgHeartRate,
    this.maxHeartRate,
    this.avgSpeed,
    this.maxSpeed,
    this.calories,
    this.distance,
    this.elevationGain,
    this.elevationLoss,
    this.maxElevation,
    this.minElevation,
    this.movingTime,
    this.totalTime,
    this.location,
    this.imageCount,
    this.images,
    this.starImage,
    this.la,
    this.lo,
  });
}
