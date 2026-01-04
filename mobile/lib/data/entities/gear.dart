import 'package:floor/floor.dart';
import 'package:mobile/annotations/field_info.dart';
import 'package:mobile/data/datetime_converter.dart';

@Entity(tableName: 'gear')
class Gear {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'name')
  @FieldInfo('装备名称', example: '小鹰背包', isRequired: true)
  final String name;

  @ColumnInfo(name: 'category')
  @FieldInfo('装备分类', example: '背包', isRequired: true)
  final String category;

  @ColumnInfo(name: 'brand')
  @FieldInfo('装备品牌', example: '小鹰背包', isRequired: true)
  final String brand;

  @ColumnInfo(name: 'weight')
  @FieldInfo('装备重量', example: '100', isRequired: false)
  final double? weight;

  @ColumnInfo(name: 'weight_unit')
  @FieldInfo('重量单位', example: 'g', isRequired: false)
  final String? weightUnit;

  @ColumnInfo(name: 'price')
  @FieldInfo('装备价格', example: '2000.00', isRequired: true)
  final double price;

  @ColumnInfo(name: 'quantity')
  @FieldInfo('数量', example: '1', isRequired: true)
  final int quantity;

  @ColumnInfo(name: 'purchase_date')
  @FieldInfo('购买/办理时间', example: '2024-01-15 08:00:00', isRequired: false)
  @TypeConverters([DateTimeConverter])
  final DateTime? purchaseDate;

  @ColumnInfo(name: 'usage_count')
  @FieldInfo('使用次数', example: '1/2/3/4/5', isRequired: false)
  final int? usageCount;

  @ColumnInfo(name: 'image_url')
  @FieldInfo('装备图片', example: 'http://xxx.xx.x', isRequired: false)
  final String? image;

  @ColumnInfo(name: 'status')
  @FieldInfo(
    '状态',
    example: '使用中',
    isRequired: false,
    enumValues: ['未使用', '使用中', '已报废', '已售出'],
  )
  final String status;

  Gear({
    this.id,
    required this.name,
    required this.category,
    required this.brand,
    this.image,
    required this.price,
    this.purchaseDate,
    required this.quantity,
    required this.status,
    this.usageCount,
    required this.weight,
    this.weightUnit,
  });
}
