import 'http_client.dart';
import 'dart:convert';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // 统一使用共享 HttpClient，避免重复实例化与分散配置
  final HttpClient _http = HttpClient.shared;

  // Kept for backward compatibility; prefer using UserApi directly.
  Future<Map<String, dynamic>> getUserByUsername(String username) async {
    final raw = await _http.getJson('/api/user/$username');
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }
}
