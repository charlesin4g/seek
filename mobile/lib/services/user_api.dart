import 'dart:convert';
import 'dart:async';
import 'http_client.dart';

/// 用户管理 API，支持统一错误处理与重试
class UserApi {
  UserApi({HttpClient? client}) : _client = client ?? HttpClient.shared;

  final HttpClient _client;

  /// 默认重试策略：最多 3 次，指数退避
  static const int _maxRetries = 3;
  static const Duration _initialDelay = Duration(seconds: 1);

  // 统一异常转译，方便 UI 层提示
  Never _handleException(ApiException e, String operation) {
    switch (e.statusCode) {
      case 400:
        throw BadRequestException('$operation失败：${e.message}');
      case 401:
        throw UnauthorizedException('未登录或登录已过期');
      case 404:
        throw UserNotFoundException('用户不存在');
      case 409:
        throw ConflictException('数据冲突：${e.message}');
      case 500:
        throw ServerException('服务器内部错误');
      default:
        throw UnknownApiException('未知错误(${e.statusCode})：${e.message}');
    }
  }

  /// 带重试的请求包装
  Future<T> _retry<T>(Future<T> Function() fn, String operation) async {
    int attempt = 0;
    Duration delay = _initialDelay;
    while (true) {
      try {
        return await fn();
      } on ApiException catch (e) {
        _handleException(e, operation);
      } catch (e) {
        if (attempt >= _maxRetries - 1) rethrow;
        attempt++;
        await Future.delayed(delay);
        delay *= 2; // 指数退避
      }
    }
  }

  // 登录
  Future<Map<String, dynamic>> login(String username, String password) async {
    final path =
        '/api/user/login?'
        'username=${Uri.encodeQueryComponent(username)}&'
        'password=${Uri.encodeQueryComponent(password)}';
    return _retry(() async {
      final raw = await _client.postJson(path);
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    }, '登录');
  }

  // 查询用户
  Future<Map<String, dynamic>> getUserByUsername(String username) async {
    return _retry(() async {
      final raw = await _client.getJson('/api/user/$username');
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    }, '查询用户');
  }

  // 创建用户（注册）
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> payload) async {
    return _retry(() async {
      final raw = await _client.postJson('/api/user', body: payload);
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    }, '注册');
  }

  // 更新用户
  Future<Map<String, dynamic>> updateUser(String username, Map<String, dynamic> payload) async {
    return _retry(() async {
      final raw = await _client.putJson('/api/user/$username', body: payload);
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    }, '更新用户');
  }

  // 删除用户
  Future<void> deleteUser(String username) async {
    return _retry(() async {
      await _client.deleteJson('/api/user/$username');
    }, '删除用户');
  }
}

// 业务异常定义
class BadRequestException implements Exception {
  final String message;
  BadRequestException(this.message);
  @override
  String toString() => 'BadRequestException: $message';
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
  @override
  String toString() => 'UnauthorizedException: $message';
}

class UserNotFoundException implements Exception {
  final String message;
  UserNotFoundException(this.message);
  @override
  String toString() => 'UserNotFoundException: $message';
}

class ConflictException implements Exception {
  final String message;
  ConflictException(this.message);
  @override
  String toString() => 'ConflictException: $message';
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
  @override
  String toString() => 'ServerException: $message';
}

class UnknownApiException implements Exception {
  final String message;
  UnknownApiException(this.message);
  @override
  String toString() => 'UnknownApiException: $message';
}
