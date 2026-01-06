import 'package:floor/floor.dart';
import 'package:mobile/annotations/field_info.dart';

@Entity(tableName: 'gear_brand')
class GearBrand {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'name')
  @FieldInfo('品牌名称', isRequired: true, example: 'The North Face')
  final String name;

  @ColumnInfo(name: 'english_name')
  @FieldInfo('英文名称', example: 'The North Face')
  final String? englishName;

  @ColumnInfo(name: 'description')
  @FieldInfo('品牌描述', example: '全球知名户外品牌，以登山装备和户外服饰闻名')
  final String? description;

  @ColumnInfo(name: 'category')
  @FieldInfo(
    '品牌类别',
    example: 'Gear',
    enumValues: [
      'Gear: 户外综合',
      'mountaineering: 登山攀岩',
      'camping: 露营装备',
      'hiking: 徒步旅行',
      'cycling: 骑行运动',
      'water_sports: 水上运动',
      'snow_sports: 雪上运动',
      'apparel: 户外服饰',
      'footwear: 户外鞋履',
      'other: 其他',
    ],
  )
  final String? category;

  @ColumnInfo(name: 'country')
  @FieldInfo('所属国家', example: '美国')
  final String? country;

  @ColumnInfo(name: 'founded_year')
  @FieldInfo('成立年份', example: '1966')
  final int? foundedYear;

  @ColumnInfo(name: 'specialty')
  @FieldInfo(
    '专业领域',
    example: 'mountaineering',
    enumValues: [
      'mountaineering: 登山攀岩',
      'hiking: 徒步',
      'camping: 露营',
      'trailRunning: 越野跑',
      'climbing: 攀岩',
      'skiing: 滑雪',
      'snowboarding: 单板滑雪',
      'cycling: 骑行',
      'waterSports: 水上运动',
      'multisport: 多项运动',
    ],
  )
  final String? specialty;

  @ColumnInfo(name: 'official_website')
  @FieldInfo('官方网站', example: 'https://www.thenorthface.com')
  final String? officialWebsite;

  @ColumnInfo(name: 'social_media')
  @FieldInfo('社交媒体链接(JSON格式)', example: '{"instagram": "thenorthface", "facebook": "TheNorthFace"}')
  final String? socialMedia;

  @ColumnInfo(name: 'logo_url')
  @FieldInfo('品牌Logo链接', example: 'https://example.com/logo.png')
  final String? logoUrl;

  @ColumnInfo(name: 'popular_products')
  @FieldInfo('热门产品(JSON数组)', example: '["冲锋衣", "登山鞋", "帐篷"]')
  final String? popularProducts;

  @ColumnInfo(name: 'environment_friendly')
  @FieldInfo('环保认证', example: 'true', enumValues: ['环保材料', '回收计划', '碳补偿'])
  final bool? environmentFriendly;

  @ColumnInfo(name: 'warranty_policy')
  @FieldInfo('保修政策', example: '终身保修')
  final String? warrantyPolicy;

  @ColumnInfo(name: 'is_favorite')
  @FieldInfo('是否收藏', example: 'false')
  final bool? isFavorite;

  @ColumnInfo(name: 'rating')
  @FieldInfo('用户评分(1-5)', example: '4.5')
  final double? rating;

  @ColumnInfo(name: 'notes')
  @FieldInfo('备注信息', example: '在中国有很好的售后服务网络')
  final String? notes;

  GearBrand({
    this.id,
    required this.name,
    this.englishName,
    this.description,
    this.category,
    this.country,
    this.foundedYear,
    this.specialty,
    this.officialWebsite,
    this.socialMedia,
    this.logoUrl,
    this.popularProducts,
    this.environmentFriendly,
    this.warrantyPolicy,
    this.isFavorite = false,
    this.rating,
    this.notes
  });
}