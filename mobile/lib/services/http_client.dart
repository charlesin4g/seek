import 'dart:convert';
import 'package:http/http.dart' as http;
import 'offline_mode.dart';
import 'env.dart'; // 从 Env 读取后端地址配置

/// 统一异常类，方便上层区分处理
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String path;

  ApiException({
    required this.statusCode,
    required this.message,
    required this.path,
  });

  @override
  String toString() => 'ApiException($statusCode, $message, $path)';
}

class HttpClient {
  final String localBaseUrl = 'http://127.0.0.1:8080';
  // final String localAreaBaseUrl = 'http://172.16.115.42:8080';
  final String localAreaBaseUrl = 'http://192.168.3.24:8080';

  HttpClient({this.baseUrl = 'http://127.0.0.1:8080', http.Client? client})
    : _client = client ?? http.Client();

  /// 全局共享的 HttpClient 实例
  ///
  /// 说明：
  /// - 统一管理 baseUrl 与默认请求头；
  /// - 从 Env 读取后端地址（支持 dart-define 覆盖），并按平台切换；
  /// - 如需自定义，可在各 API 构造时显式传入自定义 HttpClient。
  static final HttpClient shared = HttpClient(baseUrl: Env.backendBaseUrl);

  final String baseUrl;
  final http.Client _client;

  Map<String, String> get defaultHeaders => const {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<String> getJson(
    String path, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final res = await _client
          .get(_uri(path), headers: {...defaultHeaders, ...?headers})
          .timeout(timeout);
      return _decodeJsonOrThrow(res, 'GET', path);
    } catch (e) {
      // 网络异常：自动切换离线
      await OfflineModeManager.instance.setOffline(true);
      rethrow;
    }
  }

  Future<String> postJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final res = await _client
          .post(
            _uri(path),
            headers: {...defaultHeaders, ...?headers},
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(timeout);
      return _decodeJsonOrThrow(res, 'POST', path);
    } catch (e) {
      await OfflineModeManager.instance.setOffline(true);
      rethrow;
    }
  }

  Future<String> putJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final res = await _client
          .put(
            _uri(path),
            headers: {...defaultHeaders, ...?headers},
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(timeout);
      return _decodeJsonOrThrow(res, 'PUT', path);
    } catch (e) {
      await OfflineModeManager.instance.setOffline(true);
      rethrow;
    }
  }

  Future<String> deleteJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final res = await _client
          .delete(
            _uri(path),
            headers: {...defaultHeaders, ...?headers},
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(timeout);
      return _decodeJsonOrThrow(res, 'DELETE', path);
    } catch (e) {
      await OfflineModeManager.instance.setOffline(true);
      rethrow;
    }
  }

  /// 统一错误体解析
  String _decodeJsonOrThrow(http.Response res, String method, String path) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return '';
      return res.body;
    }
    // 尝试解析统一错误体
    try {
      final map = jsonDecode(res.body) as Map<String, dynamic>;
      throw ApiException(
        statusCode: res.statusCode,
        message: map['message'] ?? 'Unknown error',
        path: path,
      );
    } catch (_) {
      // 解析失败则降级
      throw ApiException(
        statusCode: res.statusCode,
        message: res.reasonPhrase ?? 'Unknown error',
        path: path,
      );
    }
  }

  void close() => _client.close();
}
