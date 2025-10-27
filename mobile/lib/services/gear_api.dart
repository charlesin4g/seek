import 'http_client.dart';
import 'dart:convert';

class GearApi {
  /// 默认使用全局共享的 HttpClient
  GearApi({HttpClient? client}) : _client = client ?? HttpClient.shared;

  final HttpClient _client;

  Future<String> addGear(Map<String, dynamic> gearData) {
    return _client.putJson('/api/gear/add', body: gearData);
  }
  
  Future<List<Map<String, dynamic>>> getBrands() async {
    final raw = await _client.getJson('/api/gear/brands');
    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
  
  Future<List<String>> getCategories() async {
    final raw = await _client.getJson('/api/gear/category');
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((e) => (e as Map)['code']?.toString() ?? '')
        .where((code) => code.isNotEmpty)
        .toList();
  }

  Future<Map<String, String>> getCategoryDict() async {
    final raw = await _client.getJson('/api/gear/category');
    final decoded = jsonDecode(raw) as List;
    final Map<String, String> map = {};
    for (final e in decoded) {
      final m = e as Map;
      final code = m['code']?.toString();
      final name = m['name']?.toString();
      if (code != null && name != null) {
        map[code] = name;
      }
    }
    return map;
  }

  Future<List<Map<String, dynamic>>> getMyGear() async {
    final raw = await _client.getJson('/api/gear/my?owner=1');
    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> editGear(String gearId, Map<String, dynamic> gearData) async {
    await _client.postJson('/api/gear/edit?gearId=$gearId', body: gearData);
  }
}

class UserApi {
  /// 默认使用全局共享的 HttpClient
  UserApi({HttpClient? client}) : _client = client ?? HttpClient.shared;

  final HttpClient _client;

  Future<Map<String, dynamic>> getUserByUsername(String username) async {
    final raw = await _client.getJson('/api/user/$username');
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }
}
