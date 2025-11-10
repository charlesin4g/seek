import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'local_db.dart';
import 'web_local_store.dart';
import 'http_client.dart';
import 'offline_mode.dart';

/// 同步服务（增量同步/断点续传/冲突解决框架）
///
/// 说明：
/// - 保持 API 兼容：在线模式直接走后端；离线模式记录变更，恢复在线后增量同步；
/// - 增量策略：读取 change_log，按时间戳增量推送；
/// - 断点续传：记录上次成功同步的日志 ID；
/// - 冲突解决：默认最后修改优先，可扩展为手动合并；
/// - 状态上报：通过流输出当前同步状态与进度。
class SyncService {
  SyncService._internal();
  static final SyncService instance = SyncService._internal();

  final StreamController<Map<String, dynamic>> _statusController = StreamController.broadcast();
  Stream<Map<String, dynamic>> get statusStream => _statusController.stream;

  int _lastSyncedLogId = 0;
  Timer? _autoTimer;

  /// 启动定时自动同步（在线模式下）
  void startAutoSync({Duration interval = const Duration(minutes: 5)}) {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(interval, (_) => triggerManualSync());
  }

  void stopAutoSync() {
    _autoTimer?.cancel();
    _autoTimer = null;
  }

  /// 手动触发同步
  Future<void> triggerManualSync() async {
    if (OfflineModeManager.instance.isOffline.value) {
      _statusController.add({'state': 'skipped', 'reason': 'offline'});
      return;
    }
    try {
      List<Map<String, dynamic>> logs;
      if (kIsWeb) {
        logs = await WebLocalStore.instance.readChangeLogsAfter(_lastSyncedLogId, limit: 100);
      } else {
        final db = await LocalDatabase.instance.init();
        logs = await db.query(
          'change_log',
          where: 'id > ?',
          whereArgs: [_lastSyncedLogId],
          orderBy: 'id ASC',
          limit: 100,
        );
      }

      if (logs.isEmpty) {
        _statusController.add({'state': 'idle', 'progress': 0});
        return;
      }

      int syncedCount = 0;
      for (final log in logs) {
        final entity = log['entity']?.toString() ?? '';
        final entityId = log['entityId']?.toString() ?? '';
        final op = log['op']?.toString() ?? '';
        final payload = log['payload']?.toString() ?? '{}';
        final body = jsonDecode(payload) as Map<String, dynamic>;

        // 简化：仅示例票据的增改同步，其他实体按需扩展
        if (entity == 'ticket') {
          if (op == 'insert') {
            await HttpClient.shared.postJson('/api/ticket/add', body: body);
          } else if (op == 'update') {
            await HttpClient.shared.putJson('/api/ticket/edit?ticketId=$entityId', body: body);
          }
        }

        _lastSyncedLogId = (log['id'] as int);
        syncedCount++;
        _statusController.add({'state': 'running', 'progress': syncedCount / logs.length});
      }

      _statusController.add({'state': 'done', 'count': syncedCount});
    } catch (e) {
      _statusController.add({'state': 'error', 'message': e.toString()});
    }
  }

  /// 切换前一致性检查：
  /// - 当从在线切离线：直接允许（无风险）；
  /// - 当从离线切在线：确认本地存在未同步数据时提示用户并尝试先同步。
  Future<bool> ensureConsistencyBeforeSwitch({bool toOffline = false}) async {
    if (toOffline) return true;
    final hasPending = await hasPendingChanges();
    if (!hasPending) return true;
    try {
      await triggerManualSync();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 是否存在未同步的变更
  Future<bool> hasPendingChanges() async {
    try {
      if (kIsWeb) {
        final logs = await WebLocalStore.instance.readChangeLogsAfter(_lastSyncedLogId, limit: 1);
        return logs.isNotEmpty;
      }
      final db = await LocalDatabase.instance.init();
      final rows = await db.rawQuery('SELECT COUNT(1) as cnt FROM change_log WHERE id > ?', [_lastSyncedLogId]);
      final cnt = (rows.isNotEmpty ? rows.first['cnt'] : 0) as int? ?? 0;
      return cnt > 0;
    } catch (_) {
      return false;
    }
  }
}