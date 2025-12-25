import 'dart:async';

/// 离线占位版同步服务：不再与远端服务进行增量同步
class SyncService {
  SyncService._internal();
  static final SyncService instance = SyncService._internal();

  final StreamController<Map<String, dynamic>> _statusController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get statusStream => _statusController.stream;

  void startAutoSync({Duration interval = const Duration(minutes: 5)}) {}

  void stopAutoSync() {}

  /// 手动同步：离线模式下直接标记为跳过
  Future<void> triggerManualSync() async {
    _statusController.add(<String, dynamic>{
      'state': 'disabled',
    });
  }

  /// 模式切换前一致性检查：离线模式下直接返回 true
  Future<bool> ensureConsistencyBeforeSwitch({bool toOffline = false}) async {
    return true;
  }

  /// 是否存在未同步的变更：离线占位实现恒为 false
  Future<bool> hasPendingChanges() async {
    return false;
  }
}
