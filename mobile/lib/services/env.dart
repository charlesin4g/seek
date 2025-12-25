import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

/// 应用环境配置项
///
/// 说明：当前版本不再在前端使用 OSS 相关配置。
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

  /// 根据平台返回后端基础地址（Web/非 Web），自动适配模拟器与真机默认值
  /// 优先使用 `API_BASE_URL`，否则：
  /// - Web/iOS/macOS/windows/linux 默认 `127.0.0.1:8080`
  /// - Android 模拟器默认 `10.0.2.2:8080`
  static String get backendBaseUrl {
    if (apiBaseUrl.isNotEmpty) return apiBaseUrl;
    if (kIsWeb) return 'http://127.0.0.1:8080';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://127.0.0.1:8080';
  }
}
