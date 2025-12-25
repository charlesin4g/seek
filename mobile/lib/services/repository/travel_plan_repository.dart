import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../local_db.dart';

class TravelPlanRecord {
  const TravelPlanRecord({
    required this.id,
    required this.title,
    required this.dateRange,
    required this.daysLabel,
    required this.budgetLabel,
    required this.companionsLabel,
  });

  final int id;
  final String title;
  final String dateRange;
  final String daysLabel;
  final String budgetLabel;
  final String companionsLabel;
}

/// 旅行计划时间线本地仓储
class TravelPlanRepository {
  TravelPlanRepository._internal();
  static final TravelPlanRepository instance = TravelPlanRepository._internal();

  Future<Database> _db() => LocalDatabase.instance.init();

  Future<List<TravelPlanRecord>> getAllPlans() async {
    final db = await _db();
    final countResult = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM travel_plan'),
    );
    if ((countResult ?? 0) == 0) {
      await _seedMockPlans(db);
    }

    final rows = await db.query(
      'travel_plan',
      orderBy: 'createdAt DESC, id DESC',
    );

    return rows.map((row) {
      return TravelPlanRecord(
        id: row['id'] as int,
        title: row['title']!.toString(),
        dateRange: row['dateRange']!.toString(),
        daysLabel: row['daysLabel']!.toString(),
        budgetLabel: row['budgetLabel']!.toString(),
        companionsLabel: row['companionsLabel']!.toString(),
      );
    }).toList();
  }

  Future<void> addPlan({
    required String title,
    required String dateRange,
    required String daysLabel,
    required String budgetLabel,
    required String companionsLabel,
  }) async {
    final db = await _db();
    await db.insert(
      'travel_plan',
      {
        'title': title,
        'dateRange': dateRange,
        'daysLabel': daysLabel,
        'budgetLabel': budgetLabel,
        'companionsLabel': companionsLabel,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updatePlan({
    required int id,
    required String title,
    required String dateRange,
    required String daysLabel,
    required String budgetLabel,
    required String companionsLabel,
  }) async {
    final db = await _db();
    await db.update(
      'travel_plan',
      {
        'title': title,
        'dateRange': dateRange,
        'daysLabel': daysLabel,
        'budgetLabel': budgetLabel,
        'companionsLabel': companionsLabel,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> _seedMockPlans(Database db) async {
    if (kDebugMode) {
      debugPrint('Seeding mock travel_plan data into SQLite');
    }

    const List<Map<String, String>> mockPlans = [
      {
        'title': '四川稻城亚丁',
        'dateRange': '2024年4月15日 - 4月22日',
        'daysLabel': '25天',
        'budgetLabel': '¥8,500',
        'companionsLabel': '3人同行',
      },
      {
        'title': '新疆喀纳斯',
        'dateRange': '2024年5月1日 - 5月8日',
        'daysLabel': '41天',
        'budgetLabel': '¥12,000',
        'companionsLabel': '5人同行',
      },
      {
        'title': '云南梅里雪山',
        'dateRange': '2024年3月1日 - 3月5日',
        'daysLabel': '已完成',
        'budgetLabel': '¥6,800',
        'companionsLabel': '2人同行',
      },
    ];

    await db.transaction((tx) async {
      for (final m in mockPlans) {
        await tx.insert(
          'travel_plan',
          {
            'title': m['title'],
            'dateRange': m['dateRange'],
            'daysLabel': m['daysLabel'],
            'budgetLabel': m['budgetLabel'],
            'companionsLabel': m['companionsLabel'],
            'createdAt': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
