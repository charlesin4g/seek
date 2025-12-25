import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/rustfs_config.dart';

/// RustFS 客户端
///
/// 仅负责基础客户端初始化和简单的 URL 构造，不在前端打印或记录任何密钥。
class RustFsClient {
  RustFsClient._internal({http.Client? client})
      : _client = client ?? http.Client(),
        baseUri = Uri.parse(RustFsConfig.endpoint),
        accessKey = RustFsConfig.accessKey,
        secretKey = RustFsConfig.secretKey;

  /// 全局共享实例
  static final RustFsClient instance = RustFsClient._internal();

  final Uri baseUri;
  final String accessKey;
  final String secretKey;
  final http.Client _client;

  /// 当前配置是否完整，可用于在启动时做一次自检
  bool get isConfigured =>
      RustFsConfig.enabled &&
      baseUri.toString().isNotEmpty &&
      accessKey.isNotEmpty &&
      secretKey.isNotEmpty;

  /// 构造对象访问的完整 URL（不做签名，适合公共读 bucket 或开发环境）
  Uri buildObjectUrl(String objectKey, {String? bucket}) {
    final String base = baseUri.toString().replaceAll(RegExp(r'/+\$'), '');
    final String effectiveBucket = bucket ?? RustFsConfig.defaultBucket;
    final String trimmedKey =
        objectKey.startsWith('/') ? objectKey.substring(1) : objectKey;
    final String path = effectiveBucket.isEmpty
        ? '/$trimmedKey'
        : '/$effectiveBucket/$trimmedKey';
    return Uri.parse('$base$path');
  }

  Future<String?> uploadImageBytes(
    Uint8List bytes, {
    String? objectKey,
    String contentType = 'image/jpeg',
    String? bucket,
  }) async {
    if (!isConfigured) {
      if (kDebugMode) {
        debugPrint(
          '[RustFS] uploadImageBytes: client is not configured. '
          'enabled=${RustFsConfig.enabled}, '
          'endpoint=${RustFsConfig.endpoint}',
        );
      }
      return null;
    }

    final String key = objectKey ??
        'activities/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final Uri url = buildObjectUrl(key, bucket: bucket);

    try {
      if (kDebugMode) {
        debugPrint('[RustFS] uploadImageBytes: PUT $url');
      }

      final http.Response res = await _client.put(
        url,
        headers: <String, String>{
          'Content-Type': contentType,
        },
        body: bytes,
      );

      if (kDebugMode) {
        debugPrint(
          '[RustFS] uploadImageBytes: response status=${res.statusCode}',
        );
      }

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return url.toString();
      }

      if (kDebugMode) {
        debugPrint(
          '[RustFS] uploadImageBytes: non-success status=${res.statusCode}, '
          'body=${res.body}',
        );
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[RustFS] uploadImageBytes: error while PUT $url: $e');
      }
      return null;
    }
  }

  /// 示例 ping 方法，可在应用启动时调用，用于验证 RustFS 服务是否可达。
  ///
  /// 为避免泄露配置信息，此处不会打印 accessKey/secretKey，也不会抛出详细错误。
  Future<void> ping() async {
    if (!isConfigured) {
      if (kDebugMode) {
        debugPrint(
          '[RustFS] ping: client is not configured. '
          'enabled=${RustFsConfig.enabled}, '
          'endpoint=${RustFsConfig.endpoint}',
        );
      }
      return;
    }

    try {
      if (kDebugMode) {
        debugPrint('[RustFS] ping: GET $baseUri');
      }

      final http.Response res = await _client.get(baseUri);

      if (kDebugMode) {
        debugPrint('[RustFS] ping: response status=${res.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[RustFS] ping: error while GET $baseUri: $e');
      }
    }
  }

  void dispose() {
    _client.close();
  }
}
