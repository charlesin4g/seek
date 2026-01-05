// 火车站基本信息
import 'package:floor/floor.dart';
import 'package:mobile/annotations/field_info.dart';

@Entity(tableName: 'train_station')
class TrainStation {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'code')
  @FieldInfo('车站代码(简码)', isRequired: true, example: 'BJN')
  final String code;

  @ColumnInfo(name: 'name')
  @FieldInfo('车站名称', isRequired: true, example: '北京南站')
  final String name;

  @ColumnInfo(name: 'english_name')
  @FieldInfo('英文名称', example: 'Beijing South Railway Station')
  final String? englishName;

  @ColumnInfo(name: 'alias')
  @FieldInfo('车站别名', example: '南站')
  final String? alias;

  @ColumnInfo(name: 'district')
  @FieldInfo('所在区县', example: '丰台区')
  final String? district;

  @ColumnInfo(name: 'city')
  @FieldInfo('所在城市', isRequired: true, example: '北京市')
  final String city;

  @ColumnInfo(name: 'province')
  @FieldInfo('所在省份', isRequired: true, example: '北京市')
  final String province;

  @ColumnInfo(name: 'railway_administration')
  @FieldInfo('所属铁路局', example: '北京铁路局')
  final String? railwayAdministration;

  @ColumnInfo(name: 'longitude')
  @FieldInfo('经度', example: '116.385')
  final double? longitude;

  @ColumnInfo(name: 'latitude')
  @FieldInfo('纬度', example: '39.865')
  final double? latitude;

  @ColumnInfo(name: 'notes')
  @FieldInfo('备注信息', example: '亚洲最大火车站之一，拥有南北两个广场')
  final String? notes;

  @ColumnInfo(name: 'visit_count')
  @FieldInfo('访问次数', example: '0')
  final int? visitCount;

  TrainStation({
    this.id,
    required this.code,
    required this.name,
    this.englishName,
    this.alias,
    required this.city,
    required this.province,
    this.district,
    this.railwayAdministration,
    this.longitude,
    this.latitude,
    this.notes,
    this.visitCount = 0,
  });
}
