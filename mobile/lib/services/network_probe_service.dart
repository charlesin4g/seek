import 'dart:async';
import 'http_client.dart';
import 'offline_mode.dart';
import 'sync_service.dart';

/// 网络探测服务：离线时定期探测后端可达性，恢复后自动切回在线并触发同步
class NetworkProbeService {
  NetworkProbeService._internal();
  static final NetworkProbeService instance = NetworkProbeService._internal();

  Timer? _timer;

  void start({Duration interval = const Duration(seconds: 10)}) {
    _timer?.cancel();
    // 监听模式变化：离线时启动探测，在线时停止
    OfflineModeManager.instance.onModeChanged.listen((offline) {
      if (offline) {
        _startTimer(interval);
      } else {
        _stopTimer();
      }
    });
    // 初始状态
    if (OfflineModeManager.instance.isOffline.value) {
      _startTimer(interval);
    }
  }

  void _startTimer(Duration interval) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) async {
      try {
        // 轻量探测：尝试请求一个简单路径；根据项目情况可调整
        await HttpClient.shared.getJson('/');
        // 可达：切回在线并触发同步
        final switched = await OfflineModeManager.instance.setOffline(false);
        if (switched) {
          await SyncService.instance.triggerManualSync();
        }
      } catch (_) {
        // 不可达：保持离线
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
}