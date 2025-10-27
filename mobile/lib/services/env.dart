import 'package:flutter/foundation.dart';

/// 应用环境配置项
///
/// 说明：OSS 配置已迁移至 `lib/config/oss_config.dart`，不通过启动参数重配置。
class Env {
  // 是否在登录页启用测试默认值：admin/seek
  // 可通过 --dart-define=USE_TEST_DEFAULT_LOGIN=true/false 覆盖
  static const bool useTestDefaultLogin = bool.fromEnvironment(
    'USE_TEST_DEFAULT_LOGIN',
    defaultValue: !kReleaseMode,
  );

  /// 后端 API 基础地址（非 Web 平台默认 8080）
  /// 可通过 --dart-define=API_BASE_URL=... 覆盖，例如：https://api.example.com
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8080',
  );

  /// 后端 API 基础地址（Web 平台默认 8081）
  /// 可通过 --dart-define=API_BASE_URL_WEB=... 覆盖，例如：https://api-web.example.com
  static const String apiBaseUrlWeb = String.fromEnvironment(
    'API_BASE_URL_WEB',
    defaultValue: 'http://127.0.0.1:8081',
  );

  /// 根据平台返回后端基础地址（Web/非 Web）
  static String get backendBaseUrl => kIsWeb ? apiBaseUrlWeb : apiBaseUrl;
}