import 'http_client.dart';
import 'dart:convert';

class UserApi {
  /// 默认使用全局共享的 HttpClient
  UserApi({HttpClient? client}) : _client = client ?? HttpClient.shared;

  final HttpClient _client;

  // Login with username/password via GET query parameters
  Future<Map<String, dynamic>> login(String username, String password) async {
    final path =
        '/api/user/login?'
        'username=${Uri.encodeQueryComponent(username)}&'
        'password=${Uri.encodeQueryComponent(password)}';
    final raw = await _client.postJson(path);
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<Map<String, dynamic>> getUserByUsername(String username) async {
    final raw = await _client.getJson('/api/user/$username');
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> payload) async {
    final raw = await _client.postJson('/api/user', body: payload);
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<Map<String, dynamic>> updateUser(String username, Map<String, dynamic> payload) async {
    final raw = await _client.putJson('/api/user/$username', body: payload);
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<Map<String, dynamic>> deleteUser(String username) async {
    final raw = await _client.deleteJson('/api/user/$username');
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }
}
