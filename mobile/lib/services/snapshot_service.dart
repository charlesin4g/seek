import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'local_db.dart';
import 'package:sqflite/sqflite.dart';
import 'web_local_store.dart';
import 'storage_service.dart';

/// 快照服务：在从在线切换到离线模式前，自动保存关键数据到本地
///
/// 职责（遵循“controller 只调用 service，业务逻辑在 service”）：
/// - 统一收集当前页面的表单草稿（通过注册的提供者回调）；
/// - 保存会话状态（如当前用户信息）与临时缓存；
/// - 分批写入本地数据库/IndexedDB，避免 UI 卡顿；
/// - 输出进度状态，供 UI 展示保存进度；
class SnapshotService {
  SnapshotService._internal();
  static final SnapshotService instance = SnapshotService._internal();

  /// 进度状态输出流：{state: saving/done/error, progress: 0..1, count: int}
  final StreamController<Map<String, dynamic>> _statusController = StreamController.broadcast();
  Stream<Map<String, dynamic>> get statusStream => _statusController.stream;

  /// 已注册的表单快照提供者：key -> provider()
  final Map<String, Future<Map<String, dynamic>> Function()> _formProviders = {};

  /// 注册一个表单快照提供者（页面在 initState 时调用）
  void registerFormProvider(String key, Future<Map<String, dynamic>> Function() provider) {
    _formProviders[key] = provider;
  }

  /// 取消注册（页面在 dispose 时调用）
  void unregisterFormProvider(String key) {
    _formProviders.remove(key);
  }

  /// 切离线前的保存流程：返回 true 表示保存成功
  Future<bool> saveBeforeOfflineSwitch() async {
    try {
      // 1) 收集表单草稿（异步合并）：
      _statusController.add({'state': 'saving', 'progress': 0.0});
      final entries = _formProviders.entries.toList();
      final forms = <String, Map<String, dynamic>>{};
      for (var i = 0; i < entries.length; i++) {
        final e = entries[i];
        try {
          final payload = await e.value();
          forms[e.key] = payload;
        } catch (_) {
          // 单个提供者失败不影响整体保存（可按需收集错误）
        }
        _statusController.add({'state': 'saving', 'progress': (i + 1) / (entries.isEmpty ? 1 : entries.length)});
      }

      // 2) 会话状态：读取已缓存的用户信息
      final sessionUser = StorageService().getCachedUserSync() ?? await StorageService().getCachedAdminUser() ?? {};

      // 3) 分批保存到本地存储
      if (kIsWeb) {
        // Web：使用 localStorage（IndexedDB 可后续替换）
        await WebLocalStore.instance.saveFormSnapshots(forms);
        await WebLocalStore.instance.saveSessionRecord('user', Map<String, dynamic>.from(sessionUser));
        // 临时缓存：当前未有具体项，预留接口
        // await WebLocalStore.instance.saveTempCache('page_cache', {...});
      } else {
        // App：使用加密 SQLite
        final db = await LocalDatabase.instance.init();
        // 表单快照分批 upsert
        const batchSize = 50;
        final formEntries = forms.entries.toList();
        for (var i = 0; i < formEntries.length; i += batchSize) {
          final slice = formEntries.skip(i).take(batchSize);
          await db.transaction((tx) async {
            for (final e in slice) {
              await tx.insert(
                'form_snapshot',
                {
                  'key': e.key,
                  'payload': e.value.isEmpty ? '{}' : jsonEncode(e.value),
                  'updatedAt': DateTime.now().millisecondsSinceEpoch,
                  'version': 1,
                },
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          });
          // 让出事件循环以避免 UI 卡顿
          await Future.delayed(const Duration(milliseconds: 1));
        }
        // 会话状态 upsert
        await db.insert(
          'session_state',
          {
            'key': 'user',
            'payload': sessionUser.isEmpty ? '{}' : jsonEncode(sessionUser),
            'updatedAt': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      _statusController.add({'state': 'done', 'count': forms.length});
      return true;
    } catch (e) {
      _statusController.add({'state': 'error', 'message': e.toString()});
      return false;
    }
  }
}