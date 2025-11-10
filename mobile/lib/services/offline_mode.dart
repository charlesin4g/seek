import 'dart:async';
import 'package:flutter/foundation.dart';

/// 离线/在线模式管理器
///
/// 职责：
/// - 提供当前运行模式（在线/离线）状态；
/// - 负责模式切换并触发一致性检查；
/// - 作为应用内的单例服务，供 UI 和各业务服务使用。
class OfflineModeManager {
  OfflineModeManager._internal();
  static final OfflineModeManager instance = OfflineModeManager._internal();

  /// 当前是否处于离线模式的通知器（供 UI 订阅）
  final ValueNotifier<bool> isOffline = ValueNotifier<bool>(false);

  /// 模式切换事件流（供后台同步或其他服务订阅）
  final StreamController<bool> _modeChangeController = StreamController<bool>.broadcast();
  Stream<bool> get onModeChanged => _modeChangeController.stream;

  /// 切换为离线或在线模式
  ///
  /// 参数：
  /// - `offline`：true 切换到离线；false 切换到在线。
  /// - `beforeSwitchCheck`：切换前一致性检查回调，返回 true 则允许切换。
  Future<bool> setOffline(bool offline, {Future<bool> Function()? beforeSwitchCheck}) async {
    if (offline == isOffline.value) return true;
    if (beforeSwitchCheck != null) {
      final ok = await beforeSwitchCheck();
      if (!ok) return false;
    }
    isOffline.value = offline;
    _modeChangeController.add(offline);
    return true;
  }

  /// 关闭资源（通常在应用退出时调用）
  void dispose() {
    _modeChangeController.close();
    isOffline.dispose();
  }
}