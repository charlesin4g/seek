import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../local_db.dart';
import '../web_local_store.dart';

/// 车站离线仓储（本地等效实现）
class StationRepository {
  StationRepository._internal();
  static final StationRepository instance = StationRepository._internal();

  Future<Map<String, dynamic>> addStation(Map<String, dynamic> data) async {
    if (kIsWeb) {
      return WebLocalStore.instance.addStation(data);
    }
    final db = await LocalDatabase.instance.init();
    final row = {
      'code': (data['code'] ?? '').toString().toUpperCase(),
      'name': (data['name'] ?? '').toString(),
      'pinyin': (data['pinyin'] ?? '').toString(),
      'city': (data['city'] ?? '').toString(),
    };
    await db.insert('station', row, conflictAlgorithm: ConflictAlgorithm.replace);
    return row;
  }

  Future<Map<String, dynamic>?> getByCode(String code) async {
    if (kIsWeb) {
      return WebLocalStore.instance.getByCode(code);
    }
    final db = await LocalDatabase.instance.init();
    final rows = await db.query('station', where: 'code = ?', whereArgs: [code.toUpperCase()]);
    if (rows.isEmpty) return null;
    return Map<String, dynamic>.from(rows.first);
  }

  Future<List<Map<String, dynamic>>> search(String keyword) async {
    if (kIsWeb) {
      return WebLocalStore.instance.search(keyword);
    }
    final db = await LocalDatabase.instance.init();
    final key = '%${keyword.toLowerCase()}%';
    final rows = await db.query(
      'station',
      where: 'LOWER(name) LIKE ? OR LOWER(pinyin) LIKE ? OR LOWER(city) LIKE ?',
      whereArgs: [key, key, key],
      orderBy: 'name ASC',
      limit: 50,
    );
    return rows.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}