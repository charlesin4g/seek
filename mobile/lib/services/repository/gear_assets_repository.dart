import 'package:flutter/foundation.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../local_db.dart';

class GearAssetRecord {
  const GearAssetRecord({
    required this.id,
    required this.name,
    required this.brand,
    required this.purchaseDateLabel,
    required this.price,
    required this.usageCount,
    required this.imageUrl,
    required this.status,
  });

  final int id;
  final String name;
  final String brand;
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
    final countResult = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM gear_asset'),
    );
    if ((countResult ?? 0) == 0) {
      await _seedMockAssets(db);
    }

    final rows = await db.query(
      'gear_asset',
      orderBy: 'id DESC',
    );

    return rows.map((row) {
      return GearAssetRecord(
        id: row['id'] as int,
        name: row['name']!.toString(),
        brand: row['brand']!.toString(),
        purchaseDateLabel: row['purchaseDateLabel']!.toString(),
        price: (row['price'] as num?)?.toDouble() ?? 0,
        usageCount: (row['usageCount'] as num?)?.toInt() ?? 0,
        imageUrl: row['imageUrl']!.toString(),
        status: row['status']?.toString() ?? '在用',
      );
    }).toList();
  }

  Future<int> addAsset({
    required String name,
    required String brand,
    required String purchaseDateLabel,
    required double price,
    int usageCount = 0,
    required String imageUrl,
    String status = '在用',
  }) async {
    final db = await _db();
    return db.insert(
      'gear_asset',
      {
        'name': name,
        'brand': brand,
        'purchaseDateLabel': purchaseDateLabel,
        'price': price,
        'usageCount': usageCount,
        'imageUrl': imageUrl,
        'status': status,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateAsset({
    required int id,
    String? name,
    String? brand,
    String? purchaseDateLabel,
    double? price,
    int? usageCount,
    String? imageUrl,
    String? status,
  }) async {
    final db = await _db();
    final Map<String, Object?> updates = <String, Object?>{};
    if (name != null) {
      updates['name'] = name;
    }
    if (brand != null) {
      updates['brand'] = brand;
    }
    if (purchaseDateLabel != null) {
      updates['purchaseDateLabel'] = purchaseDateLabel;
    }
    if (price != null) {
      updates['price'] = price;
    }
    if (usageCount != null) {
      updates['usageCount'] = usageCount;
    }
    if (imageUrl != null) {
      updates['imageUrl'] = imageUrl;
    }
    if (status != null) {
      updates['status'] = status;
    }
    if (updates.isEmpty) {
      return;
    }

    await db.update(
      'gear_asset',
      updates,
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  Future<void> _seedMockAssets(Database db) async {
    if (kDebugMode) {
      debugPrint('Seeding mock gear_asset data into SQLite');
    }

    const List<Map<String, dynamic>> mockAssets = [
      {
        'name': 'Osprey Atmos AG 65',
        'brand': 'Osprey',
        'purchaseDateLabel': '2024-01-15',
        'price': 2680.0,
        'usageCount': 12,
        'imageUrl': 'https://images.pexels.com/photos/884788/pexels-photo-884788.jpeg?auto=compress&cs=tinysrgb&w=800',
        'status': '在用',
      },
      {
        'name': '北面四季帐篷',
        'brand': 'The North Face',
        'purchaseDateLabel': '2023-11-20',
        'price': 3200.0,
        'usageCount': 8,
        'imageUrl': 'https://images.pexels.com/photos/618848/pexels-photo-618848.jpeg?auto=compress&cs=tinysrgb&w=800',
        'status': '在用',
      },
      {
        'name': '防水冲锋衣',
        'brand': "Arc'teryx",
        'purchaseDateLabel': '2023-09-05',
        'price': 1800.0,
        'usageCount': 15,
        'imageUrl': 'https://images.pexels.com/photos/4492042/pexels-photo-4492042.jpeg?auto=compress&cs=tinysrgb&w=800',
        'status': '在用',
      },
      {
        'name': '户外登山表',
        'brand': 'Garmin',
        'purchaseDateLabel': '2023-06-12',
        'price': 2380.0,
        'usageCount': 20,
        'imageUrl': 'https://images.pexels.com/photos/2774062/pexels-photo-2774062.jpeg?auto=compress&cs=tinysrgb&w=800',
        'status': '在用',
      },
    ];

    await db.transaction((tx) async {
      for (final m in mockAssets) {
        await tx.insert(
          'gear_asset',
          m,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
