class NetworkProbeService {
  NetworkProbeService._internal();
  static final NetworkProbeService instance = NetworkProbeService._internal();

  /// 离线模式：不再做任何后台网络探测，调用该方法将被忽略
  void start({Duration interval = const Duration(seconds: 10)}) {}
}
