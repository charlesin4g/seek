import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../local_db.dart';

class UserPhotoRecord {
  const UserPhotoRecord({
    required this.id,
    required this.owner,
    required this.path,
    required this.isStar,
    required this.createdAt,
  });

  final int id;
  final String owner;
  final String path;
  final bool isStar;
  final int createdAt;
}

/// 用户照片本地仓储
class UserPhotoRepository {
  UserPhotoRepository._internal();
  static final UserPhotoRepository instance = UserPhotoRepository._internal();

  Future<Database> _db() => LocalDatabase.instance.init();

  Future<void> _ensureTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_photo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        owner TEXT NOT NULL,
        path TEXT NOT NULL,
        is_star INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  /// 查询指定用户的所有照片，按创建时间倒序排列
  Future<List<UserPhotoRecord>> getPhotos(String owner) async {
    try {
      final db = await _db();
      await _ensureTable(db);
      final rows = await db.query(
        'user_photo',
        where: 'owner = ?',
        whereArgs: <Object?>[owner],
        orderBy: 'created_at DESC, id DESC',
      );
      return rows.map((Map<String, Object?> row) {
        return UserPhotoRecord(
          id: (row['id'] as num).toInt(),
          owner: (row['owner'] ?? '').toString(),
          path: (row['path'] ?? '').toString(),
          isStar: ((row['is_star'] ?? 0) as num).toInt() == 1,
          createdAt: (row['created_at'] as num).toInt(),
        );
      }).toList();
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('UserPhotoRepository.getPhotos error: $e');
        debugPrint(stack.toString());
      }
      return <UserPhotoRecord>[];
    }
  }

  /// 新增照片记录：若该用户当前无任何照片，则自动将该照片标记为星标
  Future<UserPhotoRecord?> addPhoto({
    required String owner,
    required String path,
  }) async {
    try {
      final db = await _db();
      await _ensureTable(db);

      return await LocalDatabase.instance.runInTransaction<UserPhotoRecord?>((tx) async {
        final int existingCount = Sqflite.firstIntValue(
              await tx.rawQuery(
                'SELECT COUNT(*) FROM user_photo WHERE owner = ?',
                <Object?>[owner],
              ),
            ) ??
            0;

        final bool isFirst = existingCount == 0;
        final int now = DateTime.now().millisecondsSinceEpoch;

        final int id = await tx.insert(
          'user_photo',
          <String, Object?>{
            'owner': owner,
            'path': path,
            'is_star': isFirst ? 1 : 0,
            'created_at': now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        return UserPhotoRecord(
          id: id,
          owner: owner,
          path: path,
          isStar: isFirst,
          createdAt: now,
        );
      });
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('UserPhotoRepository.addPhoto error: $e');
        debugPrint(stack.toString());
      }
      rethrow;
    }
  }

  /// 将指定照片设为星标，自动取消该用户其他照片的星标
  Future<void> setStar({
    required String owner,
    required int photoId,
  }) async {
    try {
      final db = await _db();
      await _ensureTable(db);
      await db.transaction((tx) async {
        await tx.update(
          'user_photo',
          <String, Object?>{'is_star': 0},
          where: 'owner = ?',
          whereArgs: <Object?>[owner],
        );
        await tx.update(
          'user_photo',
          <String, Object?>{'is_star': 1},
          where: 'owner = ? AND id = ?',
          whereArgs: <Object?>[owner, photoId],
        );
      });
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('UserPhotoRepository.setStar error: $e');
        debugPrint(stack.toString());
      }
      rethrow;
    }
  }
}
