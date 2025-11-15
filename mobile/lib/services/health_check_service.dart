import 'dart:async';
import 'package:http/http.dart' as http;
import 'env.dart';

/// 后端健康检查服务
///
/// 说明：
/// - 独立使用 http.Client 进行探测，避免触发全局 Offline 切换副作用；
/// - 统一提供 3 秒超时；
/// - 返回后端可用性布尔值，调用方决定后续 UI 与模式切换逻辑。
class HealthCheckService {
  HealthCheckService._internal();
  static final HealthCheckService instance = HealthCheckService._internal();

  final http.Client _client = http.Client();

  /// 检测后端是否可用（GET `/health/check`）
  ///
  /// 返回：
  /// - true：后端可用；
  /// - false：不可用或超时/网络错误。
  Future<bool> checkAvailable({Duration timeout = const Duration(seconds: 3)}) async {
    final uri = Uri.parse('${Env.backendBaseUrl}/health/check');
    try {
      final res = await _client.get(uri).timeout(timeout);
      // 2xx 认为可用；503 健康检查未通过也视为不可用
      if (res.statusCode == 503) {
        print('Health check returned 503, backend dependencies unhealthy');
      }
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (e) {
      print('Health check error: $e');
      return false;
    }
  }

  void close() => _client.close();
}