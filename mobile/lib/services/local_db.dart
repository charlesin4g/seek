import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../config/db_config.dart';

class LocalDatabase {
  LocalDatabase._internal();
  static final LocalDatabase instance = LocalDatabase._internal();

  static const String _dbName = 'seek_offline.db';
  Database? _db;

  Future<Database> init() async {
    if (_db != null) {
      return _db!;
    }

    // Web 平台不支持原生 SQLite，跳过打开（调用方需做平台判断）
    if (kIsWeb) {
      throw UnsupportedError('Web 平台不支持本地 SQLCipher 数据库');
    }

    final String databasesPath = await getDatabasesPath();
    final String dbPath = p.join(databasesPath, _dbName);

    final Directory databasesDirectory = Directory(databasesPath);
    if (!await databasesDirectory.exists()) {
      await databasesDirectory.create(recursive: true);
    }

    if (DbConfig.resetDbOnStartup) {
      // 模式一：每次启动都用 asset 中的数据库文件覆盖本地文件
      try {
        final data = await rootBundle.load('assets/seek_offline.db');
        final bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );

        final File dbFile = File(dbPath);
        await dbFile.writeAsBytes(bytes, flush: true);
      } catch (error) {
        debugPrint('覆盖预填充数据库失败: $error');
      }
    } else {
      // 模式二：仅在本地不存在数据库文件时，从 asset 拷贝一次
      final bool dbExists = await databaseExists(dbPath);
      if (!dbExists) {
        try {
          final data = await rootBundle.load('assets/seek_offline.db');
          final bytes = data.buffer.asUint8List(
            data.offsetInBytes,
            data.lengthInBytes,
          );

          final File dbFile = File(dbPath);
          await dbFile.writeAsBytes(bytes, flush: true);
        } catch (error) {
          debugPrint('预填充数据库拷贝失败: $error');
        }
      }
    }

    _db = await openDatabase(dbPath);
    return _db!;
  }

  /// 事务封装：回调中抛出异常则回滚
  Future<T> runInTransaction<T>(Future<T> Function(Transaction tx) action) async {
    final db = await init();
    return db.transaction((tx) async {
      return await action(tx);
    });
  }

  Database get db {
    final database = _db;
    if (database == null) {
      throw StateError('LocalDatabase 尚未初始化，先调用 init()');
    }
    return database;
  }
}