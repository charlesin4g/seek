import 'package:sqflite/sqflite.dart';
import '../local_db.dart';

class GearBrandRepository {
  GearBrandRepository._internal();
  static final GearBrandRepository instance = GearBrandRepository._internal();

  Future<Database> _db() => LocalDatabase.instance.init();

  // 根据名称模糊查询id-name列表
  Future<List<Map<String, dynamic>>> getBrandIdNameList(String keyword) async {
    final db = await _db();
    if(keyword.isEmpty){
      // 全部
      return await db.query(
        'gear_brand',
        columns: ['id', 'name'],
      );
    }
    return await db.query(
      'gear_brand',
      columns: ['id', 'name'],
      where: 'name LIKE ?',
      whereArgs: ['%$keyword%'],
    );
  }
}