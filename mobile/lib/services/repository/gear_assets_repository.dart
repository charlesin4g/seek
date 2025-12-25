import 'package:sqflite/sqflite.dart';

import '../local_db.dart';

class GearAssetRecord {
  const GearAssetRecord({
    required this.id,
    required this.name,
    this.brandId,
    required this.brand,
    required this.category,
    required this.purchaseDateLabel,
    required this.price,
    required this.usageCount,
    required this.imageUrl,
    required this.status,
  });

  final int id;
  final String name;
  final int? brandId;
  final String brand;
  final String category;
  final String purchaseDateLabel;
  final double price;
  final int usageCount;
  final String imageUrl;
  final String status;
}

/// 装备资产本地仓储
class GearAssetsRepository {
  GearAssetsRepository._internal();
  static final GearAssetsRepository instance = GearAssetsRepository._internal();

  Future<Database> _db() => LocalDatabase.instance.init();

  Future<List<GearAssetRecord>> getAllAssets() async {
    final db = await _db();
    final List<Map<String, Object?>> rows = await db.query(
      'gear',
      orderBy: 'id DESC',
    );

    return rows.map((Map<String, Object?> row) {
      return GearAssetRecord(
        id: row['id'] as int,
        name: (row['name'] ?? '').toString(),
        brandId: (row['brand_id'] as num?)?.toInt(),
        brand: (row['brand'] ?? '').toString(),
        category: (row['category'] ?? '').toString(),
        purchaseDateLabel: (row['purchase_date'] ?? '').toString(),
        price: (row['price'] as num?)?.toDouble() ?? 0,
        usageCount: (row['usage_count'] as num?)?.toInt() ?? 0,
        imageUrl: (row['image_id'] ?? '').toString(),
        status: (row['status'] ?? '').toString(),
      );
    }).toList();
  }

  Future<int> addAsset({
    required String name,
    int? brandId,
    required String brand,
    String? category,
    required String purchaseDateLabel,
    required double price,
    int usageCount = 0,
    required String imageUrl,
    String status = '在用',
  }) async {
    final Database db = await _db();
    final Map<String, Object?> data = <String, Object?>{
      'name': name,
      'brand_id': brandId,
      'brand': brand,
      'category': category,
      'purchase_date': purchaseDateLabel,
      'price': price,
      'usage_count': usageCount,
      'image_id': imageUrl,
      'status': status,
    };

    return db.insert(
      'gear',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateAsset({
    required int id,
    String? name,
    int? brandId,
    String? brand,
    String? category,
    String? purchaseDateLabel,
    double? price,
    int? usageCount,
    String? imageUrl,
    String? status,
  }) async {
    final Database db = await _db();
    final Map<String, Object?> updates = <String, Object?>{};
    if (name != null) {
      updates['name'] = name;
    }
    if (brandId != null) {
      updates['brand_id'] = brandId;
    }
    if (brand != null) {
      updates['brand'] = brand;
    }
    if (category != null) {
      updates['category'] = category;
    }
    if (purchaseDateLabel != null) {
      updates['purchase_date'] = purchaseDateLabel;
    }
    if (price != null) {
      updates['price'] = price;
    }
    if (usageCount != null) {
      updates['usage_count'] = usageCount;
    }
    if (imageUrl != null) {
      updates['image_id'] = imageUrl;
    }
    if (status != null) {
      updates['status'] = status;
    }
    if (updates.isEmpty) {
      return;
    }

    await db.update(
      'gear',
      updates,
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }
}
