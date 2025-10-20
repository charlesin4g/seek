import 'http_client.dart';
import 'dart:convert';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final HttpClient _http = HttpClient();

  // Kept for backward compatibility; prefer using UserApi directly.
  Future<Map<String, dynamic>> getUserByUsername(String username) async {
    final raw = await _http.getJson('/api/user/$username');
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }
}
