import 'package:flutter/foundation.dart';

class Env {
  // 是否在登录页启用测试默认值：admin/seek
  // 可通过 --dart-define=USE_TEST_DEFAULT_LOGIN=true/false 覆盖
  static const bool useTestDefaultLogin = bool.fromEnvironment(
    'USE_TEST_DEFAULT_LOGIN',
    defaultValue: !kReleaseMode,
  );
}