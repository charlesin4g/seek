class HealthCheckService {
  HealthCheckService._internal();
  static final HealthCheckService instance = HealthCheckService._internal();

  /// 离线模式：统一视为后端不可用，避免发起真实网络请求
  Future<bool> checkAvailable({Duration timeout = const Duration(seconds: 3)}) async {
    return false;
  }

  void close() {}
}
