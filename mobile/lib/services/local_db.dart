import 'package:path/path.dart' as p;
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:flutter/foundation.dart';

/// 加密本地数据库服务（SQLite / SQLCipher）
///
/// 职责：
/// - 统一管理数据库连接与初始化；
/// - 提供事务封装；
/// - 创建必要的表结构（首期包含 ticket 与 station）。
class LocalDatabase {
  LocalDatabase._internal();
  static final LocalDatabase instance = LocalDatabase._internal();

  static const String _dbName = 'seek_offline.db';
  // 升级到 v2：新增 form_snapshot/session_state/temp_cache/sync_meta 表
  static const int _dbVersion = 2;

  Database? _db;

  /// 注意：演示密钥，生产环境需使用用户派生密钥或安全存储
  /// 可使用设备安全存储结合 PBKDF2/Scrypt 派生
  static const String _demoPassphrase = 'seek_local_db_secret';

  /// 初始化数据库（若已初始化则直接返回）
  Future<Database> init() async {
    if (_db != null) return _db!;
    final databasesPath = await getDatabasesPath();
    final dbPath = p.join(databasesPath, _dbName);

    // Web 平台不支持原生 SQLite，跳过打开（调用方需做平台判断）
    if (kIsWeb) {
      throw UnsupportedError('Web 平台不支持本地 SQLCipher 数据库');
    }

    _db = await openDatabase(
      dbPath,
      password: _demoPassphrase,
      version: _dbVersion,
      onCreate: (db, version) async {
        await _createSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // 版本迁移：按需补充缺失表结构（幂等）
        if (oldVersion < 2) {
          await _migrateToV2(db);
        }
      },
    );
    return _db!;
  }

  /// 创建基础表结构
  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ticket (
        id TEXT PRIMARY KEY,
        owner TEXT,
        category TEXT,
        travelNo TEXT,
        fromPlace TEXT,
        toPlace TEXT,
        departureTime TEXT,
        arrivalTime TEXT,
        seatClass TEXT,
        seatNo TEXT,
        price REAL,
        currency TEXT,
        passengerName TEXT,
        remark TEXT,
        updatedAt INTEGER,
        synced INTEGER DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS station (
        code TEXT PRIMARY KEY,
        name TEXT,
        pinyin TEXT,
        city TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS change_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity TEXT,
        entityId TEXT,
        op TEXT, -- insert/update/delete
        payload TEXT,
        ts INTEGER
      );
    ''');

    // v2 新增：表单快照（保存未提交的表单数据）
    await db.execute('''
      CREATE TABLE IF NOT EXISTS form_snapshot (
        key TEXT PRIMARY KEY,
        payload TEXT,
        updatedAt INTEGER,
        version INTEGER DEFAULT 1
      );
    ''');

    // v2 新增：会话状态（如当前用户信息、临时状态）
    await db.execute('''
      CREATE TABLE IF NOT EXISTS session_state (
        key TEXT PRIMARY KEY,
        payload TEXT,
        updatedAt INTEGER
      );
    ''');

    // v2 新增：临时缓存（可用于页面缓存、临时文件索引等）
    await db.execute('''
      CREATE TABLE IF NOT EXISTS temp_cache (
        key TEXT PRIMARY KEY,
        payload TEXT,
        updatedAt INTEGER
      );
    ''');

    // v2 新增：同步/版本元信息（冲突处理辅助）
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_meta (
        key TEXT PRIMARY KEY,
        value TEXT
      );
    ''');
  }

  /// 迁移到 v2：补充新增表结构（幂等）
  Future<void> _migrateToV2(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS form_snapshot (
        key TEXT PRIMARY KEY,
        payload TEXT,
        updatedAt INTEGER,
        version INTEGER DEFAULT 1
      );
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS session_state (
        key TEXT PRIMARY KEY,
        payload TEXT,
        updatedAt INTEGER
      );
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS temp_cache (
        key TEXT PRIMARY KEY,
        payload TEXT,
        updatedAt INTEGER
      );
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_meta (
        key TEXT PRIMARY KEY,
        value TEXT
      );
    ''');
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